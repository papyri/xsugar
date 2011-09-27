package info.papyri.xsugar.standalone;

import java.io.*;

import info.papyri.xsugar.standalone.XSugarStandaloneTransformer;

import org.apache.commons.pool.*;
import org.apache.commons.pool.impl.*;

public class XSugarTransformerFactory implements PoolableObjectFactory {
  public Object makeObject() {
    return new XSugarStandaloneTransformer();
  }

  public void passivateObject(Object obj) {
  }

  public void activateObject(Object obj) {
  }

  public boolean validateObject(Object obj) {
    return true;
  }

  public void destroyObject(Object obj) {
  }
}
