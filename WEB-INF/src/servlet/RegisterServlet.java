package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import util.DBUtil;

public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null ||
            username.isEmpty() || password.isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/register.jsp");
            return;
        }

        String checkSql = "SELECT 1 FROM USERS WHERE USERNAME = ?";
        String insertSql = "INSERT INTO USERS (USERNAME, PASSWORD) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {

            // Check duplicate username
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, username);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/register.jsp?error=1");
                        return;
                    }
                }
            }

            // Insert new user
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setString(1, username);
                insertPs.setString(2, password);
                insertPs.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=1");
            return;
        }

        // back to login servlet
        response.sendRedirect(request.getContextPath() + "/login");
    }
}