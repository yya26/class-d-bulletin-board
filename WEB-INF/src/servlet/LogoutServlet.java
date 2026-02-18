package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try{
            if(req.getSession(false)!=null){
                req.getSession(false).invalidate();
            }
        }catch(Exception ignored){}
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}
