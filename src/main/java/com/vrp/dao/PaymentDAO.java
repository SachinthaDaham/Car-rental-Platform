package com.vrp.dao;

import com.vrp.model.Payment;

import java.io.*;
import java.util.*;

public class PaymentDAO {

    private final String filePath;

    public PaymentDAO(String filePath) {
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

    public synchronized void addPayment(Payment p) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, true))) {
            bw.write(p.toFileString());
            bw.newLine();
        }
    }

    public synchronized List<Payment> getAllPayments() throws IOException {
        List<Payment> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                Payment p = parseLine(line);
                if (p != null) list.add(p);
            }
        }
        return list;
    }

    public Payment getByBookingId(String bookingId) throws IOException {
        for (Payment p : getAllPayments())
            if (p.getBookingId().equalsIgnoreCase(bookingId)) return p;
        return null;
    }

    public synchronized String nextPaymentId() throws IOException {
        return String.format("PAY%04d", getAllPayments().size() + 1);
    }

    public Map<String, Object> getStats() throws IOException {
        List<Payment> all = getAllPayments();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("total", all.size());
        double revenue = all.stream().filter(Payment::isSuccess).mapToDouble(Payment::getAmount).sum();
        m.put("revenue", revenue);
        return m;
    }

    private Payment parseLine(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 9) return null;
        try {
            return new Payment(p[0], p[1], p[2], p[3], p[4], p[5],
                Double.parseDouble(p[6]), p[7], p[8]);
        } catch (Exception e) { return null; }
    }
}
