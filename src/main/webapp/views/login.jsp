<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - Wildlife Safari Trip Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container d-flex justify-content-center align-items-center" style="min-height: 100vh;">
    <div class="card p-4 shadow" style="width: 400px;">
        <h3 class="mb-3 text-center">🦁 Safari Login</h3>

        <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger">Invalid email or password.</div>
        <% } %>
        <% if (request.getParameter("registered") != null) { %>
        <div class="alert alert-success">Account created! Please log in.</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="mb-3">
                <label class="form-label">Email</label>
                <input type="email" name="email" class="form-control" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-success w-100">Login</button>
        </form>

        <p class="text-center mt-3">
            Don't have an account? <a href="${pageContext.request.contextPath}/views/register.jsp">Register here</a>
        </p>
    </div>
</div>
</body>
</html>