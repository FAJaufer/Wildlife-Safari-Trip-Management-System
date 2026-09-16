package com.wildlifesafari.model;

import java.sql.Date;

public class Vehicle {

    private int id;
    private String registrationNumber;
    private String vehicleType;
    private Date insuranceExpiry;
    private String maintenanceStatus;
    private String availabilityStatus;

    public Vehicle() {}

    public Vehicle(int id, String registrationNumber, String vehicleType, Date insuranceExpiry,
                   String maintenanceStatus, String availabilityStatus) {
        this.id = id;
        this.registrationNumber = registrationNumber;
        this.vehicleType = vehicleType;
        this.insuranceExpiry = insuranceExpiry;
        this.maintenanceStatus = maintenanceStatus;
        this.availabilityStatus = availabilityStatus;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getRegistrationNumber() { return registrationNumber; }
    public void setRegistrationNumber(String registrationNumber) { this.registrationNumber = registrationNumber; }

    public String getVehicleType() { return vehicleType; }
    public void setVehicleType(String vehicleType) { this.vehicleType = vehicleType; }

    public Date getInsuranceExpiry() { return insuranceExpiry; }
    public void setInsuranceExpiry(Date insuranceExpiry) { this.insuranceExpiry = insuranceExpiry; }

    public String getMaintenanceStatus() { return maintenanceStatus; }
    public void setMaintenanceStatus(String maintenanceStatus) { this.maintenanceStatus = maintenanceStatus; }

    public String getAvailabilityStatus() { return availabilityStatus; }
    public void setAvailabilityStatus(String availabilityStatus) { this.availabilityStatus = availabilityStatus; }
}