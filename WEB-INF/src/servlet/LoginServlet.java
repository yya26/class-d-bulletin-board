
package servlet;
import util.DB;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
public class LoginServlet extends HttpServlet {
 protected void doPost(HttpServletRequest r,HttpServletResponse s)throws ServletException,IOException{
  try(Connection c=DB.getConnection()){
   PreparedStatement p=c.prepareStatement("select * from users where user_id=? and password=?");
   p.setString(1,r.getParameter("userId"));
   p.setString(2,r.getParameter("password"));
   ResultSet rs=p.executeQuery();
   if(rs.next()){
    r.getSession().setAttribute("loginUser",r.getParameter("userId"));
    s.sendRedirect("threads");
   } else s.sendRedirect("login.jsp");
  }catch(Exception e){throw new ServletException(e);}
 }
}
