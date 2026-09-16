<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Booking" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Bookings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
%>

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <div>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/bookings">Browse Packages</a>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        </div>
    </div>
</nav>

<div class="container mt-4">
    <h2>📖 My Bookings</h2>

    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success">Booking confirmed!</div>
    <% } %>

    <table class="table table-striped">
        <thead>
        <tr>
            <th>Reference</th><th>Package</th><th>Date</th><th>Time</th><th>Participants</th><th>Total</th><th>Status</th><th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <% if (bookings != null) {
            for (Booking b : bookings) { %>
        <tr>
            <td><%= b.getBookingReference() %></td>
            <td><%= b.getPackageType() %> — <%= b.getDestination() %></td>
            <td><%= b.getSafariDate() %></td>
            <td><%= b.getTimeSlot() %></td>
            <td><%= b.getParticipants() %></td>
            <td>$<%= b.getTotalCost() %></td>
            <td><span class="badge <%= "confirmed".equals(b.getStatus()) ? "bg-success" : ("cancelled".equals(b.getStatus()) ? "bg-danger" : "bg-secondary") %>"><%= b.getStatus() %></span></td>
            <td>
                <a href="${pageContext.request.contextPath}/payments?action=pay&bookingId=<%= b.getId() %>" class="btn btn-sm btn-outline-success me-1">
                    💳 Pay / Receipt
                </a>
                <% if ("confirmed".equals(b.getStatus())) { %>
                <a href="${pageContext.request.contextPath}/bookings?action=cancel&id=<%= b.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('Cancel this booking?')">Cancel</a>
                <% } %>
            </td>
        </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>