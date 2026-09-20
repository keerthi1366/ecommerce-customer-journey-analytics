-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 04: Funnel Drop-off & Stage-by-Stage Conversion Analysis
-- Engine: MySQL 8.0+
-- Description: Measures sequential funnel progression, stage-to-stage drop-off,
--              cart abandonment, checkout abandonment, and device/traffic splits.
-- =============================================================================

USE ecommerce_analytics;

-- -----------------------------------------------------------------------------
-- Query 4.1: Overall Macro Funnel Progression (Session-Level)
-- Tracks the 7 core steps of the customer journey
-- -----------------------------------------------------------------------------
WITH stage_flags AS (
    SELECT 
        s.session_id,
        1 AS step_1_visit,
        MAX(CASE WHEN fe.event_name = 'browse_search' THEN 1 ELSE 0 END) AS step_2_browse,
        MAX(CASE WHEN fe.event_name = 'product_view' THEN 1 ELSE 0 END) AS step_3_view,
        MAX(CASE WHEN fe.event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS step_4_cart,
        MAX(CASE WHEN fe.event_name = 'checkout_initiated' THEN 1 ELSE 0 END) AS step_5_checkout,
        MAX(CASE WHEN fe.event_name = 'payment_attempted' THEN 1 ELSE 0 END) AS step_6_payment,
        MAX(CASE WHEN fe.event_name = 'purchase_completed' THEN 1 ELSE 0 END) AS step_7_purchase
    FROM web_sessions s
    LEFT JOIN funnel_events fe ON s.session_id = fe.session_id
    GROUP BY s.session_id
),
funnel_counts AS (
    SELECT 
        SUM(step_1_visit) AS total_visits,
        SUM(step_2_browse) AS total_browsed,
        SUM(step_3_view) AS total_product_views,
        SUM(step_4_cart) AS total_added_to_cart,
        SUM(step_5_checkout) AS total_checkout_initiated,
        SUM(step_6_payment) AS total_payment_attempted,
        SUM(step_7_purchase) AS total_purchased
    FROM stage_flags
)
SELECT 
    '1. Session Visit' AS funnel_stage,
    total_visits AS session_count,
    100.00 AS pct_of_initial_visits,
    0.00 AS stage_dropoff_pct
FROM funnel_counts

UNION ALL

SELECT 
    '2. Browse / Search' AS funnel_stage,
    total_browsed AS session_count,
    ROUND((total_browsed * 100.0) / total_visits, 2) AS pct_of_initial_visits,
    ROUND(((total_visits - total_browsed) * 100.0) / total_visits, 2) AS stage_dropoff_pct
FROM funnel_counts

UNION ALL

SELECT 
    '3. Product View' AS funnel_stage,
    total_product_views AS session_count,
    ROUND((total_product_views * 100.0) / total_visits, 2) AS pct_of_initial_visits,
    ROUND(((total_browsed - total_product_views) * 100.0) / total_browsed, 2) AS stage_dropoff_pct
FROM funnel_counts

UNION ALL

SELECT 
    '4. Add to Cart' AS funnel_stage,
    total_added_to_cart AS session_count,
    ROUND((total_added_to_cart * 100.0) / total_visits, 2) AS pct_of_initial_visits,
    ROUND(((total_product_views - total_added_to_cart) * 100.0) / total_product_views, 2) AS stage_dropoff_pct
FROM funnel_counts

UNION ALL

SELECT 
    '5. Checkout Initiated' AS funnel_stage,
    total_checkout_initiated AS session_count,
    ROUND((total_checkout_initiated * 100.0) / total_visits, 2) AS pct_of_initial_visits,
    ROUND(((total_added_to_cart - total_checkout_initiated) * 100.0) / total_added_to_cart, 2) AS stage_dropoff_pct
FROM funnel_counts

UNION ALL

SELECT 
    '6. Payment Attempted' AS funnel_stage,
    total_payment_attempted AS session_count,
    ROUND((total_payment_attempted * 100.0) / total_visits, 2) AS pct_of_initial_visits,
    ROUND(((total_checkout_initiated - total_payment_attempted) * 100.0) / total_checkout_initiated, 2) AS stage_dropoff_pct
FROM funnel_counts

UNION ALL

SELECT 
    '7. Purchase Completed' AS funnel_stage,
    total_purchased AS session_count,
    ROUND((total_purchased * 100.0) / total_visits, 2) AS pct_of_initial_visits,
    ROUND(((total_payment_attempted - total_purchased) * 100.0) / total_payment_attempted, 2) AS stage_dropoff_pct
FROM funnel_counts;

-- -----------------------------------------------------------------------------
-- Query 4.2: Cart & Checkout Abandonment Rates
-- Industry-standard benchmark calculations
-- -----------------------------------------------------------------------------
WITH session_milestones AS (
    SELECT 
        s.session_id,
        MAX(CASE WHEN fe.event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN fe.event_name = 'checkout_initiated' THEN 1 ELSE 0 END) AS reached_checkout,
        MAX(CASE WHEN fe.event_name = 'purchase_completed' THEN 1 ELSE 0 END) AS completed_purchase
    FROM web_sessions s
    LEFT JOIN funnel_events fe ON s.session_id = fe.session_id
    GROUP BY s.session_id
)
SELECT 
    SUM(added_to_cart) AS total_cart_sessions,
    SUM(CASE WHEN added_to_cart = 1 AND completed_purchase = 0 THEN 1 ELSE 0 END) AS abandoned_cart_sessions,
    ROUND(
        (SUM(CASE WHEN added_to_cart = 1 AND completed_purchase = 0 THEN 1 ELSE 0 END) * 100.0) 
        / NULLIF(SUM(added_to_cart), 0), 
        2
    ) AS cart_abandonment_rate_pct,
    
    SUM(reached_checkout) AS total_checkout_sessions,
    SUM(CASE WHEN reached_checkout = 1 AND completed_purchase = 0 THEN 1 ELSE 0 END) AS abandoned_checkout_sessions,
    ROUND(
        (SUM(CASE WHEN reached_checkout = 1 AND completed_purchase = 0 THEN 1 ELSE 0 END) * 100.0) 
        / NULLIF(SUM(reached_checkout), 0), 
        2
    ) AS checkout_abandonment_rate_pct
FROM session_milestones;

-- -----------------------------------------------------------------------------
-- Query 4.3: Stage Conversion & Drop-off by Device Type
-- -----------------------------------------------------------------------------
WITH device_funnel AS (
    SELECT 
        s.device_type,
        COUNT(DISTINCT s.session_id) AS total_sessions,
        COUNT(DISTINCT CASE WHEN fe.event_name = 'add_to_cart' THEN s.session_id END) AS cart_sessions,
        COUNT(DISTINCT CASE WHEN fe.event_name = 'checkout_initiated' THEN s.session_id END) AS checkout_sessions,
        COUNT(DISTINCT CASE WHEN fe.event_name = 'purchase_completed' THEN s.session_id END) AS purchase_sessions
    FROM web_sessions s
    LEFT JOIN funnel_events fe ON s.session_id = fe.session_id
    GROUP BY s.device_type
)
SELECT 
    device_type,
    total_sessions,
    cart_sessions,
    checkout_sessions,
    purchase_sessions,
    ROUND((cart_sessions * 100.0) / total_sessions, 2) AS visit_to_cart_rate_pct,
    ROUND(((cart_sessions - checkout_sessions) * 100.0) / NULLIF(cart_sessions, 0), 2) AS cart_abandonment_rate_pct,
    ROUND(((checkout_sessions - purchase_sessions) * 100.0) / NULLIF(checkout_sessions, 0), 2) AS checkout_abandonment_rate_pct,
    ROUND((purchase_sessions * 100.0) / total_sessions, 2) AS overall_conversion_rate_pct
FROM device_funnel
ORDER BY overall_conversion_rate_pct DESC;

-- -----------------------------------------------------------------------------
-- Query 4.4: Stage Conversion by Acquisition Channel (Traffic Source)
-- -----------------------------------------------------------------------------
WITH source_funnel AS (
    SELECT 
        s.traffic_source,
        COUNT(DISTINCT s.session_id) AS total_sessions,
        COUNT(DISTINCT CASE WHEN fe.event_name = 'add_to_cart' THEN s.session_id END) AS cart_sessions,
        COUNT(DISTINCT CASE WHEN fe.event_name = 'checkout_initiated' THEN s.session_id END) AS checkout_sessions,
        COUNT(DISTINCT CASE WHEN fe.event_name = 'purchase_completed' THEN s.session_id END) AS purchase_sessions
    FROM web_sessions s
    LEFT JOIN funnel_events fe ON s.session_id = fe.session_id
    GROUP BY s.traffic_source
)
SELECT 
    traffic_source,
    total_sessions,
    cart_sessions,
    purchase_sessions,
    ROUND((cart_sessions * 100.0) / total_sessions, 2) AS visit_to_cart_rate_pct,
    ROUND(((cart_sessions - checkout_sessions) * 100.0) / NULLIF(cart_sessions, 0), 2) AS cart_abandonment_pct,
    ROUND((purchase_sessions * 100.0) / total_sessions, 2) AS overall_conversion_rate_pct
FROM source_funnel
ORDER BY overall_conversion_rate_pct DESC;
