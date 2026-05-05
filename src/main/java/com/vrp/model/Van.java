package com.vrp.model;

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

    @Override public String getType() { return "Van"; }
    @Override public String getIconClass() { return "bi-truck"; }
    @Override public String getSpecLine() {
        return passengerCapacity + " Pax &middot; " + cargoCapacity + "kg cargo &middot; " + getYear();
    }
    @Override public double weeklyRate() { return getDailyRate() * 7 * 0.80; }
    @Override protected String extra1() { return String.valueOf(cargoCapacity); }
    @Override protected String extra2() { return String.valueOf(passengerCapacity); }
}
