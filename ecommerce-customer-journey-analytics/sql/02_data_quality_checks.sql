-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 02: Data Quality & Integrity Validation Suite
-- Engine: MySQL 8.0+
-- Description: Verifies referential integrity, domain constraints, chronological
--              consistency, and funnel logic.
-- =============================================================================

USE ecommerce_analytics;

-- -----------------------------------------------------------------------------
-- DQ Test 1: Referential Integrity - Orphaned Records Check
-- -----------------------------------------------------------------------------
SELECT 
    'DQ_REF_01' AS check_code,
    'Orphaned Web Sessions (Non-null user_id not in users)' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM web_sessions s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE s.user_id IS NOT NULL AND u.user_id IS NULL

UNION ALL

SELECT 
    'DQ_REF_02' AS check_code,
    'Orphaned Orders (Invalid user_id or session_id)' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM orders o
LEFT JOIN users u ON o.user_id = u.user_id
LEFT JOIN web_sessions s ON o.session_id = s.session_id
WHERE u.user_id IS NULL OR s.session_id IS NULL

UNION ALL

SELECT 
    'DQ_REF_03' AS check_code,
    'Orphaned Order Items (Invalid order_id or product_id)' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE o.order_id IS NULL OR p.product_id IS NULL

UNION ALL

SELECT 
    'DQ_REF_04' AS check_code,
    'Orphaned Funnel Events (Invalid session_id)' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM funnel_events fe
LEFT JOIN web_sessions s ON fe.session_id = s.session_id
WHERE s.session_id IS NULL;

-- -----------------------------------------------------------------------------
-- DQ Test 2: Temporal Consistency - Event Timestamps vs Session Start
-- -----------------------------------------------------------------------------
SELECT 
    'DQ_TIME_01' AS check_code,
    'Events occurring strictly before session_start' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM funnel_events fe
JOIN web_sessions s ON fe.session_id = s.session_id
WHERE fe.event_timestamp < s.session_start

UNION ALL

SELECT 
    'DQ_TIME_02' AS check_code,
    'Order timestamp occurring strictly before session_start' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM orders o
JOIN web_sessions s ON o.session_id = s.session_id
WHERE o.order_timestamp < s.session_start;

-- -----------------------------------------------------------------------------
-- DQ Test 3: Numerical & Domain Boundaries
-- -----------------------------------------------------------------------------
SELECT 
    'DQ_DOM_01' AS check_code,
    'Negative or zero total order amount' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM orders
WHERE total_amount <= 0.00

UNION ALL

SELECT 
    'DQ_DOM_02' AS check_code,
    'Invalid item quantity (quantity <= 0)' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM order_items
WHERE quantity <= 0

UNION ALL

SELECT 
    'DQ_DOM_03' AS check_code,
    'Negative product retail or cost prices' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM products
WHERE retail_price < 0 OR cost_price < 0;

-- -----------------------------------------------------------------------------
-- DQ Test 4: Primary Key & Uniqueness Verification
-- -----------------------------------------------------------------------------
SELECT 
    'DQ_UNIQ_01' AS check_code,
    'Duplicate user_id in users' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM (
    SELECT user_id FROM users GROUP BY user_id HAVING COUNT(*) > 1
) dupes

UNION ALL

SELECT 
    'DQ_UNIQ_02' AS check_code,
    'Duplicate session_id in web_sessions' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM (
    SELECT session_id FROM web_sessions GROUP BY session_id HAVING COUNT(*) > 1
) dupes

UNION ALL

SELECT 
    'DQ_UNIQ_03' AS check_code,
    'Duplicate order_id in orders' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM (
    SELECT order_id FROM orders GROUP BY order_id HAVING COUNT(*) > 1
) dupes;

-- -----------------------------------------------------------------------------
-- DQ Test 5: Funnel Journey Logic Consistency
-- Check that every purchase event had a prior checkout initiation
-- -----------------------------------------------------------------------------
SELECT 
    'DQ_FUNNEL_01' AS check_code,
    'Sessions with purchase_completed but no checkout_initiated' AS check_description,
    COUNT(*) AS failed_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_status
FROM (
    SELECT session_id
    FROM funnel_events
    GROUP BY session_id
    HAVING 
        SUM(CASE WHEN event_name = 'purchase_completed' THEN 1 ELSE 0 END) > 0
        AND SUM(CASE WHEN event_name = 'checkout_initiated' THEN 1 ELSE 0 END) = 0
) invalid_journeys;
