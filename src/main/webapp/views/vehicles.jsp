<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Vehicle" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Vehicles</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
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

<nav class="navbar navbar-dark bg-success">
  <div class="container-fluid">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
    <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
  </div>
</nav>

<div class="container mt-4">
  <h2>🚙 Vehicles</h2>

  <% if (canManage) { %>
  <div class="card p-3 mb-4">
    <h5><%= editVehicle != null ? "Edit Vehicle" : "Add New Vehicle" %></h5>
    <form action="${pageContext.request.contextPath}/vehicles" method="post">
      <% if (editVehicle != null) { %>
      <input type="hidden" name="id" value="<%= editVehicle.getId() %>">
      <% } %>
      <div class="row g-2">
        <div class="col-md-2">
          <input type="text" name="registrationNumber" class="form-control" placeholder="Reg. Number"
                 value="<%= editVehicle != null ? editVehicle.getRegistrationNumber() : "" %>" required>
        </div>
        <div class="col-md-2">
          <input type="text" name="vehicleType" class="form-control" placeholder="Type (e.g. Jeep)"
                 value="<%= editVehicle != null ? editVehicle.getVehicleType() : "" %>" required>
        </div>
        <div class="col-md-2">
          <input type="date" name="insuranceExpiry" class="form-control"
                 value="<%= editVehicle != null ? editVehicle.getInsuranceExpiry() : "" %>" required>
        </div>
        <div class="col-md-3">
          <select name="maintenanceStatus" class="form-control">
            <option value="active" <%= (editVehicle != null && "active".equals(editVehicle.getMaintenanceStatus())) ? "selected" : "" %>>Active</option>
            <option value="under_maintenance" <%= (editVehicle != null && "under_maintenance".equals(editVehicle.getMaintenanceStatus())) ? "selected" : "" %>>Under Maintenance</option>
            <option value="inactive" <%= (editVehicle != null && "inactive".equals(editVehicle.getMaintenanceStatus())) ? "selected" : "" %>>Inactive</option>
          </select>
        </div>
        <div class="col-md-3">
          <select name="availabilityStatus" class="form-control">
            <option value="available" <%= (editVehicle != null && "available".equals(editVehicle.getAvailabilityStatus())) ? "selected" : "" %>>Available</option>
            <option value="assigned" <%= (editVehicle != null && "assigned".equals(editVehicle.getAvailabilityStatus())) ? "selected" : "" %>>Assigned</option>
            <option value="unavailable" <%= (editVehicle != null && "unavailable".equals(editVehicle.getAvailabilityStatus())) ? "selected" : "" %>>Unavailable</option>
          </select>
        </div>
        <div class="col-md-12">
          <button type="submit" class="btn btn-success"><%= editVehicle != null ? "Update" : "Add" %> Vehicle</button>
          <% if (editVehicle != null) { %>
          <a href="${pageContext.request.contextPath}/vehicles" class="btn btn-secondary">Cancel</a>
          <% } %>
        </div>
      </div>
    </form>
  </div>
  <% } %>

  <table class="table table-striped">
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
      <td><%= v.getRegistrationNumber() %></td>
      <td><%= v.getVehicleType() %></td>
      <td><%= v.getInsuranceExpiry() %></td>
      <td><span class="badge <%= "active".equals(v.getMaintenanceStatus()) ? "bg-success" : "bg-warning" %>"><%= v.getMaintenanceStatus() %></span></td>
      <td><span class="badge <%= "available".equals(v.getAvailabilityStatus()) ? "bg-success" : "bg-secondary" %>"><%= v.getAvailabilityStatus() %></span></td>
      <% if (canManage) { %>
      <td>
        <a href="${pageContext.request.contextPath}/vehicles?action=edit&id=<%= v.getId() %>" class="btn btn-sm btn-primary">Edit</a>
        <a href="${pageContext.request.contextPath}/vehicles?action=delete&id=<%= v.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this vehicle?')">Delete</a>
      </td>
      <% } %>
    </tr>
    <% } } %>
    </tbody>
  </table>
</div>
</body>
</html>