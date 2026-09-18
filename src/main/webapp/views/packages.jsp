<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.SafariPackage" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Safari Packages - Wildlife Safari</title>
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
    boolean canManage = user.getRole().equals("admin") || user.getRole().equals("manager");
    SafariPackage editPackage = (SafariPackage) request.getAttribute("editPackage");
    List<SafariPackage> packages = (List<SafariPackage>) request.getAttribute("packages");
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">

        <div class="safari-card p-4 mb-4 bg-white">
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="safari-badge-forest text-uppercase">Operations</span>
            </div>
            <h2 class="font-heading mb-1"><i class="bi bi-map me-2"></i>Safari Packages</h2>
            <p class="text-muted small mb-0">Curate and maintain your tour offerings</p>
        </div>

        <% if (canManage) { %>
        <div class="safari-card-static p-4 mb-4">
            <h5 class="fw-bold mb-3">
                <i class="bi bi-<%= editPackage != null ? "pencil-square" : "plus-circle" %> me-2"></i>
                <%= editPackage != null ? "Edit Package" : "Add New Package" %>
            </h5>
            <form action="${pageContext.request.contextPath}/packages" method="post">
                <% if (editPackage != null) { %>
                <input type="hidden" name="id" value="<%= editPackage.getId() %>">
                <% } %>
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold">Safari Type</label>
                        <input type="text" name="safariType" class="form-control" placeholder="e.g. Jeep Safari"
                               value="<%= editPackage != null ? editPackage.getSafariType() : "" %>" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold">Destination</label>
                        <input type="text" name="destination" class="form-control" placeholder="e.g. Yala National Park"
                               value="<%= editPackage != null ? editPackage.getDestination() : "" %>" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold">Duration</label>
                        <input type="text" name="duration" class="form-control" placeholder="e.g. 3 days"
                               value="<%= editPackage != null ? editPackage.getDuration() : "" %>" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold">Price</label>
                        <input type="number" step="0.01" name="price" class="form-control" placeholder="0.00"
                               value="<%= editPackage != null ? editPackage.getPrice() : "" %>" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold">Availability</label>
                        <select name="availabilityStatus" class="form-select">
                            <option value="available" <%= (editPackage != null && "available".equals(editPackage.getAvailabilityStatus())) ? "selected" : "" %>>Available</option>
                            <option value="unavailable" <%= (editPackage != null && "unavailable".equals(editPackage.getAvailabilityStatus())) ? "selected" : "" %>>Unavailable</option>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label small fw-semibold">Description</label>
                        <textarea name="description" class="form-control" placeholder="Describe the experience..." rows="2"><%= editPackage != null ? editPackage.getDescription() : "" %></textarea>
                    </div>
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-safari-amber">
                            <i class="bi bi-check2-circle me-1"></i> <%= editPackage != null ? "Update" : "Add" %> Package
                        </button>
                        <% if (editPackage != null) { %>
                        <a href="${pageContext.request.contextPath}/packages" class="btn btn-safari-outline">Cancel</a>
                        <% } %>
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
                    <th>Type</th><th>Destination</th><th>Duration</th><th>Price</th><th>Status</th>
                    <% if (canManage) { %><th>Actions</th><% } %>
                </tr>
                </thead>
                <tbody>
                <% if (packages != null) {
                    for (SafariPackage pkg : packages) { %>
                <tr>
                    <td class="fw-semibold"><%= pkg.getSafariType() %></td>
                    <td><%= pkg.getDestination() %></td>
                    <td><%= pkg.getDuration() %></td>
                    <td class="safari-price-tag" style="font-size: 1rem;">$<%= pkg.getPrice() %></td>
                    <td>
                        <% if ("available".equals(pkg.getAvailabilityStatus())) { %>
                        <span class="safari-badge-forest">Available</span>
                        <% } else { %>
                        <span class="badge bg-secondary">Unavailable</span>
                        <% } %>
                    </td>
                    <% if (canManage) { %>
                    <td>
                        <a href="${pageContext.request.contextPath}/packages?action=edit&id=<%= pkg.getId() %>" class="btn btn-sm btn-safari-outline">Edit</a>
                        <a href="${pageContext.request.contextPath}/packages?action=delete&id=<%= pkg.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this package?')">Delete</a>
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