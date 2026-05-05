<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map, java.util.List, com.vrp.model.Vehicle" %>
<%
    request.setAttribute("nav", "dashboard");
    request.setAttribute("pageTitle", "Admin Dashboard — DriveLanka");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<Vehicle> recent = (List<Vehicle>) request.getAttribute("recent");
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">
  <div class="max-w-7xl mx-auto px-6 py-10">
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-3xl font-extrabold text-ink-900">Admin Dashboard</h1>
        <p class="text-slate-500 mt-1">Overview of your fleet and operations.</p>
      </div>
      <a href="${pageContext.request.contextPath}/vehicles?action=list" class="bg-brand-600 hover:bg-brand-700 text-white font-bold py-2.5 px-5 rounded-lg shadow-btn transition-colors duration-200">
        Manage Fleet <i class="bi bi-arrow-right ml-1"></i>
      </a>
    </div>

    <!-- Stats Grid -->
    <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex items-center gap-5">
        <div class="w-14 h-14 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center text-2xl">
          <i class="bi bi-car-front-fill"></i>
        </div>
        <div>
          <p class="text-slate-500 text-sm font-bold uppercase tracking-wider mb-1">Total Fleet</p>
          <p class="text-3xl font-extrabold text-ink-900"><%= stats.get("total") %></p>
        </div>
      </div>
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex items-center gap-5">
        <div class="w-14 h-14 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center text-2xl">
          <i class="bi bi-check-circle-fill"></i>
        </div>
        <div>
          <p class="text-slate-500 text-sm font-bold uppercase tracking-wider mb-1">Available</p>
          <p class="text-3xl font-extrabold text-ink-900"><%= stats.get("available") %></p>
        </div>
      </div>
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex items-center gap-5">
        <div class="w-14 h-14 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center text-2xl">
          <i class="bi bi-key-fill"></i>
        </div>
        <div>
          <p class="text-slate-500 text-sm font-bold uppercase tracking-wider mb-1">Rented</p>
          <p class="text-3xl font-extrabold text-ink-900"><%= stats.get("rented") %></p>
        </div>
      </div>
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex items-center gap-5">
        <div class="w-14 h-14 rounded-full bg-purple-100 text-purple-600 flex items-center justify-center text-2xl">
          <i class="bi bi-cash-stack"></i>
        </div>
        <div>
          <p class="text-slate-500 text-sm font-bold uppercase tracking-wider mb-1">Fleet Value/Day</p>
          <p class="text-2xl font-extrabold text-ink-900">Rs <%= String.format("%,.0f", stats.get("fleetValuePerDay")) %></p>
        </div>
      </div>
    </div>

    <div class="grid lg:grid-cols-3 gap-8">
      <!-- Composition Chart (CSS only representation) -->
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 lg:col-span-1">
        <h3 class="font-bold text-lg mb-6">Fleet Composition</h3>
        <div class="space-y-6">
          <div>
            <div class="flex justify-between text-sm mb-1 font-medium">
              <span class="text-slate-700"><i class="bi bi-car-front text-brand-500 mr-2"></i>Cars</span>
              <span><%= stats.get("cars") %></span>
            </div>
            <div class="w-full bg-slate-100 rounded-full h-2.5">
              <div class="bg-brand-500 h-2.5 rounded-full" style="width: <%= (Long)stats.get("cars") * 100.0 / (Integer)stats.get("total") %>%"></div>
            </div>
          </div>
          <div>
            <div class="flex justify-between text-sm mb-1 font-medium">
              <span class="text-slate-700"><i class="bi bi-bicycle text-indigo-500 mr-2"></i>Bikes</span>
              <span><%= stats.get("bikes") %></span>
            </div>
            <div class="w-full bg-slate-100 rounded-full h-2.5">
              <div class="bg-indigo-500 h-2.5 rounded-full" style="width: <%= (Long)stats.get("bikes") * 100.0 / (Integer)stats.get("total") %>%"></div>
            </div>
          </div>
          <div>
            <div class="flex justify-between text-sm mb-1 font-medium">
              <span class="text-slate-700"><i class="bi bi-truck text-emerald-500 mr-2"></i>Vans</span>
              <span><%= stats.get("vans") %></span>
            </div>
            <div class="w-full bg-slate-100 rounded-full h-2.5">
              <div class="bg-emerald-500 h-2.5 rounded-full" style="width: <%= (Long)stats.get("vans") * 100.0 / (Integer)stats.get("total") %>%"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Vehicles -->
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 lg:col-span-2">
        <h3 class="font-bold text-lg mb-6">Recently Added Vehicles</h3>
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="text-xs uppercase text-slate-400 border-b border-slate-100">
                <th class="pb-3 font-semibold">Vehicle</th>
                <th class="pb-3 font-semibold">Type</th>
                <th class="pb-3 font-semibold">Rate</th>
                <th class="pb-3 font-semibold text-right">Status</th>
              </tr>
            </thead>
            <tbody class="text-sm">
              <% for (Vehicle v : recent) { %>
                <tr class="border-b border-slate-50 last:border-0 hover:bg-slate-50">
                  <td class="py-4 flex items-center gap-3">
                    <img src="<%= v.getImageUrl() %>" onerror="this.src='https://placehold.co/100x100/e0f2fe/0369a1'" class="w-10 h-10 rounded-lg object-cover bg-slate-100">
                    <div>
                      <p class="font-bold text-ink-900"><%= v.getName() %></p>
                      <p class="text-xs text-slate-500"><%= v.getId() %></p>
                    </div>
                  </td>
                  <td class="py-4 text-slate-600"><%= v.getType() %></td>
                  <td class="py-4 font-medium">Rs <%= String.format("%,.0f", v.getDailyRate()) %></td>
                  <td class="py-4 text-right">
                    <% if (v.isAvailable()) { %>
                      <span class="bg-emerald-100 text-emerald-700 text-[10px] font-bold uppercase px-2 py-1 rounded">Available</span>
                    <% } else { %>
                      <span class="bg-rose-100 text-rose-700 text-[10px] font-bold uppercase px-2 py-1 rounded">Rented</span>
                    <% } %>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ include file="footer.jspf" %>
