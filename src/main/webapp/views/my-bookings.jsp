<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings - Wildlife Safari</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Safari Custom Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="d-flex flex-column min-vh-100">
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    Set<Integer> paidBookingIds = (Set<Integer>) request.getAttribute("paidBookingIds");
    if (paidBookingIds == null) { paidBookingIds = new java.util.HashSet<>(); }
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">
        <div class="d-flex justify-content-between align-items-end mb-4 flex-wrap gap-2">
            <div>
                <span class="safari-badge-amber text-uppercase mb-2 d-inline-block">Expedition History</span>
                <h2 class="font-heading display-6 mb-1">My Safari Bookings</h2>
                <p class="text-muted small mb-0">Track confirmation details, review invoices, and manage upcoming trails</p>
            </div>
            <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-primary">
                <i class="bi bi-plus-circle me-1"></i> Book New Safari
            </a>
        </div>

        <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success d-flex align-items-center mb-4">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            Booking registered successfully!
        </div>
        <% } %>

        <div class="safari-card">
            <% if (bookings == null || bookings.isEmpty()) { %>
                <div class="text-center py-5">
                    <i class="bi bi-ticket-perforated text-muted fs-1 d-block mb-3"></i>
                    <h5 class="text-muted">No Safari Bookings Found</h5>
                    <p class="text-muted small mb-4">You haven't reserved any wildlife expeditions yet.</p>
                    <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-amber">
                        Browse Safari Packages
                    </a>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead style="background-color: var(--safari-forest-subtle); color: var(--safari-forest);">
                        <tr>
                            <th class="ps-4">Reference</th>
                            <th>Package & Park</th>
                            <th>Date & Slot</th>
                            <th>Explorers</th>
                            <th>Total Cost</th>
                            <th>Status</th>
                            <th class="text-end pe-4">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Booking b : bookings) { %>
                        <tr>
                            <td class="ps-4">
                                <span class="badge bg-light text-dark border font-monospace fs-6">
                                    <%= b.getBookingReference() %>
                                </span>
                            </td>
                            <td>
                                <strong class="text-dark"><%= b.getPackageType() %></strong>
                                <div class="small text-muted"><i class="bi bi-geo-alt text-warning me-1"></i><%= b.getDestination() %></div>
                            </td>
                            <td>
                                <div><i class="bi bi-calendar-event me-1 text-muted"></i><%= b.getSafariDate() %></div>
                                <small class="text-muted"><%= b.getTimeSlot() %></small>
                            </td>
                            <td>
                                <%= b.getParticipants() %> <%= b.getParticipants() == 1 ? "Person" : "People" %>
                            </td>
                            <td class="fw-bold text-success">
                                $<%= b.getTotalCost() %>
                            </td>
                            <td>
                                <%
                                    String badgeClass = "safari-badge-forest";
                                    if ("confirmed".equalsIgnoreCase(b.getStatus())) {
                                        badgeClass = "safari-badge-forest";
                                    } else if ("cancelled".equalsIgnoreCase(b.getStatus())) {
                                        badgeClass = "badge bg-danger";
                                    } else {
                                        badgeClass = "safari-badge-amber";
                                    }
                                    boolean isPaid = paidBookingIds.contains(b.getId());
                                %>
                                <span class="<%= badgeClass %> text-uppercase"><%= b.getStatus() %></span>
                                <% if (isPaid) { %>
                                <span class="safari-badge-sage text-uppercase ms-1"><i class="bi bi-check-circle-fill me-1"></i>Paid</span>
                                <% } %>
                            </td>
                            <td class="text-end pe-4">
                                <% boolean paid = paidBookingIds.contains(b.getId()); %>
                                <% if (paid) { %>
                                <a href="${pageContext.request.contextPath}/payments?action=pay&bookingId=<%= b.getId() %>" class="btn btn-sm btn-safari-outline me-1">
                                    <i class="bi bi-receipt me-1"></i>View Receipt
                                </a>
                                <% } else if ("confirmed".equals(b.getStatus())) { %>
                                <a href="${pageContext.request.contextPath}/payments?action=pay&bookingId=<%= b.getId() %>" class="btn btn-sm btn-safari-amber me-1">
                                    <i class="bi bi-credit-card me-1"></i>Pay Now
                                </a>
                                <a href="${pageContext.request.contextPath}/bookings?action=cancel&id=<%= b.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Cancel this booking?')">
                                    Cancel
                                </a>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>