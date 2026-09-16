package com.wildlifesafari.model;

public class Guide {

    private int id;
    private int userId;
    private String guideName;
    private String qualifications;
    private String specialization;
    private int experienceYears;
    private String employmentStatus;
    private String availabilityStatus;

    public Guide() {}

    public Guide(int id, int userId, String guideName, String qualifications, String specialization,
                 int experienceYears, String employmentStatus, String availabilityStatus) {
        this.id = id;
        this.userId = userId;
        this.guideName = guideName;
        this.qualifications = qualifications;
        this.specialization = specialization;
        this.experienceYears = experienceYears;
        this.employmentStatus = employmentStatus;
        this.availabilityStatus = availabilityStatus;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getGuideName() { return guideName; }
    public void setGuideName(String guideName) { this.guideName = guideName; }

    public String getQualifications() { return qualifications; }
    public void setQualifications(String qualifications) { this.qualifications = qualifications; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public int getExperienceYears() { return experienceYears; }
    public void setExperienceYears(int experienceYears) { this.experienceYears = experienceYears; }

    public String getEmploymentStatus() { return employmentStatus; }
    public void setEmploymentStatus(String employmentStatus) { this.employmentStatus = employmentStatus; }

    public String getAvailabilityStatus() { return availabilityStatus; }
    public void setAvailabilityStatus(String availabilityStatus) { this.availabilityStatus = availabilityStatus; }
}