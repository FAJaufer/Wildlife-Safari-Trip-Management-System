package com.wildlifesafari.dao;

import com.wildlifesafari.model.EmergencyReport;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmergencyReportDAO {

    private static final String SELECT_BASE =
            "SELECT er.*, u.name AS reporter_name, b.booking_reference FROM emergency_reports er " +
                    "LEFT JOIN users u ON er.reported_by = u.id " +
                    "LEFT JOIN safari_schedules s ON er.schedule_id = s.id " +
                    "LEFT JOIN bookings b ON s.booking_id = b.id ";

    public List<EmergencyReport> findAll() throws SQLException {
        List<EmergencyReport> reports = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY er.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                reports.add(mapRow(rs));
            }
        }
        return reports;
    }

    public void create(EmergencyReport r) throws SQLException {
        String sql = "INSERT INTO emergency_reports (reported_by, schedule_id, incident_type, details, status) VALUES (?, ?, ?, ?, 'reported')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, r.getReportedBy());
            stmt.setObject(2, r.getScheduleId());
            stmt.setString(3, r.getIncidentType());
            stmt.setString(4, r.getDetails());
            stmt.executeUpdate();
        }
    }

    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE emergency_reports SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        }
    }

    private EmergencyReport mapRow(ResultSet rs) throws SQLException {
        EmergencyReport r = new EmergencyReport();
        r.setId(rs.getInt("id"));
        r.setReportedBy(rs.getInt("reported_by"));
        r.setReporterName(rs.getString("reporter_name"));
        r.setScheduleId((Integer) rs.getObject("schedule_id"));
        r.setBookingReference(rs.getString("booking_reference"));
        r.setIncidentType(rs.getString("incident_type"));
        r.setDetails(rs.getString("details"));
        r.setStatus(rs.getString("status"));
        r.setReportedAt(rs.getTimestamp("reported_at"));
        return r;
    }
}