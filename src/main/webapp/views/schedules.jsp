<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Safari Schedules</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
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

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
    </div>
</nav>

<div class="container mt-4">
    <h2>📅 Safari Schedule & Resource Management</h2>

    <% if (conflictError != null) { %>
    <div class="alert alert-danger">⚠️ Scheduling conflict: <%= conflictError %></div>
    <% } %>
    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success">Schedule created successfully!</div>
    <% } %>

    <div class="card p-3 mb-4">
        <h5>Create New Schedule</h5>

        <% if (unscheduledBookings == null || unscheduledBookings.isEmpty()) { %>
        <div class="alert alert-info">No confirmed bookings awaiting a schedule right now.</div>
        <% } else { %>
        <form action="${pageContext.request.contextPath}/schedules" method="post">
            <div class="row g-2">
                <div class="col-md-4">
                    <label class="form-label">Booking</label>
                    <select name="bookingId" class="form-control" required>
                        <option value="">-- Select Booking --</option>
                        <% for (Booking b : unscheduledBookings) { %>
                        <option value="<%= b.getId() %>">
                            <%= b.getBookingReference() %> — <%= b.getPackageType() %> (<%= b.getSafariDate() %>, <%= b.getParticipants() %> people)
                        </option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Guide</label>
                    <select name="guideId" class="form-control">
                        <option value="">-- None --</option>
                        <% if (guides != null) for (Guide g : guides) { %>
                        <option value="<%= g.getId() %>"><%= g.getGuideName() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Driver</label>
                    <select name="driverId" class="form-control">
                        <option value="">-- None --</option>
                        <% if (drivers != null) for (Driver d : drivers) { %>
                        <option value="<%= d.getId() %>"><%= d.getDriverName() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Vehicle</label>
                    <select name="vehicleId" class="form-control">
                        <option value="">-- None --</option>
                        <% if (vehicles != null) for (Vehicle v : vehicles) { %>
                        <option value="<%= v.getId() %>"><%= v.getRegistrationNumber() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Time</label>
                    <select name="scheduleTime" class="form-control" required>
                        <option value="Morning">Morning</option>
                        <option value="Afternoon">Afternoon</option>
                        <option value="Evening">Evening</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Schedule Date</label>
                    <input type="date" name="scheduleDate" class="form-control" required>
                </div>
                <div class="col-md-12 mt-2">
                    <button type="submit" class="btn btn-success">Create Schedule</button>
                </div>
            </div>
        </form>
        <% } %>
    </div>

    <h4>All Schedules</h4>
    <table class="table table-striped">
        <thead>
        <tr>
            <th>Booking Ref</th><th>Package</th><th>Guide</th><th>Driver</th><th>Vehicle</th><th>Date</th><th>Time</th><th>Status</th><th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <% if (schedules != null) {
            for (SafariSchedule s : schedules) { %>
        <tr>
            <td><%= s.getBookingReference() %></td>
            <td><%= s.getPackageType() %></td>
            <td><%= s.getGuideName() != null ? s.getGuideName() : "—" %></td>
            <td><%= s.getDriverName() != null ? s.getDriverName() : "—" %></td>
            <td><%= s.getVehicleRegNumber() != null ? s.getVehicleRegNumber() : "—" %></td>
            <td><%= s.getScheduleDate() %></td>
            <td><%= s.getScheduleTime() %></td>
            <td>
                <span class="badge <%=
                    "scheduled".equals(s.getTripStatus()) ? "bg-primary" :
                    "completed".equals(s.getTripStatus()) ? "bg-success" :
                    "cancelled".equals(s.getTripStatus()) ? "bg-danger" : "bg-secondary"
                %>"><%= s.getTripStatus() %></span>
            </td>
            <td>
                <% if ("scheduled".equals(s.getTripStatus())) { %>
                <a href="${pageContext.request.contextPath}/schedules?action=complete&id=<%= s.getId() %>" class="btn btn-sm btn-success">Complete</a>
                <a href="${pageContext.request.contextPath}/schedules?action=cancel&id=<%= s.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('Cancel this schedule?')">Cancel</a>
                <% } %>
            </td>
        </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>