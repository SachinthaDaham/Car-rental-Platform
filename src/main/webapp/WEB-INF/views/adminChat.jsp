<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, com.vrp.model.ChatMessage" %>
<%
    List<Map<String,Object>> conversations = (List<Map<String,Object>>) request.getAttribute("conversations");
    long totalUnread = request.getAttribute("totalUnread") != null ? (Long)request.getAttribute("totalUnread") : 0;
    String activeConv = request.getParameter("with");
%>
<%@ include file="header.jspf" %>

<style>
#chatMessages { scroll-behavior: smooth; }
.msg-bubble { max-width: 75%; word-break: break-word; }
.conv-item.active { background: rgba(2,132,199,.08); border-color: rgba(2,132,199,.25); }
@keyframes msgIn { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }
.msg-anim { animation: msgIn .2s ease both; }
</style>

<div class="bg-slate-100 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 py-6">

    <div class="flex items-center justify-between mb-5">
      <div>
        <h1 class="text-2xl font-extrabold text-ink-900 flex items-center gap-2">
          <i class="bi bi-chat-dots-fill text-brand-500"></i> Live Support Chat
          <% if (totalUnread > 0) { %>
            <span class="ml-1 inline-flex items-center justify-center w-6 h-6 rounded-full bg-rose-500 text-white text-xs font-bold"><%= totalUnread %></span>
          <% } %>
        </h1>
        <p class="text-slate-500 text-sm mt-0.5">Respond to customer enquiries in real time</p>
      </div>
      <a href="${pageContext.request.contextPath}/vehicles?action=dashboard"
         class="inline-flex items-center gap-2 bg-white border border-slate-200 text-slate-600 hover:border-brand-300 hover:text-brand-700 font-semibold py-2.5 px-4 rounded-xl transition text-sm">
        <i class="bi bi-speedometer2"></i> Dashboard
      </a>
    </div>

    <div class="bg-white rounded-3xl shadow-card border border-slate-100 overflow-hidden" style="height:calc(100vh - 180px); min-height:500px;">
      <div class="flex h-full">

        <!-- LEFT: Conversation list -->
        <div class="w-80 shrink-0 border-r border-slate-100 flex flex-col bg-slate-50/50">
          <div class="p-4 border-b border-slate-100">
            <div class="relative">
              <i class="bi bi-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
              <input id="convSearch" type="text" placeholder="Search customers…"
                     class="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-brand-500 bg-white">
            </div>
          </div>

          <div class="flex-1 overflow-y-auto" id="convList">
            <% if (conversations == null || conversations.isEmpty()) { %>
              <div class="text-center py-16 px-4">
                <i class="bi bi-chat-square text-4xl text-slate-200 block mb-3"></i>
                <p class="text-slate-500 font-semibold text-sm">No conversations yet</p>
                <p class="text-slate-400 text-xs mt-1">Messages from customers will appear here</p>
              </div>
            <% } else { %>
              <% for (Map<String,Object> conv : conversations) {
                  String cid = (String) conv.get("conversationId");
                  ChatMessage last = (ChatMessage) conv.get("lastMessage");
                  long unread = (Long) conv.get("unreadCount");
                  int msgCount = (Integer) conv.get("messageCount");
                  boolean isActive = cid.equals(activeConv);
              %>
                <div class="conv-item p-4 border-b border-slate-100 cursor-pointer hover:bg-slate-100 transition <%= isActive?"active border-l-2 border-l-brand-500":"" %>"
                     onclick="openConversation('<%= cid %>')"
                     data-customer="<%= cid.toLowerCase() %>">
                  <div class="flex items-start gap-3">
                    <div class="w-10 h-10 rounded-full bg-gradient-to-br from-brand-400 to-brand-600 flex items-center justify-center text-white font-bold shrink-0">
                      <%= cid.substring(0,1).toUpperCase() %>
                    </div>
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center justify-between mb-0.5">
                        <p class="font-bold text-sm text-ink-900 truncate">@<%= cid %></p>
                        <span class="text-[10px] text-slate-400 shrink-0 ml-2"><%= last.getShortTime() %></span>
                      </div>
                      <p class="text-xs text-slate-500 truncate">
                        <% if (last.isFromAdmin()) { %><span class="text-brand-500 font-semibold">You: </span><% } %>
                        <%= last.getContent().length() > 45 ? last.getContent().substring(0,45) + "…" : last.getContent() %>
                      </p>
                      <div class="flex items-center justify-between mt-1">
                        <span class="text-[10px] text-slate-300"><%= msgCount %> msg<%= msgCount!=1?"s":"" %></span>
                        <% if (unread > 0) { %>
                          <span class="inline-flex items-center justify-center w-5 h-5 rounded-full bg-rose-500 text-white text-[10px] font-bold"><%= unread %></span>
                        <% } %>
                      </div>
                    </div>
                  </div>
                </div>
              <% } %>
            <% } %>
          </div>
        </div>

        <!-- RIGHT: Chat thread -->
        <div class="flex-1 flex flex-col">
          <!-- Thread header -->
          <div id="threadHeader" class="p-4 border-b border-slate-100 flex items-center gap-3 bg-white">
            <% if (activeConv != null) { %>
              <div class="w-10 h-10 rounded-full bg-gradient-to-br from-brand-400 to-brand-600 flex items-center justify-center text-white font-bold shrink-0">
                <%= activeConv.substring(0,1).toUpperCase() %>
              </div>
              <div>
                <p class="font-bold text-ink-900">@<%= activeConv %></p>
                <p class="text-xs text-emerald-500 font-semibold flex items-center gap-1">
                  <span class="w-2 h-2 rounded-full bg-emerald-400 inline-block animate-pulse"></span> Active
                </p>
              </div>
            <% } else { %>
              <div class="text-slate-400 text-sm">Select a conversation to start replying</div>
            <% } %>
          </div>

          <!-- Messages area -->
          <div id="chatMessages" class="flex-1 overflow-y-auto p-5 space-y-3 bg-slate-50/30">
            <% if (activeConv == null) { %>
              <div class="flex flex-col items-center justify-center h-full text-center">
                <div class="w-20 h-20 rounded-full bg-slate-100 flex items-center justify-center mb-4">
                  <i class="bi bi-chat-heart text-slate-300 text-4xl"></i>
                </div>
                <p class="text-slate-500 font-semibold">Select a conversation</p>
                <p class="text-slate-400 text-sm mt-1">Choose a customer from the left panel to start chatting</p>
              </div>
            <% } %>
          </div>

          <!-- Reply box -->
          <div class="p-4 border-t border-slate-100 bg-white">
            <% if (activeConv != null) { %>
              <div class="flex gap-3">
                <input id="replyInput" type="text" placeholder="Type your reply… (Enter to send)"
                       class="flex-1 px-4 py-3 border border-slate-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-brand-500 bg-white"
                       <%= activeConv==null?"disabled":"" %>>
                <button id="sendBtn" onclick="sendMessage()"
                        class="bg-brand-600 hover:bg-brand-700 text-white font-bold px-5 py-3 rounded-xl transition flex items-center gap-2 shrink-0">
                  <i class="bi bi-send-fill"></i>
                </button>
              </div>
              <p class="text-[10px] text-slate-400 mt-2 text-center">Messages are stored securely · Customer sees replies instantly</p>
            <% } else { %>
              <div class="flex gap-3 opacity-40 pointer-events-none">
                <input type="text" placeholder="Select a conversation first…" class="flex-1 px-4 py-3 border border-slate-200 rounded-xl text-sm bg-white" disabled>
                <button class="bg-slate-300 text-white font-bold px-5 py-3 rounded-xl"><i class="bi bi-send-fill"></i></button>
              </div>
            <% } %>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
