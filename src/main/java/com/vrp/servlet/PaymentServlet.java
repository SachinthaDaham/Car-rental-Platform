package com.vrp.servlet;

import com.vrp.dao.BookingDAO;
import com.vrp.dao.PaymentDAO;
import com.vrp.model.Booking;
import com.vrp.model.Payment;
import com.vrp.model.User;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Handles the payment flow for booking confirmation.
 * GET  form    — show payment form for a PENDING booking
 * GET  success — show receipt after payment
 * POST create  — process card, confirm booking
 */
@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {

    private BookingDAO bookingDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        String base = System.getProperty("user.home") + "/vrp_data/";
        bookingDAO = new BookingDAO(base + "bookings.txt");
        paymentDAO = new PaymentDAO(base + "payments.txt");
    }

    // ── GET ───────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "form";

        User user = sessionUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        try {
            switch (action) {

                case "form": {
                    String bookingId = req.getParameter("bookingId");
                    Booking b = bookingDAO.getBookingById(bookingId);
                    if (b == null
                            || !b.getCustomerUsername().equalsIgnoreCase(user.getUsername())
                            || !b.isPending()) {
                        resp.sendRedirect(req.getContextPath() + "/booking?action=my");
                        return;
                    }
                    // Already paid — go straight to receipt
                    if (paymentDAO.getByBookingId(bookingId) != null) {
                        resp.sendRedirect(req.getContextPath() + "/payment?action=success&bookingId=" + bookingId);
                        return;
                    }
                    req.setAttribute("booking", b);
                    req.setAttribute("pageTitle", "Secure Payment — DriveLanka");
                    req.getRequestDispatcher("/WEB-INF/views/paymentForm.jsp").forward(req, resp);
                    return;
                }

                case "success": {
                    String bookingId = req.getParameter("bookingId");
                    Booking b  = bookingDAO.getBookingById(bookingId);
                    Payment  p = paymentDAO.getByBookingId(bookingId);
                    if (b == null || p == null) {
                        resp.sendRedirect(req.getContextPath() + "/booking?action=my");
                        return;
                    }
                    req.setAttribute("booking", b);
                    req.setAttribute("payment", p);
                    req.setAttribute("pageTitle", "Payment Confirmed — DriveLanka");
                    req.getRequestDispatcher("/WEB-INF/views/paymentSuccess.jsp").forward(req, resp);
                    return;
                }

                default:
                    resp.sendRedirect(req.getContextPath() + "/booking?action=my");
            }
        } catch (IOException e) {
            throw new ServletException(e);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = sessionUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String bookingId  = req.getParameter("bookingId");
        String cardNumber = req.getParameter("cardNumber");
        String cardHolder = req.getParameter("cardHolder");
        String expiry     = req.getParameter("expiry");
        String cvv        = req.getParameter("cvv");

        try {
            Booking b = bookingDAO.getBookingById(bookingId);
            if (b == null
                    || !b.getCustomerUsername().equalsIgnoreCase(user.getUsername())
                    || !b.isPending()) {
                resp.sendRedirect(req.getContextPath() + "/booking?action=my");
                return;
            }

            // ── Validation ────────────────────────────────────────────────────
            String error = validateCard(cardNumber, cardHolder, expiry, cvv);
            if (error != null) {
                req.setAttribute("booking", b);
                req.setAttribute("errorMsg", error);
                req.setAttribute("pageTitle", "Secure Payment — DriveLanka");
                req.getRequestDispatcher("/WEB-INF/views/paymentForm.jsp").forward(req, resp);
                return;
            }

            String clean = cardNumber.replaceAll("[^0-9]", "");

            // Test decline card: 4000000000000002
            if ("4000000000000002".equals(clean)) {
                req.setAttribute("booking", b);
                req.setAttribute("errorMsg", "Your card was declined. Please try a different card or use a test card.");
                req.setAttribute("pageTitle", "Secure Payment — DriveLanka");
                req.getRequestDispatcher("/WEB-INF/views/paymentForm.jsp").forward(req, resp);
                return;
            }

            // ── Process payment ───────────────────────────────────────────────
            String cardType  = detectCardType(clean);
            String last4     = clean.substring(clean.length() - 4);
            String paymentId = paymentDAO.nextPaymentId();

            Payment payment = new Payment(
                paymentId, bookingId, user.getUsername(),
                last4, cardHolder.trim(), cardType,
                b.getTotalCost(), "SUCCESS", Payment.now()
            );
            paymentDAO.addPayment(payment);

            // Auto-confirm the booking
            bookingDAO.updateStatus(bookingId, "CONFIRMED");

            resp.sendRedirect(req.getContextPath() + "/payment?action=success&bookingId=" + bookingId);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private String validateCard(String number, String holder, String expiry, String cvv) {
        if (number == null || holder == null || expiry == null || cvv == null)
            return "All payment fields are required.";
        String clean = number.replaceAll("[^0-9]", "");
        if (clean.length() < 13 || clean.length() > 19)
            return "Invalid card number length.";
        if (!luhn(clean))
            return "Invalid card number. Please check and try again.";
        if (holder.trim().length() < 2)
            return "Please enter the cardholder name as it appears on the card.";
        if (!expiry.matches("(0[1-9]|1[0-2])/[0-9]{2}"))
            return "Invalid expiry date. Use MM/YY format.";
        if (cvv.length() < 3 || cvv.length() > 4 || !cvv.matches("[0-9]+"))
            return "Invalid CVV/CVC code.";
        return null;
    }

    private boolean luhn(String number) {
        int sum = 0;
        boolean alt = false;
        for (int i = number.length() - 1; i >= 0; i--) {
            int n = number.charAt(i) - '0';
            if (alt) { n *= 2; if (n > 9) n -= 9; }
            sum += n;
            alt = !alt;
        }
        return sum % 10 == 0;
    }

    private String detectCardType(String clean) {
        if (clean.startsWith("4"))                                   return "VISA";
        if (clean.startsWith("5") || clean.startsWith("2"))         return "MASTERCARD";
        if (clean.startsWith("34") || clean.startsWith("37"))       return "AMEX";
        if (clean.startsWith("6011") || clean.startsWith("65"))     return "DISCOVER";
        return "CARD";
    }

    private User sessionUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (User) s.getAttribute("loggedInUser");
    }
}
