-- ============================================================================
-- SHODWE HOSPITALITY REVENUE & BUSINESS INTELLIGENCE
-- SCRIPT 03: BUSINESS STRATEGY & DEEP DIVE INSIGHTS
-- ============================================================================

USE shodwe_hospitality_db;

-- ----------------------------------------------------------------------------
-- 1. PROPERTY-LEVEL REVENUE & OPERATIONAL EFFICIENCY
-- Ranks each property by revenue, realization rate, and guest satisfaction
-- ----------------------------------------------------------------------------
SELECT 
    h.property_id,
    h.property_name,
    h.city,
    h.category,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(SUM(b.revenue_realized), 2) AS total_revenue_realized,
    ROUND((SUM(b.revenue_realized) / SUM(b.revenue_generated)) * 100, 2) AS realization_pct,
    ROUND((COUNT(CASE WHEN b.booking_status = 'Cancelled' THEN 1 END) / COUNT(b.booking_id)) * 100, 2) AS cancellation_pct,
    ROUND(AVG(b.ratings_given), 2) AS avg_guest_rating,
    DENSE_RANK() OVER (ORDER BY SUM(b.revenue_realized) DESC) AS revenue_rank
FROM dim_hotels h
JOIN fact_bookings b ON h.property_id = b.property_id
GROUP BY h.property_id, h.property_name, h.city, h.category
ORDER BY revenue_rank ASC;

-- ----------------------------------------------------------------------------
-- 2. CITY-WISE REVENUE & OCCUPANCY BENCHMARKS
-- Identifies top metropolitan market performance
-- ----------------------------------------------------------------------------
SELECT 
    h.city,
    COUNT(DISTINCT h.property_id) AS total_properties,
    ROUND(SUM(b.revenue_realized), 2) AS total_city_revenue,
    ROUND(
        (SUM(b.revenue_realized) / (SELECT SUM(revenue_realized) FROM fact_bookings)) * 100, 
        2
    ) AS revenue_contribution_pct,
    ROUND(AVG(b.ratings_given), 2) AS avg_city_rating,
    ROUND((COUNT(CASE WHEN b.booking_status = 'Cancelled' THEN 1 END) / COUNT(b.booking_id)) * 100, 2) AS city_cancellation_pct
FROM dim_hotels h
JOIN fact_bookings b ON h.property_id = b.property_id
GROUP BY h.city
ORDER BY total_city_revenue DESC;

-- ----------------------------------------------------------------------------
-- 3. BOOKING CHANNEL CONVERSION & CANCELLATION ANALYSIS
-- Evaluates OTA (Online Travel Agency) dependency vs Direct bookings
-- ----------------------------------------------------------------------------
SELECT 
    b.booking_platform,
    COUNT(b.booking_id) AS total_bookings_received,
    ROUND(SUM(b.revenue_realized), 2) AS realized_revenue,
    ROUND(
        (SUM(b.revenue_realized) / (SELECT SUM(revenue_realized) FROM fact_bookings)) * 100, 
        2
    ) AS platform_revenue_share_pct,
    ROUND((SUM(b.revenue_realized) / SUM(b.revenue_generated)) * 100, 2) AS platform_realization_pct,
    ROUND((COUNT(CASE WHEN b.booking_status = 'Cancelled' THEN 1 END) / COUNT(b.booking_id)) * 100, 2) AS cancellation_rate_pct,
    ROUND((COUNT(CASE WHEN b.booking_status = 'No show' THEN 1 END) / COUNT(b.booking_id)) * 100, 2) AS no_show_rate_pct
FROM fact_bookings b
GROUP BY b.booking_platform
ORDER BY realized_revenue DESC;

-- ----------------------------------------------------------------------------
-- 4. WEEKEND VS. WEEKDAY DEMAND & PRICING POWER
-- Analyzes dynamic pricing elasticity and capacity utilization
-- ----------------------------------------------------------------------------
SELECT 
    d.day_type,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(SUM(b.revenue_realized), 2) AS total_revenue,
    ROUND(
        SUM(b.revenue_realized) / COUNT(CASE WHEN b.booking_status = 'Checked Out' THEN 1 END), 
        2
    ) AS adr_by_day_type,
    ROUND((COUNT(CASE WHEN b.booking_status = 'Cancelled' THEN 1 END) / COUNT(b.booking_id)) * 100, 2) AS cancellation_pct
FROM fact_bookings b
JOIN dim_date d ON b.check_in_date = d.date
GROUP BY d.day_type;

-- ----------------------------------------------------------------------------
-- 5. ROOM CLASS CONTRIBUTION & YIELD ANALYSIS
-- Compares Standard, Elite, Premium, and Presidential room yields
-- ----------------------------------------------------------------------------
SELECT 
    r.room_class,
    r.room_id,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(SUM(b.revenue_realized), 2) AS total_revenue_realized,
    ROUND(
        (SUM(b.revenue_realized) / (SELECT SUM(revenue_realized) FROM fact_bookings)) * 100, 
        2
    ) AS revenue_share_pct,
    ROUND(
        SUM(b.revenue_realized) / COUNT(CASE WHEN b.booking_status = 'Checked Out' THEN 1 END), 
        2
    ) AS room_class_adr,
    ROUND(AVG(b.ratings_given), 2) AS avg_guest_rating
FROM dim_rooms r
JOIN fact_bookings b ON r.room_id = b.room_category
GROUP BY r.room_class, r.room_id
ORDER BY total_revenue_realized DESC;

-- ----------------------------------------------------------------------------
-- 6. MONTH-OVER-MONTH REVENUE TRAJECTORY
-- Tracks seasonal trend from May through July
-- ----------------------------------------------------------------------------
SELECT 
    d.mmm_yy AS month_year,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(SUM(b.revenue_realized), 2) AS monthly_revenue_realized,
    ROUND(
        SUM(b.revenue_realized) / COUNT(CASE WHEN b.booking_status = 'Checked Out' THEN 1 END), 
        2
    ) AS monthly_adr,
    ROUND((COUNT(CASE WHEN b.booking_status = 'Cancelled' THEN 1 END) / COUNT(b.booking_id)) * 100, 2) AS monthly_cancellation_pct
FROM fact_bookings b
JOIN dim_date d ON b.check_in_date = d.date
GROUP BY d.mmm_yy
ORDER BY MIN(d.date) ASC;
