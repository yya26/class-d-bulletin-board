package filter;

import jakarta.servlet.*;
import util.DBUtil;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class ThreadDataFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        long id = 0L;
        try { id = Long.parseLong(Optional.ofNullable(request.getParameter("id")).orElse("0")); } catch (Exception ignored) {}
        if(id>0){
            String title=null, category=null, author=null, threadContent=null;
            java.sql.Timestamp created=null, updated=null;
            List<Map<String,Object>> posts = new ArrayList<>();
            try (Connection con = DBUtil.getConnection()) {
                try(PreparedStatement ps = con.prepareStatement("SELECT t.title,t.author_name,t.content,t.created_at,t.updated_at,c.name AS category FROM threads t LEFT JOIN categories c ON c.id=t.category_id WHERE t.id=?")){
                    ps.setLong(1, id);
                    try(ResultSet rs = ps.executeQuery()){
                        if(rs.next()){
                            title = rs.getString("title");
                            author = rs.getString("author_name");
                            threadContent = rs.getString("content");
                            created = rs.getTimestamp("created_at");
                            updated = rs.getTimestamp("updated_at");
                            category = rs.getString("category");
                        }
                    }
                }
                try(PreparedStatement ps = con.prepareStatement("SELECT author_name,content,created_at FROM replies WHERE thread_id=? ORDER BY created_at")){
                    ps.setLong(1, id);
                    try(ResultSet rs = ps.executeQuery()){
                        while(rs.next()){
                            Map<String,Object> p = new HashMap<>();
                            p.put("author", rs.getString(1));
                            p.put("content", rs.getString(2));
                            p.put("created_at", rs.getTimestamp(3));
                            posts.add(p);
                        }
                    }
                }
            } catch (Exception ignored) {}
            request.setAttribute("thread_title", title);
            request.setAttribute("thread_author", author);
            request.setAttribute("thread_category", category);
            request.setAttribute("thread_content", threadContent);
            request.setAttribute("thread_created", created);
            request.setAttribute("thread_updated", updated);
            request.setAttribute("thread_posts", posts);
        }
        chain.doFilter(request, response);
    }
}
