package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.GuideDAO;
import com.wildlifesafari.dao.UserDAO;
import com.wildlifesafari.model.Guide;
import com.wildlifesafari.model.User;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

@WebServlet("/guides")
public class GuideServlet extends HttpServlet {

    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{8,}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Set<String> EMPLOYMENT = Set.of("active", "inactive");
    private static final Set<String> AVAILABILITY = Set.of("available", "assigned", "unavailable");

    private final GuideDAO guideDAO = new GuideDAO();
    private final UserDAO userDAO = new UserDAO();

    private boolean canManage(User user) {
        return user != null && (user.getRole().equals("admin") || user.getRole().equals("manager"));
    }

    // Accounts with role 'guide' that don't have a guide profile yet.
    private List<User> findAvailableUsers(List<Guide> guides) throws SQLException {
        Set<Integer> linked = new HashSet<>();
        for (Guide g : guides) {
            linked.add(g.getUserId());
        }
        List<User> result = new ArrayList<>();
        for (User u : userDAO.findByRole("guide")) {
            if (!linked.contains(u.getId())) {
                result.add(u);
            }
        }
        return result;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if ("edit".equals(request.getParameter("action"))) {
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("editGuide", guideDAO.findById(id));
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/guides?error=invalid");
                    return;
                }
            }

            List<Guide> guides = guideDAO.findAll();
            request.setAttribute("guides", guides);
            request.setAttribute("availableUsers", findAvailableUsers(guides));
            request.getRequestDispatcher("/views/guides.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading guides", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (!canManage(user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can manage guides");
            return;
        }

        String ctx = request.getContextPath();
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        try {
            // ---------- DELETE ----------
            if ("delete".equals(action)) {
                int id;
                try {
                    id = Integer.parseInt(idParam);
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/guides?error=invalid");
                    return;
                }
                try {
                    guideDAO.delete(id);
                } catch (SQLException e) {
                    e.printStackTrace();
                    response.sendRedirect(ctx + "/guides?error=inuse");
                    return;
                }
                response.sendRedirect(ctx + "/guides?success=deleted");
                return;
            }

            // ---------- STEP 1: CREATE ACCOUNT ONLY ----------
            if ("createAccount".equals(action)) {
                String name = trim(request.getParameter("name"));
                String email = trim(request.getParameter("email"));
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");

                if (name.isEmpty() || name.length() > 100) {
                    response.sendRedirect(ctx + "/guides?error=name");
                    return;
                }
                if (!EMAIL_PATTERN.matcher(email).matches() || email.length() > 150) {
                    response.sendRedirect(ctx + "/guides?error=email");
                    return;
                }
                if (password == null || !password.equals(confirmPassword)) {
                    response.sendRedirect(ctx + "/guides?error=mismatch");
                    return;
                }
                if (!PASSWORD_PATTERN.matcher(password).matches()) {
                    response.sendRedirect(ctx + "/guides?error=weakpassword");
                    return;
                }
                if (userDAO.findByEmail(email) != null) {
                    response.sendRedirect(ctx + "/guides?error=exists");
                    return;
                }

                String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
                userDAO.createUser(new User(0, name, email, hashed, "guide"));
                response.sendRedirect(ctx + "/guides?success=accountCreated");
                return;
            }

            // ---------- Validate profile fields (add + update) ----------
            String qualifications = trim(request.getParameter("qualifications"));
            String specialization = trim(request.getParameter("specialization"));
            String employmentStatus = request.getParameter("employmentStatus");
            String availabilityStatus = request.getParameter("availabilityStatus");

            int experienceYears;
            try {
                experienceYears = Integer.parseInt(request.getParameter("experienceYears"));
            } catch (NumberFormatException e) {
                response.sendRedirect(ctx + "/guides?error=invalid");
                return;
            }
            if (experienceYears < 0 || experienceYears > 60
                    || qualifications.length() > 255 || specialization.length() > 255
                    || !EMPLOYMENT.contains(employmentStatus)
                    || !AVAILABILITY.contains(availabilityStatus)) {
                response.sendRedirect(ctx + "/guides?error=invalid");
                return;
            }

            // ---------- UPDATE ----------
            if (idParam != null && !idParam.isEmpty()) {
                int id;
                try {
                    id = Integer.parseInt(idParam);
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/guides?error=invalid");
                    return;
                }
                Guide existing = guideDAO.findById(id);
                if (existing == null) {
                    response.sendRedirect(ctx + "/guides?error=notfound");
                    return;
                }
                // The linked user comes from the database, never from the form.
                guideDAO.update(new Guide(id, existing.getUserId(), null, qualifications,
                        specialization, experienceYears, employmentStatus, availabilityStatus));
                response.sendRedirect(ctx + "/guides?success=updated");
                return;
            }

            // ---------- STEP 2: ADD GUIDE (pick an available account) ----------
            int userId;
            try {
                userId = Integer.parseInt(request.getParameter("userId"));
            } catch (NumberFormatException e) {
                response.sendRedirect(ctx + "/guides?error=invalid");
                return;
            }
            boolean eligible = false;
            for (User u : findAvailableUsers(guideDAO.findAll())) {
                if (u.getId() == userId) {
                    eligible = true;
                }
            }
            if (!eligible) {
                response.sendRedirect(ctx + "/guides?error=notavailable");
                return;
            }

            guideDAO.create(new Guide(0, userId, null, qualifications,
                    specialization, experienceYears, employmentStatus, availabilityStatus));
            response.sendRedirect(ctx + "/guides?success=created");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving guide", e);
        }
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}