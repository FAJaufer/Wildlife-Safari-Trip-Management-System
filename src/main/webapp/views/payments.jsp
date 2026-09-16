<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Payment" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Records - Wildlife Safari Trip Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="bg-light">
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    if (!(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can view all payments");
        return;
    }

    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
    BigDecimal totalRevenue = (BigDecimal) request.getAttribute("totalRevenue");
    if (totalRevenue == null) {
        totalRevenue = BigDecimal.ZERO;
    }
    int transactionCount = (payments != null) ? payments.size() : 0;
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <div class="d-flex align-items-center">
            <span class="navbar-text text-white me-3">
                <%= user.getName() %> (<%= user.getRole() %>)
            </span>
            <a class="btn btn-outline-light btn-sm me-2" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">Logout</a>
        </div>
    </div>
</nav>

<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h2 class="fw-bold mb-1">💳 Payment & Revenue Management</h2>
            <p class="text-muted mb-0">Overview of all customer payments and transactions</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left me-1"></i>Back to Dashboard
            </a>
        </div>
    </div>

    <!-- Summary Statistics Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-6 col-lg-4">
            <div class="card shadow-sm border-0 bg-white p-3 h-100 border-start border-success border-4">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small text-uppercase fw-semibold">Total Revenue</span>
                        <h3 class="fw-bold text-success mb-0 mt-1">$<%= totalRevenue %></h3>
                    </div>
                    <div class="bg-success-subtle p-3 rounded-circle text-success">
                        <i class="bi bi-cash-stack fs-3"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="card shadow-sm border-0 bg-white p-3 h-100 border-start border-primary border-4">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small text-uppercase fw-semibold">Completed Transactions</span>
                        <h3 class="fw-bold text-primary mb-0 mt-1"><%= transactionCount %></h3>
                    </div>
                    <div class="bg-primary-subtle p-3 rounded-circle text-primary">
                        <i class="bi bi-receipt fs-3"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-12 col-lg-4">
            <div class="card shadow-sm border-0 bg-white p-3 h-100 border-start border-info border-4">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small text-uppercase fw-semibold">Average Value</span>
                        <h3 class="fw-bold text-dark mb-0 mt-1">
                            $<%= transactionCount > 0 ? totalRevenue.divide(new BigDecimal(transactionCount), 2, java.math.RoundingMode.HALF_UP) : "0.00" %>
                        </h3>
                    </div>
                    <div class="bg-info-subtle p-3 rounded-circle text-info">
                        <i class="bi bi-graph-up-arrow fs-3"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Payments Table Card -->
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h5 class="card-title mb-0 fw-bold">Recent Payment Transactions</h5>
            <div style="max-width: 300px;" class="w-100">
                <input type="text" id="searchInput" class="form-control form-control-sm" placeholder="Search reference or method..." onkeyup="filterPayments()">
            </div>
        </div>
        <div class="card-body p-0">
            <% if (payments == null || payments.isEmpty()) { %>
            <div class="text-center py-5">
                <i class="bi bi-credit-card text-muted" style="font-size: 3rem;"></i>
                <h5 class="text-muted mt-3">No payments recorded yet</h5>
                <p class="text-muted small">Transactions will appear here once tourists book and pay for safari packages.</p>
            </div>
            <% } else { %>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="paymentsTable">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4">ID</th>
                        <th>Booking Reference</th>
                        <th>Amount</th>
                        <th>Payment Method</th>
                        <th>Payment Date</th>
                        <th>Status</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Payment p : payments) {
                        String methodBadge = "bg-secondary";
                        String methodLabel = p.getPaymentMethod();
                        if ("credit_card".equalsIgnoreCase(methodLabel)) {
                            methodBadge = "bg-primary";
                            methodLabel = "Credit Card";
                        } else if ("debit_card".equalsIgnoreCase(methodLabel)) {
                            methodBadge = "bg-info text-dark";
                            methodLabel = "Debit Card";
                        } else if ("online_banking".equalsIgnoreCase(methodLabel)) {
                            methodBadge = "bg-warning text-dark";
                            methodLabel = "Online Banking";
                        }

                        String dateStr = (p.getPaymentDate() != null)
                                ? dateFormat.format(p.getPaymentDate())
                                : "—";
                    %>
                    <tr>
                        <td class="ps-4 fw-semibold text-muted">#<%= p.getId() %></td>
                        <td>
                            <span class="badge bg-light text-dark border font-monospace fs-6">
                                <%= p.getBookingReference() != null ? p.getBookingReference() : "Booking #" + p.getBookingId() %>
                            </span>
                        </td>
                        <td class="fw-bold text-success">$<%= p.getAmount() %></td>
                        <td>
                            <span class="badge <%= methodBadge %>"><%= methodLabel %></span>
                        </td>
                        <td class="text-muted small"><%= dateStr %></td>
                        <td>
                            <span class="badge bg-success text-uppercase"><%= p.getStatus() %></span>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>
</div>

<script>
    function filterPayments() {
        const query = document.getElementById('searchInput').value.toLowerCase();
        const rows = document.querySelectorAll('#paymentsTable tbody tr');
        rows.forEach(row => {
            const text = row.innerText.toLowerCase();
            row.style.display = text.includes(query) ? '' : 'none';
        });
    }
</script>
</body>
</html>
