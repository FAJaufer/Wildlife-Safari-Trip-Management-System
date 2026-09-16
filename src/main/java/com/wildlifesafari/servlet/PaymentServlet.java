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
import java.util.List;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

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
                    // already paid — just show the receipt again
                    request.setAttribute("payment", existing);
                    request.setAttribute("booking", booking);
                    request.getRequestDispatcher("/views/receipt.jsp").forward(request, response);
                    return;
                }

                request.setAttribute("booking", booking);
                request.getRequestDispatcher("/views/payment-form.jsp").forward(request, response);
                return;
            }

            // Default: admin/manager view of all payments + revenue
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
}