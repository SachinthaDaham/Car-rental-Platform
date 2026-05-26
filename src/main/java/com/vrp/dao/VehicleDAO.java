package com.vrp.dao;

import com.vrp.model.*;
import java.sql.*;
import java.util.*;

public class VehicleDAO {

    public VehicleDAO(String ignored) {}

    // ── CREATE ───────────────────────────────────────────────────────────────
    public void addVehicle(Vehicle v) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO vehicles VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")) {
            ps.setString(1, v.getId());
            ps.setString(2, v.getType());
            ps.setString(3, v.getBrand());
            ps.setString(4, v.getModel());
            ps.setInt(5, v.getYear());
            ps.setDouble(6, v.getDailyRate());
            ps.setBoolean(7, v.isAvailable());
            ps.setString(8, v.getLocation());
            ps.setString(9, v.getImageUrl());
            ps.setString(10, v.getDescription());
            ps.setString(11, getExtra1(v));
            ps.setString(12, getExtra2(v));
            ps.executeUpdate();
        }
    }

    // ── READ ─────────────────────────────────────────────────────────────────
    public List<Vehicle> getAllVehicles() throws SQLException {
        List<Vehicle> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM vehicles")) {
            while (rs.next()) {
                Vehicle v = map(rs);
                if (v != null) list.add(v);
            }
        }
        return list;
    }

    public Vehicle getVehicleById(String id) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM vehicles WHERE id = ?")) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<Vehicle> filter(String keyword, String type,
                                Double minRate, Double maxRate,
                                Boolean availableOnly) throws SQLException {
        List<Vehicle> all = getAllVehicles();
        List<Vehicle> out = new ArrayList<>();
        String k = keyword == null ? "" : keyword.toLowerCase().trim();
        for (Vehicle v : all) {
            if (!k.isEmpty() &&
                    !(v.getBrand().toLowerCase().contains(k)
                    || v.getModel().toLowerCase().contains(k)
                    || v.getId().toLowerCase().contains(k)
                    || (v.getLocation()    != null && v.getLocation().toLowerCase().contains(k))
                    || (v.getDescription() != null && v.getDescription().toLowerCase().contains(k)))) continue;
            if (type != null && !type.isEmpty() && !v.getType().equalsIgnoreCase(type)) continue;
            if (minRate != null && v.getDailyRate() < minRate) continue;
            if (maxRate != null && v.getDailyRate() > maxRate) continue;
            if (Boolean.TRUE.equals(availableOnly) && !v.isAvailable()) continue;
            out.add(v);
        }
        return out;
    }

    // ── UPDATE ───────────────────────────────────────────────────────────────
    public boolean updateVehicle(Vehicle v) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "UPDATE vehicles SET type=?, brand=?, model=?, year=?, daily_rate=?, " +
                 "available=?, location=?, image_url=?, description=?, extra1=?, extra2=? WHERE id=?")) {
            ps.setString(1, v.getType());
            ps.setString(2, v.getBrand());
            ps.setString(3, v.getModel());
            ps.setInt(4, v.getYear());
            ps.setDouble(5, v.getDailyRate());
            ps.setBoolean(6, v.isAvailable());
            ps.setString(7, v.getLocation());
            ps.setString(8, v.getImageUrl());
            ps.setString(9, v.getDescription());
            ps.setString(10, getExtra1(v));
            ps.setString(11, getExtra2(v));
            ps.setString(12, v.getId());
            return ps.executeUpdate() > 0;
        }
    }

    // ── DELETE ───────────────────────────────────────────────────────────────
    public boolean deleteVehicle(String id) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "DELETE FROM vehicles WHERE id = ?")) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean toggleAvailability(String id) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "UPDATE vehicles SET available = NOT available WHERE id = ?")) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ── STATS ────────────────────────────────────────────────────────────────
    public Map<String, Object> getStats() throws SQLException {
        List<Vehicle> all = getAllVehicles();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("total",           all.size());
        m.put("available",       all.stream().filter(Vehicle::isAvailable).count());
        m.put("rented",          all.stream().filter(v -> !v.isAvailable()).count());
        m.put("cars",            all.stream().filter(v -> v instanceof Car).count());
        m.put("bikes",           all.stream().filter(v -> v instanceof Bike).count());
        m.put("vans",            all.stream().filter(v -> v instanceof Van).count());
        m.put("avgRate",         all.stream().mapToDouble(Vehicle::getDailyRate).average().orElse(0));
        m.put("fleetValuePerDay",all.stream().mapToDouble(Vehicle::getDailyRate).sum());
        return m;
    }

    public List<Vehicle> getTopByRate(int n) throws SQLException {
        List<Vehicle> all = getAllVehicles();
        all.sort((a, b) -> Double.compare(b.getDailyRate(), a.getDailyRate()));
        return all.subList(0, Math.min(n, all.size()));
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    private Vehicle map(ResultSet rs) throws SQLException {
        String type  = rs.getString("type");
        String id    = rs.getString("id");
        String brand = rs.getString("brand");
        String model = rs.getString("model");
        int    year  = rs.getInt("year");
        double rate  = rs.getDouble("daily_rate");
        boolean avail = rs.getBoolean("available");
        String loc   = rs.getString("location");
        String img   = rs.getString("image_url");
        String desc  = rs.getString("description");
        String e1    = rs.getString("extra1");
        String e2    = rs.getString("extra2");
        switch (type) {
            case "Car":  return new Car (id, brand, model, year, rate, avail, loc, img, desc, intOr(e1, 4), e2);
            case "Bike": return new Bike(id, brand, model, year, rate, avail, loc, img, desc, intOr(e1, 100), e2);
            case "Van":  return new Van (id, brand, model, year, rate, avail, loc, img, desc, intOr(e1, 0), intOr(e2, 0));
            default: return null;
        }
    }

    private String getExtra1(Vehicle v) {
        if (v instanceof Car)  return String.valueOf(((Car)  v).getSeats());
        if (v instanceof Bike) return String.valueOf(((Bike) v).getEngineCC());
        if (v instanceof Van)  return String.valueOf(((Van)  v).getCargoCapacity());
        return "";
    }

    private String getExtra2(Vehicle v) {
        if (v instanceof Car)  return ((Car)  v).getTransmission();
        if (v instanceof Bike) return ((Bike) v).getBikeType();
        if (v instanceof Van)  return String.valueOf(((Van)  v).getPassengerCapacity());
        return "";
    }

    private int intOr(String s, int d) {
        try { return Integer.parseInt(s); } catch (Exception e) { return d; }
    }
}
