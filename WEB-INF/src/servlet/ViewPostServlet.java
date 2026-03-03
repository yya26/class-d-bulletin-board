package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class ViewPostServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String id = req.getParameter("id");
        if (id == null || id.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/board");
            return;
        }

        // Forward to JSP (keeps URL as /thread?id=...)
        req.getRequestDispatcher("/thread.jsp").forward(req, resp);
    }
}