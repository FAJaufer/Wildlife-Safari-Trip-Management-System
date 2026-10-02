package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.ReviewDAO;
import com.wildlifesafari.dao.SafariPackageDAO;
import com.wildlifesafari.model.Review;
import com.wildlifesafari.model.SafariPackage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/package-reviews")
public class PackageReviewsServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final SafariPackageDAO packageDAO = new SafariPackageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int packageId = Integer.parseInt(request.getParameter("packageId"));
            SafariPackage pkg = packageDAO.findById(packageId);
            if (pkg == null) {
                response.sendRedirect(request.getContextPath() + "/bookings");
                return;
            }

            List<Review> reviews = reviewDAO.findByPackageId(packageId);
            double avgRating = reviewDAO.getAverageRating(packageId);

            request.setAttribute("pkg", pkg);
            request.setAttribute("reviews", reviews);
            request.setAttribute("avgRating", avgRating);
            request.getRequestDispatcher("/views/package-reviews.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading reviews", e);
        }
    }
}