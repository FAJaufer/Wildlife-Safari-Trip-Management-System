package com.wildlifesafari.dao;

import com.wildlifesafari.model.SafariSchedule;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SafariScheduleDAO {

    private static final String SELECT_BASE =
            "SELECT s.*, b.booking_reference, p.safari_type, " +
                    "gu.name AS guide_name, du.name AS driver_name, v.registration_number " +
                    "FROM safari_schedules s " +
                    "JOIN bookings b ON s.booking_id = b.id " +
                    "JOIN safari_packages p ON b.package_id = p.id " +
                    "LEFT JOIN guides g ON s.guide_id = g.id " +
                    "LEFT JOIN users gu ON g.user_id = gu.id " +
                    "LEFT JOIN drivers d ON s.driver_id = d.id " +
                    "LEFT JOIN users du ON d.user_id = du.id " +
                    "LEFT JOIN vehicles v ON s.vehicle_id = v.id ";

    public List<SafariSchedule> findAll() throws SQLException {
        List<SafariSchedule> schedules = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY s.schedule_date DESC, s.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                schedules.add(mapRow(rs));
            }
        }
        return schedules;
    }

    /**
     * Checks whether the given guide, driver, or vehicle is already assigned
     * to another ACTIVE schedule (not cancelled) on the same date.
     * Returns a human-readable conflict message, or null if no conflict.
     */
    public String checkConflict(Integer guideId, Integer driverId, Integer vehicleId, Date scheduleDate) throws SQLException {
        String sql = "SELECT s.id, s.guide_id, s.driver_id, s.vehicle_id, gu.name AS guide_name, du.name AS driver_name, v.registration_number " +
                "FROM safari_schedules s " +
                "LEFT JOIN guides g ON s.guide_id = g.id LEFT JOIN users gu ON g.user_id = gu.id " +
                "LEFT JOIN drivers d ON s.driver_id = d.id LEFT JOIN users du ON d.user_id = du.id " +
                "LEFT JOIN vehicles v ON s.vehicle_id = v.id " +
                "WHERE s.schedule_date = ? AND s.trip_status != 'cancelled' " +
                "AND (s.guide_id = ? OR s.driver_id = ? OR s.vehicle_id = ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setDate(1, scheduleDate);
            stmt.setObject(2, guideId);
            stmt.setObject(3, driverId);
            stmt.setObject(4, vehicleId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    if (guideId != null && guideId.equals(rs.getObject("guide_id"))) {
                        return "Guide " + rs.getString("guide_name") + " is already assigned to another trip on this date.";
                    }
                    if (driverId != null && driverId.equals(rs.getObject("driver_id"))) {
                        return "Driver " + rs.getString("driver_name") + " is already assigned to another trip on this date.";
                    }
                    if (vehicleId != null && vehicleId.equals(rs.getObject("vehicle_id"))) {
                        return "Vehicle " + rs.getString("registration_number") + " is already assigned to another trip on this date.";
                    }
                }
            }
        }
        return null;
    }

    public void create(SafariSchedule s) throws SQLException {
        String sql = "INSERT INTO safari_schedules (booking_id, guide_id, driver_id, vehicle_id, schedule_date, schedule_time, trip_status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, s.getBookingId());
            stmt.setObject(2, s.getGuideId());
            stmt.setObject(3, s.getDriverId());
            stmt.setObject(4, s.getVehicleId());
            stmt.setDate(5, s.getScheduleDate());
            stmt.setString(6, s.getScheduleTime());
            stmt.setString(7, s.getTripStatus());
            stmt.executeUpdate();
        }
    }

    public List<SafariSchedule> findByGuideId(int guideId) throws SQLException {
        List<SafariSchedule> schedules = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE s.guide_id = ? AND s.trip_status = 'scheduled' ORDER BY s.schedule_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, guideId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    schedules.add(mapRow(rs));
                }
            }
        }
        return schedules;
    }

    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE safari_schedules SET trip_status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM safari_schedules WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    public List<SafariSchedule> findByDriverId(int driverId) throws SQLException {
        List<SafariSchedule> schedules = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE s.driver_id = ? AND s.trip_status = 'scheduled' ORDER BY s.schedule_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, driverId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    schedules.add(mapRow(rs));
                }
            }
        }
        return schedules;
    }

    public boolean isSlotAvailable(java.sql.Date date, String timeSlot) throws SQLException {
        int availableGuides = countAvailable(
                "SELECT COUNT(*) FROM guides WHERE employment_status = 'active'",
                date, timeSlot, "guide_id"
        );
        int availableDrivers = countAvailable(
                "SELECT COUNT(*) FROM drivers WHERE employment_status = 'active'",
                date, timeSlot, "driver_id"
        );
        int availableVehicles = countAvailable(
                "SELECT COUNT(*) FROM vehicles WHERE maintenance_status = 'active'",
                date, timeSlot, "vehicle_id"
        );

        return availableGuides > 0 && availableDrivers > 0 && availableVehicles > 0;
    }

    private int countAvailable(String totalCountSql, java.sql.Date date, String timeSlot, String resourceColumn) throws SQLException {
        int total = 0;
        int busy = 0;

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement stmt = conn.prepareStatement(totalCountSql);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }

            String busySql = "SELECT COUNT(DISTINCT " + resourceColumn + ") FROM safari_schedules " +
                    "WHERE schedule_date = ? AND schedule_time = ? " +
                    "AND trip_status != 'cancelled' AND " + resourceColumn + " IS NOT NULL";

            try (PreparedStatement stmt = conn.prepareStatement(busySql)) {
                stmt.setDate(1, date);
                stmt.setString(2, timeSlot);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        busy = rs.getInt(1);
                    }
                }
            }
        }

        return total - busy;
    }

    private SafariSchedule mapRow(ResultSet rs) throws SQLException {
        SafariSchedule s = new SafariSchedule();
        s.setId(rs.getInt("id"));
        s.setBookingId(rs.getInt("booking_id"));
        s.setBookingReference(rs.getString("booking_reference"));
        s.setPackageType(rs.getString("safari_type"));
        s.setGuideId((Integer) rs.getObject("guide_id"));
        s.setGuideName(rs.getString("guide_name"));
        s.setDriverId((Integer) rs.getObject("driver_id"));
        s.setDriverName(rs.getString("driver_name"));
        s.setVehicleId((Integer) rs.getObject("vehicle_id"));
        s.setVehicleRegNumber(rs.getString("registration_number"));
        s.setScheduleDate(rs.getDate("schedule_date"));
        s.setScheduleTime(rs.getString("schedule_time"));
        s.setTripStatus(rs.getString("trip_status"));
        return s;
    }
}