<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Schedules - Wildlife Safari</title>
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

    List<Booking> unscheduledBookings = (List<Booking>) request.getAttribute("unscheduledBookings");
    List<Guide> guides = (List<Guide>) request.getAttribute("guides");
    List<Driver> drivers = (List<Driver>) request.getAttribute("drivers");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    List<SafariSchedule> schedules = (List<SafariSchedule>) request.getAttribute("schedules");
    String conflictError = (String) request.getAttribute("conflictError");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">

        <div class="safari-card p-4 mb-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="safari-badge-forest text-uppercase">Operations</span>
            </div>
            <h2 class="font-heading mb-1"><i class="bi bi-calendar-event me-2"></i>Safari Schedule &amp; Resource Management</h2>
            <p class="text-muted small mb-0">Allocate guides, drivers, and vehicles to confirmed bookings</p>
        </div>

        <% if (conflictError != null) { %>
        <div class="alert alert-danger d-flex align-items-center gap-2">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <div><strong>Scheduling conflict:</strong> <%= conflictError %></div>
        </div>
        <% } %>
        <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success d-flex align-items-center gap-2">
            <i class="bi bi-check-circle-fill"></i>
            <div>Schedule created successfully!</div>
        </div>
        <% } %>

        <div class="safari-card-static p-4 mb-4">
            <h5 class="fw-bold mb-3"><i class="bi bi-plus-circle me-2"></i>Create New Schedule</h5>
            <p class="text-muted small mb-3"><i class="bi bi-info-circle me-1"></i>Date and time are taken automatically from the selected booking.</p>

            <% if (unscheduledBookings == null || unscheduledBookings.isEmpty()) { %>
            <div class="alert alert-info mb-0">No confirmed bookings awaiting a schedule right now.</div>
            <% } else { %>
            <form action="${pageContext.request.contextPath}/schedules" method="post">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label small fw-semibold">Booking</label>
                        <select name="bookingId" class="form-select" required>
                            <option value="">-- Select Booking --</option>
                            <% for (Booking b : unscheduledBookings) { %>
                            <option value="<%= b.getId() %>">
                                <%= b.getBookingReference() %> — <%= b.getPackageType() %> — 📅 <%= b.getSafariDate() %> (<%= b.getTimeSlot() %>) — <%= b.getParticipants() %> people
                            </option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold">Guide</label>
                        <select name="guideId" class="form-select">
                            <option value="">-- None --</option>
                            <% if (guides != null) for (Guide g : guides) { %>
                            <option value="<%= g.getId() %>"><%= g.getGuideName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold">Driver</label>
                        <select name="driverId" class="form-select">
                            <option value="">-- None --</option>
                            <% if (drivers != null) for (Driver d : drivers) { %>
                            <option value="<%= d.getId() %>"><%= d.getDriverName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold">Vehicle</label>
                        <select name="vehicleId" class="form-select">
                            <option value="">-- None --</option>
                            <% if (vehicles != null) for (Vehicle v : vehicles) { %>
                            <option value="<%= v.getId() %>"><%= v.getRegistrationNumber() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-12 mt-2">
                        <button type="submit" class="btn btn-safari-amber">
                            <i class="bi bi-check2-circle me-1"></i> Create Schedule
                        </button>
                    </div>
                </div>
            </form>
            <% } %>
        </div>

        <div class="safari-divider-route"><i class="bi bi-signpost-split"></i></div>

        <h4 class="font-heading mb-3">All Schedules</h4>
        <div class="table-responsive">
            <table class="table table-safari align-middle">
                <thead>
                <tr>
                    <th>Booking Ref</th><th>Package</th><th>Guide</th><th>Driver</th><th>Vehicle</th><th>Date</th><th>Time</th><th>Status</th><th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (schedules != null) {
                    for (SafariSchedule s : schedules) { %>
                <tr>
                    <td class="fw-semibold"><%= s.getBookingReference() %></td>
                    <td><%= s.getPackageType() %></td>
                    <td><%= s.getGuideName() != null ? s.getGuideName() : "—" %></td>
                    <td><%= s.getDriverName() != null ? s.getDriverName() : "—" %></td>
                    <td><%= s.getVehicleRegNumber() != null ? s.getVehicleRegNumber() : "—" %></td>
                    <td><%= s.getScheduleDate() %></td>
                    <td><%= s.getScheduleTime() %></td>
                    <td>
                        <% if ("scheduled".equals(s.getTripStatus())) { %>
                        <span class="safari-badge-forest">Scheduled</span>
                        <% } else if ("completed".equals(s.getTripStatus())) { %>
                        <span class="safari-badge-sage">Completed</span>
                        <% } else if ("cancelled".equals(s.getTripStatus())) { %>
                        <span class="badge bg-danger">Cancelled</span>
                        <% } else { %>
                        <span class="safari-badge-sand"><%= s.getTripStatus() %></span>
                        <% } %>
                    </td>
                    <td>
                        <% if ("scheduled".equals(s.getTripStatus())) { %>
                        <a href="${pageContext.request.contextPath}/schedules?action=complete&id=<%= s.getId() %>" class="btn btn-sm btn-safari-outline">Complete</a>
                        <a href="${pageContext.request.contextPath}/schedules?action=cancel&id=<%= s.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Cancel this schedule?')">Cancel</a>
                        <% } %>
                        <a href="${pageContext.request.contextPath}/schedules?action=delete&id=<%= s.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Permanently delete this schedule? This cannot be undone.')">
                            <i class="bi bi-trash"></i>
                        </a>
                    </td>
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