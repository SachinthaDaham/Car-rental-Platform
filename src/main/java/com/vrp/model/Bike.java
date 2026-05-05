package com.vrp.model;

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

    @Override public String getType() { return "Bike"; }
    @Override public String getIconClass() { return "bi-bicycle"; }
    @Override public String getSpecLine() {
        return engineCC + "cc &middot; " + bikeType + " &middot; " + getYear();
    }
    @Override public double weeklyRate() { return getDailyRate() * 7 * 0.90; }
    @Override protected String extra1() { return String.valueOf(engineCC); }
    @Override protected String extra2() { return bikeType == null ? "" : bikeType; }
}
