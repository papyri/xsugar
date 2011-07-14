package info.papyri.xsugar.standalone;

import java.io.*;
import java.net.URL;
import java.util.*;

import javax.servlet.*;
import javax.servlet.http.*;

import info.papyri.xsugar.standalone.XSugarStandaloneTransformer;
import info.papyri.xsugar.splitter.EpiDocSplitter;
import info.papyri.xsugar.splitter.LeidenPlusSplitter;
import info.papyri.xsugar.splitter.SplitterJoiner;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringEscapeUtils;

public class XSugarStandaloneServlet extends HttpServlet
{
  private Hashtable transformers = null;

  private static String[] known_grammars = {"epidoc", "translation_epidoc","commentary"};

  /**
   * Servlet init, called upon first request.
   *
   * Initializes all known grammars.
   */
  public void init(ServletConfig config)
    throws ServletException
  {
    super.init(config);

    transformers = new Hashtable();

    System.out.println("Initializing known-grammars...");
    for (String grammar : known_grammars) {
      System.out.println(grammar);
      initTransformer(grammar);
    }
    System.out.println("Done.");
  }

  /**
   * Initialize a transformer based on a string with the name (used to access a resource).
   */
  private XSugarStandaloneTransformer initTransformer(String transformer_name)
  {
    XSugarStandaloneTransformer transformer = null;
    URL url = this.getClass().getClassLoader().getResource("/" + transformer_name + ".xsg");
    StringWriter url_writer = new StringWriter();

    try {
      IOUtils.copy(url.openStream(), url_writer, java.nio.charset.Charset.forName("UTF-8").name());

      transformer = new XSugarStandaloneTransformer(url_writer.toString());
      transformers.put(transformer_name, transformer);
    }
    catch (IOException e) {
    }
    catch (Throwable t) {
    }

    return transformer;
  }

  /**
   * Get the transformer for a given name, optionally initializing it if not already present.
   */
  private XSugarStandaloneTransformer getTransformer(String transformer_name)
  {
    XSugarStandaloneTransformer transformer = 
      (XSugarStandaloneTransformer)transformers.get(transformer_name);
    if (transformer == null) {
      System.out.println("Cache miss for " + transformer_name);

      transformer = initTransformer(transformer_name);
    }
    return transformer;
  }
 
  /**
   * Perform an XSugar transform, trying to split the input and join the results.
   */ 
  private String doSplitTransform(String content, XSugarStandaloneTransformer transformer, String direction, SplitterJoiner splitter, SplitterJoiner joiner)
    throws org.jdom.JDOMException, dk.brics.grammar.parser.ParseException, Exception
  {
    //add counter to display with split processing to see which split we are working in
    int split_counter = 0;
    //line counter primed with 1 because the first chunk has only 1 line added at the end
    // and will subtract 2 for the lines added at beginning and end of a chunk below
    Integer line_counter = 0; 
    
    List<String> split_results = null;
    try {
       split_results = splitter.split(content);
    }
    catch (org.xml.sax.SAXParseException e) {
      System.out.println("SAX Parse exception, doing transform normally");
      return direction.equals("xml2nonxml") ? transformer.XMLToNonXML(content, split_counter) : transformer.nonXMLToXML(content, split_counter);
    }
    catch (java.lang.StringIndexOutOfBoundsException e) {
      System.out.println("Split exception, doing transform normally");
      return direction.equals("xml2nonxml") ? transformer.XMLToNonXML(content, split_counter) : transformer.nonXMLToXML(content, split_counter);
    }
    if (split_results.size() == 1) {
      System.out.println("Single chunk, doing transform normally");
      return direction.equals("xml2nonxml") ? transformer.XMLToNonXML(content, split_counter) : transformer.nonXMLToXML(content, split_counter);
    }
    ArrayList<String> results_list = new ArrayList();
    System.out.println("Split into " + split_results.size());
    for (String split_item : split_results) {
      split_counter++;
      
      try {
        String item_result = "";
        if(direction.equals("xml2nonxml")) {
          item_result = transformer.XMLToNonXML(split_item, split_counter);
        }
        else {
          item_result = transformer.nonXMLToXML(split_item, split_counter);
        }
        //add up the lines successfully transformed for adjusting line counter on parse exception if it occurs
        //subtract 2 for the lines added at the beginning and end of a chunk
        line_counter = line_counter + (StringUtils.countMatches(split_item, "\n") - 2);
        results_list.add(item_result);
      }
      catch (org.jdom.input.JDOMParseException e) {
        System.out.println("Error transforming:\n" + split_item + "\n message = " + e.getMessage() + "\n cause = " + e.getCause() + "\n line = " + e.getLineNumber() + "\n column = " + e.getColumnNumber() + "\n partial doc = " + e.getPartialDocument());
        throw e;
      }
      catch (dk.brics.grammar.parser.ParseException e) {
        if (direction.equals("nonxml2xml")) { 
          if (split_results.size() < 5) {
            System.out.println("Parse exception in small split transform, trying full transform");
            return transformer.nonXMLToXML(StringEscapeUtils.unescapeHtml(content), split_counter);
          }
          else {
            int error_line = e.getLocation().getLine();
            int error_col = e.getLocation().getColumn();
            e.setLocation(new dk.brics.grammar.parser.Location("dummy.txt", 0, error_line+line_counter, error_col)); //index, line, col
          }
        }
        else { //direction is xml2nonxml
          
          if (split_counter > 1) { //adjust line counter if error is not in the first chunk
            int error_line = e.getLocation().getLine();
            int error_col = e.getLocation().getColumn();
            e.setLocation(new dk.brics.grammar.parser.Location("dummy.txt", 0, error_line+line_counter, error_col)); //index, line, col
          }
        }
        throw e;
      } //catch ParseException
    } //for split_results loop
    System.out.println("Joining from " + results_list.size());
    return joiner.join(results_list);
  }

