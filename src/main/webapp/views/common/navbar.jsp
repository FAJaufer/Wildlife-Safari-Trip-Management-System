<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%
    User navUser = (User) session.getAttribute("loggedInUser");
    String navRole = (navUser != null) ? navUser.getRole() : null;
%>
<nav class="navbar navbar-expand-lg safari-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">
            <span>🦁</span>
            <span>Wildlife Safari</span>
            <span class="brand-badge ms-1">•</span>
        </a>

        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#safariNavMenu">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="safariNavMenu">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/"><i class="bi bi-compass me-1"></i> Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/bookings"><i class="bi bi-binoculars me-1"></i> Safaris</a>
                </li>

                <% if (navUser != null) { %>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/dashboard"><i class="bi bi-grid me-1"></i> Dashboard</a>
                </li>
                <% if ("tourist".equals(navRole)) { %>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/bookings?view=mine"><i class="bi bi-ticket-detailed me-1"></i> My Bookings</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/support"><i class="bi bi-chat-dots me-1"></i> Support</a>
                </li>
                <% } else if ("guide".equals(navRole)) { %>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/sightings"><i class="bi bi-camera me-1"></i> Sightings</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/schedules?view=mine"><i class="bi bi-calendar-check me-1"></i> My Trips</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/emergencies"><i class="bi bi-exclamation-octagon me-1"></i> Emergencies</a>
                </li>
                <% } else if ("driver".equals(navRole)) { %>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/schedules?view=mine"><i class="bi bi-truck me-1"></i> My Schedule</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/emergencies"><i class="bi bi-exclamation-octagon me-1"></i> Emergencies</a>
                </li>
                <% } else if ("support_officer".equals(navRole)) { %>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/support"><i class="bi bi-chat-dots me-1"></i> Support Requests</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/emergencies"><i class="bi bi-exclamation-octagon me-1"></i> Emergencies</a>
                </li>
                <% } else if ("admin".equals(navRole) || "manager".equals(navRole)) { %>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="bi bi-gear me-1"></i> Operations
                    </a>
                    <ul class="dropdown-menu border-0 shadow-sm">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/packages">Packages</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/schedules">Schedules</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vehicles">Vehicles</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/drivers">Drivers</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/guides">Guides</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/support">Support Requests</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emergencies">Emergency Reports</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/payments">Payment Records</a></li>
                    </ul>
                </li>
                <% } %>
                <% } %>
            </ul>

            <div class="d-flex align-items-center gap-2">
                <% if (navUser == null) { %>
                <a href="${pageContext.request.contextPath}/views/login.jsp" class="btn btn-safari-outline btn-sm">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Sign In
                </a>
                <a href="${pageContext.request.contextPath}/views/register.jsp" class="btn btn-safari-amber btn-sm">
                    Register
                </a>
                <% } else { %>
                <div class="d-flex align-items-center me-2">
                    <div class="text-end me-2 d-none d-sm-block">
                        <div class="fw-semibold small text-dark"><%= navUser.getName() %></div>
                        <span class="safari-badge-amber text-uppercase" style="font-size: 0.7rem; padding: 0.15rem 0.5rem;"><%= navRole %></span>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-secondary btn-sm" title="Log Out">
                    <i class="bi bi-box-arrow-right"></i>
                </a>
                <% } %>
            </div>
        </div>
    </div>
</nav>