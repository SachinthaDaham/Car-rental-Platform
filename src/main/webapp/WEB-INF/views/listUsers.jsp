<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, com.vrp.model.User" %>
<%
    request.setAttribute("nav", "users");
    request.setAttribute("pageTitle", "User Management — DriveLanka Admin");
    List<User> users = (List<User>) request.getAttribute("users");
    Map<String, Long> counts = (Map<String, Long>) request.getAttribute("userCounts");
    String msg = request.getParameter("msg");
    long totalUsers = counts != null ? counts.getOrDefault("total", 0L) : 0;
    long admins     = counts != null ? counts.getOrDefault("admins", 0L) : 0;
    long customers  = counts != null ? counts.getOrDefault("customers", 0L) : 0;
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 py-8">

    <!-- Header -->
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-3xl font-extrabold text-ink-900">User Management</h1>
        <p class="text-slate-500 mt-1">
          <span class="font-semibold text-ink-900"><%= totalUsers %></span> registered users ·
          <span class="text-brand-600 font-semibold"><%= admins %> admin<%= admins!=1?"s":"" %></span> ·
          <span class="text-slate-600 font-semibold"><%= customers %> customer<%= customers!=1?"s":"" %></span>
        </p>
      </div>
      <a href="${pageContext.request.contextPath}/vehicles?action=dashboard"
         class="inline-flex items-center gap-2 bg-white border border-slate-200 text-slate-600 hover:border-brand-300 hover:text-brand-700 font-semibold py-2.5 px-4 rounded-xl transition text-sm">
        <i class="bi bi-speedometer2"></i> Dashboard
      </a>
    </div>

    <!-- Stats row -->
    <div class="grid grid-cols-3 gap-4 mb-6">
      <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 text-center">
        <p class="text-2xl font-extrabold text-ink-900"><%= totalUsers %></p>
        <p class="text-xs text-slate-500 font-semibold mt-1 uppercase tracking-wide">Total Users</p>
      </div>
      <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 text-center">
        <p class="text-2xl font-extrabold text-brand-600"><%= admins %></p>
        <p class="text-xs text-slate-500 font-semibold mt-1 uppercase tracking-wide">Admins</p>
      </div>
      <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 text-center">
        <p class="text-2xl font-extrabold text-emerald-600"><%= customers %></p>
        <p class="text-xs text-slate-500 font-semibold mt-1 uppercase tracking-wide">Customers</p>
      </div>
    </div>

    <!-- Flash messages -->
    <% if ("deleted".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-slate-100 text-slate-700 px-4 py-3 rounded-xl border border-slate-200 font-medium text-sm">
        <i class="bi bi-trash3-fill"></i> User account removed.
      </div>
    <% } %>

    <!-- Search bar -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 mb-4 flex gap-3">
      <div class="relative flex-1">
        <i class="bi bi-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
        <input id="userSearch" type="text" placeholder="Search by name or username…"
               class="w-full pl-9 pr-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
      </div>
      <div class="flex gap-2">
        <button data-role="all"      class="role-btn active px-3 py-2 text-xs font-bold rounded-lg border border-brand-300 bg-brand-600 text-white">All</button>
        <button data-role="ADMIN"    class="role-btn px-3 py-2 text-xs font-bold rounded-lg border border-slate-200 bg-white text-slate-600 hover:border-brand-300">Admins</button>
        <button data-role="CUSTOMER" class="role-btn px-3 py-2 text-xs font-bold rounded-lg border border-slate-200 bg-white text-slate-600 hover:border-brand-300">Customers</button>
      </div>
    </div>

    <p class="text-xs text-slate-400 font-medium mb-3 px-1">
      Showing <span id="visibleCount"><%= totalUsers %></span> of <%= totalUsers %> users
    </p>

    <!-- Table -->
    <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead>
            <tr class="bg-slate-50 text-xs uppercase text-slate-500 tracking-wider">
              <th class="px-6 py-4 font-semibold">User</th>
              <th class="px-6 py-4 font-semibold">Username</th>
              <th class="px-6 py-4 font-semibold text-center">Role</th>
              <th class="px-6 py-4 font-semibold text-right">Actions</th>
            </tr>
          </thead>
          <tbody id="userTableBody" class="text-sm">
            <% if (users == null || users.isEmpty()) { %>
              <tr>
                <td colspan="4" class="px-6 py-14 text-center text-slate-400">
                  <i class="bi bi-people text-5xl mb-3 block opacity-30"></i>
                  <p class="font-medium">No users registered yet.</p>
                </td>
              </tr>
            <% } else { %>
              <% for (User u : users) { %>
                <tr class="user-row border-b border-slate-50 last:border-0 hover:bg-slate-50/60 transition-colors"
                    data-name="<%= u.getName().toLowerCase() %>"
                    data-username="<%= u.getUsername().toLowerCase() %>"
                    data-role="<%= u.getRole() %>">
                  <td class="px-6 py-4">
                    <div class="flex items-center gap-3">
                      <div class="w-10 h-10 rounded-full bg-gradient-to-br from-brand-500 to-indigo-600 flex items-center justify-center text-white font-extrabold text-sm shrink-0">
                        <%= u.getName().substring(0, 1).toUpperCase() %>
                      </div>
                      <p class="font-bold text-ink-900"><%= u.getName() %></p>
                    </div>
                  </td>
                  <td class="px-6 py-4 font-mono text-slate-500 text-xs">@<%= u.getUsername() %></td>
                  <td class="px-6 py-4 text-center">
                    <% if (u.isAdmin()) { %>
                      <span class="inline-flex items-center gap-1 bg-brand-100 text-brand-700 text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">
                        <i class="bi bi-shield-fill-check"></i> Admin
                      </span>
                    <% } else { %>
                      <span class="inline-flex items-center gap-1 bg-emerald-100 text-emerald-700 text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">
                        <i class="bi bi-person-fill"></i> Customer
                      </span>
                    <% } %>
                  </td>
                  <td class="px-6 py-4 text-right">
                    <% if (!"admin".equals(u.getUsername())) { %>
                      <a href="${pageContext.request.contextPath}/auth?action=deleteUser&username=<%= u.getUsername() %>"
                         onclick="return confirm('Remove user @<%= u.getUsername() %>?');"
                         class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-slate-100 hover:bg-rose-100 text-slate-500 hover:text-rose-700 transition" title="Delete User">
                        <i class="bi bi-trash3"></i>
                      </a>
                    <% } else { %>
                      <span class="text-xs text-slate-300 italic">Protected</span>
                    <% } %>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>

        <div id="noUserResults" class="hidden py-14 text-center text-slate-400">
          <i class="bi bi-search text-4xl mb-3 block opacity-30"></i>
          <p class="font-medium">No users match your search.</p>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
  var searchInput = document.getElementById('userSearch');
  var rows        = document.querySelectorAll('.user-row');
  var noResults   = document.getElementById('noUserResults');
  var countEl     = document.getElementById('visibleCount');
  var roleBtns    = document.querySelectorAll('.role-btn');
  var activeRole  = 'all';

  function applyFilter() {
    var q = searchInput.value.toLowerCase().trim();
    var visible = 0;
    rows.forEach(function(row) {
      var matchSearch = !q || row.dataset.name.includes(q) || row.dataset.username.includes(q);
      var matchRole   = activeRole === 'all' || row.dataset.role === activeRole;
      var show = matchSearch && matchRole;
      row.classList.toggle('hidden', !show);
      if (show) visible++;
    });
    countEl.textContent = visible;
    noResults.classList.toggle('hidden', visible > 0);
  }

  searchInput.addEventListener('input', applyFilter);

  roleBtns.forEach(function(btn) {
    btn.addEventListener('click', function() {
      roleBtns.forEach(function(b) {
        b.classList.remove('active', 'bg-brand-600', 'text-white', 'border-brand-300');
        b.classList.add('bg-white', 'text-slate-600');
      });
      this.classList.add('active', 'bg-brand-600', 'text-white', 'border-brand-300');
      this.classList.remove('bg-white', 'text-slate-600');
      activeRole = this.dataset.role;
      applyFilter();
    });
  });
})();
</script>

<%@ include file="footer.jspf" %>
