package com.vrp.dao;

import com.vrp.model.Payment;
import java.sql.*;
import java.util.*;

public class PaymentDAO {

    public PaymentDAO(String ignored) {}

    // ── CREATE ───────────────────────────────────────────────────────────────
    public void addPayment(Payment p) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO payments VALUES (?,?,?,?,?,?,?,?,?)")) {
            ps.setString(1, p.getPaymentId());
            ps.setString(2, p.getBookingId());
            ps.setString(3, p.getCustomerUsername());
            ps.setString(4, p.getCardLast4());
            ps.setString(5, p.getCardHolder());
            ps.setString(6, p.getCardType());
            ps.setDouble(7, p.getAmount());
            ps.setString(8, p.getStatus());
            ps.setString(9, p.getPaidAt());
            ps.executeUpdate();
        }
    }

    // ── READ ─────────────────────────────────────────────────────────────────
    public List<Payment> getAllPayments() throws SQLException {
        List<Payment> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM payments")) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public Payment getByBookingId(String bookingId) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM payments WHERE booking_id = ?")) {
            ps.setString(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public String nextPaymentId() throws SQLException {
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(
                 "SELECT payment_id FROM payments ORDER BY payment_id DESC LIMIT 1")) {
            int max = 0;
            if (rs.next()) {
                String last = rs.getString(1);
                if (last != null && last.startsWith("PAY"))
                    try { max = Integer.parseInt(last.substring(3)); } catch (NumberFormatException ignored) {}
            }
            return String.format("PAY%04d", max + 1);
        }
    }

    public Map<String, Object> getStats() throws SQLException {
        List<Payment> all = getAllPayments();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("total", all.size());
        m.put("revenue", all.stream().filter(Payment::isSuccess).mapToDouble(Payment::getAmount).sum());
        return m;
    }

    private Payment map(ResultSet rs) throws SQLException {
        return new Payment(
            rs.getString("payment_id"),
            rs.getString("booking_id"),
            rs.getString("customer_username"),
            rs.getString("card_last4"),
            rs.getString("card_holder"),
            rs.getString("card_type"),
            rs.getDouble("amount"),
            rs.getString("status"),
            rs.getString("paid_at")
        );
    }
}
