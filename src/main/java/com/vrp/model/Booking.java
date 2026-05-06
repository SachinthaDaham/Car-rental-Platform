package com.vrp.model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * Represents a vehicle rental booking.
 * Demonstrates ENCAPSULATION — all fields are private with controlled access.
 * Associated with a Vehicle (via vehicleId) — demonstrates ASSOCIATION relationship.
 */
public class Booking {

    public enum Status { PENDING, CONFIRMED, CANCELLED, COMPLETED }

    private static final DateTimeFormatter FMT = DateTimeFormatter.ISO_LOCAL_DATE;

    private String bookingId;
    private String vehicleId;
    private String vehicleName;
    private String vehicleType;
    private String customerUsername;
    private String customerName;
    private String startDate;   // YYYY-MM-DD
    private String endDate;     // YYYY-MM-DD
    private int    days;
    private double dailyRate;
    private double totalCost;
    private String status;      // PENDING | CONFIRMED | CANCELLED | COMPLETED
    private String createdAt;   // YYYY-MM-DD

    public Booking() {}

    public Booking(String bookingId, String vehicleId, String vehicleName, String vehicleType,
                   String customerUsername, String customerName,
                   String startDate, String endDate,
                   int days, double dailyRate, double totalCost,
                   String status, String createdAt) {
        this.bookingId        = bookingId;
        this.vehicleId        = vehicleId;
        this.vehicleName      = vehicleName;
        this.vehicleType      = vehicleType;
        this.customerUsername = customerUsername;
        this.customerName     = customerName;
        this.startDate        = startDate;
        this.endDate          = endDate;
        this.days             = days;
        this.dailyRate        = dailyRate;
        this.totalCost        = totalCost;
        this.status           = status;
        this.createdAt        = createdAt;
    }

    // ── Getters / Setters ───────────────────────────────────────────────────
    public String getBookingId()        { return bookingId; }
    public void   setBookingId(String v){ bookingId = v; }
    public String getVehicleId()        { return vehicleId; }
    public void   setVehicleId(String v){ vehicleId = v; }
    public String getVehicleName()      { return vehicleName; }
    public String getVehicleType()      { return vehicleType; }
    public String getCustomerUsername() { return customerUsername; }
    public String getCustomerName()     { return customerName; }
    public String getStartDate()        { return startDate; }
    public void   setStartDate(String v){ startDate = v; }
    public String getEndDate()          { return endDate; }
    public void   setEndDate(String v)  { endDate = v; }
    public int    getDays()             { return days; }
    public double getDailyRate()        { return dailyRate; }
    public double getTotalCost()        { return totalCost; }
    public String getStatus()           { return status; }
    public void   setStatus(String v)   { status = v; }
    public String getCreatedAt()        { return createdAt; }

    public boolean isPending()    { return "PENDING".equals(status); }
    public boolean isConfirmed()  { return "CONFIRMED".equals(status); }
    public boolean isCancelled()  { return "CANCELLED".equals(status); }
    public boolean isCompleted()  { return "COMPLETED".equals(status); }

    /** User-friendly status label. */
    public String getStatusLabel() {
        switch (status == null ? "" : status) {
            case "CONFIRMED":  return "Confirmed";
            case "CANCELLED":  return "Cancelled";
            case "COMPLETED":  return "Completed";
            default:           return "Pending";
        }
    }

    /** Tailwind CSS colour classes for the status badge. */
    public String getStatusColor() {
        switch (status == null ? "" : status) {
            case "CONFIRMED":  return "bg-emerald-100 text-emerald-700";
            case "CANCELLED":  return "bg-rose-100 text-rose-700";
            case "COMPLETED":  return "bg-brand-100 text-brand-700";
            default:           return "bg-amber-100 text-amber-700";
        }
    }

    /** Compute days between two ISO date strings. */
    public static int daysBetween(String start, String end) {
        try {
            LocalDate s = LocalDate.parse(start, FMT);
            LocalDate e = LocalDate.parse(end, FMT);
            long d = ChronoUnit.DAYS.between(s, e);
            return d > 0 ? (int) d : 1;
        } catch (Exception ex) { return 1; }
    }

    /** Serialise to pipe-delimited record. */
    public String toFileString() {
        return String.join("|",
            safe(bookingId), safe(vehicleId), safe(vehicleName), safe(vehicleType),
            safe(customerUsername), safe(customerName),
            safe(startDate), safe(endDate),
            String.valueOf(days), String.valueOf(dailyRate), String.valueOf(totalCost),
            safe(status), safe(createdAt));
    }

    private static String safe(String s) { return s == null ? "" : s.replace("|", "/"); }
}
