package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.BookingDAO;
import com.wildlifesafari.dao.PaymentDAO;
import com.wildlifesafari.dao.RefundRequestDAO;
import com.wildlifesafari.model.Booking;
import com.wildlifesafari.model.Payment;
import com.wildlifesafari.model.RefundRequest;
import com.wildlifesafari.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.List;

@WebServlet("/refunds")
public class RefundServlet extends HttpServlet {

    private final RefundRequestDAO refundDAO = new RefundRequestDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    private boolean isStaff(User user) {
        return user.getRole().equals("admin") || user.getRole().equals("manager");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }
        if (!isStaff(user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can view refund requests");
            return;
        }

        try {
            List<RefundRequest> requests = refundDAO.findAll();
            request.setAttribute("refundRequests", requests);
            request.getRequestDispatcher("/views/refunds.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading refund requests", e);
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

        String ctx = request.getContextPath();
        String action = request.getParameter("action");

        try {
            // ---------- TOURIST: REQUEST A REFUND ----------
            if ("request".equals(action)) {
                String back = ctx + "/bookings?view=mine&error=";

                int bookingId;
                try {
                    bookingId = Integer.parseInt(request.getParameter("bookingId"));
                } catch (NumberFormatException e) {
                    response.sendRedirect(back + "refundDenied");
                    return;
                }

                String reason = request.getParameter("reason");
                reason = (reason == null) ? "" : reason.trim();
                if (reason.isEmpty() || reason.length() > 500) {
                    response.sendRedirect(back + "refundInvalid");
                    return;
                }

                Booking booking = bookingDAO.findById(bookingId);
                if (booking == null || booking.getUserId() != user.getId()) {
                    response.sendRedirect(back + "refundDenied");
                    return;
                }
                if (!"cancelled".equalsIgnoreCase(booking.getStatus())) {
                    response.sendRedirect(back + "refundDenied");
                    return;
                }

                Payment payment = paymentDAO.findByBookingId(bookingId);
                if (payment == null || !"success".equals(payment.getStatus())) {
                    response.sendRedirect(back + "refundNoPayment");
                    return;
                }

                if (refundDAO.findByBookingId(bookingId) != null) {
                    response.sendRedirect(back + "refundExists");
                    return;
                }

                RefundRequest r = new RefundRequest();
                r.setBookingId(bookingId);
                r.setUserId(user.getId());
                r.setAmount(payment.getAmount());
                r.setReason(reason);

                try {
                    refundDAO.create(r);
                } catch (SQLIntegrityConstraintViolationException e) {
                    response.sendRedirect(back + "refundExists");
                    return;
                }

                response.sendRedirect(ctx + "/bookings?view=mine&refund=requested");
                return;
            }

            // ---------- STAFF: APPROVE / REJECT ----------
            if ("review".equals(action)) {
                if (!isStaff(user)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can review refunds");
                    return;
                }

                int id;
                try {
                    id = Integer.parseInt(request.getParameter("id"));
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/refunds?error=invalid");
                    return;
                }

                String decision = request.getParameter("decision");
                if (!"approved".equals(decision) && !"rejected".equals(decision)) {
                    response.sendRedirect(ctx + "/refunds?error=invalid");
                    return;
                }

                String note = request.getParameter("note");
                note = (note == null) ? "" : note.trim();
                if (note.length() > 500) {
                    response.sendRedirect(ctx + "/refunds?error=invalid");
                    return;
                }

                RefundRequest existing = refundDAO.findById(id);
                if (existing == null) {
                    response.sendRedirect(ctx + "/refunds?error=notfound");
                    return;
                }

                int changed = refundDAO.review(id, decision, note.isEmpty() ? null : note, user.getId());
                if (changed == 0) {
                    response.sendRedirect(ctx + "/refunds?error=handled");
                    return;
                }

                if ("approved".equals(decision)) {
                    paymentDAO.markRefunded(existing.getBookingId());
                }

                response.sendRedirect(ctx + "/refunds?success=" + decision);
                return;
            }

            response.sendRedirect(ctx + "/bookings?view=mine");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error processing refund", e);
        }
    }
}