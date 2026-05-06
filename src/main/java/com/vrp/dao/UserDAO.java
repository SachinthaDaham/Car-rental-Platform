package com.vrp.dao;

import com.vrp.model.User;
import java.io.*;
import java.util.*;

/**
 * File-based Data Access Object for User entities.
 * Demonstrates ENCAPSULATION — all file I/O is hidden behind public methods.
 */
public class UserDAO {
    private final String filePath;

    public UserDAO(String filePath) {
        this.filePath = filePath;
        ensureFileExists();
    }

    private void ensureFileExists() {
        try {
            File f = new File(filePath);
            File parent = f.getParentFile();
            if (parent != null && !parent.exists()) parent.mkdirs();
            if (!f.exists()) {
                f.createNewFile();
                try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, true))) {
                    bw.write(new User("admin", "admin123", "System Administrator", "ADMIN").toFileString());
                    bw.newLine();
                }
            }
        } catch (IOException e) { e.printStackTrace(); }
    }

    /** CREATE */
    public synchronized void addUser(User u) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, true))) {
            bw.write(u.toFileString());
            bw.newLine();
        }
    }

    /** READ all */
    public synchronized List<User> getAllUsers() throws IOException {
        List<User> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] p = line.split("\\|", -1);
                if (p.length >= 4) list.add(new User(p[0], p[1], p[2], p[3]));
            }
        }
        return list;
    }

    public User getUserByUsername(String username) throws IOException {
        for (User u : getAllUsers())
            if (u.getUsername().equalsIgnoreCase(username)) return u;
        return null;
    }

    public User authenticate(String username, String password) throws IOException {
        User u = getUserByUsername(username);
        return (u != null && u.getPassword().equals(password)) ? u : null;
    }

    public boolean userExists(String username) throws IOException {
        return getUserByUsername(username) != null;
    }

    /** DELETE — admin cannot be deleted */
    public synchronized boolean deleteUser(String username) throws IOException {
        if ("admin".equalsIgnoreCase(username)) return false;
        List<User> all = getAllUsers();
        boolean removed = all.removeIf(u -> u.getUsername().equalsIgnoreCase(username));
        if (removed) writeAll(all);
        return removed;
    }

    /** Returns count of users per role. */
    public Map<String, Long> getRoleCounts() throws IOException {
        List<User> all = getAllUsers();
        Map<String, Long> m = new LinkedHashMap<>();
        m.put("total", (long) all.size());
        m.put("admins", all.stream().filter(User::isAdmin).count());
        m.put("customers", all.stream().filter(u -> !u.isAdmin()).count());
        return m;
    }

    private void writeAll(List<User> list) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, false))) {
            for (User u : list) { bw.write(u.toFileString()); bw.newLine(); }
        }
    }
}
