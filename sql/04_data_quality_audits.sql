-- ============================================================================
-- SHODWE HOSPITALITY REVENUE & BUSINESS INTELLIGENCE
-- SCRIPT 04: DATA QUALITY & INTEGRITY AUDIT SUITE
-- ============================================================================

USE shodwe_hospitality_db;

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY UNIQUENESS AUDIT
-- Expectation: 0 duplicates
-- ----------------------------------------------------------------------------
SELECT 
    booking_id, 
    COUNT(*) AS occurrence_count
FROM fact_bookings
GROUP BY booking_id
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 2. REFERENTIAL INTEGRITY AUDIT (ORPHAN RECORDS)
-- Expectation: 0 orphan rows
-- ----------------------------------------------------------------------------
-- Orphan Hotels
SELECT COUNT(*) AS orphan_hotel_records
FROM fact_bookings b
LEFT JOIN dim_hotels h ON b.property_id = h.property_id
WHERE h.property_id IS NULL;

-- Orphan Rooms
SELECT COUNT(*) AS orphan_room_records
FROM fact_bookings b
LEFT JOIN dim_rooms r ON b.room_category = r.room_id
WHERE r.room_id IS NULL;

-- Orphan Dates
SELECT COUNT(*) AS orphan_date_records
FROM fact_bookings b
LEFT JOIN dim_date d ON b.check_in_date = d.date
WHERE d.date IS NULL;

-- ----------------------------------------------------------------------------
-- 3. CHRONOLOGICAL DATE LOGIC AUDIT
-- Rules:
-- 1. check_in_date must be >= booking_date
-- 2. check_out_date must be >= check_in_date
-- Expectation: 0 violations
-- ----------------------------------------------------------------------------
SELECT 
    booking_id,
    booking_date,
    check_in_date,
    check_out_date,
    CASE 
        WHEN check_in_date < booking_date THEN 'Check-in before booking'
        WHEN check_out_date < check_in_date THEN 'Check-out before check-in'
    END AS anomaly_reason
FROM fact_bookings
WHERE check_in_date < booking_date 
   OR check_out_date < check_in_date;

-- ----------------------------------------------------------------------------
-- 4. REVENUE REALIZATION BUSINESS RULE AUDIT
-- Business Rule:
-- - If booking_status = 'Cancelled': revenue_realized must equal 40% of revenue_generated
-- - If booking_status IN ('Checked Out', 'No show'): revenue_realized must equal 100% of revenue_generated
-- Expectation: 0 rule violations
-- ----------------------------------------------------------------------------
SELECT 
    booking_id,
    booking_status,
    revenue_generated,
    revenue_realized,
    CASE 
        WHEN booking_status = 'Cancelled' AND ROUND(revenue_realized, 0) != ROUND(revenue_generated * 0.40, 0) 
            THEN 'Invalid cancellation penalty (expected 40%)'
        WHEN booking_status IN ('Checked Out', 'No show') AND revenue_realized != revenue_generated 
            THEN 'Invalid realized revenue (expected 100%)'
    END AS rule_violation
FROM fact_bookings
WHERE (booking_status = 'Cancelled' AND ROUND(revenue_realized, 0) != ROUND(revenue_generated * 0.40, 0))
   OR (booking_status IN ('Checked Out', 'No show') AND revenue_realized != revenue_generated);

-- ----------------------------------------------------------------------------
-- 5. CAPACITY VS BOOKINGS AUDIT IN AGGREGATED TABLE
-- Rule: successful_bookings should never exceed available capacity
-- Expectation: 0 over-capacity records
-- ----------------------------------------------------------------------------
SELECT 
    property_id,
    check_in_date,
    room_category,
    successful_bookings,
    capacity,
    (successful_bookings - capacity) AS overbooking_count
FROM fact_aggregated_bookings
WHERE successful_bookings > capacity;
