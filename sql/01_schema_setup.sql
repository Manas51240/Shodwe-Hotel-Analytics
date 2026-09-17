-- ============================================================================
-- SHODWE HOSPITALITY REVENUE & BUSINESS INTELLIGENCE
-- SCRIPT 01: DATABASE SCHEMA AND STAR-SCHEMA DDL
-- Database Dialect: MySQL / PostgreSQL Compatible
-- ============================================================================

CREATE DATABASE IF NOT EXISTS shodwe_hospitality_db;
USE shodwe_hospitality_db;

-- ----------------------------------------------------------------------------
-- 1. DIMENSION TABLE: dim_date
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date (
    date DATE PRIMARY KEY,
    mmm_yy VARCHAR(10) NOT NULL,
    week_no VARCHAR(10) NOT NULL,
    day_type VARCHAR(15) NOT NULL -- 'Weekend' or 'Weekday'
);

-- ----------------------------------------------------------------------------
-- 2. DIMENSION TABLE: dim_hotels
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_hotels;
CREATE TABLE dim_hotels (
    property_id INT PRIMARY KEY,
    property_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'Luxury' or 'Business'
    city VARCHAR(50) NOT NULL       -- 'Bangalore', 'Mumbai', 'Delhi', 'Hyderabad'
);

-- ----------------------------------------------------------------------------
-- 3. DIMENSION TABLE: dim_rooms
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_rooms;
CREATE TABLE dim_rooms (
    room_id VARCHAR(10) PRIMARY KEY, -- 'RT1', 'RT2', 'RT3', 'RT4'
    room_class VARCHAR(50) NOT NULL  -- 'Standard', 'Elite', 'Premium', 'Presidential'
);

-- ----------------------------------------------------------------------------
-- 4. FACT TABLE: fact_aggregated_bookings
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS fact_aggregated_bookings;
CREATE TABLE fact_aggregated_bookings (
    property_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    room_category VARCHAR(10) NOT NULL,
    successful_bookings INT NOT NULL DEFAULT 0,
    capacity INT NOT NULL DEFAULT 0,
    PRIMARY KEY (property_id, check_in_date, room_category),
    FOREIGN KEY (property_id) REFERENCES dim_hotels(property_id),
    FOREIGN KEY (check_in_date) REFERENCES dim_date(date),
    FOREIGN KEY (room_category) REFERENCES dim_rooms(room_id)
);

-- ----------------------------------------------------------------------------
-- 5. FACT TABLE: fact_bookings
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS fact_bookings;
CREATE TABLE fact_bookings (
    booking_id VARCHAR(50) PRIMARY KEY,
    property_id INT NOT NULL,
    booking_date DATE NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    no_guests INT NOT NULL DEFAULT 1,
    room_category VARCHAR(10) NOT NULL,
    booking_platform VARCHAR(50) NOT NULL, -- 'MakeMyTrip', 'LogTrip', 'Direct Online', etc.
    ratings_given DECIMAL(3, 1) NULL,
    booking_status VARCHAR(30) NOT NULL,   -- 'Checked Out', 'Cancelled', 'No show'
    revenue_generated DECIMAL(12, 2) NOT NULL,
    revenue_realized DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (property_id) REFERENCES dim_hotels(property_id),
    FOREIGN KEY (check_in_date) REFERENCES dim_date(date),
    FOREIGN KEY (room_category) REFERENCES dim_rooms(room_id)
);

-- ----------------------------------------------------------------------------
-- Create Analytical Indexes for Query Acceleration
-- ----------------------------------------------------------------------------
CREATE INDEX idx_fb_property ON fact_bookings(property_id);
CREATE INDEX idx_fb_checkin ON fact_bookings(check_in_date);
CREATE INDEX idx_fb_status ON fact_bookings(booking_status);
CREATE INDEX idx_fb_platform ON fact_bookings(booking_platform);
CREATE INDEX idx_fb_category ON fact_bookings(room_category);
