package com.vrp.model;

/**
 * Concrete subclass: Car.
 * Demonstrates INHERITANCE from Vehicle and POLYMORPHISM via method overrides.
 * Pricing: 15% weekly discount applied per full week.
 */
public class Car extends Vehicle {
    private int seats;
    private String transmission;

    public Car() {}

    public Car(String id, String brand, String model, int year,
               double dailyRate, boolean available,
               String location, String imageUrl, String description,
               int seats, String transmission) {
        super(id, brand, model, year, dailyRate, available, location, imageUrl, description);
        this.seats = seats;
        this.transmission = transmission;
    }

    public int getSeats() { return seats; }
    public void setSeats(int seats) { this.seats = seats; }
    public String getTransmission() { return transmission; }
    public void setTransmission(String transmission) { this.transmission = transmission; }

    @Override public String getType()      { return "Car"; }
    @Override public String getIconClass() { return "bi-car-front-fill"; }
    @Override public String getSpecLine() {
        return seats + " Seats &middot; " + transmission + " &middot; " + getYear();
    }

    /** 15% discount on full weeks. */
    @Override public double weeklyRate() { return getDailyRate() * 7 * 0.85; }

    /**
     * Cars: flat 15% weekly discount, no surcharges.
     * Overrides Vehicle default to ensure weekly discount is applied correctly.
     */
    @Override
    public double calculateRentalCost(int days) {
        if (days <= 0) return 0;
        int weeks = days / 7;
        int rem   = days % 7;
        return weeks * weeklyRate() + rem * getDailyRate();
    }

    @Override
    public String getRentalSummary(int days) {
        int weeks = days / 7;
        int rem   = days % 7;
        double total = calculateRentalCost(days);
        if (weeks > 0) {
            return String.format("%dw %dd · 15%% weekly discount · LKR %.0f", weeks, rem, total);
        }
        return String.format("%d day(s) · LKR %.0f/day · LKR %.0f", days, getDailyRate(), total);
    }

    @Override protected String extra1() { return String.valueOf(seats); }
    @Override protected String extra2() { return transmission == null ? "" : transmission; }
}
