<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.Booking" %>
<%
    Booking b = (Booking) request.getAttribute("booking");
    if (b == null) { response.sendRedirect(request.getContextPath() + "/booking?action=my"); return; }
    request.setAttribute("pageTitle", "Booking Submitted — DriveLanka");
%>
<%@ include file="header.jspf" %>

<style>
@keyframes slideUp { from{opacity:0;transform:translateY(24px)} to{opacity:1;transform:translateY(0)} }
.slide-up { animation: slideUp .45s ease both; }
@keyframes pulse-ring { 0%{transform:scale(.9);opacity:.7} 70%{transform:scale(1.1);opacity:0} 100%{opacity:0} }
.pulse-ring::before { content:''; position:absolute; inset:-8px; border-radius:50%; border:3px solid #f59e0b; animation:pulse-ring 1.5s ease infinite; }
</style>

<div class="bg-gradient-to-br from-amber-50 via-white to-brand-50 min-h-screen py-12">
  <div class="max-w-2xl mx-auto px-4 sm:px-6">

    <!-- Hero -->
    <div class="text-center mb-8 slide-up">
      <div class="relative inline-flex items-center justify-center w-20 h-20 rounded-full bg-amber-400 shadow-2xl shadow-amber-200 mb-5 pulse-ring">
        <i class="bi bi-calendar-check-fill text-white text-4xl"></i>
      </div>
      <h1 class="text-3xl font-extrabold text-ink-900">Booking Submitted!</h1>
      <p class="text-slate-500 mt-2">Complete your payment below to confirm the reservation instantly.</p>
    </div>

    <!-- Booking card -->
    <div class="bg-white rounded-3xl shadow-card border border-slate-100 overflow-hidden slide-up" style="animation-delay:.1s">

      <!-- Header band -->
      <div class="bg-gradient-to-r from-amber-500 to-orange-500 px-6 py-4 flex items-center justify-between">
        <div>
          <p class="text-amber-100 text-xs font-semibold uppercase tracking-wider">Booking Reference</p>
          <p class="text-2xl font-extrabold text-white font-mono tracking-widest"><%= b.getBookingId() %></p>
        </div>
        <span class="inline-flex items-center gap-1.5 bg-white/25 text-white text-xs font-bold uppercase px-3 py-1.5 rounded-full">
          <i class="bi bi-hourglass-split"></i> Awaiting Payment
        </span>
      </div>

      <div class="p-6 space-y-4">

        <!-- Vehicle -->
        <div class="flex items-center gap-4 pb-4 border-b border-slate-100">
          <div class="w-14 h-14 rounded-xl bg-brand-50 flex items-center justify-center text-brand-600 text-2xl shrink-0">
            <i class="bi bi-<%= "Car".equals(b.getVehicleType())?"car-front-fill":"Bike".equals(b.getVehicleType())?"bicycle":"truck" %>"></i>
          </div>
          <div>
            <p class="text-xs text-slate-400 font-semibold uppercase tracking-wider">Vehicle</p>
            <p class="font-extrabold text-ink-900 text-lg"><%= b.getVehicleName() %></p>
            <p class="text-xs text-slate-400 font-mono"><%= b.getVehicleId() %> · <%= b.getVehicleType() %></p>
          </div>
        </div>

        <!-- Spec grid -->
        <div class="grid grid-cols-2 gap-3">
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
            <p class="font-bold text-ink-900"><%= b.getDays() %> day<%= b.getDays()!=1?"s":"" %></p>
          </div>
          <div class="bg-slate-50 rounded-xl p-3">
            <p class="text-[10px] text-slate-400 uppercase font-semibold mb-1">Daily Rate</p>
            <p class="font-bold text-ink-900">LKR <%= String.format("%,.0f", b.getDailyRate()) %></p>
          </div>
        </div>

        <!-- Total -->
        <div class="bg-gradient-to-r from-brand-50 to-amber-50 rounded-2xl p-4 flex items-center justify-between border border-brand-100">
          <div>
            <p class="text-xs text-slate-400 uppercase font-semibold">Total Due</p>
            <p class="text-3xl font-extrabold text-brand-700">LKR <%= String.format("%,.0f", b.getTotalCost()) %></p>
          </div>
          <div class="text-right">
            <p class="text-xs text-slate-400 uppercase font-semibold">Booked By</p>
            <p class="font-bold text-ink-900"><%= b.getCustomerName() %></p>
            <p class="text-xs font-mono text-slate-400">@<%= b.getCustomerUsername() %></p>
          </div>
        </div>

        <!-- Pay Now CTA (primary) -->
        <a href="${pageContext.request.contextPath}/payment?action=form&bookingId=<%= b.getBookingId() %>"
           class="block w-full text-center bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 text-white font-extrabold text-lg py-4 rounded-2xl shadow-lg transition flex items-center justify-center gap-3">
          <i class="bi bi-credit-card-fill text-xl"></i>
          Complete Payment — LKR <%= String.format("%,.0f", b.getTotalCost()) %>
        </a>

        <!-- What happens info -->
        <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 text-sm">
          <div class="flex items-start gap-3">
            <i class="bi bi-info-circle-fill text-blue-500 mt-0.5 shrink-0"></i>
            <div>
              <p class="font-semibold text-blue-800">Why pay now?</p>
              <p class="text-blue-700 mt-1 text-xs leading-relaxed">Paying now instantly confirms your booking. Without payment, your reservation remains <strong>Pending</strong> and may be cancelled by admin.</p>
            </div>
          </div>
        </div>

        <!-- Secondary actions -->
        <div class="flex flex-col sm:flex-row gap-3">
          <a href="${pageContext.request.contextPath}/booking?action=my"
             class="flex-1 text-center bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 font-semibold py-3 rounded-xl transition text-sm flex items-center justify-center gap-2">
            <i class="bi bi-list-ul"></i> My Bookings
          </a>
          <a href="${pageContext.request.contextPath}/vehicles?action=browse"
             class="flex-1 text-center bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 font-semibold py-3 rounded-xl transition text-sm flex items-center justify-center gap-2">
            <i class="bi bi-search"></i> Browse More
          </a>
        </div>

        <!-- Cancel option -->
        <div class="border-t border-slate-100 pt-4">
          <p class="text-xs text-slate-400 text-center mb-2">Changed your mind?</p>
          <a href="${pageContext.request.contextPath}/booking?action=cancel&id=<%= b.getBookingId() %>"
             onclick="return confirm('Cancel booking <%= b.getBookingId() %>? This cannot be undone.');"
             class="w-full flex items-center justify-center gap-2 text-sm font-semibold text-rose-500 hover:text-rose-700 border border-rose-200 hover:border-rose-400 hover:bg-rose-50 py-2.5 rounded-xl transition">
            <i class="bi bi-x-circle"></i> Cancel This Booking
          </a>
        </div>
      </div>
    </div>

    <p class="text-center text-xs text-slate-400 mt-6">
      Booking ID: <span class="font-mono font-semibold"><%= b.getBookingId() %></span> · Created: <%= b.getCreatedAt() %>
    </p>
  </div>
</div>

<%@ include file="footer.jspf" %>
