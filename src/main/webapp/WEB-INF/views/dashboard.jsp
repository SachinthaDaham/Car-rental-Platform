<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,com.vrp.model.Vehicle" %>
<%
    request.setAttribute("nav", "dashboard");
    request.setAttribute("pageTitle", "Admin Dashboard — DriveLanka");
    Map<String,Object> stats = (Map<String,Object>) request.getAttribute("stats");
    List<Vehicle> recent     = (List<Vehicle>) request.getAttribute("recent");
    List<Vehicle> topEarners = (List<Vehicle>) request.getAttribute("topEarners");
    int total  = (Integer) stats.get("total");
    long avail = (Long) stats.get("available");
    long rented= (Long) stats.get("rented");
    long cars  = (Long) stats.get("cars");
    long bikes = (Long) stats.get("bikes");
    long vans  = (Long) stats.get("vans");
    double avgRate = (Double) stats.get("avgRate");
    double fleetVal= (Double) stats.get("fleetValuePerDay");
    int utilPct = total > 0 ? (int)(rented * 100.0 / total) : 0;
    int availPct= total > 0 ? (int)(avail  * 100.0 / total) : 0;
%>
<%@ include file="header.jspf" %>

<!-- Dashboard Hero -->
<div class="bg-gradient-to-br from-ink-900 via-brand-900 to-indigo-900 text-white">
  <div class="max-w-7xl mx-auto px-6 py-10">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <p class="text-brand-200 text-sm font-semibold uppercase tracking-wider mb-1">Admin Panel</p>
        <h1 class="text-3xl font-extrabold">Fleet Dashboard</h1>
        <p class="text-slate-300 mt-1">Real-time overview of the DriveLanka vehicle fleet.</p>
      </div>
      <div class="flex gap-3">
        <a href="${pageContext.request.contextPath}/vehicles?action=add" class="inline-flex items-center gap-2 bg-white/10 hover:bg-white/20 border border-white/25 text-white font-semibold px-4 py-2.5 rounded-xl transition">
          <i class="bi bi-plus-lg"></i> Add Vehicle
        </a>
        <a href="${pageContext.request.contextPath}/vehicles?action=list" class="inline-flex items-center gap-2 bg-brand-500 hover:bg-brand-600 text-white font-semibold px-4 py-2.5 rounded-xl shadow-btn transition">
          Manage Fleet <i class="bi bi-arrow-right"></i>
        </a>
      </div>
    </div>
  </div>
</div>

