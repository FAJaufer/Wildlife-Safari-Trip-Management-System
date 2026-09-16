package com.wildlifesafari.dao;

import com.wildlifesafari.model.SafariPackage;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SafariPackageDAO {

    public List<SafariPackage> findAll() throws SQLException {
        List<SafariPackage> packages = new ArrayList<>();
        String sql = "SELECT * FROM safari_packages ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                packages.add(mapRow(rs));
            }
        }
        return packages;
    }

    public SafariPackage findById(int id) throws SQLException {
        String sql = "SELECT * FROM safari_packages WHERE id = ?";
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

    public void create(SafariPackage pkg) throws SQLException {
        String sql = "INSERT INTO safari_packages (safari_type, destination, duration, price, description, availability_status, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, pkg.getSafariType());
            stmt.setString(2, pkg.getDestination());
            stmt.setString(3, pkg.getDuration());
            stmt.setBigDecimal(4, pkg.getPrice());
            stmt.setString(5, pkg.getDescription());
            stmt.setString(6, pkg.getAvailabilityStatus());
            stmt.setInt(7, pkg.getCreatedBy());
            stmt.executeUpdate();
        }
    }

    public void update(SafariPackage pkg) throws SQLException {
        String sql = "UPDATE safari_packages SET safari_type=?, destination=?, duration=?, price=?, description=?, availability_status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, pkg.getSafariType());
            stmt.setString(2, pkg.getDestination());
            stmt.setString(3, pkg.getDuration());
            stmt.setBigDecimal(4, pkg.getPrice());
            stmt.setString(5, pkg.getDescription());
            stmt.setString(6, pkg.getAvailabilityStatus());
            stmt.setInt(7, pkg.getId());
            stmt.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM safari_packages WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    private SafariPackage mapRow(ResultSet rs) throws SQLException {
        return new SafariPackage(
                rs.getInt("id"),
                rs.getString("safari_type"),
                rs.getString("destination"),
                rs.getString("duration"),
                rs.getBigDecimal("price"),
                rs.getString("description"),
                rs.getString("availability_status"),
                rs.getInt("created_by")
        );
    }
}