<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>

<%
/* ===== LOGIN CHECK ===== */
Boolean ok = (Boolean)session.getAttribute("loggedIn");
if(ok == null || !ok){
  response.sendRedirect(request.getContextPath() + "/login.jsp");
  return;
}

/* ===== LOGIN USER FIX ===== */
String loginUser = (String)session.getAttribute("username"); // ✅ FIXED

/* ===== DB INFO ===== */
String dbUrl = System.getenv("ORACLE_URL");
String dbUser = System.getenv("ORACLE_USER");
String dbPass = System.getenv("ORACLE_PASS");
if(dbUrl==null) dbUrl="jdbc:oracle:thin:@//localhost:1521/orcl";
if(dbUser==null) dbUser="info";
if(dbPass==null) dbPass="pro";

/* ===== GET ID ===== */
long id = 0L;
try{ id = Long.parseLong(Optional.ofNullable(request.getParameter("id")).orElse("0")); }catch(Exception e){}
if(id<=0){
%>
<!doctype html>
<html lang="ja">
<head><meta charset="utf-8" /><title>Thread</title></head>
<body>Thread not found. <a href="board">Back</a></body>
</html>
<%
  return;
}

/* ===== DATA ===== */
String title=null, category=null, author=null, threadContent=null;
java.sql.Timestamp created=null;
List<Map<String,Object>> posts = new ArrayList<>();

try{
  Class.forName("oracle.jdbc.OracleDriver");
  try(Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass)){

    /* ===== THREAD INFO ===== */
    try(PreparedStatement ps = con.prepareStatement(
      "SELECT t.title, TRIM(t.author_name), t.content, t.created_at, c.name " +
      "FROM threads t LEFT JOIN categories c ON c.id=t.category_id WHERE t.id=?")){
      ps.setLong(1, id);
      try(ResultSet rs = ps.executeQuery()){
        if(rs.next()){
          title = rs.getString(1);
          author = rs.getString(2);
          threadContent = rs.getString(3);
          created = rs.getTimestamp(4);
          category = rs.getString(5);
        }
      }
    }

    /* ===== REPLIES WITH FILE ===== */
    try(PreparedStatement ps = con.prepareStatement(
      "SELECT TRIM(author_name), content, created_at, file_name " +
      "FROM replies WHERE thread_id=? ORDER BY created_at")){
      ps.setLong(1, id);
      try(ResultSet rs = ps.executeQuery()){
        while(rs.next()){
          Map<String,Object> p = new HashMap<>();
          p.put("author", rs.getString(1));
          p.put("content", rs.getString(2));
          p.put("created_at", rs.getTimestamp(3));
          p.put("file", rs.getString(4)); // ✅ NEW
          posts.add(p);
        }
      }
    }
  }
} catch(Exception ex){
  ex.printStackTrace();
}

/* ===== OWNER CHECK ===== */
boolean isOwner = false;
if(loginUser != null && author != null){
    isOwner = loginUser.trim().equals(author.trim());
}
%>

<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Classroom 掲示板 - スレッド</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/thread.css" />
</head>

<body>
<div class="container">

<!-- ===== HEADER ===== -->
<div class="header">
  <div class="brand">
    <div class="brand-left">
      <span class="badge"><%= category==null?"—":category %></span>
      <h1><%= title==null?"":title %></h1>
      <small>
        投稿者: <%= author==null?"":author %> ・
        作成: <%= created!=null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(created) : "" %>
      </small>
    </div>

    <div class="top-actions">
      <button class="btn secondary" onclick="location.href='board'">← 戻る</button>

      <% if(isOwner){ %>
        <a class="btn" href="edit.jsp?id=<%= id %>">編集</a>

        <form method="post" action="deleteThread"
              onsubmit="return confirm('このスレッドを削除しますか？');"
              style="display:inline;">
          <input type="hidden" name="id" value="<%= id %>">
          <button type="submit" class="btn danger">削除</button>
        </form>
      <% } %>
    </div>
  </div>
</div>

<!-- ===== THREAD CONTENT ===== -->
<div class="card" style="margin-top:16px">
  <div class="pad">
    <div class="reply-body">
      <%= threadContent==null?"":threadContent %>
    </div>
  </div>
</div>

<!-- ===== REPLY LIST ===== -->
<div class="card" style="margin-top:16px">
<div class="pad">
<div class="table-head">提出一覧</div>

<%
int idx = 1;
for(Map<String,Object> p: posts){
%>
<div class="reply">
  <div class="reply-head">
    <span>#<%= idx++ %> <%= (String)p.get("author") %></span>
    <span>
      <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm")
            .format((java.sql.Timestamp)p.get("created_at")) %>
    </span>
  </div>

  <div class="reply-body">
    <%= (String)p.get("content") %>
  </div>

  <% if(p.get("file") != null){ %>
    <div style="margin-top:8px;">
      📎 <a href="<%=request.getContextPath()%>/uploads/<%= p.get("file") %>" target="_blank">
        <%= p.get("file") %>
      </a>
    </div>
  <% } %>

</div>
<% } %>

</div>
</div>

<!-- ===== REPLY FORM (WITH FILE UPLOAD) ===== -->
<div class="card" style="margin-top:16px">
<div class="pad">
<h2>課題を提出する</h2>

<form method="post"
      action="<%=request.getContextPath()%>/reply-add"
      enctype="multipart/form-data">

  <input type="hidden" name="thread_id" value="<%= id %>" />

  <!-- <div class="row"> 
    <label>名前</label>
    <input name="replyAuthor" type="text" value="<%= loginUser %>" readonly />
  </div> -->

  <div class="row">
    <label>コメント</label>
    <textarea name="replyBody"></textarea>
  </div>

  <div class="row">
    <label>提出ファイル</label>
    <input type="file" name="uploadFile" />
  </div>

  <div class="actions">
    <button class="btn secondary" type="submit">提出</button>
  </div>

</form>
</div>
</div>

</div>
</body>
</html>