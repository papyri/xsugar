package info.papyri.xsugar.standalone;

import java.io.*;

import org.junit.*;
import static org.junit.Assert.*;
import org.mortbay.jetty.testing.*;

import org.apache.commons.lang.StringEscapeUtils;

public class XSugarStandaloneServletTest {
  private static ServletTester tester;
  private static String baseUrl;

  private static String exampleEpiDoc = "<div xml:lang=\"grc\" type=\"edition\" xml:space=\"preserve\" xmlns:xml=\"http://www.w3.org/XML/1998/namespace\">\n<ab>\n<lb n=\"1\"/>\n</ab></div>";
  private static String exampleLeidenPlus = "<S=.grc\n<=\n1. \n=>";

  @BeforeClass public static void initServletContainer ()
    throws Exception
  {
    tester = new ServletTester();
    tester.setContextPath("/");
    tester.addServlet(XSugarStandaloneServlet.class, "/xsugar");
    baseUrl = tester.createSocketConnector(true);
    tester.start();
  }

  @AfterClass
    public static void cleanupServletContainer ()
    throws Exception
  {
    tester.stop();
  }

  @Test
    public void testHttp ()
    throws Exception
  {
    HttpTester request = new HttpTester();
    HttpTester response = new HttpTester();

    request.setMethod("GET");
    request.setHeader("Host","tester");
    request.setURI("/xsugar");
    request.setVersion("HTTP/1.0");

    response.parse(tester.getResponses(request.generate()));
    System.out.println(response.getContent());
  }

  private void testGoodPostTransform(String input, String expected, String direction)
    throws Exception
  {
    HttpTester request = new HttpTester();
    HttpTester response = new HttpTester();

    request.setMethod("POST");
    request.setHeader("Host","tester");
    request.setHeader("Content-Type","application/x-www-form-urlencoded");
    request.setURI("/xsugar?content=" + java.net.URLEncoder.encode(input, "UTF-8") + "&type=epidoc&direction=" + direction);
    request.setVersion("HTTP/1.1");

    response.parse(tester.getResponses(request.generate()));
    System.out.println(response.getContent());
    assertEquals("{\n\"content\": \"" + StringEscapeUtils.escapeJavaScript(expected) + "\"\n}\n", response.getContent());
  }

  @Test
    public void testPost()
    throws Exception
  {
    testGoodPostTransform(exampleLeidenPlus, exampleEpiDoc, "nonxml2xml"); 
    testGoodPostTransform(exampleEpiDoc, exampleLeidenPlus, "xml2nonxml"); 
  }
}
