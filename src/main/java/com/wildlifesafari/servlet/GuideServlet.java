package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.GuideDAO;
import com.wildlifesafari.dao.UserDAO;
import com.wildlifesafari.model.Guide;
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

@WebServlet("/guides")
public class GuideServlet extends HttpServlet {

    private final GuideDAO guideDAO = new GuideDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                guideDAO.delete(id);
                response.sendRedirect(request.getContextPath() + "/guides");
                return;
            }

            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Guide guide = guideDAO.findById(id);
                request.setAttribute("editGuide", guide);
            }

            List<Guide> guides = guideDAO.findAll();
            List<User> guideUsers = userDAO.findByRole("guide");
            request.setAttribute("guides", guides);
            request.setAttribute("guideUsers", guideUsers);
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

        if (user == null || !(user.getRole().equals("admin") || user.getRole().equals("manager"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only managers/admins can manage guides");
            return;
        }

        String idParam = request.getParameter("id");
        int userId = Integer.parseInt(request.getParameter("userId"));
        String qualifications = request.getParameter("qualifications");
        String specialization = request.getParameter("specialization");
        int experienceYears = Integer.parseInt(request.getParameter("experienceYears"));
        String employmentStatus = request.getParameter("employmentStatus");
        String availabilityStatus = request.getParameter("availabilityStatus");

        try {
            if (idParam != null && !idParam.isEmpty()) {
                Guide g = new Guide(Integer.parseInt(idParam), userId, null, qualifications,
                        specialization, experienceYears, employmentStatus, availabilityStatus);
                guideDAO.update(g);
            } else {
                Guide g = new Guide(0, userId, null, qualifications,
                        specialization, experienceYears, employmentStatus, availabilityStatus);
                guideDAO.create(g);
            }

            response.sendRedirect(request.getContextPath() + "/guides");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error saving guide", e);
        }
    }
}