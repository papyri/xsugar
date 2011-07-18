/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package info.papyri.xsugar.splitter;

import java.io.*;
import java.util.List;
import javax.xml.parsers.*;
import org.xml.sax.*;
import org.xml.sax.helpers.DefaultHandler;
import junit.framework.TestCase;

/**
 *
 * @author hcayless
 */
public class EpiDocSplitterTest extends TestCase {

  public EpiDocSplitterTest(String testName) {
    super(testName);
    try {
      file = loadTestFile("badtext.xml");
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  String file;

  /**
   * Test of split method, of class EpiDocSplitter.
   */
  public void testSplit_String() throws Exception {
    System.out.println("split(String in)");
    String in = file;
    EpiDocSplitter instance = new EpiDocSplitter();
    List result = instance.split(in);
    assertEquals(in, instance.join(result));
  }

  /**
   * Test of split method, of class EpiDocSplitter.
   */
  public void testSplit_File() throws Exception {
    System.out.println("split(File in)");
    File in = new File(getClass().getClassLoader().getResource("o.claud.2.372.xml").toURI());
    EpiDocSplitter instance = new EpiDocSplitter();
    List<String> result = instance.split(in);
    String a = loadTestFile("o.claud.2.372.xml");
    System.out.println(a);
    String b = instance.join(result);
    System.out.println(b);
    assertEquals(loadTestFile("o.claud.2.372.xml"), instance.join(result));
  }

  /**
   * Test of split method, of class EpiDocSplitter.
   */
  public void testSplit_Reader() throws Exception {
    System.out.println("split(Reader in)");
    Reader reader = new InputStreamReader(getClass().getClassLoader().getResourceAsStream("badtext.xml"));
    EpiDocSplitter instance = new EpiDocSplitter();
    List result = instance.split(reader);
    assertEquals(file, instance.join(result));
  }

  /**
   * Test of join method, of class EpiDocSplitter.
   */
  public void testJoin() throws Exception {
    System.out.println("join");
    EpiDocSplitter instance = new EpiDocSplitter();
    List<String> in = instance.split(file);
    String expResult = file;
    String result = instance.join(in);
    assertEquals(expResult, result);
  }
  
  public void testWellFormedness() throws Exception {
    EpiDocSplitter instance = new EpiDocSplitter();
    File in = new File(getClass().getClassLoader().getResource("p.panop.beatty.2.xml").toURI());
    List<String> result = instance.split(in);
    SAXParserFactory factory = SAXParserFactory.newInstance();
    String currentChunk = null;
    try {
      for (String chunk : result) {
        currentChunk = chunk;
        SAXParser p = factory.newSAXParser();
        p.parse(new InputSource(new StringReader(chunk)), new DefaultHandler());
      }
    } catch (Exception e) {
      System.out.println(currentChunk);
      e.printStackTrace();
      assertTrue(false);
    }
    assertTrue(true);
  }

  private String loadTestFile(String in) throws Exception {
    Reader reader = new InputStreamReader(getClass().getClassLoader().getResourceAsStream(in));
    char[] buffer = new char[1024];
    int read = -1;
    StringBuilder file = new StringBuilder();
    while ((read = reader.read(buffer)) > 0) {
      file.append(buffer, 0, read);
    }
    return file.toString();
  }
}
