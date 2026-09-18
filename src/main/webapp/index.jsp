<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.wildlifesafari.dao.SafariPackageDAO" %>
<%@ page import="com.wildlifesafari.model.SafariPackage" %>
<%@ page import="com.wildlifesafari.model.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wildlife Safari - Discover the Wild</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Safari Custom Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<!-- Navigation -->
<jsp:include page="/views/common/navbar.jsp" />

<!-- Hero Section -->
<section class="safari-hero">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-8 col-xl-7">
                <div class="d-inline-flex align-items-center gap-2 px-3 py-1 mb-3 rounded-pill" style="background: rgba(217, 139, 58, 0.2); border: 1px solid rgba(217, 139, 58, 0.4);">
                    <span class="text-warning">🐾</span>
                    <span class="text-white small fw-medium">Certified Luxury Wildlife Expeditions</span>
                </div>
                <h1 class="safari-hero-heading">
                    Discover the Wild.
                </h1>
                <p class="safari-hero-lead">
                    Where every journey becomes a story. Traverse untamed savannas, encounter elusive leopards, and track majestic elephant herds in supreme comfort.
                </p>
                <div class="d-flex flex-wrap gap-3">
                    <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-amber btn-lg px-4">
                        <i class="bi bi-compass me-1"></i> Explore Safaris
                    </a>
                    <a href="${pageContext.request.contextPath}/views/register.jsp" class="btn btn-safari-outline-light btn-lg px-4">
                        Book Your Safari
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Floating Booking & Quick Search Card -->
<div class="container safari-floating-search">
    <div class="safari-search-box">
        <form action="${pageContext.request.contextPath}/bookings" method="get">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label small fw-semibold text-muted mb-1">
                        <i class="bi bi-geo-alt text-warning me-1"></i> National Park / Destination
                    </label>
                    <select class="form-select" name="destination">
                        <option value="">All Wildlife Reserves</option>
                        <option value="Yala">Yala National Park</option>
                        <option value="Udawalawe">Udawalawe Elephant Sanctuary</option>
                        <option value="Wilpattu">Wilpattu Natural Reserve</option>
                        <option value="Minneriya">Minneriya National Park</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-semibold text-muted mb-1">
                        <i class="bi bi-calendar-event text-warning me-1"></i> Safari Date
                    </label>
                    <input type="date" class="form-control" name="safariDate">
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-semibold text-muted mb-1">
                        <i class="bi bi-people text-warning me-1"></i> Explorers
                    </label>
                    <select class="form-select" name="participants">
                        <option value="1">1 Person (Solo)</option>
                        <option value="2" selected>2 Persons (Couple)</option>
                        <option value="4">4 Persons (Family)</option>
                        <option value="6">6+ Persons (Group)</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-safari-amber w-100 py-2">
                        <i class="bi bi-search me-1"></i> Find Trips
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Safari Pillars / Features Section -->
<section class="container py-5 my-3">
    <div class="text-center mb-5">
        <span class="safari-badge-amber text-uppercase mb-2 d-inline-block">The Safari Experience</span>
        <h2 class="display-6 font-heading">Crafted For The Conscious Explorer</h2>
        <p class="text-muted max-w-600 mx-auto" style="max-width: 600px;">
            We pair conservation stewardship with bespoke field hospitality for indelible wildlife encounters.
        </p>
    </div>

    <div class="row g-4">
        <div class="col-md-4">
            <div class="safari-card p-4 h-100 text-center">
                <div class="d-inline-flex p-3 rounded-circle mb-3" style="background-color: var(--safari-forest-subtle); color: var(--safari-forest);">
                    <i class="bi bi-shield-shaded fs-2"></i>
                </div>
                <h5 class="fw-bold mb-2">Custom 4x4 Safari Jeeps</h5>
                <p class="text-muted small mb-0">
                    Raised suspension, unobstructed 360-degree viewing roofs, onboard GPS, and all-terrain capabilities certified for national park trails.
                </p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="safari-card p-4 h-100 text-center">
                <div class="d-inline-flex p-3 rounded-circle mb-3" style="background-color: var(--safari-amber-subtle); color: var(--safari-amber);">
                    <i class="bi bi-binoculars fs-2"></i>
                </div>
                <h5 class="fw-bold mb-2">Master Naturalists & Trackers</h5>
                <p class="text-muted small mb-0">
                    Led by licensed field guides with generational tracking expertise, animal behavior literacy, and real-time radio telemetry.
                </p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="safari-card p-4 h-100 text-center">
                <div class="d-inline-flex p-3 rounded-circle mb-3" style="background-color: var(--safari-sage-subtle); color: var(--safari-sage);">
                    <i class="bi bi-tree fs-2"></i>
                </div>
                <h5 class="fw-bold mb-2">Low-Impact Conservation</h5>
                <p class="text-muted small mb-0">
                    Strict adherence to park carrying capacity guidelines, buffer-zone etiquette, and support for local wildlife research projects.
                </p>
            </div>
        </div>
    </div>
</section>

<!-- Route Divider Motif -->
<div class="container">
    <div class="safari-divider-route">
        <span>🐾 🐾 🐾</span>
    </div>
</div>

