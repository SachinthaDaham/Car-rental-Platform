<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setAttribute("nav", "login");
    request.setAttribute("pageTitle", "Login — DriveLanka");
    String error = request.getParameter("error");
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen py-16 flex items-center justify-center">
  <div class="max-w-md w-full px-6">
    <div class="bg-white rounded-3xl shadow-xl border border-slate-100 p-8 md:p-10">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-extrabold text-ink-900 mb-2">Welcome Back</h1>
        <p class="text-slate-500">Sign in to your DriveLanka account.</p>
      </div>

      <% if ("invalid".equals(error)) { %>
        <div class="bg-rose-50 text-rose-600 text-sm font-semibold p-3 rounded-lg mb-6 text-center border border-rose-100">
          Invalid username or password.
        </div>
      <% } %>

      <form action="${pageContext.request.contextPath}/auth" method="post" class="space-y-5">
        <input type="hidden" name="action" value="login">
        
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Username</label>
          <input type="text" name="username" required placeholder="Enter your username" class="w-full px-4 py-3 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow">
        </div>
        
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Password</label>
          <input type="password" name="password" required placeholder="••••••••" class="w-full px-4 py-3 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow">
        </div>

        <button type="submit" class="w-full bg-brand-600 hover:bg-brand-700 text-white font-bold text-lg py-3 rounded-xl shadow-btn transition-colors mt-2">
          Sign In
        </button>
      </form>

      <p class="text-center text-slate-500 text-sm mt-8">
        Don't have an account? 
        <a href="${pageContext.request.contextPath}/auth?action=register" class="text-brand-600 font-bold hover:underline">Create one</a>
      </p>
    </div>
  </div>
</div>

<%@ include file="footer.jspf" %>
