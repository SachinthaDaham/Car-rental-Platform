<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.vrp.model.Vehicle, com.vrp.model.User" %>
<%
    request.setAttribute("nav", "browse");
    request.setAttribute("pageTitle", "Browse Fleet — DriveLanka");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    User browseUser = (User) session.getAttribute("loggedInUser");
    String kw     = (String) request.getAttribute("keyword");
    String typeF  = (String) request.getAttribute("typeFilter");
    String minR   = (String) request.getAttribute("minRate");
    String maxR   = (String) request.getAttribute("maxRate");
    boolean availOnly = Boolean.TRUE.equals(request.getAttribute("availableOnly"));
    int total = vehicles == null ? 0 : vehicles.size();
%>
<%@ include file="header.jspf" %>

<style>
@keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
.vehicle-card { animation: fadeUp .4s ease both; }
.vehicle-card:nth-child(1){animation-delay:.05s}.vehicle-card:nth-child(2){animation-delay:.10s}
.vehicle-card:nth-child(3){animation-delay:.15s}.vehicle-card:nth-child(4){animation-delay:.20s}
.vehicle-card:nth-child(5){animation-delay:.25s}.vehicle-card:nth-child(6){animation-delay:.30s}
.card-img-wrap img { transition: transform .5s ease; }
.vehicle-card:hover .card-img-wrap img { transform: scale(1.08); }
.quick-book { opacity:0; transform:translateY(8px); transition: opacity .2s, transform .2s; }
.vehicle-card:hover .quick-book { opacity:1; transform:translateY(0); }
</style>

<!-- Hero banner -->
<section class="relative bg-gradient-to-br from-brand-800 via-brand-700 to-indigo-800 text-white overflow-hidden">
  <div class="absolute inset-0 opacity-10" style="background-image:url('data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><circle cx=%2250%22 cy=%2250%22 r=%2240%22 fill=%22none%22 stroke=%22white%22 stroke-width=%220.5%22/></svg>'); background-size:80px;"></div>
  <div class="relative max-w-7xl mx-auto px-4 sm:px-6 py-12">
    <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-6">
      <div>
        <nav class="text-sm text-brand-200 mb-2 flex items-center gap-1">
          <a href="${pageContext.request.contextPath}/" class="hover:text-white transition">Home</a>
          <i class="bi bi-chevron-right text-xs opacity-50"></i>
          <span class="text-white font-medium">Browse Fleet</span>
        </nav>
        <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight">Our Fleet</h1>
        <p class="text-brand-100 mt-2 text-lg">
          <span class="font-bold text-white"><%= total %></span> vehicle<%= total!=1?"s":"" %> ready across Sri Lanka
        </p>
      </div>
      <!-- Type pills -->
      <div class="flex flex-wrap gap-2">
        <% String[] tpills={"","Car","Bike","Van"}; String[] tlabels={"All Types","Cars","Bikes","Vans"}; String[] ticons={"bi-grid3x3-gap","bi-car-front","bi-bicycle","bi-truck"};
           for(int i=0;i<tpills.length;i++){
             boolean sel=(typeF==null&&tpills[i].isEmpty())||(typeF!=null&&typeF.equalsIgnoreCase(tpills[i]));
        %>
          <a href="${pageContext.request.contextPath}/vehicles?action=browse&type=<%= tpills[i] %>"
             class="inline-flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-semibold border transition
             <%= sel?"bg-white text-brand-700 border-white shadow-md":"bg-white/10 text-white border-white/25 hover:bg-white/20" %>">
            <i class="bi <%= ticons[i] %> text-xs"></i> <%= tlabels[i] %>
          </a>
        <% } %>
      </div>
    </div>
  </div>
</section>

