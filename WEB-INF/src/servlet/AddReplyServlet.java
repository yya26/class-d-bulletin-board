
package servlet;
import util.DB;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
public class AddReplyServlet extends HttpServlet {
 protected void doPost(HttpServletRequest r,HttpServletResponse s)throws ServletException,IOException{
  int id=Integer.parseInt(r.getParameter("threadId"));
  try(Connection c=DB.getConnection()){
   PreparedStatement p=c.prepareStatement(
    "insert into replies(thread_id,author,body,created_at) values(?,?,?,now())");
   p.setInt(1,id);
   p.setString(2,r.getParameter("author"));
   p.setString(3,r.getParameter("body"));
   p.executeUpdate();
   s.sendRedirect("thread?id="+id);
  }catch(Exception e){throw new ServletException(e);}
 }
}
