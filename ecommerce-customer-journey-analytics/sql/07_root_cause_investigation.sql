-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 07: Root-Cause Investigation & Multi-Dimensional Friction Discovery
-- Engine: MySQL 8.0+
-- Description: Dissects conversion bottlenecks across Device x Channel, 
--              page load latency, payment gateway failure codes, and shipping fees.
-- =============================================================================

USE ecommerce_analytics;

-- -----------------------------------------------------------------------------
-- Query 7.1: Multi-Dimensional Cross-Tabulation
-- Segmenting Device x Traffic Source x User Status (New vs Returning)
-- -----------------------------------------------------------------------------
WITH user_history AS (
    SELECT 
        user_id,
        MIN(order_timestamp) AS first_order_date
    FROM orders
    GROUP BY user_id
),
session_facts AS (
    SELECT 
        s.session_id,
        s.device_type,
        s.traffic_source,
        CASE 
            WHEN s.user_id IS NULL THEN 'Guest / Anonymous'
            WHEN uh.first_order_date IS NULL THEN 'New Visitor'
            WHEN s.session_start > uh.first_order_date THEN 'Returning Customer'
            ELSE 'New Visitor'
        END AS user_status,
        MAX(CASE WHEN fe.event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS has_cart,
        MAX(CASE WHEN fe.event_name = 'checkout_initiated' THEN 1 ELSE 0 END) AS has_checkout,
        MAX(CASE WHEN fe.event_name = 'purchase_completed' THEN 1 ELSE 0 END) AS has_purchased
    FROM web_sessions s
    LEFT JOIN user_history uh ON s.user_id = uh.user_id
    LEFT JOIN funnel_events fe ON s.session_id = fe.session_id
    GROUP BY s.session_id, s.device_type, s.traffic_source, user_status
)
SELECT 
    device_type,
    traffic_source,
    user_status,
    COUNT(*) AS total_sessions,
    SUM(has_cart) AS cart_sessions,
    SUM(has_checkout) AS checkout_sessions,
    SUM(has_purchased) AS purchased_sessions,
    ROUND((SUM(has_cart) * 100.0) / COUNT(*), 2) AS visit_to_cart_rate_pct,
    ROUND(((SUM(has_cart) - SUM(has_checkout)) * 100.0) / NULLIF(SUM(has_cart), 0), 2) AS cart_abandonment_pct,
    ROUND(((SUM(has_checkout) - SUM(has_purchased)) * 100.0) / NULLIF(SUM(has_checkout), 0), 2) AS checkout_abandonment_pct,
    ROUND((SUM(has_purchased) * 100.0) / COUNT(*), 2) AS overall_conversion_rate_pct
FROM session_facts
GROUP BY device_type, traffic_source, user_status
HAVING COUNT(*) >= 50
ORDER BY overall_conversion_rate_pct ASC;

-- -----------------------------------------------------------------------------
-- Query 7.2: Page Load Latency Friction Analysis
-- Tests Hypothesis: Slower page load latency correlates with increased drop-off
-- -----------------------------------------------------------------------------
WITH event_latency AS (
    SELECT 
        fe.session_id,
        s.device_type,
        fe.page_load_ms,
        CASE 
            WHEN fe.page_load_ms < 1500 THEN '1. Fast (< 1.5s)'
            WHEN fe.page_load_ms BETWEEN 1500 AND 2500 THEN '2. Moderate (1.5s - 2.5s)'
            WHEN fe.page_load_ms BETWEEN 2501 AND 4000 THEN '3. Slow (2.5s - 4.0s)'
            ELSE '4. Critical Latency (> 4.0s)'
        END AS latency_tier,
        s.has_converted
    FROM funnel_events fe
    JOIN web_sessions s ON fe.session_id = s.session_id
    WHERE fe.event_name IN ('product_view', 'checkout_initiated')
)
SELECT 
    device_type,
    latency_tier,
    COUNT(DISTINCT session_id) AS sessions_evaluated,
    SUM(has_converted) AS converted_sessions,
    ROUND((SUM(has_converted) * 100.0) / COUNT(DISTINCT session_id), 2) AS conversion_rate_pct
FROM event_latency
GROUP BY device_type, latency_tier
ORDER BY device_type, latency_tier;

-- -----------------------------------------------------------------------------
-- Query 7.3: Payment Gateway & Method Failure Breakdown
-- Tests Hypothesis: Specific payment methods encounter disproportionate failure
-- -----------------------------------------------------------------------------
SELECT 
    payment_method,
    COUNT(*) AS total_payment_attempts,
    SUM(CASE WHEN payment_status = 'Successful' THEN 1 ELSE 0 END) AS successful_payments,
    SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) AS failed_payments,
    ROUND(
        (SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS failure_rate_pct,
    ROUND(SUM(CASE WHEN payment_status = 'Failed' THEN amount ELSE 0 END), 2) AS estimated_lost_gmv_usd,
    COALESCE(
        GROUP_CONCAT(DISTINCT CASE WHEN error_code IS NOT NULL THEN error_code END), 
        'None'
    ) AS reported_error_codes
FROM payments
GROUP BY payment_method
ORDER BY failure_rate_pct DESC;

-- -----------------------------------------------------------------------------
-- Query 7.4: Shipping Fee Friction & Threshold Analysis
-- Tests Hypothesis: Charging shipping fees on carts under $75 triggers abandonment
-- -----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN subtotal >= 75.00 THEN 'Free Shipping Tier ($75+)'
        ELSE 'Paid Shipping Tier (< $75)'
    END AS shipping_policy_tier,
    COUNT(*) AS total_orders,
    ROUND(AVG(subtotal), 2) AS avg_subtotal_usd,
    ROUND(AVG(shipping_fee), 2) AS avg_shipping_fee_paid,
    ROUND(SUM(shipping_fee), 2) AS total_shipping_revenue,
    ROUND(SUM(total_amount), 2) AS total_gmv
FROM orders
GROUP BY 
    CASE 
        WHEN subtotal >= 75.00 THEN 'Free Shipping Tier ($75+)'
        ELSE 'Paid Shipping Tier (< $75)'
    END;
