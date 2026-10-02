package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.BookingDAO;
import com.wildlifesafari.dao.ReviewDAO;
import com.wildlifesafari.dao.SafariScheduleDAO;
import com.wildlifesafari.model.Booking;
import com.wildlifesafari.model.Review;
import com.wildlifesafari.model.SafariSchedule;
import com.wildlifesafari.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/reviews")
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final SafariScheduleDAO scheduleDAO = new SafariScheduleDAO();

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
            if ("write".equals(action)) {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                Booking booking = bookingDAO.findById(bookingId);

                if (booking == null || booking.getUserId() != user.getId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "This booking doesn't belong to you");
                    return;
                }

                SafariSchedule schedule = scheduleDAO.findByBookingId(bookingId);
                if (schedule == null || !"completed".equals(schedule.getTripStatus())) {
                    response.sendRedirect(request.getContextPath() + "/bookings?view=mine&error=notcompleted");
                    return;
                }

                Review existing = reviewDAO.findByBookingId(bookingId);
                if (existing != null) {
                    response.sendRedirect(request.getContextPath() + "/bookings?view=mine&error=alreadyreviewed");
                    return;
                }

                request.setAttribute("booking", booking);
                request.getRequestDispatcher("/views/write-review.jsp").forward(request, response);
                return;
            }

            if ("moderate".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                reviewDAO.updateStatus(id, status);
                response.sendRedirect(request.getContextPath() + "/reviews");
                return;
            }

            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                reviewDAO.delete(id);
                response.sendRedirect(request.getContextPath() + "/reviews");
                return;
            }

            // Default: admin/manager moderation view of all reviews
            if (!(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can view all reviews");
                return;
            }

            List<Review> reviews = reviewDAO.findAll();
            request.setAttribute("reviews", reviews);
            request.getRequestDispatcher("/views/reviews.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading reviews", e);
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
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.findById(bookingId);

            if (booking == null || booking.getUserId() != user.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "This booking doesn't belong to you");
                return;
            }

            SafariSchedule schedule = scheduleDAO.findByBookingId(bookingId);
            if (schedule == null || !"completed".equals(schedule.getTripStatus())) {
                response.sendRedirect(request.getContextPath() + "/bookings?view=mine&error=notcompleted");
                return;
            }

            if (reviewDAO.findByBookingId(bookingId) != null) {
                response.sendRedirect(request.getContextPath() + "/bookings?view=mine&error=alreadyreviewed");
                return;
            }

            int rating = Integer.parseInt(request.getParameter("rating"));
            if (rating < 1 || rating > 5) {
                response.sendRedirect(request.getContextPath() + "/reviews?action=write&bookingId=" + bookingId + "&error=badrating");
                return;
            }

            String comment = request.getParameter("comment");
            String photoUrl = request.getParameter("photoUrl");

            Review r = new Review();
            r.setBookingId(bookingId);
            r.setUserId(user.getId());
            r.setPackageId(booking.getPackageId());
            r.setRating(rating);
            r.setComment(comment);
            r.setPhotoUrl(photoUrl);

            reviewDAO.create(r);

            response.sendRedirect(request.getContextPath() + "/bookings?view=mine&reviewSubmitted=1");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving review", e);
        }
    }
}