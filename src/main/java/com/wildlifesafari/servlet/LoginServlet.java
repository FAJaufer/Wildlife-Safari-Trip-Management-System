package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.UserDAO;
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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO userDAO = new UserDAO();

        try {
            User user = userDAO.findByEmail(email);

            if (user != null && BCrypt.checkpw(password, user.getPassword())) {
                HttpSession session = request.getSession();
                session.setAttribute("loggedInUser", user);
                response.sendRedirect("views/dashboard.jsp");
            } else {
                response.sendRedirect("views/login.jsp?error=1");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error during login", e);
        }
    }
}