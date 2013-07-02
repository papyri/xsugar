package info.papyri.xsugar.standalone;

import java.io.*;

import org.jdom.JDOMException;
import org.xml.sax.SAXParseException;

import dk.brics.grammar.Grammar;
import dk.brics.grammar.ast.AST;
import dk.brics.grammar.operations.GrammarChecker;
import dk.brics.grammar.operations.Unparser;
import dk.brics.grammar.parser.Location;
import dk.brics.grammar.parser.ParseException;
import dk.brics.grammar.parser.Parser;
import dk.brics.misc.Loader;
import dk.brics.xmlgraph.XMLGraph;
import dk.brics.xsugar.reversibility.ReversibilityChecker;
import dk.brics.xsugar.stylesheet.*;
import dk.brics.xsugar.validator.*;
import dk.brics.xsugar.xml.*;
import dk.brics.xsugar.*;

import org.apache.jcs.JCS;
import org.apache.jcs.access.exception.CacheException;

import com.twmacinta.util.MD5;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import info.papyri.xsugar.standalone.TransformResult;

/**
 * Holds an instance of an XSugar transformer, with methods for performing transforms using it.
 */
public class XSugarStandaloneTransformer
{
  private Stylesheet stylesheet;
  private Grammar l_grammar;
  private Grammar x_grammar;
  private Parser parser_l;
  private Parser parser_x;
  
  private Grammar normalized_l_grammar;
  private Grammar normalized_x_grammar;
  
  private NamespaceAdder namespace_adder;
  private Unparser unparsed_l_grammar;
  private Unparser unparsed_x_grammar;
  
  private static PrintWriter out = new PrintWriter(java.lang.System.out, true);
  private static String charset = java.nio.charset.Charset.forName("UTF-8").name();
  
  private static InputNormalizer norm = new InputNormalizer();
  private static EndTagNameAdder end_tag = new EndTagNameAdder();
  
  private int grammar_hash = 0;
  private JCS cache = null;

  // We use a class-shared initialization lock because it seems that some things in
  // the XSugar initialization can get into race conditions/deadlock if multiple threads
  // call them at the same time.
  private static final Lock initializationLock = new ReentrantLock(true);

  /**
   * Initialize an empty transformer.
   */
  public XSugarStandaloneTransformer()
  {
  }
  
  /**
   * Initialize a transformer for a given XSugar grammar.
   */ 
  public XSugarStandaloneTransformer(String grammar)
    throws dk.brics.xsugar.XSugarException, IOException, ParseException, dk.brics.relaxng.converter.ParseException, InstantiationException,	IllegalAccessException, ClassNotFoundException
  {
    this.initializeTransformer(grammar);
  }

  public synchronized void initializeTransformer(String grammar)
    throws dk.brics.xsugar.XSugarException, IOException, ParseException, dk.brics.relaxng.converter.ParseException, InstantiationException,	IllegalAccessException, ClassNotFoundException
  {
    // This lock could probably be finer-grained, but this seems to solve the problem.
    initializationLock.lock();

    if(grammar_hash == 0) {
      grammar_hash = grammar.hashCode();
      System.out.println("Hash: " + grammar_hash);
      
      try {
        StylesheetParser parser = new StylesheetParser();

        stylesheet = parser.parse(grammar, "dummy.xsg", charset);
        new StylesheetChecker().check(stylesheet);
        GrammarBuilder grammar_builder = new GrammarBuilder(false);
        grammar_builder.convert(stylesheet);
        
        l_grammar = grammar_builder.getNonXMLGrammar();
        x_grammar = grammar_builder.getXMLGrammar();
        
        GrammarBuilder normalizing_grammar_builder = new GrammarBuilder(true);
        new StylesheetNormalizer().normalize(stylesheet);
        normalizing_grammar_builder.convert(stylesheet);
        normalized_l_grammar = normalizing_grammar_builder.getNonXMLGrammar();
        normalized_x_grammar = normalizing_grammar_builder.getXMLGrammar();
        
        parser_l = new Parser(l_grammar, out);
        parser_x = new Parser(normalized_x_grammar, out);
        
        unparsed_l_grammar = new Unparser(normalized_l_grammar);
        unparsed_x_grammar = new Unparser(x_grammar);
        
        namespace_adder = new NamespaceAdder(stylesheet);
      }
      catch (Throwable t) {
        System.out.println("Error initializing transformer for " + grammar_hash);
        grammar_hash = 0;
        initializationLock.unlock();
      }

      
      try {
        cache = JCS.getInstance("default");
      }
      catch (CacheException e) {
        System.out.println("Error initializing cache!");
      }
    }

    initializationLock.unlock();
  }

