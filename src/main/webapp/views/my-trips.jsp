<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Assigned Trips - Wildlife Safari</title>
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
    List<SafariSchedule> myTrips = (List<SafariSchedule>) request.getAttribute("myTrips");
    String roleLabel = (String) request.getAttribute("roleLabel");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">

        <div class="safari-card p-4 mb-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="safari-badge-amber text-uppercase"><%= roleLabel %></span>
            </div>
            <h2 class="font-heading mb-1"><i class="bi bi-signpost-2 me-2"></i>My Assigned Trips</h2>
            <p class="text-muted small mb-0">Your upcoming allocated safari expeditions</p>
        </div>

        <% if (myTrips == null || myTrips.isEmpty()) { %>
        <div class="alert alert-info">
            <i class="bi bi-info-circle me-2"></i>You have no active scheduled trips right now.
        </div>
        <% } else { %>
        <div class="table-responsive">
            <table class="table table-safari align-middle">
                <thead>
                <tr><th>Booking Ref</th><th>Package</th><th>Date</th><th>Time</th><th>Guide</th><th>Driver</th><th>Vehicle</th></tr>
                </thead>
                <tbody>
                <% for (SafariSchedule s : myTrips) { %>
                <tr>
                    <td class="fw-semibold"><%= s.getBookingReference() %></td>
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
        </div>
        <% } %>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>