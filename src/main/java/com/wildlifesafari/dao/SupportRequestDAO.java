package com.wildlifesafari.dao;

import com.wildlifesafari.model.SupportRequest;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SupportRequestDAO {

    private static final String SELECT_BASE =
            "SELECT sr.*, u.name AS user_name, b.booking_reference FROM support_requests sr " +
                    "LEFT JOIN users u ON sr.user_id = u.id " +
                    "LEFT JOIN bookings b ON sr.booking_id = b.id ";

    public List<SupportRequest> findAll() throws SQLException {
        List<SupportRequest> requests = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY sr.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                requests.add(mapRow(rs));
            }
        }
        return requests;
    }

    public List<SupportRequest> findByUserId(int userId) throws SQLException {
        List<SupportRequest> requests = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE sr.user_id = ? ORDER BY sr.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRow(rs));
                }
            }
        }
        return requests;
    }

    public void create(SupportRequest r) throws SQLException {
        String sql = "INSERT INTO support_requests (user_id, booking_id, request_type, details, status) VALUES (?, ?, ?, ?, 'open')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, r.getUserId());
            stmt.setObject(2, r.getBookingId());
            stmt.setString(3, r.getRequestType());
            stmt.setString(4, r.getDetails());
            stmt.executeUpdate();
        }
    }

    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE support_requests SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        }
    }

    private SupportRequest mapRow(ResultSet rs) throws SQLException {
        SupportRequest r = new SupportRequest();
        r.setId(rs.getInt("id"));
        r.setUserId(rs.getInt("user_id"));
        r.setUserName(rs.getString("user_name"));
        r.setBookingId((Integer) rs.getObject("booking_id"));
        r.setBookingReference(rs.getString("booking_reference"));
        r.setRequestType(rs.getString("request_type"));
        r.setDetails(rs.getString("details"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }
}