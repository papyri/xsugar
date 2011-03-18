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

public class XSugarStandaloneTransformer
{
  private Stylesheet stylesheet = null;
  private Grammar l_grammar = null;
  private Grammar x_grammar = null;
  private Parser parser_l = null;
  private Parser parser_x = null;
  
  private Grammar normalized_l_grammar = null;
  
  public XSugarStandaloneTransformer()
  {
  
  }
  
  public XSugarStandaloneTransformer(String grammar)
    throws dk.brics.xsugar.XSugarException, IOException, ParseException, dk.brics.relaxng.converter.ParseException, InstantiationException,	IllegalAccessException, ClassNotFoundException
  {
    PrintWriter out = new PrintWriter(java.lang.System.out, true);
    String charset = java.nio.charset.Charset.forName("UTF-8").name();
    
    StylesheetParser parser = new StylesheetParser();
    
    Stylesheet stylesheet = parser.parse(grammar, "dummy.xsg", charset);
    new StylesheetChecker().check(stylesheet);
    GrammarBuilder grammar_builder = new GrammarBuilder(false);
    grammar_builder.convert(stylesheet);
    
    l_grammar = grammar_builder.getNonXMLGrammar();
    x_grammar = grammar_builder.getXMLGrammar();
    
    GrammarBuilder normalizing_grammar_builder = new GrammarBuilder(true);
    new StylesheetNormalizer().normalize(stylesheet);
    normalizing_grammar_builder.convert(stylesheet);
    normalized_l_grammar = normalizing_grammar_builder.getNonXMLGrammar();
    Grammar normalized_x_grammar = normalizing_grammar_builder.getXMLGrammar();

    parser_l = new Parser(l_grammar, out);
    parser_x = new Parser(normalized_x_grammar, out);
  }
  
  public String nonXMLToXML(String text)
    throws dk.brics.grammar.parser.ParseException
  {
    AST ast = parser_l.parse(text, "dummy.txt");
    
    String output = new Unparser(x_grammar).unparse(ast);
    output = new EndTagNameAdder().fix(output);
    output = new NamespaceAdder(stylesheet).fix(output);
    
    return output;
  }
  
  public String XMLToNonXML(String xml)
    throws org.jdom.JDOMException, dk.brics.grammar.parser.ParseException, IOException
  {
    InputNormalizer norm = new InputNormalizer();
    String input = norm.normalize(xml, "dummy.xml");
    
    AST ast = parser_x.parse(input, "dummy.xml");
    new ASTUnescaper().unescape(ast);
    String output = new Unparser(normalized_l_grammar).unparse(ast);
    
    return output;
  }
}