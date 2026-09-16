package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.BookingDAO;
import com.wildlifesafari.dao.SafariPackageDAO;
import com.wildlifesafari.model.Booking;
import com.wildlifesafari.model.SafariPackage;
import com.wildlifesafari.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/bookings")
public class BookingServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final SafariPackageDAO packageDAO = new SafariPackageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("cancel".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                bookingDAO.updateStatus(id, "cancelled");
                response.sendRedirect(request.getContextPath() + "/bookings?view=mine");
                return;
            }

            if ("book".equals(action)) {
                // Show booking form for a specific package
                int packageId = Integer.parseInt(request.getParameter("packageId"));
                SafariPackage pkg = packageDAO.findById(packageId);
                request.setAttribute("bookPackage", pkg);
                request.getRequestDispatcher("/views/book-form.jsp").forward(request, response);
                return;
            }

            if ("mine".equals(request.getParameter("view"))) {
                // Tourist's own booking history
                List<Booking> myBookings = bookingDAO.findByUserId(user.getId());
                request.setAttribute("bookings", myBookings);
                request.getRequestDispatcher("/views/my-bookings.jsp").forward(request, response);
                return;
            }

            // Default: browse all available packages
            List<SafariPackage> packages = packageDAO.findAll();
            request.setAttribute("packages", packages);
            request.getRequestDispatcher("/views/browse-packages.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }

        try {
            int packageId = Integer.parseInt(request.getParameter("packageId"));
            Date safariDate = Date.valueOf(request.getParameter("safariDate"));
            String timeSlot = request.getParameter("timeSlot");
            int participants = Integer.parseInt(request.getParameter("participants"));

            SafariPackage pkg = packageDAO.findById(packageId);
            if (pkg == null || !"available".equals(pkg.getAvailabilityStatus())) {
                response.sendRedirect(request.getContextPath() + "/bookings?error=unavailable");
                return;
            }

            BigDecimal totalCost = pkg.getPrice().multiply(BigDecimal.valueOf(participants));

            Booking booking = new Booking();
            booking.setUserId(user.getId());
            booking.setPackageId(packageId);
            booking.setSafariDate(safariDate);
            booking.setTimeSlot(timeSlot);
            booking.setParticipants(participants);
            booking.setTotalCost(totalCost);
            booking.setStatus("confirmed");

            bookingDAO.create(booking);

            response.sendRedirect(request.getContextPath() + "/bookings?view=mine&success=1");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error creating booking", e);
        }
    }
}