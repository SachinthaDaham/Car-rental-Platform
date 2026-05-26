package com.vrp.servlet;

import com.vrp.dao.BookingDAO;
import com.vrp.dao.VehicleDAO;
import com.vrp.model.*;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Front-controller servlet for the Vehicle Management module.
 * Routes via ?action= :
 *   GET  — browse | details | list | dashboard | add | edit | delete | toggle | calculate
 *   POST — create | update
 */
@WebServlet("/vehicles")
public class VehicleServlet extends HttpServlet {

    private VehicleDAO dao;
    private BookingDAO bookingDAO;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        dao        = new VehicleDAO(null);
        bookingDAO = new BookingDAO(null);
    }

    // ── GET ─────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "browse";
        try {
            switch (action) {

                case "add":
                    req.getRequestDispatcher("/WEB-INF/views/addVehicle.jsp").forward(req, resp);
                    return;

                case "edit": {
                    Vehicle v = dao.getVehicleById(req.getParameter("id"));
                    if (v == null) {
                        resp.sendRedirect("vehicles?action=list");
                        return;
                    }
                    req.setAttribute("vehicle", v);
                    req.getRequestDispatcher("/WEB-INF/views/editVehicle.jsp").forward(req, resp);
                    return;
                }

                case "delete":
                    dao.deleteVehicle(req.getParameter("id"));
                    resp.sendRedirect("vehicles?action=list&msg=deleted");
                    return;

                case "toggle":
                    dao.toggleAvailability(req.getParameter("id"));
                    resp.sendRedirect("vehicles?action=list&msg=toggled");
                    return;

                case "details": {
                    Vehicle v = dao.getVehicleById(req.getParameter("id"));
                    if (v == null) {
                        resp.sendRedirect("vehicles?action=browse");
                        return;
                    }
                    req.setAttribute("vehicle", v);
                    req.getRequestDispatcher("/WEB-INF/views/details.jsp").forward(req, resp);
                    return;
                }

                case "dashboard": {
                    Map<String, Object> stats = dao.getStats();
                    req.setAttribute("stats", stats);
                    req.setAttribute("bookingStats", bookingDAO.getStats());
                    List<Vehicle> all = dao.getAllVehicles();
                    req.setAttribute("recent", all.subList(Math.max(0, all.size() - 5), all.size()));
                    req.setAttribute("topEarners", dao.getTopByRate(5));
                    req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
                    return;
                }

                case "list": {
                    List<Vehicle> all = dao.getAllVehicles();
                    req.setAttribute("vehicles", all);
                    req.getRequestDispatcher("/WEB-INF/views/listVehicles.jsp").forward(req, resp);
                    return;
                }

                case "calculate": {
                    // AJAX endpoint — returns JSON cost breakdown
                    String id  = req.getParameter("id");
                    int days   = parseI(req.getParameter("days"), 1);
                    Vehicle v  = dao.getVehicleById(id);
                    resp.setContentType("application/json;charset=UTF-8");
                    if (v == null || days < 1) {
                        resp.getWriter().write("{\"error\":\"invalid\"}");
                        return;
                    }
                    double cost    = v.calculateRentalCost(days);
                    String summary = v.getRentalSummary(days);
                    resp.getWriter().write(String.format(
                        "{\"cost\":%.2f,\"summary\":\"%s\",\"days\":%d}",
                        cost, summary.replace("\"", "'"), days));
                    return;
                }

                case "browse":
                default: {
                    String kw        = req.getParameter("keyword");
                    String type      = req.getParameter("type");
                    Double min       = parseD(req.getParameter("minRate"));
                    Double max       = parseD(req.getParameter("maxRate"));
                    boolean availOnly = "1".equals(req.getParameter("availableOnly"));
                    List<Vehicle> result = dao.filter(kw, type, min, max, availOnly);
                    req.setAttribute("vehicles", result);
                    req.setAttribute("keyword", kw);
                    req.setAttribute("typeFilter", type);
                    req.setAttribute("minRate", req.getParameter("minRate"));
                    req.setAttribute("maxRate", req.getParameter("maxRate"));
                    req.setAttribute("availableOnly", availOnly);
                    req.getRequestDispatcher("/WEB-INF/views/browse.jsp").forward(req, resp);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── POST ────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("create".equals(action)) {
                String error = validate(req);
                if (error != null) {
                    req.setAttribute("errorMsg", error);
                    req.getRequestDispatcher("/WEB-INF/views/addVehicle.jsp").forward(req, resp);
                    return;
                }
                dao.addVehicle(buildVehicle(req));
                resp.sendRedirect("vehicles?action=list&msg=created");

            } else if ("update".equals(action)) {
                String error = validate(req);
                if (error != null) {
                    Vehicle existing = dao.getVehicleById(req.getParameter("id"));
                    req.setAttribute("vehicle", existing);
                    req.setAttribute("errorMsg", error);
                    req.getRequestDispatcher("/WEB-INF/views/editVehicle.jsp").forward(req, resp);
                    return;
                }
                dao.updateVehicle(buildVehicle(req));
                resp.sendRedirect("vehicles?action=list&msg=updated");

            } else {
                resp.sendRedirect("vehicles?action=list");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    /** Server-side validation. Returns error message or null if valid. */
    private String validate(HttpServletRequest r) {
        String id    = r.getParameter("id");
        String brand = r.getParameter("brand");
        String model = r.getParameter("model");
        String rate  = r.getParameter("dailyRate");
        String type  = r.getParameter("type");

        if (id == null || id.trim().isEmpty())    return "Vehicle ID is required.";
        if (!id.matches("[A-Za-z0-9]+"))           return "Vehicle ID must be alphanumeric only.";
        if (brand == null || brand.trim().isEmpty()) return "Brand is required.";
        if (model == null || model.trim().isEmpty()) return "Model is required.";
        if (type == null || (!type.equals("Car") && !type.equals("Bike") && !type.equals("Van")))
            return "Invalid vehicle type.";
        double rateVal = parseDOr(rate, -1);
        if (rateVal < 0) return "Daily rate must be a positive number.";
        return null;
    }

    private Vehicle buildVehicle(HttpServletRequest r) {
        String type = r.getParameter("type");
        String id   = r.getParameter("id").trim();
        String brand = r.getParameter("brand").trim();
        String model = r.getParameter("model").trim();
        int year     = parseI(r.getParameter("year"), 2024);
        double rate  = parseDOr(r.getParameter("dailyRate"), 0);
        boolean avail = "on".equalsIgnoreCase(r.getParameter("available"))
                     || "true".equalsIgnoreCase(r.getParameter("available"));
        String loc   = r.getParameter("location");
        String img   = r.getParameter("imageUrl");
        String desc  = r.getParameter("description");

        switch (type) {
            case "Car":
                return new Car(id, brand, model, year, rate, avail, loc, img, desc,
                        parseI(r.getParameter("seats"), 4), r.getParameter("transmission"));
            case "Bike":
                return new Bike(id, brand, model, year, rate, avail, loc, img, desc,
                        parseI(r.getParameter("engineCC"), 100), r.getParameter("bikeType"));
            case "Van":
                return new Van(id, brand, model, year, rate, avail, loc, img, desc,
                        parseI(r.getParameter("cargoCapacity"), 0),
                        parseI(r.getParameter("passengerCapacity"), 0));
            default:
                throw new IllegalArgumentException("Unknown type: " + type);
        }
    }

    private int    parseI(String s, int d)      { try { return Integer.parseInt(s.trim()); }  catch (Exception e) { return d; } }
    private double parseDOr(String s, double d) { try { return Double.parseDouble(s.trim()); } catch (Exception e) { return d; } }
    private Double parseD(String s)             { try { return (s==null||s.isEmpty()) ? null : Double.parseDouble(s); } catch (Exception e) { return null; } }
}
