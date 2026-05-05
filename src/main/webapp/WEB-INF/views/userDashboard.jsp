<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.User" %>
<%
    request.setAttribute("nav", "dashboard");
    request.setAttribute("pageTitle", "My Dashboard — DriveLanka");
    
    // Check session
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/auth?action=login");
        return;
    }
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">
  <!-- Dashboard Header -->
  <div class="bg-brand-700 text-white pb-24 pt-10">
    <div class="max-w-7xl mx-auto px-6">
      <div class="flex items-center gap-5">
        <div class="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center text-2xl font-bold border border-white/30">
          <%= user.getName().substring(0, 1).toUpperCase() %>
        </div>
        <div>
          <h1 class="text-3xl font-extrabold tracking-tight">Welcome, <%= user.getName() %>!</h1>
          <p class="text-brand-100 mt-1">Manage your account and rentals from your personal dashboard.</p>
        </div>
      </div>
    </div>
  </div>

  <div class="max-w-7xl mx-auto px-6 -mt-16">
    <div class="grid md:grid-cols-3 gap-6">
      <!-- Profile Card -->
      <div class="bg-white rounded-2xl shadow-card p-6 border border-slate-100">
        <h3 class="font-bold text-lg mb-4 text-ink-900 border-b border-slate-100 pb-2">Profile Details</h3>
        <div class="space-y-4">
          <div>
            <p class="text-xs font-bold uppercase tracking-wider text-slate-400">Full Name</p>
            <p class="font-medium text-slate-700 mt-0.5"><%= user.getName() %></p>
          </div>
          <div>
            <p class="text-xs font-bold uppercase tracking-wider text-slate-400">Username</p>
            <p class="font-medium text-slate-700 mt-0.5">@<%= user.getUsername() %></p>
          </div>
          <div>
            <p class="text-xs font-bold uppercase tracking-wider text-slate-400">Account Type</p>
            <span class="inline-block mt-1 bg-brand-50 text-brand-700 text-[10px] font-bold uppercase px-2 py-1 rounded">
              <%= user.getRole() %>
            </span>
          </div>
        </div>
        <div class="mt-8 pt-4 border-t border-slate-100">
          <a href="${pageContext.request.contextPath}/auth?action=logout" class="block w-full text-center text-rose-600 font-semibold hover:bg-rose-50 py-2 rounded-lg transition-colors">
            Sign Out
          </a>
        </div>
      </div>

      <!-- Quick Actions & Status -->
      <div class="md:col-span-2 space-y-6">
        <div class="bg-white rounded-2xl shadow-card p-8 border border-slate-100 text-center flex flex-col items-center justify-center min-h-[250px]">
          <div class="w-16 h-16 rounded-full bg-slate-50 text-slate-400 flex items-center justify-center text-3xl mb-4">
            <i class="bi bi-car-front"></i>
          </div>
          <h3 class="text-xl font-bold text-ink-900 mb-2">No Active Rentals</h3>
          <p class="text-slate-500 mb-6 max-w-sm">You haven't rented any vehicles yet. Check out our fleet and hit the road!</p>
          <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="bg-brand-600 hover:bg-brand-700 text-white font-bold py-3 px-8 rounded-xl shadow-btn transition-colors">
            Browse Vehicles
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ include file="footer.jspf" %>
