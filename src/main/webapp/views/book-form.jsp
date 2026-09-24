<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.SafariPackage" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Safari - Wildlife Safari</title>
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
    SafariPackage pkg = (SafariPackage) request.getAttribute("bookPackage");
    if (pkg == null) {
        response.sendRedirect(request.getContextPath() + "/bookings");
        return;
    }
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-6 col-md-8">
                <div class="safari-card p-4 p-md-5">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <span class="safari-badge-amber text-uppercase">Expedition Reservation</span>
                        <a href="${pageContext.request.contextPath}/bookings" class="small text-muted text-decoration-none">
                            <i class="bi bi-arrow-left"></i> Change Package
                        </a>
                    </div>

                    <h3 class="font-heading mb-1"><%= pkg.getSafariType() %></h3>
                    <p class="text-muted small mb-4">
                        <i class="bi bi-geo-alt text-warning me-1"></i> <%= pkg.getDestination() %> •
                        <i class="bi bi-clock text-warning mx-1"></i> <%= pkg.getDuration() %> •
                        <strong class="text-dark">$<%= pkg.getPrice() %></strong> / explorer
                    </p>

                    <% if ("full".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-danger d-flex align-items-center gap-2 mb-3">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <div>Slots are full for that date and time. Please choose a different slot.</div>
                    </div>
                    <% } %>

                    <form id="bookingForm" action="${pageContext.request.contextPath}/bookings" method="post">
                        <input type="hidden" name="packageId" value="<%= pkg.getId() %>">

                        <div class="mb-3">
                            <label class="form-label small fw-semibold text-muted">Select Safari Date</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-calendar-event text-muted"></i></span>
                                <input type="date" id="safariDate" name="safariDate" class="form-control border-start-0 ps-0" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold text-muted">Game Drive Time Slot</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-sun text-muted"></i></span>
                                <select id="timeSlot" name="timeSlot" class="form-select border-start-0 ps-0" required>
                                    <option value="Morning">Morning Safari (06:00 AM - 10:00 AM)</option>
                                    <option value="Afternoon">Afternoon Safari (02:30 PM - 06:30 PM)</option>
                                    <option value="Full Day">Full Day Wilderness Expedition</option>
                                </select>
                            </div>
                        </div>

                        <div id="availabilityMessage" class="mb-3"></div>

                        <div class="mb-4">
                            <label class="form-label small fw-semibold text-muted">Number of Participants</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-people text-muted"></i></span>
                                <input type="number" id="participants" name="participants" class="form-control border-start-0 ps-0" min="1" max="10" value="1" required oninput="calcTotal(this.value)">
                            </div>
                        </div>

                        <div class="p-3 bg-light rounded mb-4 d-flex justify-content-between align-items-center">
                            <div>
                                <span class="small text-muted d-block">Estimated Total</span>
                                <span class="fw-bold fs-4" style="color: var(--safari-amber);" id="totalPreview">$<%= pkg.getPrice() %></span>
                            </div>
                            <span class="safari-badge-forest">All Park Fees Included</span>
                        </div>

                        <button type="submit" id="submitBtn" class="btn btn-safari-amber w-100 py-3 fw-bold">
                            Proceed to Confirmation & Payment
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const basePrice = <%= pkg.getPrice() %>;
    function calcTotal(count) {
        const n = parseInt(count) || 1;
        document.getElementById('totalPreview').innerText = '$' + (basePrice * n).toFixed(2);
    }

    const contextPath = "${pageContext.request.contextPath}";
    const dateInput = document.getElementById('safariDate');
    const timeSlotSelect = document.getElementById('timeSlot');
    const messageDiv = document.getElementById('availabilityMessage');
    const submitBtn = document.getElementById('submitBtn');

    function checkAvailability() {
        const date = dateInput.value;
        const timeSlot = timeSlotSelect.value;

        if (!date || !timeSlot) {
            return;
        }

        messageDiv.innerHTML = '<div class="text-muted small"><i class="bi bi-hourglass-split me-1"></i>Checking availability...</div>';
        submitBtn.disabled = true;

        fetch(contextPath + '/bookings?action=checkAvailability&safariDate=' + encodeURIComponent(date) + '&timeSlot=' + encodeURIComponent(timeSlot))
            .then(res => res.text())
            .then(result => {
                if (result.trim() === 'available') {
                    messageDiv.innerHTML = '<div class="alert alert-success py-2 px-3 mb-0 small"><i class="bi bi-check-circle-fill me-1"></i>Slot available!</div>';
                    submitBtn.disabled = false;
                } else {
                    messageDiv.innerHTML = '<div class="alert alert-danger py-2 px-3 mb-0 small"><i class="bi bi-x-circle-fill me-1"></i>Slots are full for this date and time. Please choose a different slot.</div>';
                    submitBtn.disabled = true;
                }
            })
            .catch(() => {
                messageDiv.innerHTML = '';
                submitBtn.disabled = false;
            });
    }

    dateInput.addEventListener('change', checkAvailability);
    timeSlotSelect.addEventListener('change', checkAvailability);
</script>
</body>
</html>