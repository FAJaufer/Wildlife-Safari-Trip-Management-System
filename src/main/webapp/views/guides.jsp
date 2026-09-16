<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Guide" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Guides</title>
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
  Guide editGuide = (Guide) request.getAttribute("editGuide");
  List<Guide> guides = (List<Guide>) request.getAttribute("guides");
  List<User> guideUsers = (List<User>) request.getAttribute("guideUsers");
%>

<nav class="navbar navbar-dark bg-success">
  <div class="container-fluid">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
    <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
  </div>
</nav>

<div class="container mt-4">
  <h2>🧭 Guides</h2>

  <% if (canManage) { %>
  <div class="card p-3 mb-4">
    <h5><%= editGuide != null ? "Edit Guide" : "Add New Guide" %></h5>

    <% if (guideUsers == null || guideUsers.isEmpty()) { %>
    <div class="alert alert-warning">
      No users with role 'guide' exist yet. Register a user and set their role to 'guide' in the database first.
    </div>
    <% } else { %>
    <form action="${pageContext.request.contextPath}/guides" method="post">
      <% if (editGuide != null) { %>
      <input type="hidden" name="id" value="<%= editGuide.getId() %>">
      <% } %>
      <div class="row g-2">
        <div class="col-md-3">
          <select name="userId" class="form-control" required>
            <option value="">-- Select User --</option>
            <% for (User u : guideUsers) { %>
            <option value="<%= u.getId() %>" <%= (editGuide != null && editGuide.getUserId() == u.getId()) ? "selected" : "" %>>
              <%= u.getName() %> (<%= u.getEmail() %>)
            </option>
            <% } %>
          </select>
        </div>
        <div class="col-md-3">
          <input type="text" name="qualifications" class="form-control" placeholder="Qualifications"
                 value="<%= editGuide != null ? editGuide.getQualifications() : "" %>">
        </div>
        <div class="col-md-2">
          <input type="text" name="specialization" class="form-control" placeholder="Specialization"
                 value="<%= editGuide != null ? editGuide.getSpecialization() : "" %>">
        </div>
        <div class="col-md-1">
          <input type="number" name="experienceYears" class="form-control" placeholder="Years"
                 value="<%= editGuide != null ? editGuide.getExperienceYears() : "" %>" required>
        </div>
        <div class="col-md-1">
          <select name="employmentStatus" class="form-control">
            <option value="active" <%= (editGuide != null && "active".equals(editGuide.getEmploymentStatus())) ? "selected" : "" %>>Active</option>
            <option value="inactive" <%= (editGuide != null && "inactive".equals(editGuide.getEmploymentStatus())) ? "selected" : "" %>>Inactive</option>
          </select>
        </div>
        <div class="col-md-2">
          <select name="availabilityStatus" class="form-control">
            <option value="available" <%= (editGuide != null && "available".equals(editGuide.getAvailabilityStatus())) ? "selected" : "" %>>Available</option>
            <option value="assigned" <%= (editGuide != null && "assigned".equals(editGuide.getAvailabilityStatus())) ? "selected" : "" %>>Assigned</option>
            <option value="unavailable" <%= (editGuide != null && "unavailable".equals(editGuide.getAvailabilityStatus())) ? "selected" : "" %>>Unavailable</option>
          </select>
        </div>
        <div class="col-md-12">
          <button type="submit" class="btn btn-success"><%= editGuide != null ? "Update" : "Add" %> Guide</button>
          <% if (editGuide != null) { %>
          <a href="${pageContext.request.contextPath}/guides" class="btn btn-secondary">Cancel</a>
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
      <th>Name</th><th>Qualifications</th><th>Specialization</th><th>Experience</th><th>Employment</th><th>Availability</th>
      <% if (canManage) { %><th>Actions</th><% } %>
    </tr>
    </thead>
    <tbody>
    <% if (guides != null) {
      for (Guide g : guides) { %>
    <tr>
      <td><%= g.getGuideName() != null ? g.getGuideName() : "(unlinked)" %></td>
      <td><%= g.getQualifications() %></td>
      <td><%= g.getSpecialization() %></td>
      <td><%= g.getExperienceYears() %> yrs</td>
      <td><span class="badge <%= "active".equals(g.getEmploymentStatus()) ? "bg-success" : "bg-secondary" %>"><%= g.getEmploymentStatus() %></span></td>
      <td><span class="badge <%= "available".equals(g.getAvailabilityStatus()) ? "bg-success" : "bg-secondary" %>"><%= g.getAvailabilityStatus() %></span></td>
      <% if (canManage) { %>
      <td>
        <a href="${pageContext.request.contextPath}/guides?action=edit&id=<%= g.getId() %>" class="btn btn-sm btn-primary">Edit</a>
        <a href="${pageContext.request.contextPath}/guides?action=delete&id=<%= g.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this guide?')">Delete</a>
      </td>
      <% } %>
    </tr>
    <% } } %>
    </tbody>
  </table>
</div>
</body>
</html>