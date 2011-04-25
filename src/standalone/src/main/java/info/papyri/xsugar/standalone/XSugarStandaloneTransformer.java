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

import info.papyri.xsugar.standalone.TransformResult;

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
  
  private int grammar_hash;
  private JCS cache = null;
  
  public XSugarStandaloneTransformer()
  {
  
  }
  
  public XSugarStandaloneTransformer(String grammar)
    throws dk.brics.xsugar.XSugarException, IOException, ParseException, dk.brics.relaxng.converter.ParseException, InstantiationException,	IllegalAccessException, ClassNotFoundException
  {
    StylesheetParser parser = new StylesheetParser();
    
    grammar_hash = grammar.hashCode();
    System.out.println("Hash: " + grammar_hash);
    
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
    
    try {
      cache = JCS.getInstance("default");
    }
    catch (CacheException e) {
      System.out.println("Error initializing cache!");
    }
  }
  
  private String cacheKey(String direction, String text) {
    MD5 md5 = new MD5();
    
    try {
      md5.Update(text,null);
      return new String(grammar_hash + ":" + direction + ":" + md5.asHex());
    }
    catch (java.io.UnsupportedEncodingException e) {
      return new String(grammar_hash + ":" + direction + ":" + text);
    }
  }
  
  private void cachePut(String direction, String text, TransformResult result) {
    try {
      cache.put(cacheKey(direction,text),result);
    }
    catch (CacheException e) {
      System.out.println("Problem caching!");
    }
  }
  
  public String nonXMLToXML(String text)
    throws dk.brics.grammar.parser.ParseException
  {
    String result;
    
    TransformResult cache_result = (TransformResult)cache.get(cacheKey("nonxml2xml", text));
    if (cache_result == null) {
      System.out.println("Cache miss!");
      
      try {
        AST ast = parser_l.parse(text, "dummy.txt");
    
        result = unparsed_x_grammar.unparse(ast);
        result = end_tag.fix(result);
        result = namespace_adder.fix(result);
      }
      catch (dk.brics.grammar.parser.ParseException e) {
        cachePut("nonxml2xml",text,new TransformResult(e));
        throw e;
      }
      
      cachePut("nonxml2xml",text,new TransformResult(result));
    }
    else {
      System.out.println("Cache hit!");
      if (cache_result.isException()) {
        throw cache_result.exception;
      }
      else {
        result = cache_result.content;
      }
    }
    return result;
  }
  
  public String XMLToNonXML(String xml)
    throws org.jdom.JDOMException, dk.brics.grammar.parser.ParseException, IOException
  {
    String result;
    
    TransformResult cache_result = (TransformResult)cache.get(cacheKey("xml2nonxml",xml));
    if (cache_result == null) {
      System.out.println("Cache miss!");
      
      try {
        String input = norm.normalize(xml, "dummy.xml");
    
        AST ast = parser_x.parse(input, "dummy.xml");
        new ASTUnescaper().unescape(ast);
        result = unparsed_l_grammar.unparse(ast);
      }
      catch (dk.brics.grammar.parser.ParseException e) {
        cachePut("xml2nonxml",xml,new TransformResult(e));
        throw e;
      }
      
      cachePut("xml2nonxml",xml,new TransformResult(result));
    }
    else {
      System.out.println("Cache hit!");
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