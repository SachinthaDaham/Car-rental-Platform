<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%  request.setAttribute("nav", "add");
    request.setAttribute("pageTitle", "Add Vehicle — DriveLanka Admin"); %>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen py-8">
  <div class="max-w-3xl mx-auto px-4 sm:px-6">

    <!-- Breadcrumbs -->
    <nav class="text-sm text-slate-500 mb-5 flex items-center gap-1">
      <a href="${pageContext.request.contextPath}/vehicles?action=dashboard" class="hover:text-brand-600">Dashboard</a>
      <i class="bi bi-chevron-right text-xs text-slate-300"></i>
      <a href="${pageContext.request.contextPath}/vehicles?action=list" class="hover:text-brand-600">Manage Fleet</a>
      <i class="bi bi-chevron-right text-xs text-slate-300"></i>
      <span class="text-ink-900 font-medium">Add Vehicle</span>
    </nav>

    <div class="mb-6">
      <h1 class="text-3xl font-extrabold text-ink-900">Add New Vehicle</h1>
      <p class="text-slate-500 mt-1">Fill in the details to register a new vehicle in the fleet.</p>
    </div>

    <%-- Server-side validation error --%>
    <% String errMsg = (String) request.getAttribute("errorMsg"); %>
    <% if (errMsg != null) { %>
      <div class="mb-4 flex items-center gap-3 bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl text-sm font-medium">
        <i class="bi bi-exclamation-circle-fill text-rose-500"></i> <%= errMsg %>
      </div>
    <% } %>

    <form action="${pageContext.request.contextPath}/vehicles" method="post" class="space-y-6">
      <input type="hidden" name="action" value="create">

      <!-- Section 1: Core Info -->
      <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-5">
        <h3 class="text-base font-bold text-ink-900 flex items-center gap-2"><span class="w-6 h-6 rounded-full bg-brand-600 text-white text-xs flex items-center justify-center font-bold">1</span> Basic Information</h3>
        <div class="grid sm:grid-cols-2 gap-5">
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Vehicle Type <span class="text-rose-500">*</span></label>
            <select name="type" id="typeSelector" required class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 bg-white text-sm">
              <option value="Car">🚗 Car</option>
              <option value="Bike">🏍️ Bike</option>
              <option value="Van">🚐 Van</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Vehicle ID <span class="text-rose-500">*</span></label>
            <input type="text" name="id" required placeholder="e.g. C001" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm" pattern="[A-Za-z0-9]+" title="Alphanumeric only">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Brand <span class="text-rose-500">*</span></label>
            <input type="text" name="brand" required placeholder="e.g. Toyota" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Model <span class="text-rose-500">*</span></label>
            <input type="text" name="model" required placeholder="e.g. Aqua" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Year</label>
            <input type="number" name="year" value="2024" min="1990" max="2026" required class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Daily Rate (LKR) <span class="text-rose-500">*</span></label>
            <div class="relative">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm font-medium">Rs</span>
              <input type="number" name="dailyRate" required placeholder="5000" min="0" step="0.01" class="w-full pl-9 pr-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
            </div>
          </div>
        </div>
      </div>

      <!-- Section 2: Type-specific -->
      <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-5">
        <h3 class="text-base font-bold text-ink-900 flex items-center gap-2"><span class="w-6 h-6 rounded-full bg-brand-600 text-white text-xs flex items-center justify-center font-bold">2</span> Specifications</h3>
        <div class="grid sm:grid-cols-2 gap-5">
          <div class="spec-field car-field">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Seats</label>
            <input type="number" name="seats" value="4" min="1" max="15" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
          <div class="spec-field car-field">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Transmission</label>
            <select name="transmission" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 bg-white text-sm">
              <option>Automatic</option><option>Manual</option>
            </select>
          </div>
          <div class="spec-field bike-field hidden">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Engine CC</label>
            <input type="number" name="engineCC" value="150" min="50" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
          <div class="spec-field bike-field hidden">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Bike Type</label>
            <select name="bikeType" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 bg-white text-sm">
              <option>Scooter</option><option>Sport</option><option>Cruiser</option><option>Commuter</option>
            </select>
          </div>
          <div class="spec-field van-field hidden">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Cargo Capacity (kg)</label>
            <input type="number" name="cargoCapacity" value="500" min="0" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
          <div class="spec-field van-field hidden">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Passenger Capacity</label>
            <input type="number" name="passengerCapacity" value="12" min="1" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
        </div>
      </div>

      <!-- Section 3: Extra Details -->
      <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-5">
        <h3 class="text-base font-bold text-ink-900 flex items-center gap-2"><span class="w-6 h-6 rounded-full bg-brand-600 text-white text-xs flex items-center justify-center font-bold">3</span> Additional Details</h3>
        <div class="grid sm:grid-cols-2 gap-5">
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Location</label>
            <input type="text" name="location" placeholder="e.g. Colombo 03" class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Image URL</label>
            <input type="url" name="imageUrl" id="imageUrlInput" placeholder="https://..." class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm">
          </div>
        </div>
        <!-- Image preview -->
        <div id="imagePreviewBox" class="hidden">
          <p class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2">Preview</p>
          <img id="imagePreview" src="" alt="Preview" class="w-full max-h-48 object-cover rounded-xl border border-slate-200">
        </div>
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Description</label>
          <textarea name="description" rows="3" placeholder="A short description about this vehicle..." class="w-full px-4 py-2.5 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-brand-500 text-sm resize-none"></textarea>
        </div>
        <label class="flex items-center gap-3 p-4 bg-emerald-50 rounded-xl border border-emerald-100 cursor-pointer select-none">
          <input type="checkbox" name="available" checked class="w-5 h-5 rounded accent-brand-600">
          <div>
            <span class="font-semibold text-slate-700 text-sm">Make available immediately</span>
            <p class="text-xs text-slate-400">Vehicle will appear as rentable in the fleet browser</p>
          </div>
        </label>
      </div>

      <!-- Actions -->
      <div class="flex items-center justify-end gap-3 pt-2">
        <a href="${pageContext.request.contextPath}/vehicles?action=list" class="px-6 py-2.5 rounded-xl font-bold text-slate-600 hover:bg-slate-100 transition text-sm">Cancel</a>
        <button type="submit" class="bg-brand-600 hover:bg-brand-700 text-white px-8 py-2.5 rounded-xl font-bold shadow-btn transition text-sm flex items-center gap-2">
          <i class="bi bi-plus-circle-fill"></i> Save Vehicle
        </button>
      </div>
    </form>
  </div>
</div>

<script>
// Type selector
const sel = document.getElementById('typeSelector');
const fields = document.querySelectorAll('.spec-field');
function updateFields() {
  const t = sel.value.toLowerCase();
  fields.forEach(f => f.classList.toggle('hidden', !f.classList.contains(t + '-field')));
}
sel.addEventListener('change', updateFields);
updateFields();

// Image preview
const imgInput = document.getElementById('imageUrlInput');
const imgPreview = document.getElementById('imagePreview');
const imgBox = document.getElementById('imagePreviewBox');
imgInput.addEventListener('input', function() {
  const url = this.value.trim();
  if (url.startsWith('http')) {
    imgPreview.src = url;
    imgBox.classList.remove('hidden');
    imgPreview.onerror = function() { imgBox.classList.add('hidden'); };
  } else {
    imgBox.classList.add('hidden');
  }
});
</script>

<%@ include file="footer.jspf" %>
