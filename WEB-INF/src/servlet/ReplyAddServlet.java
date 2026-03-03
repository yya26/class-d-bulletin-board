package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;

import util.DBUtil;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,  // 1MB
    maxFileSize = 1024 * 1024 * 10,   // 10MB
    maxRequestSize = 1024 * 1024 * 15 // 15MB
)
public class ReplyAddServlet extends HttpServlet {

protected void doPost(HttpServletRequest request,
                      HttpServletResponse response)
        throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    HttpSession session = request.getSession(false);

    // ===== LOGIN CHECK =====
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String author = (String) session.getAttribute("username");

    String threadIdStr = request.getParameter("thread_id");
    String content = request.getParameter("replyBody");

    if (threadIdStr == null || threadIdStr.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/board");
        return;
    }

    long threadId = Long.parseLong(threadIdStr);

    Part filePart = request.getPart("uploadFile");
    String fileName = null;

    // ===== Save file if exists =====
    if (filePart != null && filePart.getSize() > 0) {

        fileName = Paths.get(filePart.getSubmittedFileName())
                .getFileName()
                .toString();

        String uploadPath = getServletContext().getRealPath("/uploads");

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        filePart.write(uploadPath + File.separator + fileName);
    }

    // ===== Insert into DB =====
    String sql = "INSERT INTO replies " +
            "(thread_id, author_name, content, created_at, file_name) " +
            "VALUES (?, ?, ?, SYSTIMESTAMP, ?)";

    try (Connection con = DBUtil.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setLong(1, threadId);
        ps.setString(2, author);
        ps.setString(3, content);
        ps.setString(4, fileName);

        ps.executeUpdate();

    } catch (Exception e) {
        e.printStackTrace();
    }

    response.sendRedirect(request.getContextPath() + "/thread?id=" + threadId);
}
}