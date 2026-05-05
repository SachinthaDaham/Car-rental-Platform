package com.vrp.model;

/**
 * Abstract base class for all rentable vehicles.
 * Demonstrates ENCAPSULATION (private fields) and ABSTRACTION (abstract methods).
 */
public abstract class Vehicle {
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

    /** POLYMORPHIC: each subclass returns its own type label. */
    public abstract String getType();

    /** POLYMORPHIC: each subclass formats spec line differently. */
    public abstract String getSpecLine();

    /** POLYMORPHIC: each subclass provides icon class for UI. */
    public abstract String getIconClass();

    /** POLYMORPHIC: weekly discount differs by type (Bike 10%, Car 15%, Van 20%). */
    public abstract double weeklyRate();

    public String toFileString() {
        return String.join("|",
                getType(), safe(id), safe(brand), safe(model),
                String.valueOf(year), String.valueOf(dailyRate),
                String.valueOf(available),
                safe(location), safe(imageUrl), safe(description),
                extra1(), extra2());
    }

    /** Subclasses serialize their two extra fields. */
    protected abstract String extra1();
    protected abstract String extra2();

    private static String safe(String s) { return s == null ? "" : s.replace("|", "/"); }
}
