<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.vrp.model.Vehicle" %>
<%
    request.setAttribute("nav", "list");
    request.setAttribute("pageTitle", "Manage Fleet — DriveLanka Admin");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    String msg = request.getParameter("msg");
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">
  <div class="max-w-7xl mx-auto px-6 py-10">
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-3xl font-extrabold text-ink-900">Manage Fleet</h1>
        <p class="text-slate-500 mt-1">View, edit, and update your vehicle listings.</p>
      </div>
      <a href="${pageContext.request.contextPath}/vehicles?action=add" class="bg-brand-600 hover:bg-brand-700 text-white font-bold py-2.5 px-5 rounded-lg shadow-btn transition-colors duration-200">
        <i class="bi bi-plus-lg mr-1"></i> Add Vehicle
      </a>
    </div>

    <% if ("created".equals(msg)) { %>
      <div class="mb-6 bg-emerald-50 text-emerald-700 px-4 py-3 rounded-lg border border-emerald-200 font-medium">Vehicle successfully added to fleet.</div>
    <% } else if ("updated".equals(msg)) { %>
      <div class="mb-6 bg-blue-50 text-blue-700 px-4 py-3 rounded-lg border border-blue-200 font-medium">Vehicle information updated.</div>
    <% } else if ("deleted".equals(msg)) { %>
      <div class="mb-6 bg-slate-100 text-slate-700 px-4 py-3 rounded-lg border border-slate-200 font-medium">Vehicle removed from fleet.</div>
    <% } else if ("toggled".equals(msg)) { %>
      <div class="mb-6 bg-brand-50 text-brand-700 px-4 py-3 rounded-lg border border-brand-200 font-medium">Availability status changed.</div>
    <% } %>

    <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-slate-50 text-xs uppercase text-slate-500 tracking-wider">
              <th class="px-6 py-4 font-semibold">Vehicle & ID</th>
              <th class="px-6 py-4 font-semibold">Type</th>
              <th class="px-6 py-4 font-semibold">Daily Rate</th>
              <th class="px-6 py-4 font-semibold text-center">Status</th>
              <th class="px-6 py-4 font-semibold text-right">Actions</th>
            </tr>
          </thead>
          <tbody class="text-sm">
            <% if (vehicles == null || vehicles.isEmpty()) { %>
              <tr>
                <td colspan="5" class="px-6 py-10 text-center text-slate-500">
                  <i class="bi bi-inbox text-4xl mb-3 block"></i>
                  <p class="text-lg">No vehicles found in the system.</p>
                </td>
              </tr>
            <% } else { %>
              <% for (Vehicle v : vehicles) { %>
                <tr class="border-b border-slate-50 last:border-0 hover:bg-slate-50 transition-colors">
                  <td class="px-6 py-4 flex items-center gap-4">
                    <img src="<%= v.getImageUrl() %>" onerror="this.src='https://placehold.co/100x100/e0f2fe/0369a1'" class="w-12 h-12 rounded-lg object-cover bg-slate-100">
                    <div>
                      <p class="font-bold text-ink-900 text-base"><%= v.getName() %></p>
                      <p class="text-xs font-mono text-slate-400"><%= v.getId() %></p>
                    </div>
                  </td>
                  <td class="px-6 py-4">
                    <span class="inline-flex items-center gap-1.5 bg-slate-100 text-slate-700 text-xs font-semibold px-2.5 py-1 rounded-md">
                      <i class="bi <%= v.getIconClass() %> text-slate-500"></i> <%= v.getType() %>
                    </span>
                  </td>
                  <td class="px-6 py-4 font-medium text-slate-700">LKR <%= String.format("%,.0f", v.getDailyRate()) %></td>
                  <td class="px-6 py-4 text-center">
                    <% if (v.isAvailable()) { %>
                      <a href="${pageContext.request.contextPath}/vehicles?action=toggle&id=<%= v.getId() %>" class="inline-block bg-emerald-100 hover:bg-emerald-200 text-emerald-700 text-xs font-bold uppercase px-3 py-1.5 rounded-full transition-colors" title="Click to mark as Rented">Available</a>
                    <% } else { %>
                      <a href="${pageContext.request.contextPath}/vehicles?action=toggle&id=<%= v.getId() %>" class="inline-block bg-rose-100 hover:bg-rose-200 text-rose-700 text-xs font-bold uppercase px-3 py-1.5 rounded-full transition-colors" title="Click to mark as Available">Rented</a>
                    <% } %>
                  </td>
                  <td class="px-6 py-4 text-right space-x-2">
                    <a href="${pageContext.request.contextPath}/vehicles?action=edit&id=<%= v.getId() %>" class="inline-flex items-center justify-center w-8 h-8 rounded bg-slate-100 hover:bg-brand-100 text-slate-600 hover:text-brand-700 transition-colors" title="Edit">
                      <i class="bi bi-pencil-square"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}/vehicles?action=delete&id=<%= v.getId() %>" onclick="return confirm('Are you sure you want to delete this <%= v.getType() %>?');" class="inline-flex items-center justify-center w-8 h-8 rounded bg-slate-100 hover:bg-rose-100 text-slate-600 hover:text-rose-700 transition-colors" title="Delete">
                      <i class="bi bi-trash3"></i>
                    </a>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<%@ include file="footer.jspf" %>