<div class="max-w-7xl mx-auto px-6 -mt-6 pb-16 space-y-8">

  <!-- KPI CARDS -->
  <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
    <%
      Object[][] kpis = {
        {"bi-collection-fill","Total Fleet",String.valueOf(total),"All vehicles","bg-brand-50 text-brand-600"},
        {"bi-check-circle-fill","Available",String.valueOf(avail),avail+" ready to rent","bg-emerald-50 text-emerald-600"},
        {"bi-key-fill","Currently Rented",String.valueOf(rented),rented+" on the road","bg-rose-50 text-rose-600"},
        {"bi-cash-stack","Fleet Value/Day","Rs "+String.format("%,.0f",fleetVal),"Avg Rs "+String.format("%,.0f",avgRate)+"/vehicle","bg-amber-50 text-amber-600"}
      };
      for(Object[] k:kpis){
    %>
      <div class="bg-white rounded-2xl border border-slate-100 shadow-card p-5">
        <div class="flex items-center gap-3 mb-3">
          <div class="w-11 h-11 rounded-xl <%= k[4] %> flex items-center justify-center text-xl">
            <i class="bi <%= k[0] %>"></i>
          </div>
          <p class="text-xs font-bold uppercase tracking-wider text-slate-400"><%= k[1] %></p>
        </div>
        <p class="text-3xl font-extrabold text-ink-900"><%= k[2] %></p>
        <p class="text-xs text-slate-400 mt-1"><%= k[3] %></p>
      </div>
    <% } %>
  </div>

  <!-- MIDDLE ROW: Utilization + Composition + Breakdown -->
  <div class="grid lg:grid-cols-3 gap-6">

    <!-- Utilization Ring -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-card p-6 flex flex-col items-center justify-center text-center">
      <h3 class="font-bold text-lg text-ink-900 mb-6 self-start">Fleet Utilization</h3>
      <div class="relative w-36 h-36 mb-4">
        <svg class="w-full h-full -rotate-90" viewBox="0 0 120 120">
          <circle cx="60" cy="60" r="50" fill="none" stroke="#e2e8f0" stroke-width="12"/>
          <circle cx="60" cy="60" r="50" fill="none" stroke="#0284c7" stroke-width="12"
                  stroke-dasharray="314"
                  stroke-dashoffset="<%= 314 - (314 * utilPct / 100) %>"
                  stroke-linecap="round" class="transition-all duration-1000"/>
        </svg>
        <div class="absolute inset-0 flex flex-col items-center justify-center">
          <span class="text-3xl font-extrabold text-brand-700"><%= utilPct %>%</span>
          <span class="text-xs text-slate-400">Utilization</span>
        </div>
      </div>
      <div class="grid grid-cols-2 gap-3 w-full mt-2">
        <div class="bg-emerald-50 rounded-xl p-3 text-center">
          <p class="text-xl font-extrabold text-emerald-600"><%= avail %></p>
          <p class="text-xs text-slate-500 font-medium">Available</p>
        </div>
        <div class="bg-rose-50 rounded-xl p-3 text-center">
          <p class="text-xl font-extrabold text-rose-600"><%= rented %></p>
          <p class="text-xs text-slate-500 font-medium">Rented</p>
        </div>
      </div>
    </div>

    <!-- Fleet Composition Bars -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-card p-6">
      <h3 class="font-bold text-lg text-ink-900 mb-6">Fleet Composition</h3>
      <div class="space-y-5">
        <%
          Object[][] comp = {
            {"bi-car-front","Cars",String.valueOf(cars),String.valueOf(total>0?cars*100/total:0),"bg-brand-500"},
            {"bi-bicycle","Bikes",String.valueOf(bikes),String.valueOf(total>0?bikes*100/total:0),"bg-indigo-500"},
            {"bi-truck","Vans",String.valueOf(vans),String.valueOf(total>0?vans*100/total:0),"bg-emerald-500"}
          };
          for(Object[] c:comp){
        %>
          <div>
            <div class="flex items-center justify-between text-sm mb-2">
              <span class="flex items-center gap-2 font-medium text-slate-700">
                <i class="bi <%= c[0] %> text-slate-400"></i><%= c[1] %>
              </span>
              <span class="font-bold text-ink-900"><%= c[2] %> <span class="text-slate-400 font-normal text-xs">(<%= c[3] %>%)</span></span>
            </div>
            <div class="h-2.5 bg-slate-100 rounded-full overflow-hidden">
              <div class="h-full <%= c[4] %> rounded-full progress-bar" style="width:<%= c[3] %>%"></div>
            </div>
          </div>
        <% } %>
      </div>

      <!-- Availability breakdown per type -->
      <div class="mt-6 pt-5 border-t border-slate-100">
        <p class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-3">Availability Rate</p>
        <div class="h-3 bg-slate-100 rounded-full overflow-hidden flex">
          <div class="h-full bg-emerald-400 transition-all duration-700" style="width:<%= availPct %>%" title="<%= avail %> available"></div>
          <div class="h-full bg-rose-400 transition-all duration-700" style="width:<%= 100-availPct %>%" title="<%= rented %> rented"></div>
        </div>
        <div class="flex items-center gap-4 mt-2 text-xs text-slate-500">
          <span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-emerald-400 inline-block"></span><%= availPct %>% Available</span>
          <span class="flex items-center gap-1"><span class="w-2 h-2 rounded-full bg-rose-400 inline-block"></span><%= 100-availPct %>% Rented</span>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-card p-6">
      <h3 class="font-bold text-lg text-ink-900 mb-5">Quick Actions</h3>
      <div class="space-y-3">
        <a href="${pageContext.request.contextPath}/vehicles?action=add" class="flex items-center gap-3 p-3 rounded-xl border border-slate-100 hover:border-brand-200 hover:bg-brand-50 transition group">
          <div class="w-10 h-10 bg-brand-100 rounded-lg flex items-center justify-center text-brand-600 group-hover:bg-brand-600 group-hover:text-white transition">
            <i class="bi bi-plus-lg"></i>
          </div>
          <div>
            <p class="font-semibold text-sm text-ink-900">Add Vehicle</p>
            <p class="text-xs text-slate-400">Register new fleet vehicle</p>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse&availableOnly=1" class="flex items-center gap-3 p-3 rounded-xl border border-slate-100 hover:border-emerald-200 hover:bg-emerald-50 transition group">
          <div class="w-10 h-10 bg-emerald-100 rounded-lg flex items-center justify-center text-emerald-600 group-hover:bg-emerald-600 group-hover:text-white transition">
            <i class="bi bi-check2-circle"></i>
          </div>
          <div>
            <p class="font-semibold text-sm text-ink-900">View Available</p>
            <p class="text-xs text-slate-400"><%= avail %> vehicles ready</p>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse&type=Car" class="flex items-center gap-3 p-3 rounded-xl border border-slate-100 hover:border-indigo-200 hover:bg-indigo-50 transition group">
          <div class="w-10 h-10 bg-indigo-100 rounded-lg flex items-center justify-center text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white transition">
            <i class="bi bi-car-front"></i>
          </div>
          <div>
            <p class="font-semibold text-sm text-ink-900">Browse Cars</p>
            <p class="text-xs text-slate-400"><%= cars %> cars in fleet</p>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/vehicles?action=list" class="flex items-center gap-3 p-3 rounded-xl border border-slate-100 hover:border-slate-300 hover:bg-slate-50 transition group">
          <div class="w-10 h-10 bg-slate-100 rounded-lg flex items-center justify-center text-slate-600 group-hover:bg-slate-600 group-hover:text-white transition">
            <i class="bi bi-table"></i>
          </div>
          <div>
            <p class="font-semibold text-sm text-ink-900">Manage Fleet</p>
            <p class="text-xs text-slate-400"><%= total %> total vehicles</p>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/auth?action=users" class="flex items-center gap-3 p-3 rounded-xl border border-slate-100 hover:border-purple-200 hover:bg-purple-50 transition group">
          <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center text-purple-600 group-hover:bg-purple-600 group-hover:text-white transition">
            <i class="bi bi-people"></i>
          </div>
          <div>
            <p class="font-semibold text-sm text-ink-900">Manage Users</p>
            <p class="text-xs text-slate-400">View registered accounts</p>
          </div>
        </a>
      </div>
    </div>
  </div>

  <!-- REVENUE STRIP -->
  <div class="grid sm:grid-cols-3 gap-4">
    <div class="bg-gradient-to-br from-brand-600 to-brand-800 rounded-2xl p-5 text-white shadow-card">
      <p class="text-brand-200 text-xs font-bold uppercase tracking-wider mb-1">Daily Revenue Potential</p>
      <p class="text-3xl font-extrabold">LKR <%= String.format("%,.0f", fleetVal) %></p>
      <p class="text-brand-100 text-xs mt-1">If all <%= total %> vehicles rented today</p>
    </div>
    <div class="bg-gradient-to-br from-emerald-500 to-emerald-700 rounded-2xl p-5 text-white shadow-card">
      <p class="text-emerald-100 text-xs font-bold uppercase tracking-wider mb-1">Current Active Revenue</p>
      <p class="text-3xl font-extrabold">LKR <%= String.format("%,.0f", fleetVal * rented / Math.max(total,1)) %></p>
      <p class="text-emerald-100 text-xs mt-1">From <%= rented %> rented vehicle<%= rented!=1?"s":"" %></p>
    </div>
    <div class="bg-gradient-to-br from-amber-500 to-orange-600 rounded-2xl p-5 text-white shadow-card">
      <p class="text-amber-100 text-xs font-bold uppercase tracking-wider mb-1">Avg Daily Rate</p>
      <p class="text-3xl font-extrabold">LKR <%= String.format("%,.0f", avgRate) %></p>
      <p class="text-amber-100 text-xs mt-1">Across all fleet vehicles</p>
    </div>
  </div>

  <!-- TOP EARNERS + RECENT IN TWO COLUMNS -->
  <div class="grid lg:grid-cols-2 gap-6">

    <!-- Top Earners -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-card overflow-hidden">
      <div class="px-6 py-4 border-b border-slate-100">
        <h3 class="font-bold text-base text-ink-900 flex items-center gap-2">
          <i class="bi bi-trophy-fill text-amber-500"></i> Top Earners
        </h3>
        <p class="text-xs text-slate-400 mt-0.5">Highest daily rate vehicles</p>
      </div>
      <div class="divide-y divide-slate-50">
        <% if (topEarners != null) { int rank = 1; for (Vehicle te : topEarners) { %>
          <div class="flex items-center gap-4 px-6 py-3 hover:bg-slate-50/60 transition">
            <span class="text-base font-extrabold text-slate-200 w-5 shrink-0">#<%= rank++ %></span>
            <img src="<%= te.getImageUrl() %>" onerror="this.src='https://placehold.co/80x80/e0f2fe/0369a1'"
                 class="w-10 h-10 rounded-lg object-cover bg-slate-100 shrink-0">
            <div class="flex-1 min-w-0">
              <p class="font-bold text-sm text-ink-900 truncate"><%= te.getName() %></p>
              <p class="text-[10px] font-mono text-slate-400"><%= te.getId() %> · <span class="inline-flex items-center gap-0.5 bg-slate-100 px-1.5 py-0.5 rounded text-slate-600"><i class="bi <%= te.getIconClass() %>"></i> <%= te.getType() %></span></p>
            </div>
            <div class="text-right shrink-0">
              <p class="text-sm font-extrabold text-brand-700">LKR <%= String.format("%,.0f", te.getDailyRate()) %></p>
              <p class="text-[10px] text-slate-400">/day</p>
            </div>
          </div>
        <% } } %>
      </div>
    </div>

  <!-- RECENT VEHICLES TABLE -->
  <div class="bg-white rounded-2xl border border-slate-100 shadow-card overflow-hidden">
    <div class="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
      <h3 class="font-bold text-lg text-ink-900">Recently Added Vehicles</h3>
      <a href="${pageContext.request.contextPath}/vehicles?action=list" class="text-sm text-brand-600 hover:text-brand-700 font-semibold flex items-center gap-1">
        View all <i class="bi bi-arrow-right"></i>
      </a>
    </div>
    <div class="overflow-x-auto">
      <table class="w-full text-left">
        <thead>
          <tr class="text-xs uppercase text-slate-400 bg-slate-50 border-b border-slate-100">
            <th class="px-6 py-3 font-semibold">Vehicle</th>
            <th class="px-6 py-3 font-semibold">Type</th>
            <th class="px-6 py-3 font-semibold">Location</th>
            <th class="px-6 py-3 font-semibold">Daily Rate</th>
            <th class="px-6 py-3 font-semibold text-right">Status</th>
          </tr>
        </thead>
        <tbody class="text-sm divide-y divide-slate-50">
          <% for (Vehicle v : recent) { %>
            <tr class="hover:bg-slate-50 transition-colors">
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <img src="<%= v.getImageUrl() %>" onerror="this.src='https://placehold.co/80x80/e0f2fe/0369a1'" class="w-10 h-10 rounded-lg object-cover bg-slate-100 shrink-0">
                  <div>
                    <p class="font-bold text-ink-900"><%= v.getName() %></p>
                    <p class="text-xs font-mono text-slate-400"><%= v.getId() %></p>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4">
                <span class="inline-flex items-center gap-1.5 bg-slate-100 text-slate-700 text-xs font-semibold px-2.5 py-1 rounded-md">
                  <i class="bi <%= v.getIconClass() %>"></i> <%= v.getType() %>
                </span>
              </td>
              <td class="px-6 py-4 text-slate-500 text-sm"><i class="bi bi-geo-alt text-slate-300"></i> <%= v.getLocation() %></td>
              <td class="px-6 py-4 font-semibold text-slate-700">LKR <%= String.format("%,.0f", v.getDailyRate()) %></td>
              <td class="px-6 py-4 text-right">
                <% if (v.isAvailable()) { %>
                  <span class="bg-emerald-100 text-emerald-700 text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">Available</span>
                <% } else { %>
                  <span class="bg-rose-100 text-rose-700 text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">Rented</span>
                <% } %>
              </td>
            </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  </div>
  </div><!-- end two-column grid -->
</div>

<%@ include file="footer.jspf" %>
