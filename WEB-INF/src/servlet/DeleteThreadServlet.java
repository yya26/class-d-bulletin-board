package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import util.DBUtil;

import java.io.IOException;
import java.sql.*;

public class DeleteThreadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        /* ===== LOGIN CHECK ===== */
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedIn") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String loginUser = (String) session.getAttribute("username");

        /* ===== GET THREAD ID ===== */
        long id = 0L;
        try {
            id = Long.parseLong(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendRedirect("board");
            return;
        }

        if (id <= 0) {
            resp.sendRedirect("board");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {

            /* ===== CHECK OWNER ===== */
            String author = null;

            try (PreparedStatement ps =
                    con.prepareStatement("SELECT author_name FROM threads WHERE id=?")) {

                ps.setLong(1, id);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        author = rs.getString(1);
                    }
                }
            }

            if (author == null || !author.equals(loginUser)) {
                // Not owner → no delete
                resp.sendRedirect("board");
                return;
            }

            /* ===== DELETE REPLIES FIRST ===== */
            try (PreparedStatement ps =
                    con.prepareStatement("DELETE FROM replies WHERE thread_id=?")) {

                ps.setLong(1, id);
                ps.executeUpdate();
            }

            /* ===== DELETE THREAD ===== */
            try (PreparedStatement ps =
                    con.prepareStatement("DELETE FROM threads WHERE id=?")) {

                ps.setLong(1, id);
                ps.executeUpdate();
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

        /* ===== SUCCESS ===== */
        resp.sendRedirect("board");
    }
}