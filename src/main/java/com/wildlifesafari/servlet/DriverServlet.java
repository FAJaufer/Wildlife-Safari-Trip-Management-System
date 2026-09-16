package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.DriverDAO;
import com.wildlifesafari.dao.UserDAO;
import com.wildlifesafari.model.Driver;
import com.wildlifesafari.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/drivers")
public class DriverServlet extends HttpServlet {

    private final DriverDAO driverDAO = new DriverDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                driverDAO.delete(id);
                response.sendRedirect(request.getContextPath() + "/drivers");
                return;
            }

            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Driver driver = driverDAO.findById(id);
                request.setAttribute("editDriver", driver);
            }

            List<Driver> drivers = driverDAO.findAll();
            List<User> driverUsers = userDAO.findByRole("driver");
            request.setAttribute("drivers", drivers);
            request.setAttribute("driverUsers", driverUsers);
            request.getRequestDispatcher("/views/drivers.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading drivers", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null || !(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can manage drivers");
            return;
        }

        String idParam = request.getParameter("id");
        int userId = Integer.parseInt(request.getParameter("userId"));
        String licenseNumber = request.getParameter("licenseNumber");
        Date licenseExpiry = Date.valueOf(request.getParameter("licenseExpiry"));
        int experienceYears = Integer.parseInt(request.getParameter("experienceYears"));
        String employmentStatus = request.getParameter("employmentStatus");
        String availabilityStatus = request.getParameter("availabilityStatus");

        try {
            if (idParam != null && !idParam.isEmpty()) {
                Driver d = new Driver(Integer.parseInt(idParam), userId, null, licenseNumber,
                        licenseExpiry, experienceYears, employmentStatus, availabilityStatus);
                driverDAO.update(d);
            } else {
                Driver d = new Driver(0, userId, null, licenseNumber,
                        licenseExpiry, experienceYears, employmentStatus, availabilityStatus);
                driverDAO.create(d);
            }

            response.sendRedirect(request.getContextPath() + "/drivers");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving driver", e);
        }
    }
}