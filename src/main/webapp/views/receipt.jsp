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
    <title>Payment Receipt - Wildlife Safari Trip Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        @media print {
            .no-print {
                display: none !important;
            }
            body {
                background-color: #fff !important;
            }
            .card {
                border: 1px solid #ddd !important;
                box-shadow: none !important;
            }
        }
        .receipt-card {
            border-radius: 1rem;
        }
        .stamp-badge {
            border: 2px dashed #198754;
            color: #198754;
            padding: 0.5rem 1.25rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: inline-block;
            border-radius: 6px;
        }
    </style>
</head>
<body class="bg-light">
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

<!-- Top Navbar (hidden on print) -->
<nav class="navbar navbar-dark bg-success no-print">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
        <div>
            <a class="btn btn-outline-light btn-sm me-2" href="${pageContext.request.contextPath}/bookings?view=mine">My Bookings</a>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        </div>
    </div>
</nav>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">

            <!-- Success Alert (hidden on print) -->
            <div class="alert alert-success d-flex align-items-center mb-4 no-print shadow-sm" role="alert">
                <i class="bi bi-check-circle-fill fs-3 me-3 text-success"></i>
                <div>
                    <h5 class="alert-heading mb-1">Payment Successful!</h5>
                    <p class="mb-0">Your payment has been processed and your safari booking is confirmed.</p>
                </div>
            </div>

            <!-- Receipt Container -->
            <div class="card receipt-card shadow-sm border-0 bg-white p-4 p-md-5 mb-4">
                <!-- Header -->
                <div class="d-flex justify-content-between align-items-start border-bottom pb-4 mb-4">
                    <div>
                        <h3 class="fw-bold text-success mb-1">🦁 Wildlife Safari Management</h3>
                        <p class="text-muted mb-0 small">Official Electronic Payment Receipt & Confirmation</p>
                    </div>
                    <div class="text-end">
                        <div class="stamp-badge">PAID</div>
                    </div>
                </div>

                <!-- Receipt Metadata Grid -->
                <div class="row mb-4">
                    <div class="col-sm-6 mb-3">
                        <span class="text-muted small d-block">Transaction / Receipt ID</span>
                        <strong class="fs-6 text-dark">#PAY-<%= payment.getId() %></strong>
                    </div>
                    <div class="col-sm-6 mb-3 text-sm-end">
                        <span class="text-muted small d-block">Date & Time</span>
                        <strong><%= formattedDate %></strong>
                    </div>
                    <div class="col-sm-6 mb-2">
                        <span class="text-muted small d-block">Customer Name</span>
                        <strong><%= user.getName() %></strong>
                        <span class="text-muted small d-block"><%= user.getEmail() %></span>
                    </div>
                    <div class="col-sm-6 mb-2 text-sm-end">
                        <span class="text-muted small d-block">Payment Method</span>
                        <strong><i class="bi bi-wallet2 me-1"></i><%= methodDisplay %></strong>
                    </div>
                </div>

                <!-- Booking Details Table -->
                <div class="table-responsive mb-4">
                    <table class="table table-bordered align-middle">
                        <thead class="table-light">
                        <tr>
                            <th>Description</th>
                            <th>Details</th>
                            <th class="text-end">Amount</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td>
                                <strong class="text-success"><%= booking.getPackageType() != null ? booking.getPackageType() : "Safari Package" %></strong>
                                <div class="text-muted small">
                                    <i class="bi bi-geo-alt"></i> <%= booking.getDestination() != null ? booking.getDestination() : "Safari Destination" %>
                                </div>
                            </td>
                            <td>
                                <div><small class="text-muted">Ref:</small> <code><%= booking.getBookingReference() %></code></div>
                                <div><small class="text-muted">Date:</small> <%= booking.getSafariDate() %> (<%= booking.getTimeSlot() %>)</div>
                                <div><small class="text-muted">Participants:</small> <%= booking.getParticipants() %> <%= booking.getParticipants() == 1 ? "person" : "people" %></div>
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

                <!-- Status and Notes -->
                <div class="bg-light p-3 rounded mb-2">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span class="text-muted small d-block">Payment Status</span>
                            <span class="badge bg-success text-uppercase"><%= payment.getStatus() %></span>
                        </div>
                        <div class="text-end">
                            <span class="text-muted small d-block">Booking Status</span>
                            <span class="badge bg-primary text-uppercase"><%= booking.getStatus() %></span>
                        </div>
                    </div>
                </div>

                <p class="text-muted small text-center mt-3 mb-0">
                    Thank you for choosing Wildlife Safari Management. Please present this receipt or your booking reference upon arrival.
                </p>
            </div>

            <!-- Action Buttons (hidden on print) -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 no-print">
                <button type="button" class="btn btn-outline-dark" onclick="window.print()">
                    <i class="bi bi-printer-fill me-2"></i>Print Receipt
                </button>
                <div>
                    <a href="${pageContext.request.contextPath}/bookings?view=mine" class="btn btn-success me-2">
                        <i class="bi bi-ticket-detailed me-2"></i>My Bookings
                    </a>
                    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline-secondary">
                        <i class="bi bi-house-door me-1"></i>Dashboard
                    </a>
                </div>
            </div>

        </div>
    </div>
</div>
</body>
</html>
