<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Emergency Reports</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
  User user = (User) session.getAttribute("loggedInUser");
  if (user == null) {
    response.sendRedirect(request.getContextPath() + "/views/login.jsp");
    return;
  }
  List<EmergencyReport> reports = (List<EmergencyReport>) request.getAttribute("reports");
  List<SafariSchedule> scheduleOptions = (List<SafariSchedule>) request.getAttribute("scheduleOptions");
  Boolean canManage = (Boolean) request.getAttribute("canManage");
  Boolean canReport = (Boolean) request.getAttribute("canReport");
%>

<nav class="navbar navbar-dark bg-success">
  <div class="container-fluid">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
    <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
  </div>
</nav>

<div class="container mt-4">
  <h2>🚨 Emergency Reports</h2>

  <% if (request.getParameter("success") != null) { %>
  <div class="alert alert-success">Emergency reported! Management has been notified.</div>
  <% } %>

  <% if (Boolean.TRUE.equals(canReport)) { %>
  <div class="card p-3 mb-4 border-danger">
    <h5>🚨 Report an Emergency</h5>
    <form action="${pageContext.request.contextPath}/emergencies" method="post">
      <div class="row g-2">
        <div class="col-md-4">
          <select name="scheduleId" class="form-control">
            <option value="">-- Trip (optional) --</option>
            <% if (scheduleOptions != null) for (SafariSchedule s : scheduleOptions) { %>
            <option value="<%= s.getId() %>"><%= s.getBookingReference() %> — <%= s.getScheduleDate() %></option>
            <% } %>
          </select>
        </div>
        <div class="col-md-3">
          <select name="incidentType" class="form-control" required>
            <option value="vehicle_breakdown">Vehicle Breakdown</option>
            <option value="medical_incident">Medical Incident</option>
            <option value="wildlife_threat">Wildlife Threat</option>
            <option value="other">Other</option>
          </select>
        </div>
        <div class="col-md-3">
          <input type="text" name="details" class="form-control" placeholder="Brief details" required>
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-danger w-100">Report</button>
        </div>
      </div>
    </form>
  </div>
  <% } %>

  <table class="table table-striped">
    <thead>
    <tr>
      <th>Reported By</th><th>Trip</th><th>Type</th><th>Details</th><th>Status</th>
      <% if (Boolean.TRUE.equals(canManage)) { %><th>Update Status</th><% } %>
    </tr>
    </thead>
    <tbody>
    <% if (reports != null) {
      for (EmergencyReport r : reports) { %>
    <tr>
      <td><%= r.getReporterName() %></td>
      <td><%= r.getBookingReference() != null ? r.getBookingReference() : "—" %></td>
      <td><%= r.getIncidentType() %></td>
      <td><%= r.getDetails() %></td>
      <td>
                <span class="badge <%=
                    "reported".equals(r.getStatus()) ? "bg-danger" :
                    "resolved".equals(r.getStatus()) ? "bg-success" : "bg-warning"
                %>"><%= r.getStatus() %></span>
      </td>
      <% if (Boolean.TRUE.equals(canManage)) { %>
      <td>
        <form action="${pageContext.request.contextPath}/emergencies" method="get" class="d-flex gap-1">
          <input type="hidden" name="action" value="updateStatus">
          <input type="hidden" name="id" value="<%= r.getId() %>">
          <select name="status" class="form-select form-select-sm">
            <option value="reported" <%= "reported".equals(r.getStatus()) ? "selected" : "" %>>Reported</option>
            <option value="in_progress" <%= "in_progress".equals(r.getStatus()) ? "selected" : "" %>>In Progress</option>
            <option value="resolved" <%= "resolved".equals(r.getStatus()) ? "selected" : "" %>>Resolved</option>
          </select>
          <button type="submit" class="btn btn-sm btn-primary">Update</button>
        </form>
      </td>
      <% } %>
    </tr>
    <% } } %>
    </tbody>
  </table>
</div>
</body>
</html>