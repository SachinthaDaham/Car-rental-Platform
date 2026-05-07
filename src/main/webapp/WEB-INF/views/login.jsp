<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setAttribute("nav", "login");
    request.setAttribute("pageTitle", "Sign In — DriveLanka");
    String error = request.getParameter("error");
    String redirect = request.getParameter("redirect");
%>
<%@ include file="header.jspf" %>

<div class="min-h-screen bg-gradient-to-br from-slate-100 via-brand-50 to-slate-100 flex items-center justify-center py-16 px-4">
  <div class="max-w-md w-full">

    <!-- Card -->
    <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 p-8 md:p-10">

      <!-- Logo + Title -->
      <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-brand-500 to-brand-700 text-white shadow-btn mb-4">
          <i class="bi bi-car-front-fill text-2xl"></i>
        </div>
        <h1 class="text-3xl font-extrabold text-ink-900">Welcome Back</h1>
        <p class="text-slate-500 mt-1 text-sm">Sign in to your DriveLanka account</p>
      </div>

      <!-- Error alert -->
      <% if ("invalid".equals(error)) { %>
        <div class="flex items-center gap-3 bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl mb-6 text-sm font-semibold">
          <i class="bi bi-exclamation-circle-fill text-rose-500 shrink-0"></i>
          Invalid username or password. Please try again.
        </div>
      <% } else if ("session".equals(error)) { %>
        <div class="flex items-center gap-3 bg-amber-50 border border-amber-200 text-amber-700 px-4 py-3 rounded-xl mb-6 text-sm font-semibold">
          <i class="bi bi-clock-fill text-amber-500 shrink-0"></i>
          Your session has expired. Please sign in again.
        </div>
      <% } %>

      <!-- Form -->
      <form id="loginForm" action="${pageContext.request.contextPath}/auth" method="post" class="space-y-5" novalidate>
        <input type="hidden" name="action" value="login">
        <% if (redirect != null) { %>
          <input type="hidden" name="redirect" value="<%= redirect %>">
        <% } %>

        <!-- Username -->
        <div>
          <label for="username" class="block text-sm font-semibold text-slate-700 mb-1.5">
            <i class="bi bi-person-fill text-slate-400 mr-1"></i>Username
          </label>
          <input type="text" id="username" name="username" required
                 autocomplete="username"
                 placeholder="Enter your username"
                 class="w-full px-4 py-3 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent transition-shadow text-sm">
        </div>

        <!-- Password -->
        <div>
          <label for="password" class="block text-sm font-semibold text-slate-700 mb-1.5">
            <i class="bi bi-lock-fill text-slate-400 mr-1"></i>Password
          </label>
          <div class="relative">
            <input type="password" id="password" name="password" required
                   autocomplete="current-password"
                   placeholder="••••••••"
                   class="w-full px-4 py-3 pr-12 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent transition-shadow text-sm">
            <button type="button" id="togglePass"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition p-1"
                    tabindex="-1" aria-label="Toggle password visibility">
              <i id="toggleIcon" class="bi bi-eye-fill text-base"></i>
            </button>
          </div>
        </div>

        <!-- Submit -->
        <button type="submit" id="loginBtn"
                class="w-full bg-brand-600 hover:bg-brand-700 text-white font-bold text-base py-3.5 rounded-xl shadow-btn transition-all flex items-center justify-center gap-2 mt-2">
          <i class="bi bi-box-arrow-in-right"></i>
          <span id="loginBtnText">Sign In</span>
          <span id="loginSpinner" class="hidden w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
        </button>
      </form>

      <!-- Divider -->
      <div class="relative my-6">
        <div class="absolute inset-0 flex items-center">
          <div class="w-full border-t border-slate-100"></div>
        </div>
        <div class="relative flex justify-center">
          <span class="bg-white px-3 text-xs text-slate-400 font-medium">New to DriveLanka?</span>
        </div>
      </div>

      <!-- Register CTA -->
      <a href="${pageContext.request.contextPath}/auth?action=register"
         class="w-full flex items-center justify-center gap-2 border border-brand-200 text-brand-700 font-semibold text-sm py-3 rounded-xl hover:bg-brand-50 hover:border-brand-300 transition">
        <i class="bi bi-person-plus-fill"></i> Create Free Account
      </a>
    </div>

    <!-- Demo hint -->
    <div class="mt-4 bg-white/70 border border-slate-200 rounded-2xl px-5 py-4 text-xs text-slate-500 text-center shadow-sm backdrop-blur">
      <i class="bi bi-info-circle text-brand-500 mr-1"></i>
      Demo admin: <span class="font-mono font-bold text-slate-700">admin</span> /
      <span class="font-mono font-bold text-slate-700">admin123</span>
    </div>
  </div>
</div>

<script>
(function() {
  // Password toggle
  var passEl  = document.getElementById('password');
  var iconEl  = document.getElementById('toggleIcon');
  document.getElementById('togglePass').addEventListener('click', function() {
    if (passEl.type === 'password') {
      passEl.type = 'text';
      iconEl.className = 'bi bi-eye-slash-fill text-base';
    } else {
      passEl.type = 'password';
      iconEl.className = 'bi bi-eye-fill text-base';
    }
  });

  // Submit spinner
  document.getElementById('loginForm').addEventListener('submit', function(e) {
    var u = document.getElementById('username').value.trim();
    var p = document.getElementById('password').value;
    if (!u || !p) return;
    document.getElementById('loginBtnText').textContent = 'Signing in…';
    document.getElementById('loginSpinner').classList.remove('hidden');
    document.getElementById('loginBtn').disabled = true;
  });
})();
</script>

<%@ include file="footer.jspf" %>
