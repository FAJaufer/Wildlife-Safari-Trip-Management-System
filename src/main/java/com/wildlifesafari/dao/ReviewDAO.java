package com.wildlifesafari.dao;

import com.wildlifesafari.model.Review;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    private static final String SELECT_BASE =
            "SELECT r.*, b.booking_reference, u.name AS user_name, p.safari_type FROM reviews r " +
                    "JOIN bookings b ON r.booking_id = b.id " +
                    "JOIN users u ON r.user_id = u.id " +
                    "JOIN safari_packages p ON r.package_id = p.id ";

    public List<Review> findByPackageId(int packageId) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE r.package_id = ? AND r.status = 'visible' ORDER BY r.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, packageId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reviews.add(mapRow(rs));
                }
            }
        }
        return reviews;
    }

    public List<Review> findAll() throws SQLException {
        List<Review> reviews = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY r.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                reviews.add(mapRow(rs));
            }
        }
        return reviews;
    }

    public Review findByBookingId(int bookingId) throws SQLException {
        String sql = SELECT_BASE + "WHERE r.booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public double getAverageRating(int packageId) throws SQLException {
        String sql = "SELECT AVG(rating) AS avg_rating FROM reviews WHERE package_id = ? AND status = 'visible'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, packageId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("avg_rating");
                }
            }
        }
        return 0.0;
    }

    public void create(Review r) throws SQLException {
        String sql = "INSERT INTO reviews (booking_id, user_id, package_id, rating, comment, photo_url) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, r.getBookingId());
            stmt.setInt(2, r.getUserId());
            stmt.setInt(3, r.getPackageId());
            stmt.setInt(4, r.getRating());
            stmt.setString(5, r.getComment());
            stmt.setString(6, r.getPhotoUrl());
            stmt.executeUpdate();
        }
    }

    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE reviews SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM reviews WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    public java.util.Set<Integer> findReviewedBookingIds(int userId) throws SQLException {
        java.util.Set<Integer> ids = new java.util.HashSet<>();
        String sql = "SELECT booking_id FROM reviews WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("booking_id"));
                }
            }
        }
        return ids;
    }

    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setId(rs.getInt("id"));
        r.setBookingId(rs.getInt("booking_id"));
        r.setBookingReference(rs.getString("booking_reference"));
        r.setUserId(rs.getInt("user_id"));
        r.setUserName(rs.getString("user_name"));
        r.setPackageId(rs.getInt("package_id"));
        r.setPackageType(rs.getString("safari_type"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setPhotoUrl(rs.getString("photo_url"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }
}