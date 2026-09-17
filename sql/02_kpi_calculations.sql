-- ============================================================================
-- SHODWE HOSPITALITY REVENUE & BUSINESS INTELLIGENCE
-- SCRIPT 02: CORE HOSPITALITY KPIS & MEASURE CALCULATIONS
-- ============================================================================

USE shodwe_hospitality_db;

-- ----------------------------------------------------------------------------
-- 1. EXECUTIVE KPI SUMMARY SCORECARD
-- Computes primary health indicators for the entire chain
-- ----------------------------------------------------------------------------
WITH booking_metrics AS (
    SELECT 
        COUNT(booking_id) AS total_bookings,
        COUNT(CASE WHEN booking_status = 'Checked Out' THEN 1 END) AS successful_stays,
        COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) AS total_cancellations,
        COUNT(CASE WHEN booking_status = 'No show' THEN 1 END) AS total_no_shows,
        SUM(revenue_generated) AS gross_revenue_generated,
        SUM(revenue_realized) AS net_revenue_realized,
        AVG(ratings_given) AS avg_guest_rating
    FROM fact_bookings
),
capacity_metrics AS (
    SELECT 
        SUM(capacity) AS total_capacity_available,
        SUM(successful_bookings) AS total_aggregated_successful_bookings,
        COUNT(DISTINCT check_in_date) AS total_operational_days
    FROM fact_aggregated_bookings
)
SELECT 
    -- Volume KPIs
    b.total_bookings,
    b.successful_stays,
    b.total_cancellations,
    b.total_no_shows,
    c.total_capacity_available,
    
    -- Revenue KPIs (in Currency Units)
    ROUND(b.gross_revenue_generated, 2) AS total_revenue_generated,
    ROUND(b.net_revenue_realized, 2) AS total_revenue_realized,
    ROUND(b.gross_revenue_generated - b.net_revenue_realized, 2) AS revenue_loss_to_cancellations,
    
    -- Hospitality Operational KPIs
    ROUND((c.total_aggregated_successful_bookings / c.total_capacity_available) * 100, 2) AS occupancy_pct,
    ROUND((b.net_revenue_realized / b.successful_stays), 2) AS adr_average_daily_rate,
    ROUND((b.net_revenue_realized / c.total_capacity_available), 2) AS revpar_revenue_per_available_room,
    ROUND((b.net_revenue_realized / b.gross_revenue_generated) * 100, 2) AS realization_pct,
    ROUND((b.total_cancellations / b.total_bookings) * 100, 2) AS cancellation_pct,
    ROUND((b.total_no_shows / b.total_bookings) * 100, 2) AS no_show_pct,
    
    -- Room Night Velocity (DSRN & DURN)
    ROUND(c.total_capacity_available / c.total_operational_days, 1) AS dsrn_daily_sellable_room_nights,
    ROUND(b.successful_stays / c.total_operational_days, 1) AS durn_daily_utilized_room_nights,
    
    -- Quality Score
    ROUND(b.avg_guest_rating, 2) AS avg_customer_rating
FROM booking_metrics b
CROSS JOIN capacity_metrics c;

-- ----------------------------------------------------------------------------
-- 2. ADR & REVPAR VALIDATION CHECK
-- Verifies the fundamental hospitality equation: RevPAR = ADR * Occupancy %
-- ----------------------------------------------------------------------------
SELECT 
    ROUND((SUM(b.revenue_realized) / COUNT(CASE WHEN b.booking_status = 'Checked Out' THEN 1 END)), 2) AS calculated_adr,
    ROUND((SUM(a.successful_bookings) / SUM(a.capacity)) * 100, 2) AS calculated_occupancy_pct,
    ROUND((SUM(b.revenue_realized) / SUM(a.capacity)), 2) AS actual_revpar,
    ROUND(
        ((SUM(b.revenue_realized) / COUNT(CASE WHEN b.booking_status = 'Checked Out' THEN 1 END)) * 
        (SUM(a.successful_bookings) / SUM(a.capacity))), 
        2
    ) AS theoretical_revpar_check
FROM fact_bookings b
CROSS JOIN (
    SELECT SUM(capacity) AS capacity, SUM(successful_bookings) AS successful_bookings 
    FROM fact_aggregated_bookings
) a;
