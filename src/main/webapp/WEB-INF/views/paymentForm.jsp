<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.Booking, com.vrp.model.User" %>
<%
    Booking b = (Booking) request.getAttribute("booking");
    if (b == null) { response.sendRedirect(request.getContextPath() + "/booking?action=my"); return; }
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<%@ include file="header.jspf" %>

<style>
.card-3d { perspective: 1000px; }
.card-inner { position:relative; width:100%; height:200px; transition: transform 0.7s; transform-style: preserve-3d; }
.card-inner.flipped { transform: rotateY(180deg); }
.card-front, .card-back { position:absolute; width:100%; height:100%; backface-visibility:hidden; border-radius:16px; padding:24px; }
.card-back { transform: rotateY(180deg); }
.input-card { transition: border-color .2s, box-shadow .2s; }
.input-card:focus { border-color: #0284c7; box-shadow: 0 0 0 3px rgba(2,132,199,.15); outline:none; }
@keyframes fadeSlideUp { from { opacity:0; transform:translateY(20px); } to { opacity:1; transform:translateY(0); } }
.fade-in { animation: fadeSlideUp .4s ease both; }
.card-chip { width:44px; height:32px; background:linear-gradient(135deg,#f5d060,#e3a800); border-radius:6px; }
</style>

<div class="bg-gradient-to-br from-slate-900 via-brand-900 to-slate-900 min-h-screen py-10">
  <div class="max-w-5xl mx-auto px-4 sm:px-6">

    <!-- Progress steps -->
    <div class="flex items-center justify-center gap-2 mb-8 fade-in">
      <div class="flex items-center gap-2">
        <span class="w-8 h-8 rounded-full bg-white/20 text-white text-xs font-bold flex items-center justify-center"><i class="bi bi-check-lg"></i></span>
        <span class="text-white/60 text-sm font-medium hidden sm:inline">Choose Vehicle</span>
      </div>
      <div class="w-12 h-px bg-white/20"></div>
      <div class="flex items-center gap-2">
        <span class="w-8 h-8 rounded-full bg-white/20 text-white text-xs font-bold flex items-center justify-center"><i class="bi bi-check-lg"></i></span>
        <span class="text-white/60 text-sm font-medium hidden sm:inline">Book Dates</span>
      </div>
      <div class="w-12 h-px bg-white/20"></div>
      <div class="flex items-center gap-2">
        <span class="w-8 h-8 rounded-full bg-brand-500 text-white text-xs font-bold flex items-center justify-center">3</span>
        <span class="text-white text-sm font-bold hidden sm:inline">Secure Payment</span>
      </div>
    </div>

    <div class="grid lg:grid-cols-5 gap-6">

      <!-- LEFT: Order summary + card preview -->
      <div class="lg:col-span-2 space-y-5 fade-in">

        <!-- Booking summary -->
        <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-5 text-white">
          <h3 class="font-bold text-sm uppercase tracking-wider text-white/60 mb-4 flex items-center gap-2">
            <i class="bi bi-receipt"></i> Order Summary
          </h3>
          <div class="flex items-center gap-3 mb-4 pb-4 border-b border-white/10">
            <div class="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center shrink-0">
              <i class="bi bi-<%= "Car".equals(b.getVehicleType()) ? "car-front-fill" : "Bike".equals(b.getVehicleType()) ? "bicycle" : "truck" %> text-brand-300"></i>
            </div>
            <div>
              <p class="font-bold"><%= b.getVehicleName() %></p>
              <p class="text-xs text-white/50"><%= b.getVehicleId() %> · <%= b.getVehicleType() %></p>
            </div>
          </div>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between"><span class="text-white/60">Booking ID</span><span class="font-mono font-bold"><%= b.getBookingId() %></span></div>
            <div class="flex justify-between"><span class="text-white/60">Pick-up</span><span class="font-semibold"><%= b.getStartDate() %></span></div>
            <div class="flex justify-between"><span class="text-white/60">Return</span><span class="font-semibold"><%= b.getEndDate() %></span></div>
            <div class="flex justify-between"><span class="text-white/60">Duration</span><span class="font-semibold"><%= b.getDays() %> day<%= b.getDays()!=1?"s":"" %></span></div>
            <div class="flex justify-between"><span class="text-white/60">Daily Rate</span><span class="font-semibold">LKR <%= String.format("%,.0f", b.getDailyRate()) %></span></div>
          </div>
          <div class="mt-4 pt-4 border-t border-white/20 flex justify-between items-center">
            <span class="font-bold text-white/80">Total Due</span>
            <span class="text-2xl font-extrabold text-brand-300">LKR <%= String.format("%,.0f", b.getTotalCost()) %></span>
          </div>
        </div>

        <!-- Live 3D card preview -->
        <div class="card-3d">
          <div class="card-inner" id="cardInner">
            <!-- Front -->
            <div class="card-front bg-gradient-to-br from-brand-700 to-brand-900 shadow-2xl text-white flex flex-col justify-between">
              <div class="flex items-center justify-between">
                <div class="card-chip"></div>
                <div id="cardTypeIcon" class="text-2xl opacity-80">
                  <i class="bi bi-credit-card-fill"></i>
                </div>
              </div>
              <div>
                <p id="cardNumDisplay" class="font-mono text-lg tracking-[4px] mb-3">•••• •••• •••• ••••</p>
                <div class="flex justify-between items-end">
                  <div>
                    <p class="text-[9px] text-white/50 uppercase tracking-wider mb-0.5">Cardholder</p>
                    <p id="cardNameDisplay" class="font-bold text-sm uppercase tracking-wide truncate max-w-[160px]">YOUR NAME</p>
                  </div>
                  <div class="text-right">
                    <p class="text-[9px] text-white/50 uppercase tracking-wider mb-0.5">Expires</p>
                    <p id="cardExpDisplay" class="font-bold text-sm">MM/YY</p>
                  </div>
                </div>
              </div>
            </div>
            <!-- Back -->
            <div class="card-back bg-gradient-to-br from-slate-700 to-slate-900 text-white flex flex-col justify-center">
              <div class="w-full h-10 bg-black/40 mb-6 -mx-6" style="width:calc(100% + 48px); margin-left:-24px;"></div>
              <div class="flex items-center gap-3">
                <div class="flex-1 h-9 bg-white/20 rounded"></div>
                <div class="bg-white rounded px-3 py-1.5">
                  <p id="cvvDisplay" class="text-slate-800 font-mono font-bold tracking-widest text-sm">•••</p>
                </div>
              </div>
              <p class="text-[10px] text-white/40 mt-4 text-center">CVV / CVC Security Code</p>
            </div>
          </div>
        </div>

        <!-- Test cards helper -->
        <div class="bg-amber-500/10 border border-amber-400/30 rounded-2xl p-4">
          <p class="text-amber-300 text-xs font-bold uppercase tracking-wider mb-3 flex items-center gap-1.5">
            <i class="bi bi-info-circle-fill"></i> Test Card Numbers
          </p>
          <div class="space-y-2">
            <% String[][] testCards = {
              {"Visa (Success)","4111 1111 1111 1111","Any future date","Any 3 digits"},
              {"Mastercard","5500 0000 0000 0004","Any future date","Any 3 digits"},
              {"Amex","3714 496353 98431","Any future date","Any 4 digits"},
              {"Visa (Decline)","4000 0000 0000 0002","Any future date","Any 3 digits"}
            }; %>
            <% for (String[] tc : testCards) { %>
              <button type="button" onclick="fillTestCard('<%= tc[1] %>','Test User','12/28','123')"
                      class="w-full text-left p-2 rounded-lg bg-white/5 hover:bg-white/10 transition border border-white/10 hover:border-amber-400/40">
                <p class="text-white text-xs font-semibold"><%= tc[0] %></p>
                <p class="text-amber-300 font-mono text-xs mt-0.5"><%= tc[1] %></p>
              </button>
            <% } %>
          </div>
        </div>
      </div>

      <!-- RIGHT: Payment form -->
      <div class="lg:col-span-3 fade-in" style="animation-delay:.1s">
        <div class="bg-white rounded-3xl shadow-2xl p-7 sm:p-9">
          <div class="flex items-center gap-3 mb-6">
            <div class="w-10 h-10 rounded-xl bg-emerald-100 flex items-center justify-center">
              <i class="bi bi-shield-lock-fill text-emerald-600"></i>
            </div>
            <div>
              <h2 class="text-xl font-extrabold text-ink-900">Secure Payment</h2>
              <p class="text-xs text-slate-400">256-bit SSL encrypted · PCI DSS compliant</p>
            </div>
          </div>

          <% if (errorMsg != null) { %>
            <div class="flex items-start gap-3 bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl mb-5 text-sm font-medium">
              <i class="bi bi-x-circle-fill shrink-0 mt-0.5"></i>
              <span><%= errorMsg %></span>
            </div>
          <% } %>

          <form method="POST" action="${pageContext.request.contextPath}/payment" id="payForm" onsubmit="return handleSubmit(event)">
            <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">

            <!-- Card Number -->
            <div class="mb-5">
              <label class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2">Card Number</label>
              <div class="relative">
                <input type="text" name="cardNumber" id="cardNumber" maxlength="19" placeholder="0000 0000 0000 0000"
                       autocomplete="cc-number" inputmode="numeric"
                       class="input-card w-full pl-4 pr-14 py-4 border-2 border-slate-200 rounded-xl font-mono text-lg text-ink-900 bg-white"
                       required>
                <span id="cardTypeDisplay" class="absolute right-4 top-1/2 -translate-y-1/2 text-2xl text-slate-300">
                  <i class="bi bi-credit-card-fill"></i>
                </span>
              </div>
              <p id="luhnError" class="text-rose-500 text-xs mt-1 hidden">Invalid card number</p>
            </div>

            <!-- Cardholder name -->
            <div class="mb-5">
              <label class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2">Cardholder Name</label>
              <input type="text" name="cardHolder" id="cardHolder" placeholder="As printed on card"
                     autocomplete="cc-name"
                     class="input-card w-full px-4 py-4 border-2 border-slate-200 rounded-xl text-ink-900 bg-white uppercase tracking-wide"
                     required>
            </div>

            <!-- Expiry + CVV -->
            <div class="grid grid-cols-2 gap-4 mb-6">
              <div>
                <label class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2">Expiry Date</label>
                <input type="text" name="expiry" id="expiry" placeholder="MM/YY" maxlength="5"
                       autocomplete="cc-exp" inputmode="numeric"
                       class="input-card w-full px-4 py-4 border-2 border-slate-200 rounded-xl font-mono text-ink-900 bg-white"
                       required>
              </div>
              <div>
                <label class="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2">CVV / CVC</label>
                <input type="text" name="cvv" id="cvv" placeholder="•••" maxlength="4"
                       autocomplete="cc-csc" inputmode="numeric"
                       class="input-card w-full px-4 py-4 border-2 border-slate-200 rounded-xl font-mono text-ink-900 bg-white"
                       required>
              </div>
            </div>

            <!-- Security badges -->
            <div class="flex items-center justify-center gap-4 mb-6 py-3 bg-slate-50 rounded-xl border border-slate-100">
              <div class="flex items-center gap-1.5 text-xs text-slate-500 font-medium">
                <i class="bi bi-lock-fill text-emerald-500"></i> SSL Secure
              </div>
              <div class="w-px h-4 bg-slate-200"></div>
              <div class="flex items-center gap-1.5 text-xs text-slate-500 font-medium">
                <i class="bi bi-shield-check-fill text-emerald-500"></i> PCI Compliant
              </div>
              <div class="w-px h-4 bg-slate-200"></div>
              <div class="flex items-center gap-1.5 text-xs text-slate-500 font-medium">
                <i class="bi bi-eye-slash-fill text-emerald-500"></i> Encrypted
              </div>
            </div>

            <!-- Pay button -->
            <button type="submit" id="payBtn"
                    class="w-full bg-gradient-to-r from-brand-600 to-brand-700 hover:from-brand-700 hover:to-brand-800 text-white font-extrabold text-lg py-4 rounded-xl shadow-btn transition flex items-center justify-center gap-3 relative overflow-hidden">
              <i class="bi bi-lock-fill" id="payIcon"></i>
              <span id="payText">Pay LKR <%= String.format("%,.0f", b.getTotalCost()) %></span>
              <svg id="paySpinner" class="hidden animate-spin w-5 h-5" viewBox="0 0 24 24" fill="none">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="white" stroke-width="4"/>
                <path class="opacity-75" fill="white" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
              </svg>
            </button>

            <p class="text-center text-xs text-slate-400 mt-4">
              By paying you agree to our terms. Your card is charged LKR <%= String.format("%,.0f", b.getTotalCost()) %>.
              <a href="${pageContext.request.contextPath}/booking?action=my" class="text-brand-600 hover:underline">Cancel</a>
            </p>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
  var numEl    = document.getElementById('cardNumber');
  var nameEl   = document.getElementById('cardHolder');
  var expEl    = document.getElementById('expiry');
  var cvvEl    = document.getElementById('cvv');
  var inner    = document.getElementById('cardInner');

  var numDisp  = document.getElementById('cardNumDisplay');
  var nameDisp = document.getElementById('cardNameDisplay');
  var expDisp  = document.getElementById('cardExpDisplay');
  var cvvDisp  = document.getElementById('cvvDisplay');
  var typeIcon = document.getElementById('cardTypeDisplay');
  var typeIconCard = document.getElementById('cardTypeIcon');
  var luhnErr  = document.getElementById('luhnError');

  // ── Card type detection ───────────────────────────────────────────────────
  function detectType(n) {
    if (/^4/.test(n)) return { name:'VISA', icon:'bi bi-credit-card-2-front-fill', color:'#1a56db' };
    if (/^5[1-5]|^2[2-7]/.test(n)) return { name:'MC', icon:'bi bi-credit-card-fill', color:'#e02424' };
    if (/^3[47]/.test(n)) return { name:'AMEX', icon:'bi bi-credit-card-2-back-fill', color:'#057a55' };
    if (/^6/.test(n)) return { name:'DISC', icon:'bi bi-credit-card-fill', color:'#ff6b00' };
    return { name:'', icon:'bi bi-credit-card-fill', color:'#94a3b8' };
  }

  // ── Luhn ─────────────────────────────────────────────────────────────────
  function luhn(n) {
    var s = 0, a = false;
    for (var i = n.length - 1; i >= 0; i--) {
      var d = parseInt(n[i]);
      if (a) { d *= 2; if (d > 9) d -= 9; }
      s += d; a = !a;
    }
    return s % 10 === 0;
  }

  // ── Format card number ────────────────────────────────────────────────────
  numEl.addEventListener('input', function() {
    var raw = this.value.replace(/\D/g, '').substring(0, 16);
    var fmt = raw.replace(/(.{4})/g, '$1 ').trim();
    this.value = fmt;

    var disp = fmt || '•••• •••• •••• ••••';
    while (disp.replace(/\s/g,'').length < 16)
      disp = disp.replace(/•+/, function(m){ return m + '•••• '.substring(0,5-fmt.replace(/\s/g,'').length%4||4); }).substring(0,19);
    numDisp.textContent = fmt ? fmt.padEnd(19,'•').replace(/(\d{4})\s?/g,'$1 ').trim() : '•••• •••• •••• ••••';

    var type = detectType(raw);
    typeIcon.innerHTML = '<i class="' + type.icon + '" style="color:' + type.color + '"></i>';
    typeIconCard.innerHTML = '<i class="' + type.icon + '"></i>';

    if (raw.length === 16) {
      var ok = luhn(raw);
      luhnErr.classList.toggle('hidden', ok);
      numEl.style.borderColor = ok ? '' : '#ef4444';
    } else {
      luhnErr.classList.add('hidden');
      numEl.style.borderColor = '';
    }
  });

  // ── Cardholder ────────────────────────────────────────────────────────────
  nameEl.addEventListener('input', function() {
    nameDisp.textContent = this.value.toUpperCase() || 'YOUR NAME';
  });

  // ── Expiry ────────────────────────────────────────────────────────────────
  expEl.addEventListener('input', function() {
    var v = this.value.replace(/\D/g,'');
    if (v.length >= 2) v = v.substring(0,2) + '/' + v.substring(2,4);
    this.value = v;
    expDisp.textContent = this.value || 'MM/YY';
  });

  // ── CVV flip ─────────────────────────────────────────────────────────────
  cvvEl.addEventListener('focus', function() { inner.classList.add('flipped'); });
  cvvEl.addEventListener('blur',  function() { inner.classList.remove('flipped'); });
  cvvEl.addEventListener('input', function() {
    var v = this.value.replace(/\D/g,'').substring(0,4);
    this.value = v;
    cvvDisp.textContent = v ? v.replace(/./g,'•') : '•••';
  });

  // ── Submit handler ────────────────────────────────────────────────────────
  window.handleSubmit = function(e) {
    var btn = document.getElementById('payBtn');
    var txt = document.getElementById('payText');
    var ico = document.getElementById('payIcon');
    var spin= document.getElementById('paySpinner');
    btn.disabled = true;
    btn.classList.add('opacity-80');
    ico.classList.add('hidden');
    spin.classList.remove('hidden');
    txt.textContent = 'Processing…';
    return true;
  };

  // ── Fill test card ─────────────────────────────────────────────────────────
  window.fillTestCard = function(num, name, exp, cvv) {
    numEl.value  = num;  numEl.dispatchEvent(new Event('input'));
    nameEl.value = name; nameEl.dispatchEvent(new Event('input'));
    expEl.value  = exp;  expEl.dispatchEvent(new Event('input'));
    cvvEl.value  = cvv;  cvvEl.dispatchEvent(new Event('input'));
  };
})();
</script>

<%@ include file="footer.jspf" %>
