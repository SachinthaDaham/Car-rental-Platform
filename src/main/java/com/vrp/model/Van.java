package com.vrp.model;

/**
 * Concrete subclass: Van.
 * Demonstrates INHERITANCE from Vehicle and POLYMORPHISM via method overrides.
 * Pricing: 20% weekly discount. Mandatory insurance fee of 10% applied for rentals > 3 days.
 */
public class Van extends Vehicle {
    private int cargoCapacity;
    private int passengerCapacity;

    public Van() {}

    public Van(String id, String brand, String model, int year,
               double dailyRate, boolean available,
               String location, String imageUrl, String description,
               int cargoCapacity, int passengerCapacity) {
        super(id, brand, model, year, dailyRate, available, location, imageUrl, description);
        this.cargoCapacity = cargoCapacity;
        this.passengerCapacity = passengerCapacity;
    }

    public int getCargoCapacity() { return cargoCapacity; }
    public void setCargoCapacity(int cargoCapacity) { this.cargoCapacity = cargoCapacity; }
    public int getPassengerCapacity() { return passengerCapacity; }
    public void setPassengerCapacity(int passengerCapacity) { this.passengerCapacity = passengerCapacity; }

    @Override public String getType()      { return "Van"; }
    @Override public String getIconClass() { return "bi-truck"; }
    @Override public String getSpecLine() {
        return passengerCapacity + " Pax &middot; " + cargoCapacity + "kg cargo &middot; " + getYear();
    }

    /** 20% discount on full weeks. */
    @Override public double weeklyRate() { return getDailyRate() * 7 * 0.80; }

    /**
     * Vans: 20% weekly discount + mandatory 10% insurance surcharge when rental > 3 days.
     * This is unique to Van and demonstrates polymorphic behaviour.
     */
    @Override
    public double calculateRentalCost(int days) {
        if (days <= 0) return 0;
        int weeks = days / 7;
        int rem   = days % 7;
        double base = weeks * weeklyRate() + rem * getDailyRate();
        // Insurance surcharge for longer rentals
        if (days > 3) base *= 1.10;
        return base;
    }

    @Override
    public String getRentalSummary(int days) {
        double total = calculateRentalCost(days);
        int weeks = days / 7;
        int rem   = days % 7;
        String surcharge = days > 3 ? " + 10% insurance" : "";
        if (weeks > 0) {
            return String.format("%dw %dd · 20%% discount%s · LKR %.0f", weeks, rem, surcharge, total);
        }
        return String.format("%d day(s)%s · LKR %.0f", days, surcharge, total);
    }

    @Override protected String extra1() { return String.valueOf(cargoCapacity); }
    @Override protected String extra2() { return String.valueOf(passengerCapacity); }
}
