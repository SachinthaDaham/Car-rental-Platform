package com.vrp.servlet;

import com.vrp.dao.UserDAO;
import com.vrp.model.User;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

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
        if (action == null) action = "login";

        switch (action) {
            case "logout": {
                HttpSession s = req.getSession(false);
                if (s != null) s.invalidate();
                resp.sendRedirect(req.getContextPath() + "/vehicles?action=browse");
                return;
            }
            case "register":
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                return;

            case "users": {
                // Admin-only — enforced by AuthFilter on /auth
                try {
                    List<User> users = userDAO.getAllUsers();
                    Map<String, Long> counts = userDAO.getRoleCounts();
                    req.setAttribute("users", users);
                    req.setAttribute("userCounts", counts);
                    req.getRequestDispatcher("/WEB-INF/views/listUsers.jsp").forward(req, resp);
                } catch (IOException e) { throw new ServletException(e); }
                return;
            }

            case "deleteUser": {
                // Admin-only
                String username = req.getParameter("username");
                try { userDAO.deleteUser(username); } catch (IOException e) { throw new ServletException(e); }
                resp.sendRedirect(req.getContextPath() + "/auth?action=users&msg=deleted");
                return;
            }

            case "dashboard":
                req.getRequestDispatcher("/WEB-INF/views/userDashboard.jsp").forward(req, resp);
                return;

            default:
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("login".equals(action)) {
            try {
                User user = userDAO.authenticate(req.getParameter("username"), req.getParameter("password"));
                if (user != null) {
                    HttpSession session = req.getSession();
                    session.setAttribute("loggedInUser", user);
                    resp.sendRedirect(req.getContextPath() +
                        (user.isAdmin() ? "/vehicles?action=dashboard" : "/auth?action=dashboard"));
                } else {
                    resp.sendRedirect(req.getContextPath() + "/auth?action=login&error=invalid");
                }
            } catch (IOException e) { throw new ServletException(e); }

        } else if ("register".equals(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String name     = req.getParameter("name");

            // Basic server-side validation
            if (username == null || username.trim().isEmpty() || !username.matches("[A-Za-z0-9_]+")) {
                resp.sendRedirect(req.getContextPath() + "/auth?action=register&error=baduser");
                return;
            }
            if (password == null || password.length() < 6) {
                resp.sendRedirect(req.getContextPath() + "/auth?action=register&error=weakpass");
                return;
            }

            try {
                if (userDAO.userExists(username)) {
                    resp.sendRedirect(req.getContextPath() + "/auth?action=register&error=exists");
                } else {
                    User newUser = new User(username.trim(), password, name == null ? username : name.trim(), "CUSTOMER");
                    userDAO.addUser(newUser);
                    HttpSession session = req.getSession();
                    session.setAttribute("loggedInUser", newUser);
                    resp.sendRedirect(req.getContextPath() + "/auth?action=dashboard");
                }
            } catch (IOException e) { throw new ServletException(e); }

        } else {
            resp.sendRedirect(req.getContextPath() + "/vehicles?action=browse");
        }
    }
}
