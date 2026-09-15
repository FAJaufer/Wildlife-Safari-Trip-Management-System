package com.wildlifesafari.servlet;

import com.wildlifesafari.dao.UserDAO;
import com.wildlifesafari.model.User;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO userDAO = new UserDAO();

        try {
            User existing = userDAO.findByEmail(email);
            if (existing != null) {
                response.sendRedirect("views/register.jsp?error=1");
                return;
            }

            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

            User newUser = new User(0, name, email, hashedPassword, "tourist");
            userDAO.createUser(newUser);

            response.sendRedirect("views/login.jsp?registered=1");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error during registration", e);
        }
    }
}