var ACTIVE_CONV = '<%= activeConv != null ? activeConv : "" %>';
var CTX = '${pageContext.request.contextPath}';
var lastTimestamp = '';
var pollInterval  = null;

// Conversation search
document.getElementById('convSearch').addEventListener('input', function() {
  var q = this.value.toLowerCase();
  document.querySelectorAll('.conv-item').forEach(function(el) {
    el.classList.toggle('hidden', !!q && !el.dataset.customer.includes(q));
  });
});

function openConversation(convId) {
  window.location.href = CTX + '/chat?action=admin&with=' + encodeURIComponent(convId);
}

function renderMessage(msg) {
  var isAdmin = msg.role === 'ADMIN';
  var div = document.createElement('div');
  div.className = 'flex msg-anim ' + (isAdmin ? 'justify-end' : 'justify-start');
  div.innerHTML =
    '<div class="msg-bubble ' + (isAdmin
      ? 'bg-brand-600 text-white rounded-2xl rounded-tr-sm'
      : 'bg-white border border-slate-200 text-ink-900 rounded-2xl rounded-tl-sm') + ' px-4 py-3 shadow-sm">' +
      '<p class="text-sm leading-relaxed">' + escHtml(msg.content) + '</p>' +
      '<p class="text-[10px] mt-1 ' + (isAdmin ? 'text-brand-200' : 'text-slate-400') + ' text-right">' +
        (isAdmin ? 'You' : '@' + msg.from) + ' · ' + msg.shortTime +
      '</p>' +
    '</div>';
  return div;
}

