package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import util.DBUtil;

import java.io.IOException;
import java.sql.*;
import java.util.*;

public class BoardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String q = Optional.ofNullable(req.getParameter("q")).orElse("").trim();
        String cat = Optional.ofNullable(req.getParameter("cat")).orElse("ALL").trim();

        List<Map<String,Object>> threads = new ArrayList<>();
        int totalThreads = 0;

        try (Connection con = DBUtil.getConnection()) {

            /* ===== COUNT ===== */
            try (Statement st = con.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM threads")) {
                if (rs.next()) totalThreads = rs.getInt(1);
            }

            /* ===== MAIN QUERY ===== */
            String sql =
                "SELECT t.id,t.title,t.author_name,t.content,t.created_at,t.updated_at," +
                "c.name AS category," +
                "(SELECT COUNT(*) FROM replies r WHERE r.thread_id=t.id) AS reply_count " +
                "FROM threads t LEFT JOIN categories c ON c.id=t.category_id";

            List<Object> params = new ArrayList<>();
            List<String> conds = new ArrayList<>();

            if (!q.isEmpty()) {
                conds.add("(LOWER(t.title) LIKE ? OR LOWER(t.author_name) LIKE ? OR LOWER(c.name) LIKE ?)");
                String qp = "%" + q.toLowerCase() + "%";
                params.add(qp);
                params.add(qp);
                params.add(qp);
            }

            if (!cat.isEmpty() && !"ALL".equalsIgnoreCase(cat)) {
                conds.add("c.name = ?");
                params.add(cat);
            }

            if (!conds.isEmpty()) {
                sql += " WHERE " + String.join(" AND ", conds);
            }

            sql += " ORDER BY NVL(t.updated_at,t.created_at) DESC";

            try (PreparedStatement ps = con.prepareStatement(sql)) {

                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {
                        Map<String,Object> row = new HashMap<>();

                        row.put("id", rs.getLong("id"));
                        row.put("title", rs.getString("title"));
                        row.put("author", rs.getString("author_name"));
                        row.put("content", rs.getString("content"));
                        row.put("created_at", rs.getTimestamp("created_at"));
                        row.put("updated_at", rs.getTimestamp("updated_at"));
                        row.put("category", rs.getString("category"));
                        row.put("reply_count", rs.getInt("reply_count"));

                        threads.add(row);
                    }
                }
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

        /* ===== SEND TO JSP ===== */
        req.setAttribute("threads", threads);
        req.setAttribute("q", q);
        req.setAttribute("cat", cat);
        req.setAttribute("totalThreads", totalThreads);

        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}