package com.wildlifesafari.model;

import java.sql.Date;

public class SafariSchedule {

    private int id;
    private int bookingId;
    private String bookingReference;   // via JOIN, for display
    private String packageType;        // via JOIN, for display
    private Integer guideId;
    private String guideName;          // via JOIN, for display
    private Integer driverId;
    private String driverName;         // via JOIN, for display
    private Integer vehicleId;
    private String vehicleRegNumber;   // via JOIN, for display
    private Date scheduleDate;
    private String scheduleTime;
    private String tripStatus;

    public SafariSchedule() {}

    public SafariSchedule(int id, int bookingId, String bookingReference, String packageType,
                          Integer guideId, String guideName, Integer driverId, String driverName,
                          Integer vehicleId, String vehicleRegNumber, Date scheduleDate,
                          String scheduleTime, String tripStatus) {
        this.id = id;
        this.bookingId = bookingId;
        this.bookingReference = bookingReference;
        this.packageType = packageType;
        this.guideId = guideId;
        this.guideName = guideName;
        this.driverId = driverId;
        this.driverName = driverName;
        this.vehicleId = vehicleId;
        this.vehicleRegNumber = vehicleRegNumber;
        this.scheduleDate = scheduleDate;
        this.scheduleTime = scheduleTime;
        this.tripStatus = tripStatus;
    }

    private String guideAvailability;
    private String guideEmployment;
    private String driverAvailability;
    private String driverEmployment;
    private String vehicleAvailability;
    private String vehicleMaintenance;

    public String getGuideAvailability() { return guideAvailability; }
    public void setGuideAvailability(String guideAvailability) { this.guideAvailability = guideAvailability; }

    public String getGuideEmployment() { return guideEmployment; }
    public void setGuideEmployment(String guideEmployment) { this.guideEmployment = guideEmployment; }

    public String getDriverAvailability() { return driverAvailability; }
    public void setDriverAvailability(String driverAvailability) { this.driverAvailability = driverAvailability; }

    public String getDriverEmployment() { return driverEmployment; }
    public void setDriverEmployment(String driverEmployment) { this.driverEmployment = driverEmployment; }

    public String getVehicleAvailability() { return vehicleAvailability; }
    public void setVehicleAvailability(String vehicleAvailability) { this.vehicleAvailability = vehicleAvailability; }

    public String getVehicleMaintenance() { return vehicleMaintenance; }
    public void setVehicleMaintenance(String vehicleMaintenance) { this.vehicleMaintenance = vehicleMaintenance; }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public String getBookingReference() { return bookingReference; }
    public void setBookingReference(String bookingReference) { this.bookingReference = bookingReference; }

    public String getPackageType() { return packageType; }
    public void setPackageType(String packageType) { this.packageType = packageType; }

    public Integer getGuideId() { return guideId; }
    public void setGuideId(Integer guideId) { this.guideId = guideId; }

    public String getGuideName() { return guideName; }
    public void setGuideName(String guideName) { this.guideName = guideName; }

    public Integer getDriverId() { return driverId; }
    public void setDriverId(Integer driverId) { this.driverId = driverId; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public Integer getVehicleId() { return vehicleId; }
    public void setVehicleId(Integer vehicleId) { this.vehicleId = vehicleId; }

    public String getVehicleRegNumber() { return vehicleRegNumber; }
    public void setVehicleRegNumber(String vehicleRegNumber) { this.vehicleRegNumber = vehicleRegNumber; }

    public Date getScheduleDate() { return scheduleDate; }
    public void setScheduleDate(Date scheduleDate) { this.scheduleDate = scheduleDate; }

    public String getScheduleTime() { return scheduleTime; }
    public void setScheduleTime(String scheduleTime) { this.scheduleTime = scheduleTime; }

    public String getTripStatus() { return tripStatus; }
    public void setTripStatus(String tripStatus) { this.tripStatus = tripStatus; }
}