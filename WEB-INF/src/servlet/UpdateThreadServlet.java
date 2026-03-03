package servlet;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

import util.DBUtil;

@WebServlet("/updateThread")
public class UpdateThreadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        long id = Long.parseLong(request.getParameter("id"));
        String title = request.getParameter("title");
        String content = request.getParameter("content");

        String sql = "UPDATE threads SET title=?, content=?, updated_at=SYSDATE WHERE id=?";

        try(Connection con = DBUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, title);
            ps.setString(2, content);
            ps.setLong(3, id);

            ps.executeUpdate();

        } catch(Exception e){
            e.printStackTrace();
        }

        response.sendRedirect("thread.jsp?id=" + id);
    }
}