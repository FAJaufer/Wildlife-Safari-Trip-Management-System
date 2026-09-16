package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.SupportRequestDAO;
import com.wildlifesafari.model.SupportRequest;
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

@WebServlet("/support")
public class SupportServlet extends HttpServlet {

    private final SupportRequestDAO supportDAO = new SupportRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }

        boolean canManage = user.getRole().equals("admin") || user.getRole().equals("support_officer");

        try {
            String action = request.getParameter("action");

            if (canManage && "updateStatus".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                supportDAO.updateStatus(id, status);
                response.sendRedirect(request.getContextPath() + "/support");
                return;
            }

            List<SupportRequest> requests = canManage
                    ? supportDAO.findAll()
                    : supportDAO.findByUserId(user.getId());

            request.setAttribute("requests", requests);
            request.setAttribute("canManage", canManage);
            request.getRequestDispatcher("/views/support.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading support requests", e);
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
            String bookingIdParam = request.getParameter("bookingId");
            String requestType = request.getParameter("requestType");
            String details = request.getParameter("details");

            SupportRequest r = new SupportRequest();
            r.setUserId(user.getId());
            r.setBookingId((bookingIdParam != null && !bookingIdParam.isEmpty()) ? Integer.parseInt(bookingIdParam) : null);
            r.setRequestType(requestType);
            r.setDetails(details);

            supportDAO.create(r);

            response.sendRedirect(request.getContextPath() + "/support?success=1");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving support request", e);
        }
    }
}