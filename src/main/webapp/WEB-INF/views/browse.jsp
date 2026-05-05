<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.vrp.model.Vehicle" %>
<%
    request.setAttribute("nav", "browse");
    request.setAttribute("pageTitle", "Browse Fleet — DriveLanka");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    String kw    = (String) request.getAttribute("keyword");
    String typeF = (String) request.getAttribute("typeFilter");
    String minR  = (String) request.getAttribute("minRate");
    String maxR  = (String) request.getAttribute("maxRate");
    boolean availOnly = Boolean.TRUE.equals(request.getAttribute("availableOnly"));
    int total = vehicles == null ? 0 : vehicles.size();
%>
<%@ include file="header.jspf" %>

<!-- Page Header -->
<section class="bg-gradient-to-r from-brand-700 to-indigo-700 text-white">
  <div class="max-w-7xl mx-auto px-6 py-12">
    <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
      <div>
        <nav class="text-sm text-brand-200 mb-2 flex items-center gap-1">
          <a href="${pageContext.request.contextPath}/" class="hover:text-white">Home</a>
          <i class="bi bi-chevron-right text-xs"></i>
          <span class="text-white font-medium">Browse Fleet</span>
        </nav>
        <h1 class="text-4xl font-extrabold">Our Fleet</h1>
        <p class="text-brand-100 mt-1">Explore <strong><%= total %></strong> vehicle<%= total!=1?"s":"" %> available for rent across Sri Lanka.</p>
      </div>
      <!-- Quick type pills -->
      <div class="flex flex-wrap gap-2">
        <% String[] tpills={"","Car","Bike","Van"}; String[] tlabels={"All","Cars","Bikes","Vans"};
           for(int i=0;i<tpills.length;i++){
             boolean sel=(typeF==null&&tpills[i].isEmpty())||(typeF!=null&&typeF.equalsIgnoreCase(tpills[i]));
        %>
          <a href="${pageContext.request.contextPath}/vehicles?action=browse&type=<%= tpills[i] %>"
             class="px-4 py-1.5 rounded-full text-sm font-semibold border transition
             <%= sel?"bg-white text-brand-700 border-white":"bg-white/10 text-white border-white/30 hover:bg-white/20" %>">
            <%= tlabels[i] %>
          </a>
        <% } %>
      </div>
    </div>
  </div>
</section>

