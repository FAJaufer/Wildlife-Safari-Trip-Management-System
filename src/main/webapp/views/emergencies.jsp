<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Emergency Reports - Wildlife Safari</title>
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
  List<EmergencyReport> reports = (List<EmergencyReport>) request.getAttribute("reports");
  List<SafariSchedule> scheduleOptions = (List<SafariSchedule>) request.getAttribute("scheduleOptions");
  Boolean canManage = (Boolean) request.getAttribute("canManage");
  Boolean canReport = (Boolean) request.getAttribute("canReport");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
  <div class="container">

    <div class="safari-card p-4 mb-4 bg-white" style="border-left: 4px solid #dc3545;">
      <div class="d-flex align-items-center gap-2 mb-1">
        <span class="badge bg-danger text-uppercase">Emergency</span>
      </div>
      <h2 class="font-heading mb-1"><i class="bi bi-exclamation-octagon me-2"></i>Emergency Reports</h2>
      <p class="text-muted small mb-0">Field incidents and their resolution status</p>
    </div>

    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success d-flex align-items-center gap-2">
      <i class="bi bi-check-circle-fill"></i><div>Emergency reported! Management has been notified.</div>
    </div>
    <% } %>

    <% if (Boolean.TRUE.equals(canReport)) { %>
    <div class="safari-card-static p-4 mb-4" style="border: 1.5px solid rgba(220,53,69,0.3);">
      <h5 class="fw-bold mb-3 text-danger"><i class="bi bi-exclamation-triangle me-2"></i>Report an Emergency</h5>
      <form action="${pageContext.request.contextPath}/emergencies" method="post">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label small fw-semibold">Trip (optional)</label>
            <select name="scheduleId" class="form-select">
              <option value="">-- Trip (optional) --</option>
              <% if (scheduleOptions != null) for (SafariSchedule s : scheduleOptions) { %>
              <option value="<%= s.getId() %>"><%= s.getBookingReference() %> — <%= s.getScheduleDate() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Incident Type</label>
            <select name="incidentType" class="form-select" required>
              <option value="vehicle_breakdown">Vehicle Breakdown</option>
              <option value="medical_incident">Medical Incident</option>
              <option value="wildlife_threat">Wildlife Threat</option>
              <option value="other">Other</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label small fw-semibold">Details</label>
            <input type="text" name="details" class="form-control" placeholder="Brief details" required>
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button type="submit" class="btn btn-danger w-100">
              <i class="bi bi-exclamation-octagon me-1"></i> Report
            </button>
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
          <th>Reported By</th><th>Trip</th><th>Type</th><th>Details</th><th>Status</th>
          <% if (Boolean.TRUE.equals(canManage)) { %><th>Update Status</th><% } %>
        </tr>
        </thead>
        <tbody>
        <% if (reports != null) {
          for (EmergencyReport r : reports) { %>
        <tr>
          <td class="fw-semibold"><%= r.getReporterName() %></td>
          <td><%= r.getBookingReference() != null ? r.getBookingReference() : "—" %></td>
          <td><span class="safari-badge-sand text-capitalize"><%= r.getIncidentType().replace("_", " ") %></span></td>
          <td><%= r.getDetails() %></td>
          <td>
            <% if ("reported".equals(r.getStatus())) { %>
            <span class="badge bg-danger">Reported</span>
            <% } else if ("resolved".equals(r.getStatus())) { %>
            <span class="safari-badge-forest">Resolved</span>
            <% } else { %>
            <span class="safari-badge-amber">In Progress</span>
            <% } %>
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
              <button type="submit" class="btn btn-sm btn-safari-outline">Update</button>
            </form>
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