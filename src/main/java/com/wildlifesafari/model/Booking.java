package com.wildlifesafari.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Booking {

    private int id;
    private int userId;
    private int packageId;
    private String packageType;   // populated via JOIN for display
    private String destination;   // populated via JOIN for display
    private Date safariDate;
    private String timeSlot;
    private int participants;
    private BigDecimal totalCost;
    private String status;
    private String bookingReference;
    private Timestamp createdAt;

    public Booking() {}

    public Booking(int id, int userId, int packageId, String packageType, String destination,
                   Date safariDate, String timeSlot, int participants, BigDecimal totalCost,
                   String status, String bookingReference, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.packageId = packageId;
        this.packageType = packageType;
        this.destination = destination;
        this.safariDate = safariDate;
        this.timeSlot = timeSlot;
        this.participants = participants;
        this.totalCost = totalCost;
        this.status = status;
        this.bookingReference = bookingReference;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getPackageId() { return packageId; }
    public void setPackageId(int packageId) { this.packageId = packageId; }

    public String getPackageType() { return packageType; }
    public void setPackageType(String packageType) { this.packageType = packageType; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public Date getSafariDate() { return safariDate; }
    public void setSafariDate(Date safariDate) { this.safariDate = safariDate; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public int getParticipants() { return participants; }
    public void setParticipants(int participants) { this.participants = participants; }

    public BigDecimal getTotalCost() { return totalCost; }
    public void setTotalCost(BigDecimal totalCost) { this.totalCost = totalCost; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getBookingReference() { return bookingReference; }
    public void setBookingReference(String bookingReference) { this.bookingReference = bookingReference; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}