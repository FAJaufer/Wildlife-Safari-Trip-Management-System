<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Booking" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Write a Review - Wildlife Safari</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .star-rating {
            display: flex;
            flex-direction: row-reverse;
            justify-content: flex-end;
            gap: 4px;
            font-size: 2.2rem;
        }
        .star-rating input { display: none; }
        .star-rating label {
            color: #d8d8d8;
            cursor: pointer;
            transition: color 0.15s ease;
        }
        .star-rating input:checked ~ label,
        .star-rating label:hover,
        .star-rating label:hover ~ label {
            color: var(--safari-amber);
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    Booking booking = (Booking) request.getAttribute("booking");
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/bookings?view=mine");
        return;
    }
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-5">
    <div class="container" style="max-width: 600px;">
        <div class="safari-card p-4 p-md-5">
            <span class="safari-badge-amber text-uppercase mb-2 d-inline-block">Share Your Story</span>
            <h3 class="font-heading mb-1">How was your safari?</h3>
            <p class="text-muted small mb-4">
                <%= booking.getPackageType() %> — <%= booking.getDestination() %> — <%= booking.getSafariDate() %>
            </p>

            <% if ("badrating".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">Please select a star rating.</div>
            <% } %>

            <form action="${pageContext.request.contextPath}/reviews" method="post">
                <input type="hidden" name="bookingId" value="<%= booking.getId() %>">

                <div class="mb-4 text-center">
                    <label class="form-label small fw-semibold text-muted d-block mb-2">Your Rating</label>
                    <div class="star-rating">
                        <input type="radio" id="star5" name="rating" value="5"><label for="star5">★</label>
                        <input type="radio" id="star4" name="rating" value="4"><label for="star4">★</label>
                        <input type="radio" id="star3" name="rating" value="3"><label for="star3">★</label>
                        <input type="radio" id="star2" name="rating" value="2"><label for="star2">★</label>
                        <input type="radio" id="star1" name="rating" value="1"><label for="star1">★</label>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-muted">Your Experience</label>
                    <textarea name="comment" class="form-control" rows="4" placeholder="Tell other travelers about your trip..."></textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-semibold text-muted">Photo URL (optional)</label>
                    <input type="url" name="photoUrl" class="form-control" placeholder="https://...">
                </div>

                <button type="submit" class="btn btn-safari-amber w-100 fw-bold">
                    <i class="bi bi-send-check me-1"></i> Submit Review
                </button>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>