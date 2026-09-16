package com.wildlifesafari.model;

import java.sql.Date;
import java.sql.Timestamp;

public class WildlifeSighting {

    private int id;
    private Integer scheduleId;
    private int guideId;
    private String guideName;   // via JOIN, for display
    private String species;
    private String location;
    private Date sightingDate;
    private String sightingTime;
    private String photoUrl;
    private Timestamp createdAt;

    public WildlifeSighting() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public int getGuideId() { return guideId; }
    public void setGuideId(int guideId) { this.guideId = guideId; }

    public String getGuideName() { return guideName; }
    public void setGuideName(String guideName) { this.guideName = guideName; }

    public String getSpecies() { return species; }
    public void setSpecies(String species) { this.species = species; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Date getSightingDate() { return sightingDate; }
    public void setSightingDate(Date sightingDate) { this.sightingDate = sightingDate; }

    public String getSightingTime() { return sightingTime; }
    public void setSightingTime(String sightingTime) { this.sightingTime = sightingTime; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}