package com.vrp.dao;

import com.vrp.model.Booking;

import java.io.*;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

/**
 * File-based Data Access Object for Booking entities.
 * Demonstrates ENCAPSULATION and the DAO pattern — all file I/O hidden behind
 * a clean public API, so servlets never touch file operations directly.
 *
 * File format (13 pipe-delimited fields per line):
 *   bookingId|vehicleId|vehicleName|vehicleType|customerUsername|customerName|
 *   startDate|endDate|days|dailyRate|totalCost|status|createdAt
 */
public class BookingDAO {

    private final String filePath;

    public BookingDAO(String filePath) {
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

    // ── CREATE ───────────────────────────────────────────────────────────────
    public synchronized void addBooking(Booking b) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, true))) {
            bw.write(b.toFileString());
            bw.newLine();
        }
    }

    // ── READ all ─────────────────────────────────────────────────────────────
    public synchronized List<Booking> getAllBookings() throws IOException {
        List<Booking> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                Booking b = parseLine(line);
                if (b != null) list.add(b);
            }
        }
        return list;
    }

    public Booking getBookingById(String id) throws IOException {
        for (Booking b : getAllBookings())
            if (b.getBookingId().equalsIgnoreCase(id)) return b;
        return null;
    }

    /** Bookings belonging to a specific customer, newest first. */
    public List<Booking> getBookingsByUser(String username) throws IOException {
        List<Booking> result = getAllBookings().stream()
            .filter(b -> b.getCustomerUsername().equalsIgnoreCase(username))
            .collect(Collectors.toList());
        Collections.reverse(result);
        return result;
    }

    /** All bookings for a specific vehicle. */
    public List<Booking> getBookingsByVehicle(String vehicleId) throws IOException {
        return getAllBookings().stream()
            .filter(b -> b.getVehicleId().equalsIgnoreCase(vehicleId))
            .collect(Collectors.toList());
    }

    /**
     * Returns true if the given date range overlaps with any PENDING or CONFIRMED booking
     * for the specified vehicle. Uses exclusive-end convention: conflict when
     * newStart < bookedEnd AND bookedStart < newEnd.
     */
    public boolean hasDateConflict(String vehicleId, String startDate, String endDate) throws IOException {
        LocalDate ns = LocalDate.parse(startDate);
        LocalDate ne = LocalDate.parse(endDate);
        for (Booking b : getAllBookings()) {
            if (!b.getVehicleId().equalsIgnoreCase(vehicleId)) continue;
            if (b.isCancelled() || b.isCompleted()) continue;
            LocalDate bs = LocalDate.parse(b.getStartDate());
            LocalDate be = LocalDate.parse(b.getEndDate());
            if (ns.isBefore(be) && bs.isBefore(ne)) return true;
        }
        return false;
    }

    /**
     * Returns all PENDING/CONFIRMED booked date ranges for a vehicle
     * as a list of {startDate, endDate} string pairs.
     */
    public List<String[]> getBookedDateRanges(String vehicleId) throws IOException {
        List<String[]> ranges = new ArrayList<>();
        for (Booking b : getAllBookings()) {
            if (!b.getVehicleId().equalsIgnoreCase(vehicleId)) continue;
            if (b.isCancelled() || b.isCompleted()) continue;
            ranges.add(new String[]{b.getStartDate(), b.getEndDate()});
        }
        return ranges;
    }

    // ── UPDATE status ────────────────────────────────────────────────────────
    public synchronized boolean updateStatus(String bookingId, String newStatus) throws IOException {
        List<Booking> all = getAllBookings();
        boolean found = false;
        for (Booking b : all) {
            if (b.getBookingId().equalsIgnoreCase(bookingId)) {
                b.setStatus(newStatus); found = true; break;
            }
        }
        if (found) writeAll(all);
        return found;
    }

    // ── DELETE ───────────────────────────────────────────────────────────────
    public synchronized boolean deleteBooking(String bookingId) throws IOException {
        List<Booking> all = getAllBookings();
        boolean removed = all.removeIf(b -> b.getBookingId().equalsIgnoreCase(bookingId));
        if (removed) writeAll(all);
        return removed;
    }

    // ── STATS for admin dashboard ─────────────────────────────────────────────
    public Map<String, Object> getStats() throws IOException {
        List<Booking> all = getAllBookings();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("total",     all.size());
        m.put("pending",   all.stream().filter(Booking::isPending).count());
        m.put("confirmed", all.stream().filter(Booking::isConfirmed).count());
        m.put("cancelled", all.stream().filter(Booking::isCancelled).count());
        m.put("completed", all.stream().filter(Booking::isCompleted).count());
        double revenue = all.stream()
            .filter(b -> !b.isCancelled())
            .mapToDouble(Booking::getTotalCost).sum();
        m.put("totalRevenue", revenue);
        return m;
    }

    /** Generates the next booking ID: BK0001, BK0002, … */
    public synchronized String nextBookingId() throws IOException {
        int count = getAllBookings().size() + 1;
        return String.format("BK%04d", count);
    }

    // ── Private helpers ───────────────────────────────────────────────────────
    private void writeAll(List<Booking> list) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, false))) {
            for (Booking b : list) { bw.write(b.toFileString()); bw.newLine(); }
        }
    }

    private Booking parseLine(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 13) return null;
        try {
            return new Booking(
                p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7],
                Integer.parseInt(p[8]),
                Double.parseDouble(p[9]),
                Double.parseDouble(p[10]),
                p[11], p[12]
            );
        } catch (Exception e) { return null; }
    }
}
