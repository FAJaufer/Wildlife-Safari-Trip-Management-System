<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Booking" %>
<%@ page import="com.wildlifesafari.model.Payment" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Receipt - Wildlife Safari</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Safari Custom Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        @media print {
            .no-print {
                display: none !important;
            }
            body {
                background-color: #ffffff !important;
            }
            .safari-card {
                border: 1px solid #ddd !important;
                box-shadow: none !important;
            }
        }
        .stamp-badge {
            border: 2px dashed var(--safari-forest);
            color: var(--safari-forest);
            padding: 0.5rem 1.25rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 2px;
            display: inline-block;
            border-radius: 6px;
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
    Payment payment = (Payment) request.getAttribute("payment");

    if (payment == null || booking == null) {
        response.sendRedirect(request.getContextPath() + "/bookings?view=mine");
        return;
    }

    String methodDisplay = payment.getPaymentMethod();
    if ("credit_card".equalsIgnoreCase(methodDisplay)) {
        methodDisplay = "Credit Card";
    } else if ("debit_card".equalsIgnoreCase(methodDisplay)) {
        methodDisplay = "Debit Card";
    } else if ("online_banking".equalsIgnoreCase(methodDisplay)) {
        methodDisplay = "Online Banking";
    }

    String formattedDate = payment.getPaymentDate() != null
            ? new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(payment.getPaymentDate())
            : "Just now";
%>

<!-- Navbar (hidden on print) -->
<div class="no-print">
    <jsp:include page="/views/common/navbar.jsp" />
</div>

<main class="flex-grow-1 py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8 col-md-10">

                <!-- Success Alert (hidden on print) -->
                <div class="alert alert-success d-flex align-items-center mb-4 no-print shadow-sm">
                    <i class="bi bi-check-circle-fill fs-3 me-3 text-success"></i>
                    <div>
                        <h5 class="alert-heading mb-1 fw-bold">Expedition Confirmed & Paid</h5>
                        <p class="mb-0 small">Your payment has been successfully recorded into the field dispatch system.</p>
                    </div>
                </div>

                <!-- Receipt Document Card -->
                <div class="safari-card p-4 p-md-5 mb-4 bg-white">
                    <!-- Invoice Header -->
                    <div class="d-flex justify-content-between align-items-start border-bottom pb-4 mb-4">
                        <div>
                            <div class="d-flex align-items-center gap-2 mb-1">
                                <span class="fs-3">🦁</span>
                                <h3 class="font-heading mb-0">Wildlife Safari</h3>
                            </div>
                            <p class="text-muted small mb-0">National Park Expedition Electronic Receipt</p>
                        </div>
                        <div class="text-end">
                            <div class="stamp-badge">PAID</div>
                        </div>
                    </div>

                    <!-- Metadata Grid -->
                    <div class="row g-3 mb-4">
                        <div class="col-sm-6">
                            <span class="text-muted small d-block">Transaction Identifier</span>
                            <strong class="font-monospace text-dark fs-6">#PAY-<%= payment.getId() %></strong>
                        </div>
                        <div class="col-sm-6 text-sm-end">
                            <span class="text-muted small d-block">Transaction Timestamp</span>
                            <strong><%= formattedDate %></strong>
                        </div>
                        <div class="col-sm-6">
                            <span class="text-muted small d-block">Explorer Name</span>
                            <strong><%= user.getName() %></strong>
                            <span class="text-muted small d-block"><%= user.getEmail() %></span>
                        </div>
                        <div class="col-sm-6 text-sm-end">
                            <span class="text-muted small d-block">Payment Method</span>
                            <strong><i class="bi bi-wallet2 me-1 text-warning"></i><%= methodDisplay %></strong>
                        </div>
                    </div>

                    <!-- Line Items Table -->
                    <div class="table-responsive mb-4">
                        <table class="table table-bordered align-middle">
                            <thead style="background-color: var(--safari-forest-subtle);">
                            <tr>
                                <th>Safari Trail Description</th>
                                <th>Schedule Details</th>
                                <th class="text-end">Amount</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>
                                    <strong style="color: var(--safari-forest);"><%= booking.getPackageType() != null ? booking.getPackageType() : "Safari Package" %></strong>
                                    <div class="text-muted small">
                                        <i class="bi bi-geo-alt text-warning"></i> <%= booking.getDestination() != null ? booking.getDestination() : "Safari Destination" %>
                                    </div>
                                </td>
                                <td>
                                    <div><small class="text-muted">Booking Reference:</small> <code><%= booking.getBookingReference() %></code></div>
                                    <div><small class="text-muted">Date:</small> <%= booking.getSafariDate() %> (<%= booking.getTimeSlot() %>)</div>
                                    <div><small class="text-muted">Explorers:</small> <%= booking.getParticipants() %> <%= booking.getParticipants() == 1 ? "Person" : "People" %></div>
                                </td>
                                <td class="text-end fw-bold">
                                    $<%= payment.getAmount() %>
                                </td>
                            </tr>
                            </tbody>
                            <tfoot>
                            <tr class="table-light">
                                <td colspan="2" class="text-end fw-bold fs-5">Total Paid:</td>
                                <td class="text-end fw-bold fs-5 text-success">$<%= payment.getAmount() %></td>
                            </tr>
                            </tfoot>
                        </table>
                    </div>

                    <!-- Badges Row -->
                    <div class="p-3 rounded mb-3" style="background-color: var(--safari-sand-light);">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small d-block">Payment Clearance</span>
                                <span class="safari-badge-forest text-uppercase"><%= payment.getStatus() %></span>
                            </div>
                            <div class="text-end">
                                <span class="text-muted small d-block">Booking Status</span>
                                <span class="safari-badge-amber text-uppercase"><%= booking.getStatus() %></span>
                            </div>
                        </div>
                    </div>

                    <p class="text-muted small text-center mt-3 mb-0">
                        Please present this digital invoice or reference code <strong><%= booking.getBookingReference() %></strong> at the park ranger checkpoint.
                    </p>
                </div>

                <!-- Print & Nav Buttons (hidden on print) -->
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 no-print">
                    <button type="button" class="btn btn-safari-outline" onclick="window.print()">
                        <i class="bi bi-printer me-2"></i>Print Invoice
                    </button>
                    <div>
                        <a href="${pageContext.request.contextPath}/bookings?view=mine" class="btn btn-safari-amber me-2">
                            <i class="bi bi-ticket-detailed me-1"></i> My Bookings
                        </a>
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline-secondary">
                            Dashboard
                        </a>
                    </div>
                </div>

            </div>
        </div>
    </div>
</main>

<div class="no-print">
    <jsp:include page="/views/common/footer.jsp" />
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
