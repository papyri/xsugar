package info.papyri.xsugar.standalone;

import java.io.*;

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

public class XSugarStandaloneTransformer
{
  public XSugarStandaloneTransformer()
  {
  
  }
  
  public XSugarStandaloneTransformer(String grammar)
  {
    String charset = java.nio.charset.Charset.forName("UTF-8").name();
    
    dk.brics.xsugar.StylesheetParser parser = new dk.brics.xsugar.StylesheetParser();
  }
}