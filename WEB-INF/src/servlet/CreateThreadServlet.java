
package servlet;
import util.DB;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
public class CreateThreadServlet extends HttpServlet {
 protected void doPost(HttpServletRequest r,HttpServletResponse s)throws ServletException,IOException{
  try(Connection c=DB.getConnection()){
   PreparedStatement p=c.prepareStatement(
    "insert into threads(category,title,author,body,updated_at) values(?,?,?,?,now())");
   p.setString(1,r.getParameter("category"));
   p.setString(2,r.getParameter("title"));
   p.setString(3,r.getParameter("author"));
   p.setString(4,r.getParameter("body"));
   p.executeUpdate();
   s.sendRedirect("threads");
  }catch(Exception e){throw new ServletException(e);}
 }
}
