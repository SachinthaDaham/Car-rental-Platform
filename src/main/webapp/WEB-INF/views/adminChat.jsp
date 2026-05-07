<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, com.vrp.model.ChatMessage" %>
<%
    request.setAttribute("nav", "chat");
    request.setAttribute("pageTitle", "Live Chat — DriveLanka Admin");
    String activeConv = request.getParameter("with");
%>
<%@ include file="header.jspf" %>

<style>
.conv-item        { cursor:pointer; transition: background .15s; border-left: 3px solid transparent; }
.conv-item:hover  { background: #f1f5f9; }
.conv-item.active { background: #eff6ff; border-left-color: #0284c7; }
.conv-item.has-unread .conv-name { font-weight: 800; color: #0b1220; }
#chatMessages     { scroll-behavior: smooth; }
.msg-bubble       { max-width: 72%; word-break: break-word; }
@keyframes msgIn  { from{opacity:0;transform:translateY(6px)} to{opacity:1;transform:translateY(0)} }
.msg-anim         { animation: msgIn .2s ease both; }
@keyframes convPop{ from{background:#dbeafe} to{background:transparent} }
.conv-new         { animation: convPop 1.5s ease; }
</style>

<div class="bg-slate-100 min-h-screen">
<div class="max-w-7xl mx-auto px-4 sm:px-6 py-6">

  <div class="flex items-center justify-between mb-4">
    <div>
      <h1 class="text-2xl font-extrabold text-ink-900 flex items-center gap-2">
        <i class="bi bi-chat-dots-fill text-brand-500"></i> Live Support Chat
        <span id="unreadBadgeHeader" class="hidden ml-1 inline-flex items-center justify-center min-w-[24px] h-6 rounded-full bg-rose-500 text-white text-xs font-bold px-1.5"></span>
      </h1>
      <p class="text-slate-500 text-sm mt-0.5">Conversations update live every 5 seconds</p>
    </div>
    <a href="${pageContext.request.contextPath}/vehicles?action=dashboard"
       class="inline-flex items-center gap-2 bg-white border border-slate-200 text-slate-600 hover:border-brand-300 hover:text-brand-700 font-semibold py-2.5 px-4 rounded-xl transition text-sm">
      <i class="bi bi-speedometer2"></i> Dashboard
    </a>
  </div>

  <div class="bg-white rounded-3xl shadow-card border border-slate-100 overflow-hidden flex" style="height:calc(100vh - 175px); min-height:500px;">

    <!-- LEFT: Conversation list (live-updated) -->
    <div class="w-72 shrink-0 border-r border-slate-100 flex flex-col bg-slate-50/60">
      <div class="p-3 border-b border-slate-100 bg-white">
        <div class="relative">
          <i class="bi bi-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
          <input id="convSearch" type="text" placeholder="Search customers…"
                 class="w-full pl-8 pr-3 py-2 border border-slate-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-brand-500 bg-white">
        </div>
      </div>

      <div class="flex-1 overflow-y-auto" id="convList">
        <div class="text-center py-10 text-slate-400 text-sm" id="convPlaceholder">
          <i class="bi bi-arrow-repeat animate-spin text-xl block mb-2"></i>Loading…
        </div>
      </div>

      <div class="px-3 py-2 border-t border-slate-100 bg-white">
        <p class="text-[10px] text-slate-400 text-center flex items-center justify-center gap-1">
          <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block animate-pulse"></span>
          Live · refreshes every 5s
        </p>
      </div>
    </div>

    <!-- RIGHT: Chat thread -->
    <div class="flex-1 flex flex-col min-w-0">

      <!-- Thread header -->
      <div id="threadHeader" class="p-4 border-b border-slate-100 bg-white flex items-center gap-3 shrink-0">
        <div id="headerContent" class="text-slate-400 text-sm flex items-center gap-2">
          <i class="bi bi-arrow-left text-slate-300"></i>
          Select a conversation to start replying
        </div>
      </div>

      <!-- Messages -->
      <div id="chatMessages" class="flex-1 overflow-y-auto p-5 space-y-3 bg-slate-50/40">
        <div id="emptyState" class="flex flex-col items-center justify-center h-full text-center">
          <div class="w-20 h-20 rounded-full bg-slate-100 flex items-center justify-center mb-4">
            <i class="bi bi-chat-heart text-slate-300 text-4xl"></i>
          </div>
          <p class="text-slate-500 font-semibold">No conversation selected</p>
          <p class="text-slate-400 text-sm mt-1">Click a customer on the left to view their messages</p>
        </div>
      </div>

      <!-- Reply input -->
      <div class="p-4 border-t border-slate-100 bg-white shrink-0">
        <div class="flex gap-2">
          <input id="replyInput" type="text" placeholder="Select a conversation first…"
                 class="flex-1 px-4 py-3 border border-slate-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-brand-500 transition"
                 disabled>
          <button id="sendBtn" onclick="sendAdminMessage()"
                  class="bg-brand-600 hover:bg-brand-700 disabled:bg-slate-300 disabled:cursor-not-allowed text-white font-bold px-5 py-3 rounded-xl transition flex items-center gap-2 shrink-0"
                  disabled>
            <i class="bi bi-send-fill"></i>
          </button>
        </div>
        <p id="replyHint" class="text-[10px] text-slate-400 mt-1.5 text-center">Choose a conversation · Press Enter to send</p>
      </div>
    </div>
  </div>
</div>
</div>

<script>
var CTX       = '${pageContext.request.contextPath}';
var ACTIVE    = '<%= activeConv != null ? activeConv.replace("'","") : "" %>';
var lastTs    = '';
var msgPoll   = null;
var convPoll  = null;
var knownConvs= {};   // id → msgCount, for detecting new messages

// ── Conversation list rendering ────────────────────────────────────────────
function renderConvList(convs) {
  var list = document.getElementById('convList');
  var ph   = document.getElementById('convPlaceholder');
  if (ph) ph.remove();

  var q = (document.getElementById('convSearch').value || '').toLowerCase();

  if (convs.length === 0) {
    list.innerHTML = '<div class="text-center py-12 px-4"><i class="bi bi-chat-square text-4xl text-slate-200 block mb-3"></i><p class="text-slate-500 text-sm font-semibold">No conversations yet</p><p class="text-slate-400 text-xs mt-1">Customer messages will appear here</p></div>';
    return;
  }

  // Build set of existing ids
  var existing = {};
  list.querySelectorAll('.conv-item').forEach(function(el) { existing[el.dataset.id] = el; });

  convs.forEach(function(cv) {
    if (q && !cv.id.toLowerCase().includes(q)) return;

    var isActive = cv.id === ACTIVE;
    var isNew = !knownConvs[cv.id];
    var hasMore = knownConvs[cv.id] && knownConvs[cv.id] < cv.count;
    knownConvs[cv.id] = cv.count;

    var el = existing[cv.id];
    if (!el) {
      el = document.createElement('div');
      el.className = 'conv-item p-3.5 border-b border-slate-100' + (isActive ? ' active' : '') + (cv.unread > 0 ? ' has-unread' : '') + (isNew ? ' conv-new' : '');
      el.dataset.id = cv.id;
      el.onclick = function() { openConv(cv.id); };
      list.appendChild(el);
    } else {
      if (hasMore && !isActive) el.classList.add('conv-new');
      el.className = 'conv-item p-3.5 border-b border-slate-100' + (isActive ? ' active' : '') + (cv.unread > 0 ? ' has-unread' : '');
    }

    el.innerHTML =
      '<div class="flex items-center gap-3">' +
        '<div class="w-9 h-9 rounded-full bg-gradient-to-br from-brand-400 to-brand-600 flex items-center justify-center text-white font-bold text-sm shrink-0">' +
          cv.id.charAt(0).toUpperCase() +
        '</div>' +
        '<div class="flex-1 min-w-0">' +
          '<div class="flex items-center justify-between mb-0.5">' +
            '<p class="conv-name text-sm text-ink-900 truncate' + (cv.unread > 0 ? ' font-bold' : ' font-semibold') + '">@' + escHtml(cv.id) + '</p>' +
            '<span class="text-[10px] text-slate-400 shrink-0 ml-1">' + cv.time + '</span>' +
          '</div>' +
          '<p class="text-xs text-slate-500 truncate">' +
            (cv.fromAdmin ? '<span class="text-brand-500 font-semibold">You: </span>' : '') +
            escHtml(cv.preview) +
          '</p>' +
        '</div>' +
        (cv.unread > 0 ? '<span class="w-5 h-5 rounded-full bg-rose-500 text-white text-[10px] font-bold flex items-center justify-center shrink-0">' + cv.unread + '</span>' : '') +
      '</div>';
  });

  // Update header unread badge
  var total = convs.reduce(function(s,c){ return s + c.unread; }, 0);
  var badge = document.getElementById('unreadBadgeHeader');
  if (total > 0) { badge.textContent = total; badge.classList.remove('hidden'); }
  else badge.classList.add('hidden');
}

function fetchConversations() {
  fetch(CTX + '/chat?action=conversations')
    .then(function(r){ return r.json(); })
    .then(renderConvList)
    .catch(function(){});
}

// ── Open a conversation ────────────────────────────────────────────────────
function openConv(convId) {
  if (ACTIVE === convId) return;
  ACTIVE  = convId;
  lastTs  = '';

  // Update active highlight without page reload
  document.querySelectorAll('.conv-item').forEach(function(el) {
    el.classList.toggle('active', el.dataset.id === convId);
  });

  // Update header
  document.getElementById('headerContent').innerHTML =
    '<div class="w-9 h-9 rounded-full bg-gradient-to-br from-brand-400 to-brand-600 flex items-center justify-center text-white font-bold shrink-0">' +
      convId.charAt(0).toUpperCase() +
    '</div>' +
    '<div>' +
      '<p class="font-bold text-ink-900 text-sm">@' + escHtml(convId) + '</p>' +
      '<p class="text-xs text-emerald-500 font-semibold flex items-center gap-1">' +
        '<span class="w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block animate-pulse"></span> Active' +
      '</p>' +
    '</div>';

  // Enable reply input
  var inp = document.getElementById('replyInput');
  var btn = document.getElementById('sendBtn');
  inp.disabled = false;
  inp.placeholder = 'Reply to @' + convId + '… (Enter to send)';
  inp.focus();
  btn.disabled = false;

  // Load message history
  loadHistory(convId);

  // Restart message polling for this conversation
  if (msgPoll) clearInterval(msgPoll);
  msgPoll = setInterval(function() { pollMessages(convId); }, 3000);
}

// ── Message rendering ──────────────────────────────────────────────────────
function escHtml(s) {
  if (!s) return '';
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function renderMsg(msg) {
  var isAdmin = msg.role === 'ADMIN';
  var wrap = document.createElement('div');
  wrap.className = 'flex msg-anim ' + (isAdmin ? 'justify-end' : 'justify-start');
  wrap.innerHTML =
    '<div class="msg-bubble ' + (isAdmin
      ? 'bg-brand-600 text-white rounded-2xl rounded-tr-sm'
      : 'bg-white border border-slate-200 text-ink-900 rounded-2xl rounded-tl-sm') +
    ' px-4 py-3 shadow-sm">' +
      '<p class="text-sm leading-relaxed whitespace-pre-wrap">' + escHtml(msg.content) + '</p>' +
      '<p class="text-[10px] mt-1.5 ' + (isAdmin ? 'text-brand-200' : 'text-slate-400') + ' text-right">' +
        (isAdmin ? 'You (Admin)' : '@' + escHtml(msg.from)) + ' · ' + msg.shortTime +
      '</p>' +
    '</div>';
  return wrap;
}

function scrollBottom() {
  var el = document.getElementById('chatMessages');
  el.scrollTop = el.scrollHeight;
}

function loadHistory(convId) {
  var msgs = document.getElementById('chatMessages');
  msgs.innerHTML = '<div class="text-center py-8 text-slate-400 text-sm"><i class="bi bi-arrow-repeat animate-spin text-xl block mb-2"></i>Loading messages…</div>';

  fetch(CTX + '/chat?action=history&with=' + encodeURIComponent(convId))
    .then(function(r){ return r.json(); })
    .then(function(data) {
      msgs.innerHTML = '';
      if (data.length === 0) {
        msgs.innerHTML = '<div class="text-center py-8 text-slate-400 text-sm"><i class="bi bi-chat text-2xl block mb-2 opacity-30"></i>No messages yet. Reply to start the conversation.</div>';
      }
      data.forEach(function(m){ msgs.appendChild(renderMsg(m)); });
      if (data.length) lastTs = data[data.length-1].timestamp;
      scrollBottom();
      // Remove unread marker for this conversation
      fetchConversations();
    })
    .catch(function(){
      msgs.innerHTML = '<div class="text-center py-8 text-rose-400 text-sm">Failed to load messages.</div>';
    });
}

function pollMessages(convId) {
  if (!convId || !lastTs) return;
  fetch(CTX + '/chat?action=poll&with=' + encodeURIComponent(convId) + '&since=' + encodeURIComponent(lastTs))
    .then(function(r){ return r.json(); })
    .then(function(data) {
      if (!data.length) return;
      var msgs = document.getElementById('chatMessages');
      var atBottom = msgs.scrollHeight - msgs.scrollTop - msgs.clientHeight < 80;
      data.forEach(function(m){ msgs.appendChild(renderMsg(m)); });
      lastTs = data[data.length-1].timestamp;
      if (atBottom) scrollBottom();
      // Refresh conversation list to clear unread
      fetchConversations();
    })
    .catch(function(){});
}

// ── Send message ───────────────────────────────────────────────────────────
function sendAdminMessage() {
  var inp     = document.getElementById('replyInput');
  var content = inp.value.trim();
  if (!content || !ACTIVE) return;
  inp.value    = '';
  inp.disabled = true;

  var body = new URLSearchParams();
  body.append('content', content);
  body.append('with', ACTIVE);

  fetch(CTX + '/chat', { method:'POST', body:body, headers:{'Content-Type':'application/x-www-form-urlencoded'} })
    .then(function(r){ return r.json(); })
    .then(function(d) {
      if (d.success) {
        var msgs = document.getElementById('chatMessages');
        msgs.appendChild(renderMsg({
          role:'ADMIN', from:'admin', content: content, shortTime: d.shortTime
        }));
        lastTs = d.timestamp;
        scrollBottom();
        fetchConversations();
      }
      inp.disabled = false;
      inp.focus();
    })
    .catch(function(){ inp.disabled = false; });
}

// ── Conversation search ────────────────────────────────────────────────────
document.getElementById('convSearch').addEventListener('input', function() {
  var q = this.value.toLowerCase();
  document.querySelectorAll('.conv-item').forEach(function(el) {
    el.style.display = (!q || el.dataset.id.toLowerCase().includes(q)) ? '' : 'none';
  });
});

// ── Enter to send ──────────────────────────────────────────────────────────
document.getElementById('replyInput').addEventListener('keydown', function(e) {
  if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendAdminMessage(); }
});

// ── Init ───────────────────────────────────────────────────────────────────
fetchConversations();
convPoll = setInterval(fetchConversations, 5000);

// Auto-open conversation from URL param
if (ACTIVE) {
  setTimeout(function() { openConv(ACTIVE); }, 300);
}
</script>

<%@ include file="footer.jspf" %>
