package com.wildlifesafari.model;

import java.sql.Timestamp;

public class EmergencyReport {

    private int id;
    private int reportedBy;
    private String reporterName;       // via JOIN, for display
    private Integer scheduleId;
    private String bookingReference;   // via JOIN, for display
    private String incidentType;
    private String details;
    private String status;
    private Timestamp reportedAt;

    public EmergencyReport() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getReportedBy() { return reportedBy; }
    public void setReportedBy(int reportedBy) { this.reportedBy = reportedBy; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public String getBookingReference() { return bookingReference; }
    public void setBookingReference(String bookingReference) { this.bookingReference = bookingReference; }

    public String getIncidentType() { return incidentType; }
    public void setIncidentType(String incidentType) { this.incidentType = incidentType; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getReportedAt() { return reportedAt; }
    public void setReportedAt(Timestamp reportedAt) { this.reportedAt = reportedAt; }
}