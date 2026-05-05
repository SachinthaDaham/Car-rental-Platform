package com.vrp.servlet;

import com.vrp.dao.VehicleDAO;
import com.vrp.model.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Front-controller servlet for the Vehicle Management module.
 * Routes via ?action=  list | add | edit | update | delete | toggle |
 *                     browse | details | dashboard | create
 */
@WebServlet("/vehicles")
public class VehicleServlet extends HttpServlet {

    private VehicleDAO dao;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        String dataFile = System.getProperty("user.home") + "/vrp_data/vehicles.txt";
        dao = new VehicleDAO(dataFile);
    }

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
                    req.setAttribute("vehicle", v);
                    req.getRequestDispatcher("/WEB-INF/views/details.jsp").forward(req, resp);
                    return;
                }
                case "dashboard": {
                    Map<String, Object> stats = dao.getStats();
                    req.setAttribute("stats", stats);
                    List<Vehicle> all = dao.getAllVehicles();
                    req.setAttribute("recent", all.subList(Math.max(0, all.size() - 5), all.size()));
                    req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
                    return;
                }
                case "list": {
                    List<Vehicle> all = dao.getAllVehicles();
                    req.setAttribute("vehicles", all);
                    req.getRequestDispatcher("/WEB-INF/views/listVehicles.jsp").forward(req, resp);
                    return;
                }
                case "browse":
                default: {
                    String kw   = req.getParameter("keyword");
                    String type = req.getParameter("type");
                    Double min  = parseD(req.getParameter("minRate"));
                    Double max  = parseD(req.getParameter("maxRate"));
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
        } catch (IOException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("create".equals(action)) {
                dao.addVehicle(buildVehicle(req));
                resp.sendRedirect("vehicles?action=list&msg=created");
            } else if ("update".equals(action)) {
                dao.updateVehicle(buildVehicle(req));
                resp.sendRedirect("vehicles?action=list&msg=updated");
            } else {
                resp.sendRedirect("vehicles?action=list");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private Vehicle buildVehicle(HttpServletRequest r) {
        String type = r.getParameter("type");
        String id = r.getParameter("id");
        String brand = r.getParameter("brand");
        String model = r.getParameter("model");
        int year = parseI(r.getParameter("year"), 2024);
        double rate = parseDOr(r.getParameter("dailyRate"), 0);
        boolean avail = "on".equalsIgnoreCase(r.getParameter("available"))
                || "true".equalsIgnoreCase(r.getParameter("available"));
        String loc = r.getParameter("location");
        String img = r.getParameter("imageUrl");
        String desc = r.getParameter("description");

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
            default: throw new IllegalArgumentException("Unknown type " + type);
        }
    }

    private int parseI(String s, int d) { try { return Integer.parseInt(s); } catch (Exception e) { return d; } }
    private double parseDOr(String s, double d) { try { return Double.parseDouble(s); } catch (Exception e) { return d; } }
    private Double parseD(String s) { try { return s==null||s.isEmpty()?null:Double.parseDouble(s); } catch (Exception e) { return null; } }
}
