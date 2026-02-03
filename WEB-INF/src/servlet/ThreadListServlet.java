
package servlet;
import util.DB;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
public class ThreadListServlet extends HttpServlet {
 protected void doGet(HttpServletRequest r,HttpServletResponse s)throws ServletException,IOException{
  List<Map<String,Object>> list=new ArrayList<>();
  try(Connection c=DB.getConnection();
      PreparedStatement p=c.prepareStatement("select * from threads order by updated_at desc");
      ResultSet rs=p.executeQuery()){
   while(rs.next()){
    Map<String,Object> m=new HashMap<>();
    m.put("id",rs.getInt("id"));
    m.put("title",rs.getString("title"));
    m.put("author",rs.getString("author"));
    m.put("updatedAt",rs.getTimestamp("updated_at"));
    list.add(m);
   }
   r.setAttribute("threads",list);
   r.getRequestDispatcher("threads.jsp").forward(r,s);
  }catch(Exception e){throw new ServletException(e);}
 }
}
