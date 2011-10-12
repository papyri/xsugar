package info.papyri.xsugar.standalone;

import java.io.*;

import info.papyri.xsugar.standalone.XSugarTransformerFactory;

import org.apache.commons.pool.*;
import org.apache.commons.pool.impl.*;

public class XSugarTransformerPool extends GenericObjectPool {
  public XSugarTransformerPool(XSugarTransformerFactory objFactory) {
    super(objFactory);
    this.setMaxActive(64);
  }

  public XSugarTransformerPool(XSugarTransformerFactory objFactory, GenericObjectPool.Config config) {
    super(objFactory, config);
  }
}
