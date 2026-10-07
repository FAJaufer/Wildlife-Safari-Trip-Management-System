<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.RefundRequest" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Refund Requests - Wildlife Safari</title>
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
    if (!(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    List<RefundRequest> refundRequests = (List<RefundRequest>) request.getAttribute("refundRequests");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">

        <div class="safari-card p-4 mb-4 bg-white">
            <span class="safari-badge-forest text-uppercase">Finance</span>
            <h2 class="font-heading mb-1 mt-2"><i class="bi bi-cash-coin me-2"></i>Refund Requests</h2>
            <p class="text-muted small mb-0">Review refund requests for cancelled, paid bookings</p>
        </div>

        <% if (success != null) { %>
        <div class="alert alert-success d-flex align-items-center gap-2">
            <i class="bi bi-check-circle-fill"></i>
            <div><%= "approved".equals(success) ? "Refund approved and the payment marked as refunded. Remember to send the money."
                    : "Refund request rejected." %></div>
        </div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger d-flex align-items-center gap-2">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <div><%= "handled".equals(error) ? "That request was already reviewed."
                    : "notfound".equals(error) ? "That request no longer exists."
                    : "Please check the details and try again." %></div>
        </div>
        <% } %>

        <div class="table-responsive">
            <table class="table table-safari align-middle">
                <thead>
                <tr>
                    <th>Booking</th><th>Customer</th><th>Amount</th><th>Reason</th><th>Requested</th><th>Status</th><th style="min-width: 260px;">Action</th>
                </tr>
                </thead>
                <tbody>
                <% if (refundRequests == null || refundRequests.isEmpty()) { %>
                <tr><td colspan="7" class="text-center text-muted py-4">No refund requests yet.</td></tr>
                <% } else {
                    for (RefundRequest r : refundRequests) { %>
                <tr>
                    <td><span class="badge bg-light text-dark border font-monospace"><%= r.getBookingReference() %></span></td>
                    <td><%= r.getUserName() %></td>
                    <td class="fw-semibold">$<%= r.getAmount() %></td>
                    <td class="small"><%= r.getReason() %></td>
                    <td class="small text-muted"><%= r.getCreatedAt() %></td>
                    <td>
                        <% if ("pending".equals(r.getStatus())) { %>
                        <span class="safari-badge-amber text-uppercase">Pending</span>
                        <% } else if ("approved".equals(r.getStatus())) { %>
                        <span class="safari-badge-forest text-uppercase">Approved</span>
                        <% } else { %>
                        <span class="badge bg-danger text-uppercase">Rejected</span>
                        <% } %>
                    </td>
                    <td>
                        <% if ("pending".equals(r.getStatus())) { %>
                        <form action="${pageContext.request.contextPath}/refunds" method="post" class="m-0">
                            <input type="hidden" name="action" value="review">
                            <input type="hidden" name="id" value="<%= r.getId() %>">
                            <input type="text" name="note" class="form-control form-control-sm mb-2" maxlength="500" placeholder="Note to customer (optional)">
                            <button type="submit" name="decision" value="approved" class="btn btn-sm btn-safari-amber"
                                    onclick="return confirm('Approve this refund of $<%= r.getAmount() %>?')">Approve</button>
                            <button type="submit" name="decision" value="rejected" class="btn btn-sm btn-outline-danger"
                                    onclick="return confirm('Reject this refund request?')">Reject</button>
                        </form>
                        <% } else { %>
                        <span class="small text-muted"><%= r.getAdminNote() != null ? r.getAdminNote() : "" %></span>
                        <% } %>
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