<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Wildlife Safari Trip Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    String role = user.getRole();
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <div class="d-flex">
            <span class="navbar-text text-white me-3">
                <%= user.getName() %> (<%= role %>)
            </span>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">Logout</a>
        </div>
    </div>
</nav>

<div class="container mt-4">
    <h2>Welcome, <%= user.getName() %>!</h2>

    <div class="row mt-4">
        <% if (role.equals("admin")) { %>
            <div class="col-md-4 mb-3"><div class="card p-3">👥 Manage Users <span class="badge bg-secondary">Coming soon</span></div></div>
            <div class="col-md-4 mb-3"><div class="card p-3">📊 System Reports <span class="badge bg-secondary">Coming soon</span></div></div>
        <% } %>

        <% if (role.equals("admin") || role.equals("manager")) { %>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/packages" class="text-decoration-none"><div class="card p-3">🗺️ Manage Packages</div></a></div>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/vehicles" class="text-decoration-none"><div class="card p-3">🚙 Manage Vehicles</div></a></div>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/drivers" class="text-decoration-none"><div class="card p-3">🚗 Manage Drivers</div></a></div>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/guides" class="text-decoration-none"><div class="card p-3">🧭 Manage Guides</div></a></div>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/schedules" class="text-decoration-none"><div class="card p-3">📅 Manage Schedules</div></a></div>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/payments" class="text-decoration-none"><div class="card p-3">💳 Payment Records</div></a></div>
        <% } %>

        <% if (role.equals("tourist")) { %>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/bookings" class="text-decoration-none"><div class="card p-3">🔍 Browse Safari Packages</div></a></div>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/bookings?view=mine" class="text-decoration-none"><div class="card p-3">📖 My Bookings</div></a></div>
        <% } %>

        <% if (role.equals("guide")) { %>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/sightings" class="text-decoration-none"><div class="card p-3">🐘 Log Wildlife Sighting</div></a></div>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/schedules?view=mine" class="text-decoration-none"><div class="card p-3">📋 My Assigned Trips</div></a></div>
        <% } %>

        <% if (role.equals("driver")) { %>
            <div class="col-md-4 mb-3"><a href="${pageContext.request.contextPath}/schedules?view=mine" class="text-decoration-none"><div class="card p-3">🚗 My Schedule</div></a></div>
        <% } %>

        <% if (role.equals("support_officer")) { %>
            <div class="col-md-4 mb-3"><div class="card p-3">💬 Support Requests <span class="badge bg-secondary">Coming soon</span></div></div>
        <% } %>
    </div>
</div>
</body>
</html>