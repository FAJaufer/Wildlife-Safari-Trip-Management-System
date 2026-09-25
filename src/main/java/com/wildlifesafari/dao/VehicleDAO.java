package com.wildlifesafari.dao;

import com.wildlifesafari.model.Vehicle;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VehicleDAO {

    public List<Vehicle> findAll() throws SQLException {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = "SELECT * FROM vehicles ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                vehicles.add(mapRow(rs));
            }
        }
        return vehicles;
    }

    public List<Vehicle> findAvailable() throws SQLException {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = "SELECT * FROM vehicles WHERE availability_status = 'available' AND maintenance_status = 'active' ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                vehicles.add(mapRow(rs));
            }
        }
        return vehicles;
    }

    public Vehicle findById(int id) throws SQLException {
        String sql = "SELECT * FROM vehicles WHERE id = ?";
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

    public void create(Vehicle v) throws SQLException {
        String sql = "INSERT INTO vehicles (registration_number, vehicle_type, insurance_expiry, maintenance_status, availability_status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, v.getRegistrationNumber());
            stmt.setString(2, v.getVehicleType());
            stmt.setDate(3, v.getInsuranceExpiry());
            stmt.setString(4, v.getMaintenanceStatus());
            stmt.setString(5, v.getAvailabilityStatus());
            stmt.executeUpdate();
        }
    }

    public void update(Vehicle v) throws SQLException {
        String sql = "UPDATE vehicles SET registration_number=?, vehicle_type=?, insurance_expiry=?, maintenance_status=?, availability_status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, v.getRegistrationNumber());
            stmt.setString(2, v.getVehicleType());
            stmt.setDate(3, v.getInsuranceExpiry());
            stmt.setString(4, v.getMaintenanceStatus());
            stmt.setString(5, v.getAvailabilityStatus());
            stmt.setInt(6, v.getId());
            stmt.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM vehicles WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    private Vehicle mapRow(ResultSet rs) throws SQLException {
        return new Vehicle(
                rs.getInt("id"),
                rs.getString("registration_number"),
                rs.getString("vehicle_type"),
                rs.getDate("insurance_expiry"),
                rs.getString("maintenance_status"),
                rs.getString("availability_status")
        );
    }
}