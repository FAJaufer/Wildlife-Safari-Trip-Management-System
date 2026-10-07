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

    private boolean isAdminOrManager(User user) {
        return user.getRole().equals("admin") || user.getRole().equals("manager");
    }

    // Admins/managers can change any sighting; a guide only their own.
    private boolean canModify(User user, WildlifeSighting s) throws SQLException {
        if (isAdminOrManager(user)) {
            return true;
        }
        if (user.getRole().equals("guide")) {
            Guide guide = guideDAO.findByUserId(user.getId());
            return guide != null && guide.getId() == s.getGuideId();
        }
        return false;
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

        try {
            if ("edit".equals(request.getParameter("action"))) {
                int id;
                try {
                    id = Integer.parseInt(request.getParameter("id"));
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/sightings?error=invalid");
                    return;
                }

                WildlifeSighting existing = sightingDAO.findById(id);
                if (existing == null) {
                    response.sendRedirect(request.getContextPath() + "/sightings?error=notfound");
                    return;
                }
                if (!canModify(user, existing)) {
                    response.sendRedirect(request.getContextPath() + "/sightings?error=forbidden");
                    return;
                }
                request.setAttribute("editSighting", existing);
            }

            List<WildlifeSighting> recentSightings = sightingDAO.findRecent(20);
            request.setAttribute("recentSightings", recentSightings);

            if (user.getRole().equals("guide")) {
                Guide guide = guideDAO.findByUserId(user.getId());
                if (guide != null) {
                    List<SafariSchedule> myTrips = scheduleDAO.findByGuideId(guide.getId());
                    request.setAttribute("myTrips", myTrips);
                    request.setAttribute("currentGuide", guide);
                    request.setAttribute("myGuideId", guide.getId());
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

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }

        String ctx = request.getContextPath();
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        boolean isUpdate = idParam != null && !idParam.isEmpty();

        try {
            // ---------- DELETE ----------
            if ("delete".equals(action)) {
                int id;
                try {
                    id = Integer.parseInt(idParam);
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/sightings?error=invalid");
                    return;
                }
                WildlifeSighting existing = sightingDAO.findById(id);
                if (existing == null) {
                    response.sendRedirect(ctx + "/sightings?error=notfound");
                    return;
                }
                if (!canModify(user, existing)) {
                    response.sendRedirect(ctx + "/sightings?error=forbidden");
                    return;
                }
                sightingDAO.delete(id);
                response.sendRedirect(ctx + "/sightings?success=deleted");
                return;
            }

            // ---------- Read and validate form fields (create + update) ----------
            String species = request.getParameter("species");
            String location = request.getParameter("location");
            String sightingTime = request.getParameter("sightingTime");
            String photoUrl = request.getParameter("photoUrl");

            species = (species == null) ? "" : species.trim();
            location = (location == null) ? "" : location.trim();
            sightingTime = (sightingTime == null || sightingTime.trim().isEmpty()) ? null : sightingTime.trim();
            photoUrl = (photoUrl == null || photoUrl.trim().isEmpty()) ? null : photoUrl.trim();

            Date sightingDate;
            try {
                sightingDate = Date.valueOf(request.getParameter("sightingDate"));
            } catch (IllegalArgumentException | NullPointerException e) {
                response.sendRedirect(ctx + "/sightings?error=invalid");
                return;
            }

            if (species.isEmpty() || species.length() > 100
                    || location.isEmpty() || location.length() > 150) {
                response.sendRedirect(ctx + "/sightings?error=invalid");
                return;
            }

            if (photoUrl != null) {
                String lower = photoUrl.toLowerCase();
                if (!(lower.startsWith("http://") || lower.startsWith("https://"))) {
                    response.sendRedirect(ctx + "/sightings?error=invalid");
                    return;
                }
            }

            // ---------- UPDATE ----------
            if (isUpdate) {
                int id;
                try {
                    id = Integer.parseInt(idParam);
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/sightings?error=invalid");
                    return;
                }
                WildlifeSighting existing = sightingDAO.findById(id);
                if (existing == null) {
                    response.sendRedirect(ctx + "/sightings?error=notfound");
                    return;
                }
                if (!canModify(user, existing)) {
                    response.sendRedirect(ctx + "/sightings?error=forbidden");
                    return;
                }

                existing.setSpecies(species);
                existing.setLocation(location);
                existing.setSightingDate(sightingDate);
                existing.setSightingTime(sightingTime);
                existing.setPhotoUrl(photoUrl);
                sightingDAO.update(existing);

                response.sendRedirect(ctx + "/sightings?success=updated");
                return;
            }

            // ---------- CREATE (guides only) ----------
            if (!user.getRole().equals("guide")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only guides can log sightings");
                return;
            }

            Guide guide = guideDAO.findByUserId(user.getId());
            if (guide == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "No guide profile linked to your account");
                return;
            }

            String scheduleIdParam = request.getParameter("scheduleId");
            Integer scheduleId = null;
            if (scheduleIdParam != null && !scheduleIdParam.isEmpty()) {
                try {
                    scheduleId = Integer.parseInt(scheduleIdParam);
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/sightings?error=invalid");
                    return;
                }
            }

            WildlifeSighting s = new WildlifeSighting();
            s.setScheduleId(scheduleId);
            s.setGuideId(guide.getId());
            s.setSpecies(species);
            s.setLocation(location);
            s.setSightingDate(sightingDate);
            s.setSightingTime(sightingTime);
            s.setPhotoUrl(photoUrl);

            sightingDAO.create(s);

            response.sendRedirect(ctx + "/sightings?success=1");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving sighting", e);
        }
    }
}