<div class="max-w-7xl mx-auto px-4 sm:px-6 py-8 grid lg:grid-cols-[260px_1fr] gap-8">

  <!-- FILTER SIDEBAR -->
  <aside class="h-fit lg:sticky lg:top-20">
    <form id="filterForm" action="${pageContext.request.contextPath}/vehicles" method="get" class="bg-white rounded-2xl shadow-card border border-slate-100 p-6 space-y-6">
      <input type="hidden" name="action" value="browse">
      <h3 class="font-bold text-base text-ink-900 flex items-center gap-2"><i class="bi bi-funnel text-brand-600"></i> Filters</h3>

      <div>
        <label class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-1.5 block">Search</label>
        <div class="relative">
          <i class="bi bi-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
          <input id="liveSearch" name="keyword" value="<%= kw==null?"":kw %>" placeholder="Brand, model, location..."
                 class="pl-9 w-full px-3 py-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-brand-500 outline-none text-sm">
        </div>
      </div>

      <div>
        <label class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-1.5 block">Vehicle Type</label>
        <div class="grid grid-cols-2 gap-2 text-sm">
          <% String[] types={"","Car","Bike","Van"}; String[] labels={"All","Car","Bike","Van"};
             for(int i=0;i<types.length;i++){
               boolean s=(typeF==null&&types[i].isEmpty())||(typeF!=null&&typeF.equalsIgnoreCase(types[i]));
          %>
            <label class="cursor-pointer">
              <input type="radio" name="type" value="<%= types[i] %>" class="hidden peer" <%= s?"checked":"" %>>
              <div class="text-center px-2 py-2 rounded-lg border border-slate-200 peer-checked:bg-brand-600 peer-checked:text-white peer-checked:border-brand-600 hover:border-brand-400 transition text-slate-600 font-medium">
                <%= labels[i] %>
              </div>
            </label>
          <% } %>
        </div>
      </div>

      <div>
        <label class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-1.5 block">Daily Rate (LKR)</label>
        <div class="grid grid-cols-2 gap-2">
          <input name="minRate" value="<%= minR==null?"":minR %>" placeholder="Min" type="number"
                 class="px-3 py-2 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          <input name="maxRate" value="<%= maxR==null?"":maxR %>" placeholder="Max" type="number"
                 class="px-3 py-2 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
        </div>
      </div>

      <label class="flex items-center gap-2.5 cursor-pointer select-none">
        <input type="checkbox" name="availableOnly" value="1" <%= availOnly?"checked":"" %> class="w-4 h-4 rounded accent-brand-600">
        <span class="text-sm text-slate-700 font-medium">Available vehicles only</span>
      </label>

      <div class="space-y-2">
        <button type="submit" class="w-full bg-brand-600 hover:bg-brand-700 text-white font-bold py-2.5 rounded-xl flex items-center justify-center gap-2 transition shadow-btn">
          <i class="bi bi-funnel-fill"></i> Apply Filters
        </button>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="block text-center text-sm text-slate-400 hover:text-brand-600 transition py-1">
          <i class="bi bi-x"></i> Clear all filters
        </a>
      </div>
    </form>
  </aside>

  <!-- RESULTS -->
  <section>
    <!-- Toolbar: count + sort -->
    <div class="flex flex-wrap items-center justify-between gap-3 mb-5">
      <p class="text-slate-500 text-sm">
        Showing <span class="font-bold text-ink-900" id="visibleCount"><%= total %></span> vehicle<%= total!=1?"s":"" %>
        <% if(kw!=null&&!kw.isEmpty()){%> for "<%= kw %>"<%}%>
      </p>
      <div class="flex items-center gap-2">
        <label class="text-sm text-slate-500 font-medium">Sort by:</label>
        <select id="sortSelect" class="text-sm border border-slate-200 rounded-lg px-3 py-1.5 outline-none focus:ring-2 focus:ring-brand-500 bg-white">
          <option value="default">Default</option>
          <option value="price-asc">Price: Low to High</option>
          <option value="price-desc">Price: High to Low</option>
          <option value="name-asc">Name: A–Z</option>
          <option value="avail">Available First</option>
        </select>
      </div>
    </div>

    <% if (vehicles == null || vehicles.isEmpty()) { %>
      <div class="bg-white rounded-2xl shadow-card p-12 text-center border border-slate-100">
        <div class="w-20 h-20 rounded-full bg-slate-50 flex items-center justify-center mx-auto mb-4">
          <i class="bi bi-search text-4xl text-slate-300"></i>
        </div>
        <h3 class="font-bold text-xl text-ink-900">No vehicles found</h3>
        <p class="text-slate-500 mt-2 mb-6">Try adjusting your filters or search terms.</p>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="inline-flex items-center gap-2 bg-brand-600 text-white font-bold px-6 py-2.5 rounded-xl shadow-btn">
          <i class="bi bi-arrow-counterclockwise"></i> Reset Filters
        </a>
      </div>
    <% } else { %>
      <div id="vehicleGrid" class="grid sm:grid-cols-2 xl:grid-cols-3 gap-5">
        <% for (Vehicle v : vehicles) { %>
          <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= v.getId() %>"
             class="group vehicle-card bg-white rounded-2xl shadow-card border border-slate-100 overflow-hidden hover:-translate-y-1 hover:shadow-xl transition-all duration-300"
             data-name="<%= v.getBrand().toLowerCase() %> <%= v.getModel().toLowerCase() %>"
             data-price="<%= v.getDailyRate() %>"
             data-avail="<%= v.isAvailable() %>">
            <!-- Image -->
            <div class="aspect-[16/10] overflow-hidden bg-slate-100 relative">
              <img src="<%= v.getImageUrl() %>"
                   onerror="this.src='https://placehold.co/600x380/e0f2fe/0369a1?text=<%= v.getType() %>'"
                   class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                   alt="<%= v.getName() %>" loading="lazy">
              <span class="absolute top-3 left-3 bg-white/90 backdrop-blur text-xs font-bold uppercase text-brand-700 px-2.5 py-1 rounded-full shadow-sm">
                <i class="bi <%= v.getIconClass() %>"></i> <%= v.getType() %>
              </span>
              <% if (v.isAvailable()) { %>
                <span class="available-badge absolute top-3 right-3 bg-emerald-500 text-white text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">
                  <i class="bi bi-check-circle-fill mr-0.5"></i>Available
                </span>
              <% } else { %>
                <span class="absolute top-3 right-3 bg-slate-700/80 text-white text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">Rented</span>
              <% } %>
            </div>
            <!-- Body -->
            <div class="p-4">
              <h3 class="font-bold text-base leading-tight"><%= v.getName() %></h3>
              <p class="text-slate-400 text-xs mt-0.5"><%= v.getSpecLine() %></p>
              <div class="flex items-center justify-between mt-3 pt-3 border-t border-slate-100">
                <span class="text-xs text-slate-500 flex items-center gap-1"><i class="bi bi-geo-alt"></i><%= v.getLocation() %></span>
                <div class="text-right">
                  <span class="text-brand-700 font-extrabold">LKR <%= String.format("%,.0f", v.getDailyRate()) %></span>
                  <span class="text-slate-400 text-xs">/day</span>
                </div>
              </div>
            </div>
          </a>
        <% } %>
      </div>

      <!-- Empty state for live filter -->
      <div id="noResults" class="hidden bg-white rounded-2xl shadow-card p-10 text-center border border-slate-100 mt-4">
        <i class="bi bi-emoji-frown text-4xl text-slate-300"></i>
        <p class="text-slate-500 font-medium mt-3">No vehicles match your search.</p>
      </div>
    <% } %>
  </section>
