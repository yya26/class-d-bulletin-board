<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Classroom 掲示板 - ログイン</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/Classroom_Keijiban1111/styles.css" />
  <style>
    body{background:#f5f6f9; min-height:100vh; display:flex; align-items:center; justify-content:center; margin:0}
    .login-card{width:min(420px,92%); border-radius:14px; box-shadow:0 10px 30px rgba(15,23,42,.08); background:#fff; border:1px solid #e5e7eb}
    .login-pad{padding:18px}
    .login-title{display:flex; align-items:center; gap:8px; font-size:24px; margin:0 0 8px}
    .login-form label{display:block; font-weight:700; margin:10px 0 6px; color:#374151; font-size:13px}
    .login-form input{width:100%; border:1px solid #d9e2ef; border-radius:12px; padding:12px 14px; font:inherit; background:#fff}
    .login-actions{margin-top:12px; display:flex; align-items:center}
    .login-button{width:100%; border:1px solid #1e40af; color:#fff; background:#2563eb; padding:10px 14px; border-radius:8px; font-weight:600; cursor:pointer}
    .login-note{margin-top:8px; font-size:12px; color:#666; text-align:center}
  </style>
</head>
<body>
  <div class="login-card">
    <div class="login-pad">
      <h2 class="login-title">🔐 ログイン</h2>
      <form class="login-form" action="index.jsp">
        <label>ユーザーID</label>
        <input type="text" placeholder="User ID" required />
        <label>パスワード</label>
        <input type="password" placeholder="Password" required />
        <div class="login-actions">
          <button type="submit" class="login-button">ログイン</button>
        </div>
      </form>
      <div class="login-note">※ HTMLのみのデモ画面（認証・保存なし）</div>
    </div>
  </div>
</body>
</html>
