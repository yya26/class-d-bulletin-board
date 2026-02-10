<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%
String dbUrl = System.getenv("ORACLE_URL");
String dbUser = System.getenv("ORACLE_USER");
String dbPass = System.getenv("ORACLE_PASS");
if(dbUrl==null) dbUrl="jdbc:oracle:thin:@//localhost:1521/orcl";
if(dbUser==null) dbUser="info";
if(dbPass==null) dbPass="pro";
long id = 0L;
try{ id = Long.parseLong(Optional.ofNullable(request.getParameter("id")).orElse("0")); }catch(Exception e){}
if(id<=0){
%>
<!doctype html>
<html lang="ja"><head><meta charset="utf-8" /><link rel="stylesheet" href="Classroom_Keijiban1111/styles.css" /><title>Thread</title></head><body><div class="container"><div class="card"><div class="pad">Thread not found. <a href="index.jsp">Back</a></div></div></div></body></html>
<%
  return;
}
String title=null, category=null, author=null;
java.sql.Timestamp created=null, updated=null;
List<Map<String,Object>> posts = new ArrayList<>();
try{
  Class.forName("oracle.jdbc.OracleDriver");
  try(Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass)){
  if("POST".equalsIgnoreCase(request.getMethod())){
    String replyAuthor = Optional.ofNullable(request.getParameter("replyAuthor")).orElse("").trim();
    String replyBody = Optional.ofNullable(request.getParameter("replyBody")).orElse("").trim();
    String imageData = Optional.ofNullable(request.getParameter("imageData")).orElse("").trim();
    if(replyAuthor.length()>0 && replyBody.length()>0){
      try(PreparedStatement ps = con.prepareStatement("INSERT INTO replies(thread_id,author_name,content,created_at) VALUES(?,?,?,SYSDATE)")){
        ps.setLong(1, id);
        ps.setString(2, replyAuthor);
        if(imageData.length()>0){
          ps.setString(3, replyBody + "<div class='imgwrap'><img src='"+imageData+"' /></div>");
        }else{
          ps.setString(3, replyBody);
        }
        ps.executeUpdate();
      }
      try(PreparedStatement ps = con.prepareStatement("UPDATE threads SET updated_at=SYSDATE WHERE id=?")){
        ps.setLong(1, id);
        ps.executeUpdate();
      }
      response.sendRedirect("thread.jsp?id=" + id);
      return;
    }
  }
  try(PreparedStatement ps = con.prepareStatement("SELECT t.title,t.author_name,t.created_at,t.updated_at,c.name AS category FROM threads t LEFT JOIN categories c ON c.id=t.category_id WHERE t.id=?")){
    ps.setLong(1, id);
    try(ResultSet rs = ps.executeQuery()){
      if(rs.next()){
        title = rs.getString("title");
        author = rs.getString("author_name");
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
  }
} catch(Exception ex){
  // allow client-side fallback rendering
}
%>
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Classroom 掲示板 - スレッド</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/Classroom_Keijiban1111/styles.css" />
  <style>
    body{background:#f1f5f9;}
    .container{max-width:100%; margin:0; padding:0 16px;}
    .header{background:#ffffff; border:1px solid #e5e7eb; border-radius:16px; padding:18px; margin:12px 0;}
    .brand{display:flex; justify-content:space-between; align-items:center;}
    .top-actions{display:flex; gap:8px;}
    .card{width:100%; background:#ffffff; border:1px solid #e5e7eb; border-radius:16px; box-shadow:0 2px 6px rgba(0,0,0,0.04);}
    .pad{padding:18px;}
    .badge{background:#f1f5f9; border:1px solid #e2e8f0; padding:4px 10px; border-radius:999px;}
    .table-head{background:#eaf2ff; border:1px solid #d6e4ff; border-top-left-radius:12px; border-top-right-radius:12px; padding:10px 16px; color:#334155; font-weight:600;}
    table{width:100%;}
    table thead th{background:#eef2ff; border-bottom:1px solid #e5e7eb;}
    thead th:nth-child(1), thead th:nth-child(4){text-align:center;}
    thead th:nth-child(2), td:nth-child(2){text-align:left;}
    thead th:nth-child(3), td:nth-child(3){text-align:left;}
    #postsBody tr td{padding-top:12px; padding-bottom:12px;}
    form label.label{display:block; margin-top:10px; margin-bottom:6px; color:#334155;}
    form input, form textarea{width:100%; border:1px solid #e2e8f0; border-radius:12px; padding:10px 12px; background:#f8fafc;}
    form textarea{min-height:140px; background:#ffffff;}
    .actions{display:flex; align-items:center; gap:12px; margin-top:14px;}
    .footer-note{margin:12px 4px; color:#64748b;}
    .imgwrap{margin-top:10px}
    .imgwrap img{max-width:100%; border-radius:12px; display:block}
  </style>
</head>
<body>
  <div class="container" id="threadWrap">
    <div class="header">
      <div class="brand">
        <div>
          <h1 class="thread-title" id="tTitle"><%= title %></h1>
          <small id="tMeta"><%= (author!=null && created!=null) ? ("投稿者: "+author+" • 作成: "+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(created)+" • 更新: "+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(updated!=null?updated:created)) : "" %></small>
        </div>
        <div class="top-actions">
          <span class="badge" id="tBadge"><%= category==null?"—":category %></span>
          <button class="btn secondary" type="button" onclick="location.href='index.jsp'">← 戻る</button>
          <a class="btn secondary" href="new.jsp">+ 新規スレッド</a>
        </div>
      </div>
      <div class="navbar">
        <div class="right">
          <a class="btn" href="index.jsp">スレッド一覧</a>
        </div>
      </div>
    </div>
    <div class="card" style="margin-top:16px">
      <div class="pad">
        <div class="table-head">返信一覧</div>
        <table style="table-layout:fixed">
          <colgroup>
            <col style="width:80px" />
            <col style="width:160px" />
            <col />
            <col style="width:170px" />
          </colgroup>
          <thead>
            <tr>
              <th style="width:80px">番号</th>
              <th style="width:160px">名前</th>
              <th>内容</th>
              <th style="width:170px">日時</th>
            </tr>
          </thead>
          <tbody id="postsBody">
            <%
            int idx = 1;
            for(Map<String,Object> p: posts){
            %>
            <tr>
              <td>#<%= idx++ %></td>
              <td><%= (String)p.get("author") %></td>
              <td><%= (String)p.get("content") %></td>
              <td><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format((java.sql.Timestamp)p.get("created_at")) %></td>
            </tr>
            <%
            }
            %>
          </tbody>
        </table>
      </div>
    </div>
    <div class="card" style="margin-top:14px">
      <div class="pad">
        <h2>返信する</h2>
        <form method="post" id="replyForm">
          <div class="row">
            <div>
              <label class="label" for="replyAuthor">名前</label>
              <input id="replyAuthor" name="replyAuthor" type="text" placeholder="名前" required />
            </div>
          </div>
          <label class="label" for="replyBody">返信内容</label>
          <textarea id="replyBody" name="replyBody" placeholder="返信を書いてください" required></textarea>
          <label class="label" for="imageUpload">画像をアップロード</label>
          <input id="imageUpload" type="file" accept="image/*" />
          <input type="hidden" id="imageData" name="imageData" />
          <div class="actions">
            <button class="btn secondary" type="submit">返信</button>
            <span class="notice">名前 + 返信だけ</span>
          </div>
        </form>
      </div>
    </div>
    <div class="footer-note">Tip: 先生にスクショを見せればOK（BBSっぽい）</div>
  </div>
  <script>
    (function(){
      var file=document.getElementById("imageUpload");
      var hid=document.getElementById("imageData");
      if(file && hid){
        file.addEventListener("change", function(){
          try{
            var f=this.files && this.files[0];
            if(!f){ hid.value=""; return; }
            if(!/^image\//.test(f.type)){ alert("画像ファイルを選択してください"); this.value=""; hid.value=""; return; }
            if(f.size>2*1024*1024){ alert("画像サイズは2MB以下にしてください"); this.value=""; hid.value=""; return; }
            var r=new FileReader();
            r.onload=function(){ hid.value = r.result || ""; };
            r.readAsDataURL(f);
          }catch(e){ hid.value=""; }
        });
      }
    })();
  </script>
  <script>
    (function(){
      function esc(s){return String(s).replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#39;");}
      function fmt(iso){
        try{var d=new Date(iso);var p=n=>String(n).padStart(2,"0");return d.getFullYear()+"-"+p(d.getMonth()+1)+"-"+p(d.getDate())+" "+p(d.getHours())+":"+p(d.getMinutes());}
        catch(e){return iso;}
      }
      var serverTitle = "<%= title==null?"" : title.replace("\"","\\\"") %>";
      var threadId = <%= id %>;
      if(!serverTitle){
        var raw = localStorage.getItem("classd_fallback_threads");
        var arr = []; try{arr=JSON.parse(raw)||[];}catch(e){arr=[];}
        var t = arr.find(function(x){return Number(x.id)===Number(threadId);});
        if(!t) return;
        var titleEl = document.getElementById("tTitle");
        var badgeEl = document.getElementById("tBadge");
        var metaEl = document.getElementById("tMeta");
        titleEl.textContent = t.title||"";
        badgeEl.textContent = t.category||"";
        metaEl.textContent = "投稿者: "+(t.author||"")+" • 作成: "+fmt(t.created_at)+" • 更新: "+fmt(t.updated_at||t.created_at);
        var bodyEl = document.getElementById("postsBody");
        var rraw = localStorage.getItem("classd_fallback_replies");
        var reps = []; try{reps=JSON.parse(rraw)||[];}catch(e){reps=[];}
        reps = reps.filter(function(x){return Number(x.thread_id)===Number(threadId);}).sort(function(a,b){return String(a.created_at).localeCompare(String(b.created_at));});
        var idx=1;
        bodyEl.innerHTML = reps.map(function(p){
          return "<tr>"
            +"<td>#"+(idx++)+"</td>"
            +"<td>"+esc(p.author||"")+"</td>"
            +"<td>"+(esc(p.content||"") + (p.image_data ? "<div class=\\\"imgwrap\\\"><img src=\\\""+esc(p.image_data)+"\\\" /></div>" : ""))+"</td>"
            +"<td>"+fmt(p.created_at)+"</td>"
            +"</tr>";
        }).join("") || "<tr><td colspan=\"4\" style=\"text-align:center; color:#64748b; padding:22px\">返信はまだありません。</td></tr>";
        var form = document.getElementById("replyForm");
        form.addEventListener("submit", function(ev){
          ev.preventDefault();
          var au = document.getElementById("replyAuthor").value.trim();
          var bd = document.getElementById("replyBody").value.trim();
          var img = document.getElementById("imageData").value || "";
          if(!au || !bd) return;
          var now = new Date().toISOString();
          var rraw2 = localStorage.getItem("classd_fallback_replies");
          var reps2 = []; try{reps2=JSON.parse(rraw2)||[];}catch(e){reps2=[];}
          reps2.push({thread_id:Number(threadId), author: au, content: bd, image_data: img, created_at: now});
          localStorage.setItem("classd_fallback_replies", JSON.stringify(reps2));
          // update thread updated_at and reply_count
          var raw2 = localStorage.getItem("classd_fallback_threads");
          var arr2 = []; try{arr2=JSON.parse(raw2)||[];}catch(e){arr2=[];}
          arr2 = arr2.map(function(tt){ if(Number(tt.id)===Number(threadId)){ tt.updated_at = now; tt.reply_count = Number(tt.reply_count||0)+1; } return tt; });
          localStorage.setItem("classd_fallback_threads", JSON.stringify(arr2));
          document.getElementById("replyBody").value = "";
          document.getElementById("imageUpload").value = "";
          document.getElementById("imageData").value = "";
          // repaint
          reps2 = reps2.filter(function(x){return Number(x.thread_id)===Number(threadId);}).sort(function(a,b){return String(a.created_at).localeCompare(String(b.created_at));});
          var i=1;
          bodyEl.innerHTML = reps2.map(function(p){
            return "<tr>"
              +"<td>#"+(i++)+"</td>"
              +"<td>"+esc(p.author||"")+"</td>"
              +"<td>"+(esc(p.content||"") + (p.image_data ? "<div class=\\\"imgwrap\\\"><img src=\\\""+esc(p.image_data)+"\\\" /></div>" : ""))+"</td>"
              +"<td>"+fmt(p.created_at)+"</td>"
              +"</tr>";
          }).join("");
        });
      }
    })();
  </script>
</body>
</html>
