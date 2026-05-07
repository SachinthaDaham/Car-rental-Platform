<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.vrp.model.Vehicle" %>
<%
    request.setAttribute("nav", "list");
    request.setAttribute("pageTitle", "Manage Fleet — DriveLanka Admin");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    String msg = request.getParameter("msg");
    int total = vehicles == null ? 0 : vehicles.size();
    long avail = vehicles == null ? 0 : vehicles.stream().filter(Vehicle::isAvailable).count();
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 py-8">

    <!-- Header row -->
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-3xl font-extrabold text-ink-900">Manage Fleet</h1>
        <p class="text-slate-500 mt-1">
          <span class="font-semibold text-ink-900"><%= total %></span> vehicle<%= total != 1 ? "s" : "" %> ·
          <span class="text-emerald-600 font-semibold"><%= avail %> available</span> ·
          <span class="text-rose-500 font-semibold"><%= total - avail %> blocked</span>
        </p>
      </div>
      <a href="${pageContext.request.contextPath}/vehicles?action=add"
         class="inline-flex items-center gap-2 bg-brand-600 hover:bg-brand-700 text-white font-bold py-2.5 px-5 rounded-xl shadow-btn transition">
        <i class="bi bi-plus-lg"></i> Add Vehicle
      </a>
    </div>

    <!-- Flash messages -->
    <% if ("created".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-emerald-50 text-emerald-700 px-4 py-3 rounded-xl border border-emerald-200 font-medium text-sm">
        <i class="bi bi-check-circle-fill"></i> Vehicle successfully added to the fleet.
      </div>
    <% } else if ("updated".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-blue-50 text-blue-700 px-4 py-3 rounded-xl border border-blue-200 font-medium text-sm">
        <i class="bi bi-pencil-fill"></i> Vehicle information updated.
      </div>
    <% } else if ("deleted".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-slate-100 text-slate-700 px-4 py-3 rounded-xl border border-slate-200 font-medium text-sm">
        <i class="bi bi-trash3-fill"></i> Vehicle removed from fleet.
      </div>
    <% } else if ("toggled".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-brand-50 text-brand-700 px-4 py-3 rounded-xl border border-brand-200 font-medium text-sm">
        <i class="bi bi-arrow-repeat"></i> Availability status updated.
      </div>
    <% } %>

    <!-- Search + Filter bar -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 mb-4 flex flex-col sm:flex-row gap-3">
      <div class="relative flex-1">
        <i class="bi bi-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
        <input id="listSearch" type="text" placeholder="Search by name, ID, brand, or location…"
               class="w-full pl-9 pr-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
      </div>
      <div class="flex gap-2 flex-wrap">
        <button data-filter="all"  class="filter-btn active px-3 py-2 text-xs font-bold rounded-lg border border-brand-300 bg-brand-600 text-white transition">All</button>
        <button data-filter="Car"  class="filter-btn px-3 py-2 text-xs font-bold rounded-lg border border-slate-200 bg-white text-slate-600 hover:border-brand-300 transition">Cars</button>
        <button data-filter="Bike" class="filter-btn px-3 py-2 text-xs font-bold rounded-lg border border-slate-200 bg-white text-slate-600 hover:border-brand-300 transition">Bikes</button>
        <button data-filter="Van"  class="filter-btn px-3 py-2 text-xs font-bold rounded-lg border border-slate-200 bg-white text-slate-600 hover:border-brand-300 transition">Vans</button>
        <button data-filter="available" class="filter-btn px-3 py-2 text-xs font-bold rounded-lg border border-emerald-200 bg-white text-emerald-700 hover:bg-emerald-50 transition">Available</button>
        <button data-filter="rented" class="filter-btn px-3 py-2 text-xs font-bold rounded-lg border border-rose-200 bg-white text-rose-600 hover:bg-rose-50 transition">Blocked</button>
      </div>
    </div>

    <!-- Results count -->
    <p id="resultCount" class="text-xs text-slate-400 font-medium mb-3 px-1">
      Showing <span id="visibleCount"><%= total %></span> of <%= total %> vehicles
    </p>

    <!-- Table -->
    <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-slate-50 text-xs uppercase text-slate-500 tracking-wider">
              <th class="px-6 py-4 font-semibold">Vehicle</th>
              <th class="px-6 py-4 font-semibold">Type</th>
              <th class="px-6 py-4 font-semibold hidden md:table-cell">Location</th>
              <th class="px-6 py-4 font-semibold">Daily Rate</th>
              <th class="px-6 py-4 font-semibold text-center">Status</th>
              <th class="px-6 py-4 font-semibold text-right">Actions</th>
            </tr>
          </thead>
          <tbody id="vehicleTableBody" class="text-sm">
            <% if (vehicles == null || vehicles.isEmpty()) { %>
              <tr>
                <td colspan="6" class="px-6 py-14 text-center text-slate-400">
                  <i class="bi bi-inbox text-5xl mb-3 block opacity-40"></i>
                  <p class="text-base font-medium">No vehicles in the fleet yet.</p>
                  <a href="${pageContext.request.contextPath}/vehicles?action=add" class="mt-3 inline-block text-brand-600 hover:underline text-sm font-semibold">Add the first vehicle &rarr;</a>
                </td>
              </tr>
            <% } else { %>
              <% for (Vehicle v : vehicles) { %>
                <tr class="vehicle-row border-b border-slate-50 last:border-0 hover:bg-slate-50/70 transition-colors"
                    data-name="<%= v.getName().toLowerCase() %>"
                    data-id="<%= v.getId().toLowerCase() %>"
                    data-type="<%= v.getType() %>"
                    data-location="<%= v.getLocation() == null ? "" : v.getLocation().toLowerCase() %>"
                    data-available="<%= v.isAvailable() ? "available" : "rented" %>">
                  <td class="px-6 py-4">
                    <div class="flex items-center gap-4">
                      <img src="<%= v.getImageUrl() %>"
                           onerror="this.src='https://placehold.co/100x100/e0f2fe/0369a1'"
                           class="w-12 h-12 rounded-lg object-cover bg-slate-100 shrink-0">
                      <div>
                        <p class="font-bold text-ink-900"><%= v.getName() %></p>
                        <p class="text-xs font-mono text-slate-400"><%= v.getId() %></p>
                      </div>
                    </div>
                  </td>
                  <td class="px-6 py-4">
                    <span class="inline-flex items-center gap-1.5 bg-slate-100 text-slate-700 text-xs font-semibold px-2.5 py-1 rounded-lg">
                      <i class="bi <%= v.getIconClass() %>"></i> <%= v.getType() %>
                    </span>
                  </td>
                  <td class="px-6 py-4 text-slate-500 text-xs hidden md:table-cell">
                    <i class="bi bi-geo-alt text-slate-300 mr-1"></i><%= v.getLocation() %>
                  </td>
                  <td class="px-6 py-4 font-semibold text-slate-700">
                    LKR <%= String.format("%,.0f", v.getDailyRate()) %>
                    <span class="block text-xs font-normal text-slate-400">/ day</span>
                  </td>
                  <td class="px-6 py-4 text-center">
                    <% if (v.isAvailable()) { %>
                      <a href="${pageContext.request.contextPath}/vehicles?action=toggle&id=<%= v.getId() %>"
                         title="Click to block this vehicle"
                         class="inline-block bg-emerald-100 hover:bg-emerald-200 text-emerald-700 text-xs font-bold uppercase px-3 py-1.5 rounded-full transition">
                        <i class="bi bi-check-circle-fill mr-1"></i>Available
                      </a>
                    <% } else { %>
                      <a href="${pageContext.request.contextPath}/vehicles?action=toggle&id=<%= v.getId() %>"
                         title="Click to make available"
                         class="inline-block bg-rose-100 hover:bg-rose-200 text-rose-700 text-xs font-bold uppercase px-3 py-1.5 rounded-full transition">
                        <i class="bi bi-slash-circle-fill mr-1"></i>Blocked
                      </a>
                    <% } %>
                  </td>
                  <td class="px-6 py-4 text-right">
                    <div class="flex items-center justify-end gap-1.5">
                      <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= v.getId() %>"
                         class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-slate-100 hover:bg-brand-100 text-slate-500 hover:text-brand-700 transition" title="View Details">
                        <i class="bi bi-eye"></i>
                      </a>
                      <a href="${pageContext.request.contextPath}/vehicles?action=edit&id=<%= v.getId() %>"
                         class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-slate-100 hover:bg-blue-100 text-slate-500 hover:text-blue-700 transition" title="Edit">
                        <i class="bi bi-pencil-square"></i>
                      </a>
                      <a href="${pageContext.request.contextPath}/vehicles?action=delete&id=<%= v.getId() %>"
                         onclick="return confirm('Permanently delete <%= v.getName() %>?');"
                         class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-slate-100 hover:bg-rose-100 text-slate-500 hover:text-rose-700 transition" title="Delete">
                        <i class="bi bi-trash3"></i>
                      </a>
                    </div>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>

        <!-- No results (JS-controlled) -->
        <div id="noResults" class="hidden py-14 text-center text-slate-400">
          <i class="bi bi-search text-4xl mb-3 block opacity-30"></i>
          <p class="font-medium">No vehicles match your search.</p>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
  var searchInput  = document.getElementById('listSearch');
  var rows         = document.querySelectorAll('.vehicle-row');
  var noResults    = document.getElementById('noResults');
  var countEl      = document.getElementById('visibleCount');
  var filterBtns   = document.querySelectorAll('.filter-btn');
  var activeFilter = 'all';

  function applyFilters() {
    var query = searchInput.value.toLowerCase().trim();
    var visible = 0;
    rows.forEach(function(row) {
      var matchSearch = !query
        || row.dataset.name.includes(query)
        || row.dataset.id.includes(query)
        || row.dataset.location.includes(query);

      var matchFilter = activeFilter === 'all'
        || row.dataset.type === activeFilter
        || row.dataset.available === activeFilter;

      var show = matchSearch && matchFilter;
      row.classList.toggle('hidden', !show);
      if (show) visible++;
    });
    countEl.textContent = visible;
    noResults.classList.toggle('hidden', visible > 0);
  }

  searchInput.addEventListener('input', applyFilters);

  filterBtns.forEach(function(btn) {
    btn.addEventListener('click', function() {
      filterBtns.forEach(function(b) {
        b.classList.remove('active', 'bg-brand-600', 'text-white', 'border-brand-300');
        b.classList.add('bg-white', 'text-slate-600');
      });
      this.classList.add('active', 'bg-brand-600', 'text-white', 'border-brand-300');
      this.classList.remove('bg-white', 'text-slate-600');
      activeFilter = this.dataset.filter;
      applyFilters();
    });
  });
})();
</script>

<%@ include file="footer.jspf" %>
