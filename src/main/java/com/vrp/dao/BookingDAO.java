package com.vrp.dao;

import com.vrp.model.Booking;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

public class BookingDAO {

    public BookingDAO(String ignored) {}

    // ── CREATE ───────────────────────────────────────────────────────────────
    public void addBooking(Booking b) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO bookings VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
            ps.setString(1, b.getBookingId());
            ps.setString(2, b.getVehicleId());
            ps.setString(3, b.getVehicleName());
            ps.setString(4, b.getVehicleType());
            ps.setString(5, b.getCustomerUsername());
            ps.setString(6, b.getCustomerName());
            ps.setString(7, b.getStartDate());
            ps.setString(8, b.getEndDate());
            ps.setInt(9, b.getDays());
            ps.setDouble(10, b.getDailyRate());
            ps.setDouble(11, b.getTotalCost());
            ps.setString(12, b.getStatus());
            ps.setString(13, b.getCreatedAt());
            ps.executeUpdate();
        }
    }

    // ── READ ─────────────────────────────────────────────────────────────────
    public List<Booking> getAllBookings() throws SQLException {
        List<Booking> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM bookings ORDER BY created_at DESC")) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public Booking getBookingById(String id) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM bookings WHERE booking_id = ?")) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<Booking> getBookingsByUser(String username) throws SQLException {
        List<Booking> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM bookings WHERE customer_username = ? ORDER BY created_at DESC")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<Booking> getBookingsByVehicle(String vehicleId) throws SQLException {
        List<Booking> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM bookings WHERE vehicle_id = ?")) {
            ps.setString(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public boolean hasDateConflict(String vehicleId, String startDate, String endDate) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE vehicle_id = ? " +
                     "AND status IN ('PENDING','CONFIRMED') " +
                     "AND start_date < ? AND end_date > ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, vehicleId);
            ps.setString(2, endDate);
            ps.setString(3, startDate);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public List<String[]> getBookedDateRanges(String vehicleId) throws SQLException {
        List<String[]> ranges = new ArrayList<>();
        String sql = "SELECT start_date, end_date FROM bookings WHERE vehicle_id = ? " +
                     "AND status IN ('PENDING','CONFIRMED')";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    ranges.add(new String[]{rs.getString("start_date"), rs.getString("end_date")});
            }
        }
        return ranges;
    }

    // ── UPDATE ───────────────────────────────────────────────────────────────
    public boolean updateStatus(String bookingId, String newStatus) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "UPDATE bookings SET status = ? WHERE booking_id = ?")) {
            ps.setString(1, newStatus);
            ps.setString(2, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── DELETE ───────────────────────────────────────────────────────────────
    public boolean deleteBooking(String bookingId) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "DELETE FROM bookings WHERE booking_id = ?")) {
            ps.setString(1, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── STATS ────────────────────────────────────────────────────────────────
    public Map<String, Object> getStats() throws SQLException {
        List<Booking> all = getAllBookings();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("total",     all.size());
        m.put("pending",   all.stream().filter(Booking::isPending).count());
        m.put("confirmed", all.stream().filter(Booking::isConfirmed).count());
        m.put("cancelled", all.stream().filter(Booking::isCancelled).count());
        m.put("completed", all.stream().filter(Booking::isCompleted).count());
        double revenue = all.stream().filter(b -> !b.isCancelled())
                            .mapToDouble(Booking::getTotalCost).sum();
        m.put("totalRevenue", revenue);
        return m;
    }

    public synchronized String nextBookingId() throws SQLException {
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(
                 "SELECT booking_id FROM bookings ORDER BY booking_id DESC LIMIT 1")) {
            int max = 0;
            if (rs.next()) {
                String last = rs.getString(1);
                if (last != null && last.startsWith("BK"))
                    try { max = Integer.parseInt(last.substring(2)); } catch (NumberFormatException ignored) {}
            }
            return String.format("BK%04d", max + 1);
        }
    }

    private Booking map(ResultSet rs) throws SQLException {
        return new Booking(
            rs.getString("booking_id"),
            rs.getString("vehicle_id"),
            rs.getString("vehicle_name"),
            rs.getString("vehicle_type"),
            rs.getString("customer_username"),
            rs.getString("customer_name"),
            rs.getString("start_date"),
            rs.getString("end_date"),
            rs.getInt("days"),
            rs.getDouble("daily_rate"),
            rs.getDouble("total_cost"),
            rs.getString("status"),
            rs.getString("created_at")
        );
    }
}
