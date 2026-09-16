<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Driver" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Drivers</title>
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
  Driver editDriver = (Driver) request.getAttribute("editDriver");
  List<Driver> drivers = (List<Driver>) request.getAttribute("drivers");
  List<User> driverUsers = (List<User>) request.getAttribute("driverUsers");
%>

<nav class="navbar navbar-dark bg-success">
  <div class="container-fluid">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
    <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
  </div>
</nav>

<div class="container mt-4">
  <h2>🚗 Drivers</h2>

  <% if (canManage) { %>
  <div class="card p-3 mb-4">
    <h5><%= editDriver != null ? "Edit Driver" : "Add New Driver" %></h5>

    <% if (driverUsers == null || driverUsers.isEmpty()) { %>
    <div class="alert alert-warning">
      No users with role 'driver' exist yet. Register a user and set their role to 'driver' in the database first.
    </div>
    <% } else { %>
    <form action="${pageContext.request.contextPath}/drivers" method="post">
      <% if (editDriver != null) { %>
      <input type="hidden" name="id" value="<%= editDriver.getId() %>">
      <% } %>
      <div class="row g-2">
        <div class="col-md-3">
          <select name="userId" class="form-control" required>
            <option value="">-- Select User --</option>
            <% for (User u : driverUsers) { %>
            <option value="<%= u.getId() %>" <%= (editDriver != null && editDriver.getUserId() == u.getId()) ? "selected" : "" %>>
              <%= u.getName() %> (<%= u.getEmail() %>)
            </option>
            <% } %>
          </select>
        </div>
        <div class="col-md-2">
          <input type="text" name="licenseNumber" class="form-control" placeholder="License Number"
                 value="<%= editDriver != null ? editDriver.getLicenseNumber() : "" %>" required>
        </div>
        <div class="col-md-2">
          <input type="date" name="licenseExpiry" class="form-control"
                 value="<%= editDriver != null ? editDriver.getLicenseExpiry() : "" %>" required>
        </div>
        <div class="col-md-1">
          <input type="number" name="experienceYears" class="form-control" placeholder="Years"
                 value="<%= editDriver != null ? editDriver.getExperienceYears() : "" %>" required>
        </div>
        <div class="col-md-2">
          <select name="employmentStatus" class="form-control">
            <option value="active" <%= (editDriver != null && "active".equals(editDriver.getEmploymentStatus())) ? "selected" : "" %>>Active</option>
            <option value="inactive" <%= (editDriver != null && "inactive".equals(editDriver.getEmploymentStatus())) ? "selected" : "" %>>Inactive</option>
          </select>
        </div>
        <div class="col-md-2">
          <select name="availabilityStatus" class="form-control">
            <option value="available" <%= (editDriver != null && "available".equals(editDriver.getAvailabilityStatus())) ? "selected" : "" %>>Available</option>
            <option value="assigned" <%= (editDriver != null && "assigned".equals(editDriver.getAvailabilityStatus())) ? "selected" : "" %>>Assigned</option>
            <option value="unavailable" <%= (editDriver != null && "unavailable".equals(editDriver.getAvailabilityStatus())) ? "selected" : "" %>>Unavailable</option>
          </select>
        </div>
        <div class="col-md-12">
          <button type="submit" class="btn btn-success"><%= editDriver != null ? "Update" : "Add" %> Driver</button>
          <% if (editDriver != null) { %>
          <a href="${pageContext.request.contextPath}/drivers" class="btn btn-secondary">Cancel</a>
          <% } %>
        </div>
      </div>
    </form>
    <% } %>
  </div>
  <% } %>

  <table class="table table-striped">
    <thead>
    <tr>
      <th>Name</th><th>License Number</th><th>Expiry</th><th>Experience</th><th>Employment</th><th>Availability</th>
      <% if (canManage) { %><th>Actions</th><% } %>
    </tr>
    </thead>
    <tbody>
    <% if (drivers != null) {
      for (Driver d : drivers) { %>
    <tr>
      <td><%= d.getDriverName() != null ? d.getDriverName() : "(unlinked)" %></td>
      <td><%= d.getLicenseNumber() %></td>
      <td><%= d.getLicenseExpiry() %></td>
      <td><%= d.getExperienceYears() %> yrs</td>
      <td><span class="badge <%= "active".equals(d.getEmploymentStatus()) ? "bg-success" : "bg-secondary" %>"><%= d.getEmploymentStatus() %></span></td>
      <td><span class="badge <%= "available".equals(d.getAvailabilityStatus()) ? "bg-success" : "bg-secondary" %>"><%= d.getAvailabilityStatus() %></span></td>
      <% if (canManage) { %>
      <td>
        <a href="${pageContext.request.contextPath}/drivers?action=edit&id=<%= d.getId() %>" class="btn btn-sm btn-primary">Edit</a>
        <a href="${pageContext.request.contextPath}/drivers?action=delete&id=<%= d.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this driver?')">Delete</a>
      </td>
      <% } %>
    </tr>
    <% } } %>
    </tbody>
  </table>
</div>
</body>
</html>