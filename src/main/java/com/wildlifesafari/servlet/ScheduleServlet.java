package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.*;
import com.wildlifesafari.model.*;

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

@WebServlet("/schedules")
public class ScheduleServlet extends HttpServlet {

    private final SafariScheduleDAO scheduleDAO = new SafariScheduleDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final GuideDAO guideDAO = new GuideDAO();
    private final DriverDAO driverDAO = new DriverDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();

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
            if ("mine".equals(request.getParameter("view"))) {
                if (user.getRole().equals("guide")) {
                    Guide guide = guideDAO.findByUserId(user.getId());
                    List<SafariSchedule> myTrips = (guide != null) ? scheduleDAO.findByGuideId(guide.getId()) : new java.util.ArrayList<>();
                    request.setAttribute("myTrips", myTrips);
                    request.setAttribute("roleLabel", "Guide");
                    request.getRequestDispatcher("/views/my-trips.jsp").forward(request, response);
                    return;
                } else if (user.getRole().equals("driver")) {
                    Driver driver = driverDAO.findByUserId(user.getId());
                    List<SafariSchedule> myTrips = (driver != null) ? scheduleDAO.findByDriverId(driver.getId()) : new java.util.ArrayList<>();
                    request.setAttribute("myTrips", myTrips);
                    request.setAttribute("roleLabel", "Driver");
                    request.getRequestDispatcher("/views/my-trips.jsp").forward(request, response);
                    return;
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only guides/drivers can view their own trips this way");
                    return;
                }
            }

            if (!(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can manage schedules");
                return;
            }

            String action = request.getParameter("action");

            if ("reassign".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                SafariSchedule target = scheduleDAO.findById(id);

                if (target == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Schedule not found");
                    return;
                }

                List<Guide> guides = guideDAO.findAvailable();
                List<Driver> drivers = driverDAO.findAvailable();
                List<Vehicle> vehicles = vehicleDAO.findAvailable();

                request.setAttribute("reassignTarget", target);
                request.setAttribute("guides", guides);
                request.setAttribute("drivers", drivers);
                request.setAttribute("vehicles", vehicles);
                request.getRequestDispatcher("/views/reassign.jsp").forward(request, response);
                return;
            }

            List<Booking> unscheduledBookings = bookingDAO.findUnscheduledBookings();
            List<Guide> guides = guideDAO.findAvailable();
            List<Driver> drivers = driverDAO.findAvailable();
            List<Vehicle> vehicles = vehicleDAO.findAvailable();
            List<SafariSchedule> schedules = scheduleDAO.findAll();

            request.setAttribute("unscheduledBookings", unscheduledBookings);
            request.setAttribute("guides", guides);
            request.setAttribute("drivers", drivers);
            request.setAttribute("vehicles", vehicles);
            request.setAttribute("schedules", schedules);

            request.getRequestDispatcher("/views/schedules.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading schedules", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null || !(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can manage schedules");
            return;
        }

        String formType = request.getParameter("formType");
        String action = request.getParameter("action");
        String ctx = request.getContextPath();

        try {
            // ---------- CANCEL / COMPLETE / DELETE ----------
            if ("cancel".equals(action) || "complete".equals(action) || "delete".equals(action)) {
                int id;
                try {
                    id = Integer.parseInt(request.getParameter("id"));
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/schedules?error=invalid");
                    return;
                }

                SafariSchedule existing = scheduleDAO.findById(id);
                if (existing == null) {
                    response.sendRedirect(ctx + "/schedules?error=notfound");
                    return;
                }

                if ("delete".equals(action)) {
                    scheduleDAO.delete(id);
                    response.sendRedirect(ctx + "/schedules?deleted=1");
                    return;
                }

                // Cancel and complete only apply to a schedule that is still active.
                if (!"scheduled".equals(existing.getTripStatus())) {
                    response.sendRedirect(ctx + "/schedules?error=notactive");
                    return;
                }

                if ("cancel".equals(action)) {
                    scheduleDAO.updateStatus(id, "cancelled");
                    response.sendRedirect(ctx + "/schedules?released=1");
                    return;
                }

                // complete
                if ("cancelled".equalsIgnoreCase(existing.getBookingStatus())) {
                    response.sendRedirect(ctx + "/schedules?error=bookingcancelled");
                    return;
                }
                scheduleDAO.updateStatus(id, "completed");
                response.sendRedirect(ctx + "/schedules?completed=1");
                return;
            }

            if ("reassign".equals(formType)) {
                int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
                String guideIdParam = request.getParameter("guideId");
                String driverIdParam = request.getParameter("driverId");
                String vehicleIdParam = request.getParameter("vehicleId");
                Date scheduleDate = Date.valueOf(request.getParameter("scheduleDate"));

                // The time slot comes from the stored schedule, not from the form.
                SafariSchedule existingSchedule = scheduleDAO.findById(scheduleId);
                if (existingSchedule == null) {
                    response.sendRedirect(ctx + "/schedules?error=notfound");
                    return;
                }
                String scheduleTime = existingSchedule.getScheduleTime();

                Integer guideId = (guideIdParam != null && !guideIdParam.isEmpty()) ? Integer.parseInt(guideIdParam) : null;
                Integer driverId = (driverIdParam != null && !driverIdParam.isEmpty()) ? Integer.parseInt(driverIdParam) : null;
                Integer vehicleId = (vehicleIdParam != null && !vehicleIdParam.isEmpty()) ? Integer.parseInt(vehicleIdParam) : null;

                String conflict = scheduleDAO.checkConflict(guideId, driverId, vehicleId, scheduleDate, scheduleTime, scheduleId);
                if (conflict != null) {
                    request.setAttribute("conflictError", conflict);
                    response.sendRedirect(ctx + "/schedules?action=reassign&id=" + scheduleId);
                    return;
                }

                scheduleDAO.updateResources(scheduleId, guideId, driverId, vehicleId);
                response.sendRedirect(ctx + "/schedules?reassigned=1");
                return;
            }

            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            String guideIdParam = request.getParameter("guideId");
            String driverIdParam = request.getParameter("driverId");
            String vehicleIdParam = request.getParameter("vehicleId");

            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Booking not found");
                return;
            }
            Date scheduleDate = booking.getSafariDate();
            String scheduleTime = booking.getTimeSlot();

            Integer guideId = (guideIdParam != null && !guideIdParam.isEmpty()) ? Integer.parseInt(guideIdParam) : null;
            Integer driverId = (driverIdParam != null && !driverIdParam.isEmpty()) ? Integer.parseInt(driverIdParam) : null;
            Integer vehicleId = (vehicleIdParam != null && !vehicleIdParam.isEmpty()) ? Integer.parseInt(vehicleIdParam) : null;

            String conflict = scheduleDAO.checkConflict(guideId, driverId, vehicleId, scheduleDate, scheduleTime);
            if (conflict != null) {
                request.setAttribute("conflictError", conflict);
                doGet(request, response);
                return;
            }

            SafariSchedule s = new SafariSchedule();
            s.setBookingId(bookingId);
            s.setGuideId(guideId);
            s.setDriverId(driverId);
            s.setVehicleId(vehicleId);
            s.setScheduleDate(scheduleDate);
            s.setScheduleTime(scheduleTime);
            s.setTripStatus("scheduled");

            scheduleDAO.create(s);

            response.sendRedirect(ctx + "/schedules?success=1");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving schedule", e);
        }
    }
}