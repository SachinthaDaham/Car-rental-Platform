<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.Vehicle" %>
<%
    Vehicle v = (Vehicle) request.getAttribute("vehicle");
    if (v == null) {
        response.sendRedirect(request.getContextPath() + "/vehicles?action=browse");
        return;
    }
    request.setAttribute("pageTitle", "Book " + v.getName() + " — DriveLanka");
    String today          = (String) request.getAttribute("today");
    String maxDate        = (String) request.getAttribute("maxDate");
    String errMsg         = (String) request.getAttribute("errorMsg");
    String bookedRangesJson = (String) request.getAttribute("bookedRangesJson");
    if (bookedRangesJson == null) bookedRangesJson = "[]";
%>
<%@ include file="header.jspf" %>

<div class="max-w-5xl mx-auto px-4 sm:px-6 py-8">

  <!-- Breadcrumbs -->
  <nav class="text-sm text-slate-500 mb-6 flex items-center gap-1 flex-wrap">
    <a href="${pageContext.request.contextPath}/" class="hover:text-brand-600">Home</a>
    <i class="bi bi-chevron-right text-xs text-slate-300"></i>
    <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="hover:text-brand-600">Browse Fleet</a>
    <i class="bi bi-chevron-right text-xs text-slate-300"></i>
    <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= v.getId() %>" class="hover:text-brand-600"><%= v.getName() %></a>
    <i class="bi bi-chevron-right text-xs text-slate-300"></i>
    <span class="text-ink-900 font-medium">Book</span>
  </nav>

  <div class="grid lg:grid-cols-5 gap-8">

    <!-- LEFT: Vehicle summary -->
    <div class="lg:col-span-2">
      <div class="bg-white rounded-2xl shadow-card border border-slate-100 overflow-hidden sticky top-24">
        <div class="aspect-[4/3] overflow-hidden bg-slate-100">
          <img src="<%= v.getImageUrl() %>"
               onerror="this.src='https://placehold.co/600x400/e0f2fe/0369a1?text=<%= v.getType() %>'"
               class="w-full h-full object-cover" alt="<%= v.getName() %>">
        </div>
        <div class="p-5">
          <div class="flex items-start gap-2 mb-1">
            <span class="inline-flex items-center gap-1 bg-brand-50 text-brand-700 text-xs font-bold uppercase px-2 py-0.5 rounded-full">
              <i class="bi <%= v.getIconClass() %>"></i> <%= v.getType() %>
            </span>
          </div>
          <h2 class="text-xl font-extrabold text-ink-900 mt-1"><%= v.getName() %></h2>
          <p class="text-xs text-slate-400 mt-0.5 flex items-center gap-1"><i class="bi bi-geo-alt"></i> <%= v.getLocation() %></p>
          <div class="mt-4 pt-4 border-t border-slate-100 space-y-2 text-sm">
            <div class="flex justify-between">
              <span class="text-slate-500">Daily Rate</span>
              <span class="font-bold text-brand-700">LKR <%= String.format("%,.0f", v.getDailyRate()) %></span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Weekly Rate</span>
              <span class="font-bold text-emerald-600">LKR <%= String.format("%,.0f", v.weeklyRate()) %></span>
            </div>
            <div class="flex justify-between text-xs text-slate-400 italic">
              <span>Pricing includes all applicable discounts</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- RIGHT: Booking form -->
    <div class="lg:col-span-3">
      <div class="mb-5">
        <h1 class="text-3xl font-extrabold text-ink-900">Reserve Your Vehicle</h1>
        <p class="text-slate-500 mt-1">Select your rental dates and confirm your booking below.</p>
      </div>

      <% if (errMsg != null) { %>
        <div class="flex items-center gap-3 bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl mb-5 text-sm font-medium">
          <i class="bi bi-exclamation-circle-fill text-rose-500"></i> <%= errMsg %>
        </div>
      <% } %>

      <form id="bookingForm" action="${pageContext.request.contextPath}/booking" method="post" class="space-y-5">
        <input type="hidden" name="action" value="create">
        <input type="hidden" name="vehicleId" value="<%= v.getId() %>">

        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-5">
          <h3 class="font-bold text-base text-ink-900 flex items-center gap-2">
            <span class="w-6 h-6 rounded-full bg-brand-600 text-white text-xs flex items-center justify-center font-bold">1</span>
            Rental Period
          </h3>

          <div class="grid sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">
                <i class="bi bi-calendar3 text-brand-500 mr-1"></i>Pick-up Date <span class="text-rose-500">*</span>
              </label>
              <input type="date" id="startDate" name="startDate"
                     min="<%= today %>" max="<%= maxDate %>" required
                     class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
            </div>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">
                <i class="bi bi-calendar3-range text-brand-500 mr-1"></i>Return Date <span class="text-rose-500">*</span>
              </label>
              <input type="date" id="endDate" name="endDate"
                     min="<%= today %>" max="<%= maxDate %>" required
                     onclick="try{this.showPicker();}catch(e){}"
                     class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
            </div>
          </div>

          <!-- Quick duration selectors -->
          <div>
            <p class="text-xs font-semibold text-slate-400 mb-2">Quick select duration:</p>
            <div class="flex gap-2 flex-wrap">
              <% int[] durations = {1, 3, 7, 14, 30}; %>
              <% for (int d : durations) { %>
                <button type="button" class="duration-btn px-3 py-1.5 text-xs font-bold border border-slate-200 bg-slate-50 rounded-lg hover:border-brand-400 hover:text-brand-700 hover:bg-brand-50 transition" data-days="<%= d %>">
                  <%= d %> day<%= d > 1 ? "s" : "" %>
                </button>
              <% } %>
            </div>
          </div>

          <!-- Date conflict warning -->
          <div id="dateConflictAlert" class="hidden flex items-start gap-3 bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl text-sm font-medium">
            <i class="bi bi-calendar-x-fill text-rose-500 shrink-0 mt-0.5"></i>
            <div>
              <p class="font-bold">Date Conflict</p>
              <p id="dateConflictMsg" class="mt-0.5 font-normal">Those dates overlap with an existing booking.</p>
            </div>
          </div>

          <!-- Booked periods for this vehicle -->
          <% if (!bookedRangesJson.equals("[]")) { %>
          <div class="bg-amber-50 border border-amber-100 rounded-xl p-4">
            <p class="text-xs font-bold text-amber-800 flex items-center gap-1.5 mb-2">
              <i class="bi bi-calendar-week text-amber-600"></i> Already Booked Periods
            </p>
            <div id="bookedRangesList" class="space-y-1.5"></div>
            <p class="text-[11px] text-amber-600 mt-2">You cannot select dates that overlap with these periods.</p>
          </div>
          <% } %>
        </div>

        <!-- Cost Summary -->
        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <h3 class="font-bold text-base text-ink-900 flex items-center gap-2 mb-5">
            <span class="w-6 h-6 rounded-full bg-brand-600 text-white text-xs flex items-center justify-center font-bold">2</span>
            Cost Summary
          </h3>
          <div id="costSummary" class="bg-gradient-to-br from-brand-50 to-slate-50 rounded-xl p-4 border border-brand-100">
            <div class="flex items-center justify-between mb-3">
              <div>
                <p class="text-xs text-slate-400 uppercase font-semibold">Estimated Total</p>
                <p id="costTotal" class="text-2xl font-extrabold text-brand-700">—</p>
              </div>
              <div class="text-right">
                <p class="text-xs text-slate-400 uppercase font-semibold">Duration</p>
                <p id="costDays" class="text-sm font-bold text-ink-900">Select dates</p>
              </div>
            </div>
            <div id="costBreakdown" class="text-xs text-slate-500 border-t border-brand-100 pt-3 space-y-1 hidden">
              <div class="flex justify-between"><span>Daily Rate</span><span id="brDaily" class="font-semibold">—</span></div>
              <div class="flex justify-between"><span>Rental Days</span><span id="brDays" class="font-semibold">—</span></div>
              <div id="brDiscountRow" class="flex justify-between text-emerald-600 hidden"><span id="brDiscountLabel">Discount</span><span id="brDiscount">—</span></div>
              <div class="flex justify-between font-bold border-t border-slate-200 pt-1 mt-1 text-ink-900"><span>Total</span><span id="brTotal">—</span></div>
            </div>
          </div>
          <p class="text-[11px] text-slate-400 mt-3 flex items-center gap-1">
            <i class="bi bi-info-circle"></i>
            Final cost is calculated based on type-specific pricing rules. No hidden fees.
          </p>
        </div>

        <!-- Booking confirmation -->
        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <h3 class="font-bold text-base text-ink-900 flex items-center gap-2 mb-4">
            <span class="w-6 h-6 rounded-full bg-brand-600 text-white text-xs flex items-center justify-center font-bold">3</span>
            Confirm Booking
          </h3>

          <div class="bg-amber-50 border border-amber-100 rounded-xl p-4 mb-5 text-sm">
            <div class="flex items-start gap-3">
              <i class="bi bi-info-circle-fill text-amber-500 mt-0.5"></i>
              <div>
                <p class="font-semibold text-amber-800">What happens next?</p>
                <p class="text-amber-700 mt-1">Your booking will be marked <strong>Pending</strong> until our team reviews and confirms it. You'll see status updates in My Bookings.</p>
              </div>
            </div>
          </div>

          <div class="flex items-center justify-between pt-2">
            <a href="${pageContext.request.contextPath}/vehicles?action=details&id=<%= v.getId() %>"
               class="text-sm font-semibold text-slate-500 hover:text-slate-700 transition">
              <i class="bi bi-arrow-left mr-1"></i> Back to Vehicle
            </a>
            <button type="submit" id="submitBtn"
                    class="inline-flex items-center gap-2 bg-brand-600 hover:bg-brand-700 text-white font-bold px-8 py-3 rounded-xl shadow-btn transition">
              <i class="bi bi-calendar-check-fill"></i>
              <span id="btnText">Confirm Booking</span>
              <span id="btnSpinner" class="hidden w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
