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
  List<User> availableUsers = (List<User>) request.getAttribute("availableUsers");
  String success = request.getParameter("success");
  String error = request.getParameter("error");
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

    <% if (success != null) { %>
    <div class="alert alert-success d-flex align-items-center gap-2">
      <i class="bi bi-check-circle-fill"></i>
      <div>
        <%= "accountCreated".equals(success) ? "Driver account created. Now add the driver profile below."
                : "created".equals(success) ? "Driver added."
                : "updated".equals(success) ? "Driver updated."
                : "Driver deleted." %>
      </div>
    </div>
    <% } %>

    <% if (error != null) { %>
    <div class="alert alert-danger d-flex align-items-center gap-2">
      <i class="bi bi-exclamation-triangle-fill"></i>
      <div>
        <%= "name".equals(error) ? "Please enter a name (up to 100 characters)."
                : "email".equals(error) ? "Please enter a valid email address."
                : "exists".equals(error) ? "An account with that email already exists."
                : "mismatch".equals(error) ? "The passwords do not match."
                : "weakpassword".equals(error) ? "Password must be 8+ characters with upper and lower case letters, a number and a symbol."
                : "expired".equals(error) ? "The license expiry date can't be in the past."
                : "notavailable".equals(error) ? "That account is not available (it already has a driver profile or isn't a driver)."
                : "inuse".equals(error) ? "This driver is used in schedules and can't be deleted. Set them to Inactive instead."
                : "notfound".equals(error) ? "That driver no longer exists."
                : "Please check the details and try again." %>
      </div>
    </div>
    <% } %>

    <% if (canManage && editDriver == null) { %>
    <!-- STEP 1: CREATE ACCOUNT -->
    <div class="safari-card-static p-4 mb-4">
      <h5 class="fw-bold mb-3"><i class="bi bi-person-plus me-2"></i>Step 1: Create Driver Account</h5>
      <form action="${pageContext.request.contextPath}/drivers" method="post">
        <input type="hidden" name="action" value="createAccount">
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Full Name</label>
            <input type="text" name="name" class="form-control" maxlength="100" required>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Email</label>
            <input type="email" name="email" class="form-control" maxlength="150" required>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Password</label>
            <input type="password" name="password" class="form-control" minlength="8" required autocomplete="new-password">
            <div class="form-text">8+ chars, upper &amp; lower case, number, symbol</div>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Confirm Password</label>
            <input type="password" name="confirmPassword" class="form-control" minlength="8" required autocomplete="new-password">
          </div>
          <div class="col-md-12">
            <button type="submit" class="btn btn-safari-outline">
              <i class="bi bi-person-plus me-1"></i> Create Account
            </button>
          </div>
        </div>
      </form>
    </div>
    <% } %>

    <% if (canManage) { %>
    <!-- STEP 2: ADD / EDIT DRIVER -->
    <div class="safari-card-static p-4 mb-4">
      <h5 class="fw-bold mb-3">
        <i class="bi bi-<%= editDriver != null ? "pencil-square" : "plus-circle" %> me-2"></i>
        <%= editDriver != null ? "Edit Driver" : "Step 2: Add Driver" %>
      </h5>

      <% if (editDriver == null && (availableUsers == null || availableUsers.isEmpty())) { %>
      <div class="alert alert-warning mb-0">
        <i class="bi bi-exclamation-triangle me-2"></i>No available driver accounts. Create an account in Step 1 first.
      </div>
      <% } else { %>
      <form action="${pageContext.request.contextPath}/drivers" method="post">
        <% if (editDriver != null) { %>
        <input type="hidden" name="id" value="<%= editDriver.getId() %>">
        <% } %>
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label small fw-semibold">Driver Account</label>
            <% if (editDriver != null) { %>
            <input type="text" class="form-control" disabled
                   value="<%= editDriver.getDriverName() != null ? editDriver.getDriverName() : "(unlinked)" %>">
            <% } else { %>
            <select name="userId" class="form-select" required>
              <option value="">-- Select Available Driver --</option>
              <% for (User u : availableUsers) { %>
              <option value="<%= u.getId() %>"><%= u.getName() %> (<%= u.getEmail() %>)</option>
              <% } %>
            </select>
            <% } %>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">License Number</label>
            <input type="text" name="licenseNumber" class="form-control" maxlength="50"
                   value="<%= editDriver != null ? editDriver.getLicenseNumber() : "" %>" required>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">License Expiry</label>
            <input type="date" name="licenseExpiry" class="form-control"
              <%= editDriver == null ? "min=\"" + java.time.LocalDate.now() + "\"" : "" %>
                   value="<%= editDriver != null ? editDriver.getLicenseExpiry() : "" %>" required>
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">Years</label>
            <input type="number" name="experienceYears" class="form-control" min="0" max="60" step="1"
                   value="<%= editDriver != null ? editDriver.getExperienceYears() : "" %>" required>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Employment</label>
            <select name="employmentStatus" class="form-select">
              <option value="active" <%= (editDriver != null && "active".equals(editDriver.getEmploymentStatus())) ? "selected" : "" %>>Active</option>
              <option value="inactive" <%= (editDriver != null && "inactive".equals(editDriver.getEmploymentStatus())) ? "selected" : "" %>>Inactive</option>
            </select>
          </div>
          <div class="col-md-3">
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
            <div class="d-flex gap-2">
              <a href="${pageContext.request.contextPath}/drivers?action=edit&id=<%= d.getId() %>" class="btn btn-sm btn-safari-outline">Edit</a>
              <form action="${pageContext.request.contextPath}/drivers" method="post" class="m-0"
                    onsubmit="return confirm('Delete this driver?')">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<%= d.getId() %>">
                <button type="submit" class="btn btn-sm btn-outline-danger">Delete</button>
              </form>
            </div>
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