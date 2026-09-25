<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reassign Resources - Wildlife Safari</title>
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
    SafariSchedule target = (SafariSchedule) request.getAttribute("reassignTarget");
    if (target == null) {
        response.sendRedirect(request.getContextPath() + "/schedules");
        return;
    }
    List<Guide> guides = (List<Guide>) request.getAttribute("guides");
    List<Driver> drivers = (List<Driver>) request.getAttribute("drivers");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    String conflictError = (String) request.getAttribute("conflictError");

    boolean guideIssue = target.getGuideId() != null &&
            (!"available".equals(target.getGuideAvailability()) || !"active".equals(target.getGuideEmployment()));
    boolean driverIssue = target.getDriverId() != null &&
            (!"available".equals(target.getDriverAvailability()) || !"active".equals(target.getDriverEmployment()));
    boolean vehicleIssue = target.getVehicleId() != null &&
            (!"available".equals(target.getVehicleAvailability()) || !"active".equals(target.getVehicleMaintenance()));
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container" style="max-width: 700px;">

        <div class="safari-card p-4 mb-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="badge bg-warning text-dark text-uppercase">Reassign</span>
            </div>
            <h2 class="font-heading mb-1"><i class="bi bi-arrow-repeat me-2"></i>Reassign Trip Resources</h2>
            <p class="text-muted small mb-0">
                <%= target.getBookingReference() %> — <%= target.getPackageType() %> —
                📅 <%= target.getScheduleDate() %> (<%= target.getScheduleTime() %>)
            </p>
        </div>

        <% if (conflictError != null) { %>
        <div class="alert alert-danger d-flex align-items-center gap-2">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <div><strong>Scheduling conflict:</strong> <%= conflictError %></div>
        </div>
        <% } %>

        <div class="alert alert-warning">
            <i class="bi bi-exclamation-triangle me-2"></i>
            <strong>Current assignment issues:</strong>
            <ul class="mb-0 mt-1">
                <% if (guideIssue) { %><li>Guide <%= target.getGuideName() %> is currently unavailable.</li><% } %>
                <% if (driverIssue) { %><li>Driver <%= target.getDriverName() %> is currently unavailable.</li><% } %>
                <% if (vehicleIssue) { %><li>Vehicle <%= target.getVehicleRegNumber() %> is currently unavailable.</li><% } %>
                <% if (!guideIssue && !driverIssue && !vehicleIssue) { %><li>No issues detected — you can still reassign manually if needed.</li><% } %>
            </ul>
        </div>

        <div class="safari-card-static p-4">
            <form action="${pageContext.request.contextPath}/schedules" method="post">
                <input type="hidden" name="formType" value="reassign">
                <input type="hidden" name="scheduleId" value="<%= target.getId() %>">
                <input type="hidden" name="scheduleDate" value="<%= target.getScheduleDate() %>">

                <div class="mb-3">
                    <label class="form-label small fw-semibold">
                        Guide <% if (guideIssue) { %><span class="text-danger">(currently unavailable)</span><% } %>
                    </label>
                    <select name="guideId" class="form-select">
                        <option value="">-- None --</option>
                        <% if (target.getGuideId() != null) { %>
                        <option value="<%= target.getGuideId() %>" selected>
                            <%= target.getGuideName() %> (currently assigned<% if (guideIssue) { %> — unavailable<% } %>)
                        </option>
                        <% } %>
                        <% if (guides != null) for (Guide g : guides) {
                            if (target.getGuideId() == null || g.getId() != target.getGuideId()) { %>
                        <option value="<%= g.getId() %>"><%= g.getGuideName() %></option>
                        <% } } %>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold">
                        Driver <% if (driverIssue) { %><span class="text-danger">(currently unavailable)</span><% } %>
                    </label>
                    <select name="driverId" class="form-select">
                        <option value="">-- None --</option>
                        <% if (target.getDriverId() != null) { %>
                        <option value="<%= target.getDriverId() %>" selected>
                            <%= target.getDriverName() %> (currently assigned<% if (driverIssue) { %> — unavailable<% } %>)
                        </option>
                        <% } %>
                        <% if (drivers != null) for (Driver d : drivers) {
                            if (target.getDriverId() == null || d.getId() != target.getDriverId()) { %>
                        <option value="<%= d.getId() %>"><%= d.getDriverName() %></option>
                        <% } } %>
                    </select>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-semibold">
                        Vehicle <% if (vehicleIssue) { %><span class="text-danger">(currently unavailable)</span><% } %>
                    </label>
                    <select name="vehicleId" class="form-select">
                        <option value="">-- None --</option>
                        <% if (target.getVehicleId() != null) { %>
                        <option value="<%= target.getVehicleId() %>" selected>
                            <%= target.getVehicleRegNumber() %> (currently assigned<% if (vehicleIssue) { %> — unavailable<% } %>)
                        </option>
                        <% } %>
                        <% if (vehicles != null) for (Vehicle v : vehicles) {
                            if (target.getVehicleId() == null || v.getId() != target.getVehicleId()) { %>
                        <option value="<%= v.getId() %>"><%= v.getRegistrationNumber() %></option>
                        <% } } %>
                    </select>
                </div>

                <button type="submit" class="btn btn-safari-amber">
                    <i class="bi bi-check2-circle me-1"></i> Save Reassignment
                </button>
                <a href="${pageContext.request.contextPath}/schedules" class="btn btn-safari-outline">Cancel</a>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>