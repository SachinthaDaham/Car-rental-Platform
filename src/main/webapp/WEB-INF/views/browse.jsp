<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.vrp.model.Vehicle" %>
<%
    request.setAttribute("nav", "browse");
    request.setAttribute("pageTitle", "Browse Fleet — DriveLanka");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    String kw = (String) request.getAttribute("keyword");
    String typeF = (String) request.getAttribute("typeFilter");
    String minR = (String) request.getAttribute("minRate");
    String maxR = (String) request.getAttribute("maxRate");
    boolean availOnly = Boolean.TRUE.equals(request.getAttribute("availableOnly"));
%>
<%@ include file="header.jspf" %>

<section class="bg-gradient-to-r from-brand-700 to-indigo-700 text-white">
  <div class="max-w-7xl mx-auto px-6 py-14">
    <h1 class="text-4xl font-extrabold">Our Fleet</h1>
    <p class="text-brand-100 mt-2">Find the perfect vehicle for every journey.</p>
  </div>
</section>

<div class="max-w-7xl mx-auto px-6 py-10 grid lg:grid-cols-[280px_1fr] gap-8">

  <!-- FILTER SIDEBAR -->
  <aside class="bg-white rounded-2xl shadow-card p-6 h-fit lg:sticky lg:top-24">
    <form action="${pageContext.request.contextPath}/vehicles" method="get" class="space-y-5">
      <input type="hidden" name="action" value="browse">
      <div>
        <label class="text-xs font-bold uppercase tracking-wider text-slate-500">Search</label>
        <div class="relative mt-1">
          <i class="bi bi-search absolute left-3 top-2.5 text-slate-400"></i>
          <input name="keyword" value="<%= kw==null?"":kw %>" placeholder="Brand, model..." class="pl-9 w-full px-3 py-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-brand-500 outline-none">
        </div>
      </div>
      <div>
        <label class="text-xs font-bold uppercase tracking-wider text-slate-500">Vehicle Type</label>
        <div class="mt-2 grid grid-cols-3 gap-1 text-center text-sm">
          <% String[] tps = {"", "Car", "Bike", "Van"};
             String[] lbs = {"All", "Car", "Bike", "Van"};
             for (int i = 0; i < tps.length; i++) {
               boolean sel = (typeF==null && tps[i].isEmpty()) || (typeF!=null && typeF.equalsIgnoreCase(tps[i]));
          %>
            <label class="cursor-pointer">
              <input type="radio" name="type" value="<%= tps[i] %>" class="hidden peer" <%= sel?"checked":"" %>>
              <div class="px-2 py-1.5 rounded-md border border-slate-200 peer-checked:bg-brand-600 peer-checked:text-white peer-checked:border-brand-600 hover:border-brand-400"><%= lbs[i] %></div>
            </label>
          <% } %>
        </div>
      </div>
      <div>
        <label class="text-xs font-bold uppercase tracking-wider text-slate-500">Daily Rate (LKR)</label>
        <div class="mt-1 grid grid-cols-2 gap-2">
          <input name="minRate" value="<%= minR==null?"":minR %>" placeholder="Min" type="number" class="px-3 py-2 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
          <input name="maxRate" value="<%= maxR==null?"":maxR %>" placeholder="Max" type="number" class="px-3 py-2 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
        </div>
      </div>
      <label class="flex items-center gap-2 select-none">
        <input type="checkbox" name="availableOnly" value="1" <%= availOnly?"checked":"" %> class="w-4 h-4 accent-brand-600">
        <span class="text-sm text-slate-700">Available only</span>
      </label>
      <button class="w-full bg-brand-600 hover:bg-brand-700 text-white font-semibold py-2.5 rounded-lg flex items-center justify-center gap-2"><i class="bi bi-funnel-fill"></i> Apply Filters</button>
      <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="block text-center text-sm text-slate-500 hover:text-brand-600">Reset</a>
    </form>
  </aside>

  <!-- RESULTS -->
  <section>
    <div class="flex items-center justify-between mb-5">
      <p class="text-slate-600"><span class="font-bold text-ink-900"><%= vehicles==null?0:vehicles.size() %></span> vehicles found</p>
    </div>

    <% if (vehicles == null || vehicles.isEmpty()) { %>
      <div class="bg-white rounded-2xl shadow-card p-10 text-center">
        <i class="bi bi-emoji-frown text-5xl text-slate-300"></i>
        <h3 class="font-bold text-xl mt-3">No vehicles match your filters</h3>
        <p class="text-slate-500 mt-1">Try widening your search or resetting filters.</p>
      </div>
    <% } else { %>
      <div class="grid sm:grid-cols-2 xl:grid-cols-3 gap-6">
        <% for (Vehicle v : vehicles) { %>
          <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= v.getId() %>" class="group bg-white rounded-2xl shadow-card overflow-hidden hover:-translate-y-1 transition-all duration-300">
            <div class="aspect-[16/10] overflow-hidden bg-slate-100 relative">
              <img src="<%= v.getImageUrl() %>" onerror="this.src='https://placehold.co/600x400/e0f2fe/0369a1?text=<%= v.getType() %>'" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" alt="<%= v.getName() %>">
              <span class="absolute top-3 left-3 bg-white/90 text-xs font-bold uppercase text-brand-700 px-2.5 py-1 rounded-full"><i class="bi <%= v.getIconClass() %>"></i> <%= v.getType() %></span>
              <% if (v.isAvailable()) { %>
                <span class="absolute top-3 right-3 bg-emerald-500 text-white text-[10px] font-bold uppercase px-2 py-1 rounded-full">Available</span>
              <% } else { %>
                <span class="absolute top-3 right-3 bg-rose-500 text-white text-[10px] font-bold uppercase px-2 py-1 rounded-full">Rented</span>
              <% } %>
            </div>
            <div class="p-5">
              <h3 class="font-bold text-lg leading-tight"><%= v.getName() %></h3>
              <p class="text-slate-500 text-sm mt-1"><%= v.getSpecLine() %></p>
              <div class="flex items-end justify-between mt-4">
                <span class="text-xs text-slate-500"><i class="bi bi-geo-alt"></i> <%= v.getLocation() %></span>
                <span class="text-brand-700 font-extrabold text-lg">LKR <%= String.format("%,.0f", v.getDailyRate()) %><span class="text-xs text-slate-400 font-medium">/day</span></span>
              </div>
            </div>
          </a>
        <% } %>
      </div>
    <% } %>
  </section>
</div>

<%@ include file="footer.jspf" %>
