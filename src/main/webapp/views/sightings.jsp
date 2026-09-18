<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Wildlife Sightings - Wildlife Safari</title>
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

  List<WildlifeSighting> recentSightings = (List<WildlifeSighting>) request.getAttribute("recentSightings");
  List<SafariSchedule> myTrips = (List<SafariSchedule>) request.getAttribute("myTrips");
  Boolean noGuideProfile = (Boolean) request.getAttribute("noGuideProfile");
  boolean isGuide = user.getRole().equals("guide");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
  <div class="container">

    <div class="safari-card p-4 mb-4 bg-white">
      <div class="d-flex align-items-center gap-2 mb-1">
        <span class="safari-badge-sage text-uppercase">Field Notes</span>
      </div>
      <h2 class="font-heading mb-1"><i class="bi bi-camera me-2"></i>Wildlife Sightings</h2>
      <p class="text-muted small mb-0">Recent animal sightings logged by field naturalists</p>
    </div>

    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success d-flex align-items-center gap-2">
      <i class="bi bi-check-circle-fill"></i><div>Sighting logged successfully!</div>
    </div>
    <% } %>

    <% if (isGuide) { %>
    <% if (Boolean.TRUE.equals(noGuideProfile)) { %>
    <div class="alert alert-warning">
      <i class="bi bi-exclamation-triangle me-2"></i>Your account has role 'guide' but no guide profile is linked yet. Ask an admin/manager to create one for you under Guides.
    </div>
    <% } else if (myTrips == null || myTrips.isEmpty()) { %>
    <div class="alert alert-info">
      <i class="bi bi-info-circle me-2"></i>You have no active scheduled trips right now. Sightings can be logged once a trip is assigned to you.
    </div>
    <% } else { %>
    <div class="safari-card-static p-4 mb-4">
      <h5 class="fw-bold mb-3"><i class="bi bi-plus-circle me-2"></i>Log a New Sighting</h5>
      <form action="${pageContext.request.contextPath}/sightings" method="post">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label small fw-semibold">Trip</label>
            <select name="scheduleId" class="form-select" required>
              <option value="">-- Select Trip --</option>
              <% for (SafariSchedule trip : myTrips) { %>
              <option value="<%= trip.getId() %>">
                <%= trip.getBookingReference() %> — <%= trip.getPackageType() %> (<%= trip.getScheduleDate() %>)
              </option>
              <% } %>
            </select>
          </div>
          <div class="col-md-4">
            <label class="form-label small fw-semibold">Species</label>
            <input type="text" name="species" class="form-control" placeholder="e.g. African Elephant" required>
          </div>
          <div class="col-md-4">
            <label class="form-label small fw-semibold">Location</label>
            <input type="text" name="location" class="form-control" placeholder="e.g. North Watering Hole" required>
          </div>
          <div class="col-md-4">
            <label class="form-label small fw-semibold">Date</label>
            <input type="date" name="sightingDate" class="form-control" required>
          </div>
          <div class="col-md-4">
            <label class="form-label small fw-semibold">Time</label>
            <input type="time" name="sightingTime" class="form-control">
          </div>
          <div class="col-md-4">
            <label class="form-label small fw-semibold">Photo URL (optional)</label>
            <input type="url" name="photoUrl" class="form-control" placeholder="https://...">
          </div>
          <div class="col-md-12">
            <button type="submit" class="btn btn-safari-amber">
              <i class="bi bi-camera me-1"></i> Log Sighting
            </button>
          </div>
        </div>
      </form>
    </div>
    <% } %>
    <% } %>

    <div class="safari-divider-route"><i class="bi bi-binoculars"></i></div>

    <h4 class="font-heading mb-3">Recent Sightings</h4>
    <div class="row g-4">
      <% if (recentSightings != null) {
        for (WildlifeSighting s : recentSightings) { %>
      <div class="col-md-4">
        <div class="safari-card h-100">
          <% if (s.getPhotoUrl() != null && !s.getPhotoUrl().isEmpty()) { %>
          <img src="<%= s.getPhotoUrl() %>" class="w-100" style="height: 180px; object-fit: cover;" alt="<%= s.getSpecies() %>">
          <% } %>
          <div class="p-3">
            <h6 class="fw-bold mb-2"><%= s.getSpecies() %></h6>
            <p class="mb-1 text-muted small"><i class="bi bi-geo-alt me-1"></i><%= s.getLocation() %></p>
            <p class="mb-2 text-muted small"><i class="bi bi-calendar3 me-1"></i><%= s.getSightingDate() %> <%= s.getSightingTime() != null ? s.getSightingTime() : "" %></p>
            <span class="safari-badge-sand">Logged by <%= s.getGuideName() != null ? s.getGuideName() : "a guide" %></span>
          </div>
        </div>
      </div>
      <% } } %>
    </div>
  </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>