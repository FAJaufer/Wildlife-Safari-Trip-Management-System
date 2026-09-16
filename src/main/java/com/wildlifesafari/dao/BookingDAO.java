package com.wildlifesafari.dao;

import com.wildlifesafari.model.Booking;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class BookingDAO {

    public List<Booking> findAll() throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.*, p.safari_type, p.destination FROM bookings b " +
                "JOIN safari_packages p ON b.package_id = p.id ORDER BY b.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                bookings.add(mapRow(rs));
            }
        }
        return bookings;
    }

    public List<Booking> findByUserId(int userId) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.*, p.safari_type, p.destination FROM bookings b " +
                "JOIN safari_packages p ON b.package_id = p.id " +
                "WHERE b.user_id = ? ORDER BY b.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapRow(rs));
                }
            }
        }
        return bookings;
    }

    public Booking findById(int id) throws SQLException {
        String sql = "SELECT b.*, p.safari_type, p.destination FROM bookings b " +
                "JOIN safari_packages p ON b.package_id = p.id WHERE b.id = ?";
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

    public List<Booking> findUnscheduledBookings() throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.*, p.safari_type, p.destination FROM bookings b " +
                "JOIN safari_packages p ON b.package_id = p.id " +
                "WHERE b.status = 'confirmed' " +
                "AND b.id NOT IN (SELECT booking_id FROM safari_schedules) " +
                "ORDER BY b.safari_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                bookings.add(mapRow(rs));
            }
        }
        return bookings;
    }

    public int create(Booking b) throws SQLException {
        String sql = "INSERT INTO bookings (user_id, package_id, safari_date, time_slot, participants, total_cost, status, booking_reference) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            String reference = "BK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

            stmt.setInt(1, b.getUserId());
            stmt.setInt(2, b.getPackageId());
            stmt.setDate(3, b.getSafariDate());
            stmt.setString(4, b.getTimeSlot());
            stmt.setInt(5, b.getParticipants());
            stmt.setBigDecimal(6, b.getTotalCost());
            stmt.setString(7, b.getStatus());
            stmt.setString(8, reference);
            stmt.executeUpdate();

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return 0;
    }

    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE bookings SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        }
    }

    private Booking mapRow(ResultSet rs) throws SQLException {
        return new Booking(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getInt("package_id"),
                rs.getString("safari_type"),
                rs.getString("destination"),
                rs.getDate("safari_date"),
                rs.getString("time_slot"),
                rs.getInt("participants"),
                rs.getBigDecimal("total_cost"),
                rs.getString("status"),
                rs.getString("booking_reference"),
                rs.getTimestamp("created_at")
        );
    }
}