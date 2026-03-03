<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Classroom 掲示板 - ログイン</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/logindesign.css" />
</head>
<body>

<div class="login-card">
  <h2 class="login-title">Classroom 掲示板</h2>

  <% if(request.getParameter("error") != null){ %>
    <div style="color:#dc2626; margin-bottom:10px; text-align:center;">
      ユーザーIDまたはパスワードが正しくありません
    </div>
  <% } %>

  <form class="login-form"
        action="<%=request.getContextPath()%>/login"
        method="post"
        autocomplete="off">

    <label for="username">ユーザーID</label>
    <input type="text" id="username" name="username" required />

    <label for="password">パスワード</label>
    <input type="password" id="password" name="password" required />

    <div class="login-actions">
      <button type="submit" class="login-button">ログイン</button>
    </div>

  </form>

  <hr style="margin:20px 0;">

  <div style="text-align:center;">
    <p>アカウントをお持ちでないですか？</p>

    <!-- ✅ SAFE: link styled like a button -->
    <a class="login-button"
       style="background:#16a34a; display:inline-block; text-decoration:none; text-align:center;"
       href="<%=request.getContextPath()%>/register.jsp">
      新規登録
    </a>
  </div>

</div>

</body>
</html>