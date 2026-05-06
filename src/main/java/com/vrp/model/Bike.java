package com.vrp.model;

/**
 * Concrete subclass: Bike.
 * Demonstrates INHERITANCE from Vehicle and POLYMORPHISM via method overrides.
 * Pricing: 10% weekly discount. Insurance surcharge of 5% applied for rentals > 5 days.
 */
public class Bike extends Vehicle {
    private int engineCC;
    private String bikeType;

    public Bike() {}

    public Bike(String id, String brand, String model, int year,
                double dailyRate, boolean available,
                String location, String imageUrl, String description,
                int engineCC, String bikeType) {
        super(id, brand, model, year, dailyRate, available, location, imageUrl, description);
        this.engineCC = engineCC;
        this.bikeType = bikeType;
    }

    public int getEngineCC() { return engineCC; }
    public void setEngineCC(int engineCC) { this.engineCC = engineCC; }
    public String getBikeType() { return bikeType; }
    public void setBikeType(String bikeType) { this.bikeType = bikeType; }

    @Override public String getType()      { return "Bike"; }
    @Override public String getIconClass() { return "bi-bicycle"; }
    @Override public String getSpecLine() {
        return engineCC + "cc &middot; " + bikeType + " &middot; " + getYear();
    }

    /** 10% discount on full weeks. */
    @Override public double weeklyRate() { return getDailyRate() * 7 * 0.90; }

    /**
     * Bikes: 10% weekly discount + 5% insurance surcharge when rental > 5 days.
     * This is unique to Bike and demonstrates polymorphic behaviour.
     */
    @Override
    public double calculateRentalCost(int days) {
        if (days <= 0) return 0;
        int weeks = days / 7;
        int rem   = days % 7;
        double base = weeks * weeklyRate() + rem * getDailyRate();
        // Insurance surcharge for longer rentals
        if (days > 5) base *= 1.05;
        return base;
    }

    @Override
    public String getRentalSummary(int days) {
        double total = calculateRentalCost(days);
        int weeks = days / 7;
        int rem   = days % 7;
        String surcharge = days > 5 ? " + 5% insurance" : "";
        if (weeks > 0) {
            return String.format("%dw %dd · 10%% discount%s · LKR %.0f", weeks, rem, surcharge, total);
        }
        return String.format("%d day(s)%s · LKR %.0f", days, surcharge, total);
    }

    @Override protected String extra1() { return String.valueOf(engineCC); }
    @Override protected String extra2() { return bikeType == null ? "" : bikeType; }
}
