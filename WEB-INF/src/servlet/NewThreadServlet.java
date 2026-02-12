package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBUtil;
import java.io.IOException;
import java.sql.*;

public class NewThreadServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String category = param(req, "category");
        String title = param(req, "title");
        String author = param(req, "author");
        String body = param(req, "body");
        if (category.isEmpty() || title.isEmpty() || author.isEmpty() || body.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/new.jsp");
            return;
        }
        try (Connection con = DBUtil.getConnection()) {
            Long catId = null;
            try (PreparedStatement ps = con.prepareStatement("SELECT id FROM categories WHERE name=?")) {
                ps.setString(1, category);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) catId = rs.getLong(1);
                }
            }
            if (catId == null) {
                try (PreparedStatement ps = con.prepareStatement("INSERT INTO categories(name) VALUES(?)", Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, category);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) catId = rs.getLong(1);
                    }
                }
            }
            long threadId = 0L;
            try (PreparedStatement ps = con.prepareStatement("INSERT INTO threads(category_id,title,author_name,content,created_at,updated_at) VALUES(?,?,?,?,SYSDATE,SYSDATE)", Statement.RETURN_GENERATED_KEYS)) {
                if (catId == null) ps.setNull(1, Types.NUMERIC); else ps.setLong(1, catId);
                ps.setString(2, title);
                ps.setString(3, author);
                ps.setString(4, body);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) threadId = rs.getLong(1);
                }
            }
            if (threadId > 0) {
                try (PreparedStatement ps = con.prepareStatement("INSERT INTO replies(thread_id,author_name,content,created_at) VALUES(?,?,?,SYSDATE)")) {
                    ps.setLong(1, threadId);
                    ps.setString(2, author);
                    ps.setString(3, body);
                    ps.executeUpdate();
                }
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
}
