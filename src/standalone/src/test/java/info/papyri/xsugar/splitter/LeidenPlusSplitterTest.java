/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package info.papyri.xsugar.splitter;

import java.io.*;
import java.net.URI;
import java.nio.charset.Charset;
import java.util.List;
import junit.framework.TestCase;

/**
 *
 * @author hcayless
 */
public class LeidenPlusSplitterTest extends TestCase {

  public LeidenPlusSplitterTest(String testName) {
    super(testName);
    try {
      file = loadTestFile("leidenplus.txt");
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  String file;

  /**
   * Test of split method, of class LeidenPlusSplitter.
   */
  public void testSplit_String() throws Exception {
    System.out.println("split(String in)");
    String in = file;
    LeidenPlusSplitter instance = new LeidenPlusSplitter();
    List result = instance.split(in);
    String join = instance.join(result);
    assertEquals(in, join);
  }

  /**
   * Test of split method, of class LeidenPlusSplitter.
   */
  public void testSplit_File() throws Exception {
    System.out.println("split(File in)");
    File in = new File(getClass().getClassLoader().getResource("p.panop.beatty.1.txt").toURI());
    LeidenPlusSplitter instance = new LeidenPlusSplitter();
    List<String> result = instance.split(in);
    int i = 1;
    for (String s : result) {
      File f = new File(new URI(getClass().getClassLoader().getResource("p.panop.beatty.1.txt").toExternalForm().replace(".txt", "-" + i + ".txt")));
      FileOutputStream out = new FileOutputStream(f);
      out.write(s.getBytes());
      out.close();
      i++;
    }
    assertEquals(loadTestFile("p.panop.beatty.1.txt"), instance.join(result));
  }

  /**
   * Test of split method, of class LeidenPlusSplitter.
   */
  public void testSplit_Reader() throws Exception {
    System.out.println("split(Reader in)");
    Reader reader = new InputStreamReader(getClass().getClassLoader().getResourceAsStream("leidenplus.txt"));
    LeidenPlusSplitter instance = new LeidenPlusSplitter();
    List result = instance.split(reader);
    assertEquals(file, instance.join(result));
  }

  /**
   * Test of join method, of class LeidenPlusSplitter.
   */
  public void testJoin() throws Exception {
    System.out.println("join");
    LeidenPlusSplitter instance = new LeidenPlusSplitter();
    List<String> in = instance.split(file);
    String expResult = file;
    String result = instance.join(in);
    assertEquals(expResult, result);
  }
  
  /**
   * Test splitting a translation
   */
  public void testTranslation() throws Exception {
    System.out.println("split(Reader in)");
    String translation = loadTestFile("translation.txt");
    Reader reader = new InputStreamReader(getClass().getClassLoader().getResourceAsStream("translation.txt"));
    LeidenPlusSplitter instance = new LeidenPlusSplitter();
    List result = instance.split(reader);
    System.out.println("Chunks: " + result.size());
    assertEquals(translation, instance.join(result));
  }

  private String loadTestFile(String in) throws Exception {
    Reader reader = new InputStreamReader(getClass().getClassLoader().getResourceAsStream(in));
    char[] buffer = new char[1024];
    int read;
    StringBuilder sb = new StringBuilder();
    while ((read = reader.read(buffer)) > 0) {
      sb.append(buffer, 0, read);
    }
    return sb.toString();
  }
}