(function() {
  var startEl   = document.getElementById('startDate');
  var endEl     = document.getElementById('endDate');
  var submitBtn = document.getElementById('submitBtn');
  var dailyRate = <%= v.getDailyRate() %>;
  var vehicleId = '<%= v.getId() %>';
  var ctx       = '${pageContext.request.contextPath}';

  // Booked date ranges from server (exclusive end dates)
  var BOOKED_RANGES = <%= bookedRangesJson %>;

  // Render booked periods list
  var listEl = document.getElementById('bookedRangesList');
  if (listEl && BOOKED_RANGES.length) {
    BOOKED_RANGES.forEach(function(r) {
      var row = document.createElement('div');
      row.className = 'flex items-center gap-2 text-xs text-amber-700';
      row.innerHTML =
        '<i class="bi bi-dash-circle-fill text-rose-400 shrink-0"></i>' +
        '<span class="font-semibold">' + formatDate(r.start) + '</span>' +
        '<span class="text-amber-500">→</span>' +
        '<span class="font-semibold">' + formatDate(r.end) + '</span>' +
        '<span class="text-amber-500 text-[10px]">(unavailable)</span>';
      listEl.appendChild(row);
    });
  }

  function formatDate(iso) {
    var d = new Date(iso + 'T00:00:00');
    return d.toLocaleDateString('en-US', {month: 'short', day: 'numeric', year: 'numeric'});
  }

  function hasConflict(startVal, endVal) {
    if (!startVal || !endVal) return false;
    var ns = new Date(startVal + 'T00:00:00');
    var ne = new Date(endVal   + 'T00:00:00');
    for (var i = 0; i < BOOKED_RANGES.length; i++) {
      var bs = new Date(BOOKED_RANGES[i].start + 'T00:00:00');
      var be = new Date(BOOKED_RANGES[i].end   + 'T00:00:00');
      if (ns < be && bs < ne) return true;
    }
    return false;
  }

  function checkConflictAndUpdate() {
    var s = startEl.value, e = endEl.value;
    var alertEl = document.getElementById('dateConflictAlert');
    var msgEl   = document.getElementById('dateConflictMsg');
    if (s && e && hasConflict(s, e)) {
      // Find which range conflicts
      var ns = new Date(s + 'T00:00:00'), ne = new Date(e + 'T00:00:00');
      var conflictRange = null;
      for (var i = 0; i < BOOKED_RANGES.length; i++) {
        var bs = new Date(BOOKED_RANGES[i].start + 'T00:00:00');
        var be = new Date(BOOKED_RANGES[i].end   + 'T00:00:00');
        if (ns < be && bs < ne) { conflictRange = BOOKED_RANGES[i]; break; }
      }
      alertEl.classList.remove('hidden');
      if (conflictRange) {
        msgEl.textContent = 'Conflicts with booking ' + formatDate(conflictRange.start) + ' → ' + formatDate(conflictRange.end) + '. Please pick other dates.';
      }
      submitBtn.disabled = true;
      submitBtn.classList.add('opacity-50', 'cursor-not-allowed');
    } else {
      alertEl.classList.add('hidden');
      if (s && e) {
        submitBtn.disabled = false;
        submitBtn.classList.remove('opacity-50', 'cursor-not-allowed');
      }
    }
  }

  function refreshCost() {
    var s = startEl.value, e = endEl.value;
    if (!s || !e || e <= s) {
      document.getElementById('costTotal').textContent = '—';
      document.getElementById('costDays').textContent  = 'Select dates';
      document.getElementById('costBreakdown').classList.add('hidden');
      return;
    }
    var days = Math.round((new Date(e) - new Date(s)) / 86400000);
    if (days < 1) return;

    fetch(ctx + '/vehicles?action=calculate&id=' + vehicleId + '&days=' + days)
      .then(function(r) { return r.json(); })
      .then(function(d) {
        document.getElementById('costTotal').textContent = 'LKR ' + d.cost.toLocaleString('en-US', {maximumFractionDigits: 0});
        document.getElementById('costDays').textContent  = days + ' day' + (days > 1 ? 's' : '');
        document.getElementById('brDaily').textContent   = 'LKR ' + dailyRate.toLocaleString('en-US', {maximumFractionDigits: 0});
        document.getElementById('brDays').textContent    = days;
        document.getElementById('brTotal').textContent   = 'LKR ' + d.cost.toLocaleString('en-US', {maximumFractionDigits: 0});
        document.getElementById('costBreakdown').classList.remove('hidden');
        if (d.summary && (d.summary.includes('discount') || d.summary.includes('insurance'))) {
          document.getElementById('brDiscountRow').classList.remove('hidden');
          document.getElementById('brDiscountLabel').textContent = d.summary.split('·').slice(1).join('·').trim() || 'Pricing applied';
        }
      });
  }

  startEl.addEventListener('change', function() {
    // Set end min to day AFTER start date
    var nextDay = new Date(this.value + 'T00:00:00');
    nextDay.setDate(nextDay.getDate() + 1);
    var nextDayStr = nextDay.toISOString().split('T')[0];
    endEl.min = nextDayStr;
    // Clear end date if it's no longer valid
    if (endEl.value && endEl.value <= this.value) endEl.value = '';
    checkConflictAndUpdate();
    refreshCost();
    // Auto-focus end date so user can pick it immediately
    endEl.focus();
    try { endEl.showPicker(); } catch(e) {}
  });
  endEl.addEventListener('change', function() {
    checkConflictAndUpdate();
    refreshCost();
  });

  // Duration quick-select
  document.querySelectorAll('.duration-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var days = parseInt(this.dataset.days);
      var base = startEl.value ? new Date(startEl.value + 'T00:00:00') : new Date();
      if (!startEl.value) {
        startEl.value = base.toISOString().split('T')[0];
      }
      var end = new Date(startEl.value + 'T00:00:00');
      end.setDate(end.getDate() + days);
      endEl.value = end.toISOString().split('T')[0];
      endEl.min = startEl.value;
      checkConflictAndUpdate();
      refreshCost();
    });
  });

  // Block submit if conflict
  document.getElementById('bookingForm').addEventListener('submit', function(e) {
    if (hasConflict(startEl.value, endEl.value)) {
      e.preventDefault();
      checkConflictAndUpdate();
      return false;
    }
    document.getElementById('btnText').textContent = 'Processing…';
    document.getElementById('btnSpinner').classList.remove('hidden');
    submitBtn.disabled = true;
  });
})();
</script>

<%@ include file="footer.jspf" %>
