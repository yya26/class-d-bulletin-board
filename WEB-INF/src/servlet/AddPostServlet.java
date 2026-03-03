package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBUtil;
import java.io.IOException;
import java.sql.*;

public class AddPostServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long threadId = parseLong(req.getParameter("thread_id"));
        String author = param(req, "replyAuthor");
        String body = param(req, "replyBody");
        if (threadId <= 0 || author.isEmpty() || body.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }
        try (Connection con = DBUtil.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement("INSERT INTO replies(thread_id,author_name,content,created_at) VALUES(?,?,?,SYSDATE)")) {
                ps.setLong(1, threadId);
                ps.setString(2, author);
                ps.setString(3, body);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement("UPDATE threads SET updated_at=SYSDATE WHERE id=?")) {
                ps.setLong(1, threadId);
                ps.executeUpdate();
            }
            resp.sendRedirect(req.getContextPath() + "/thread.jsp?id=" + threadId);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v == null ? "" : v.trim();
    }
    private long parseLong(String v) {
        try { return Long.parseLong(v); } catch (Exception e) { return 0L; }
    }
}