  /**
   * Perform an XSugar transform.
   *
   * @param content content to be transformed
   * @param transform_type type of transform (name of grammar)
   * @param direction direction of transform ("xml2nonxml" or "nonxml2xml")
   * @return string containing the result of running the transform
   */
  private String doTransform(String content, String transform_type, String direction)
    throws dk.brics.grammar.parser.ParseException, org.jdom.JDOMException, java.lang.Exception, java.io.IOException
  {
    String result = null;
    XSugarStandaloneTransformer transformer = getTransformer(transform_type);

    try {
      if (direction.equals("xml2nonxml"))
      {
        if (transform_type.equals("epidoc")) {
          try {
            result = doSplitTransform(content, transformer, direction, new EpiDocSplitter(), new LeidenPlusSplitter());
          }
          catch (dk.brics.grammar.parser.ParseException e) {
            throw e;
            // System.out.println("Parse exception in split transform, trying full transform");
            // result = transformer.XMLToNonXML(content);
          }
        }
        else {
          result = transformer.XMLToNonXML(content, 0);
        }
      }
      else if (direction.equals("nonxml2xml"))
      {
        if (transform_type.equals("epidoc")) {
          try {
            result = doSplitTransform(content, transformer, direction, new LeidenPlusSplitter(), new EpiDocSplitter());
          }
          catch (dk.brics.grammar.parser.ParseException e) {
            throw e;
            // System.out.println("Parse exception in split transform, trying full transform");
            // result = transformer.nonXMLToXML(StringEscapeUtils.unescapeHtml(content));
          }
        }
        else {
          result = transformer.nonXMLToXML(StringEscapeUtils.unescapeHtml(content), 0);
        }
      }
      else {
        result = "Bad direction " + direction;
      }
    }
    catch (dk.brics.grammar.parser.ParseException e) {
      System.out.println(e.getMessage());
      // System.out.println(e.getLocation().getLine() + "," + e.getLocation().getColumn());
      // e.printStackTrace();
      throw e;
    }

    return result;
  }

  /**
   * Handle a servlet GET request (serves an HTML form for making a POST request for a transform).
   */
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException
  {
    response.setContentType("text/html;charset=UTF-8");
    response.setStatus(HttpServletResponse.SC_OK);
    PrintWriter out = response.getWriter();

    out.println("<html>");
    out.println("<head><title>XSugarStandaloneServlet</title></head>");
    out.println("<body>");
    out.println("<h1>XSugarStandaloneServlet</h1>");
    out.println("<form method=\"POST\" action=\"/\"/>");
    out.println("<textarea name=\"content\" rows=\"20\" cols=\"80\"></textarea>");
    out.println("<select name=\"type\">");
    for (String grammar : known_grammars) {
      out.println("<option value=\"" + grammar + "\">" + grammar + "</option>");
    }
    out.println("</select>");
    out.println("<input type=\"radio\" name=\"direction\" value=\"xml2nonxml\" checked />XML->Non-XML&nbsp;&nbsp");
    out.println("<input type=\"radio\" name=\"direction\" value=\"nonxml2xml\" />Non-XML->XML<br />");
    out.println("<input type=\"submit\" value=\"Submit\" />");
    out.println("</form>");
    out.println("session=" + request.getSession(true).getId());
    out.println("</body>");
    out.println("</html>");
  }

  /**
   * Handle a servlet POST request (serves JSON result of running XSugar transform).
   */
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException
  {
    String param_content = request.getParameter("content");
    String param_type = request.getParameter("type");
    String param_direction = request.getParameter("direction");
    
    boolean parse_exception = false;
    String result = null;
    String cause = null;
    int line = 0;
    int column = 0;
    
    PrintWriter out = response.getWriter();

    response.setContentType("application/json;charset=UTF-8");
    
    try {
      result = doTransform(param_content, param_type, param_direction);
      response.setStatus(HttpServletResponse.SC_OK);
    }
    catch (dk.brics.grammar.parser.ParseException e) {
      response.setStatus(HttpServletResponse.SC_OK);
      parse_exception = true;
      cause = e.getMessage();
      line = e.getLocation().getLine();
      column = e.getLocation().getColumn();
    }
    catch (Throwable t) {
      response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      parse_exception = true;
      cause = "Unhandled error performing conversion. This is likely due to a large file containing a parse error, but due to the length of the file we are unable to fully parse it to indicate the position of the error.";
    }

    out.println("{");
    if (!parse_exception) {
      out.println("\"content\": \"" + StringEscapeUtils.escapeJavaScript(result) + "\"");
    }
    else {
      out.println("\"content\": \"" + StringEscapeUtils.escapeJavaScript(param_content) + "\",");
      out.println("\"exception\":");
        out.println("{");
          out.println("\"cause\": \"" + StringEscapeUtils.escapeJavaScript(cause) + "\",");
          out.println("\"line\": " + line + ",");
          out.println("\"column\": " + column);
        out.println("}");
    }
    out.println("}");
  }
}
