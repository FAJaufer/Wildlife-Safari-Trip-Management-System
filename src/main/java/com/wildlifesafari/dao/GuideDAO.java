package com.wildlifesafari.dao;

import com.wildlifesafari.model.Guide;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GuideDAO {

    public List<Guide> findAll() throws SQLException {
        List<Guide> guides = new ArrayList<>();
        String sql = "SELECT g.*, u.name AS guide_name FROM guides g " +
                "LEFT JOIN users u ON g.user_id = u.id ORDER BY g.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                guides.add(mapRow(rs));
            }
        }
        return guides;
    }

    public List<Guide> findAvailable() throws SQLException {
        List<Guide> guides = new ArrayList<>();
        String sql = "SELECT g.*, u.name AS guide_name FROM guides g " +
                "LEFT JOIN users u ON g.user_id = u.id " +
                "WHERE g.availability_status = 'available' AND g.employment_status = 'active' " +
                "ORDER BY g.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                guides.add(mapRow(rs));
            }
        }
        return guides;
    }

    public Guide findById(int id) throws SQLException {
        String sql = "SELECT g.*, u.name AS guide_name FROM guides g " +
                "LEFT JOIN users u ON g.user_id = u.id WHERE g.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public void create(Guide g) throws SQLException {
        String sql = "INSERT INTO guides (user_id, qualifications, specialization, experience_years, employment_status, availability_status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, g.getUserId());
            stmt.setString(2, g.getQualifications());
            stmt.setString(3, g.getSpecialization());
            stmt.setInt(4, g.getExperienceYears());
            stmt.setString(5, g.getEmploymentStatus());
            stmt.setString(6, g.getAvailabilityStatus());
            stmt.executeUpdate();
        }
    }

    public void update(Guide g) throws SQLException {
        String sql = "UPDATE guides SET user_id=?, qualifications=?, specialization=?, experience_years=?, employment_status=?, availability_status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, g.getUserId());
            stmt.setString(2, g.getQualifications());
            stmt.setString(3, g.getSpecialization());
            stmt.setInt(4, g.getExperienceYears());
            stmt.setString(5, g.getEmploymentStatus());
            stmt.setString(6, g.getAvailabilityStatus());
            stmt.setInt(7, g.getId());
            stmt.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM guides WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    public Guide findByUserId(int userId) throws SQLException {
        String sql = "SELECT g.*, u.name AS guide_name FROM guides g " +
                "LEFT JOIN users u ON g.user_id = u.id WHERE g.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    private Guide mapRow(ResultSet rs) throws SQLException {
        return new Guide(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("guide_name"),
                rs.getString("qualifications"),
                rs.getString("specialization"),
                rs.getInt("experience_years"),
                rs.getString("employment_status"),
                rs.getString("availability_status")
        );
    }
}