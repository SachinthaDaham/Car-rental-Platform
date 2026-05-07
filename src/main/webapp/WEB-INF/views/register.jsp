<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setAttribute("pageTitle", "Register — DriveLanka");
    String error = request.getParameter("error");
%>
<%@ include file="header.jspf" %>

<div class="min-h-screen bg-gradient-to-br from-slate-100 via-brand-50 to-slate-100 py-14 flex items-center justify-center px-4">
  <div class="max-w-md w-full">
    <div class="bg-white rounded-3xl shadow-xl border border-slate-100 p-8 md:p-10">

      <div class="text-center mb-8">
        <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-brand-500 to-indigo-600 flex items-center justify-center mx-auto mb-4 shadow-btn">
          <i class="bi bi-person-plus-fill text-white text-2xl"></i>
        </div>
        <h1 class="text-3xl font-extrabold text-ink-900">Create Account</h1>
        <p class="text-slate-500 mt-1">Join DriveLanka and start renting vehicles.</p>
      </div>

      <!-- Error messages -->
      <% if ("exists".equals(error)) { %>
        <div class="flex items-center gap-2 bg-rose-50 text-rose-600 text-sm font-semibold p-3 rounded-xl mb-5 border border-rose-100">
          <i class="bi bi-exclamation-circle-fill"></i> Username already taken. Please choose another.
        </div>
      <% } else if ("weakpass".equals(error)) { %>
        <div class="flex items-center gap-2 bg-amber-50 text-amber-700 text-sm font-semibold p-3 rounded-xl mb-5 border border-amber-100">
          <i class="bi bi-exclamation-triangle-fill"></i> Password must be at least 6 characters.
        </div>
      <% } else if ("baduser".equals(error)) { %>
        <div class="flex items-center gap-2 bg-rose-50 text-rose-600 text-sm font-semibold p-3 rounded-xl mb-5 border border-rose-100">
          <i class="bi bi-exclamation-circle-fill"></i> Username may only contain letters, numbers and underscores.
        </div>
      <% } %>

      <form id="regForm" action="${pageContext.request.contextPath}/auth" method="post" class="space-y-5" novalidate>
        <input type="hidden" name="action" value="register">

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Full Name <span class="text-rose-500">*</span></label>
          <input type="text" name="name" id="nameInput" required placeholder="e.g. Sankalpa Wijesekara"
                 class="w-full px-4 py-3 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow text-sm">
        </div>

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Username <span class="text-rose-500">*</span></label>
          <div class="relative">
            <span class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm font-medium">@</span>
            <input type="text" name="username" id="usernameInput" required placeholder="johndoe123"
                   pattern="[A-Za-z0-9_]+"
                   title="Letters, numbers and underscores only"
                   class="w-full pl-8 pr-4 py-3 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow text-sm">
          </div>
          <p class="text-[11px] text-slate-400 mt-1">Letters, numbers and underscores only.</p>
        </div>

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Password <span class="text-rose-500">*</span></label>
          <div class="relative">
            <input type="password" name="password" id="passwordInput" required placeholder="Min. 6 characters"
                   autocomplete="new-password"
                   class="w-full px-4 py-3 pr-12 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow text-sm">
            <button type="button" id="togglePass1" tabindex="-1"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition p-1" aria-label="Toggle password">
              <i id="toggleIcon1" class="bi bi-eye-fill text-base"></i>
            </button>
          </div>
          <!-- Strength bar -->
          <div class="mt-2 h-1.5 bg-slate-100 rounded-full overflow-hidden">
            <div id="strengthBar" class="h-full rounded-full transition-all duration-300" style="width:0%"></div>
          </div>
          <p id="strengthLabel" class="text-[11px] mt-1 text-slate-400"></p>
        </div>

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Confirm Password <span class="text-rose-500">*</span></label>
          <div class="relative">
            <input type="password" id="confirmInput" required placeholder="Re-enter password"
                   autocomplete="new-password"
                   class="w-full px-4 py-3 pr-12 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 transition-shadow text-sm">
            <button type="button" id="togglePass2" tabindex="-1"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition p-1" aria-label="Toggle confirm password">
              <i id="toggleIcon2" class="bi bi-eye-fill text-base"></i>
            </button>
          </div>
          <p id="matchMsg" class="text-[11px] mt-1 hidden"></p>
        </div>

        <button type="submit" id="submitBtn"
                class="w-full bg-brand-600 hover:bg-brand-700 text-white font-bold text-base py-3.5 rounded-xl shadow-btn transition mt-1 flex items-center justify-center gap-2">
          <i class="bi bi-person-check-fill" id="submitIcon"></i>
          <span id="submitText">Create Account</span>
          <span id="submitSpinner" class="hidden w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
        </button>
      </form>

      <p class="text-center text-slate-500 text-sm mt-7">
        Already have an account?
        <a href="${pageContext.request.contextPath}/auth?action=login" class="text-brand-600 font-bold hover:underline">Sign In</a>
      </p>
    </div>
  </div>
