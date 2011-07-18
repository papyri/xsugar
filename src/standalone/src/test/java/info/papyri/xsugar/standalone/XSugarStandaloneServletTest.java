package info.papyri.xsugar.standalone;

import java.io.*;

import org.junit.*;
import org.mortbay.jetty.testing.*;

public class XSugarStandaloneServletTest {
  private static ServletTester tester;
  private static String baseUrl;

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
}
