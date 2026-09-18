<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Support Requests - Wildlife Safari</title>
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
    List<SupportRequest> requests = (List<SupportRequest>) request.getAttribute("requests");
    Boolean canManage = (Boolean) request.getAttribute("canManage");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">

        <div class="safari-card p-4 mb-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="safari-badge-amber text-uppercase">Support</span>
            </div>
            <h2 class="font-heading mb-1"><i class="bi bi-chat-dots me-2"></i>
                <%= Boolean.TRUE.equals(canManage) ? "All Support Requests" : "My Support Requests" %>
            </h2>
            <p class="text-muted small mb-0">Inquiries, complaints, and refund requests</p>
        </div>

        <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success d-flex align-items-center gap-2">
            <i class="bi bi-check-circle-fill"></i><div>Your request has been submitted!</div>
        </div>
        <% } %>

        <% if (!Boolean.TRUE.equals(canManage)) { %>
        <div class="safari-card-static p-4 mb-4">
            <h5 class="fw-bold mb-3"><i class="bi bi-plus-circle me-2"></i>Submit a New Request</h5>
            <form action="${pageContext.request.contextPath}/support" method="post">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold">Type</label>
                        <select name="requestType" class="form-select" required>
                            <option value="inquiry">Inquiry</option>
                            <option value="complaint">Complaint</option>
                            <option value="refund">Refund Request</option>
                        </select>
                    </div>
                    <div class="col-md-7">
                        <label class="form-label small fw-semibold">Details</label>
                        <textarea name="details" class="form-control" placeholder="Describe your issue..." rows="1" required></textarea>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-safari-amber w-100">Submit</button>
                    </div>
                </div>
            </form>
        </div>
        <% } %>

        <div class="safari-divider-route"><i class="bi bi-signpost-split"></i></div>

        <div class="table-responsive">
            <table class="table table-safari align-middle">
                <thead>
                <tr>
                    <% if (Boolean.TRUE.equals(canManage)) { %><th>From</th><% } %>
                    <th>Type</th><th>Details</th><th>Status</th>
                    <% if (Boolean.TRUE.equals(canManage)) { %><th>Update Status</th><% } %>
                </tr>
                </thead>
                <tbody>
                <% if (requests != null) {
                    for (SupportRequest r : requests) { %>
                <tr>
                    <% if (Boolean.TRUE.equals(canManage)) { %><td class="fw-semibold"><%= r.getUserName() %></td><% } %>
                    <td><span class="safari-badge-sand text-capitalize"><%= r.getRequestType() %></span></td>
                    <td><%= r.getDetails() %></td>
                    <td>
                        <% if ("open".equals(r.getStatus())) { %>
                        <span class="safari-badge-amber">Open</span>
                        <% } else if ("resolved".equals(r.getStatus())) { %>
                        <span class="safari-badge-forest">Resolved</span>
                        <% } else { %>
                        <span class="safari-badge-sage">In Progress</span>
                        <% } %>
                    </td>
                    <% if (Boolean.TRUE.equals(canManage)) { %>
                    <td>
                        <form action="${pageContext.request.contextPath}/support" method="get" class="d-flex gap-1">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="id" value="<%= r.getId() %>">
                            <select name="status" class="form-select form-select-sm">
                                <option value="open" <%= "open".equals(r.getStatus()) ? "selected" : "" %>>Open</option>
                                <option value="in_progress" <%= "in_progress".equals(r.getStatus()) ? "selected" : "" %>>In Progress</option>
                                <option value="resolved" <%= "resolved".equals(r.getStatus()) ? "selected" : "" %>>Resolved</option>
                            </select>
                            <button type="submit" class="btn btn-sm btn-safari-outline">Update</button>
                        </form>
                    </td>
                    <% } %>
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