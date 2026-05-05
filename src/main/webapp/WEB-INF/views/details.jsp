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

<div class="max-w-7xl mx-auto px-4 sm:px-6 py-6">

  <!-- Breadcrumbs -->
  <nav class="text-sm text-slate-500 mb-6 flex items-center gap-1 flex-wrap">
    <a href="${pageContext.request.contextPath}/" class="hover:text-brand-600 transition">Home</a>
    <i class="bi bi-chevron-right text-xs text-slate-300"></i>
    <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="hover:text-brand-600 transition">Browse Fleet</a>
    <i class="bi bi-chevron-right text-xs text-slate-300"></i>
    <span class="text-ink-900 font-medium"><%= v.getName() %></span>
  </nav>

  <div class="bg-white rounded-3xl shadow-card border border-slate-100 overflow-hidden">
    <div class="grid lg:grid-cols-2">

      <!-- LEFT: Image -->
      <div class="bg-slate-100 relative min-h-[360px] lg:min-h-[500px]">
        <img src="<%= v.getImageUrl() %>"
             onerror="this.src='https://placehold.co/800x600/e0f2fe/0369a1?text=<%= v.getType() %>'"
             class="absolute inset-0 w-full h-full object-cover"
             alt="<%= v.getName() %>">
        <div class="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent"></div>
        <!-- Badges -->
        <span class="absolute top-5 left-5 bg-white/95 backdrop-blur text-sm font-bold uppercase text-brand-700 px-3 py-1.5 rounded-full shadow-sm">
          <i class="bi <%= v.getIconClass() %> mr-1"></i><%= v.getType() %>
        </span>
        <% if (v.isAvailable()) { %>
          <span class="absolute top-5 right-5 bg-emerald-500 text-white text-xs font-bold uppercase px-3 py-1.5 rounded-full shadow-sm available-badge">
            <i class="bi bi-check-circle-fill mr-1"></i>Available Now
          </span>
        <% } else { %>
          <span class="absolute top-5 right-5 bg-slate-800/80 text-white text-xs font-bold uppercase px-3 py-1.5 rounded-full shadow-sm">
            <i class="bi bi-x-circle-fill mr-1"></i>Currently Rented
          </span>
        <% } %>
        <!-- ID chip at bottom -->
        <span class="absolute bottom-5 left-5 bg-black/40 backdrop-blur text-white text-xs font-mono px-3 py-1.5 rounded-full">
          ID: <%= v.getId() %>
        </span>
      </div>

      <!-- RIGHT: Info -->
      <div class="p-6 sm:p-10 flex flex-col">

        <div class="flex items-center gap-2 text-sm text-slate-500 mb-2">
          <i class="bi bi-geo-alt-fill text-brand-500"></i>
          <span><%= v.getLocation() %></span>
          <span class="text-slate-300">•</span>
          <span class="font-mono text-xs text-slate-400"><%= v.getId() %></span>
        </div>
        <h1 class="text-3xl sm:text-4xl font-extrabold text-ink-900 leading-tight"><%= v.getName() %></h1>
        <p class="text-slate-500 mt-3 mb-6 text-base leading-relaxed border-b border-slate-100 pb-6">
          <%= v.getDescription() %>
        </p>

        <!-- Spec grid -->
        <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-4">Specifications</h4>
        <div class="grid grid-cols-2 sm:grid-cols-3 gap-4 mb-8">
          <%
            String[][] specs = {
              {"bi-calendar3","Year",String.valueOf(v.getYear())},
              {"bi-gear","Key Specs",v.getSpecLine()},
              {"bi-tag","Vehicle ID",v.getId()},
              {"bi-car-front","Brand",v.getBrand()},
              {"bi-list-check","Model",v.getModel()},
              {"bi-clock","Type",v.getType()}
            };
            for(String[] s:specs){
          %>
            <div class="bg-slate-50 rounded-xl p-3 border border-slate-100">
              <p class="text-[10px] uppercase tracking-wider text-slate-400 mb-1 flex items-center gap-1">
                <i class="bi <%= s[0] %>"></i> <%= s[1] %>
              </p>
              <p class="font-bold text-sm text-ink-900"><%= s[2] %></p>
            </div>
          <% } %>
        </div>

        <!-- Pricing box -->
        <div class="mt-auto bg-gradient-to-br from-slate-50 to-brand-50 rounded-2xl p-5 border border-brand-100">
          <div class="flex items-center justify-between mb-5">
            <div>
              <p class="text-xs uppercase tracking-wider text-slate-400 font-semibold">Daily Rate</p>
              <p class="text-3xl font-extrabold text-brand-700">LKR <%= String.format("%,.0f", v.getDailyRate()) %></p>
            </div>
            <div class="text-right">
              <p class="text-xs uppercase tracking-wider text-slate-400 font-semibold">
                Weekly
                <span class="text-emerald-600 font-bold">
                  -<%= String.format("%.0f", (1 - v.weeklyRate() / (v.getDailyRate() * 7)) * 100) %>%
                </span>
              </p>
              <p class="text-xl font-bold text-ink-900">LKR <%= String.format("%,.0f", v.weeklyRate()) %></p>
            </div>
          </div>

          <% if (v.isAvailable()) { %>
            <% if (sessionUser != null) { %>
              <button onclick="window.showToast('Booking coming soon! Contact us to reserve.','info')"
                      class="w-full bg-brand-600 hover:bg-brand-700 text-white font-bold text-base py-3.5 rounded-xl shadow-btn transition flex items-center justify-center gap-2">
                <i class="bi bi-calendar-check-fill"></i> Book This <%= v.getType() %>
              </button>
            <% } else { %>
              <a href="${pageContext.request.contextPath}/auth?action=login"
                 class="w-full block text-center bg-brand-600 hover:bg-brand-700 text-white font-bold text-base py-3.5 rounded-xl shadow-btn transition">
                <i class="bi bi-box-arrow-in-right mr-2"></i>Sign In to Book
              </a>
              <p class="text-center text-xs text-slate-400 mt-2">
                <a href="${pageContext.request.contextPath}/auth?action=register" class="text-brand-600 hover:underline">Create an account</a> — it's free
              </p>
            <% } %>
          <% } else { %>
            <div class="w-full text-center bg-slate-200 text-slate-500 font-bold py-3.5 rounded-xl flex items-center justify-center gap-2 cursor-not-allowed">
              <i class="bi bi-x-circle"></i> Currently Unavailable
            </div>
            <p class="text-center text-xs text-slate-400 mt-2">Check back soon or <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="text-brand-600 hover:underline">browse other vehicles</a></p>
          <% } %>
        </div>

        <!-- Admin edit link -->
        <% if (sessionUser != null && sessionUser.isAdmin()) { %>
          <div class="mt-4 flex gap-2">
            <a href="${pageContext.request.contextPath}/vehicles?action=edit&id=<%= v.getId() %>" class="flex-1 text-center text-sm font-semibold text-slate-500 hover:text-brand-600 border border-slate-200 hover:border-brand-300 py-2 rounded-xl transition">
              <i class="bi bi-pencil"></i> Edit Vehicle
            </a>
            <a href="${pageContext.request.contextPath}/vehicles?action=toggle&id=<%= v.getId() %>" class="flex-1 text-center text-sm font-semibold text-slate-500 hover:text-amber-600 border border-slate-200 hover:border-amber-300 py-2 rounded-xl transition">
              <i class="bi bi-arrow-repeat"></i> Toggle Status
            </a>
          </div>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Similar Vehicles -->
  <div class="mt-12">
    <h2 class="text-2xl font-extrabold text-ink-900 mb-2">More <%= v.getType() %>s</h2>
    <p class="text-slate-500 mb-6">Other vehicles of the same type you might like.</p>
    <div class="text-center">
      <a href="${pageContext.request.contextPath}/vehicles?action=browse&type=<%= v.getType() %>"
         class="inline-flex items-center gap-2 bg-white hover:bg-brand-50 border border-brand-200 text-brand-700 font-bold px-8 py-3 rounded-xl shadow-sm transition">
        <i class="bi bi-grid-3x3-gap"></i> Browse All <%= v.getType() %>s
      </a>
    </div>
  </div>
</div>

<%@ include file="footer.jspf" %>
