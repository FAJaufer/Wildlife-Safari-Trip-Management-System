<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.SafariPackage" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Book Safari</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
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

<nav class="navbar navbar-dark bg-success">
  <div class="container-fluid">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🦁 Safari Management</a>
    <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/bookings">Back to Packages</a>
  </div>
</nav>

<div class="container mt-4" style="max-width: 500px;">
  <h2>📖 Book: <%= pkg.getSafariType() %></h2>
  <p class="text-muted"><%= pkg.getDestination() %> — <%= pkg.getDuration() %> — $<%= pkg.getPrice() %>/person</p>

  <form action="${pageContext.request.contextPath}/bookings" method="post" class="card p-4">
    <input type="hidden" name="packageId" value="<%= pkg.getId() %>">

    <div class="mb-3">
      <label class="form-label">Safari Date</label>
      <input type="date" name="safariDate" class="form-control" required>
    </div>
    <div class="mb-3">
      <label class="form-label">Time Slot</label>
      <select name="timeSlot" class="form-control" required>
        <option value="Morning">Morning</option>
        <option value="Afternoon">Afternoon</option>
        <option value="Evening">Evening</option>
      </select>
    </div>
    <div class="mb-3">
      <label class="form-label">Number of Participants</label>
      <input type="number" name="participants" class="form-control" min="1" value="1" required>
    </div>

    <button type="submit" class="btn btn-success w-100">Confirm Booking</button>
  </form>
</div>
</body>
</html>