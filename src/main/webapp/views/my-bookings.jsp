<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings - Wildlife Safari</title>
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
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    Set<Integer> paidBookingIds = (Set<Integer>) request.getAttribute("paidBookingIds");
    if (paidBookingIds == null) { paidBookingIds = new java.util.HashSet<>(); }
    Set<Integer> completedBookingIds = (Set<Integer>) request.getAttribute("completedBookingIds");
    if (completedBookingIds == null) { completedBookingIds = new java.util.HashSet<>(); }
    Set<Integer> reviewedBookingIds = (Set<Integer>) request.getAttribute("reviewedBookingIds");
    if (reviewedBookingIds == null) { reviewedBookingIds = new java.util.HashSet<>(); }
    java.util.Map<Integer, String> refundStatuses = (java.util.Map<Integer, String>) request.getAttribute("refundStatuses");
    if (refundStatuses == null) { refundStatuses = new java.util.HashMap<>(); }

    // Sort bookings into tabs
    java.time.LocalDate today = java.time.LocalDate.now();
    List<Booking> upcomingList = new ArrayList<>();
    List<Booking> pastList = new ArrayList<>();
    List<Booking> cancelledList = new ArrayList<>();
    if (bookings != null) {
        for (Booking b : bookings) {
            if ("cancelled".equalsIgnoreCase(b.getStatus())) {
                cancelledList.add(b);
            } else if (completedBookingIds.contains(b.getId())
                    || (b.getSafariDate() != null && b.getSafariDate().toLocalDate().isBefore(today))) {
                pastList.add(b);
            } else {
                upcomingList.add(b);
            }
        }
    }

    String[] tabKeys = {"upcoming", "past", "cancelled"};
    String[] tabLabels = {"Upcoming", "Past", "Cancelled"};
    String[] tabIcons = {"bi-calendar-event", "bi-clock-history", "bi-x-circle"};
    List<List<Booking>> groups = new ArrayList<>();
    groups.add(upcomingList);
    groups.add(pastList);
    groups.add(cancelledList);

    String errParam = request.getParameter("error");
    boolean openCancelled = "cancelled".equals(request.getParameter("success"))
            || request.getParameter("refund") != null
            || (errParam != null && errParam.startsWith("refund"));
    String activeTab = openCancelled ? "cancelled" : "upcoming";
