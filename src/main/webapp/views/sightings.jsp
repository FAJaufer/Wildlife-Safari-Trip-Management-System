<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Wildlife Sightings</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
  User user = (User) session.getAttribute("loggedInUser");
  if (user == null) {
    response.sendRedirect(request.getContextPath() + "/views/login.jsp");
    return;
  }

  List<WildlifeSighting> recentSightings = (List<WildlifeSighting>) request.getAttribute("recentSightings");
  List<SafariSchedule> myTrips = (List<SafariSchedule>) request.getAttribute("myTrips");
  Boolean noGuideProfile = (Boolean) request.getAttribute("noGuideProfile");
  boolean isGuide = user.getRole().equals("guide");
%>

<nav class="navbar navbar-dark bg-success">
  <div class="container-fluid">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
    <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
  </div>
</nav>

<div class="container mt-4">
  <h2>🐘 Wildlife Sightings</h2>

  <% if (request.getParameter("success") != null) { %>
  <div class="alert alert-success">Sighting logged successfully!</div>
  <% } %>

  <% if (isGuide) { %>
  <% if (Boolean.TRUE.equals(noGuideProfile)) { %>
  <div class="alert alert-warning">Your account has role 'guide' but no guide profile is linked yet. Ask an admin/manager to create one for you under Guides management.</div>
  <% } else if (myTrips == null || myTrips.isEmpty()) { %>
  <div class="alert alert-info">You have no active scheduled trips right now. Sightings can be logged once a trip is assigned to you.</div>
  <% } else { %>
  <div class="card p-3 mb-4">
    <h5>Log a New Sighting</h5>
    <form action="${pageContext.request.contextPath}/sightings" method="post">
      <div class="row g-2">
        <div class="col-md-4">
          <label class="form-label">Trip</label>
          <select name="scheduleId" class="form-control" required>
            <option value="">-- Select Trip --</option>
            <% for (SafariSchedule trip : myTrips) { %>
            <option value="<%= trip.getId() %>">
              <%= trip.getBookingReference() %> — <%= trip.getPackageType() %> (<%= trip.getScheduleDate() %>)
            </option>
            <% } %>
          </select>
        </div>
        <div class="col-md-4">
          <label class="form-label">Species</label>
          <input type="text" name="species" class="form-control" placeholder="e.g. African Elephant" required>
        </div>
        <div class="col-md-4">
          <label class="form-label">Location</label>
          <input type="text" name="location" class="form-control" placeholder="e.g. North Watering Hole" required>
        </div>
        <div class="col-md-4">
          <label class="form-label">Date</label>
          <input type="date" name="sightingDate" class="form-control" required>
        </div>
        <div class="col-md-4">
          <label class="form-label">Time</label>
          <input type="time" name="sightingTime" class="form-control">
        </div>
        <div class="col-md-4">
          <label class="form-label">Photo URL (optional)</label>
          <input type="url" name="photoUrl" class="form-control" placeholder="https://...">
        </div>
        <div class="col-md-12">
          <button type="submit" class="btn btn-success">Log Sighting</button>
        </div>
      </div>
    </form>
  </div>
  <% } %>
  <% } %>

  <h4>Recent Sightings</h4>
  <div class="row">
    <% if (recentSightings != null) {
      for (WildlifeSighting s : recentSightings) { %>
    <div class="col-md-4 mb-3">
      <div class="card p-3">
        <% if (s.getPhotoUrl() != null && !s.getPhotoUrl().isEmpty()) { %>
        <img src="<%= s.getPhotoUrl() %>" class="img-fluid mb-2" style="max-height: 150px; object-fit: cover;" alt="<%= s.getSpecies() %>">
        <% } %>
        <h6><%= s.getSpecies() %></h6>
        <p class="mb-1 text-muted">📍 <%= s.getLocation() %></p>
        <p class="mb-1 text-muted">📅 <%= s.getSightingDate() %> <%= s.getSightingTime() != null ? s.getSightingTime() : "" %></p>
        <p class="mb-0 small text-muted">Logged by <%= s.getGuideName() != null ? s.getGuideName() : "a guide" %></p>
      </div>
    </div>
    <% } } %>
  </div>
</div>
</body>
</html>