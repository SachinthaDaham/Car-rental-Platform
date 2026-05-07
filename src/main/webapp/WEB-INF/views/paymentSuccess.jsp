<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.Booking, com.vrp.model.Payment" %>
<%
    Booking b = (Booking) request.getAttribute("booking");
    Payment p = (Payment) request.getAttribute("payment");
    if (b == null || p == null) { response.sendRedirect(request.getContextPath() + "/booking?action=my"); return; }
    request.setAttribute("pageTitle","Payment Confirmed — DriveLanka");
%>
<%@ include file="header.jspf" %>

<style>
@keyframes confettiFall {
  0%   { transform: translateY(-10px) rotate(0deg); opacity:1; }
  100% { transform: translateY(600px) rotate(720deg); opacity:0; }
}
.confetti-piece {
  position:fixed; width:10px; height:10px; border-radius:2px; animation: confettiFall linear infinite;
  pointer-events:none; z-index:999;
}
@keyframes checkPop { 0%{transform:scale(0);opacity:0} 60%{transform:scale(1.2)} 100%{transform:scale(1);opacity:1} }
.check-anim { animation: checkPop 0.6s cubic-bezier(.175,.885,.32,1.275) both; }
@keyframes slideUp { from{opacity:0;transform:translateY(30px)} to{opacity:1;transform:translateY(0)} }
.slide-up { animation: slideUp .5s ease both; }
</style>

<!-- Confetti -->
<div id="confettiContainer"></div>

