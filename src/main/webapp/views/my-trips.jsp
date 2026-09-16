<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Assigned Trips</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    List<SafariSchedule> myTrips = (List<SafariSchedule>) request.getAttribute("myTrips");
    String roleLabel = (String) request.getAttribute("roleLabel");
%>

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
    </div>
</nav>

<div class="container mt-4">
    <h2>📋 My Assigned Trips (<%= roleLabel %>)</h2>

    <% if (myTrips == null || myTrips.isEmpty()) { %>
    <div class="alert alert-info">You have no active scheduled trips right now.</div>
    <% } else { %>
    <table class="table table-striped">
        <thead>
        <tr><th>Booking Ref</th><th>Package</th><th>Date</th><th>Time</th><th>Guide</th><th>Driver</th><th>Vehicle</th></tr>
        </thead>
        <tbody>
        <% for (SafariSchedule s : myTrips) { %>
        <tr>
            <td><%= s.getBookingReference() %></td>
            <td><%= s.getPackageType() %></td>
            <td><%= s.getScheduleDate() %></td>
            <td><%= s.getScheduleTime() %></td>
            <td><%= s.getGuideName() != null ? s.getGuideName() : "—" %></td>
            <td><%= s.getDriverName() != null ? s.getDriverName() : "—" %></td>
            <td><%= s.getVehicleRegNumber() != null ? s.getVehicleRegNumber() : "—" %></td>
        </tr>
        <% } %>
        </tbody>
    </table>
    <% } %>
</div>
</body>
</html>