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
<html lang="ja"><head><meta charset="utf-8" /><link rel="stylesheet" href="css/thread.css" /><title>Thread</title></head><body><div class="container"><div class="card"><div class="pad">Thread not found. <a href="index.jsp">Back</a></div></div></div></body></html>
<%
  return;
}
String title=null, category=null, author=null, threadContent=null;
java.sql.Timestamp created=null, updated=null;
List<Map<String,Object>> posts = new ArrayList<>();
try{
  Class.forName("oracle.jdbc.OracleDriver");
  try(Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass)){
  if("POST".equalsIgnoreCase(request.getMethod())){
    String replyAuthor = Optional.ofNullable(request.getParameter("replyAuthor")).orElse("").trim();
    String replyBody = Optional.ofNullable(request.getParameter("replyBody")).orElse("").trim();
    
    if(replyAuthor.length()>0 && replyBody.length()>0){
      try(PreparedStatement ps = con.prepareStatement(
    "INSERT INTO replies(thread_id,author_name,content,created_at) VALUES(?,?,?,SYSDATE)"
)){
    ps.setLong(1, id);
    ps.setString(2, replyAuthor);
    ps.setString(3, replyBody);
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
  }
} catch(Exception ex){
  // allow client-side fallback rendering
}
String headerPreview = null;
try{
  String src = null;
  if(!posts.isEmpty()){
    src = (String)posts.get(posts.size()-1).get("content");
  }
  if(src==null || src.trim().isEmpty()){
    src = threadContent;
  }
  if(src!=null){
    headerPreview = src.replaceAll("<[^>]*>", " ").replaceAll("\\s+"," ").trim();
    if(headerPreview.length()>60) headerPreview = headerPreview.substring(0,60) + "…";
  }
}catch(Exception e){}
%>
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Classroom 掲示板 - スレッド</title>
 <link rel="stylesheet" href="<%=request.getContextPath()%>/css/thread.css" />



<body>
  <div class="container" id="threadWrap">

    <!-- ===== HEADER ===== -->
    <div class="header">
      <div class="brand">

        <!-- LEFT -->
        <div class="brand-left">
          <span class="badge" id="tBadge"><%= category==null?"—":category %></span>
          <h1 class="thread-title" id="tTitle"><%= title %></h1>
          <small id="tMeta">
            <%= (author!=null && created!=null)
              ? ("投稿者: "+author+" • 内容: "+(headerPreview==null?"—":headerPreview)
              +" • 作成: "+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(created)
              +" • 更新: "+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(updated!=null?updated:created))
              : "" %>
          </small>
        </div>

        <!-- RIGHT -->
        <div class="top-actions">
          <button class="btn secondary" type="button" onclick="location.href='index.jsp'">← 戻る</button>
          <a class="btn secondary" href="new.jsp">+ 新規スレッド</a>
        </div>

      </div>
    </div>

    <!-- ===== REPLY LIST ===== -->
    <div class="card" style="margin-top:16px">
      <div class="pad">
        <div class="table-head">返信一覧</div>

        <div id="postsList" class="reply-list">
          <%
          int idx = 1;
          for(Map<String,Object> p: posts){
          %>
          <div class="reply">
            <div class="reply-head">
              <span class="num">#<%= idx++ %> <%= (String)p.get("author") %></span>
              <span class="time">
                <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm")
                      .format((java.sql.Timestamp)p.get("created_at")) %>
              </span>
            </div>
            <div class="reply-body"><%= (String)p.get("content") %></div>
          </div>
          <% } %>
        </div>

      </div>
    </div>

    <!-- ===== REPLY FORM ===== -->
    <div class="card" style="margin-top:14px">
      <div class="pad">
        <h2>返信する</h2>

        <form method="post" id="replyForm">

          <div class="row">
            <label class="label" for="replyAuthor">名前</label>
            <input id="replyAuthor" name="replyAuthor" type="text" required />
          </div>

          <label class="label" for="replyBody">返信内容</label>
          <textarea id="replyBody" name="replyBody" required></textarea>

          <div class="actions">
            <button class="btn secondary" type="submit">返信</button>
            <span class="notice">名前 + 返信だけ</span>
          </div>

        </form>
      </div>
    </div>

    <div class="footer-note">
  </div>
  <script>
    (function(){
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
        (function(){
          var rraw0 = localStorage.getItem("classd_fallback_replies");
          var reps0 = []; try{reps0=JSON.parse(rraw0)||[];}catch(e){reps0=[];}
          reps0 = reps0.filter(function(x){return Number(x.thread_id)===Number(threadId);}).sort(function(a,b){return String(a.created_at).localeCompare(String(b.created_at));});
          var pvsrc0 = reps0.length>0 ? (reps0[reps0.length-1].content||"") : (t.content||"");
          var pv0 = (pvsrc0||"").replace(/<[^>]*>/g," ").replace(/\s+/g," ").trim();
          if(pv0.length>60) pv0 = pv0.substring(0,60)+"…";
          metaEl.textContent = "投稿者: "+(t.author||"")+" • 内容: "+(pv0||"—")+" • 作成: "+fmt(t.created_at)+" • 更新: "+fmt(t.updated_at||t.created_at);
        })();
        var bodyEl = document.getElementById("postsList");
        var rraw = localStorage.getItem("classd_fallback_replies");
        var reps = []; try{reps=JSON.parse(rraw)||[];}catch(e){reps=[];}
        reps = reps.filter(function(x){return Number(x.thread_id)===Number(threadId);}).sort(function(a,b){return String(a.created_at).localeCompare(String(b.created_at));});
        var idx=1;
        bodyEl.innerHTML = reps.map(function(p){
          return "<div class=\\\"reply\\\">"
            +"<div class=\\\"reply-head\\\"><span class=\\\"num\\\">#"+(idx++)+" "+esc(p.author||"")+"</span><span class=\\\"time\\\">"+fmt(p.created_at)+"</span></div>"
            +"<div class=\\\"reply-body\\\">"+(esc(p.content||"") + (p.image_data ? "<div class=\\\"imgwrap\\\"><img src=\\\""+esc(p.image_data)+"\\\" /></div>" : "") + (p.file_data ? "<div class=\\\"filewrap\\\"><a href=\\\""+esc(p.file_data)+"\\\" download=\\\""+esc(p.file_name||'添付ファイル')+"\\\">"+esc(p.file_name||'添付ファイル')+"</a></div>" : ""))+"</div>"
            +"</div>";
        }).join("") || "<div style=\\\"text-align:center; color:#64748b; padding:22px\\\">返信はまだありません。</div>";
        var form = document.getElementById("replyForm");
        form.addEventListener("submit", function(ev){
          ev.preventDefault();
          var au = document.getElementById("replyAuthor").value.trim();
          var bd = document.getElementById("replyBody").value.trim();
         var img = "";
var fdata = "";
var fname = "";

          if(!au || !bd) return;
          var now = new Date().toISOString();
          var rraw2 = localStorage.getItem("classd_fallback_replies");
          var reps2 = []; try{reps2=JSON.parse(rraw2)||[];}catch(e){reps2=[];}
          reps2.push({thread_id:Number(threadId), author: au, content: bd, image_data: img, file_data: fdata, file_name: fname, created_at: now});
          localStorage.setItem("classd_fallback_replies", JSON.stringify(reps2));
          // update thread updated_at and reply_count
          var raw2 = localStorage.getItem("classd_fallback_threads");
          var arr2 = []; try{arr2=JSON.parse(raw2)||[];}catch(e){arr2=[];}
          arr2 = arr2.map(function(tt){ if(Number(tt.id)===Number(threadId)){ tt.updated_at = now; tt.reply_count = Number(tt.reply_count||0)+1; } return tt; });
          localStorage.setItem("classd_fallback_threads", JSON.stringify(arr2));
          document.getElementById("replyBody").value = "";
          
          // repaint
          reps2 = reps2.filter(function(x){return Number(x.thread_id)===Number(threadId);}).sort(function(a,b){return String(a.created_at).localeCompare(String(b.created_at));});
          var i=1;
          bodyEl.innerHTML = reps2.map(function(p){
            return "<div class=\\\"reply\\\">"
              +"<div class=\\\"reply-head\\\"><span class=\\\"num\\\">#"+(i++)+" "+esc(p.author||"")+"</span><span class=\\\"time\\\">"+fmt(p.created_at)+"</span></div>"
              +"<div class=\\\"reply-body\\\">"+(esc(p.content||"") + (p.image_data ? "<div class=\\\"imgwrap\\\"><img src=\\\""+esc(p.image_data)+"\\\" /></div>" : "") + (p.file_data ? "<div class=\\\"filewrap\\\"><a href=\\\""+esc(p.file_data)+"\\\" download=\\\""+esc(p.file_name||'添付ファイル')+"\\\">"+esc(p.file_name||'添付ファイル')+"</a></div>" : ""))+"</div>"
              +"</div>";
          }).join("");
          try{
            var pvsrc2 = reps2.length>0 ? (reps2[reps2.length-1].content||"") : (t.content||"");
            var pv2 = (pvsrc2||"").replace(/<[^>]*>/g," ").replace(/\s+/g," ").trim();
            if(pv2.length>60) pv2 = pv2.substring(0,60)+"…";
            metaEl.textContent = "投稿者: "+(t.author||"")+" • 内容: "+(pv2||"—")+" • 作成: "+fmt(t.created_at)+" • 更新: "+fmt(now);
          }catch(e){}
        });
      }
    })();
  </script>
</body>
</html>
