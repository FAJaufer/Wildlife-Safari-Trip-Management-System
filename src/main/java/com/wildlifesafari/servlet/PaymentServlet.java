package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.BookingDAO;
import com.wildlifesafari.dao.PaymentDAO;
import com.wildlifesafari.model.Booking;
import com.wildlifesafari.model.Payment;
import com.wildlifesafari.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.YearMonth;
import java.util.List;
import java.util.regex.Pattern;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    private static final Pattern CARD_NUMBER_PATTERN = Pattern.compile("^\\d{16}$");
    private static final Pattern CVV_PATTERN = Pattern.compile("^\\d{3}$");
    private static final Pattern EXPIRY_PATTERN = Pattern.compile("^(0[1-9]|1[0-2])/\\d{2}$");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }

        try {
            if ("pay".equals(request.getParameter("action"))) {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                Booking booking = bookingDAO.findById(bookingId);

                if (booking == null || booking.getUserId() != user.getId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "This booking doesn't belong to you");
                    return;
                }

                Payment existing = paymentDAO.findByBookingId(bookingId);
                if (existing != null) {
                    request.setAttribute("payment", existing);
                    request.setAttribute("booking", booking);
                    request.getRequestDispatcher("/views/receipt.jsp").forward(request, response);
                    return;
                }

                request.setAttribute("booking", booking);
                request.getRequestDispatcher("/views/payment-form.jsp").forward(request, response);
                return;
            }

            if (!(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can view all payments");
                return;
            }

            List<Payment> payments = paymentDAO.findAll();
            BigDecimal totalRevenue = paymentDAO.getTotalRevenue();
            request.setAttribute("payments", payments);
            request.setAttribute("totalRevenue", totalRevenue);
            request.getRequestDispatcher("/views/payments.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading payments", e);
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
            String paymentMethod = request.getParameter("paymentMethod");

            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null || booking.getUserId() != user.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "This booking doesn't belong to you");
                return;
            }

            // Server-side validation — never trust the client-side JS alone.
            // Card details are validated for format only and never persisted anywhere.
            if ("credit_card".equals(paymentMethod) || "debit_card".equals(paymentMethod)) {

                String cardNumberRaw = request.getParameter("cardNumber");
                String cardNumberDigits = (cardNumberRaw != null) ? cardNumberRaw.replaceAll("\\s+", "") : "";
                if (!CARD_NUMBER_PATTERN.matcher(cardNumberDigits).matches()) {
                    redirectWithError(request, response, bookingId, "card");
                    return;
                }

                String cvv = request.getParameter("cvv");
                if (cvv == null || !CVV_PATTERN.matcher(cvv).matches()) {
                    redirectWithError(request, response, bookingId, "cvv");
                    return;
                }

                String expiry = request.getParameter("expiryDate");
                if (expiry == null || !EXPIRY_PATTERN.matcher(expiry).matches() || !isFutureExpiry(expiry)) {
                    redirectWithError(request, response, bookingId, "expiry");
                    return;
                }
            }

            Payment p = new Payment();
            p.setBookingId(bookingId);
            p.setAmount(booking.getTotalCost());
            p.setPaymentMethod(paymentMethod);

            paymentDAO.create(p);

            response.sendRedirect(request.getContextPath() + "/payments?action=pay&bookingId=" + bookingId);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error processing payment", e);
        }
    }

    private boolean isFutureExpiry(String expiry) {
        try {
            String[] parts = expiry.split("/");
            int month = Integer.parseInt(parts[0]);
            int year = 2000 + Integer.parseInt(parts[1]);
            YearMonth expiryMonth = YearMonth.of(year, month);
            return !expiryMonth.isBefore(YearMonth.now());
        } catch (Exception e) {
            return false;
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response,
                                   int bookingId, String errorCode) throws IOException {
        response.sendRedirect(request.getContextPath()
                + "/payments?action=pay&bookingId=" + bookingId + "&error=" + errorCode);
    }
}