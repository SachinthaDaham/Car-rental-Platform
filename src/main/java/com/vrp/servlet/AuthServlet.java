package com.vrp.servlet;

import com.vrp.dao.UserDAO;
import com.vrp.model.User;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        String dataFile = System.getProperty("user.home") + "/vrp_data/users.txt";
        userDAO = new UserDAO(dataFile);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect(req.getContextPath() + "/vehicles?action=browse");
            return;
        } else if ("register".equals(action)) {
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        } else if ("dashboard".equals(action)) {
            req.getRequestDispatcher("/WEB-INF/views/userDashboard.jsp").forward(req, resp);
            return;
        }
        // Default to login
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("login".equals(action)) {
            User user = userDAO.authenticate(req.getParameter("username"), req.getParameter("password"));
            if (user != null) {
                HttpSession session = req.getSession();
                session.setAttribute("loggedInUser", user);
                if (user.isAdmin()) {
                    resp.sendRedirect(req.getContextPath() + "/vehicles?action=dashboard");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/auth?action=dashboard");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth?action=login&error=invalid");
            }
        } else if ("register".equals(action)) {
            String username = req.getParameter("username");
            if (userDAO.userExists(username)) {
                resp.sendRedirect(req.getContextPath() + "/auth?action=register&error=exists");
            } else {
                User newUser = new User(
                        username,
                        req.getParameter("password"),
                        req.getParameter("name"),
                        "CUSTOMER" // Default role
                );
                userDAO.addUser(newUser);
                // Auto login
                HttpSession session = req.getSession();
                session.setAttribute("loggedInUser", newUser);
                resp.sendRedirect(req.getContextPath() + "/auth?action=dashboard");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/vehicles?action=browse");
        }
    }
}
