package com.vrp.dao;

import com.vrp.model.*;

import java.io.*;
import java.util.*;

/**
 * File-based Data Access Object for Vehicle entities.
 * All CRUD operations use plain text file I/O (no database) per the
 * SE1020 assignment requirement.
 */
public class VehicleDAO {

    private final String filePath;

    public VehicleDAO(String filePath) {
        this.filePath = filePath;
        ensureFileExists();
    }

    private void ensureFileExists() {
        try {
            File f = new File(filePath);
            File parent = f.getParentFile();
            if (parent != null && !parent.exists()) parent.mkdirs();
            if (!f.exists()) f.createNewFile();
        } catch (IOException e) { e.printStackTrace(); }
    }

    /** CREATE */
    public synchronized void addVehicle(Vehicle v) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, true))) {
            bw.write(v.toFileString());
            bw.newLine();
        }
    }

    /** READ all */
    public synchronized List<Vehicle> getAllVehicles() throws IOException {
        List<Vehicle> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                Vehicle v = parseLine(line);
                if (v != null) list.add(v);
            }
        }
        return list;
    }

    public Vehicle getVehicleById(String id) throws IOException {
        for (Vehicle v : getAllVehicles())
            if (v.getId().equalsIgnoreCase(id)) return v;
        return null;
    }

    /** READ – multi-criteria filter for the customer browse page. */
    public List<Vehicle> filter(String keyword, String type,
                                Double minRate, Double maxRate,
                                Boolean availableOnly) throws IOException {
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

    /** UPDATE */
    public synchronized boolean updateVehicle(Vehicle updated) throws IOException {
        List<Vehicle> all = getAllVehicles();
        boolean found = false;
        for (int i = 0; i < all.size(); i++) {
            if (all.get(i).getId().equalsIgnoreCase(updated.getId())) {
                all.set(i, updated); found = true; break;
            }
        }
        if (found) writeAll(all);
        return found;
    }

    /** DELETE */
    public synchronized boolean deleteVehicle(String id) throws IOException {
        List<Vehicle> all = getAllVehicles();
        boolean removed = all.removeIf(v -> v.getId().equalsIgnoreCase(id));
        if (removed) writeAll(all);
        return removed;
    }

    /** Toggle availability — used by quick action button on admin list. */
    public synchronized boolean toggleAvailability(String id) throws IOException {
        Vehicle v = getVehicleById(id);
        if (v == null) return false;
        v.setAvailable(!v.isAvailable());
        return updateVehicle(v);
    }

    /** Aggregated stats for the admin dashboard. */
    public Map<String, Object> getStats() throws IOException {
        List<Vehicle> all = getAllVehicles();
        int total = all.size();
        long available = all.stream().filter(Vehicle::isAvailable).count();
        long cars = all.stream().filter(v -> v instanceof Car).count();
        long bikes = all.stream().filter(v -> v instanceof Bike).count();
        long vans = all.stream().filter(v -> v instanceof Van).count();
        double avgRate = all.stream().mapToDouble(Vehicle::getDailyRate).average().orElse(0);
        double fleetValuePerDay = all.stream().mapToDouble(Vehicle::getDailyRate).sum();

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("total", total);
        m.put("available", available);
        m.put("rented", total - available);
        m.put("cars", cars);
        m.put("bikes", bikes);
        m.put("vans", vans);
        m.put("avgRate", avgRate);
        m.put("fleetValuePerDay", fleetValuePerDay);
        return m;
    }

    /** Returns the top N vehicles sorted by daily rate descending. */
    public List<Vehicle> getTopByRate(int n) throws IOException {
        List<Vehicle> all = getAllVehicles();
        all.sort((a, b) -> Double.compare(b.getDailyRate(), a.getDailyRate()));
        return all.subList(0, Math.min(n, all.size()));
    }

    private void writeAll(List<Vehicle> list) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, false))) {
            for (Vehicle v : list) { bw.write(v.toFileString()); bw.newLine(); }
        }
    }

    /** Polymorphic parser — recreates the correct subclass from a record. */
    private Vehicle parseLine(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 12) return null;
        try {
            String type    = p[0];
            String id      = p[1];
            String brand   = p[2];
            String model   = p[3];
            int    year    = Integer.parseInt(p[4]);
            double rate    = Double.parseDouble(p[5]);
            boolean avail  = Boolean.parseBoolean(p[6]);
            String loc     = p[7];
            String img     = p[8];
            String desc    = p[9];
            String e1      = p[10];
            String e2      = p[11];
            switch (type) {
                case "Car":  return new Car (id, brand, model, year, rate, avail, loc, img, desc, intOr(e1, 4), e2);
                case "Bike": return new Bike(id, brand, model, year, rate, avail, loc, img, desc, intOr(e1, 100), e2);
                case "Van":  return new Van (id, brand, model, year, rate, avail, loc, img, desc, intOr(e1, 0), intOr(e2, 0));
                default: return null;
            }
        } catch (Exception e) { return null; }
    }

    private int intOr(String s, int d) { try { return Integer.parseInt(s); } catch (Exception e) { return d; } }
}
