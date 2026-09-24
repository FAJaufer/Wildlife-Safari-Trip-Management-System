<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Booking" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Checkout - Wildlife Safari</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .payment-method-card {
            cursor: pointer;
            border: 2px solid var(--safari-border);
            border-radius: var(--safari-radius-md);
            transition: all 0.2s ease-in-out;
        }
        .payment-method-card:hover {
            border-color: var(--safari-forest);
            background-color: var(--safari-forest-subtle);
        }
        .payment-method-card.selected {
            border-color: var(--safari-amber);
            background-color: var(--safari-amber-subtle);
        }
        .field-error {
            color: #dc3545;
            font-size: 0.8rem;
            margin-top: 0.25rem;
            display: none;
        }
        .is-invalid-custom {
            border-color: #dc3545 !important;
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
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/bookings?view=mine");
        return;
    }
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-5 col-md-6 mb-4">
                <div class="safari-card p-4 h-100">
                    <div class="d-flex align-items-center justify-content-between pb-3 mb-3 border-bottom">
                        <span class="safari-badge-amber text-uppercase">Expedition Summary</span>
                        <span class="badge bg-light text-dark border font-monospace"><%= booking.getBookingReference() %></span>
                    </div>

                    <h4 class="font-heading mb-3"><%= booking.getPackageType() != null ? booking.getPackageType() : "Safari Package" %></h4>

                    <ul class="list-group list-group-flush mb-4 small">
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span class="text-muted"><i class="bi bi-geo-alt text-warning me-2"></i>Destination</span>
                            <span class="fw-semibold"><%= booking.getDestination() != null ? booking.getDestination() : "Safari Park" %></span>
                        </li>
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span class="text-muted"><i class="bi bi-calendar-event text-warning me-2"></i>Safari Date</span>
                            <span class="fw-semibold"><%= booking.getSafariDate() %></span>
                        </li>
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span class="text-muted"><i class="bi bi-clock text-warning me-2"></i>Time Slot</span>
                            <span class="fw-semibold"><%= booking.getTimeSlot() %></span>
                        </li>
                        <li class="list-group-item px-0 d-flex justify-content-between align-items-center">
                            <span class="text-muted"><i class="bi bi-people text-warning me-2"></i>Explorers</span>
                            <span class="fw-semibold"><%= booking.getParticipants() %> <%= booking.getParticipants() == 1 ? "Person" : "People" %></span>
                        </li>
                    </ul>

                    <div class="p-3 rounded mt-auto" style="background-color: var(--safari-sand-light);">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="fw-bold fs-5">Total Amount Due:</span>
                            <span class="fw-bold fs-3 text-success">$<%= booking.getTotalCost() %></span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-7 col-md-6 mb-4">
                <div class="safari-card p-4 p-md-5">
                    <div class="mb-4">
                        <h4 class="font-heading mb-1">Encrypted Payment Gateway</h4>
                        <p class="text-muted small">Select your preferred payment method to finalize booking</p>
                    </div>

                    <% String err = request.getParameter("error"); %>
                    <% if (err != null) { %>
                    <div class="alert alert-danger d-flex align-items-center gap-2">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <div>
                            <% if ("card".equals(err)) { %>
                            Please enter a valid 16-digit card number.
                            <% } else if ("cvv".equals(err)) { %>
                            Please enter a valid 3-digit security code.
                            <% } else if ("expiry".equals(err)) { %>
                            Please enter a valid, non-expired expiry date (MM/YY).
                            <% } else { %>
                            Please check your payment details and try again.
                            <% } %>
                        </div>
                    </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/payments" method="post" id="paymentForm">
                        <input type="hidden" name="bookingId" value="<%= booking.getId() %>">

                        <div class="mb-4">
                            <label class="form-label small fw-semibold text-muted">Select Payment Method</label>
                            <div class="row g-2">
                                <div class="col-sm-4">
                                    <label class="payment-method-card p-3 d-block text-center selected" id="methodCard_credit">
                                        <input type="radio" name="paymentMethod" value="credit_card" class="d-none" checked onchange="handleMethodChange(this.value)">
                                        <i class="bi bi-credit-card-2-front fs-2 d-block mb-1" style="color: var(--safari-amber);"></i>
                                        <span class="fw-semibold small">Credit Card</span>
                                    </label>
                                </div>
                                <div class="col-sm-4">
                                    <label class="payment-method-card p-3 d-block text-center" id="methodCard_debit">
                                        <input type="radio" name="paymentMethod" value="debit_card" class="d-none" onchange="handleMethodChange(this.value)">
                                        <i class="bi bi-credit-card fs-2 d-block mb-1" style="color: var(--safari-forest);"></i>
                                        <span class="fw-semibold small">Debit Card</span>
                                    </label>
                                </div>
                                <div class="col-sm-4">
                                    <label class="payment-method-card p-3 d-block text-center" id="methodCard_bank">
                                        <input type="radio" name="paymentMethod" value="online_banking" class="d-none" onchange="handleMethodChange(this.value)">
                                        <i class="bi bi-bank fs-2 d-block mb-1" style="color: var(--safari-sage);"></i>
                                        <span class="fw-semibold small">Online Bank</span>
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div id="cardDetailsSection">
                            <div class="mb-3">
                                <label class="form-label small fw-semibold text-muted">Cardholder Name</label>
                                <input type="text" name="cardHolder" id="cardHolder" class="form-control" placeholder="<%= user.getName() %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-semibold text-muted">Card Number</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-credit-card-fill text-muted"></i></span>
                                    <input type="text" name="cardNumber" id="cardNumber" class="form-control border-start-0 ps-0" placeholder="4111 1111 1111 1111" maxlength="19" required inputmode="numeric">
                                </div>
                                <div class="field-error" id="cardNumberError">Card number must be exactly 16 digits.</div>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-semibold text-muted">Expiry Date</label>
                                    <input type="text" name="expiryDate" id="expiryDate" class="form-control" placeholder="MM/YY" maxlength="5" required inputmode="numeric">
                                    <div class="field-error" id="expiryError">Enter a valid future date (MM/YY).</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-semibold text-muted">Security Code (CVV)</label>
                                    <input type="password" name="cvv" id="cvv" class="form-control" placeholder="123" maxlength="3" required inputmode="numeric">
                                    <div class="field-error" id="cvvError">CVV must be exactly 3 digits.</div>
                                </div>
                            </div>
                        </div>

                        <div id="bankDetailsSection" class="d-none mb-3">
                            <div class="mb-3">
                                <label class="form-label small fw-semibold text-muted">Authorized Banking Portal</label>
                                <select class="form-select" name="bankSelect" id="bankSelect">
                                    <option value="boc">Bank of Ceylon (BOC)</option>
                                    <option value="commercial">Commercial Bank of Ceylon</option>
                                    <option value="hnb">Hatton National Bank (HNB)</option>
                                    <option value="sampath">Sampath Bank</option>
                                    <option value="peoples">People's Bank</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-semibold text-muted">Bank Account / Reference</label>
                                <input type="text" name="accountRef" id="accountRef" class="form-control" placeholder="Account identifier">
                            </div>
                        </div>

                        <div class="p-2 rounded mb-4 d-flex align-items-center" style="background-color: var(--safari-forest-subtle);">
                            <i class="bi bi-shield-check fs-5 me-2" style="color: var(--safari-forest);"></i>
                            <small class="mb-0" style="color: var(--safari-forest);">Encrypted 256-bit SSL transaction verified by Wildlife Safari Gateway.</small>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-safari-amber btn-lg fw-bold">
                                Confirm & Pay $<%= booking.getTotalCost() %>
                            </button>
                            <a href="${pageContext.request.contextPath}/bookings?view=mine" class="btn btn-outline-secondary">
                                Pay Later / Return to Bookings
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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

    // --- Card number: digits only, auto-space every 4 digits, max 16 digits ---
    const cardNumberInput = document.getElementById('cardNumber');
    cardNumberInput.addEventListener('input', function () {
        let digits = this.value.replace(/\D/g, '').slice(0, 16);
        this.value = digits.replace(/(.{4})/g, '$1 ').trim();
    });

    // --- CVV: digits only, max 3 ---
    const cvvInput = document.getElementById('cvv');
    cvvInput.addEventListener('input', function () {
        this.value = this.value.replace(/\D/g, '').slice(0, 3);
    });

    // --- Expiry: auto-insert slash after 2 digits (MM/YY) ---
    const expiryInput = document.getElementById('expiryDate');
    expiryInput.addEventListener('input', function () {
        let digits = this.value.replace(/\D/g, '').slice(0, 4);
        if (digits.length >= 3) {
            this.value = digits.slice(0, 2) + '/' + digits.slice(2);
        } else {
            this.value = digits;
        }
    });

    function isCardMethodSelected() {
        const method = document.querySelector('input[name="paymentMethod"]:checked').value;
        return method === 'credit_card' || method === 'debit_card';
    }

    function validateExpiry(value) {
        const match = /^(\d{2})\/(\d{2})$/.exec(value);
        if (!match) return false;
        const month = parseInt(match[1], 10);
        const year = parseInt('20' + match[2], 10);
        if (month < 1 || month > 12) return false;

        const now = new Date();
        const currentYear = now.getFullYear();
        const currentMonth = now.getMonth() + 1;

        if (year < currentYear) return false;
        if (year === currentYear && month < currentMonth) return false;
        return true;
    }

    document.getElementById('paymentForm').addEventListener('submit', function (e) {
        if (!isCardMethodSelected()) {
            return; // online banking — no card validation needed
        }

        let valid = true;

        const cardDigits = cardNumberInput.value.replace(/\D/g, '');
        const cardValid = cardDigits.length === 16;
        document.getElementById('cardNumberError').style.display = cardValid ? 'none' : 'block';
        cardNumberInput.classList.toggle('is-invalid-custom', !cardValid);
        if (!cardValid) valid = false;

        const cvvValid = /^\d{3}$/.test(cvvInput.value);
        document.getElementById('cvvError').style.display = cvvValid ? 'none' : 'block';
        cvvInput.classList.toggle('is-invalid-custom', !cvvValid);
        if (!cvvValid) valid = false;

        const expiryValid = validateExpiry(expiryInput.value);
        document.getElementById('expiryError').style.display = expiryValid ? 'none' : 'block';
        expiryInput.classList.toggle('is-invalid-custom', !expiryValid);
        if (!expiryValid) valid = false;

        if (!valid) {
            e.preventDefault();
        }
    });
</script>
</body>
</html>