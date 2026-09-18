<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - Wildlife Safari</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Safari Custom Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="d-flex flex-column min-vh-100">

<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 d-flex align-items-center py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-5 col-xl-4">
                <div class="safari-card p-4 p-md-5">
                    <div class="text-center mb-4">
                        <span class="fs-1 d-block mb-2">🦁</span>
                        <h3 class="font-heading mb-1">Begin Your Journey</h3>
                        <p class="text-muted small">Register for priority wildlife booking & expedition access</p>
                    </div>

                    <% if (request.getParameter("error") != null) { %>
                    <div class="alert alert-danger py-2 small d-flex align-items-center mb-3">
                        <i class="bi bi-exclamation-circle-fill me-2"></i>
                        That email address is already registered.
                    </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/register" method="post">
                        <div class="mb-3">
                            <label class="form-label small fw-semibold text-muted">Full Name</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-person text-muted"></i></span>
                                <input type="text" name="name" class="form-control border-start-0 ps-0" placeholder="e.g. Jane Doe" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold text-muted">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-envelope text-muted"></i></span>
                                <input type="email" name="email" class="form-control border-start-0 ps-0" placeholder="explorer@safari.com" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label small fw-semibold text-muted">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-lock text-muted"></i></span>
                                <input type="password" name="password" class="form-control border-start-0 ps-0" placeholder="Minimum 6 characters" required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-safari-amber w-100 py-2 mb-3 fw-bold">
                            Complete Registration
                        </button>
                    </form>

                    <div class="text-center pt-3 border-top">
                        <p class="small text-muted mb-0">
                            Already registered?
                            <a href="${pageContext.request.contextPath}/views/login.jsp" class="fw-semibold text-success">
                                Sign In here
                            </a>
                        </p>
                    </div>
                </div>

                <div class="text-center mt-3">
                    <a href="${pageContext.request.contextPath}/" class="small text-muted text-decoration-none">
                        <i class="bi bi-arrow-left me-1"></i> Back to Homepage
                    </a>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>