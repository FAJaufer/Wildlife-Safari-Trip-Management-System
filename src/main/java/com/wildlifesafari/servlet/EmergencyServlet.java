package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.EmergencyReportDAO;
import com.wildlifesafari.dao.SafariScheduleDAO;
import com.wildlifesafari.model.EmergencyReport;
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

@WebServlet("/emergencies")
public class EmergencyServlet extends HttpServlet {

    private final EmergencyReportDAO emergencyDAO = new EmergencyReportDAO();
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

        boolean canManage = user.getRole().equals("admin") || user.getRole().equals("manager")
                || user.getRole().equals("support_officer");
        boolean canReport = user.getRole().equals("guide") || user.getRole().equals("driver");

        try {
            String action = request.getParameter("action");

            if (canManage && "updateStatus".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                emergencyDAO.updateStatus(id, status);
                response.sendRedirect(request.getContextPath() + "/emergencies");
                return;
            }

            List<EmergencyReport> reports = emergencyDAO.findAll();
            request.setAttribute("reports", reports);
            request.setAttribute("canManage", canManage);
            request.setAttribute("canReport", canReport);

            if (canReport) {
                // Give them a list of their own active schedules to attach the report to
                List<SafariSchedule> allSchedules = scheduleDAO.findAll();
                request.setAttribute("scheduleOptions", allSchedules);
            }

            request.getRequestDispatcher("/views/emergencies.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading emergency reports", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null || !(user.getRole().equals("guide") || user.getRole().equals("driver"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only guides/drivers can report emergencies");
            return;
        }

        try {
            String scheduleIdParam = request.getParameter("scheduleId");
            String incidentType = request.getParameter("incidentType");
            String details = request.getParameter("details");

            EmergencyReport r = new EmergencyReport();
            r.setReportedBy(user.getId());
            r.setScheduleId((scheduleIdParam != null && !scheduleIdParam.isEmpty()) ? Integer.parseInt(scheduleIdParam) : null);
            r.setIncidentType(incidentType);
            r.setDetails(details);

            emergencyDAO.create(r);

            response.sendRedirect(request.getContextPath() + "/emergencies?success=1");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving emergency report", e);
        }
    }
}