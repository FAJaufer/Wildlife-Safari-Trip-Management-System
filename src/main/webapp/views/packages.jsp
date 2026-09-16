<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.SafariPackage" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Safari Packages</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    boolean canManage = user.getRole().equals("admin") || user.getRole().equals("manager");
    SafariPackage editPackage = (SafariPackage) request.getAttribute("editPackage");
    List<SafariPackage> packages = (List<SafariPackage>) request.getAttribute("packages");
%>

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
    </div>
</nav>

<div class="container mt-4">
    <h2>🗺️ Safari Packages</h2>

    <% if (canManage) { %>
    <div class="card p-3 mb-4">
        <h5><%= editPackage != null ? "Edit Package" : "Add New Package" %></h5>
        <form action="${pageContext.request.contextPath}/packages" method="post">
            <% if (editPackage != null) { %>
            <input type="hidden" name="id" value="<%= editPackage.getId() %>">
            <% } %>
            <div class="row g-2">
                <div class="col-md-3">
                    <input type="text" name="safariType" class="form-control" placeholder="Safari Type"
                           value="<%= editPackage != null ? editPackage.getSafariType() : "" %>" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="destination" class="form-control" placeholder="Destination"
                           value="<%= editPackage != null ? editPackage.getDestination() : "" %>" required>
                </div>
                <div class="col-md-2">
                    <input type="text" name="duration" class="form-control" placeholder="Duration (e.g. 3 days)"
                           value="<%= editPackage != null ? editPackage.getDuration() : "" %>" required>
                </div>
                <div class="col-md-2">
                    <input type="number" step="0.01" name="price" class="form-control" placeholder="Price"
                           value="<%= editPackage != null ? editPackage.getPrice() : "" %>" required>
                </div>
                <div class="col-md-2">
                    <select name="availabilityStatus" class="form-control">
                        <option value="available" <%= (editPackage != null && "available".equals(editPackage.getAvailabilityStatus())) ? "selected" : "" %>>Available</option>
                        <option value="unavailable" <%= (editPackage != null && "unavailable".equals(editPackage.getAvailabilityStatus())) ? "selected" : "" %>>Unavailable</option>
                    </select>
                </div>
                <div class="col-md-12">
                    <textarea name="description" class="form-control" placeholder="Description" rows="2"><%= editPackage != null ? editPackage.getDescription() : "" %></textarea>
                </div>
                <div class="col-md-12">
                    <button type="submit" class="btn btn-success"><%= editPackage != null ? "Update" : "Add" %> Package</button>
                    <% if (editPackage != null) { %>
                    <a href="${pageContext.request.contextPath}/packages" class="btn btn-secondary">Cancel</a>
                    <% } %>
                </div>
            </div>
        </form>
    </div>
    <% } %>

    <table class="table table-striped">
        <thead>
        <tr>
            <th>Type</th><th>Destination</th><th>Duration</th><th>Price</th><th>Status</th>
            <% if (canManage) { %><th>Actions</th><% } %>
        </tr>
        </thead>
        <tbody>
        <% if (packages != null) {
            for (SafariPackage pkg : packages) { %>
        <tr>
            <td><%= pkg.getSafariType() %></td>
            <td><%= pkg.getDestination() %></td>
            <td><%= pkg.getDuration() %></td>
            <td>$<%= pkg.getPrice() %></td>
            <td><span class="badge <%= "available".equals(pkg.getAvailabilityStatus()) ? "bg-success" : "bg-secondary" %>"><%= pkg.getAvailabilityStatus() %></span></td>
            <% if (canManage) { %>
            <td>
                <a href="${pageContext.request.contextPath}/packages?action=edit&id=<%= pkg.getId() %>" class="btn btn-sm btn-primary">Edit</a>
                <a href="${pageContext.request.contextPath}/packages?action=delete&id=<%= pkg.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this package?')">Delete</a>
            </td>
            <% } %>
        </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>