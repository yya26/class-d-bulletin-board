<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>

<%
/* ===== Login Check ===== */
Boolean ok = (Boolean)session.getAttribute("loggedIn");
if(ok == null || !ok){
  response.sendRedirect(request.getContextPath() + "/login.jsp");
  return;
}

/* ===== Data from BoardServlet ===== */
List<Map<String,Object>> threads =
    (List<Map<String,Object>>) request.getAttribute("threads");

String q = (String) request.getAttribute("q");
if(q == null) q = "";

String cat = (String) request.getAttribute("cat");
if(cat == null) cat = "";
%>

<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Classroom 掲示板 - スレッド一覧</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/indexdesign.css" />
</head>

<body>
  <div class="container">

    <div class="header">
      <div class="brand">

        <div class="brand-left">
          <h1>CLASSROOM 掲示板</h1>
        </div>

        <div class="top-actions">
          <a class="btn primary"
             href="<%=request.getContextPath()%>/new.jsp">+ 新規スレッド</a>

          <a class="btn danger"
             href="<%=request.getContextPath()%>/logout">ログアウト</a>
        </div>

      </div>

      <!-- ===== SEARCH FORM (FIXED) ===== -->
      <div class="navbar">
        <div class="right">
          <form method="get"
                action="<%=request.getContextPath()%>/board"
                style="display:flex; gap:6px;">

            <input type="text"
                   name="q"
                   value="<%= q %>"
                   placeholder="検索..." />

            <button type="submit">検索</button>
          </form>
        </div>
      </div>

    </div>

    <div class="main">
      <div class="card">
        <div class="pad">

          <div class="table-head">スレッド一覧</div>

          <table style="width:100%; table-layout:fixed">

            <thead>
              <tr>
                <th style="width:70px">番号</th>
                <th>カテゴリ</th>
                <th>内容</th>
                <th style="width:140px">名前</th>
                <th style="width:80px">返信</th>
                <th style="width:170px">最終更新</th>
              </tr>
            </thead>

            <tbody>

            <%
            if(threads != null && !threads.isEmpty()){
              for(Map<String,Object> t: threads){

                long id = (Long)t.get("id");
                String author = (String)t.get("author");
                String content = (String)t.get("content");
                String catName = (String)t.get("category");
                int replies = (Integer)t.get("reply_count");

                java.sql.Timestamp upd = (java.sql.Timestamp)t.get("updated_at");
                java.sql.Timestamp crt = (java.sql.Timestamp)t.get("created_at");
                java.sql.Timestamp show = (upd != null ? upd : crt);

                String preview = "";
                if(content != null){
                  preview = content.replaceAll("<[^>]*>", " ")
                                   .replaceAll("\\s+", " ")
                                   .trim();
                  if(preview.length() > 60){
                    preview = preview.substring(0,60) + "…";
                  }
                }
            %>

              <!-- ===== FIXED THREAD LINK ===== -->
              <tr onclick="location.href='<%=request.getContextPath()%>/thread?id=<%= id %>'"
                  style="cursor:pointer;">
                <td style="text-align:center"><%= id %></td>
                <td style="text-align:center"><%= catName==null?"—":catName %></td>
                <td><%= preview %></td>
                <td><%= author %></td>
                <td style="text-align:center"><%= replies %></td>
                <td>
                  <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm")
                        .format(show) %>
                </td>
              </tr>

            <%
              }
            } else {
            %>

              <tr>
                <td colspan="6"
                    style="text-align:center; color:#64748b;">
                  スレッドがまだありません。
                </td>
              </tr>

            <%
            }
            %>

            </tbody>
          </table>

        </div>
      </div>
    </div>

  </div>
</body>
</html>