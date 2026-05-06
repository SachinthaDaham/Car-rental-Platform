<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.User" %>
<%
    request.setAttribute("pageTitle", "My Dashboard — DriveLanka");
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/auth?action=login");
        return;
    }
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen">

  <!-- Hero banner -->
  <div class="bg-gradient-to-br from-brand-700 to-brand-900 text-white pb-28 pt-10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6">
      <div class="flex items-center gap-5">
        <div class="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center text-2xl font-extrabold border-2 border-white/30 shrink-0">
          <%= user.getName().substring(0, 1).toUpperCase() %>
        </div>
        <div>
          <p class="text-brand-200 text-sm font-semibold uppercase tracking-wider">Customer Dashboard</p>
          <h1 class="text-3xl font-extrabold tracking-tight mt-0.5">Welcome back, <%= user.getName().split(" ")[0] %>!</h1>
          <p class="text-brand-100 mt-1 text-sm">Explore our fleet, calculate rental costs, and manage your account.</p>
        </div>
      </div>
    </div>
  </div>

  <div class="max-w-7xl mx-auto px-4 sm:px-6 -mt-20">
    <div class="grid md:grid-cols-3 gap-6">

      <!-- Profile card -->
      <div class="bg-white rounded-2xl shadow-card p-6 border border-slate-100">
        <h3 class="font-bold text-base text-ink-900 border-b border-slate-100 pb-3 mb-4 flex items-center gap-2">
          <i class="bi bi-person-circle text-brand-500"></i> Profile Details
        </h3>
        <div class="space-y-4">
          <div>
            <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Full Name</p>
            <p class="font-semibold text-slate-800 mt-0.5"><%= user.getName() %></p>
          </div>
          <div>
            <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Username</p>
            <p class="font-semibold text-slate-800 mt-0.5 font-mono">@<%= user.getUsername() %></p>
          </div>
          <div>
            <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Account Type</p>
            <span class="inline-flex items-center gap-1 mt-1 bg-brand-50 text-brand-700 text-[10px] font-bold uppercase px-2.5 py-1 rounded-full">
              <i class="bi bi-person-check-fill"></i> <%= user.getRole() %>
            </span>
          </div>
          <div>
            <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Member Since</p>
            <p class="font-semibold text-slate-800 mt-0.5">2025</p>
          </div>
        </div>
        <div class="mt-6 pt-4 border-t border-slate-100 space-y-2">
          <a href="${pageContext.request.contextPath}/vehicles?action=browse"
             class="flex items-center gap-2 text-sm font-semibold text-brand-600 hover:bg-brand-50 px-3 py-2 rounded-lg transition">
            <i class="bi bi-search"></i> Browse Fleet
          </a>
          <a href="${pageContext.request.contextPath}/auth?action=logout"
             class="flex items-center gap-2 text-sm font-semibold text-rose-500 hover:bg-rose-50 px-3 py-2 rounded-lg transition">
            <i class="bi bi-box-arrow-right"></i> Sign Out
          </a>
        </div>
      </div>

      <!-- Right area -->
      <div class="md:col-span-2 space-y-6">

        <!-- Quick stats -->
        <div class="grid grid-cols-3 gap-4">
          <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 text-center">
            <p class="text-2xl font-extrabold text-brand-600">0</p>
            <p class="text-xs text-slate-500 font-semibold mt-1">Active Rentals</p>
          </div>
          <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 text-center">
            <p class="text-2xl font-extrabold text-emerald-600">0</p>
            <p class="text-xs text-slate-500 font-semibold mt-1">Completed</p>
          </div>
          <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 text-center">
            <p class="text-2xl font-extrabold text-slate-700">LKR 0</p>
            <p class="text-xs text-slate-500 font-semibold mt-1">Total Spent</p>
          </div>
        </div>

        <!-- Rental cost estimator widget -->
        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <h3 class="font-bold text-base text-ink-900 mb-4 flex items-center gap-2">
            <i class="bi bi-calculator-fill text-brand-500"></i> Quick Cost Estimator
          </h3>
          <p class="text-sm text-slate-500 mb-4">Estimate rental costs based on vehicle type and duration before you browse.</p>
          <div class="grid sm:grid-cols-3 gap-4 mb-4">
            <div>
              <label class="block text-xs font-semibold text-slate-600 mb-1.5">Vehicle Type</label>
              <select id="estType" class="w-full px-3 py-2.5 border border-slate-200 rounded-xl bg-white text-sm outline-none focus:ring-2 focus:ring-brand-500">
                <option value="Car">Car</option>
                <option value="Bike">Bike</option>
                <option value="Van">Van</option>
              </select>
            </div>
            <div>
              <label class="block text-xs font-semibold text-slate-600 mb-1.5">Daily Rate (LKR)</label>
              <input type="number" id="estRate" value="5000" min="0"
                     class="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-brand-500">
            </div>
            <div>
              <label class="block text-xs font-semibold text-slate-600 mb-1.5">Number of Days</label>
              <input type="number" id="estDays" value="3" min="1"
                     class="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-brand-500">
            </div>
          </div>
          <div id="estResult" class="bg-gradient-to-r from-brand-50 to-slate-50 rounded-xl p-4 border border-brand-100">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-xs text-slate-400 uppercase font-semibold">Estimated Total</p>
                <p id="estTotal" class="text-2xl font-extrabold text-brand-700">LKR 15,000</p>
              </div>
              <div class="text-right">
                <p class="text-xs text-slate-400 uppercase font-semibold">Pricing Note</p>
                <p id="estNote" class="text-sm text-slate-600 font-medium">3 days · LKR 5,000/day</p>
              </div>
            </div>
          </div>
          <p class="text-xs text-slate-400 mt-3">
            <i class="bi bi-info-circle"></i>
            Cars: 15% weekly discount · Bikes: 10% discount + 5% insurance >5 days · Vans: 20% discount + 10% insurance >3 days
          </p>
        </div>

        <!-- CTA -->
        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 flex flex-col sm:flex-row items-center gap-5">
          <div class="w-14 h-14 rounded-2xl bg-brand-50 flex items-center justify-center text-brand-500 text-2xl shrink-0">
            <i class="bi bi-car-front-fill"></i>
          </div>
          <div class="flex-1 text-center sm:text-left">
            <h3 class="font-bold text-ink-900">Ready to hit the road?</h3>
            <p class="text-sm text-slate-500 mt-0.5">Browse our full fleet of Cars, Bikes, and Vans available across Sri Lanka.</p>
          </div>
          <a href="${pageContext.request.contextPath}/vehicles?action=browse"
             class="shrink-0 bg-brand-600 hover:bg-brand-700 text-white font-bold py-3 px-7 rounded-xl shadow-btn transition flex items-center gap-2">
            <i class="bi bi-search"></i> Browse Fleet
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
  var typeEl  = document.getElementById('estType');
  var rateEl  = document.getElementById('estRate');
  var daysEl  = document.getElementById('estDays');
  var totalEl = document.getElementById('estTotal');
  var noteEl  = document.getElementById('estNote');

  function estimate() {
    var type = typeEl.value;
    var rate = parseFloat(rateEl.value) || 0;
    var days = parseInt(daysEl.value) || 1;
    if (days < 1) days = 1;

    var weeks = Math.floor(days / 7);
    var rem   = days % 7;
    var weeklyMultiplier = type === 'Car' ? 0.85 : type === 'Bike' ? 0.90 : 0.80;
    var weeklyRate = rate * 7 * weeklyMultiplier;
    var base = weeks * weeklyRate + rem * rate;

    var surcharge = '';
    if (type === 'Bike' && days > 5)  { base *= 1.05; surcharge = ' + 5% insurance'; }
    if (type === 'Van'  && days > 3)  { base *= 1.10; surcharge = ' + 10% insurance'; }

    totalEl.textContent = 'LKR ' + Math.round(base).toLocaleString('en-US');
    var discountPct = type === 'Car' ? '15%' : type === 'Bike' ? '10%' : '20%';
    var note = days + ' day(s)';
    if (weeks > 0) note += ' · ' + discountPct + ' weekly discount';
    if (surcharge) note += surcharge;
    noteEl.textContent = note;
  }

  typeEl.addEventListener('change', estimate);
  rateEl.addEventListener('input', estimate);
  daysEl.addEventListener('input', estimate);
  estimate();
})();
</script>

<%@ include file="footer.jspf" %>
