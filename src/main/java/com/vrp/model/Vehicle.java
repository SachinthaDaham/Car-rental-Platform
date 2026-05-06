package com.vrp.model;

/**
 * Abstract base class for all rentable vehicles.
 * Demonstrates:
 *   - ENCAPSULATION  : all fields are private, accessed via getters/setters
 *   - ABSTRACTION    : abstract methods force subclass contracts
 *   - INHERITANCE    : Car, Bike, Van extend this class
 *   - POLYMORPHISM   : abstract methods resolved at runtime per subclass
 */
public abstract class Vehicle implements Rentable {
    private String id;
    private String brand;
    private String model;
    private int year;
    private double dailyRate;
    private boolean available;
    private String location;
    private String imageUrl;
    private String description;

    protected Vehicle() {}

    protected Vehicle(String id, String brand, String model, int year,
                      double dailyRate, boolean available,
                      String location, String imageUrl, String description) {
        this.id = id;
        this.brand = brand;
        this.model = model;
        this.year = year;
        this.dailyRate = dailyRate;
        this.available = available;
        this.location = location;
        this.imageUrl = imageUrl;
        this.description = description;
    }

    // ── Getters / Setters (ENCAPSULATION) ──────────────────────────────────
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
    public double getDailyRate() { return dailyRate; }
    public void setDailyRate(double dailyRate) { this.dailyRate = dailyRate; }
    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getName() { return brand + " " + model; }

    // ── Abstract methods (POLYMORPHISM — resolved at runtime) ───────────────

    /** Each subclass returns its own type label. */
    public abstract String getType();

    /** Each subclass formats its specification line differently. */
    public abstract String getSpecLine();

    /** Each subclass provides a Bootstrap Icons class for the UI. */
    public abstract String getIconClass();

    /** Weekly rate discount differs per type: Bike 10%, Car 15%, Van 20%. */
    public abstract double weeklyRate();

    // ── Rentable interface (INTERFACE POLYMORPHISM) ─────────────────────────
    // Default implementation: subclasses override to add surcharges.
    @Override
    public double calculateRentalCost(int days) {
        if (days <= 0) return 0;
        if (days >= 7) {
            int weeks = days / 7;
            int rem   = days % 7;
            return weeks * weeklyRate() + rem * dailyRate;
        }
        return days * dailyRate;
    }

    @Override
    public String getRentalSummary(int days) {
        return String.format("%d day(s) x LKR %.0f = LKR %.0f", days, dailyRate, calculateRentalCost(days));
    }

    // ── File serialisation ──────────────────────────────────────────────────
    public String toFileString() {
        return String.join("|",
                getType(), safe(id), safe(brand), safe(model),
                String.valueOf(year), String.valueOf(dailyRate),
                String.valueOf(available),
                safe(location), safe(imageUrl), safe(description),
                extra1(), extra2());
    }

    /** Subclasses serialize their two type-specific fields. */
    protected abstract String extra1();
    protected abstract String extra2();

    private static String safe(String s) { return s == null ? "" : s.replace("|", "/"); }
}
