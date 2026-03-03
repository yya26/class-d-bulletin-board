<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
Boolean ok = (Boolean)session.getAttribute("loggedIn");
if(ok == null || !ok){
  response.sendRedirect("login.jsp");
  return;
}

String loginUser = (String)session.getAttribute("username");

long id = Long.parseLong(request.getParameter("id"));

String title="";
String content="";
String author="";

try{
  Class.forName("oracle.jdbc.OracleDriver");
  Connection con = DriverManager.getConnection(
    "jdbc:oracle:thin:@//localhost:1521/orcl","info","pro");

  PreparedStatement ps = con.prepareStatement(
    "SELECT title, content, author_name FROM threads WHERE id=?");
  ps.setLong(1,id);
  ResultSet rs = ps.executeQuery();

  if(rs.next()){
    title = rs.getString("title");
    content = rs.getString("content");
    author = rs.getString("author_name").trim();
  }

  rs.close();
  ps.close();
  con.close();

}catch(Exception e){}

if(!loginUser.equals(author)){
  response.sendRedirect("board");
  return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>編集</title>
<link rel="stylesheet" href="css/thread.css">
</head>
<body>

<div class="container">
<div class="card">
<div class="pad">

<h2>スレッド編集</h2>

<form method="post" action="updateThread">
<input type="hidden" name="id" value="<%= id %>">

<div class="row">
<label>タイトル</label>
<input type="text" name="title" value="<%= title %>" required>
</div>

<div class="row">
<label>内容</label>
<textarea name="content" required><%= content %></textarea>
</div>

<div class="actions">
<button type="submit" class="btn">更新</button>
<button type="button" onclick="history.back()" class="btn secondary">戻る</button>
</div>

</form>

</div>
</div>
</div>

</body>
</html>