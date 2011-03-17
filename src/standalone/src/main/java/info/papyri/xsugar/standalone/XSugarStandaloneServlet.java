package info.papyri.xsugar.standalone;

import java.io.*;
import java.net.URL;
import java.util.Hashtable;

import javax.servlet.*;
import javax.servlet.http.*;

import info.papyri.xsugar.standalone.XSugarStandaloneTransformer;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;

public class XSugarStandaloneServlet extends HttpServlet
{
    private Hashtable transformers = null;
    
    public void init(ServletConfig config) throws ServletException
    {
        super.init(config);
        
        transformers = new Hashtable();
    }
    
    private XSugarStandaloneTransformer getTransformer(String transformer_name)
    {
        XSugarStandaloneTransformer transformer = 
            (XSugarStandaloneTransformer)transformers.get(transformer_name);
        if (transformer == null) {
            System.out.println("Cache miss for " + transformer_name);
            transformer = new XSugarStandaloneTransformer();
            transformers.put(transformer_name, transformer);
        }
        return transformer;
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        response.setContentType("text/html");
        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().println("<h1>Hello Servlet</h1>");
        response.getWriter().println("session=" + request.getSession(true).getId());
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        URL url = this.getClass().getClassLoader().getResource("/epidoc.xsg");
        StringWriter url_writer = new StringWriter();
        IOUtils.copy(url.openStream(), url_writer);
        
        String param_content = request.getParameter("content");
        String param_type = request.getParameter("type");
        String param_direction = request.getParameter("direction");
        
        XSugarStandaloneTransformer transformer = getTransformer(param_type);
        
        PrintWriter out = response.getWriter();
        
        response.setContentType("text/html");
        response.setStatus(HttpServletResponse.SC_OK);

        out.println("<html>");
        out.println("<body>");
        out.println("You entered \"" + param_content + "\" into the text box.");
        out.println("Grammar:");
        out.println(url_writer.toString());
        // out.println(FileUtils.readFileToString(new File("epidoc.xsg")));
        out.println("</body>");
        out.println("</html>");
    }
}