  /**
   * Generate the cache key for this transformer based on the direction and input text.
   *
   * Uses an MD5 of the input text, and generates keys in the form:
   *   grammar_hash:direction:inputmd5
   * So all of the entries for a grammar hash can be invalidated at once. 
   * See: http://jakarta.apache.org/jcs/faq.html#hierarchical-removal  
   */
  public String cacheKey(String direction, String text) {
    MD5 md5 = new MD5();
    
    try {
      md5.Update(text.getBytes(charset));
      return new String(grammar_hash + ":" + direction + ":" + md5.asHex());
    }
    catch (java.io.UnsupportedEncodingException e) {
      return new String(grammar_hash + ":" + direction + ":" + text);
    }
  }
 
  /**
   * Store a given transform result in the cache, rescuing cache exceptions. 
   */
  private void cachePut(String key, TransformResult result) {
    try {
      cache.put(key,result);
    }
    catch (CacheException e) {
      System.out.println("Problem caching!");
    }
  }
 
  /**
   * Use this transformer to convert a non-XML string to XML.
   */ 
  public synchronized String nonXMLToXML(String text)
    throws dk.brics.grammar.parser.ParseException
  {
    String result;
    text = java.text.Normalizer.normalize(text,java.text.Normalizer.Form.NFD);
    String key = cacheKey("nonxml2xml", text);
    
    TransformResult cache_result = (TransformResult)cache.get(key);
    if (cache_result == null) {
      try {
        AST ast = parser_l.parse(text, "dummy.txt");
    
        result = unparsed_x_grammar.unparse(ast);
        result = end_tag.fix(result);
        result = namespace_adder.fix(result);
        result = java.text.Normalizer.normalize(result,java.text.Normalizer.Form.NFC);
      }
      catch (dk.brics.grammar.parser.ParseException e) {
        System.out.println("nonXMLToXML parse exception L+ text = " + text);
        //cachePut(key,new TransformResult(e));
        //commented out so errors not put in cache - we are getting erroneous errors and can't get by them
        //when they are in cache because retry just pulls them again
        throw e;
      }
      
      cachePut(key,new TransformResult(result));
    }
    else {
      if (cache_result.isException()) {
        throw cache_result.exception;
      }
      else {
        result = cache_result.content;
      }
    }
    return result;
  }
 
  /**
   * Use this transformer to convert an XML string to its non-XML representation.
   */ 
  public synchronized String XMLToNonXML(String xml)
    throws org.jdom.JDOMException, dk.brics.grammar.parser.ParseException, IOException
  {
    String result;
    xml = java.text.Normalizer.normalize(xml,java.text.Normalizer.Form.NFC);
    String key = cacheKey("xml2nonxml",xml);
    
    TransformResult cache_result = (TransformResult)cache.get(key);
    if (cache_result == null) {
      try {
        String input = norm.normalize(xml, "dummy.xml");
    
        AST ast = parser_x.parse(input, "dummy.xml");
        new ASTUnescaper().unescape(ast);
        result = unparsed_l_grammar.unparse(ast);
        result = java.text.Normalizer.normalize(result,java.text.Normalizer.Form.NFD);
      }
      catch (dk.brics.grammar.parser.ParseException e) {
        System.out.println("XMLToNonXML parse exception XML = " + xml);
        //cachePut(key,new TransformResult(e));
        //see comment above in nonXMLToXML
        throw e;
      }
      
      cachePut(key,new TransformResult(result));
    }
    else {
      result = cache_result.content;
      if (cache_result.isException()) {
        throw cache_result.exception;
      }
      else {
        result = cache_result.content;
      }
    }
    return result;
  }
}