function escHtml(s) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function scrollBottom() {
  var el = document.getElementById('chatMessages');
  el.scrollTop = el.scrollHeight;
}

function loadHistory() {
  if (!ACTIVE_CONV) return;
  fetch(CTX + '/chat?action=history&with=' + encodeURIComponent(ACTIVE_CONV))
    .then(function(r) { return r.json(); })
    .then(function(msgs) {
      var container = document.getElementById('chatMessages');
      container.innerHTML = '';
      if (msgs.length === 0) {
        container.innerHTML = '<div class="text-center text-slate-400 text-sm py-8">No messages yet. Say hello!</div>';
      }
      msgs.forEach(function(m) { container.appendChild(renderMessage(m)); });
      if (msgs.length > 0) lastTimestamp = msgs[msgs.length-1].timestamp;
      scrollBottom();
      startPolling();
    });
}

function startPolling() {
  if (pollInterval) clearInterval(pollInterval);
  pollInterval = setInterval(function() {
    if (!ACTIVE_CONV || !lastTimestamp) return;
    fetch(CTX + '/chat?action=poll&with=' + encodeURIComponent(ACTIVE_CONV) + '&since=' + encodeURIComponent(lastTimestamp))
      .then(function(r) { return r.json(); })
      .then(function(msgs) {
        if (!msgs.length) return;
        var container = document.getElementById('chatMessages');
        var wasAtBottom = container.scrollHeight - container.scrollTop - container.clientHeight < 60;
        msgs.forEach(function(m) { container.appendChild(renderMessage(m)); });
        lastTimestamp = msgs[msgs.length-1].timestamp;
        if (wasAtBottom) scrollBottom();
      });
  }, 3000);
}

function sendMessage() {
  var input = document.getElementById('replyInput');
  var content = input.value.trim();
  if (!content || !ACTIVE_CONV) return;
  input.value = '';
  input.disabled = true;

  var fd = new FormData();
  fd.append('content', content);
  fd.append('with', ACTIVE_CONV);

  fetch(CTX + '/chat', { method:'POST', body: fd })
    .then(function(r) { return r.json(); })
    .then(function(d) {
      if (d.success) {
        var container = document.getElementById('chatMessages');
        var msg = { role:'ADMIN', from:'admin', content: content, shortTime: d.shortTime };
        container.appendChild(renderMessage(msg));
        lastTimestamp = d.timestamp;
        scrollBottom();
      }
      input.disabled = false;
      input.focus();
    })
    .catch(function() { input.disabled = false; });
}

document.getElementById('replyInput').addEventListener('keydown', function(e) {
  if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
});

// Init
if (ACTIVE_CONV) loadHistory();
</script>

<%@ include file="footer.jspf" %>
