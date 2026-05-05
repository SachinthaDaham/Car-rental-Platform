<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setAttribute("nav", "register");
    request.setAttribute("pageTitle", "Register — DriveLanka");
    String error = request.getParameter("error");
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen py-16 flex items-center justify-center">
  <div class="max-w-md w-full px-6">
    <div class="bg-white rounded-3xl shadow-xl border border-slate-100 p-8 md:p-10">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-extrabold text-ink-900 mb-2">Create Account</h1>
        <p class="text-slate-500">Join DriveLanka to start renting vehicles.</p>
      </div>

      <% if ("exists".equals(error)) { %>
        <div class="bg-rose-50 text-rose-600 text-sm font-semibold p-3 rounded-lg mb-6 text-center border border-rose-100">
          Username already exists. Please choose another.
        </div>
      <% } %>

      <form action="${pageContext.request.contextPath}/auth" method="post" class="space-y-5">
        <input type="hidden" name="action" value="register">
        
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Full Name</label>
          <input type="text" name="name" required placeholder="John Doe" class="w-full px-4 py-3 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow">
        </div>

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Choose a Username</label>
          <input type="text" name="username" required placeholder="johndoe123" class="w-full px-4 py-3 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow">
        </div>
        
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Password</label>
          <input type="password" name="password" required placeholder="••••••••" class="w-full px-4 py-3 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow">
        </div>

        <button type="submit" class="w-full bg-brand-600 hover:bg-brand-700 text-white font-bold text-lg py-3 rounded-xl shadow-btn transition-colors mt-2">
          Create Account
        </button>
      </form>

      <p class="text-center text-slate-500 text-sm mt-8">
        Already have an account? 
        <a href="${pageContext.request.contextPath}/auth?action=login" class="text-brand-600 font-bold hover:underline">Sign In</a>
      </p>
    </div>
  </div>
</div>

<%@ include file="footer.jspf" %>
