package com.vrp.model;

/**
 * Interface defining the rental pricing contract.
 * Demonstrates INTERFACE-BASED POLYMORPHISM — each vehicle type
 * calculates cost differently (Bike: insurance surcharge >5 days,
 * Van: insurance surcharge >3 days, Car: flat weekly discount).
 */
public interface Rentable {

    /** Calculate total rental cost for the given number of days. */
    double calculateRentalCost(int days);

    /** Return a human-readable breakdown of the pricing. */
    String getRentalSummary(int days);
}
