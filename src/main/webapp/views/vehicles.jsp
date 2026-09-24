<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Vehicle" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vehicles - Wildlife Safari</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="d-flex flex-column min-vh-100">
<%
  User user = (User) session.getAttribute("loggedInUser");
  if (user == null) {
    response.sendRedirect(request.getContextPath() + "/views/login.jsp");
    return;
  }
  boolean canManage = user.getRole().equals("admin") || user.getRole().equals("manager");
  Vehicle editVehicle = (Vehicle) request.getAttribute("editVehicle");
  List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
  <div class="container">

    <div class="safari-card p-4 mb-4 bg-white">
      <div class="d-flex align-items-center gap-2 mb-1">
        <span class="safari-badge-forest text-uppercase">Fleet</span>
      </div>
      <h2 class="font-heading mb-1"><i class="bi bi-truck me-2"></i>Safari Vehicles</h2>
      <p class="text-muted small mb-0">Manage your 4x4 fleet and maintenance status</p>
    </div>

    <% if (canManage) { %>
    <div class="safari-card-static p-4 mb-4">
      <h5 class="fw-bold mb-3">
        <i class="bi bi-<%= editVehicle != null ? "pencil-square" : "plus-circle" %> me-2"></i>
        <%= editVehicle != null ? "Edit Vehicle" : "Add New Vehicle" %>
      </h5>
      <form action="${pageContext.request.contextPath}/vehicles" method="post">
        <% if (editVehicle != null) { %>
        <input type="hidden" name="id" value="<%= editVehicle.getId() %>">
        <% } %>
        <div class="row g-3">
          <div class="col-md-2">
            <label class="form-label small fw-semibold">Reg. Number</label>
            <input type="text" name="registrationNumber" class="form-control" placeholder="e.g. WP-CAB-1234"
                   value="<%= editVehicle != null ? editVehicle.getRegistrationNumber() : "" %>" required>
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">Type</label>
            <input type="text" name="vehicleType" class="form-control" placeholder="e.g. Jeep"
                   value="<%= editVehicle != null ? editVehicle.getVehicleType() : "" %>" required>
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">Insurance Expiry</label>
            <input type="date" name="insuranceExpiry" class="form-control"
                   value="<%= editVehicle != null ? editVehicle.getInsuranceExpiry() : "" %>" required>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Maintenance</label>
            <select name="maintenanceStatus" class="form-select">
              <option value="active" <%= (editVehicle != null && "active".equals(editVehicle.getMaintenanceStatus())) ? "selected" : "" %>>Active</option>
              <option value="under_maintenance" <%= (editVehicle != null && "under_maintenance".equals(editVehicle.getMaintenanceStatus())) ? "selected" : "" %>>Under Maintenance</option>
              <option value="inactive" <%= (editVehicle != null && "inactive".equals(editVehicle.getMaintenanceStatus())) ? "selected" : "" %>>Inactive</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Availability</label>
            <select name="availabilityStatus" class="form-select">
              <option value="available" <%= (editVehicle != null && "available".equals(editVehicle.getAvailabilityStatus())) ? "selected" : "" %>>Available</option>
              <option value="assigned" <%= (editVehicle != null && "assigned".equals(editVehicle.getAvailabilityStatus())) ? "selected" : "" %>>Assigned</option>
              <option value="unavailable" <%= (editVehicle != null && "unavailable".equals(editVehicle.getAvailabilityStatus())) ? "selected" : "" %>>Unavailable</option>
            </select>
          </div>
          <div class="col-md-12">
            <button type="submit" class="btn btn-safari-amber">
              <i class="bi bi-check2-circle me-1"></i> <%= editVehicle != null ? "Update" : "Add" %> Vehicle
            </button>
            <% if (editVehicle != null) { %>
            <a href="${pageContext.request.contextPath}/vehicles" class="btn btn-safari-outline">Cancel</a>
            <% } %>
          </div>
        </div>
      </form>
    </div>
    <% } %>

    <div class="safari-divider-route"><i class="bi bi-signpost-split"></i></div>

    <div class="table-responsive">
      <table class="table table-safari align-middle">
        <thead>
        <tr>
          <th>Reg. Number</th><th>Type</th><th>Insurance Expiry</th><th>Maintenance</th><th>Availability</th>
          <% if (canManage) { %><th>Actions</th><% } %>
        </tr>
        </thead>
        <tbody>
        <% if (vehicles != null) {
          for (Vehicle v : vehicles) { %>
        <tr>
          <td class="fw-semibold"><%= v.getRegistrationNumber() %></td>
          <td><%= v.getVehicleType() %></td>
          <td><%= v.getInsuranceExpiry() %></td>
          <td>
            <% if ("active".equals(v.getMaintenanceStatus())) { %>
            <span class="safari-badge-forest">Active</span>
            <% } else if ("under_maintenance".equals(v.getMaintenanceStatus())) { %>
            <span class="safari-badge-amber">Under Maintenance</span>
            <% } else { %>
            <span class="badge bg-secondary">Inactive</span>
            <% } %>
          </td>
          <td>
            <% if ("available".equals(v.getAvailabilityStatus())) { %>
            <span class="safari-badge-sage">Available</span>
            <% } else { %>
            <span class="safari-badge-sand"><%= v.getAvailabilityStatus() %></span>
            <% } %>
          </td>
          <% if (canManage) { %>
          <td>
            <a href="${pageContext.request.contextPath}/vehicles?action=edit&id=<%= v.getId() %>" class="btn btn-sm btn-safari-outline">Edit</a>
            <a href="${pageContext.request.contextPath}/vehicles?action=delete&id=<%= v.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this vehicle?')">Delete</a>
          </td>
          <% } %>
        </tr>
        <% } } %>
        </tbody>
      </table>
    </div>
  </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>