<!-- Featured Safari Packages -->
<section class="container py-4">
    <div class="d-flex justify-content-between align-items-end mb-4 flex-wrap gap-2">
        <div>
            <span class="safari-badge-forest text-uppercase mb-2 d-inline-block">Curated Journeys</span>
            <h2 class="display-6 font-heading mb-0">Featured Safari Packages</h2>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-outline">
                View All Packages <i class="bi bi-arrow-right ms-1"></i>
            </a>
        </div>
    </div>

    <%
        List<SafariPackage> packages = null;
        try {
            SafariPackageDAO packageDAO = new SafariPackageDAO();
            packages = packageDAO.findAll();
        } catch (Exception ignored) {}
    %>

    <div class="row g-4">
        <% if (packages != null && !packages.isEmpty()) {
            int count = 0;
            String[] sampleImages = {
                "https://images.unsplash.com/photo-1534177616072-ef7dc120449d?auto=format&fit=crop&w=700&q=80",
                "https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?auto=format&fit=crop&w=700&q=80",
                "https://images.unsplash.com/photo-1575550959106-5a7defe28b56?auto=format&fit=crop&w=700&q=80"
            };
            for (SafariPackage pkg : packages) {
                if ("available".equalsIgnoreCase(pkg.getAvailabilityStatus())) {
                    String imgUrl = sampleImages[count % sampleImages.length];
                    count++;
        %>
            <div class="col-lg-4 col-md-6">
                <div class="safari-card h-100 d-flex flex-column">
                    <div style="height: 220px; overflow: hidden; position: relative;">
                        <img src="<%= imgUrl %>" alt="<%= pkg.getSafariType() %>" class="w-100 h-100 object-fit-cover" style="transition: transform 0.4s ease;" onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                        <span class="position-absolute top-0 end-0 m-3 safari-badge-amber">
                            <%= pkg.getDuration() %>
                        </span>
                    </div>
                    <div class="p-4 d-flex flex-column flex-grow-1">
                        <div class="text-muted small mb-1">
                            <i class="bi bi-geo-alt text-warning me-1"></i> <%= pkg.getDestination() %>
                        </div>
                        <h5 class="fw-bold mb-2 font-heading"><%= pkg.getSafariType() %></h5>
                        <p class="text-muted small flex-grow-1 line-clamp-2">
                            <%= pkg.getDescription() != null ? pkg.getDescription() : "Embark on an unforgettable wilderness journey through pristine habitat." %>
                        </p>
                        <div class="d-flex justify-content-between align-items-center pt-3 border-top mt-3">
                            <div>
                                <span class="small text-muted d-block">Starting from</span>
                                <span class="safari-price-tag">$<%= pkg.getPrice() %></span>
                                <span class="text-muted small">/ explorer</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/bookings?action=book&packageId=<%= pkg.getId() %>" class="btn btn-safari-primary">
                                Book Safari
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        <%
                if (count >= 3) break; // Display top 3 on home page
                }
            }
        } else {
        %>
            <!-- Fallback Curated Cards if database is empty -->
            <div class="col-lg-4 col-md-6">
                <div class="safari-card h-100 d-flex flex-column">
                    <img src="https://images.unsplash.com/photo-1534177616072-ef7dc120449d?auto=format&fit=crop&w=700&q=80" alt="Yala Leopard" class="w-100" style="height: 220px; object-fit: cover;">
                    <div class="p-4 d-flex flex-column flex-grow-1">
                        <div class="text-muted small mb-1"><i class="bi bi-geo-alt text-warning me-1"></i> Yala National Park</div>
                        <h5 class="fw-bold mb-2 font-heading">Apex Predator: Leopard Track</h5>
                        <p class="text-muted small flex-grow-1">Dawn game drive focused on the rocky terrain and high-density leopard corridors of Block 1.</p>
                        <div class="d-flex justify-content-between align-items-center pt-3 border-top mt-3">
                            <div>
                                <span class="small text-muted d-block">From</span>
                                <span class="safari-price-tag">$120.00</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-primary">Book Safari</a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6">
                <div class="safari-card h-100 d-flex flex-column">
                    <img src="https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?auto=format&fit=crop&w=700&q=80" alt="Udawalawe Elephants" class="w-100" style="height: 220px; object-fit: cover;">
                    <div class="p-4 d-flex flex-column flex-grow-1">
                        <div class="text-muted small mb-1"><i class="bi bi-geo-alt text-warning me-1"></i> Udawalawe Sanctuary</div>
                        <h5 class="fw-bold mb-2 font-heading">Great Elephant Gathering</h5>
                        <p class="text-muted small flex-grow-1">Witness wild elephant herds congregating at the reservoir alongside migratory raptors.</p>
                        <div class="d-flex justify-content-between align-items-center pt-3 border-top mt-3">
                            <div>
                                <span class="small text-muted d-block">From</span>
                                <span class="safari-price-tag">$95.00</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-primary">Book Safari</a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6">
                <div class="safari-card h-100 d-flex flex-column">
                    <img src="https://images.unsplash.com/photo-1575550959106-5a7defe28b56?auto=format&fit=crop&w=700&q=80" alt="Wilpattu" class="w-100" style="height: 220px; object-fit: cover;">
                    <div class="p-4 d-flex flex-column flex-grow-1">
                        <div class="text-muted small mb-1"><i class="bi bi-geo-alt text-warning me-1"></i> Wilpattu Natural Reserve</div>
                        <h5 class="fw-bold mb-2 font-heading">Willu Wilderness & Sloth Bear</h5>
                        <p class="text-muted small flex-grow-1">Deep-forest safari surrounding serene natural rainwater lakes (willus) inhabited by sloth bears.</p>
                        <div class="d-flex justify-content-between align-items-center pt-3 border-top mt-3">
                            <div>
                                <span class="small text-muted d-block">From</span>
                                <span class="safari-price-tag">$140.00</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/bookings" class="btn btn-safari-primary">Book Safari</a>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
    </div>
</section>

<!-- Footer -->
<jsp:include page="/views/common/footer.jsp" />

<!-- Bootstrap 5 Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
