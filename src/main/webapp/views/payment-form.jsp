<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Booking" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - Wildlife Safari Trip Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        .payment-method-card {
            cursor: pointer;
            border: 2px solid #dee2e6;
            border-radius: 0.5rem;
            transition: all 0.2s ease-in-out;
        }
        .payment-method-card:hover {
            border-color: #198754;
            background-color: #f8fdf9;
        }
        .payment-method-card.selected {
            border-color: #198754;
            background-color: #e8f5e9;
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
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/bookings?view=mine");
        return;
    }
%>

<nav class="navbar navbar-dark bg-success">
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
        <!-- Booking Summary Column -->
        <div class="col-lg-5 col-md-6 mb-4">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-white py-3 border-bottom">
                    <h5 class="card-title mb-0 text-success fw-bold">
                        <i class="bi bi-ticket-perforated me-2"></i>Trip Summary
                    </h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <span class="text-muted small">Booking Reference</span>
                        <h6 class="fw-bold text-dark"><%= booking.getBookingReference() %></h6>
                    </div>
                    <ul class="list-group list-group-flush mb-4">
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-compass me-2 text-muted"></i>Package</span>
                            <span class="fw-semibold"><%= booking.getPackageType() != null ? booking.getPackageType() : "Safari Package" %></span>
                        </li>
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-geo-alt me-2 text-muted"></i>Destination</span>
                            <span class="fw-semibold"><%= booking.getDestination() != null ? booking.getDestination() : "Safari Park" %></span>
                        </li>
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-calendar-event me-2 text-muted"></i>Safari Date</span>
                            <span><%= booking.getSafariDate() %></span>
                        </li>
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-clock me-2 text-muted"></i>Time Slot</span>
                            <span><%= booking.getTimeSlot() %></span>
                        </li>
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-people me-2 text-muted"></i>Participants</span>
                            <span><%= booking.getParticipants() %> <%= booking.getParticipants() == 1 ? "Person" : "People" %></span>
                        </li>
                    </ul>

                    <div class="p-3 bg-success-subtle rounded text-dark">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="fw-bold fs-5">Total Due:</span>
                            <span class="fw-bold fs-3 text-success">$<%= booking.getTotalCost() %></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Payment Checkout Column -->
        <div class="col-lg-7 col-md-6 mb-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3 border-bottom">
                    <h5 class="card-title mb-0 text-success fw-bold">
                        <i class="bi bi-credit-card me-2"></i>Secure Payment Checkout
                    </h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/payments" method="post" id="paymentForm">
                        <input type="hidden" name="bookingId" value="<%= booking.getId() %>">

                        <!-- Payment Method Selector -->
                        <div class="mb-4">
                            <label class="form-label fw-bold">Select Payment Method</label>
                            <div class="row g-3">
                                <div class="col-sm-4">
                                    <label class="payment-method-card p-3 d-block text-center selected" id="methodCard_credit">
                                        <input type="radio" name="paymentMethod" value="credit_card" class="d-none" checked onchange="handleMethodChange(this.value)">
                                        <i class="bi bi-credit-card-2-front fs-2 text-success d-block mb-1"></i>
                                        <span class="fw-semibold">Credit Card</span>
                                    </label>
                                </div>
                                <div class="col-sm-4">
                                    <label class="payment-method-card p-3 d-block text-center" id="methodCard_debit">
                                        <input type="radio" name="paymentMethod" value="debit_card" class="d-none" onchange="handleMethodChange(this.value)">
                                        <i class="bi bi-credit-card fs-2 text-success d-block mb-1"></i>
                                        <span class="fw-semibold">Debit Card</span>
                                    </label>
                                </div>
                                <div class="col-sm-4">
                                    <label class="payment-method-card p-3 d-block text-center" id="methodCard_bank">
                                        <input type="radio" name="paymentMethod" value="online_banking" class="d-none" onchange="handleMethodChange(this.value)">
                                        <i class="bi bi-bank fs-2 text-success d-block mb-1"></i>
                                        <span class="fw-semibold">Online Banking</span>
                                    </label>
                                </div>
                            </div>
                        </div>

                        <!-- Card Details Section (for Credit/Debit Card) -->
                        <div id="cardDetailsSection">
                            <div class="mb-3">
                                <label class="form-label">Cardholder Name</label>
                                <input type="text" id="cardHolder" class="form-control" placeholder="e.g. <%= user.getName() %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Card Number</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-credit-card-fill"></i></span>
                                    <input type="text" id="cardNumber" class="form-control" placeholder="4111 2222 3333 4444" maxlength="19" required>
                                </div>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Expiration Date</label>
                                    <input type="text" id="expiryDate" class="form-control" placeholder="MM/YY" maxlength="5" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Security Code (CVV)</label>
                                    <input type="password" id="cvv" class="form-control" placeholder="123" maxlength="4" required>
                                </div>
                            </div>
                        </div>

                        <!-- Bank Details Section (for Online Banking) -->
                        <div id="bankDetailsSection" class="d-none mb-3">
                            <div class="mb-3">
                                <label class="form-label">Select Bank</label>
                                <select class="form-select" id="bankSelect">
                                    <option value="boc">Bank of Ceylon (BOC)</option>
                                    <option value="commercial">Commercial Bank of Ceylon</option>
                                    <option value="hnb">Hatton National Bank (HNB)</option>
                                    <option value="sampath">Sampath Bank</option>
                                    <option value="peoples">People's Bank</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Account / Reference Number</label>
                                <input type="text" id="accountRef" class="form-control" placeholder="e.g. 8001234567">
                            </div>
                        </div>

                        <div class="alert alert-info py-2 d-flex align-items-center mb-4">
                            <i class="bi bi-shield-lock-fill fs-5 me-2 text-success"></i>
                            <small class="mb-0">This transaction is encrypted and verified through the Safari Payment Gateway.</small>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-success btn-lg fw-bold">
                                Pay Now $<%= booking.getTotalCost() %>
                            </button>
                            <a href="${pageContext.request.contextPath}/bookings?view=mine" class="btn btn-outline-secondary">
                                Pay Later / Back to My Bookings
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function handleMethodChange(method) {
        document.querySelectorAll('.payment-method-card').forEach(card => card.classList.remove('selected'));
        const cardSection = document.getElementById('cardDetailsSection');
        const bankSection = document.getElementById('bankDetailsSection');
        const cardInputs = cardSection.querySelectorAll('input');
        const bankInputs = bankSection.querySelectorAll('input, select');

        if (method === 'credit_card' || method === 'debit_card') {
            document.getElementById(method === 'credit_card' ? 'methodCard_credit' : 'methodCard_debit').classList.add('selected');
            cardSection.classList.remove('d-none');
            bankSection.classList.add('d-none');
            cardInputs.forEach(i => i.setAttribute('required', 'required'));
            bankInputs.forEach(i => i.removeAttribute('required'));
        } else if (method === 'online_banking') {
            document.getElementById('methodCard_bank').classList.add('selected');
            cardSection.classList.add('d-none');
            bankSection.classList.remove('d-none');
            cardInputs.forEach(i => i.removeAttribute('required'));
            bankInputs.forEach(i => i.setAttribute('required', 'required'));
        }
    }
</script>
</body>
</html>
