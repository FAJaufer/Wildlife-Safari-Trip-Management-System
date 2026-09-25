package com.wildlifesafari.dao;

import com.wildlifesafari.model.Payment;
import com.wildlifesafari.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {

    private static final String SELECT_BASE =
            "SELECT pay.*, b.booking_reference FROM payments pay " +
                    "JOIN bookings b ON pay.booking_id = b.id ";

    public List<Payment> findAll() throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY pay.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                payments.add(mapRow(rs));
            }
        }
        return payments;
    }

    public Payment findByBookingId(int bookingId) throws SQLException {
        String sql = SELECT_BASE + "WHERE pay.booking_id = ?";
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

    public java.util.Set<Integer> findPaidBookingIds(int userId) throws SQLException {
        java.util.Set<Integer> paidIds = new java.util.HashSet<>();
        String sql = "SELECT pay.booking_id FROM payments pay " +
                "JOIN bookings b ON pay.booking_id = b.id " +
                "WHERE b.user_id = ? AND pay.status = 'success'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    paidIds.add(rs.getInt("booking_id"));
                }
            }
        }
        return paidIds;
    }

    public void create(Payment p) throws SQLException {
        String sql = "INSERT INTO payments (booking_id, amount, payment_method, status) VALUES (?, ?, ?, 'success')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, p.getBookingId());
            stmt.setBigDecimal(2, p.getAmount());
            stmt.setString(3, p.getPaymentMethod());
            stmt.executeUpdate();
        }
    }

    public BigDecimal getTotalRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) AS total FROM payments WHERE status = 'success'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                return rs.getBigDecimal("total");
            }
        }
        return BigDecimal.ZERO;
    }

    private Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setId(rs.getInt("id"));
        p.setBookingId(rs.getInt("booking_id"));
        p.setBookingReference(rs.getString("booking_reference"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setPaymentDate(rs.getTimestamp("payment_date"));
        p.setStatus(rs.getString("status"));
        return p;
    }
}