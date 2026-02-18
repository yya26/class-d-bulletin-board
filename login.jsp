<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = null;
if("POST".equalsIgnoreCase(request.getMethod())){
  String pw = request.getParameter("password");
  if(pw == null) pw = "";
  if("1234".equals(pw)){
    session.setAttribute("loggedIn", Boolean.TRUE);
    response.sendRedirect("index.jsp");
    return;
  } else {
    error = "パスワードが正しくありません";
  }
}
%>
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Classroom 掲示板 - ログイン</title>
  <!-- CSS ফাইলের সঠিক পথ -->
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/logindesign.css" />
</head>
<body>

  <!-- LOGIN CARD -->
  <div class="login-card">
    <h2 class="login-title">Classroom 掲示板</h2>
    <% if(error != null){ %>
      <div style="color:#dc2626; margin-bottom:10px; text-align:center;"><%= error %></div>
    <% } %>

    <form class="login-form" action="login.jsp" method="post" autocomplete="off">

      <label for="user-id">ユーザーID</label>
      <input type="text" id="user-id" name="user-id" placeholder="User ID" required />

      <label for="password">パスワード</label>
      <input type="password" id="password" name="password" placeholder="Password" required />

      <div class="login-actions">
        <button type="submit" class="login-button">ログイン</button>
      </div>

      
    </form>
  </div>

</body>

</html>
