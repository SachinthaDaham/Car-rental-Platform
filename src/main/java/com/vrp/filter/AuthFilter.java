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
 * Servlet Filter guarding admin-only and login-required routes across all servlets.
 *
 * Demonstrates the FILTER design pattern — security is a cross-cutting concern
 * kept separate from business logic, applied declaratively via annotation.
 */
@WebFilter(urlPatterns = {"/vehicles", "/auth", "/booking", "/payment", "/chat"})
public class AuthFilter implements Filter {

    // Admin-only actions per servlet path
    private static final Set<String> VEHICLE_ADMIN = Set.of(
        "dashboard", "list", "add", "edit", "delete", "toggle", "create", "update"
    );
    private static final Set<String> AUTH_ADMIN = Set.of(
        "users", "deleteUser"
    );
    private static final Set<String> BOOKING_ADMIN = Set.of(
        "adminList", "updateStatus", "delete"
    );
    private static final Set<String> BOOKING_LOGIN = Set.of(
        "form", "create", "my", "confirm", "cancel"
    );
    private static final Set<String> CHAT_ADMIN = Set.of("admin", "conversations");
    private static final Set<String> CHAT_LOGIN = Set.of("history", "poll", "unread", "send");
    private static final Set<String> PAYMENT_LOGIN = Set.of("form", "create", "success");

    @Override public void init(FilterConfig fc) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse res  = (HttpServletResponse) response;
        String path   = req.getServletPath();
        String action = req.getParameter("action");
        if (action == null) action = "";

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        // ── Determine what level of access this route needs ──────────────────
        boolean needsAdmin = false;
        boolean needsLogin = false;

        switch (path) {
            case "/vehicles":
                if (VEHICLE_ADMIN.contains(action)) needsAdmin = true;
                break;
            case "/auth":
                if (AUTH_ADMIN.contains(action)) needsAdmin = true;
                break;
            case "/booking":
                if (BOOKING_ADMIN.contains(action))      needsAdmin = true;
                else if (BOOKING_LOGIN.contains(action)) needsLogin = true;
                break;
            case "/payment":
                if (PAYMENT_LOGIN.contains(action) || action.isEmpty()) needsLogin = true;
                break;
            case "/chat":
                if (CHAT_ADMIN.contains(action))      needsAdmin = true;
                else if (CHAT_LOGIN.contains(action)) needsLogin = true;
                break;
        }

        // ── Enforce access ───────────────────────────────────────────────────
        if (needsAdmin) {
            if (user == null) {
                res.sendRedirect(req.getContextPath() + "/auth?action=login");
                return;
            }
            if (!user.isAdmin()) {
                res.sendRedirect(req.getContextPath() + "/auth?action=dashboard&error=unauthorized");
                return;
            }
        } else if (needsLogin) {
            if (user == null) {
                res.sendRedirect(req.getContextPath() + "/auth?action=login");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override public void destroy() {}
}
