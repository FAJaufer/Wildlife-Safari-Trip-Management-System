package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.SafariPackageDAO;
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
import java.sql.SQLException;
import java.util.List;

@WebServlet("/packages")
public class SafariPackageServlet extends HttpServlet {

    private final SafariPackageDAO packageDAO = new SafariPackageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                packageDAO.delete(id);
                response.sendRedirect(request.getContextPath() + "/packages");
                return;
            }

            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                SafariPackage pkg = packageDAO.findById(id);
                request.setAttribute("editPackage", pkg);
            }

            List<SafariPackage> packages = packageDAO.findAll();
            request.setAttribute("packages", packages);
            request.getRequestDispatcher("/views/packages.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading packages", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null || !(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can manage packages");
            return;
        }

        String idParam = request.getParameter("id");
        String safariType = request.getParameter("safariType");
        String destination = request.getParameter("destination");
        String duration = request.getParameter("duration");
        BigDecimal price = new BigDecimal(request.getParameter("price"));
        String description = request.getParameter("description");
        String availabilityStatus = request.getParameter("availabilityStatus");

        try {
            if (idParam != null && !idParam.isEmpty()) {
                // Update existing
                SafariPackage pkg = new SafariPackage(
                        Integer.parseInt(idParam), safariType, destination, duration,
                        price, description, availabilityStatus, user.getId());
                packageDAO.update(pkg);
            } else {
                // Create new
                SafariPackage pkg = new SafariPackage(
                        0, safariType, destination, duration,
                        price, description, availabilityStatus, user.getId());
                packageDAO.create(pkg);
            }

            response.sendRedirect(request.getContextPath() + "/packages");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving package", e);
        }
    }
}