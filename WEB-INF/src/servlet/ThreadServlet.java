
package servlet;
import util.DB;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
public class ThreadServlet extends HttpServlet {
 protected void doGet(HttpServletRequest r,HttpServletResponse s)throws ServletException,IOException{
  int id=Integer.parseInt(r.getParameter("id"));
  try(Connection c=DB.getConnection()){
   PreparedStatement t=c.prepareStatement("select * from threads where id=?");
   t.setInt(1,id);
   ResultSet tr=t.executeQuery();
   if(tr.next()) r.setAttribute("thread",tr);
   PreparedStatement p=c.prepareStatement("select * from replies where thread_id=? order by created_at");
   p.setInt(1,id);
   ResultSet rs=p.executeQuery();
   List<ResultSet> replies=new ArrayList<>();
   while(rs.next()) replies.add(rs);
   r.setAttribute("replies",replies);
   r.getRequestDispatcher("thread.jsp").forward(r,s);
  }catch(Exception e){throw new ServletException(e);}
 }
}
