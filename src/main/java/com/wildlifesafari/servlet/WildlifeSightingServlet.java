package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.GuideDAO;
import com.wildlifesafari.dao.SafariScheduleDAO;
import com.wildlifesafari.dao.WildlifeSightingDAO;
import com.wildlifesafari.model.Guide;
import com.wildlifesafari.model.SafariSchedule;
import com.wildlifesafari.model.User;
import com.wildlifesafari.model.WildlifeSighting;

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

@WebServlet("/sightings")
public class WildlifeSightingServlet extends HttpServlet {

    private final WildlifeSightingDAO sightingDAO = new WildlifeSightingDAO();
    private final GuideDAO guideDAO = new GuideDAO();
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

        try {
            List<WildlifeSighting> recentSightings = sightingDAO.findRecent(20);
            request.setAttribute("recentSightings", recentSightings);

            if (user.getRole().equals("guide")) {
                Guide guide = guideDAO.findByUserId(user.getId());
                if (guide != null) {
                    List<SafariSchedule> myTrips = scheduleDAO.findByGuideId(guide.getId());
                    request.setAttribute("myTrips", myTrips);
                    request.setAttribute("currentGuide", guide);
                } else {
                    request.setAttribute("noGuideProfile", true);
                }
            }

            request.getRequestDispatcher("/views/sightings.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading sightings", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null || !user.getRole().equals("guide")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only guides can log sightings");
            return;
        }

        try {
            Guide guide = guideDAO.findByUserId(user.getId());
            if (guide == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "No guide profile linked to your account");
                return;
            }

            String scheduleIdParam = request.getParameter("scheduleId");
            String species = request.getParameter("species");
            String location = request.getParameter("location");
            Date sightingDate = Date.valueOf(request.getParameter("sightingDate"));
            String sightingTime = request.getParameter("sightingTime");
            String photoUrl = request.getParameter("photoUrl");

            WildlifeSighting s = new WildlifeSighting();
            s.setScheduleId((scheduleIdParam != null && !scheduleIdParam.isEmpty()) ? Integer.parseInt(scheduleIdParam) : null);
            s.setGuideId(guide.getId());
            s.setSpecies(species);
            s.setLocation(location);
            s.setSightingDate(sightingDate);
            s.setSightingTime(sightingTime);
            s.setPhotoUrl(photoUrl);

            sightingDAO.create(s);

            response.sendRedirect(request.getContextPath() + "/sightings?success=1");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving sighting", e);
        }
    }
}