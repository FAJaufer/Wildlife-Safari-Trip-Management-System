package com.wildlifesafari.model;

import java.math.BigDecimal;

public class SafariPackage {

    private int id;
    private String safariType;
    private String destination;
    private String duration;
    private BigDecimal price;
    private String description;
    private String availabilityStatus;
    private int createdBy;

    public SafariPackage() {}

    public SafariPackage(int id, String safariType, String destination, String duration,
                         BigDecimal price, String description, String availabilityStatus, int createdBy) {
        this.id = id;
        this.safariType = safariType;
        this.destination = destination;
        this.duration = duration;
        this.price = price;
        this.description = description;
        this.availabilityStatus = availabilityStatus;
        this.createdBy = createdBy;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getSafariType() { return safariType; }
    public void setSafariType(String safariType) { this.safariType = safariType; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getAvailabilityStatus() { return availabilityStatus; }
    public void setAvailabilityStatus(String availabilityStatus) { this.availabilityStatus = availabilityStatus; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
}