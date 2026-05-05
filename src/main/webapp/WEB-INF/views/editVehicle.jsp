<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.vrp.model.Vehicle, com.vrp.model.Car, com.vrp.model.Bike, com.vrp.model.Van" %>
<%
    request.setAttribute("nav", "edit");
    request.setAttribute("pageTitle", "Edit Vehicle — DriveLanka Admin");
    Vehicle v = (Vehicle) request.getAttribute("vehicle");
    if (v == null) {
        response.sendRedirect(request.getContextPath() + "/vehicles?action=list");
        return;
    }
    String type = v.getType();
    Car car = v instanceof Car ? (Car) v : null;
    Bike bike = v instanceof Bike ? (Bike) v : null;
    Van van = v instanceof Van ? (Van) v : null;
%>
<%@ include file="header.jspf" %>

<div class="bg-slate-50 min-h-screen py-10">
  <div class="max-w-3xl mx-auto px-6">
    <div class="mb-8 flex items-center justify-between">
      <div>
        <a href="${pageContext.request.contextPath}/vehicles?action=list" class="text-slate-500 hover:text-brand-600 text-sm font-semibold inline-flex items-center gap-1 mb-3"><i class="bi bi-arrow-left"></i> Back to Fleet</a>
        <h1 class="text-3xl font-extrabold text-ink-900">Edit Vehicle</h1>
        <p class="text-slate-500 mt-1">Update the details for <%= v.getName() %> (<%= v.getId() %>).</p>
      </div>
      <div class="bg-white p-2 rounded-xl shadow-sm border border-slate-100 hidden sm:block">
        <img src="<%= v.getImageUrl() %>" onerror="this.src='https://placehold.co/100x100/e0f2fe/0369a1'" class="w-16 h-16 rounded-lg object-cover">
      </div>
    </div>

    <form action="${pageContext.request.contextPath}/vehicles" method="post" class="bg-white rounded-2xl shadow-sm border border-slate-100 p-8 space-y-8">
      <input type="hidden" name="action" value="update">
      <!-- ID is readonly during edit since it's the primary key -->
      <input type="hidden" name="id" value="<%= v.getId() %>">
      <!-- Pass type as hidden field so we don't accidentally change subclass types -->
      <input type="hidden" name="type" value="<%= type %>">

      <!-- Basic Info -->
      <div>
        <h3 class="text-lg font-bold text-ink-900 mb-4 border-b border-slate-100 pb-2">Basic Information</h3>
        <div class="grid sm:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Vehicle Type</label>
            <input type="text" value="<%= type %>" disabled class="w-full px-4 py-2.5 border border-slate-200 bg-slate-50 text-slate-500 rounded-lg outline-none">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Vehicle ID</label>
            <input type="text" value="<%= v.getId() %>" disabled class="w-full px-4 py-2.5 border border-slate-200 bg-slate-50 text-slate-500 rounded-lg outline-none">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Brand *</label>
            <input type="text" name="brand" value="<%= v.getBrand() %>" required class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Model *</label>
            <input type="text" name="model" value="<%= v.getModel() %>" required class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Year</label>
            <input type="number" name="year" value="<%= v.getYear() %>" required class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Daily Rate (LKR) *</label>
            <input type="number" name="dailyRate" value="<%= String.format("%.2f", v.getDailyRate()).replace(",", "") %>" required class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500">
          </div>
        </div>
      </div>

      <!-- Specific Info -->
      <div>
        <h3 class="text-lg font-bold text-ink-900 mb-4 border-b border-slate-100 pb-2">Specifications</h3>
        <div class="grid sm:grid-cols-2 gap-6">
          <% if ("Car".equals(type) && car != null) { %>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Seats</label>
              <input type="number" name="seats" value="<%= car.getSeats() %>" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
            </div>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Transmission</label>
              <select name="transmission" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 bg-white">
                <option value="Automatic" <%= "Automatic".equalsIgnoreCase(car.getTransmission()) ? "selected" : "" %>>Automatic</option>
                <option value="Manual" <%= "Manual".equalsIgnoreCase(car.getTransmission()) ? "selected" : "" %>>Manual</option>
              </select>
            </div>
          <% } else if ("Bike".equals(type) && bike != null) { %>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Engine CC</label>
              <input type="number" name="engineCC" value="<%= bike.getEngineCC() %>" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
            </div>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Bike Type</label>
              <select name="bikeType" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500 bg-white">
                <option value="Scooter" <%= "Scooter".equalsIgnoreCase(bike.getBikeType()) ? "selected" : "" %>>Scooter</option>
                <option value="Sport" <%= "Sport".equalsIgnoreCase(bike.getBikeType()) ? "selected" : "" %>>Sport</option>
                <option value="Cruiser" <%= "Cruiser".equalsIgnoreCase(bike.getBikeType()) ? "selected" : "" %>>Cruiser</option>
                <option value="Commuter" <%= "Commuter".equalsIgnoreCase(bike.getBikeType()) ? "selected" : "" %>>Commuter</option>
              </select>
            </div>
          <% } else if ("Van".equals(type) && van != null) { %>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Cargo Capacity (kg)</label>
              <input type="number" name="cargoCapacity" value="<%= van.getCargoCapacity() %>" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
            </div>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Passenger Capacity</label>
              <input type="number" name="passengerCapacity" value="<%= van.getPassengerCapacity() %>" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
            </div>
          <% } %>
        </div>
      </div>

      <!-- Additional Details -->
      <div>
        <h3 class="text-lg font-bold text-ink-900 mb-4 border-b border-slate-100 pb-2">Additional Details</h3>
        <div class="space-y-6">
          <div class="grid sm:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Location</label>
              <input type="text" name="location" value="<%= v.getLocation() %>" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
            </div>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-1.5">Image URL</label>
              <input type="url" name="imageUrl" value="<%= v.getImageUrl() %>" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500">
            </div>
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Description</label>
            <textarea name="description" rows="3" class="w-full px-4 py-2.5 border border-slate-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500"><%= v.getDescription() %></textarea>
          </div>
          <label class="flex items-center gap-3 p-4 bg-slate-50 rounded-xl border border-slate-100 cursor-pointer select-none">
            <input type="checkbox" name="available" <%= v.isAvailable() ? "checked" : "" %> class="w-5 h-5 accent-brand-600">
            <span class="font-semibold text-slate-700">Vehicle is available for rent</span>
          </label>
        </div>
      </div>

      <div class="pt-4 flex items-center justify-between border-t border-slate-100">
        <a href="${pageContext.request.contextPath}/vehicles?action=delete&id=<%= v.getId() %>" onclick="return confirm('Are you sure you want to delete this vehicle?');" class="px-5 py-2.5 rounded-lg font-bold text-rose-600 hover:bg-rose-50 transition-colors">Delete</a>
        <div class="flex gap-4">
          <a href="${pageContext.request.contextPath}/vehicles?action=list" class="px-6 py-2.5 rounded-lg font-bold text-slate-600 hover:bg-slate-100 transition-colors">Cancel</a>
          <button type="submit" class="bg-brand-600 hover:bg-brand-700 text-white px-8 py-2.5 rounded-lg font-bold shadow-btn transition-colors">Update Vehicle</button>
        </div>
      </div>
    </form>
  </div>
</div>

<%@ include file="footer.jspf" %>
