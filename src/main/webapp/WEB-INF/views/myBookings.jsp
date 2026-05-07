<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.vrp.model.Booking, com.vrp.model.User" %>
<%
    request.setAttribute("nav", "myBookings");
    request.setAttribute("pageTitle", "My Bookings — DriveLanka");
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/auth?action=login");
        return;
    }
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    int total      = bookings == null ? 0 : bookings.size();
    long pending   = bookings == null ? 0 : bookings.stream().filter(Booking::isPending).count();
    long confirmed = bookings == null ? 0 : bookings.stream().filter(Booking::isConfirmed).count();
    long cancelled = bookings == null ? 0 : bookings.stream().filter(Booking::isCancelled).count();
    long completed = bookings == null ? 0 : bookings.stream().filter(Booking::isCompleted).count();
    String msg     = request.getParameter("msg");
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">

  <!-- Hero -->
  <div class="bg-gradient-to-br from-brand-700 to-indigo-800 text-white pb-28 pt-10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6">
      <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <p class="text-brand-200 text-sm font-semibold uppercase tracking-wider mb-1">Your Account</p>
          <h1 class="text-3xl font-extrabold">My Bookings</h1>
          <p class="text-brand-100 mt-1 text-sm">
            <span class="font-bold text-white"><%= total %></span> booking<%= total != 1 ? "s" : "" %> total
          </p>
        </div>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse"
           class="inline-flex items-center gap-2 bg-white/10 hover:bg-white/20 border border-white/25 text-white font-semibold px-4 py-2.5 rounded-xl transition text-sm shrink-0">
          <i class="bi bi-plus-lg"></i> Book a Vehicle
        </a>
      </div>

      <!-- Stat pills -->
      <div class="flex flex-wrap gap-3 mt-5">
        <span class="flex items-center gap-1.5 bg-amber-400/20 border border-amber-300/30 text-amber-100 text-xs font-bold px-3 py-1.5 rounded-full">
          <i class="bi bi-hourglass-split"></i> <%= pending %> Pending
        </span>
        <span class="flex items-center gap-1.5 bg-emerald-400/20 border border-emerald-300/30 text-emerald-100 text-xs font-bold px-3 py-1.5 rounded-full">
          <i class="bi bi-check-circle-fill"></i> <%= confirmed %> Confirmed
        </span>
        <span class="flex items-center gap-1.5 bg-slate-400/20 border border-slate-300/30 text-slate-200 text-xs font-bold px-3 py-1.5 rounded-full">
          <i class="bi bi-x-circle"></i> <%= cancelled %> Cancelled
        </span>
        <span class="flex items-center gap-1.5 bg-brand-400/20 border border-brand-300/30 text-brand-100 text-xs font-bold px-3 py-1.5 rounded-full">
          <i class="bi bi-flag-fill"></i> <%= completed %> Completed
        </span>
      </div>
    </div>
  </div>

  <div class="max-w-7xl mx-auto px-4 sm:px-6 -mt-16 pb-12">

    <% if ("cancelled".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-white border border-slate-200 text-slate-700 px-4 py-3 rounded-xl shadow-sm font-medium text-sm">
        <i class="bi bi-x-circle-fill text-rose-400"></i> Booking cancelled successfully.
      </div>
    <% } %>

    <% if (bookings == null || bookings.isEmpty()) { %>
      <div class="bg-white rounded-3xl shadow-card border border-slate-100 p-12 text-center">
        <div class="w-20 h-20 rounded-full bg-slate-50 flex items-center justify-center mx-auto mb-5">
          <i class="bi bi-calendar-x text-4xl text-slate-300"></i>
        </div>
        <h3 class="text-xl font-bold text-ink-900 mb-2">No Bookings Yet</h3>
        <p class="text-slate-500 mb-6">You haven't made any bookings. Browse our fleet and book your first vehicle!</p>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse"
           class="inline-flex items-center gap-2 bg-brand-600 hover:bg-brand-700 text-white font-bold px-8 py-3 rounded-xl shadow-btn transition">
          <i class="bi bi-search"></i> Browse Fleet
        </a>
      </div>
    <% } else { %>

      <!-- Filter Tabs -->
      <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-1.5 mb-5 flex flex-wrap gap-1">
        <button data-filter="all"       class="filter-tab active flex-1 min-w-[80px] flex items-center justify-center gap-1.5 text-xs font-bold py-2 px-3 rounded-xl transition">
          All <span class="bg-slate-200 text-slate-600 rounded-full px-1.5 py-0.5 text-[10px]"><%= total %></span>
        </button>
        <button data-filter="PENDING"   class="filter-tab flex-1 min-w-[80px] flex items-center justify-center gap-1.5 text-xs font-bold py-2 px-3 rounded-xl transition">
          <i class="bi bi-hourglass-split text-amber-500"></i> Pending
          <span class="bg-amber-100 text-amber-700 rounded-full px-1.5 py-0.5 text-[10px]"><%= pending %></span>
        </button>
        <button data-filter="CONFIRMED" class="filter-tab flex-1 min-w-[80px] flex items-center justify-center gap-1.5 text-xs font-bold py-2 px-3 rounded-xl transition">
          <i class="bi bi-check-circle-fill text-emerald-500"></i> Confirmed
          <span class="bg-emerald-100 text-emerald-700 rounded-full px-1.5 py-0.5 text-[10px]"><%= confirmed %></span>
        </button>
        <button data-filter="CANCELLED" class="filter-tab flex-1 min-w-[80px] flex items-center justify-center gap-1.5 text-xs font-bold py-2 px-3 rounded-xl transition">
          <i class="bi bi-x-circle text-rose-400"></i> Cancelled
          <span class="bg-rose-50 text-rose-600 rounded-full px-1.5 py-0.5 text-[10px]"><%= cancelled %></span>
        </button>
        <button data-filter="COMPLETED" class="filter-tab flex-1 min-w-[80px] flex items-center justify-center gap-1.5 text-xs font-bold py-2 px-3 rounded-xl transition">
          <i class="bi bi-flag-fill text-brand-500"></i> Completed
          <span class="bg-brand-50 text-brand-600 rounded-full px-1.5 py-0.5 text-[10px]"><%= completed %></span>
        </button>
      </div>

      <div id="bookingList" class="space-y-4">
        <% for (Booking b : bookings) { %>
          <div class="booking-card bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden transition hover:shadow-md"
               data-status="<%= b.getStatus() %>">
            <div class="flex flex-col sm:flex-row">

              <!-- Left: status stripe -->
              <div class="sm:w-1.5 <%= b.isConfirmed() ? "bg-emerald-500" : b.isCancelled() ? "bg-rose-400" : b.isCompleted() ? "bg-brand-500" : "bg-amber-400" %>"></div>

              <!-- Content -->
              <div class="flex-1 p-5">
                <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">
                  <div>
                    <div class="flex items-center gap-2 mb-1.5 flex-wrap">
                      <span class="font-mono text-xs font-bold text-slate-400 bg-slate-50 border border-slate-100 px-2 py-0.5 rounded"><%= b.getBookingId() %></span>
                      <span class="inline-flex items-center gap-1 text-[10px] font-bold uppercase px-2.5 py-1 rounded-full <%= b.getStatusColor() %>">
                        <%= b.getStatusLabel() %>
                      </span>
                      <% if (b.isConfirmed()) { %>
                        <span class="inline-flex items-center gap-1 text-[10px] font-bold uppercase px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-600 border border-emerald-100">
                          <i class="bi bi-credit-card-fill"></i> Paid
                        </span>
                      <% } %>
                    </div>
                    <h3 class="text-lg font-extrabold text-ink-900"><%= b.getVehicleName() %></h3>
                    <p class="text-xs text-slate-400 mt-0.5">
                      <i class="bi bi-tag mr-1"></i><span class="font-mono"><%= b.getVehicleId() %></span> · <%= b.getVehicleType() %>
                    </p>
                  </div>
                  <div class="text-right shrink-0">
                    <p class="text-2xl font-extrabold text-brand-700">LKR <%= String.format("%,.0f", b.getTotalCost()) %></p>
                    <p class="text-xs text-slate-400 mt-0.5"><%= b.getDays() %> day<%= b.getDays() != 1 ? "s" : "" %> · LKR <%= String.format("%,.0f", b.getTotalCost() / Math.max(b.getDays(),1)) %>/day</p>
                  </div>
                </div>

                <!-- Date info -->
                <div class="mt-4 flex flex-wrap gap-3 text-sm">
                  <div class="flex items-center gap-2 bg-slate-50 rounded-xl px-3 py-2 border border-slate-100">
                    <i class="bi bi-calendar3 text-brand-500"></i>
                    <span class="text-slate-500 text-xs">Pick-up</span>
                    <span class="font-bold text-ink-900 text-xs"><%= b.getStartDate() %></span>
                  </div>
                  <div class="flex items-center gap-2 bg-slate-50 rounded-xl px-3 py-2 border border-slate-100">
                    <i class="bi bi-calendar3-range text-brand-500"></i>
                    <span class="text-slate-500 text-xs">Return</span>
                    <span class="font-bold text-ink-900 text-xs"><%= b.getEndDate() %></span>
                  </div>
                  <div class="flex items-center gap-2 bg-slate-50 rounded-xl px-3 py-2 border border-slate-100">
                    <i class="bi bi-clock text-slate-300"></i>
                    <span class="text-slate-400 text-xs">Booked <%= b.getCreatedAt() %></span>
                  </div>
                </div>

                <!-- Actions -->
                <div class="mt-4 pt-4 border-t border-slate-50 flex items-center gap-2 flex-wrap">
                  <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= b.getVehicleId() %>"
                     class="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-600 hover:text-brand-800 border border-brand-200 hover:border-brand-400 bg-brand-50 hover:bg-brand-100 px-3 py-1.5 rounded-lg transition">
                    <i class="bi bi-eye"></i> View Vehicle
                  </a>
                  <% if (b.isPending()) { %>
                    <a href="${pageContext.request.contextPath}/payment?action=form&bookingId=<%= b.getBookingId() %>"
                       class="inline-flex items-center gap-1.5 text-xs font-bold text-white bg-emerald-500 hover:bg-emerald-600 px-4 py-1.5 rounded-lg transition shadow-sm">
                      <i class="bi bi-credit-card-fill"></i> Pay Now
                    </a>
                    <a href="${pageContext.request.contextPath}/booking?action=cancel&id=<%= b.getBookingId() %>"
                       onclick="return confirm('Are you sure you want to cancel booking <%= b.getBookingId() %>?');"
                       class="inline-flex items-center gap-1.5 text-xs font-semibold text-rose-500 hover:text-rose-700 border border-rose-200 hover:border-rose-400 hover:bg-rose-50 px-3 py-1.5 rounded-lg transition">
                      <i class="bi bi-x-circle"></i> Cancel
                    </a>
                  <% } else if (b.isConfirmed()) { %>
                    <span class="inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-600 border border-emerald-200 px-3 py-1.5 rounded-lg bg-emerald-50">
                      <i class="bi bi-shield-check-fill"></i> Paid & Confirmed
                    </span>
                  <% } else if (b.isCompleted()) { %>
                    <span class="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-600 border border-brand-200 px-3 py-1.5 rounded-lg bg-brand-50">
                      <i class="bi bi-flag-fill"></i> Rental Completed
                    </span>
                    <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= b.getVehicleId() %>"
                       class="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-brand-600 border border-slate-200 hover:border-brand-300 px-3 py-1.5 rounded-lg transition">
                      <i class="bi bi-arrow-repeat"></i> Book Again
                    </a>
                  <% } %>
                </div>
              </div>
            </div>
          </div>
        <% } %>
      </div>

      <div id="noFilterResults" class="hidden py-16 text-center text-slate-400">
        <i class="bi bi-filter text-4xl mb-3 block opacity-30"></i>
        <p class="font-medium">No bookings match this filter.</p>
      </div>

      <div class="mt-8 text-center">
        <a href="${pageContext.request.contextPath}/vehicles?action=browse"
           class="inline-flex items-center gap-2 bg-white hover:bg-brand-50 border border-brand-200 text-brand-700 font-bold px-8 py-3 rounded-xl shadow-sm transition">
          <i class="bi bi-plus-lg"></i> Book Another Vehicle
        </a>
      </div>
    <% } %>
  </div>
</div>

<style>
.filter-tab { color: #64748b; }
.filter-tab.active { background: #0284c7; color: white; }
.filter-tab.active span { background: rgba(255,255,255,.25); color: white; }
</style>

<script>
(function() {
  var tabs  = document.querySelectorAll('.filter-tab');
  var cards = document.querySelectorAll('.booking-card');
  var noRes = document.getElementById('noFilterResults');
  if (!tabs.length) return;

  tabs.forEach(function(tab) {
    tab.addEventListener('click', function() {
      tabs.forEach(function(t) { t.classList.remove('active'); });
      this.classList.add('active');
      var f = this.dataset.filter;
      var visible = 0;
      cards.forEach(function(c) {
        var show = f === 'all' || c.dataset.status === f;
        c.classList.toggle('hidden', !show);
        if (show) visible++;
      });
      if (noRes) noRes.classList.toggle('hidden', visible > 0);
    });
  });
})();
</script>

<%@ include file="footer.jspf" %>
