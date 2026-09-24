<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Guide" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Guides - Wildlife Safari</title>
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
  Guide editGuide = (Guide) request.getAttribute("editGuide");
  List<Guide> guides = (List<Guide>) request.getAttribute("guides");
  List<User> guideUsers = (List<User>) request.getAttribute("guideUsers");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
  <div class="container">

    <div class="safari-card p-4 mb-4 bg-white">
      <div class="d-flex align-items-center gap-2 mb-1">
        <span class="safari-badge-sage text-uppercase">Personnel</span>
      </div>
      <h2 class="font-heading mb-1"><i class="bi bi-compass me-2"></i>Field Naturalists</h2>
      <p class="text-muted small mb-0">Guide qualifications, specialization, and availability</p>
    </div>

    <% if (canManage) { %>
    <div class="safari-card-static p-4 mb-4">
      <h5 class="fw-bold mb-3">
        <i class="bi bi-<%= editGuide != null ? "pencil-square" : "plus-circle" %> me-2"></i>
        <%= editGuide != null ? "Edit Guide" : "Add New Guide" %>
      </h5>

      <% if (guideUsers == null || guideUsers.isEmpty()) { %>
      <div class="alert alert-warning mb-0">
        <i class="bi bi-exclamation-triangle me-2"></i>No users with role 'guide' exist yet. Register a user and set their role to 'guide' first.
      </div>
      <% } else { %>
      <form action="${pageContext.request.contextPath}/guides" method="post">
        <% if (editGuide != null) { %>
        <input type="hidden" name="id" value="<%= editGuide.getId() %>">
        <% } %>
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label small fw-semibold">User</label>
            <select name="userId" class="form-select" required>
              <option value="">-- Select User --</option>
              <% for (User u : guideUsers) { %>
              <option value="<%= u.getId() %>" <%= (editGuide != null && editGuide.getUserId() == u.getId()) ? "selected" : "" %>>
                <%= u.getName() %> (<%= u.getEmail() %>)
              </option>
              <% } %>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Qualifications</label>
            <input type="text" name="qualifications" class="form-control"
                   value="<%= editGuide != null ? editGuide.getQualifications() : "" %>">
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">Specialization</label>
            <input type="text" name="specialization" class="form-control"
                   value="<%= editGuide != null ? editGuide.getSpecialization() : "" %>">
          </div>
          <div class="col-md-1">
            <label class="form-label small fw-semibold">Years</label>
            <input type="number" name="experienceYears" class="form-control"
                   value="<%= editGuide != null ? editGuide.getExperienceYears() : "" %>" required>
          </div>
          <div class="col-md-1">
            <label class="form-label small fw-semibold">Status</label>
            <select name="employmentStatus" class="form-select">
              <option value="active" <%= (editGuide != null && "active".equals(editGuide.getEmploymentStatus())) ? "selected" : "" %>>Active</option>
              <option value="inactive" <%= (editGuide != null && "inactive".equals(editGuide.getEmploymentStatus())) ? "selected" : "" %>>Inactive</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label small fw-semibold">Availability</label>
            <select name="availabilityStatus" class="form-select">
              <option value="available" <%= (editGuide != null && "available".equals(editGuide.getAvailabilityStatus())) ? "selected" : "" %>>Available</option>
              <option value="assigned" <%= (editGuide != null && "assigned".equals(editGuide.getAvailabilityStatus())) ? "selected" : "" %>>Assigned</option>
              <option value="unavailable" <%= (editGuide != null && "unavailable".equals(editGuide.getAvailabilityStatus())) ? "selected" : "" %>>Unavailable</option>
            </select>
          </div>
          <div class="col-md-12">
            <button type="submit" class="btn btn-safari-amber">
              <i class="bi bi-check2-circle me-1"></i> <%= editGuide != null ? "Update" : "Add" %> Guide
            </button>
            <% if (editGuide != null) { %>
            <a href="${pageContext.request.contextPath}/guides" class="btn btn-safari-outline">Cancel</a>
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
          <th>Name</th><th>Qualifications</th><th>Specialization</th><th>Experience</th><th>Employment</th><th>Availability</th>
          <% if (canManage) { %><th>Actions</th><% } %>
        </tr>
        </thead>
        <tbody>
        <% if (guides != null) {
          for (Guide g : guides) { %>
        <tr>
          <td class="fw-semibold"><%= g.getGuideName() != null ? g.getGuideName() : "(unlinked)" %></td>
          <td><%= g.getQualifications() %></td>
          <td><%= g.getSpecialization() %></td>
          <td><%= g.getExperienceYears() %> yrs</td>
          <td>
            <% if ("active".equals(g.getEmploymentStatus())) { %>
            <span class="safari-badge-forest">Active</span>
            <% } else { %>
            <span class="badge bg-secondary">Inactive</span>
            <% } %>
          </td>
          <td>
            <% if ("available".equals(g.getAvailabilityStatus())) { %>
            <span class="safari-badge-sage">Available</span>
            <% } else { %>
            <span class="safari-badge-sand"><%= g.getAvailabilityStatus() %></span>
            <% } %>
          </td>
          <% if (canManage) { %>
          <td>
            <a href="${pageContext.request.contextPath}/guides?action=edit&id=<%= g.getId() %>" class="btn btn-sm btn-safari-outline">Edit</a>
            <a href="${pageContext.request.contextPath}/guides?action=delete&id=<%= g.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this guide?')">Delete</a>
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