%>

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">
        <div class="d-flex justify-content-between align-items-end mb-4 flex-wrap gap-2">
            <div>
                <span class="safari-badge-amber text-uppercase mb-2 d-inline-block">Expedition History</span>
                <h2 class="font-heading display-6 mb-1">My Safari Bookings</h2>
                <p class="text-muted small mb-0">Track confirmation details, review invoices, and manage upcoming trails</p>
            </div>
            <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-primary">
                <i class="bi bi-plus-circle me-1"></i> Book New Safari
            </a>
        </div>

        <% if ("cancelled".equals(request.getParameter("success"))) { %>
        <div class="alert alert-success d-flex align-items-center mb-4">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            Booking cancelled.
        </div>
        <% } else if (request.getParameter("success") != null) { %>
        <div class="alert alert-success d-flex align-items-center mb-4">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            Booking registered successfully!
        </div>
        <% } %>
        <% if ("requested".equals(request.getParameter("refund"))) { %>
        <div class="alert alert-success d-flex align-items-center mb-4">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            Refund request sent. We'll review it shortly.
        </div>
        <% } %>
        <% if (request.getParameter("reviewSubmitted") != null) { %>
        <div class="alert alert-success d-flex align-items-center mb-4">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            Thanks for sharing your review!
        </div>
        <% } %>
        <% if ("cancelDenied".equals(errParam)) { %>
        <div class="alert alert-danger d-flex align-items-center mb-4">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            That booking can't be cancelled from your account.
        </div>
        <% } else if ("notCancellable".equals(errParam)) { %>
        <div class="alert alert-warning d-flex align-items-center mb-4">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            Only confirmed, upcoming bookings can be cancelled.
        </div>
        <% } %>
        <% if (errParam != null && errParam.startsWith("refund")) { %>
        <div class="alert alert-danger d-flex align-items-center mb-4">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <%= "refundExists".equals(errParam) ? "A refund has already been requested for this booking."
                    : "refundNoPayment".equals(errParam) ? "This booking has no payment to refund."
                    : "refundInvalid".equals(errParam) ? "Please give a reason (up to 500 characters)."
                    : "That refund can't be requested from your account." %>
        </div>
        <% } %>
        <% if ("notcompleted".equals(errParam)) { %>
        <div class="alert alert-warning d-flex align-items-center mb-4">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            Reviews can only be submitted after your trip is marked completed.
        </div>
        <% } %>
        <% if ("alreadyreviewed".equals(errParam)) { %>
        <div class="alert alert-warning d-flex align-items-center mb-4">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            You've already reviewed this trip.
        </div>
        <% } %>

        <% if (bookings == null || bookings.isEmpty()) { %>
        <div class="safari-card">
            <div class="text-center py-5">
                <i class="bi bi-ticket-perforated text-muted fs-1 d-block mb-3"></i>
                <h5 class="text-muted">No Safari Bookings Found</h5>
                <p class="text-muted small mb-4">You haven't reserved any wildlife expeditions yet.</p>
                <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-amber">
                    Browse Safari Packages
                </a>
            </div>
        </div>
        <% } else { %>

        <ul class="nav nav-tabs mb-3" id="bookingTabs" role="tablist">
            <% for (int t = 0; t < tabKeys.length; t++) { %>
            <li class="nav-item" role="presentation">
                <button class="nav-link <%= tabKeys[t].equals(activeTab) ? "active" : "" %>"
                        id="tab-<%= tabKeys[t] %>" data-bs-toggle="tab"
                        data-bs-target="#pane-<%= tabKeys[t] %>" type="button" role="tab">
                    <i class="bi <%= tabIcons[t] %> me-1"></i><%= tabLabels[t] %>
                    <span class="badge bg-secondary ms-1"><%= groups.get(t).size() %></span>
                </button>
            </li>
            <% } %>
        </ul>

        <div class="tab-content">
            <% for (int t = 0; t < tabKeys.length; t++) {
                List<Booking> list = groups.get(t); %>
            <div class="tab-pane fade <%= tabKeys[t].equals(activeTab) ? "show active" : "" %>"
                 id="pane-<%= tabKeys[t] %>" role="tabpanel">
                <div class="safari-card">
                    <% if (list.isEmpty()) { %>
                    <div class="text-center py-5">
                        <i class="bi <%= tabIcons[t] %> text-muted fs-1 d-block mb-3"></i>
                        <h6 class="text-muted mb-0">No <%= tabLabels[t].toLowerCase() %> bookings</h6>
                    </div>
                    <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead style="background-color: var(--safari-forest-subtle); color: var(--safari-forest);">
                            <tr>
                                <th class="ps-4">Reference</th>
                                <th>Package & Park</th>
                                <th>Date & Slot</th>
                                <th>Explorers</th>
                                <th>Total Cost</th>
                                <th>Status</th>
                                <th class="text-end pe-4">Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% for (Booking b : list) {
                                boolean paid = paidBookingIds.contains(b.getId());
                                boolean completed = completedBookingIds.contains(b.getId());
                                boolean reviewed = reviewedBookingIds.contains(b.getId());
                                boolean canCancel = "confirmed".equals(b.getStatus()) && !completed
                                        && b.getSafariDate() != null
                                        && !b.getSafariDate().toLocalDate().isBefore(today);
                                String refundStatus = refundStatuses.get(b.getId());

                                String badgeClass;
                                if ("confirmed".equalsIgnoreCase(b.getStatus())) {
                                    badgeClass = "safari-badge-forest";
                                } else if ("cancelled".equalsIgnoreCase(b.getStatus())) {
                                    badgeClass = "badge bg-danger";
                                } else {
                                    badgeClass = "safari-badge-amber";
                                }
                            %>
                            <tr>
                                <td class="ps-4">
                                    <span class="badge bg-light text-dark border font-monospace fs-6">
                                        <%= b.getBookingReference() %>
                                    </span>
                                </td>
                                <td>
                                    <strong class="text-dark"><%= b.getPackageType() %></strong>
                                    <div class="small text-muted"><i class="bi bi-geo-alt text-warning me-1"></i><%= b.getDestination() %></div>
                                </td>
                                <td>
                                    <div><i class="bi bi-calendar-event me-1 text-muted"></i><%= b.getSafariDate() %></div>
                                    <small class="text-muted"><%= b.getTimeSlot() %></small>
                                </td>
                                <td>
                                    <%= b.getParticipants() %> <%= b.getParticipants() == 1 ? "Person" : "People" %>
                                </td>
                                <td class="fw-bold text-success">
                                    $<%= b.getTotalCost() %>
                                </td>
                                <td>
                                    <span class="<%= badgeClass %> text-uppercase"><%= b.getStatus() %></span>
                                    <% if (paid) { %>
                                    <span class="safari-badge-sage text-uppercase ms-1"><i class="bi bi-check-circle-fill me-1"></i>Paid</span>
                                    <% } %>
                                </td>
                                <td class="text-end pe-4">
                                    <% if (paid) { %>
                                    <a href="${pageContext.request.contextPath}/payments?action=pay&bookingId=<%= b.getId() %>" class="btn btn-sm btn-safari-outline me-1">
                                        <i class="bi bi-receipt me-1"></i>View Receipt
                                    </a>
                                    <% } else if ("confirmed".equals(b.getStatus()) && canCancel) { %>
                                    <a href="${pageContext.request.contextPath}/payments?action=pay&bookingId=<%= b.getId() %>" class="btn btn-sm btn-safari-amber me-1">
                                        <i class="bi bi-credit-card me-1"></i>Pay Now
                                    </a>
                                    <% } %>

                                    <% if (canCancel) { %>
                                    <form action="${pageContext.request.contextPath}/bookings" method="post" class="d-inline"
                                          onsubmit="return confirm('<%= paid ? "This booking is already paid. Cancel it anyway?" : "Cancel this booking?" %>')">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="id" value="<%= b.getId() %>">
                                        <button type="submit" class="btn btn-sm btn-outline-danger">Cancel</button>
                                    </form>
                                    <% } %>

                                    <% if (refundStatus != null) { %>
                                    <% if ("pending".equals(refundStatus)) { %>
                                    <span class="safari-badge-amber text-uppercase">Refund pending</span>
                                    <% } else if ("approved".equals(refundStatus)) { %>
                                    <span class="safari-badge-forest text-uppercase">Refund approved</span>
                                    <% } else { %>
                                    <span class="badge bg-danger text-uppercase">Refund rejected</span>
                                    <% } %>
                                    <% } else if ("cancelled".equalsIgnoreCase(b.getStatus()) && paid) { %>
                                    <button type="button" class="btn btn-sm btn-safari-amber"
                                            data-bs-toggle="modal" data-bs-target="#refundModal"
                                            data-booking-id="<%= b.getId() %>"
                                            data-booking-ref="<%= b.getBookingReference() %>">
                                        <i class="bi bi-cash-coin me-1"></i>Request Refund
                                    </button>
                                    <% } %>

                                    <% if (completed && !reviewed) { %>
                                    <a href="${pageContext.request.contextPath}/reviews?action=write&bookingId=<%= b.getId() %>" class="btn btn-sm btn-safari-amber me-1">
                                        <i class="bi bi-star me-1"></i>Write Review
                                    </a>
                                    <% } else if (completed && reviewed) { %>
                                    <span class="safari-badge-sage"><i class="bi bi-check-circle-fill me-1"></i>Reviewed</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</main>

<div class="modal fade" id="refundModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form class="modal-content" action="${pageContext.request.contextPath}/refunds" method="post">
            <input type="hidden" name="action" value="request">
            <input type="hidden" name="bookingId" id="refundBookingId">
            <div class="modal-header">
                <h5 class="modal-title">Request a Refund</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="small text-muted mb-3">Booking <strong id="refundBookingRef"></strong></p>
                <label class="form-label small fw-semibold">Reason for refund</label>
                <textarea name="reason" class="form-control" rows="3" maxlength="500" required></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-safari-outline" data-bs-dismiss="modal">Close</button>
                <button type="submit" class="btn btn-safari-amber">Send Request</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('refundModal').addEventListener('show.bs.modal', function (e) {
        var btn = e.relatedTarget;
        document.getElementById('refundBookingId').value = btn.getAttribute('data-booking-id');
        document.getElementById('refundBookingRef').textContent = btn.getAttribute('data-booking-ref');
    });
</script>
</body>
</html>