package com.wildlifesafari.dao;

import com.wildlifesafari.model.RefundRequest;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RefundRequestDAO {

    private static final String SELECT_BASE =
            "SELECT r.*, b.booking_reference, u.name AS user_name FROM refund_requests r " +
                    "JOIN bookings b ON r.booking_id = b.id " +
                    "JOIN users u ON r.user_id = u.id ";

    public List<RefundRequest> findAll() throws SQLException {
        List<RefundRequest> list = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY FIELD(r.status, 'pending', 'approved', 'rejected'), r.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public RefundRequest findById(int id) throws SQLException {
        String sql = SELECT_BASE + "WHERE r.id = ?";
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

    public RefundRequest findByBookingId(int bookingId) throws SQLException {
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

    // booking id -> refund status, for one user's bookings page
    public Map<Integer, String> findStatusesByUserId(int userId) throws SQLException {
        Map<Integer, String> map = new HashMap<>();
        String sql = "SELECT booking_id, status FROM refund_requests WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("booking_id"), rs.getString("status"));
                }
            }
        }
        return map;
    }

    public void create(RefundRequest r) throws SQLException {
        String sql = "INSERT INTO refund_requests (booking_id, user_id, amount, reason, status) VALUES (?, ?, ?, ?, 'pending')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, r.getBookingId());
            stmt.setInt(2, r.getUserId());
            stmt.setBigDecimal(3, r.getAmount());
            stmt.setString(4, r.getReason());
            stmt.executeUpdate();
        }
    }

    // Only a pending request can be reviewed. Returns rows changed (0 = already handled).
    public int review(int id, String status, String note, int reviewerId) throws SQLException {
        String sql = "UPDATE refund_requests SET status = ?, admin_note = ?, reviewed_by = ?, reviewed_at = NOW() " +
                "WHERE id = ? AND status = 'pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, note);
            stmt.setInt(3, reviewerId);
            stmt.setInt(4, id);
            return stmt.executeUpdate();
        }
    }

    private RefundRequest mapRow(ResultSet rs) throws SQLException {
        RefundRequest r = new RefundRequest();
        r.setId(rs.getInt("id"));
        r.setBookingId(rs.getInt("booking_id"));
        r.setBookingReference(rs.getString("booking_reference"));
        r.setUserId(rs.getInt("user_id"));
        r.setUserName(rs.getString("user_name"));
        r.setAmount(rs.getBigDecimal("amount"));
        r.setReason(rs.getString("reason"));
        r.setStatus(rs.getString("status"));
        r.setAdminNote(rs.getString("admin_note"));
        r.setReviewedBy((Integer) rs.getObject("reviewed_by"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setReviewedAt(rs.getTimestamp("reviewed_at"));
        return r;
    }
}