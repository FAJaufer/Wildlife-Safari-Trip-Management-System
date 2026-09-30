<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reviews - Wildlife Safari</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="d-flex flex-column min-vh-100">
<%
  SafariPackage pkg = (SafariPackage) request.getAttribute("pkg");
  List<Review> reviews = (List<Review>) request.getAttribute("reviews");
  Double avgRating = (Double) request.getAttribute("avgRating");
  if (avgRating == null) avgRating = 0.0;
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
  <div class="container" style="max-width: 800px;">

    <div class="safari-card p-4 mb-4 bg-white">
      <a href="${pageContext.request.contextPath}/bookings" class="small text-muted text-decoration-none mb-2 d-inline-block">
        <i class="bi bi-arrow-left"></i> Back to Packages
      </a>
      <h2 class="font-heading mb-1"><%= pkg.getSafariType() %> — <%= pkg.getDestination() %></h2>
      <% if (avgRating > 0) { %>
      <span style="color: var(--safari-amber); font-size: 1.4rem;">
                    <% int fullStars = (int) Math.round(avgRating);
                      for (int i = 0; i < fullStars; i++) { %>★<% }
        for (int i = fullStars; i < 5; i++) { %>☆<% } %>
                </span>
      <span class="text-muted ms-2"><%= String.format("%.1f", avgRating) %> out of 5 (<%= reviews != null ? reviews.size() : 0 %> reviews)</span>
      <% } else { %>
      <span class="text-muted">No reviews yet for this package.</span>
      <% } %>
    </div>

    <div class="row g-3">
      <% if (reviews != null) {
        for (Review r : reviews) { %>
      <div class="col-12">
        <div class="safari-card p-4">
          <div class="d-flex justify-content-between align-items-start mb-2">
            <div>
              <strong class="d-block"><%= r.getUserName() %></strong>
              <span style="color: var(--safari-amber);">
                                <% for (int i = 0; i < r.getRating(); i++) { %>★<% } %><% for (int i = r.getRating(); i < 5; i++) { %>☆<% } %>
                            </span>
            </div>
            <span class="small text-muted"><%= r.getCreatedAt() %></span>
          </div>
          <% if (r.getComment() != null && !r.getComment().isEmpty()) { %>
          <p class="mb-2"><%= r.getComment() %></p>
          <% } %>
          <% if (r.getPhotoUrl() != null && !r.getPhotoUrl().isEmpty()) { %>
          <img src="<%= r.getPhotoUrl() %>" style="max-width: 250px; border-radius: 8px;" alt="Safari photo from <%= r.getUserName() %>">
          <% } %>
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