</div>

<script>
// ── Live search (client-side)
const liveSearch = document.getElementById('liveSearch');
const grid = document.getElementById('vehicleGrid');
const noRes = document.getElementById('noResults');
const countEl = document.getElementById('visibleCount');

function applyClientFilter() {
  if (!grid) return;
  const q = liveSearch.value.toLowerCase();
  const cards = grid.querySelectorAll('.vehicle-card');
  let visible = 0;
  cards.forEach(c => {
    const match = !q || c.dataset.name.includes(q);
    c.style.display = match ? '' : 'none';
    if (match) visible++;
  });
  if (countEl) countEl.textContent = visible;
  if (noRes) noRes.classList.toggle('hidden', visible > 0);
}

if (liveSearch) {
  liveSearch.addEventListener('input', function() {
    if (this.value.length === 0 || this.value.length >= 2) applyClientFilter();
  });
}

// ── Sort
const sortSelect = document.getElementById('sortSelect');
if (sortSelect && grid) {
  sortSelect.addEventListener('change', function() {
    const cards = [...grid.querySelectorAll('.vehicle-card')];
    cards.sort((a, b) => {
      switch (this.value) {
        case 'price-asc':  return parseFloat(a.dataset.price) - parseFloat(b.dataset.price);
        case 'price-desc': return parseFloat(b.dataset.price) - parseFloat(a.dataset.price);
        case 'name-asc':   return a.dataset.name.localeCompare(b.dataset.name);
        case 'avail':      return (b.dataset.avail === 'true' ? 1 : 0) - (a.dataset.avail === 'true' ? 1 : 0);
        default: return 0;
      }
    });
    cards.forEach(c => grid.appendChild(c));
  });
}
</script>

<%@ include file="footer.jspf" %>
