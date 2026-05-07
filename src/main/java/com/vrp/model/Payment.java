package com.vrp.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Payment {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private String paymentId;
    private String bookingId;
    private String customerUsername;
    private String cardLast4;
    private String cardHolder;
    private String cardType;     // VISA | MASTERCARD | AMEX | CARD
    private double amount;
    private String status;       // SUCCESS | FAILED | REFUNDED
    private String paidAt;       // yyyy-MM-dd HH:mm:ss

    public Payment() {}

    public Payment(String paymentId, String bookingId, String customerUsername,
                   String cardLast4, String cardHolder, String cardType,
                   double amount, String status, String paidAt) {
        this.paymentId        = paymentId;
        this.bookingId        = bookingId;
        this.customerUsername = customerUsername;
        this.cardLast4        = cardLast4;
        this.cardHolder       = cardHolder;
        this.cardType         = cardType;
        this.amount           = amount;
        this.status           = status;
        this.paidAt           = paidAt;
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    public String getPaymentId()        { return paymentId; }
    public String getBookingId()        { return bookingId; }
    public String getCustomerUsername() { return customerUsername; }
    public String getCardLast4()        { return cardLast4; }
    public String getCardHolder()       { return cardHolder; }
    public String getCardType()         { return cardType; }
    public double getAmount()           { return amount; }
    public String getStatus()           { return status; }
    public String getPaidAt()           { return paidAt; }

    public boolean isSuccess()  { return "SUCCESS".equals(status); }
    public boolean isRefunded() { return "REFUNDED".equals(status); }

    public String getCardMasked() { return "**** **** **** " + cardLast4; }

    public String getCardIcon() {
        if ("VISA".equals(cardType))       return "bi-credit-card-2-front-fill";
        if ("MASTERCARD".equals(cardType)) return "bi-credit-card-fill";
        if ("AMEX".equals(cardType))       return "bi-credit-card-2-back-fill";
        return "bi-credit-card-fill";
    }

    public String getCardColor() {
        if ("VISA".equals(cardType))       return "text-blue-600";
        if ("MASTERCARD".equals(cardType)) return "text-red-600";
        if ("AMEX".equals(cardType))       return "text-green-600";
        return "text-slate-600";
    }

    public static String now() {
        return LocalDateTime.now().format(FMT);
    }

    public String toFileString() {
        return String.join("|",
            safe(paymentId), safe(bookingId), safe(customerUsername),
            safe(cardLast4), safe(cardHolder), safe(cardType),
            String.valueOf(amount), safe(status), safe(paidAt));
    }

    private static String safe(String s) { return s == null ? "" : s.replace("|", "/"); }
}
