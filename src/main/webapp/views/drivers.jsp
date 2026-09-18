<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Driver" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Drivers - Wildlife Safari</title>
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
  Driver editDriver = (Driver) request.getAttribute("editDriver");
  List<Driver> drivers = (List<Driver>) request.getAttribute("drivers");
  List<User> driverUsers = (List<User>) request.getAttribute("driverUsers");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
  <div class="container">

    <div class="safari-card p-4 mb-4 bg-white">
      <div class="d-flex align-items-center gap-2 mb-1">
        <span class="safari-badge-amber text-uppercase">Personnel</span>
      </div>
      <h2 class="font-heading mb-1"><i class="bi bi-person-badge me-2"></i>Drivers Roster</h2>
      <p class="text-muted small mb-0">Driver licensing, experience, and assignment status</p>
    </div>

    <% if (canManage) { %>
    <div class="safari-card-static p-4 mb-4">
      <h5 class="fw-bold mb-3">
        <i class="bi bi-<%= editDriver != null ? "pencil-square" : "plus-circle" %> me-2"></i>
        <%= editDriver != null ? "Edit Driver" : "Add New Driver" %>
      </h5>

      <% if (driverUsers == null || driverUsers.isEmpty()) { %>
      <div class="alert alert-warning mb-0">
        <i class="bi bi-exclamation-triangle me-2"></i>No users with role 'driver' exist yet. Register a user and set their role to 'driver' first.
      </div>
      <% } else { %>
      <form action="${pageContext.request.contextPath}/drivers" method="post">
        <% if (editDriver != null) { %>
        <input type="hidden" name="id" value="<%= editDriver.getId() %>">
        <% } %>
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label small fw-semibold">User</label>
            <select name="userId" class="form-select" required>
              <option value="">-- Select User --</option>
              <% for (User u : driverUsers) { %>
              <option value="<%= u.getId() %>" <%= (editDriver != null && editDriver.getUserId() == u.getId()) ? "selected" : "" %>>
                <%= u.getName() %> (<%= u.getEmail() %>)
              </option>
              <% } %>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">License Number</label>
            <input type="text" name="licenseNumber" class="form-control"
                   value="<%= editDriver != null ? editDriver.getLicenseNumber() : "" %>" required>
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">License Expiry</label>
            <input type="date" name="licenseExpiry" class="form-control"
                   value="<%= editDriver != null ? editDriver.getLicenseExpiry() : "" %>" required>
          </div>
          <div class="col-md-1">
            <label class="form-label small fw-semibold">Years</label>
            <input type="number" name="experienceYears" class="form-control"
                   value="<%= editDriver != null ? editDriver.getExperienceYears() : "" %>" required>
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">Employment</label>
            <select name="employmentStatus" class="form-select">
              <option value="active" <%= (editDriver != null && "active".equals(editDriver.getEmploymentStatus())) ? "selected" : "" %>>Active</option>
              <option value="inactive" <%= (editDriver != null && "inactive".equals(editDriver.getEmploymentStatus())) ? "selected" : "" %>>Inactive</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">Availability</label>
            <select name="availabilityStatus" class="form-select">
              <option value="available" <%= (editDriver != null && "available".equals(editDriver.getAvailabilityStatus())) ? "selected" : "" %>>Available</option>
              <option value="assigned" <%= (editDriver != null && "assigned".equals(editDriver.getAvailabilityStatus())) ? "selected" : "" %>>Assigned</option>
              <option value="unavailable" <%= (editDriver != null && "unavailable".equals(editDriver.getAvailabilityStatus())) ? "selected" : "" %>>Unavailable</option>
            </select>
          </div>
          <div class="col-md-12">
            <button type="submit" class="btn btn-safari-amber">
              <i class="bi bi-check2-circle me-1"></i> <%= editDriver != null ? "Update" : "Add" %> Driver
            </button>
            <% if (editDriver != null) { %>
            <a href="${pageContext.request.contextPath}/drivers" class="btn btn-safari-outline">Cancel</a>
            <% } %>
          </div>
        </div>
      </form>
      <% } %>
    </div>
    <% } %>

    <div class="safari-divider-route"><i class="bi bi-signpost-split"></i></div>

    <div class="table-responsive">
      <table class="table table-safari align-middle">
        <thead>
        <tr>
          <th>Name</th><th>License</th><th>Expiry</th><th>Experience</th><th>Employment</th><th>Availability</th>
          <% if (canManage) { %><th>Actions</th><% } %>
        </tr>
        </thead>
        <tbody>
        <% if (drivers != null) {
          for (Driver d : drivers) { %>
        <tr>
          <td class="fw-semibold"><%= d.getDriverName() != null ? d.getDriverName() : "(unlinked)" %></td>
          <td><%= d.getLicenseNumber() %></td>
          <td><%= d.getLicenseExpiry() %></td>
          <td><%= d.getExperienceYears() %> yrs</td>
          <td>
            <% if ("active".equals(d.getEmploymentStatus())) { %>
            <span class="safari-badge-forest">Active</span>
            <% } else { %>
            <span class="badge bg-secondary">Inactive</span>
            <% } %>
          </td>
          <td>
            <% if ("available".equals(d.getAvailabilityStatus())) { %>
            <span class="safari-badge-sage">Available</span>
            <% } else { %>
            <span class="safari-badge-sand"><%= d.getAvailabilityStatus() %></span>
            <% } %>
          </td>
          <% if (canManage) { %>
          <td>
            <a href="${pageContext.request.contextPath}/drivers?action=edit&id=<%= d.getId() %>" class="btn btn-sm btn-safari-outline">Edit</a>
            <a href="${pageContext.request.contextPath}/drivers?action=delete&id=<%= d.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this driver?')">Delete</a>
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