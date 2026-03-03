<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Classroom 掲示板 - 新規登録</title>

  <!-- Same CSS as login -->
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/logindesign.css" />
</head>
<body>

<div class="login-card">
  <h2 class="login-title">新規アカウント作成</h2>

  <% if(request.getParameter("error") != null){ %>
    <div style="color:#dc2626; margin-bottom:10px; text-align:center;">
      ユーザーIDは既に使用されています
    </div>
  <% } %>

  <!-- ✅ FIXED: post to /register (web.xml mapping) -->
  <form class="login-form"
        action="<%=request.getContextPath()%>/register"
        method="post"
        autocomplete="off">

    <label for="username">ユーザーID</label>
    <input type="text" id="username" name="username" placeholder="User ID" required />

    <label for="password">パスワード</label>
    <input type="password" id="password" name="password" placeholder="Password" required />

    <div class="login-actions">
      <button type="submit" class="login-button" style="background:#16a34a;">
        登録する
      </button>
    </div>

  </form>

  <hr style="margin:20px 0;">

  <div style="text-align:center;">
    <!-- ✅ FIXED: go back to /login (servlet) OR /login.jsp -->
    <a href="<%=request.getContextPath()%>/login" style="text-decoration:none;">
      <button type="button" class="login-button">
        ログイン画面へ戻る
      </button>
    </a>
  </div>

</div>

</body>
</html>