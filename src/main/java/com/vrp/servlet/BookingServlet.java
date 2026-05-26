package com.vrp.servlet;

import com.vrp.dao.BookingDAO;
import com.vrp.dao.VehicleDAO;
import com.vrp.model.Booking;
import com.vrp.model.User;
import com.vrp.model.Vehicle;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Front-controller servlet for the Booking module.
 *
 * GET  actions: form | confirm | my | adminList | updateStatus | cancel | delete
 * POST actions: create
 */
@WebServlet("/booking")
public class BookingServlet extends HttpServlet {

    private BookingDAO bookingDAO;
    private VehicleDAO vehicleDAO;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        bookingDAO = new BookingDAO(null);
        vehicleDAO = new VehicleDAO(null);
    }

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "my";

        try {
            switch (action) {

                case "form": {
                    String id = req.getParameter("id");
                    Vehicle v = vehicleDAO.getVehicleById(id);
                    if (v == null || !v.isAvailable()) {
                        resp.sendRedirect(req.getContextPath() + "/vehicles?action=browse");
                        return;
                    }
                    // Pass booked ranges as JSON so the date picker can block conflicts
                    List<String[]> bookedRanges = bookingDAO.getBookedDateRanges(id);
                    StringBuilder rangesJson = new StringBuilder("[");
                    for (int i = 0; i < bookedRanges.size(); i++) {
                        if (i > 0) rangesJson.append(",");
                        rangesJson.append("{\"start\":\"").append(bookedRanges.get(i)[0])
                                  .append("\",\"end\":\"").append(bookedRanges.get(i)[1]).append("\"}");
                    }
                    rangesJson.append("]");
                    req.setAttribute("vehicle", v);
                    req.setAttribute("today", LocalDate.now().toString());
                    req.setAttribute("maxDate", LocalDate.now().plusYears(1).toString());
                    req.setAttribute("bookedRangesJson", rangesJson.toString());
                    req.getRequestDispatcher("/WEB-INF/views/bookingForm.jsp").forward(req, resp);
                    return;
                }

                case "confirm": {
                    String bid = req.getParameter("id");
                    Booking b = bookingDAO.getBookingById(bid);
                    if (b == null) {
                        resp.sendRedirect(req.getContextPath() + "/booking?action=my");
                        return;
                    }
                    req.setAttribute("booking", b);
                    req.getRequestDispatcher("/WEB-INF/views/bookingConfirm.jsp").forward(req, resp);
                    return;
                }

                case "my": {
                    User u = sessionUser(req);
                    if (u == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }
                    List<Booking> list = bookingDAO.getBookingsByUser(u.getUsername());
                    req.setAttribute("bookings", list);
                    req.getRequestDispatcher("/WEB-INF/views/myBookings.jsp").forward(req, resp);
                    return;
                }

                case "adminList": {
                    List<Booking> all = bookingDAO.getAllBookings();
                    Map<String, Object> stats = bookingDAO.getStats();
                    req.setAttribute("bookings", all);
                    req.setAttribute("bookingStats", stats);
                    req.getRequestDispatcher("/WEB-INF/views/listBookings.jsp").forward(req, resp);
                    return;
                }

                case "updateStatus": {
                    User adminUser = sessionUser(req);
                    if (adminUser == null || !adminUser.isAdmin()) {
                        resp.sendRedirect(req.getContextPath() + "/auth?action=login");
                        return;
                    }
                    String bid    = req.getParameter("id");
                    String status = req.getParameter("status");
                    String[] allowed = {"CONFIRMED", "CANCELLED", "COMPLETED"};
                    boolean validStatus = false;
                    if (status != null) {
                        for (String s : allowed) if (s.equalsIgnoreCase(status)) { validStatus = true; break; }
                    }
                    if (bid != null && validStatus) {
                        Booking b = bookingDAO.getBookingById(bid);
                        if (b != null && !b.isCompleted()) {
                            bookingDAO.updateStatus(bid, status.toUpperCase());
                            if ("CANCELLED".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status)) {
                                Vehicle v2 = vehicleDAO.getVehicleById(b.getVehicleId());
                                if (v2 != null && !v2.isAvailable()) {
                                    v2.setAvailable(true);
                                    vehicleDAO.updateVehicle(v2);
                                }
                            }
                        }
                    }
                    resp.sendRedirect(req.getContextPath() + "/booking?action=adminList&msg=updated");
                    return;
                }

                case "cancel": {
                    // Customer cancels their own PENDING or CONFIRMED booking
                    User u = sessionUser(req);
                    String bid = req.getParameter("id");
                    String cancelError = null;
                    if (u != null && bid != null) {
                        Booking b = bookingDAO.getBookingById(bid);
                        if (b == null) {
                            cancelError = "Booking not found.";
                        } else if (!b.getCustomerUsername().equalsIgnoreCase(u.getUsername())) {
                            cancelError = "You can only cancel your own bookings.";
                        } else if (b.isCancelled()) {
                            cancelError = "This booking is already cancelled.";
                        } else if (b.isCompleted()) {
                            cancelError = "Completed bookings cannot be cancelled.";
                        } else {
                            // Allow cancel for PENDING or CONFIRMED
                            bookingDAO.updateStatus(bid, "CANCELLED");
                            Vehicle v2 = vehicleDAO.getVehicleById(b.getVehicleId());
                            if (v2 != null && !v2.isAvailable()) {
                                v2.setAvailable(true);
                                vehicleDAO.updateVehicle(v2);
                            }
                        }
                    }
                    if (cancelError != null) {
                        resp.sendRedirect(req.getContextPath() + "/booking?action=my&error=" + java.net.URLEncoder.encode(cancelError, "UTF-8"));
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/booking?action=my&msg=cancelled");
                    }
                    return;
                }

                case "delete": {
                    User adminUser = sessionUser(req);
                    if (adminUser == null || !adminUser.isAdmin()) {
                        resp.sendRedirect(req.getContextPath() + "/auth?action=login");
                        return;
                    }
                    String bid = req.getParameter("id");
                    if (bid != null) bookingDAO.deleteBooking(bid);
                    resp.sendRedirect(req.getContextPath() + "/booking?action=adminList&msg=deleted");
                    return;
                }

                default:
                    resp.sendRedirect(req.getContextPath() + "/booking?action=my");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── POST ─────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = sessionUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }

        String vehicleId  = req.getParameter("vehicleId");
        String startDate  = req.getParameter("startDate");
        String endDate    = req.getParameter("endDate");

        try {
            Vehicle v = vehicleDAO.getVehicleById(vehicleId);
            if (v == null || !v.isAvailable()) {
                req.setAttribute("errorMsg", "This vehicle is no longer available.");
                req.setAttribute("vehicle", v);
                req.getRequestDispatcher("/WEB-INF/views/bookingForm.jsp").forward(req, resp);
                return;
            }

            // Validate dates
            String dateError = validateDates(startDate, endDate);
            if (dateError != null) {
                req.setAttribute("errorMsg", dateError);
                req.setAttribute("vehicle", v);
                req.setAttribute("today",   LocalDate.now().toString());
                req.setAttribute("maxDate", LocalDate.now().plusYears(1).toString());
                req.setAttribute("bookedRangesJson", "[]");
                req.getRequestDispatcher("/WEB-INF/views/bookingForm.jsp").forward(req, resp);
                return;
            }

            // Check for date conflicts with existing bookings
            if (bookingDAO.hasDateConflict(vehicleId, startDate, endDate)) {
                List<String[]> bookedRanges = bookingDAO.getBookedDateRanges(vehicleId);
                StringBuilder rangesJson = new StringBuilder("[");
                for (int i = 0; i < bookedRanges.size(); i++) {
                    if (i > 0) rangesJson.append(",");
                    rangesJson.append("{\"start\":\"").append(bookedRanges.get(i)[0])
                              .append("\",\"end\":\"").append(bookedRanges.get(i)[1]).append("\"}");
                }
                rangesJson.append("]");
                req.setAttribute("errorMsg", "Those dates conflict with an existing booking. Please choose different dates.");
                req.setAttribute("vehicle", v);
                req.setAttribute("today",   LocalDate.now().toString());
                req.setAttribute("maxDate", LocalDate.now().plusYears(1).toString());
                req.setAttribute("bookedRangesJson", rangesJson.toString());
                req.getRequestDispatcher("/WEB-INF/views/bookingForm.jsp").forward(req, resp);
                return;
            }

            int    days      = Booking.daysBetween(startDate, endDate);
            double totalCost = v.calculateRentalCost(days);
            String bookingId = bookingDAO.nextBookingId();

            Booking b = new Booking(
                bookingId, v.getId(), v.getName(), v.getType(),
                user.getUsername(), user.getName(),
                startDate, endDate, days, v.getDailyRate(), totalCost,
                "PENDING", LocalDate.now().toString()
            );
            bookingDAO.addBooking(b);

            resp.sendRedirect(req.getContextPath() + "/booking?action=confirm&id=" + bookingId);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private User sessionUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (User) s.getAttribute("loggedInUser");
    }

    private String validateDates(String start, String end) {
        if (start == null || start.isEmpty()) return "Please select a start date.";
        if (end   == null || end.isEmpty())   return "Please select an end date.";
        try {
            LocalDate s = LocalDate.parse(start);
            LocalDate e = LocalDate.parse(end);
            if (s.isBefore(LocalDate.now()))  return "Start date cannot be in the past.";
            if (!e.isAfter(s))                return "End date must be after start date.";
            if (Booking.daysBetween(start, end) > 365) return "Rental period cannot exceed 365 days.";
        } catch (Exception ex) { return "Invalid date format."; }
        return null;
    }
}
