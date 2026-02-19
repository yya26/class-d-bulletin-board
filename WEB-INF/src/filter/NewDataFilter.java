package filter;

import jakarta.servlet.*;
import util.DBUtil;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NewDataFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        List<String> categories = new ArrayList<>();
        try (Connection con = DBUtil.getConnection()) {
            try(Statement st = con.createStatement()){
                try(ResultSet rs = st.executeQuery("SELECT DISTINCT name FROM categories ORDER BY name")){
                    while(rs.next()) categories.add(rs.getString(1));
                }
            }
        } catch (Exception ignored) {}
        request.setAttribute("categories", categories);
        chain.doFilter(request, response);
    }
}
