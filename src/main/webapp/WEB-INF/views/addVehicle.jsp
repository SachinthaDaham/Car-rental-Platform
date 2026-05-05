<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setAttribute("nav", "add");
    request.setAttribute("pageTitle", "Add Vehicle — DriveLanka Admin");
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen py-10">
  <div class="max-w-3xl mx-auto px-6">
    <div class="mb-8">
      <a href="${pageContext.request.contextPath}/vehicles?action=list" class="text-slate-500 hover:text-brand-600 text-sm font-semibold inline-flex items-center gap-1 mb-3"><i class="bi bi-arrow-left"></i> Back to Fleet</a>
      <h1 class="text-3xl font-extrabold text-ink-900">Add New Vehicle</h1>
      <p class="text-slate-500 mt-1">Enter the details of the new vehicle to add it to your fleet.</p>
    </div>

    <form action="${pageContext.request.contextPath}/vehicles" method="post" class="bg-white rounded-2xl shadow-sm border border-slate-100 p-8 space-y-8">
      <input type="hidden" name="action" value="create">

      <!-- Basic Info -->
      <div>
        <h3 class="text-lg font-bold text-ink-900 mb-4 border-b border-slate-100 pb-2">Basic Information</h3>
        <div class="grid sm:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Vehicle Type *</label>
            <select name="type" id="typeSelector" required class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500 bg-white">
              <option value="Car">Car</option>
              <option value="Bike">Bike</option>
              <option value="Van">Van</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Vehicle ID *</label>
            <input type="text" name="id" required placeholder="e.g. C001" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Brand *</label>
            <input type="text" name="brand" required placeholder="e.g. Toyota" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Model *</label>
            <input type="text" name="model" required placeholder="e.g. Aqua" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Year</label>
            <input type="number" name="year" value="2024" required class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Daily Rate (LKR) *</label>
            <input type="number" name="dailyRate" required placeholder="0.00" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
        </div>
      </div>

      <!-- Specific Info -->
      <div id="typeSpecificFields">
        <h3 class="text-lg font-bold text-ink-900 mb-4 border-b border-slate-100 pb-2">Specifications</h3>
        <div class="grid sm:grid-cols-2 gap-6">
          <!-- Car Fields -->
          <div class="spec-field car-field">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Seats</label>
            <input type="number" name="seats" value="4" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
          </div>
          <div class="spec-field car-field">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Transmission</label>
            <select name="transmission" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 bg-white">
              <option value="Automatic">Automatic</option>
              <option value="Manual">Manual</option>
            </select>
          </div>
          
          <!-- Bike Fields -->
          <div class="spec-field bike-field hidden">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Engine CC</label>
            <input type="number" name="engineCC" value="100" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
          </div>
          <div class="spec-field bike-field hidden">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Bike Type</label>
            <select name="bikeType" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 bg-white">
              <option value="Scooter">Scooter</option>
              <option value="Sport">Sport</option>
              <option value="Cruiser">Cruiser</option>
              <option value="Commuter">Commuter</option>
            </select>
          </div>

          <!-- Van Fields -->
          <div class="spec-field van-field hidden">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Cargo Capacity (kg)</label>
            <input type="number" name="cargoCapacity" value="0" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
          </div>
          <div class="spec-field van-field hidden">
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Passenger Capacity</label>
            <input type="number" name="passengerCapacity" value="12" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
          </div>
        </div>
      </div>

      <!-- Additional Details -->
      <div>
        <h3 class="text-lg font-bold text-ink-900 mb-4 border-b border-slate-100 pb-2">Additional Details</h3>
        <div class="space-y-6">
          <div class="grid sm:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Location</label>
              <input type="text" name="location" placeholder="e.g. Colombo 03" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
            </div>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Image URL</label>
              <input type="url" name="imageUrl" placeholder="https://..." class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
            </div>
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Description</label>
            <textarea name="description" rows="3" placeholder="A short engaging description..." class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500"></textarea>
          </div>
          <label class="flex items-center gap-3 p-4 bg-slate-50 rounded-xl border border-slate-100 cursor-pointer select-none">
            <input type="checkbox" name="available" checked class="w-5 h-5 accent-brand-600">
            <span class="font-semibold text-slate-700">Make vehicle available immediately</span>
          </label>
        </div>
      </div>

      <div class="pt-4 flex items-center justify-end gap-4 border-t border-slate-100">
        <a href="${pageContext.request.contextPath}/vehicles?action=list" class="px-6 py-2.5 rounded-lg font-bold text-slate-600 hover:bg-slate-100 transition-colors">Cancel</a>
        <button type="submit" class="bg-brand-600 hover:bg-brand-700 text-white px-8 py-2.5 rounded-lg font-bold shadow-btn transition-colors">Save Vehicle</button>
      </div>
    </form>
  </div>
</div>

<script>
  const typeSelector = document.getElementById('typeSelector');
  const specFields = document.querySelectorAll('.spec-field');
  
  function updateFields() {
    const selectedType = typeSelector.value.toLowerCase();
    specFields.forEach(field => {
      if (field.classList.contains(selectedType + '-field')) {
        field.classList.remove('hidden');
      } else {
        field.classList.add('hidden');
      }
    });
  }
  
  typeSelector.addEventListener('change', updateFields);
  updateFields(); // Init
</script>

<%@ include file="footer.jspf" %>
