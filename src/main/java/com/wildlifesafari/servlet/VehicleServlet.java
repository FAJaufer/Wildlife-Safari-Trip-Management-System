package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.VehicleDAO;
import com.wildlifesafari.model.User;
import com.wildlifesafari.model.Vehicle;

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

@WebServlet("/vehicles")
public class VehicleServlet extends HttpServlet {

    private final VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                vehicleDAO.delete(id);
                response.sendRedirect(request.getContextPath() + "/vehicles");
                return;
            }

            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Vehicle vehicle = vehicleDAO.findById(id);
                request.setAttribute("editVehicle", vehicle);
            }

            List<Vehicle> vehicles = vehicleDAO.findAll();
            request.setAttribute("vehicles", vehicles);
            request.getRequestDispatcher("/views/vehicles.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading vehicles", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null || !(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can manage vehicles");
            return;
        }

        String idParam = request.getParameter("id");
        String registrationNumber = request.getParameter("registrationNumber");
        String vehicleType = request.getParameter("vehicleType");
        Date insuranceExpiry = Date.valueOf(request.getParameter("insuranceExpiry"));
        String maintenanceStatus = request.getParameter("maintenanceStatus");
        String availabilityStatus = request.getParameter("availabilityStatus");

        try {
            if (idParam != null && !idParam.isEmpty()) {
                Vehicle v = new Vehicle(Integer.parseInt(idParam), registrationNumber, vehicleType,
                        insuranceExpiry, maintenanceStatus, availabilityStatus);
                vehicleDAO.update(v);
            } else {
                Vehicle v = new Vehicle(0, registrationNumber, vehicleType,
                        insuranceExpiry, maintenanceStatus, availabilityStatus);
                vehicleDAO.create(v);
            }

            response.sendRedirect(request.getContextPath() + "/vehicles");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving vehicle", e);
        }
    }
}