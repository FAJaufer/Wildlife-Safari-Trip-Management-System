<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.*" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Support Requests</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    List<SupportRequest> requests = (List<SupportRequest>) request.getAttribute("requests");
    Boolean canManage = (Boolean) request.getAttribute("canManage");
%>

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
    </div>
</nav>

<div class="container mt-4">
    <h2>💬 <%= Boolean.TRUE.equals(canManage) ? "All Support Requests" : "My Support Requests" %></h2>

    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success">Your request has been submitted!</div>
    <% } %>

    <% if (!Boolean.TRUE.equals(canManage)) { %>
    <div class="card p-3 mb-4">
        <h5>Submit a New Request</h5>
        <form action="${pageContext.request.contextPath}/support" method="post">
            <div class="row g-2">
                <div class="col-md-3">
                    <select name="requestType" class="form-control" required>
                        <option value="inquiry">Inquiry</option>
                        <option value="complaint">Complaint</option>
                        <option value="refund">Refund Request</option>
                    </select>
                </div>
                <div class="col-md-7">
                    <textarea name="details" class="form-control" placeholder="Describe your issue..." rows="1" required></textarea>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-success w-100">Submit</button>
                </div>
            </div>
        </form>
    </div>
    <% } %>

    <table class="table table-striped">
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
            <% if (Boolean.TRUE.equals(canManage)) { %><td><%= r.getUserName() %></td><% } %>
            <td><%= r.getRequestType() %></td>
            <td><%= r.getDetails() %></td>
            <td>
                <span class="badge <%=
                    "open".equals(r.getStatus()) ? "bg-warning" :
                    "resolved".equals(r.getStatus()) ? "bg-success" : "bg-info"
                %>"><%= r.getStatus() %></span>
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
                    <button type="submit" class="btn btn-sm btn-primary">Update</button>
                </form>
            </td>
            <% } %>
        </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>