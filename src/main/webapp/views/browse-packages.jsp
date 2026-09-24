<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="com.wildlifesafari.model.SafariPackage" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Safari Packages - Wildlife Safari</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Safari Custom Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="d-flex flex-column min-vh-100">
<%
    User user = (User) session.getAttribute("loggedInUser");
    List<SafariPackage> packages = (List<SafariPackage>) request.getAttribute("packages");
%>

<!-- Navigation -->
<jsp:include page="/views/common/navbar.jsp" />

<main class="flex-grow-1 py-4">
    <div class="container">
        <!-- Header Banner -->
        <div class="d-flex justify-content-between align-items-end mb-4 flex-wrap gap-2">
            <div>
                <span class="safari-badge-amber text-uppercase mb-2 d-inline-block">Expedition Catalog</span>
                <h2 class="font-heading display-6 mb-1">Curated Safari Packages</h2>
                <p class="text-muted small mb-0">Select an adventure trail across Sri Lanka's renowned wilderness reserves</p>
            </div>
            <% if (user != null && "tourist".equals(user.getRole())) { %>
                <a href="${pageContext.request.contextPath}/bookings?view=mine" class="btn btn-safari-outline">
                    <i class="bi bi-ticket-detailed me-1"></i> My Bookings
                </a>
            <% } %>
        </div>

        <!-- Search & Filter Bar -->
        <div class="safari-card p-3 mb-4">
            <div class="row g-2 align-items-center">
                <div class="col-md-5">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" id="filterInput" class="form-control border-start-0" placeholder="Search by park, animal, or package name..." onkeyup="filterCards()">
                    </div>
                </div>
                <div class="col-md-4">
                    <select id="parkFilter" class="form-select" onchange="filterCards()">
                        <option value="">All Wildlife Parks</option>
                        <option value="Yala">Yala National Park</option>
                        <option value="Udawalawe">Udawalawe</option>
                        <option value="Wilpattu">Wilpattu</option>
                        <option value="Minneriya">Minneriya</option>
                    </select>
                </div>
                <div class="col-md-3 text-md-end">
                    <span class="small text-muted" id="resultsCount">
                        <%= packages != null ? packages.size() : 0 %> Expeditions available
                    </span>
                </div>
            </div>
        </div>

        <!-- Package Cards Grid -->
        <div class="row g-4" id="packageGrid">
            <% if (packages != null && !packages.isEmpty()) {
                int imgIdx = 0;
                String[] safariPhotos = {
                    "https://images.unsplash.com/photo-1534177616072-ef7dc120449d?auto=format&fit=crop&w=700&q=80",
                    "https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?auto=format&fit=crop&w=700&q=80",
                    "https://images.unsplash.com/photo-1575550959106-5a7defe28b56?auto=format&fit=crop&w=700&q=80",
                    "https://images.unsplash.com/photo-1549366021-9f761d450615?auto=format&fit=crop&w=700&q=80",
                    "https://images.unsplash.com/photo-1516426122078-c23e76319801?auto=format&fit=crop&w=700&q=80"
                };

                for (SafariPackage pkg : packages) {
                    if ("available".equalsIgnoreCase(pkg.getAvailabilityStatus())) {
                        String photo = safariPhotos[imgIdx % safariPhotos.length];
                        imgIdx++;
            %>
            <div class="col-lg-4 col-md-6 package-item"
                 data-title="<%= pkg.getSafariType().toLowerCase() %>"
                 data-dest="<%= pkg.getDestination().toLowerCase() %>"
                 data-desc="<%= pkg.getDescription() != null ? pkg.getDescription().toLowerCase() : "" %>">
                <div class="safari-card h-100 d-flex flex-column">
                    <div style="height: 220px; overflow: hidden; position: relative;">
                        <img src="<%= photo %>" alt="<%= pkg.getSafariType() %>" class="w-100 h-100 object-fit-cover" style="transition: transform 0.4s ease;" onmouseover="this.style.transform='scale(1.04)'" onmouseout="this.style.transform='scale(1)'">
                        <span class="position-absolute top-0 end-0 m-3 safari-badge-amber">
                            <%= pkg.getDuration() %>
                        </span>
                        <span class="position-absolute bottom-0 start-0 m-3 safari-badge-forest bg-white">
                            <i class="bi bi-geo-alt-fill text-warning me-1"></i><%= pkg.getDestination() %>
                        </span>
                    </div>

                    <div class="p-4 d-flex flex-column flex-grow-1">
                        <h5 class="fw-bold font-heading mb-2"><%= pkg.getSafariType() %></h5>
                        <p class="text-muted small flex-grow-1">
                            <%= pkg.getDescription() != null ? pkg.getDescription() : "Explore pristine wilderness and track signature species with certified park guides." %>
                        </p>

                        <div class="d-flex justify-content-between align-items-center pt-3 border-top mt-3">
                            <div>
                                <span class="small text-muted d-block">Price</span>
                                <span class="safari-price-tag">$<%= pkg.getPrice() %></span>
                                <span class="text-muted small">/ person</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/bookings?action=book&packageId=<%= pkg.getId() %>" class="btn btn-safari-primary">
                                Book Safari
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <% } } } else { %>
            <div class="col-12 text-center py-5">
                <div class="safari-card p-5">
                    <i class="bi bi-compass text-muted fs-1 mb-3 d-block"></i>
                    <h5 class="text-muted">No Safari Packages Currently Available</h5>
                    <p class="text-muted small mb-0">Please check back soon or contact park management.</p>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function filterCards() {
        const query = document.getElementById('filterInput').value.toLowerCase();
        const park = document.getElementById('parkFilter').value.toLowerCase();
        const items = document.querySelectorAll('.package-item');
        let visibleCount = 0;

        items.forEach(item => {
            const title = item.getAttribute('data-title') || '';
            const dest = item.getAttribute('data-dest') || '';
            const desc = item.getAttribute('data-desc') || '';

            const matchesQuery = !query || title.includes(query) || dest.includes(query) || desc.includes(query);
            const matchesPark = !park || dest.includes(park);

            if (matchesQuery && matchesPark) {
                item.style.display = '';
                visibleCount++;
            } else {
                item.style.display = 'none';
            }
        });

        document.getElementById('resultsCount').innerText = visibleCount + ' Expeditions available';
    }
</script>
</body>
</html>