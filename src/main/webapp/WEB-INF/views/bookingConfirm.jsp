<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.Booking" %>
<%
    Booking b = (Booking) request.getAttribute("booking");
    if (b == null) {
        response.sendRedirect(request.getContextPath() + "/booking?action=my");
        return;
    }
    request.setAttribute("pageTitle", "Booking Confirmed — DriveLanka");
%>
<%@ include file="header.jspf" %>

<div class="max-w-2xl mx-auto px-4 sm:px-6 py-12">

  <!-- Success animation -->
  <div class="text-center mb-8">
    <div class="w-20 h-20 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-4 shadow-sm">
      <i class="bi bi-check-circle-fill text-emerald-500 text-4xl"></i>
    </div>
    <h1 class="text-3xl font-extrabold text-ink-900">Booking Submitted!</h1>
    <p class="text-slate-500 mt-2">Your reservation request has been received and is pending confirmation.</p>
  </div>

  <!-- Booking card -->
  <div class="bg-white rounded-3xl shadow-card border border-slate-100 overflow-hidden">

    <!-- Header band -->
    <div class="bg-gradient-to-r from-brand-600 to-indigo-600 px-6 py-4 flex items-center justify-between">
      <div>
        <p class="text-brand-100 text-xs font-semibold uppercase tracking-wider">Booking Reference</p>
        <p class="text-2xl font-extrabold text-white font-mono tracking-widest"><%= b.getBookingId() %></p>
      </div>
      <span class="inline-flex items-center gap-1.5 bg-white/20 text-white text-xs font-bold uppercase px-3 py-1.5 rounded-full">
        <i class="bi bi-clock-fill"></i> <%= b.getStatusLabel() %>
      </span>
    </div>

    <!-- Details -->
    <div class="p-6 space-y-4">

      <div class="flex items-center gap-4 pb-4 border-b border-slate-100">
        <div class="w-14 h-14 rounded-xl bg-brand-50 flex items-center justify-center text-brand-600 text-2xl shrink-0">
          <i class="bi bi-car-front-fill"></i>
        </div>
        <div>
          <p class="text-xs text-slate-400 font-semibold uppercase tracking-wider">Vehicle</p>
          <p class="font-extrabold text-ink-900 text-lg"><%= b.getVehicleName() %></p>
          <p class="text-xs text-slate-400 font-mono"><%= b.getVehicleId() %> · <%= b.getVehicleType() %></p>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div class="bg-slate-50 rounded-xl p-3">
          <p class="text-[10px] text-slate-400 uppercase font-semibold mb-1">Pick-up Date</p>
          <p class="font-bold text-ink-900"><%= b.getStartDate() %></p>
        </div>
        <div class="bg-slate-50 rounded-xl p-3">
          <p class="text-[10px] text-slate-400 uppercase font-semibold mb-1">Return Date</p>
          <p class="font-bold text-ink-900"><%= b.getEndDate() %></p>
        </div>
        <div class="bg-slate-50 rounded-xl p-3">
          <p class="text-[10px] text-slate-400 uppercase font-semibold mb-1">Duration</p>
          <p class="font-bold text-ink-900"><%= b.getDays() %> day<%= b.getDays() != 1 ? "s" : "" %></p>
        </div>
        <div class="bg-slate-50 rounded-xl p-3">
          <p class="text-[10px] text-slate-400 uppercase font-semibold mb-1">Daily Rate</p>
          <p class="font-bold text-ink-900">LKR <%= String.format("%,.0f", b.getDailyRate()) %></p>
        </div>
      </div>

      <!-- Total cost -->
      <div class="bg-gradient-to-r from-brand-50 to-indigo-50 rounded-xl p-4 flex items-center justify-between border border-brand-100">
        <div>
          <p class="text-xs text-slate-400 uppercase font-semibold">Total Cost</p>
          <p class="text-3xl font-extrabold text-brand-700">LKR <%= String.format("%,.0f", b.getTotalCost()) %></p>
        </div>
        <div class="text-right">
          <p class="text-xs text-slate-400 uppercase font-semibold">Booked By</p>
          <p class="font-bold text-ink-900"><%= b.getCustomerName() %></p>
          <p class="text-xs font-mono text-slate-400">@<%= b.getCustomerUsername() %></p>
        </div>
      </div>

      <!-- Status info -->
      <div class="bg-amber-50 border border-amber-100 rounded-xl p-4 text-sm">
        <div class="flex items-start gap-3">
          <i class="bi bi-hourglass-split text-amber-500 text-lg mt-0.5"></i>
          <div>
            <p class="font-semibold text-amber-800">Awaiting Confirmation</p>
            <p class="text-amber-700 mt-1">Our team will review your booking and update the status. You can track it in My Bookings.</p>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="flex flex-col sm:flex-row gap-3 pt-2">
        <a href="${pageContext.request.contextPath}/booking?action=my"
           class="flex-1 text-center bg-brand-600 hover:bg-brand-700 text-white font-bold py-3 rounded-xl shadow-btn transition flex items-center justify-center gap-2">
          <i class="bi bi-list-ul"></i> My Bookings
        </a>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse"
           class="flex-1 text-center bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
          <i class="bi bi-search"></i> Browse More
        </a>
      </div>
    </div>
  </div>

  <p class="text-center text-xs text-slate-400 mt-6">
    Booking ID: <span class="font-mono font-semibold"><%= b.getBookingId() %></span> · Created: <%= b.getCreatedAt() %>
  </p>
</div>

<%@ include file="footer.jspf" %>
