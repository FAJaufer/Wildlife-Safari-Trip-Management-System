package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.DriverDAO;
import com.wildlifesafari.dao.UserDAO;
import com.wildlifesafari.model.Driver;
import com.wildlifesafari.model.User;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

@WebServlet("/drivers")
public class DriverServlet extends HttpServlet {

    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{8,}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Set<String> EMPLOYMENT = Set.of("active", "inactive");
    private static final Set<String> AVAILABILITY = Set.of("available", "assigned", "unavailable");

    private final DriverDAO driverDAO = new DriverDAO();
    private final UserDAO userDAO = new UserDAO();

    private boolean canManage(User user) {
        return user != null && (user.getRole().equals("admin") || user.getRole().equals("manager"));
    }

    // Accounts with role 'driver' that don't have a driver profile yet.
    private List<User> findAvailableUsers(List<Driver> drivers) throws SQLException {
        Set<Integer> linked = new HashSet<>();
        for (Driver d : drivers) {
            linked.add(d.getUserId());
        }
        List<User> result = new ArrayList<>();
        for (User u : userDAO.findByRole("driver")) {
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
                    request.setAttribute("editDriver", driverDAO.findById(id));
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/drivers?error=invalid");
                    return;
                }
            }

            List<Driver> drivers = driverDAO.findAll();
            request.setAttribute("drivers", drivers);
            request.setAttribute("availableUsers", findAvailableUsers(drivers));
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

        if (!canManage(user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can manage drivers");
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
                    response.sendRedirect(ctx + "/drivers?error=invalid");
                    return;
                }
                try {
                    driverDAO.delete(id);
                } catch (SQLException e) {
                    e.printStackTrace();
                    response.sendRedirect(ctx + "/drivers?error=inuse");
                    return;
                }
                response.sendRedirect(ctx + "/drivers?success=deleted");
                return;
            }

            // ---------- STEP 1: CREATE ACCOUNT ONLY ----------
            if ("createAccount".equals(action)) {
                String name = trim(request.getParameter("name"));
                String email = trim(request.getParameter("email"));
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");

                if (name.isEmpty() || name.length() > 100) {
                    response.sendRedirect(ctx + "/drivers?error=name");
                    return;
                }
                if (!EMAIL_PATTERN.matcher(email).matches() || email.length() > 150) {
                    response.sendRedirect(ctx + "/drivers?error=email");
                    return;
                }
                if (password == null || !password.equals(confirmPassword)) {
                    response.sendRedirect(ctx + "/drivers?error=mismatch");
                    return;
                }
                if (!PASSWORD_PATTERN.matcher(password).matches()) {
                    response.sendRedirect(ctx + "/drivers?error=weakpassword");
                    return;
                }
                if (userDAO.findByEmail(email) != null) {
                    response.sendRedirect(ctx + "/drivers?error=exists");
                    return;
                }

                String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
                userDAO.createUser(new User(0, name, email, hashed, "driver"));
                response.sendRedirect(ctx + "/drivers?success=accountCreated");
                return;
            }

            // ---------- Validate profile fields (add + update) ----------
            String licenseNumber = trim(request.getParameter("licenseNumber"));
            String employmentStatus = request.getParameter("employmentStatus");
            String availabilityStatus = request.getParameter("availabilityStatus");

            Date licenseExpiry;
            try {
                licenseExpiry = Date.valueOf(request.getParameter("licenseExpiry"));
            } catch (IllegalArgumentException | NullPointerException e) {
                response.sendRedirect(ctx + "/drivers?error=invalid");
                return;
            }

            int experienceYears;
            try {
                experienceYears = Integer.parseInt(request.getParameter("experienceYears"));
            } catch (NumberFormatException e) {
                response.sendRedirect(ctx + "/drivers?error=invalid");
                return;
            }

            if (licenseNumber.isEmpty() || licenseNumber.length() > 50
                    || experienceYears < 0 || experienceYears > 60
                    || !EMPLOYMENT.contains(employmentStatus)
                    || !AVAILABILITY.contains(availabilityStatus)) {
                response.sendRedirect(ctx + "/drivers?error=invalid");
                return;
            }

            boolean expired = licenseExpiry.toLocalDate().isBefore(java.time.LocalDate.now());

            // ---------- UPDATE ----------
            if (idParam != null && !idParam.isEmpty()) {
                int id;
                try {
                    id = Integer.parseInt(idParam);
                } catch (NumberFormatException e) {
                    response.sendRedirect(ctx + "/drivers?error=invalid");
                    return;
                }
                Driver existing = driverDAO.findById(id);
                if (existing == null) {
                    response.sendRedirect(ctx + "/drivers?error=notfound");
                    return;
                }
                // Only reject a past expiry if the date was changed,
                // so an already-expired driver can still be marked inactive.
                boolean dateChanged = existing.getLicenseExpiry() == null
                        || !existing.getLicenseExpiry().toString().equals(licenseExpiry.toString());
                if (expired && dateChanged) {
                    response.sendRedirect(ctx + "/drivers?error=expired");
                    return;
                }

                driverDAO.update(new Driver(id, existing.getUserId(), null, licenseNumber,
                        licenseExpiry, experienceYears, employmentStatus, availabilityStatus));
                response.sendRedirect(ctx + "/drivers?success=updated");
                return;
            }

            // ---------- STEP 2: ADD DRIVER (pick an available account) ----------
            if (expired) {
                response.sendRedirect(ctx + "/drivers?error=expired");
                return;
            }

            int userId;
            try {
                userId = Integer.parseInt(request.getParameter("userId"));
            } catch (NumberFormatException e) {
                response.sendRedirect(ctx + "/drivers?error=invalid");
                return;
            }
            boolean eligible = false;
            for (User u : findAvailableUsers(driverDAO.findAll())) {
                if (u.getId() == userId) {
                    eligible = true;
                }
            }
            if (!eligible) {
                response.sendRedirect(ctx + "/drivers?error=notavailable");
                return;
            }

            driverDAO.create(new Driver(0, userId, null, licenseNumber,
                    licenseExpiry, experienceYears, employmentStatus, availabilityStatus));
            response.sendRedirect(ctx + "/drivers?success=created");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving driver", e);
        }
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}