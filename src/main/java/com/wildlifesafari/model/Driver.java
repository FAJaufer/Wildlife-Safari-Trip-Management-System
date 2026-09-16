package com.wildlifesafari.model;

import java.sql.Date;

public class Driver {

    private int id;
    private int userId;
    private String driverName;
    private String licenseNumber;
    private Date licenseExpiry;
    private int experienceYears;
    private String employmentStatus;
    private String availabilityStatus;

    public Driver() {}

    public Driver(int id, int userId, String driverName, String licenseNumber, Date licenseExpiry,
                  int experienceYears, String employmentStatus, String availabilityStatus) {
        this.id = id;
        this.userId = userId;
        this.driverName = driverName;
        this.licenseNumber = licenseNumber;
        this.licenseExpiry = licenseExpiry;
        this.experienceYears = experienceYears;
        this.employmentStatus = employmentStatus;
        this.availabilityStatus = availabilityStatus;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public String getLicenseNumber() { return licenseNumber; }
    public void setLicenseNumber(String licenseNumber) { this.licenseNumber = licenseNumber; }

    public Date getLicenseExpiry() { return licenseExpiry; }
    public void setLicenseExpiry(Date licenseExpiry) { this.licenseExpiry = licenseExpiry; }

    public int getExperienceYears() { return experienceYears; }
    public void setExperienceYears(int experienceYears) { this.experienceYears = experienceYears; }

    public String getEmploymentStatus() { return employmentStatus; }
    public void setEmploymentStatus(String employmentStatus) { this.employmentStatus = employmentStatus; }

    public String getAvailabilityStatus() { return availabilityStatus; }
    public void setAvailabilityStatus(String availabilityStatus) { this.availabilityStatus = availabilityStatus; }
}