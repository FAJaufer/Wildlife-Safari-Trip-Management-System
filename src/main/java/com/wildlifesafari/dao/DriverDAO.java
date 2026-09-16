package com.wildlifesafari.dao;

import com.wildlifesafari.model.Driver;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DriverDAO {

    public List<Driver> findAll() throws SQLException {
        List<Driver> drivers = new ArrayList<>();
        String sql = "SELECT d.*, u.name AS driver_name FROM drivers d " +
                "LEFT JOIN users u ON d.user_id = u.id ORDER BY d.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                drivers.add(mapRow(rs));
            }
        }
        return drivers;
    }

    public Driver findById(int id) throws SQLException {
        String sql = "SELECT d.*, u.name AS driver_name FROM drivers d " +
                "LEFT JOIN users u ON d.user_id = u.id WHERE d.id = ?";
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

    public void create(Driver d) throws SQLException {
        String sql = "INSERT INTO drivers (user_id, license_number, license_expiry, experience_years, employment_status, availability_status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, d.getUserId());
            stmt.setString(2, d.getLicenseNumber());
            stmt.setDate(3, d.getLicenseExpiry());
            stmt.setInt(4, d.getExperienceYears());
            stmt.setString(5, d.getEmploymentStatus());
            stmt.setString(6, d.getAvailabilityStatus());
            stmt.executeUpdate();
        }
    }

    public void update(Driver d) throws SQLException {
        String sql = "UPDATE drivers SET user_id=?, license_number=?, license_expiry=?, experience_years=?, employment_status=?, availability_status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, d.getUserId());
            stmt.setString(2, d.getLicenseNumber());
            stmt.setDate(3, d.getLicenseExpiry());
            stmt.setInt(4, d.getExperienceYears());
            stmt.setString(5, d.getEmploymentStatus());
            stmt.setString(6, d.getAvailabilityStatus());
            stmt.setInt(7, d.getId());
            stmt.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM drivers WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    public Driver findByUserId(int userId) throws SQLException {
        String sql = "SELECT d.*, u.name AS driver_name FROM drivers d " +
                "LEFT JOIN users u ON d.user_id = u.id WHERE d.user_id = ?";
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

    private Driver mapRow(ResultSet rs) throws SQLException {
        return new Driver(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("driver_name"),
                rs.getString("license_number"),
                rs.getDate("license_expiry"),
                rs.getInt("experience_years"),
                rs.getString("employment_status"),
                rs.getString("availability_status")
        );
    }
}