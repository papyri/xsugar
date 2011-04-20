package info.papyri.xsugar.standalone;

import java.io.Serializable;

public class TransformResult implements Serializable
{
  public String content = null;
  public dk.brics.grammar.parser.ParseException exception = null;
  
  public TransformResult() {}
  
  public TransformResult(String set_content) {
    content = set_content;
  }
  
  public TransformResult(dk.brics.grammar.parser.ParseException set_exception) {
    exception = set_exception;
  }
  
  public TransformResult(String set_content, dk.brics.grammar.parser.ParseException set_exception) {
    content = set_content;
    exception = set_exception;
  }
  
  public boolean isException() {
    return exception != null;
  }
}