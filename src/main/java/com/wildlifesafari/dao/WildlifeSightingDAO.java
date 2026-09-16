package com.wildlifesafari.dao;

import com.wildlifesafari.model.WildlifeSighting;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WildlifeSightingDAO {

    private static final String SELECT_BASE =
            "SELECT ws.*, u.name AS guide_name FROM wildlife_sightings ws " +
                    "LEFT JOIN guides g ON ws.guide_id = g.id " +
                    "LEFT JOIN users u ON g.user_id = u.id ";

    public List<WildlifeSighting> findRecent(int limit) throws SQLException {
        List<WildlifeSighting> sightings = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY ws.sighting_date DESC, ws.id DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    sightings.add(mapRow(rs));
                }
            }
        }
        return sightings;
    }

    public List<WildlifeSighting> findByGuideId(int guideId) throws SQLException {
        List<WildlifeSighting> sightings = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE ws.guide_id = ? ORDER BY ws.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, guideId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    sightings.add(mapRow(rs));
                }
            }
        }
        return sightings;
    }

    public void create(WildlifeSighting s) throws SQLException {
        String sql = "INSERT INTO wildlife_sightings (schedule_id, guide_id, species, location, sighting_date, sighting_time, photo_url) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setObject(1, s.getScheduleId());
            stmt.setInt(2, s.getGuideId());
            stmt.setString(3, s.getSpecies());
            stmt.setString(4, s.getLocation());
            stmt.setDate(5, s.getSightingDate());
            stmt.setString(6, s.getSightingTime());
            stmt.setString(7, s.getPhotoUrl());
            stmt.executeUpdate();
        }
    }

    private WildlifeSighting mapRow(ResultSet rs) throws SQLException {
        WildlifeSighting s = new WildlifeSighting();
        s.setId(rs.getInt("id"));
        s.setScheduleId((Integer) rs.getObject("schedule_id"));
        s.setGuideId(rs.getInt("guide_id"));
        s.setGuideName(rs.getString("guide_name"));
        s.setSpecies(rs.getString("species"));
        s.setLocation(rs.getString("location"));
        s.setSightingDate(rs.getDate("sighting_date"));
        s.setSightingTime(rs.getString("sighting_time"));
        s.setPhotoUrl(rs.getString("photo_url"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }
}