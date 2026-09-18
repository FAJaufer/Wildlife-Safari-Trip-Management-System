<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Wildlife Safari</title>
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
    String role = user.getRole();
%>

<!-- Shared Navbar -->
<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">
        <!-- Dashboard Header -->
        <div class="safari-card p-4 mb-4 bg-white">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <span class="safari-badge-amber text-uppercase">Role: <%= role %></span>
                        <span class="text-muted small">• Active Session</span>
                    </div>
                    <h2 class="font-heading mb-1">Welcome back, <%= user.getName() %>!</h2>
                    <p class="text-muted small mb-0">Wildlife Safari Expedition & Operations Command Portal</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-primary btn-sm">
                        <i class="bi bi-compass me-1"></i> Browse Safaris
                    </a>
                </div>
            </div>
        </div>

        <!-- Quick Action Cards Grid -->
        <div class="row g-4">
            <% if (role.equals("admin") || role.equals("manager")) { %>
                <div class="col-md-4 col-sm-6">
                    <a href="${pageContext.request.contextPath}/packages" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-3">
                            <div class="p-3 rounded-circle" style="background: var(--safari-forest-subtle); color: var(--safari-forest);">
                                <i class="bi bi-map fs-3"></i>
                            </div>
                            <div>
                                <h5 class="mb-1 fw-bold text-dark">Safari Packages</h5>
                                <p class="text-muted small mb-0">Create and curate tour offerings</p>
                            </div>
                        </div>
                    </a>
                </div>

                <div class="col-md-4 col-sm-6">
                    <a href="${pageContext.request.contextPath}/schedules" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-3">
                            <div class="p-3 rounded-circle" style="background: var(--safari-amber-subtle); color: var(--safari-amber);">
                                <i class="bi bi-calendar-event fs-3"></i>
                            </div>
                            <div>
                                <h5 class="mb-1 fw-bold text-dark">Manage Schedules</h5>
                                <p class="text-muted small mb-0">Allocate guides, jeeps & drivers</p>
                            </div>
                        </div>
                    </a>
                </div>

                <div class="col-md-4 col-sm-6">
                    <a href="${pageContext.request.contextPath}/payments" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-3">
                            <div class="p-3 rounded-circle" style="background: var(--safari-sage-subtle); color: var(--safari-sage);">
                                <i class="bi bi-credit-card-2-front fs-3"></i>
                            </div>
                            <div>
                                <h5 class="mb-1 fw-bold text-dark">Payment Records</h5>
                                <p class="text-muted small mb-0">View revenue and billing receipts</p>
                            </div>
                        </div>
                    </a>
                </div>

                <div class="col-md-4 col-sm-6">
                    <a href="${pageContext.request.contextPath}/vehicles" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-3">
                            <div class="p-3 rounded-circle" style="background: var(--safari-forest-subtle); color: var(--safari-forest);">
                                <i class="bi bi-truck fs-3"></i>
                            </div>
                            <div>
                                <h5 class="mb-1 fw-bold text-dark">Fleet Vehicles</h5>
                                <p class="text-muted small mb-0">Manage 4x4 safari vehicles</p>
                            </div>
                        </div>
                    </a>
                </div>

                <div class="col-md-4 col-sm-6">
                    <a href="${pageContext.request.contextPath}/drivers" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-3">
                            <div class="p-3 rounded-circle" style="background: var(--safari-amber-subtle); color: var(--safari-amber);">
                                <i class="bi bi-person-badge fs-3"></i>
                            </div>
                            <div>
                                <h5 class="mb-1 fw-bold text-dark">Drivers Roster</h5>
                                <p class="text-muted small mb-0">Driver licensing & assignments</p>
                            </div>
                        </div>
                    </a>
                </div>

                <div class="col-md-4 col-sm-6">
                    <a href="${pageContext.request.contextPath}/guides" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-3">
                            <div class="p-3 rounded-circle" style="background: var(--safari-sage-subtle); color: var(--safari-sage);">
                                <i class="bi bi-compass fs-3"></i>
                            </div>
                            <div>
                                <h5 class="mb-1 fw-bold text-dark">Field Naturalists</h5>
                                <p class="text-muted small mb-0">Guide qualifications & tracking</p>
                            </div>
                        </div>
                    </a>
                </div>
            <% } %>

            <% if (role.equals("tourist")) { %>
                <div class="col-md-6">
                    <a href="${pageContext.request.contextPath}/bookings" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-4">
                            <div class="p-4 rounded-circle" style="background: var(--safari-forest-subtle); color: var(--safari-forest);">
                                <i class="bi bi-binoculars fs-1"></i>
                            </div>
                            <div>
                                <h4 class="font-heading mb-1 text-dark">Explore Safari Packages</h4>
                                <p class="text-muted small mb-0">Browse national parks, schedules, and book your next wilderness journey.</p>
                            </div>
                        </div>
                    </a>
                </div>

                <div class="col-md-6">
                    <a href="${pageContext.request.contextPath}/bookings?view=mine" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-4">
                            <div class="p-4 rounded-circle" style="background: var(--safari-amber-subtle); color: var(--safari-amber);">
                                <i class="bi bi-ticket-perforated fs-1"></i>
                            </div>
                            <div>
                                <h4 class="font-heading mb-1 text-dark">My Safari Bookings</h4>
                                <p class="text-muted small mb-0">View confirmation references, trip dates, payments, and digital receipts.</p>
                            </div>
                        </div>
                    </a>
                </div>
            <% } %>

            <% if (role.equals("guide")) { %>
                <div class="col-md-6">
                    <a href="${pageContext.request.contextPath}/sightings" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-4">
                            <div class="p-4 rounded-circle" style="background: var(--safari-sage-subtle); color: var(--safari-sage);">
                                <i class="bi bi-camera fs-1"></i>
                            </div>
                            <div>
                                <h4 class="font-heading mb-1 text-dark">Log Wildlife Sighting</h4>
                                <p class="text-muted small mb-0">Record animal species, park coordinates, and real-time sightings.</p>
                            </div>
                        </div>
                    </a>
                </div>

                <div class="col-md-6">
                    <a href="${pageContext.request.contextPath}/schedules?view=mine" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-4">
                            <div class="p-4 rounded-circle" style="background: var(--safari-forest-subtle); color: var(--safari-forest);">
                                <i class="bi bi-calendar-check fs-1"></i>
                            </div>
                            <div>
                                <h4 class="font-heading mb-1 text-dark">My Assigned Expeditions</h4>
                                <p class="text-muted small mb-0">View today's allocated safari trails, jeep details, and tourist groups.</p>
                            </div>
                        </div>
                    </a>
                </div>
            <% } %>

            <% if (role.equals("driver")) { %>
                <div class="col-md-6">
                    <a href="${pageContext.request.contextPath}/schedules?view=mine" class="text-decoration-none">
                        <div class="safari-card p-4 h-100 d-flex align-items-center gap-4">
                            <div class="p-4 rounded-circle" style="background: var(--safari-forest-subtle); color: var(--safari-forest);">
                                <i class="bi bi-truck fs-1"></i>
                            </div>
                            <div>
                                <h4 class="font-heading mb-1 text-dark">My Driving Schedule</h4>
                                <p class="text-muted small mb-0">Check vehicle assignments, pickup times, and trail destinations.</p>
                            </div>
                        </div>
                    </a>
                </div>
            <% } %>
        </div>
    </div>
</main>

<!-- Shared Footer -->
<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>