</div>

<script>
(function() {
  var passInput    = document.getElementById('passwordInput');
  var confirmInput = document.getElementById('confirmInput');
  var strengthBar  = document.getElementById('strengthBar');
  var strengthLabel= document.getElementById('strengthLabel');
  var matchMsg     = document.getElementById('matchMsg');
  var form         = document.getElementById('regForm');

  function getStrength(p) {
    var score = 0;
    if (p.length >= 6)  score++;
    if (p.length >= 10) score++;
    if (/[A-Z]/.test(p)) score++;
    if (/[0-9]/.test(p)) score++;
    if (/[^A-Za-z0-9]/.test(p)) score++;
    return score;
  }

  passInput.addEventListener('input', function() {
    var p = this.value;
    var s = getStrength(p);
    var pct   = [0, 20, 40, 65, 85, 100][s];
    var color = ['', 'bg-rose-400', 'bg-amber-400', 'bg-yellow-400', 'bg-brand-400', 'bg-emerald-500'][s];
    var label = ['', 'Very weak', 'Weak', 'Fair', 'Strong', 'Very strong'][s];
    strengthBar.style.width = pct + '%';
    strengthBar.className = 'h-full rounded-full transition-all duration-300 ' + color;
    strengthLabel.textContent = p.length ? label : '';
    strengthLabel.className = 'text-[11px] mt-1 ' + (['', 'text-rose-500', 'text-amber-600', 'text-yellow-600', 'text-brand-600', 'text-emerald-600'][s] || 'text-slate-400');
    checkMatch();
  });

  confirmInput.addEventListener('input', checkMatch);

  function checkMatch() {
    var p = passInput.value, c = confirmInput.value;
    if (!c) { matchMsg.classList.add('hidden'); return; }
    matchMsg.classList.remove('hidden');
    if (p === c) {
      matchMsg.textContent = '✓ Passwords match';
      matchMsg.className = 'text-[11px] mt-1 text-emerald-600';
    } else {
      matchMsg.textContent = '✗ Passwords do not match';
      matchMsg.className = 'text-[11px] mt-1 text-rose-500';
    }
  }

  form.addEventListener('submit', function(e) {
    var p = passInput.value, c = confirmInput.value;
    if (p !== c) {
      e.preventDefault();
      confirmInput.focus();
      checkMatch();
      return;
    }
    if (p.length < 6) {
      e.preventDefault();
      passInput.focus();
      return;
    }
    document.getElementById('submitText').textContent = 'Creating account…';
    document.getElementById('submitSpinner').classList.remove('hidden');
    document.getElementById('submitIcon').classList.add('hidden');
    document.getElementById('submitBtn').disabled = true;
  });

  // Password toggles
  function makeToggle(btnId, iconId, inputEl) {
    document.getElementById(btnId).addEventListener('click', function() {
      var icon = document.getElementById(iconId);
      if (inputEl.type === 'password') {
        inputEl.type = 'text';
        icon.className = 'bi bi-eye-slash-fill text-base';
      } else {
        inputEl.type = 'password';
        icon.className = 'bi bi-eye-fill text-base';
      }
    });
  }
  makeToggle('togglePass1', 'toggleIcon1', passInput);
  makeToggle('togglePass2', 'toggleIcon2', confirmInput);
})();
</script>

<%@ include file="footer.jspf" %>
