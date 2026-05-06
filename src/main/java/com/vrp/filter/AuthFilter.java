package com.vrp.filter;

import com.vrp.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;

/**
 * Servlet Filter that guards admin-only routes on both /vehicles and /auth.
 * Demonstrates the FILTER pattern — cross-cutting security concern separated
 * from business logic.
 */
@WebFilter(urlPatterns = {"/vehicles", "/auth"})
public class AuthFilter implements Filter {

    private static final Set<String> VEHICLE_ADMIN_ACTIONS = Set.of(
        "dashboard", "list", "add", "edit", "delete", "toggle", "create", "update"
    );
    private static final Set<String> AUTH_ADMIN_ACTIONS = Set.of(
        "users", "deleteUser"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req = (HttpServletRequest)  request;
        HttpServletResponse res = (HttpServletResponse) response;

        String action   = req.getParameter("action");
        String servletPath = req.getServletPath();  // "/vehicles" or "/auth"

        boolean requiresAdmin =
            ("/vehicles".equals(servletPath) && action != null && VEHICLE_ADMIN_ACTIONS.contains(action)) ||
            ("/auth".equals(servletPath)     && action != null && AUTH_ADMIN_ACTIONS.contains(action));

        if (requiresAdmin) {
            HttpSession session = req.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

            if (user == null) {
                res.sendRedirect(req.getContextPath() + "/auth?action=login");
                return;
            }
            if (!user.isAdmin()) {
                res.sendRedirect(req.getContextPath() + "/auth?action=dashboard&error=unauthorized");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
