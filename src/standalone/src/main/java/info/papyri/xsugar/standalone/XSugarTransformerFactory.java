package info.papyri.xsugar.standalone;

import java.io.*;

import info.papyri.xsugar.standalone.XSugarStandaloneTransformer;

import org.apache.commons.pool.*;
import org.apache.commons.pool.impl.*;

public class XSugarTransformerFactory implements PoolableObjectFactory {
  private String grammar = null;

  public XSugarTransformerFactory(String input_grammar) {
    grammar = input_grammar;
  }
  
  public Object makeObject() {
    if(grammar == null) {
      return new XSugarStandaloneTransformer();
    }
    else {
      try {
        return new XSugarStandaloneTransformer(grammar);
      }
      catch (Throwable t) {
        return new XSugarStandaloneTransformer();
      }
    }
  }

  public void passivateObject(Object obj) {
  }

  public void activateObject(Object obj) {
    if(grammar != null) {
      if(obj instanceof XSugarStandaloneTransformer) {
        XSugarStandaloneTransformer transformer = (XSugarStandaloneTransformer) obj;
        try {
          transformer.initializeTransformer(grammar);
        }
        catch (Throwable t) {
        }
      }
    }
  }

  public boolean validateObject(Object obj) {
    return true;
  }

  public void destroyObject(Object obj) {
  }
}
