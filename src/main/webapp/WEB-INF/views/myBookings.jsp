<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.vrp.model.Booking, com.vrp.model.User" %>
<%
    request.setAttribute("pageTitle", "My Bookings — DriveLanka");
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/auth?action=login");
        return;
    }
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    int total     = bookings == null ? 0 : bookings.size();
    long pending  = bookings == null ? 0 : bookings.stream().filter(Booking::isPending).count();
    long confirmed= bookings == null ? 0 : bookings.stream().filter(Booking::isConfirmed).count();
    String msg    = request.getParameter("msg");
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">

  <!-- Hero -->
  <div class="bg-gradient-to-br from-brand-700 to-indigo-800 text-white pb-24 pt-10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6">
      <h1 class="text-3xl font-extrabold">My Bookings</h1>
      <p class="text-brand-100 mt-1">
        <span class="font-bold"><%= total %></span> booking<%= total != 1 ? "s" : "" %>
        <% if (pending > 0) { %> · <span class="text-amber-200 font-bold"><%= pending %> pending</span><% } %>
        <% if (confirmed > 0) { %> · <span class="text-emerald-200 font-bold"><%= confirmed %> confirmed</span><% } %>
      </p>
    </div>
  </div>

  <div class="max-w-7xl mx-auto px-4 sm:px-6 -mt-16 pb-12">

    <% if ("cancelled".equals(msg)) { %>
      <div class="mb-5 flex items-center gap-2 bg-slate-100 text-slate-700 px-4 py-3 rounded-xl border border-slate-200 font-medium text-sm">
        <i class="bi bi-x-circle-fill text-slate-500"></i> Booking cancelled successfully.
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
      <div class="space-y-4">
        <% for (Booking b : bookings) { %>
          <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
            <div class="flex flex-col sm:flex-row">

              <!-- Left: status stripe -->
              <div class="sm:w-2 <%= b.isConfirmed() ? "bg-emerald-500" : b.isCancelled() ? "bg-rose-400" : b.isCompleted() ? "bg-brand-500" : "bg-amber-400" %>"></div>

              <!-- Content -->
              <div class="flex-1 p-5">
                <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">
                  <div>
                    <div class="flex items-center gap-2 mb-1 flex-wrap">
                      <span class="font-mono text-sm font-bold text-slate-500"><%= b.getBookingId() %></span>
                      <span class="inline-flex items-center gap-1 text-[10px] font-bold uppercase px-2 py-0.5 rounded-full <%= b.getStatusColor() %>">
                        <%= b.getStatusLabel() %>
                      </span>
                    </div>
                    <h3 class="text-lg font-extrabold text-ink-900"><%= b.getVehicleName() %></h3>
                    <p class="text-xs text-slate-400 mt-0.5">
                      <i class="bi bi-tag mr-1"></i><%= b.getVehicleId() %> · <%= b.getVehicleType() %>
                    </p>
                  </div>
                  <div class="text-right shrink-0">
                    <p class="text-2xl font-extrabold text-brand-700">LKR <%= String.format("%,.0f", b.getTotalCost()) %></p>
                    <p class="text-xs text-slate-400 mt-0.5"><%= b.getDays() %> day<%= b.getDays() != 1 ? "s" : "" %> rental</p>
                  </div>
                </div>

                <!-- Date info -->
                <div class="mt-4 flex flex-wrap gap-4 text-sm">
                  <div class="flex items-center gap-2 bg-slate-50 rounded-lg px-3 py-2">
                    <i class="bi bi-calendar3 text-brand-500"></i>
                    <span class="text-slate-500">Pick-up:</span>
                    <span class="font-semibold text-ink-900"><%= b.getStartDate() %></span>
                  </div>
                  <div class="flex items-center gap-2 bg-slate-50 rounded-lg px-3 py-2">
                    <i class="bi bi-calendar3-range text-brand-500"></i>
                    <span class="text-slate-500">Return:</span>
                    <span class="font-semibold text-ink-900"><%= b.getEndDate() %></span>
                  </div>
                  <div class="flex items-center gap-2 bg-slate-50 rounded-lg px-3 py-2">
                    <i class="bi bi-clock text-slate-400"></i>
                    <span class="text-slate-400 text-xs">Booked: <%= b.getCreatedAt() %></span>
                  </div>
                </div>

                <!-- Actions -->
                <div class="mt-4 flex items-center gap-2 flex-wrap">
                  <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= b.getVehicleId() %>"
                     class="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-600 hover:text-brand-800 border border-brand-200 hover:border-brand-400 px-3 py-1.5 rounded-lg transition">
                    <i class="bi bi-eye"></i> View Vehicle
                  </a>
                  <% if (b.isPending()) { %>
                    <a href="${pageContext.request.contextPath}/booking?action=cancel&id=<%= b.getBookingId() %>"
                       onclick="return confirm('Cancel booking <%= b.getBookingId() %>?');"
                       class="inline-flex items-center gap-1.5 text-xs font-semibold text-rose-500 hover:text-rose-700 border border-rose-200 hover:border-rose-400 px-3 py-1.5 rounded-lg transition">
                      <i class="bi bi-x-circle"></i> Cancel Booking
                    </a>
                  <% } %>
                </div>
              </div>
            </div>
          </div>
        <% } %>
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

<%@ include file="footer.jspf" %>
