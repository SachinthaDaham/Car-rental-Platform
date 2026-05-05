<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.dao.VehicleDAO, com.vrp.model.Vehicle, java.util.*" %>
<%
    request.setAttribute("nav", "home");
    request.setAttribute("pageTitle", "DriveLanka — Premium Vehicle Rental");
    VehicleDAO dao = new VehicleDAO(System.getProperty("user.home") + "/vrp_data/vehicles.txt");
    List<Vehicle> all = dao.getAllVehicles();
    List<Vehicle> featured = all.subList(0, Math.min(6, all.size()));
    Map<String,Object> stats = dao.getStats();
%>
<%@ include file="WEB-INF/views/header.jspf" %>

<!-- HERO -->
<section class="relative overflow-hidden">
  <div class="absolute inset-0 bg-gradient-to-br from-brand-900 via-ink-900 to-brand-700"></div>
  <div class="absolute inset-0 opacity-20" style="background-image:radial-gradient(circle at 20% 20%, #38bdf8 0, transparent 40%), radial-gradient(circle at 80% 60%, #6366f1 0, transparent 45%);"></div>
  <div class="relative max-w-7xl mx-auto px-6 py-24 md:py-32 text-white">
    <span class="inline-flex items-center gap-2 bg-white/10 border border-white/20 backdrop-blur px-3 py-1 rounded-full text-xs font-medium mb-6">
      <i class="bi bi-stars"></i> Sri Lanka's #1 OOP-powered rental demo
    </span>
    <h1 class="text-4xl md:text-6xl font-extrabold leading-tight tracking-tight max-w-3xl">
      Drive Anywhere. <span class="bg-gradient-to-r from-sky-300 to-cyan-200 bg-clip-text text-transparent">Anytime.</span>
    </h1>
    <p class="mt-5 text-lg text-slate-200 max-w-2xl">
      Rent cars, bikes and vans from a curated, modern fleet — managed end-to-end by the
      <strong>Vehicle Management</strong> module of the DriveLanka platform.
    </p>
    <div class="mt-8 flex flex-wrap gap-3">
      <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="bg-white text-brand-700 hover:bg-brand-50 font-semibold px-6 py-3 rounded-xl shadow-lg inline-flex items-center gap-2">
        <i class="bi bi-search"></i> Browse Fleet
      </a>
      <% if (sessionUser != null && sessionUser.isAdmin()) { %>
      <a href="${pageContext.request.contextPath}/vehicles?action=dashboard" class="bg-white/10 hover:bg-white/20 border border-white/30 text-white font-semibold px-6 py-3 rounded-xl inline-flex items-center gap-2">
        <i class="bi bi-speedometer2"></i> Admin Dashboard
      </a>
      <% } else if (sessionUser != null) { %>
      <a href="${pageContext.request.contextPath}/auth?action=dashboard" class="bg-white/10 hover:bg-white/20 border border-white/30 text-white font-semibold px-6 py-3 rounded-xl inline-flex items-center gap-2">
        <i class="bi bi-person"></i> My Dashboard
      </a>
      <% } else { %>
      <a href="${pageContext.request.contextPath}/auth?action=login" class="bg-white/10 hover:bg-white/20 border border-white/30 text-white font-semibold px-6 py-3 rounded-xl inline-flex items-center gap-2">
        <i class="bi bi-box-arrow-in-right"></i> Sign In
      </a>
      <% } %>
    </div>

    <!-- Quick search bar -->
    <form action="${pageContext.request.contextPath}/vehicles" method="get" class="mt-10 bg-white/95 backdrop-blur rounded-2xl shadow-2xl p-4 grid md:grid-cols-4 gap-3 max-w-4xl">
      <input type="hidden" name="action" value="browse">
      <div class="md:col-span-2">
        <label class="block text-xs font-semibold text-slate-500 mb-1">Search</label>
        <input name="keyword" placeholder="Brand, model, location..." class="w-full px-3 py-2 border border-slate-200 rounded-lg text-slate-800 focus:ring-2 focus:ring-brand-500 outline-none">
      </div>
      <div>
        <label class="block text-xs font-semibold text-slate-500 mb-1">Type</label>
        <select name="type" class="w-full px-3 py-2 border border-slate-200 rounded-lg text-slate-800 focus:ring-2 focus:ring-brand-500 outline-none">
          <option value="">All</option>
          <option>Car</option><option>Bike</option><option>Van</option>
        </select>
      </div>
      <div class="flex items-end">
        <button class="w-full bg-brand-600 hover:bg-brand-700 text-white font-semibold py-2 rounded-lg flex items-center justify-center gap-2"><i class="bi bi-arrow-right-circle"></i> Search</button>
      </div>
    </form>
  </div>
</section>

