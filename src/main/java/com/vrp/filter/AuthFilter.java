package com.vrp.filter;

import com.vrp.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/vehicles")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String action = req.getParameter("action");

        // List of protected actions that require ADMIN role
        if (action != null && (action.equals("dashboard") || action.equals("list") || action.equals("add") || 
            action.equals("edit") || action.equals("delete") || action.equals("toggle") || 
            action.equals("create") || action.equals("update"))) {
            
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("loggedInUser") == null) {
                // Not logged in -> redirect to login
                res.sendRedirect(req.getContextPath() + "/auth?action=login");
                return;
            }

            User user = (User) session.getAttribute("loggedInUser");
            if (!user.isAdmin()) {
                // Logged in but not admin -> forbid (or redirect to user dashboard)
                res.sendRedirect(req.getContextPath() + "/auth?action=dashboard&error=unauthorized");
                return;
            }
        }
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
