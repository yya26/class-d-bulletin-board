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
boolean dbOk = true;
try{
  Class.forName("oracle.jdbc.OracleDriver");
  try(Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass)){
  try(Statement st = con.createStatement()){
    try(ResultSet rs = st.executeQuery("SELECT DISTINCT name FROM categories ORDER BY name")){
      while(rs.next()) categories.add(rs.getString(1));
    }
  }
  if("POST".equalsIgnoreCase(request.getMethod())){
    String category = Optional.ofNullable(request.getParameter("category")).orElse("").trim();
    String title = Optional.ofNullable(request.getParameter("title")).orElse("").trim();
    String author = Optional.ofNullable(request.getParameter("author")).orElse("").trim();
    String body = Optional.ofNullable(request.getParameter("body")).orElse("").trim();
    String imageData = Optional.ofNullable(request.getParameter("imageData")).orElse("").trim();
    String fileData = Optional.ofNullable(request.getParameter("fileData")).orElse("").trim();
    String fileName = Optional.ofNullable(request.getParameter("fileName")).orElse("").trim();
    if(imageData.length()>0){
      body = body + "<div class='imgwrap'><img src='"+imageData+"' /></div>";
    }
    if(fileData.length()>0){
      String fname = (fileName==null||fileName.isEmpty()) ? "添付ファイル" : fileName.replaceAll("[<>\"']", "");
      body = body + "<div class='filewrap'><a href='"+fileData+"' download='"+fname+"'>"+fname+"</a></div>";
    }
    if(category.length()>0 && title.length()>0 && author.length()>0 && body.length()>0){
      Long catId = null;
      try(PreparedStatement ps = con.prepareStatement("SELECT id FROM categories WHERE name=?")){
        ps.setString(1, category);
        try(ResultSet rs = ps.executeQuery()){
          if(rs.next()) catId = rs.getLong(1);
        }
      }
      if(catId==null){
        try(PreparedStatement ps = con.prepareStatement("INSERT INTO categories(name) VALUES(?)", Statement.RETURN_GENERATED_KEYS)){
          ps.setString(1, category);
          ps.executeUpdate();
          try(ResultSet rs = ps.getGeneratedKeys()){
            if(rs.next()) catId = rs.getLong(1);
          }
        }
      }
      long threadId = 0L;
      try(PreparedStatement ps = con.prepareStatement("INSERT INTO threads(category_id,title,author_name,content,created_at,updated_at) VALUES(?,?,?,?,SYSDATE,SYSDATE)", Statement.RETURN_GENERATED_KEYS)){
        if(catId==null) ps.setNull(1, Types.NUMERIC); else ps.setLong(1, catId);
        ps.setString(2, title);
        ps.setString(3, author);
        ps.setString(4, body);
        ps.executeUpdate();
        try(ResultSet rs = ps.getGeneratedKeys()){
          if(rs.next()) threadId = rs.getLong(1);
        }
      }
      if(threadId>0){
        try(PreparedStatement ps = con.prepareStatement("INSERT INTO replies(thread_id,author_name,content,created_at) VALUES(?,?,?,SYSDATE)")){
          ps.setLong(1, threadId);
          ps.setString(2, author);
          ps.setString(3, body);
          ps.executeUpdate();
        }
        response.sendRedirect("thread.jsp?id=" + threadId);
        return;
      }
    }
  }
}
} catch(Exception ex){
  dbOk = false;
  categories = java.util.Arrays.asList("お知らせ","宿題・提出物","授業のポイント","質問コーナー","自由メッセージ");
  if("POST".equalsIgnoreCase(request.getMethod())){
    response.sendRedirect("index.jsp");
    return;
  }
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
        <a class="btn secondary back-btn" href="index.jsp">
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
          
          <form method="post" id="newThreadForm">
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
  <script>
    (function(){
      var form=document.getElementById("newThreadForm");
      if(!form) return;
      var imgInput=document.getElementById("imageUpload");
      var imgData=document.getElementById("imageData");
      if(imgInput && imgData){
        imgInput.addEventListener("change", function(){
          try{
            var f=this.files && this.files[0];
            if(!f){ imgData.value=""; return; }
            if(!/^image\//.test(f.type)){ alert("画像ファイルを選択してください"); this.value=""; imgData.value=""; return; }
            if(f.size>2*1024*1024){ alert("画像サイズは2MB以下にしてください"); this.value=""; imgData.value=""; return; }
            var r=new FileReader();
            r.onload=function(){ imgData.value = r.result || ""; };
            r.readAsDataURL(f);
          }catch(e){ imgData.value=""; }
        });
      }
      var fileInput=document.getElementById("fileUpload");
      var fileData=document.getElementById("fileData");
      var fileName=document.getElementById("fileName");
      if(fileInput && fileData && fileName){
        fileInput.addEventListener("change", function(){
          try{
            var f=this.files && this.files[0];
            if(!f){ fileData.value=""; fileName.value=""; return; }
            if(f.size>5*1024*1024){ alert("ファイルサイズは5MB以下にしてください"); this.value=""; fileData.value=""; fileName.value=""; return; }
            var r=new FileReader();
            r.onload=function(){ fileData.value = r.result || ""; fileName.value = f.name || ""; };
            r.readAsDataURL(f);
          }catch(e){ fileData.value=""; fileName.value=""; }
        });
      }
      form.addEventListener("submit", function(){
        try{
          var cat=document.getElementById("category")?.value||"";
          var ttl=document.getElementById("title")?.value||"";
          var au=document.getElementById("author")?.value||"";
          var bd=document.getElementById("body")?.value||"";
          var img=document.getElementById("imageData")?.value||"";
          var fdata=document.getElementById("fileData")?.value||"";
          var fname=document.getElementById("fileName")?.value||"";
          if(!cat||!ttl||!au||!bd) return;
          var raw=localStorage.getItem("classd_fallback_threads");
          var arr=[]; try{arr=JSON.parse(raw)||[];}catch(e){arr=[];}
          var now=new Date().toISOString();
          var nextId=arr.length>0 ? Math.max.apply(null, arr.map(function(x){return Number(x.id)||0;}))+1 : 1;
          var full = bd;
          if(img) full += "<div class='imgwrap'><img src='"+img+"' /></div>";
          if(fdata) full += "<div class='filewrap'><a href='"+fdata+"' download='"+(fname||"添付ファイル")+"'>"+(fname||"添付ファイル")+"</a></div>";
          arr.push({id: nextId, title: ttl, category: cat, author: au, content: full, created_at: now, updated_at: now, reply_count: 0});
          localStorage.setItem("classd_fallback_threads", JSON.stringify(arr));
          localStorage.setItem("classd_last_thread_id", String(nextId));
        }catch(e){}
      });
    })();
  </script>
  <%
    if(!dbOk && "POST".equalsIgnoreCase(request.getMethod())){
  %>
  <script>
    (function(){
      var last = localStorage.getItem("classd_last_thread_id");
      if(last){ location.href = "thread.jsp?id=" + encodeURIComponent(last); }
    })();
  </script>
  <%
    }
  %>
</body>
</html>
