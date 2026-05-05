<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.Vehicle" %>
<%
    Vehicle v = (Vehicle) request.getAttribute("vehicle");
    if (v == null) {
        response.sendRedirect(request.getContextPath() + "/vehicles?action=browse");
        return;
    }
    request.setAttribute("pageTitle", v.getName() + " — DriveLanka");
%>
<%@ include file="header.jspf" %>

<div class="max-w-7xl mx-auto px-6 py-12">
  <div class="bg-white rounded-3xl shadow-card overflow-hidden">
    <div class="grid lg:grid-cols-2">
      <!-- Image Section -->
      <div class="bg-slate-100 relative min-h-[400px]">
        <img src="<%= v.getImageUrl() %>" 
             onerror="this.src='https://placehold.co/800x600/e0f2fe/0369a1?text=<%= v.getType() %>'" 
             class="absolute inset-0 w-full h-full object-cover" 
             alt="<%= v.getName() %>">
        <span class="absolute top-6 left-6 bg-white/90 text-sm font-bold uppercase text-brand-700 px-4 py-1.5 rounded-full backdrop-blur-sm shadow-sm">
          <i class="bi <%= v.getIconClass() %> mr-1"></i> <%= v.getType() %>
        </span>
      </div>

      <!-- Details Section -->
      <div class="p-10 lg:p-14 flex flex-col justify-center">
        <div class="flex items-center gap-3 mb-2">
          <% if (v.isAvailable()) { %>
            <span class="bg-emerald-100 text-emerald-700 text-xs font-bold uppercase px-2.5 py-1 rounded-md">Available Now</span>
          <% } else { %>
            <span class="bg-rose-100 text-rose-700 text-xs font-bold uppercase px-2.5 py-1 rounded-md">Currently Rented</span>
          <% } %>
          <span class="text-slate-500 text-sm flex items-center gap-1"><i class="bi bi-geo-alt-fill text-brand-500"></i> <%= v.getLocation() %></span>
        </div>

        <h1 class="text-4xl font-extrabold text-ink-900 leading-tight mb-2"><%= v.getName() %></h1>
        <p class="text-slate-500 text-lg mb-8 border-b border-slate-100 pb-8"><%= v.getDescription() %></p>

        <!-- Specs Grid -->
        <h3 class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-4">Specifications</h3>
        <div class="grid grid-cols-2 gap-y-6 gap-x-4 mb-8">
          <div>
            <p class="text-slate-500 text-sm">Year</p>
            <p class="font-bold text-ink-900"><%= v.getYear() %></p>
          </div>
          <div>
            <p class="text-slate-500 text-sm">Key Features</p>
            <p class="font-bold text-ink-900"><%= v.getSpecLine() %></p>
          </div>
          <div>
            <p class="text-slate-500 text-sm">Vehicle ID</p>
            <p class="font-bold text-slate-700 font-mono text-sm"><%= v.getId() %></p>
          </div>
          <div>
            <p class="text-slate-500 text-sm">Brand</p>
            <p class="font-bold text-ink-900"><%= v.getBrand() %></p>
          </div>
        </div>

        <!-- Pricing & Action -->
        <div class="mt-auto bg-slate-50 rounded-2xl p-6 border border-slate-100">
          <div class="flex items-center justify-between mb-6">
            <div>
              <p class="text-slate-500 text-sm font-medium">Daily Rate</p>
              <p class="text-3xl font-extrabold text-brand-700">LKR <%= String.format("%,.0f", v.getDailyRate()) %></p>
            </div>
            <div class="text-right">
              <p class="text-slate-500 text-sm font-medium">Weekly Rate (-<%= String.format("%.0f", (1 - v.weeklyRate() / (v.getDailyRate() * 7)) * 100) %>%)</p>
              <p class="text-xl font-bold text-ink-900">LKR <%= String.format("%,.0f", v.weeklyRate()) %></p>
            </div>
          </div>
          
          <button class="w-full bg-brand-600 hover:bg-brand-700 text-white font-bold text-lg py-4 rounded-xl shadow-btn transition-colors duration-200 flex items-center justify-center gap-2" <%= !v.isAvailable() ? "disabled" : "" %> style="<%= !v.isAvailable() ? "opacity: 0.5; cursor: not-allowed;" : "" %>">
            <% if (v.isAvailable()) { %>
              <i class="bi bi-calendar-check"></i> Book This <%= v.getType() %>
            <% } else { %>
              <i class="bi bi-x-circle"></i> Not Available
            <% } %>
          </button>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ include file="footer.jspf" %>