<div class="max-w-7xl mx-auto px-4 sm:px-6 py-8 grid lg:grid-cols-[280px_1fr] gap-8">

  <!-- ── FILTER SIDEBAR ─────────────────────────────────────────────────── -->
  <aside class="h-fit lg:sticky lg:top-20">
    <form id="filterForm" action="${pageContext.request.contextPath}/vehicles" method="get"
          class="bg-white rounded-2xl shadow-card border border-slate-100 overflow-hidden">
      <input type="hidden" name="action" value="browse">

      <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
        <h3 class="font-bold text-sm text-ink-900 flex items-center gap-2"><i class="bi bi-funnel-fill text-brand-600"></i> Refine Results</h3>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="text-xs text-slate-400 hover:text-rose-500 transition">
          <i class="bi bi-x-circle"></i> Clear
        </a>
      </div>

      <div class="p-5 space-y-5">

        <!-- Keyword search -->
        <div>
          <label class="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2 block">Search</label>
          <div class="relative">
            <i class="bi bi-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
            <input id="liveSearch" name="keyword" value="<%= kw==null?"":kw %>"
                   placeholder="Brand, model, location…"
                   class="pl-9 w-full px-3 py-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-brand-500 outline-none text-sm bg-white">
          </div>
        </div>

        <!-- Vehicle type -->
        <div>
          <label class="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2 block">Vehicle Type</label>
          <div class="grid grid-cols-2 gap-2">
            <% String[] types={"","Car","Bike","Van"}; String[] labels={"All","Cars","Bikes","Vans"}; String[] tIco={"bi-grid","bi-car-front","bi-bicycle","bi-truck"};
               for(int i=0;i<types.length;i++){
                 boolean s=(typeF==null&&types[i].isEmpty())||(typeF!=null&&typeF.equalsIgnoreCase(types[i]));
            %>
              <label class="cursor-pointer">
                <input type="radio" name="type" value="<%= types[i] %>" class="hidden peer" <%= s?"checked":"" %>>
                <div class="text-center px-2 py-2.5 rounded-xl border border-slate-200 peer-checked:bg-brand-600 peer-checked:text-white peer-checked:border-brand-600 hover:border-brand-300 transition text-slate-600 font-semibold text-xs flex flex-col items-center gap-1">
                  <i class="bi <%= tIco[i] %> text-sm"></i>
                  <%= labels[i] %>
                </div>
              </label>
            <% } %>
          </div>
        </div>

        <!-- Price range -->
        <div>
          <label class="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2 block">Daily Rate (LKR)</label>
          <div class="grid grid-cols-2 gap-2">
            <input name="minRate" value="<%= minR==null?"":minR %>" placeholder="Min" type="number" min="0"
                   class="px-3 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
            <input name="maxRate" value="<%= maxR==null?"":maxR %>" placeholder="Max" type="number" min="0"
                   class="px-3 py-2 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
          <!-- Quick rate presets -->
          <div class="flex gap-1.5 mt-2 flex-wrap">
            <% int[][] presets={{0,5000},{5000,15000},{15000,30000},{30000,0}};
               String[] pLabels={"<5k","5-15k","15-30k","30k+"};
               for(int i=0;i<presets.length;i++){
            %>
              <button type="button" onclick="setRate(<%= presets[i][0] %>,<%= presets[i][1] %>)"
                      class="text-[10px] font-semibold px-2 py-1 border border-slate-200 rounded-lg hover:border-brand-400 hover:text-brand-700 transition text-slate-500">
                <%= pLabels[i] %>
              </button>
            <% } %>
          </div>
        </div>

        <!-- Availability -->
        <label class="flex items-center gap-3 cursor-pointer select-none group">
          <div class="relative">
            <input type="checkbox" name="availableOnly" value="1" id="availCheck" <%= availOnly?"checked":"" %>
                   class="w-5 h-5 rounded accent-brand-600 cursor-pointer">
          </div>
          <div>
            <p class="text-sm text-slate-700 font-semibold group-hover:text-brand-600 transition">Available Only</p>
            <p class="text-[10px] text-slate-400">Hide currently rented vehicles</p>
          </div>
        </label>

        <button type="submit"
                class="w-full bg-gradient-to-r from-brand-600 to-brand-700 hover:from-brand-700 hover:to-brand-800 text-white font-bold py-3 rounded-xl flex items-center justify-center gap-2 transition shadow-btn">
          <i class="bi bi-funnel-fill"></i> Apply Filters
        </button>
      </div>
    </form>
  </aside>

  <!-- ── RESULTS ─────────────────────────────────────────────────────────── -->
  <section>

    <!-- Toolbar -->
    <div class="flex flex-wrap items-center justify-between gap-3 mb-5">
      <div>
        <p class="text-slate-600 text-sm font-medium">
          Showing <span id="visibleCount" class="font-extrabold text-ink-900"><%= total %></span> vehicle<%= total!=1?"s":"" %>
          <% if(kw!=null&&!kw.isEmpty()){%> for "<strong><%= kw %></strong>"<%}%>
        </p>
        <% if(availOnly){ %><p class="text-xs text-emerald-600 font-semibold mt-0.5"><i class="bi bi-check-circle-fill"></i> Available vehicles only</p><% } %>
      </div>
      <div class="flex items-center gap-2">
        <label class="text-sm text-slate-500 font-medium">Sort:</label>
        <select id="sortSelect" class="text-sm border border-slate-200 rounded-xl px-3 py-2 outline-none focus:ring-2 focus:ring-brand-500 bg-white font-medium">
          <option value="default">Default</option>
          <option value="price-asc">Price: Low → High</option>
          <option value="price-desc">Price: High → Low</option>
          <option value="name-asc">Name: A–Z</option>
          <option value="avail">Available First</option>
        </select>
        <div class="hidden sm:flex border border-slate-200 rounded-xl overflow-hidden">
          <button id="viewGrid" class="w-9 h-9 flex items-center justify-center bg-brand-600 text-white" title="Grid">
            <i class="bi bi-grid-3x3-gap-fill text-sm"></i>
          </button>
          <button id="viewList" class="w-9 h-9 flex items-center justify-center bg-white text-slate-500 hover:bg-slate-50" title="List">
            <i class="bi bi-list-ul text-sm"></i>
          </button>
        </div>
      </div>
    </div>

    <% if (vehicles == null || vehicles.isEmpty()) { %>
      <div class="bg-white rounded-3xl shadow-card p-16 text-center border border-slate-100">
        <div class="w-24 h-24 rounded-full bg-slate-50 flex items-center justify-center mx-auto mb-5">
          <i class="bi bi-search text-5xl text-slate-200"></i>
        </div>
        <h3 class="font-extrabold text-2xl text-ink-900">No vehicles found</h3>
        <p class="text-slate-500 mt-2 mb-6">Try broadening your search or removing some filters.</p>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse"
           class="inline-flex items-center gap-2 bg-brand-600 hover:bg-brand-700 text-white font-bold px-7 py-3 rounded-xl shadow-btn transition">
          <i class="bi bi-arrow-counterclockwise"></i> Show All Vehicles
        </a>
      </div>
    <% } else { %>

      <div id="vehicleGrid" class="grid sm:grid-cols-2 xl:grid-cols-3 gap-5">
        <% for (Vehicle v : vehicles) { %>
          <div class="vehicle-card group bg-white rounded-2xl shadow-card border border-slate-100 overflow-hidden hover:-translate-y-1 hover:shadow-xl transition-all duration-300 flex flex-col"
               data-name="<%= v.getBrand().toLowerCase() %> <%= v.getModel().toLowerCase() %> <%= v.getLocation().toLowerCase() %>"
               data-price="<%= v.getDailyRate() %>"
               data-avail="<%= v.isAvailable() %>">

            <!-- Image -->
            <div class="card-img-wrap aspect-[16/10] overflow-hidden bg-slate-100 relative shrink-0">
              <img src="<%= v.getImageUrl() %>"
                   onerror="this.src='https://placehold.co/600x380/e0f2fe/0369a1?text=<%= v.getType() %>'"
                   class="w-full h-full object-cover"
                   alt="<%= v.getName() %>" loading="lazy">
              <!-- Overlay on hover -->
              <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <!-- Quick book button -->
              <div class="quick-book absolute bottom-4 left-0 right-0 flex justify-center">
                <% if (v.isAvailable()) { %>
                  <% if (browseUser != null) { %>
                    <a href="${pageContext.request.contextPath}/booking?action=form&id=<%= v.getId() %>"
                       class="inline-flex items-center gap-1.5 bg-white text-brand-700 font-bold text-xs px-5 py-2.5 rounded-xl shadow-lg hover:bg-brand-600 hover:text-white transition"
                       onclick="event.stopPropagation()">
                      <i class="bi bi-calendar-check-fill"></i> Book Now
                    </a>
                  <% } else { %>
                    <a href="${pageContext.request.contextPath}/auth?action=login"
                       class="inline-flex items-center gap-1.5 bg-white text-brand-700 font-bold text-xs px-5 py-2.5 rounded-xl shadow-lg hover:bg-brand-600 hover:text-white transition"
                       onclick="event.stopPropagation()">
                      <i class="bi bi-box-arrow-in-right"></i> Sign In to Book
                    </a>
                  <% } %>
                <% } else { %>
                  <span class="inline-flex items-center gap-1.5 bg-black/50 text-white text-xs px-5 py-2.5 rounded-xl font-semibold backdrop-blur">
                    <i class="bi bi-x-circle"></i> Currently Rented
                  </span>
                <% } %>
              </div>
              <!-- Badges -->
              <span class="absolute top-3 left-3 bg-white/90 backdrop-blur text-xs font-bold uppercase text-brand-700 px-2.5 py-1 rounded-full shadow-sm">
                <i class="bi <%= v.getIconClass() %>"></i> <%= v.getType() %>
              </span>
              <% if (v.isAvailable()) { %>
                <span class="available-badge absolute top-3 right-3 bg-emerald-500 text-white text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">
                  <i class="bi bi-check-circle-fill mr-0.5"></i>Available
                </span>
              <% } else { %>
                <span class="absolute top-3 right-3 bg-slate-800/70 backdrop-blur text-white text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">
                  <i class="bi bi-clock-fill mr-0.5"></i>Rented
                </span>
              <% } %>
            </div>

            <!-- Card body -->
            <div class="p-4 flex flex-col flex-1">
              <div class="flex-1">
                <h3 class="font-extrabold text-base text-ink-900 leading-tight group-hover:text-brand-700 transition"><%= v.getName() %></h3>
                <p class="text-slate-400 text-xs mt-0.5 flex items-center gap-1">
                  <i class="bi bi-gear"></i> <%= v.getSpecLine() %>
                </p>
                <p class="text-slate-400 text-xs mt-1 flex items-center gap-1">
                  <i class="bi bi-geo-alt"></i> <%= v.getLocation() %>
                  <span class="text-slate-200 mx-1">·</span>
                  <i class="bi bi-calendar3"></i> <%= v.getYear() %>
                </p>
              </div>

              <!-- Price + CTA -->
              <div class="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between">
                <div>
                  <div class="flex items-baseline gap-1">
                    <span class="text-brand-700 font-extrabold text-lg">LKR <%= String.format("%,.0f", v.getDailyRate()) %></span>
                    <span class="text-slate-400 text-xs font-medium">/day</span>
                  </div>
                  <p class="text-[10px] text-emerald-600 font-semibold">LKR <%= String.format("%,.0f", v.weeklyRate()) %>/week</p>
                </div>
                <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= v.getId() %>"
                   class="inline-flex items-center gap-1.5 text-xs font-bold text-brand-600 hover:text-white border border-brand-200 hover:bg-brand-600 hover:border-brand-600 px-3.5 py-2 rounded-xl transition">
                  View Details <i class="bi bi-arrow-right text-[10px]"></i>
                </a>
              </div>
            </div>
          </div>
        <% } %>
      </div>

      <!-- Empty state (live filter) -->
      <div id="noResults" class="hidden bg-white rounded-2xl shadow-card p-12 text-center border border-slate-100 mt-4">
        <i class="bi bi-emoji-frown text-5xl text-slate-200 block mb-3"></i>
        <p class="text-slate-600 font-semibold">No vehicles match your search.</p>
        <p class="text-xs text-slate-400 mt-1">Try a different keyword.</p>
      </div>
    <% } %>
  </section>
