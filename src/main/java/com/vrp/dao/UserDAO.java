package com.vrp.dao;

import com.vrp.model.User;
import java.sql.*;
import java.util.*;

public class UserDAO {

    public UserDAO(String ignored) {
        ensureAdminExists();
    }

    private void ensureAdminExists() {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT IGNORE INTO users VALUES (?,?,?,?)")) {
            ps.setString(1, "admin");
            ps.setString(2, "admin123");
            ps.setString(3, "System Administrator");
            ps.setString(4, "ADMIN");
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // ── CREATE ───────────────────────────────────────────────────────────────
    public void addUser(User u) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO users (username, password, name, role) VALUES (?,?,?,?)")) {
            ps.setString(1, u.getUsername());
            ps.setString(2, u.getPassword());
            ps.setString(3, u.getName());
            ps.setString(4, u.getRole());
            ps.executeUpdate();
        }
    }

    // ── READ ─────────────────────────────────────────────────────────────────
    public List<User> getAllUsers() throws SQLException {
        List<User> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM users")) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public User getUserByUsername(String username) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM users WHERE username = ?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public User authenticate(String username, String password) throws SQLException {
        User u = getUserByUsername(username);
        return (u != null && u.getPassword().equals(password)) ? u : null;
    }

    public boolean userExists(String username) throws SQLException {
        return getUserByUsername(username) != null;
    }

    // ── DELETE ───────────────────────────────────────────────────────────────
    public boolean deleteUser(String username) throws SQLException {
        if ("admin".equalsIgnoreCase(username)) return false;
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "DELETE FROM users WHERE username = ?")) {
            ps.setString(1, username);
            return ps.executeUpdate() > 0;
        }
    }

    public Map<String, Long> getRoleCounts() throws SQLException {
        List<User> all = getAllUsers();
        Map<String, Long> m = new LinkedHashMap<>();
        m.put("total",     (long) all.size());
        m.put("admins",    all.stream().filter(User::isAdmin).count());
        m.put("customers", all.stream().filter(u -> !u.isAdmin()).count());
        return m;
    }

    private User map(ResultSet rs) throws SQLException {
        return new User(
            rs.getString("username"),
            rs.getString("password"),
            rs.getString("name"),
            rs.getString("role")
        );
    }
}