<!-- STATS STRIP -->
<section class="max-w-7xl mx-auto px-6 -mt-10 relative z-10">
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
    <%
      String[][] tiles = {
        {"bi-collection", "Total Fleet", String.valueOf(stats.get("total"))},
        {"bi-check-circle", "Available Now", String.valueOf(stats.get("available"))},
        {"bi-car-front", "Cars", String.valueOf(stats.get("cars"))},
        {"bi-bicycle", "Bikes", String.valueOf(stats.get("bikes"))}
      };
      for (String[] t : tiles) {
    %>
      <div class="bg-white rounded-2xl shadow-card p-5 flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-brand-50 text-brand-600 flex items-center justify-center text-xl">
          <i class="bi <%= t[0] %>"></i>
        </div>
        <div>
          <div class="text-2xl font-extrabold leading-none"><%= t[2] %></div>
          <div class="text-xs uppercase tracking-wider text-slate-500 mt-1"><%= t[1] %></div>
        </div>
      </div>
    <% } %>
  </div>
</section>

<!-- FEATURED -->
<section class="max-w-7xl mx-auto px-6 mt-20">
  <div class="flex items-end justify-between mb-6">
    <div>
      <h2 class="text-3xl font-extrabold tracking-tight">Featured Vehicles</h2>
      <p class="text-slate-500">Hand-picked rides from across our fleet.</p>
    </div>
    <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="text-brand-600 hover:text-brand-700 font-semibold text-sm flex items-center gap-1">View all <i class="bi bi-arrow-right"></i></a>
  </div>
  <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
    <% for (Vehicle v : featured) { %>
      <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= v.getId() %>" class="group bg-white rounded-2xl shadow-card overflow-hidden hover:-translate-y-1 transition-all duration-300">
        <div class="aspect-[16/10] overflow-hidden bg-slate-100 relative">
          <img src="<%= v.getImageUrl() %>" onerror="this.src='https://placehold.co/600x400/e0f2fe/0369a1?text=<%= v.getType() %>'" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" alt="<%= v.getName() %>">
          <span class="absolute top-3 left-3 bg-white/90 backdrop-blur text-xs font-bold uppercase tracking-wide text-brand-700 px-2.5 py-1 rounded-full">
            <i class="bi <%= v.getIconClass() %>"></i> <%= v.getType() %>
          </span>
          <% if (v.isAvailable()) { %>
            <span class="absolute top-3 right-3 bg-emerald-500 text-white text-[10px] font-bold uppercase px-2 py-1 rounded-full">Available</span>
          <% } else { %>
            <span class="absolute top-3 right-3 bg-rose-500 text-white text-[10px] font-bold uppercase px-2 py-1 rounded-full">Rented</span>
          <% } %>
        </div>
        <div class="p-5">
          <div class="flex items-start justify-between">
            <div>
              <h3 class="font-bold text-lg leading-tight"><%= v.getName() %></h3>
              <p class="text-slate-500 text-sm mt-1"><%= v.getSpecLine() %></p>
            </div>
            <div class="text-right">
              <div class="text-brand-700 font-extrabold text-lg">LKR <%= String.format("%,.0f", v.getDailyRate()) %></div>
              <div class="text-[10px] uppercase tracking-wider text-slate-400">/ day</div>
            </div>
          </div>
          <div class="flex items-center justify-between mt-4 pt-4 border-t border-slate-100">
            <span class="text-xs text-slate-500"><i class="bi bi-geo-alt"></i> <%= v.getLocation() %></span>
            <span class="text-brand-600 text-sm font-semibold flex items-center gap-1">Details <i class="bi bi-arrow-right"></i></span>
          </div>
        </div>
      </a>
    <% } %>
  </div>
</section>

<!-- WHY US -->
<section class="max-w-7xl mx-auto px-6 mt-24">
  <h2 class="text-3xl font-extrabold tracking-tight text-center mb-12">Why DriveLanka</h2>
  <div class="grid md:grid-cols-3 gap-6">
    <%
      String[][] feats = {
        {"bi-shield-check","Verified Fleet","Every vehicle is inspected and insured before listing."},
        {"bi-tag","Best Daily Rates","Transparent pricing — no hidden fees, weekly discounts up to 20%."},
        {"bi-headset","24/7 Support","Roadside help and customer support around the clock."}
      };
      for (String[] f : feats) {
    %>
      <div class="bg-white rounded-2xl p-7 shadow-card border border-slate-100">
        <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-brand-500 to-brand-700 text-white flex items-center justify-center text-xl mb-4">
          <i class="bi <%= f[0] %>"></i>
        </div>
        <h3 class="font-bold text-lg"><%= f[1] %></h3>
        <p class="text-slate-500 mt-2"><%= f[2] %></p>
      </div>
    <% } %>
  </div>
</section>

<!-- CTA -->
<section class="max-w-7xl mx-auto px-6 mt-24">
  <div class="rounded-3xl bg-gradient-to-r from-brand-600 to-indigo-600 text-white p-10 md:p-14 flex flex-col md:flex-row items-center justify-between gap-6 shadow-2xl">
    <div>
      <h3 class="text-3xl font-extrabold">Ready to roll?</h3>
      <p class="text-brand-50 mt-1">Browse the fleet, pick your ride, and you're on the road.</p>
    </div>
    <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="bg-white text-brand-700 hover:bg-brand-50 font-bold px-7 py-3 rounded-xl shadow-lg">Browse Fleet</a>
  </div>
</section>

<%@ include file="WEB-INF/views/footer.jspf" %>
