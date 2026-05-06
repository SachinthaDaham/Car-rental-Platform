<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, com.vrp.model.Booking" %>
<%
    request.setAttribute("nav", "bookings");
    request.setAttribute("pageTitle", "Manage Bookings — DriveLanka Admin");
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    Map<String, Object> bStats = (Map<String, Object>) request.getAttribute("bookingStats");
    String msg = request.getParameter("msg");

    int  total     = bStats != null ? ((Number) bStats.get("total")).intValue()     : 0;
    long pending   = bStats != null ? (Long) bStats.get("pending")   : 0;
    long confirmed = bStats != null ? (Long) bStats.get("confirmed") : 0;
    long cancelled = bStats != null ? (Long) bStats.get("cancelled") : 0;
    long completed = bStats != null ? (Long) bStats.get("completed") : 0;
    double revenue = bStats != null ? (Double) bStats.get("totalRevenue") : 0;
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 py-8">

    <!-- Header -->
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-3xl font-extrabold text-ink-900">Manage Bookings</h1>
        <p class="text-slate-500 mt-1">
          <span class="font-semibold text-ink-900"><%= total %></span> total ·
          <span class="text-amber-600 font-semibold"><%= pending %> pending</span> ·
          <span class="text-emerald-600 font-semibold"><%= confirmed %> confirmed</span>
        </p>
      </div>
      <a href="${pageContext.request.contextPath}/vehicles?action=dashboard"
         class="inline-flex items-center gap-2 bg-white border border-slate-200 text-slate-600 hover:border-brand-300 hover:text-brand-700 font-semibold py-2.5 px-4 rounded-xl transition text-sm">
        <i class="bi bi-speedometer2"></i> Dashboard
      </a>
    </div>

    <!-- Stats strip -->
    <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4 mb-6">
      <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 text-center lg:col-span-2">
        <p class="text-xs text-slate-400 font-semibold uppercase tracking-wide mb-1">Total Revenue</p>
        <p class="text-2xl font-extrabold text-brand-700">LKR <%= String.format("%,.0f", revenue) %></p>
      </div>
      <div class="bg-amber-50 rounded-2xl border border-amber-100 shadow-sm p-4 text-center">
        <p class="text-2xl font-extrabold text-amber-600"><%= pending %></p>
        <p class="text-xs text-amber-600 font-semibold mt-1">Pending</p>
      </div>
      <div class="bg-emerald-50 rounded-2xl border border-emerald-100 shadow-sm p-4 text-center">
        <p class="text-2xl font-extrabold text-emerald-600"><%= confirmed %></p>
        <p class="text-xs text-emerald-600 font-semibold mt-1">Confirmed</p>
      </div>
      <div class="bg-brand-50 rounded-2xl border border-brand-100 shadow-sm p-4 text-center">
        <p class="text-2xl font-extrabold text-brand-600"><%= completed %></p>
        <p class="text-xs text-brand-600 font-semibold mt-1">Completed</p>
      </div>
    </div>

    <!-- Flash messages -->
    <% if ("updated".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-emerald-50 text-emerald-700 px-4 py-3 rounded-xl border border-emerald-200 font-medium text-sm">
        <i class="bi bi-check-circle-fill"></i> Booking status updated.
      </div>
    <% } else if ("deleted".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-slate-100 text-slate-700 px-4 py-3 rounded-xl border border-slate-200 font-medium text-sm">
        <i class="bi bi-trash3-fill"></i> Booking removed.
      </div>
    <% } %>

    <!-- Search & filter -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 mb-4 flex flex-col sm:flex-row gap-3">
      <div class="relative flex-1">
        <i class="bi bi-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
        <input id="bSearch" type="text" placeholder="Search by booking ID, vehicle, or customer…"
               class="w-full pl-9 pr-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
      </div>
      <div class="flex gap-2 flex-wrap">
        <button data-status="all"       class="status-btn active px-3 py-2 text-xs font-bold rounded-lg border border-brand-300 bg-brand-600 text-white">All</button>
        <button data-status="PENDING"   class="status-btn px-3 py-2 text-xs font-bold rounded-lg border border-amber-200 bg-white text-amber-600 hover:bg-amber-50">Pending</button>
        <button data-status="CONFIRMED" class="status-btn px-3 py-2 text-xs font-bold rounded-lg border border-emerald-200 bg-white text-emerald-600 hover:bg-emerald-50">Confirmed</button>
        <button data-status="CANCELLED" class="status-btn px-3 py-2 text-xs font-bold rounded-lg border border-rose-200 bg-white text-rose-500 hover:bg-rose-50">Cancelled</button>
        <button data-status="COMPLETED" class="status-btn px-3 py-2 text-xs font-bold rounded-lg border border-brand-200 bg-white text-brand-600 hover:bg-brand-50">Completed</button>
      </div>
    </div>

    <p class="text-xs text-slate-400 font-medium mb-3 px-1">
      Showing <span id="visibleCount"><%= total %></span> of <%= total %> bookings
    </p>

    <!-- Table -->
    <% if (bookings == null || bookings.isEmpty()) { %>
      <div class="bg-white rounded-2xl shadow-sm border border-slate-100 p-12 text-center">
        <i class="bi bi-calendar-x text-5xl text-slate-200 mb-3 block"></i>
        <p class="text-lg font-bold text-slate-700">No bookings yet</p>
        <p class="text-slate-400 text-sm mt-1">Bookings will appear here once customers start booking vehicles.</p>
      </div>
    <% } else { %>
      <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left">
            <thead>
              <tr class="bg-slate-50 text-xs uppercase text-slate-500 tracking-wider">
                <th class="px-5 py-4 font-semibold">Booking</th>
                <th class="px-5 py-4 font-semibold">Vehicle</th>
                <th class="px-5 py-4 font-semibold hidden md:table-cell">Customer</th>
                <th class="px-5 py-4 font-semibold hidden lg:table-cell">Dates</th>
                <th class="px-5 py-4 font-semibold">Total</th>
                <th class="px-5 py-4 font-semibold text-center">Status</th>
                <th class="px-5 py-4 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody id="bookingTableBody" class="text-sm divide-y divide-slate-50">
              <% for (Booking b : bookings) { %>
                <tr class="booking-row hover:bg-slate-50/70 transition-colors"
                    data-id="<%= b.getBookingId().toLowerCase() %>"
                    data-vehicle="<%= b.getVehicleName().toLowerCase() %>"
                    data-customer="<%= b.getCustomerUsername().toLowerCase() %> <%= b.getCustomerName().toLowerCase() %>"
                    data-status="<%= b.getStatus() %>">
                  <td class="px-5 py-4">
                    <p class="font-mono font-bold text-ink-900 text-sm"><%= b.getBookingId() %></p>
                    <p class="text-[10px] text-slate-400 mt-0.5"><%= b.getCreatedAt() %></p>
                  </td>
                  <td class="px-5 py-4">
                    <p class="font-bold text-ink-900"><%= b.getVehicleName() %></p>
                    <p class="text-xs font-mono text-slate-400"><%= b.getVehicleId() %></p>
                  </td>
                  <td class="px-5 py-4 hidden md:table-cell">
                    <p class="font-semibold text-slate-700"><%= b.getCustomerName() %></p>
                    <p class="text-xs font-mono text-slate-400">@<%= b.getCustomerUsername() %></p>
                  </td>
                  <td class="px-5 py-4 hidden lg:table-cell">
                    <p class="text-slate-700 text-xs"><%= b.getStartDate() %> →</p>
                    <p class="text-slate-700 text-xs"><%= b.getEndDate() %></p>
                    <p class="text-[10px] text-slate-400"><%= b.getDays() %> day<%= b.getDays()!=1?"s":"" %></p>
                  </td>
                  <td class="px-5 py-4 font-bold text-brand-700">LKR <%= String.format("%,.0f", b.getTotalCost()) %></td>
                  <td class="px-5 py-4 text-center">
                    <span class="inline-flex items-center gap-1 text-[10px] font-bold uppercase px-2.5 py-1 rounded-full <%= b.getStatusColor() %>">
                      <%= b.getStatusLabel() %>
                    </span>
                  </td>
                  <td class="px-5 py-4 text-right">
                    <div class="flex items-center justify-end gap-1">
                      <% if (b.isPending()) { %>
                        <a href="${pageContext.request.contextPath}/booking?action=updateStatus&id=<%= b.getBookingId() %>&status=CONFIRMED"
                           onclick="return confirm('Confirm booking <%= b.getBookingId() %>?');"
                           class="inline-flex items-center gap-1 text-xs font-bold text-white bg-emerald-500 hover:bg-emerald-600 px-2.5 py-1.5 rounded-lg transition" title="Confirm">
                          <i class="bi bi-check-lg"></i> Confirm
                        </a>
                        <a href="${pageContext.request.contextPath}/booking?action=updateStatus&id=<%= b.getBookingId() %>&status=CANCELLED"
                           onclick="return confirm('Cancel booking <%= b.getBookingId() %>?');"
                           class="inline-flex items-center gap-1 text-xs font-bold text-white bg-rose-500 hover:bg-rose-600 px-2.5 py-1.5 rounded-lg transition" title="Cancel">
                          <i class="bi bi-x-lg"></i>
                        </a>
                      <% } else if (b.isConfirmed()) { %>
                        <a href="${pageContext.request.contextPath}/booking?action=updateStatus&id=<%= b.getBookingId() %>&status=COMPLETED"
                           onclick="return confirm('Mark as completed?');"
                           class="inline-flex items-center gap-1 text-xs font-bold text-white bg-brand-500 hover:bg-brand-600 px-2.5 py-1.5 rounded-lg transition">
                          <i class="bi bi-flag-fill"></i> Complete
                        </a>
                      <% } %>
                      <a href="${pageContext.request.contextPath}/booking?action=delete&id=<%= b.getBookingId() %>"
                         onclick="return confirm('Permanently delete booking <%= b.getBookingId() %>?');"
                         class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-slate-100 hover:bg-rose-100 text-slate-500 hover:text-rose-700 transition" title="Delete">
                        <i class="bi bi-trash3 text-xs"></i>
                      </a>
                    </div>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
          <div id="noBookingResults" class="hidden py-12 text-center text-slate-400">
            <i class="bi bi-search text-4xl mb-3 block opacity-30"></i>
            <p class="font-medium">No bookings match your search.</p>
          </div>
        </div>
      </div>
    <% } %>
  </div>
</div>

<script>
(function() {
  var searchEl  = document.getElementById('bSearch');
  var rows      = document.querySelectorAll('.booking-row');
  var noRes     = document.getElementById('noBookingResults');
  var countEl   = document.getElementById('visibleCount');
  var btns      = document.querySelectorAll('.status-btn');
  var activeStatus = 'all';

  function filter() {
    var q = searchEl ? searchEl.value.toLowerCase().trim() : '';
    var visible = 0;
    rows.forEach(function(r) {
      var matchSearch = !q || r.dataset.id.includes(q) || r.dataset.vehicle.includes(q) || r.dataset.customer.includes(q);
      var matchStatus = activeStatus === 'all' || r.dataset.status === activeStatus;
      var show = matchSearch && matchStatus;
      r.classList.toggle('hidden', !show);
      if (show) visible++;
    });
    if (countEl) countEl.textContent = visible;
    if (noRes) noRes.classList.toggle('hidden', visible > 0);
  }

  if (searchEl) searchEl.addEventListener('input', filter);

  btns.forEach(function(btn) {
    btn.addEventListener('click', function() {
      btns.forEach(function(b) { b.classList.remove('active','bg-brand-600','text-white','border-brand-300'); b.classList.add('bg-white'); });
      this.classList.add('active','bg-brand-600','text-white','border-brand-300');
      this.classList.remove('bg-white');
      activeStatus = this.dataset.status;
      filter();
    });
  });
})();
</script>

<%@ include file="footer.jspf" %>
