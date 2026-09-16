<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.SafariPackage" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Browse Safari Packages</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    List<SafariPackage> packages = (List<SafariPackage>) request.getAttribute("packages");
%>

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <div>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/bookings?view=mine">My Bookings</a>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        </div>
    </div>
</nav>

<div class="container mt-4">
    <h2>🔍 Browse Safari Packages</h2>

    <div class="row mt-3">
        <% if (packages != null) {
            for (SafariPackage pkg : packages) {
                if ("available".equals(pkg.getAvailabilityStatus())) { %>
        <div class="col-md-4 mb-3">
            <div class="card p-3">
                <h5><%= pkg.getSafariType() %></h5>
                <p class="text-muted"><%= pkg.getDestination() %> — <%= pkg.getDuration() %></p>
                <p><%= pkg.getDescription() %></p>
                <p class="fw-bold">$<%= pkg.getPrice() %> / person</p>
                <a href="${pageContext.request.contextPath}/bookings?action=book&packageId=<%= pkg.getId() %>" class="btn btn-success">Book Now</a>
            </div>
        </div>
        <% } } } %>
    </div>
</div>
</body>
</html>