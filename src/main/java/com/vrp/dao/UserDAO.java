package com.vrp.dao;

import com.vrp.model.User;
import java.io.*;
import java.util.*;

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
                // Add a default admin user if the file is freshly created
                try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, true))) {
                    bw.write(new User("admin", "admin123", "System Administrator", "ADMIN").toFileString());
                    bw.newLine();
                }
            }
        } catch (IOException e) { e.printStackTrace(); }
    }

    public synchronized void addUser(User u) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, true))) {
            bw.write(u.toFileString());
            bw.newLine();
        }
    }

    public synchronized List<User> getAllUsers() throws IOException {
        List<User> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] p = line.split("\\|");
                if (p.length >= 4) {
                    list.add(new User(p[0], p[1], p[2], p[3]));
                }
            }
        }
        return list;
    }

    public User getUserByUsername(String username) throws IOException {
        for (User u : getAllUsers()) {
            if (u.getUsername().equalsIgnoreCase(username)) {
                return u;
            }
        }
        return null;
    }

    public User authenticate(String username, String password) throws IOException {
        User u = getUserByUsername(username);
        if (u != null && u.getPassword().equals(password)) {
            return u;
        }
        return null;
    }

    public boolean userExists(String username) throws IOException {
        return getUserByUsername(username) != null;
    }
}
