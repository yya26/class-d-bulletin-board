<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%
String dbUrl = System.getenv("ORACLE_URL");
String dbUser = System.getenv("ORACLE_USER");
String dbPass = System.getenv("ORACLE_PASS");
if(dbUrl==null) dbUrl="jdbc:oracle:thin:@//localhost:1521/orcl";
if(dbUser==null) dbUser="info";
if(dbPass==null) dbPass="pro";
List<String> categories = new ArrayList<>();
try{
  Class.forName("oracle.jdbc.OracleDriver");
  try(Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass)){
  try(Statement st = con.createStatement()){
    try(ResultSet rs = st.executeQuery("SELECT DISTINCT name FROM categories ORDER BY name")){
      while(rs.next()) categories.add(rs.getString(1));
    }
  }
}
} catch(Exception ex){
  categories = java.util.Arrays.asList("お知らせ","宿題・提出物","授業のポイント","質問コーナー","自由メッセージ");
}
%>
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Classroom 掲示板 - 新規スレッド</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/newdesign.css" />
  <style>
    body{background:#f1f5f9;}
    .container{max-width:100%; margin:0; padding:0 16px;}
    .header{background:#ffffff; border:1px solid #e5e7eb; border-radius:16px; padding:18px; margin:12px 0;}
    .brand{display:flex; justify-content:space-between; align-items:center;}
    .top-actions{display:flex; gap:8px;}
    .grid.two{grid-template-columns: 1fr;}
    .card{width:100%; background:#ffffff; border:1px solid #e5e7eb; border-radius:16px; box-shadow:0 2px 6px rgba(0,0,0,0.04);}
    .pad{padding:18px;}
    form label.label{display:block; margin-top:10px; margin-bottom:6px; color:#334155;}
    form input, form select, form textarea{width:100%; border:1px solid #e2e8f0; border-radius:12px; padding:10px 12px; background:#f8fafc;}
    form textarea{min-height:140px; background:#ffffff;}
    .actions{display:flex; align-items:center; gap:12px; margin-top:14px;}
  </style>
</head>
<body>
  <div class="container">
  <div class="header pro-header">

    <div class="brand-row">
      <div class="title-block">
        <h1 class="page-title">新規スレッドを作成</h1>
       
      </div>

      <div class="navbar">
        <a class="btn secondary back-btn" href="board">
          <span class="arrow">←</span> 戻る
        </a>
      </div>
    </div>

  </div>
</div>

    <div class="grid two" style="margin-top:16px">
      <div class="card">
        <div class="pad">
          <h2></h2>
          
          <form method="post" id="newThreadForm" action="<%=request.getContextPath()%>/new-thread">
            <label class="label" for="category">カテゴリ</label>
            <select id="category" name="category" required>
              <option value="">選択...</option>
              <%
              for(String c: categories){
              %>
                <option><%= c %></option>
              <%
              }
              %>
            </select>
            <label class="label" for="title">タイトル</label>
            <input id="title" name="title" type="text" placeholder="例: 宿題の提出について" required />
            <div class="row">
              <div>
                <label class="label" for="author">名前</label>
                <input id="author" name="author" type="text" placeholder="名前" required />
              </div>
            </div>
            <label class="label" for="body">内容</label>
            <textarea id="body" name="body" placeholder="内容を書いてください" required></textarea>
            
           
    
            <div class="actions">
              <button class="btn secondary" type="submit">投稿</button>
              <span class="notice">ログインなし・超シンプル</span>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