</div>

<script>
(function() {
  var grid    = document.getElementById('vehicleGrid');
  var noRes   = document.getElementById('noResults');
  var countEl = document.getElementById('visibleCount');
  var search  = document.getElementById('liveSearch');

  // ── Live client-side search
  function applyFilter() {
    if (!grid) return;
    var q = search ? search.value.toLowerCase() : '';
    var cards = grid.querySelectorAll('.vehicle-card');
    var vis = 0;
    cards.forEach(function(c) {
      var match = !q || c.dataset.name.includes(q);
      c.style.display = match ? '' : 'none';
      if (match) vis++;
    });
    if (countEl) countEl.textContent = vis;
    if (noRes) noRes.classList.toggle('hidden', vis > 0);
  }
  if (search) search.addEventListener('input', function() {
    if (this.value.length === 0 || this.value.length >= 2) applyFilter();
  });

  // ── Sort
  var sortSel = document.getElementById('sortSelect');
  if (sortSel && grid) {
    sortSel.addEventListener('change', function() {
      var v = this.value;
      var cards = Array.from(grid.querySelectorAll('.vehicle-card'));
      cards.sort(function(a, b) {
        if (v === 'price-asc')  return parseFloat(a.dataset.price) - parseFloat(b.dataset.price);
        if (v === 'price-desc') return parseFloat(b.dataset.price) - parseFloat(a.dataset.price);
        if (v === 'name-asc')   return a.dataset.name.localeCompare(b.dataset.name);
        if (v === 'avail')      return (b.dataset.avail==='true'?1:0) - (a.dataset.avail==='true'?1:0);
        return 0;
      });
      cards.forEach(function(c) { grid.appendChild(c); });
    });
  }

  // ── Grid / List view
  var btnGrid = document.getElementById('viewGrid');
  var btnList = document.getElementById('viewList');
  function setView(mode) {
    if (!grid) return;
    var cards = grid.querySelectorAll('.vehicle-card');
    if (mode === 'list') {
      grid.className = 'flex flex-col gap-4';
      cards.forEach(function(c) {
        c.classList.remove('hover:-translate-y-1');
        c.classList.add('flex-row');
        var img = c.querySelector('.card-img-wrap');
        if (img) { img.style.width='140px'; img.style.flexShrink='0'; img.classList.remove('aspect-[16/10]'); img.style.aspectRatio=''; img.style.height='120px'; }
      });
      btnList.classList.replace('text-slate-500','text-white'); btnList.classList.replace('bg-white','bg-brand-600');
      btnGrid.classList.replace('bg-brand-600','bg-white');     btnGrid.classList.replace('text-white','text-slate-500');
    } else {
      grid.className = 'grid sm:grid-cols-2 xl:grid-cols-3 gap-5';
      cards.forEach(function(c) {
        c.classList.remove('flex-row'); c.classList.add('hover:-translate-y-1');
        var img = c.querySelector('.card-img-wrap');
        if (img) { img.style.width=''; img.style.height=''; img.style.flexShrink=''; img.classList.add('aspect-[16/10]'); }
      });
      btnGrid.classList.replace('bg-white','bg-brand-600');     btnGrid.classList.replace('text-slate-500','text-white');
      btnList.classList.replace('bg-brand-600','bg-white');     btnList.classList.replace('text-white','text-slate-500');
    }
  }
  if (btnGrid) btnGrid.addEventListener('click', function(){ setView('grid'); });
  if (btnList) btnList.addEventListener('click', function(){ setView('list'); });

  // ── Rate presets
  window.setRate = function(min, max) {
    var minEl = document.querySelector('input[name=minRate]');
    var maxEl = document.querySelector('input[name=maxRate]');
    if (minEl) minEl.value = min || '';
    if (maxEl) maxEl.value = max || '';
  };
})();
</script>

<%@ include file="footer.jspf" %>
