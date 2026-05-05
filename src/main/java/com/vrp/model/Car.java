package com.vrp.model;

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

    @Override public String getType() { return "Car"; }
    @Override public String getIconClass() { return "bi-car-front-fill"; }
    @Override public String getSpecLine() {
        return seats + " Seats &middot; " + transmission + " &middot; " + getYear();
    }
    @Override public double weeklyRate() { return getDailyRate() * 7 * 0.85; }
    @Override protected String extra1() { return String.valueOf(seats); }
    @Override protected String extra2() { return transmission == null ? "" : transmission; }
}
