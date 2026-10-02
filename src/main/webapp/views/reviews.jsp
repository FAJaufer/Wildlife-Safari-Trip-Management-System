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
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">

        <div class="safari-card p-4 mb-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="safari-badge-sage text-uppercase">Reputation</span>
            </div>
            <h2 class="font-heading mb-1"><i class="bi bi-star me-2"></i>Customer Reviews</h2>
            <p class="text-muted small mb-0">Moderate ratings, comments, and photos submitted after completed trips</p>
        </div>

        <div class="table-responsive">
            <table class="table table-safari align-middle">
                <thead>
                <tr><th>Customer</th><th>Package</th><th>Rating</th><th>Comment</th><th>Photo</th><th>Status</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <% if (reviews != null) {
                    for (Review r : reviews) { %>
                <tr>
                    <td class="fw-semibold"><%= r.getUserName() %></td>
                    <td><%= r.getPackageType() %></td>
                    <td>
                        <span style="color: var(--safari-amber);">
                            <% for (int i = 0; i < r.getRating(); i++) { %>★<% } %><% for (int i = r.getRating(); i < 5; i++) { %>☆<% } %>
                        </span>
                    </td>
                    <td style="max-width: 250px;"><%= r.getComment() %></td>
                    <td>
                        <% if (r.getPhotoUrl() != null && !r.getPhotoUrl().isEmpty()) { %>
                        <img src="<%= r.getPhotoUrl() %>" style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px;" alt="review photo">
                        <% } else { %>
                        <span class="text-muted small">—</span>
                        <% } %>
                    </td>
                    <td>
                        <% if ("visible".equals(r.getStatus())) { %>
                        <span class="safari-badge-forest">Visible</span>
                        <% } else { %>
                        <span class="badge bg-secondary">Hidden</span>
                        <% } %>
                    </td>
                    <td>
                        <% if ("visible".equals(r.getStatus())) { %>
                        <a href="${pageContext.request.contextPath}/reviews?action=moderate&id=<%= r.getId() %>&status=hidden" class="btn btn-sm btn-safari-outline">Hide</a>
                        <% } else { %>
                        <a href="${pageContext.request.contextPath}/reviews?action=moderate&id=<%= r.getId() %>&status=visible" class="btn btn-sm btn-safari-outline">Show</a>
                        <% } %>
                        <a href="${pageContext.request.contextPath}/reviews?action=delete&id=<%= r.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Permanently delete this review?')">
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