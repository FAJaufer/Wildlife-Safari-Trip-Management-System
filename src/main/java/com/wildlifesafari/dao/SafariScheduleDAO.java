package com.wildlifesafari.dao;

import com.wildlifesafari.model.SafariSchedule;
import com.wildlifesafari.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SafariScheduleDAO {

    private static final String SELECT_BASE =
            "SELECT s.*, b.booking_reference, b.status AS booking_status, p.safari_type, " +
                    "gu.name AS guide_name, g.availability_status AS guide_availability, g.employment_status AS guide_employment, " +
                    "du.name AS driver_name, d.availability_status AS driver_availability, d.employment_status AS driver_employment, " +
                    "v.registration_number, v.availability_status AS vehicle_availability, v.maintenance_status AS vehicle_maintenance " +
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

    public SafariSchedule findById(int id) throws SQLException {
        String sql = SELECT_BASE + "WHERE s.id = ?";
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

    // ---------------------------------------------------------------
    // Conflict check (used when a manager assigns resources)
    // ---------------------------------------------------------------

    // Every slot name that clashes with the given slot.
    // Morning <-> Morning/Full Day, Afternoon <-> Afternoon/Full Day, Full Day <-> everything.
    private static List<String> conflictingSlots(String slot) {
        if ("Full Day".equals(slot)) {
            return java.util.Arrays.asList("Morning", "Afternoon", "Full Day");
        }
        if ("Morning".equals(slot) || "Afternoon".equals(slot)) {
            return java.util.Arrays.asList(slot, "Full Day");
        }
        return java.util.Collections.singletonList(slot);
    }

    public String checkConflict(Integer guideId, Integer driverId, Integer vehicleId,
                                Date scheduleDate, String scheduleTime) throws SQLException {
        return checkConflict(guideId, driverId, vehicleId, scheduleDate, scheduleTime, null);
    }

    public String checkConflict(Integer guideId, Integer driverId, Integer vehicleId,
                                Date scheduleDate, String scheduleTime, Integer excludeScheduleId) throws SQLException {
        List<String> slots = conflictingSlots(scheduleTime);

        String sql = "SELECT s.id, s.guide_id, s.driver_id, s.vehicle_id, gu.name AS guide_name, du.name AS driver_name, v.registration_number " +
                "FROM safari_schedules s " +
                "LEFT JOIN guides g ON s.guide_id = g.id LEFT JOIN users gu ON g.user_id = gu.id " +
                "LEFT JOIN drivers d ON s.driver_id = d.id LEFT JOIN users du ON d.user_id = du.id " +
                "LEFT JOIN vehicles v ON s.vehicle_id = v.id " +
                "WHERE s.schedule_date = ? AND s.trip_status != 'cancelled' " +
                "AND s.schedule_time IN (" + placeholders(slots.size()) + ") " +
                "AND (s.guide_id = ? OR s.driver_id = ? OR s.vehicle_id = ?)" +
                (excludeScheduleId != null ? " AND s.id != ?" : "");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            int i = 1;
            stmt.setDate(i++, scheduleDate);
            for (String slot : slots) {
                stmt.setString(i++, slot);
            }
            stmt.setObject(i++, guideId);
            stmt.setObject(i++, driverId);
            stmt.setObject(i++, vehicleId);
            if (excludeScheduleId != null) {
                stmt.setInt(i, excludeScheduleId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    if (guideId != null && guideId.equals(rs.getObject("guide_id"))) {
                        return "Guide " + rs.getString("guide_name") + " is already assigned to an overlapping trip on this date.";
                    }
                    if (driverId != null && driverId.equals(rs.getObject("driver_id"))) {
                        return "Driver " + rs.getString("driver_name") + " is already assigned to an overlapping trip on this date.";
                    }
                    if (vehicleId != null && vehicleId.equals(rs.getObject("vehicle_id"))) {
                        return "Vehicle " + rs.getString("registration_number") + " is already assigned to an overlapping trip on this date.";
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

    // ---------------------------------------------------------------
    // Availability check
    // ---------------------------------------------------------------

    // The halves of the day a slot occupies. Full Day uses both halves.
    private static List<String> halvesOf(String slot) {
        if ("Full Day".equals(slot)) {
            return java.util.Arrays.asList("Morning", "Afternoon");
        }
        return java.util.Collections.singletonList(slot);
    }

    // Every slot name that occupies a given half. Full Day covers both halves.
    private static List<String> slotsCovering(String half) {
        if ("Morning".equals(half) || "Afternoon".equals(half)) {
            return java.util.Arrays.asList(half, "Full Day");
        }
        return java.util.Collections.singletonList(half);
    }

    private static String placeholders(int n) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < n; i++) {
            sb.append(i == 0 ? "?" : ",?");
        }
        return sb.toString();
    }

    // A slot is bookable if EVERY half of the day it occupies still has a free
    // guide, driver and vehicle, after removing resources on active schedules
    // and bookings that are still waiting for a schedule.
    public boolean isSlotAvailable(java.sql.Date date, String timeSlot) throws SQLException {
        for (String half : halvesOf(timeSlot)) {
            int guides = countFree(
                    "SELECT COUNT(*) FROM guides r JOIN users u ON r.user_id = u.id " +
                            "WHERE r.employment_status = 'active' AND r.availability_status = 'available' AND u.role = 'guide'",
                    "guide_id", date, half);
            int drivers = countFree(
                    "SELECT COUNT(*) FROM drivers r JOIN users u ON r.user_id = u.id " +
                            "WHERE r.employment_status = 'active' AND r.availability_status = 'available' AND u.role = 'driver'",
                    "driver_id", date, half);
            int vehicles = countFree(
                    "SELECT COUNT(*) FROM vehicles r " +
                            "WHERE r.maintenance_status = 'active' AND r.availability_status = 'available'",
                    "vehicle_id", date, half);

            int capacity = Math.min(guides, Math.min(drivers, vehicles));
            int waiting = countUnscheduledBookings(date, half);

            if (capacity - waiting <= 0) {
                return false;
            }
        }
        return true;
    }

    // Eligible resources that are NOT on an active schedule covering this half of the day.
    private int countFree(String eligibleSql, String resourceColumn, java.sql.Date date, String half) throws SQLException {
        List<String> slots = slotsCovering(half);
        String sql = eligibleSql +
                " AND r.id NOT IN (SELECT " + resourceColumn + " FROM safari_schedules " +
                "WHERE schedule_date = ? AND schedule_time IN (" + placeholders(slots.size()) + ") " +
                "AND trip_status != 'cancelled' AND " + resourceColumn + " IS NOT NULL)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setDate(1, date);
            for (int i = 0; i < slots.size(); i++) {
                stmt.setString(2 + i, slots.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // Confirmed bookings covering this half of the day that have not been scheduled yet.
    private int countUnscheduledBookings(java.sql.Date date, String half) throws SQLException {
        List<String> slots = slotsCovering(half);
        String sql = "SELECT COUNT(*) FROM bookings " +
                "WHERE safari_date = ? AND time_slot IN (" + placeholders(slots.size()) + ") AND status = 'confirmed' " +
                "AND id NOT IN (SELECT booking_id FROM safari_schedules)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setDate(1, date);
            for (int i = 0; i < slots.size(); i++) {
                stmt.setString(2 + i, slots.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public void updateResources(int scheduleId, Integer guideId, Integer driverId, Integer vehicleId) throws SQLException {
        String sql = "UPDATE safari_schedules SET guide_id = ?, driver_id = ?, vehicle_id = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setObject(1, guideId);
            stmt.setObject(2, driverId);
            stmt.setObject(3, vehicleId);
            stmt.setInt(4, scheduleId);
            stmt.executeUpdate();
        }
    }

    public SafariSchedule findByBookingId(int bookingId) throws SQLException {
        String sql = SELECT_BASE + "WHERE s.booking_id = ?";
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

    public java.util.Set<Integer> findCompletedBookingIds(int userId) throws SQLException {
        java.util.Set<Integer> ids = new java.util.HashSet<>();
        String sql = "SELECT s.booking_id FROM safari_schedules s " +
                "JOIN bookings b ON s.booking_id = b.id " +
                "WHERE b.user_id = ? AND s.trip_status = 'completed'";

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
        s.setGuideAvailability(rs.getString("guide_availability"));
        s.setGuideEmployment(rs.getString("guide_employment"));
        s.setDriverAvailability(rs.getString("driver_availability"));
        s.setDriverEmployment(rs.getString("driver_employment"));
        s.setVehicleAvailability(rs.getString("vehicle_availability"));
        s.setVehicleMaintenance(rs.getString("vehicle_maintenance"));
        s.setBookingStatus(rs.getString("booking_status"));
        return s;
    }
}