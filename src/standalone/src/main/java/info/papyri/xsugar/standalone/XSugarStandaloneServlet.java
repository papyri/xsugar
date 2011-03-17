package info.papyri.xsugar.standalone;
 
import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
 
public class XSugarStandaloneServlet extends HttpServlet
{
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
        String param_content = request.getParameter("content");
        String param_type = request.getParameter("type");
        String param_direction = request.getParameter("direction");
        
        PrintWriter out = response.getWriter();
        
        response.setContentType("text/html");
        response.setStatus(HttpServletResponse.SC_OK);

        out.println("<html>");
        out.println("<body>");
        out.println("You entered \"" + param_content + "\" into the text box.");
        out.println("</body>");
        out.println("</html>");
    }
}