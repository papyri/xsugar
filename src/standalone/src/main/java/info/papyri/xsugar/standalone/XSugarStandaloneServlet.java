package info.papyri.xsugar.standalone;

import info.papyri.xsugar.splitter.EpiDocSplitter;
import info.papyri.xsugar.splitter.LeidenPlusSplitter;
import info.papyri.xsugar.splitter.SplitterJoiner;
import java.io.*;
import java.net.URL;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import javax.servlet.*;
import javax.servlet.http.*;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;

public class XSugarStandaloneServlet extends HttpServlet
{
  private HashMap<String,XSugarTransformerPool> transformers = null;
  private ConcurrentHashMap transformationLocks = null;

  private static String[] known_grammars = {"epidoc", "translation_epidoc","commentary"};

  /**
   * Servlet init, called upon first request.
   *
   * Initializes all known grammars.
   */
  @Override
  public void init(ServletConfig config)
    throws ServletException
  {
    super.init(config);

    transformers = new HashMap<String,XSugarTransformerPool>();
    transformationLocks = new ConcurrentHashMap();

    System.out.println("Initializing known-grammars...");
    for (String grammar : known_grammars) {
      System.out.println(grammar);
      initTransformerPool(grammar);
    }
    System.out.println("Done.");
  }

  /**
   * Initialize a transformer pool based on a string with the name (used to access a resource).
   */
  private XSugarTransformerPool initTransformerPool(String transformer_name)
  {
    XSugarTransformerPool transformer = null;
    URL url = this.getClass().getClassLoader().getResource(transformer_name + ".xsg");
    StringWriter url_writer = new StringWriter();

    try {
      IOUtils.copy(url.openStream(), url_writer, java.nio.charset.Charset.forName("UTF-8").name());

      transformer = new XSugarTransformerPool(new XSugarTransformerFactory(url_writer.toString()));
      transformers.put(transformer_name, transformer);
    }
    catch (IOException e) {
    }
    catch (Throwable t) {
    }

    return transformer;
  }

  /**
   * Get the transformer pool for a given name, optionally initializing it if not already present.
   */
  private XSugarTransformerPool getTransformerPool(String transformer_name)
  {
    XSugarTransformerPool transformer = transformers.get(transformer_name);
    if (transformer == null) {
      System.out.println("Cache miss for " + transformer_name);

      transformer = initTransformerPool(transformer_name);
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
      return direction.equals("xml2nonxml") ? transformer.XMLToNonXML(content) : transformer.nonXMLToXML(content);
    }
    catch (java.lang.StringIndexOutOfBoundsException e) {
      System.out.println("Split exception, doing transform normally");
      return direction.equals("xml2nonxml") ? transformer.XMLToNonXML(content) : transformer.nonXMLToXML(content);
    }
    if (split_results.size() == 1) {
      System.out.println("Single chunk, doing transform normally");
      return direction.equals("xml2nonxml") ? transformer.XMLToNonXML(content) : transformer.nonXMLToXML(content);
    }
    ArrayList<String> results_list = new ArrayList();
    System.out.println("Split into " + split_results.size());
    for (String split_item : split_results) {
      split_counter++;
      
      try {
        String item_result;
        if(direction.equals("xml2nonxml")) {
          item_result = transformer.XMLToNonXML(split_item);
        } else {
          item_result = transformer.nonXMLToXML(split_item);
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
            return transformer.nonXMLToXML(StringEscapeUtils.unescapeHtml(content));
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

    // normalize line endings
    content = content.replaceAll("\\r\\n", "\n");

    // Fetch transformer from pool and generate hash key
    XSugarTransformerPool pool = getTransformerPool(transform_type);
    XSugarStandaloneTransformer transformer = (XSugarStandaloneTransformer) pool.borrowObject();
    String key = transformer.cacheKey(direction, content);
    pool.returnObject(transformer);

    // We use ConcurrentHashMap's atomic putIfAbsent here because otherwise multiple threads
    // might obtain multiple locks.
    // If the hash of locks winds up growing too large (since we never prune it, but GC compacts it significantly
    // in my testing), we could swap out ReentrantLock for a CountDownLatch that calls await if we got
    // the latch from the map, or executes normally with countDown at the end if it doesn't (i.e.
    // we were the first thread to execute). Then at the end remove the CountDownLatch from the map.
    Lock transformationLock = (Lock) transformationLocks.putIfAbsent(key, new ReentrantLock(true));

    if (transformationLock == null) {
      transformationLock = (Lock)transformationLocks.get(key);
    }

    transformationLock.lock();
    System.out.println("Acquired lock for " + key);
    transformer = (XSugarStandaloneTransformer) pool.borrowObject();

    try {
      if (direction.equals("xml2nonxml"))
      {
        if (transform_type.contains("epidoc")) {
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
          result = transformer.XMLToNonXML(content);
        }
      }
      else if (direction.equals("nonxml2xml"))
      {
        if (transform_type.contains("epidoc")) {
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
          result = transformer.nonXMLToXML(StringEscapeUtils.unescapeHtml(content));
        }
      }
      else {
        result = "Bad direction " + direction;
      }
    }
    catch (Exception e) {
      System.out.println("Released lock for " + key);
      System.out.println(e.toString());
      // System.out.println(e.getLocation().getLine() + "," + e.getLocation().getColumn());
      // e.printStackTrace();
      throw e;
    }
    finally {
      pool.returnObject(transformer);
      transformationLock.unlock();
    }

    System.out.println("Released lock for " + key);

    return result;
  }

  /**
   * Handle a servlet GET request (serves an HTML form for making a POST request for a transform).
   */
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException
  {
    response.setContentType("text/html;charset=UTF-8");
    response.setHeader("Access-Control-Allow-Origin","*");
    response.setStatus(HttpServletResponse.SC_OK);
    PrintWriter out = response.getWriter();

    out.println("<html>");
    out.println("<head><title>XSugarStandaloneServlet</title></head>");
    out.println("<body>");
    out.println("<h1>XSugarStandaloneServlet</h1>");
    out.println("<form method=\"POST\" action=\"\"/>");
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
   * Handle a servlet OPTIONS request.
   */
  @Override
  protected void doOptions(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException
  {
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", request.getHeader("Access-Control-Request-Headers"));
    super.doOptions(request, response);
  }

  /**
   * Handle a servlet POST request (serves JSON result of running XSugar transform).
   */
  @Override
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
    response.setHeader("Access-Control-Allow-Origin","*");
    
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
      out.println("\"content\": \"" + StringEscapeUtils.escapeJavaScript(result).replace("\\'","'") + "\"");
    }
    else {
      out.println("\"content\": \"" + StringEscapeUtils.escapeJavaScript(param_content).replace("\\'","'") + "\",");
      out.println("\"exception\":");
        out.println("{");
          out.println("\"cause\": \"" + StringEscapeUtils.escapeJavaScript(cause).replace("\\'","'") + "\",");
          out.println("\"line\": " + line + ",");
          out.println("\"column\": " + column);
        out.println("}");
    }
    out.println("}");
  }
}