<div class="bg-gradient-to-br from-emerald-50 to-brand-50 min-h-screen py-12">
  <div class="max-w-2xl mx-auto px-4 sm:px-6">

    <!-- Success hero -->
    <div class="text-center mb-8 slide-up">
      <div class="check-anim inline-flex items-center justify-center w-24 h-24 rounded-full bg-emerald-500 shadow-2xl shadow-emerald-200 mb-5">
        <i class="bi bi-check-lg text-white text-5xl"></i>
      </div>
      <h1 class="text-4xl font-extrabold text-ink-900 mb-2">Payment Confirmed!</h1>
      <p class="text-slate-500 text-lg">Your booking is confirmed and ready to go.</p>
    </div>

    <!-- Receipt card -->
    <div class="bg-white rounded-3xl shadow-card border border-slate-100 overflow-hidden slide-up" style="animation-delay:.15s">

      <!-- Header band -->
      <div class="bg-gradient-to-r from-emerald-500 to-teal-600 px-7 py-5 flex items-center justify-between">
        <div>
          <p class="text-emerald-100 text-xs font-semibold uppercase tracking-wider">Booking Reference</p>
          <p class="text-white text-2xl font-extrabold font-mono"><%= b.getBookingId() %></p>
        </div>
        <div class="text-right">
          <p class="text-emerald-100 text-xs font-semibold uppercase tracking-wider">Payment ID</p>
          <p class="text-white font-mono text-sm font-bold"><%= p.getPaymentId() %></p>
        </div>
      </div>

      <div class="p-7">
        <!-- Vehicle -->
        <div class="flex items-center gap-4 pb-5 border-b border-slate-100 mb-5">
          <div class="w-12 h-12 rounded-2xl bg-brand-50 flex items-center justify-center shrink-0">
            <i class="bi bi-<%= "Car".equals(b.getVehicleType())?"car-front-fill":"Bike".equals(b.getVehicleType())?"bicycle":"truck" %> text-brand-600 text-xl"></i>
          </div>
          <div>
            <h3 class="font-extrabold text-xl text-ink-900"><%= b.getVehicleName() %></h3>
            <p class="text-slate-400 text-sm"><%= b.getVehicleId() %> · <%= b.getVehicleType() %></p>
          </div>
          <span class="ml-auto inline-flex items-center gap-1.5 bg-emerald-100 text-emerald-700 text-xs font-bold px-3 py-1.5 rounded-full">
            <i class="bi bi-check-circle-fill"></i> CONFIRMED
          </span>
        </div>

        <!-- Spec grid -->
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-5">
          <div class="bg-slate-50 rounded-xl p-3 text-center">
            <p class="text-[10px] text-slate-400 uppercase font-bold tracking-wider mb-1">Pick-up</p>
            <p class="font-bold text-sm text-ink-900"><%= b.getStartDate() %></p>
          </div>
          <div class="bg-slate-50 rounded-xl p-3 text-center">
            <p class="text-[10px] text-slate-400 uppercase font-bold tracking-wider mb-1">Return</p>
            <p class="font-bold text-sm text-ink-900"><%= b.getEndDate() %></p>
          </div>
          <div class="bg-slate-50 rounded-xl p-3 text-center">
            <p class="text-[10px] text-slate-400 uppercase font-bold tracking-wider mb-1">Duration</p>
            <p class="font-bold text-sm text-ink-900"><%= b.getDays() %> day<%= b.getDays()!=1?"s":"" %></p>
          </div>
          <div class="bg-slate-50 rounded-xl p-3 text-center">
            <p class="text-[10px] text-slate-400 uppercase font-bold tracking-wider mb-1">Daily Rate</p>
            <p class="font-bold text-sm text-ink-900">LKR <%= String.format("%,.0f",b.getDailyRate()) %></p>
          </div>
        </div>

        <!-- Payment details -->
        <div class="bg-gradient-to-r from-brand-50 to-emerald-50 rounded-2xl p-5 border border-brand-100 mb-5">
          <div class="flex items-center justify-between mb-3">
            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">Payment Details</p>
          </div>
          <div class="flex items-center gap-3 mb-3">
            <div class="w-10 h-7 bg-white rounded border border-slate-200 flex items-center justify-center text-sm">
              <i class="bi <%= p.getCardIcon() %> <%= p.getCardColor() %>"></i>
            </div>
            <div>
              <p class="font-bold text-sm text-ink-900"><%= p.getCardType() %> <%= p.getCardMasked() %></p>
              <p class="text-xs text-slate-400"><%= p.getCardHolder() %> · Paid <%= p.getPaidAt() %></p>
            </div>
          </div>
          <div class="flex items-center justify-between pt-3 border-t border-brand-100">
            <span class="font-bold text-slate-700">Amount Charged</span>
            <span class="text-2xl font-extrabold text-emerald-600">LKR <%= String.format("%,.0f", p.getAmount()) %></span>
          </div>
        </div>

        <!-- What happens next -->
        <div class="bg-amber-50 rounded-2xl p-4 border border-amber-100 mb-6">
          <p class="text-xs font-bold uppercase tracking-wider text-amber-600 mb-3 flex items-center gap-1.5">
            <i class="bi bi-info-circle-fill"></i> What Happens Next
          </p>
          <div class="space-y-2">
            <div class="flex items-start gap-2 text-sm text-slate-600">
              <i class="bi bi-1-circle-fill text-amber-500 shrink-0 mt-0.5"></i>
              <span>Your booking is <strong>confirmed</strong>. Present your Booking ID <strong><%= b.getBookingId() %></strong> at pickup.</span>
            </div>
            <div class="flex items-start gap-2 text-sm text-slate-600">
              <i class="bi bi-2-circle-fill text-amber-500 shrink-0 mt-0.5"></i>
              <span>Bring a valid <strong>National ID or Passport</strong> and your driver's license.</span>
            </div>
            <div class="flex items-start gap-2 text-sm text-slate-600">
              <i class="bi bi-3-circle-fill text-amber-500 shrink-0 mt-0.5"></i>
              <span>Need help? Use the <strong>live chat</strong> or contact us anytime.</span>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex flex-col sm:flex-row gap-3">
          <a href="${pageContext.request.contextPath}/booking?action=my"
             class="flex-1 text-center bg-brand-600 hover:bg-brand-700 text-white font-bold py-3.5 px-6 rounded-xl shadow-btn transition flex items-center justify-center gap-2">
            <i class="bi bi-calendar-check-fill"></i> My Bookings
          </a>
          <a href="${pageContext.request.contextPath}/vehicles?action=browse"
             class="flex-1 text-center bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 font-bold py-3.5 px-6 rounded-xl transition flex items-center justify-center gap-2">
            <i class="bi bi-search"></i> Browse More
          </a>
          <button onclick="window.print()"
                  class="flex-1 text-center bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 font-bold py-3.5 px-6 rounded-xl transition flex items-center justify-center gap-2">
            <i class="bi bi-printer"></i> Print
          </button>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
// Confetti
(function() {
  var colors = ['#0ea5e9','#10b981','#f59e0b','#8b5cf6','#ef4444','#06b6d4'];
  var container = document.getElementById('confettiContainer');
  for (var i = 0; i < 60; i++) {
    (function(i) {
      var el = document.createElement('div');
      el.className = 'confetti-piece';
      el.style.left = Math.random() * 100 + 'vw';
      el.style.top  = -10 + 'px';
      el.style.background = colors[Math.floor(Math.random() * colors.length)];
      el.style.borderRadius = Math.random() > 0.5 ? '50%' : '2px';
      el.style.animationDuration = (Math.random() * 3 + 2) + 's';
      el.style.animationDelay    = (Math.random() * 2) + 's';
      el.style.width  = (Math.random() * 8 + 6) + 'px';
      el.style.height = (Math.random() * 8 + 6) + 'px';
      container.appendChild(el);
      setTimeout(function() { el.remove(); }, 6000);
    })(i);
  }
})();
</script>

<%@ include file="footer.jspf" %>
