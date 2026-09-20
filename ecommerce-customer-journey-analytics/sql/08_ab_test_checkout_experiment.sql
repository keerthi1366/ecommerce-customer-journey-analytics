-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 08: A/B Testing Experimentation - Checkout Redesign Evaluation
-- Engine: MySQL 8.0+
-- Description: Analyzes experiment EXP-CHK-2025-Q3 (Control vs Treatment),
--              calculating conversion uplift, device breakdown, and guardrail metrics.
-- =============================================================================

USE ecommerce_analytics;

-- -----------------------------------------------------------------------------
-- Query 8.1: Overall Experiment Summary & Conversion Uplift
-- Evaluates Control (Multi-Step) vs Treatment (One-Step Frictionless Checkout)
-- -----------------------------------------------------------------------------
WITH variant_summary AS (
    SELECT 
        variant,
        COUNT(*) AS total_sample_size,
        SUM(completed_checkout) AS conversions,
        ROUND((SUM(completed_checkout) * 100.0) / COUNT(*), 2) AS conversion_rate_pct,
        ROUND(AVG(checkout_duration_sec), 1) AS avg_checkout_duration_sec,
        SUM(encountered_error) AS total_errors_encountered,
        ROUND((SUM(encountered_error) * 100.0) / COUNT(*), 2) AS error_rate_pct
    FROM ab_test_events
    WHERE experiment_id = 'EXP-CHK-2025-Q3'
    GROUP BY variant
),
control_benchmark AS (
    SELECT conversion_rate_pct AS control_cr
    FROM variant_summary
    WHERE variant = 'Control'
)
SELECT 
    v.variant,
    v.total_sample_size,
    v.conversions,
    v.conversion_rate_pct,
    ROUND(v.conversion_rate_pct - cb.control_cr, 2) AS absolute_difference_pp,
    ROUND(
        (v.conversion_rate_pct - cb.control_cr) * 100.0 / NULLIF(cb.control_cr, 0), 
        2
    ) AS relative_uplift_pct,
    v.avg_checkout_duration_sec,
    v.total_errors_encountered,
    v.error_rate_pct AS guardrail_error_rate_pct
FROM variant_summary v
CROSS JOIN control_benchmark cb
ORDER BY v.variant DESC;

-- -----------------------------------------------------------------------------
-- Query 8.2: Experiment Results Segmented by Device Type
-- Verifies whether the treatment specifically resolved the mobile friction
-- -----------------------------------------------------------------------------
WITH device_exp AS (
    SELECT 
        device,
        variant,
        COUNT(*) AS participants,
        SUM(completed_checkout) AS conversions,
        ROUND((SUM(completed_checkout) * 100.0) / COUNT(*), 2) AS conversion_rate_pct,
        ROUND(AVG(checkout_duration_sec), 1) AS avg_duration_sec,
        ROUND((SUM(encountered_error) * 100.0) / COUNT(*), 2) AS error_rate_pct
    FROM ab_test_events
    WHERE experiment_id = 'EXP-CHK-2025-Q3'
    GROUP BY device, variant
)
SELECT 
    device,
    variant,
    participants,
    conversions,
    conversion_rate_pct,
    avg_duration_sec,
    error_rate_pct
FROM device_exp
ORDER BY device, variant;

-- -----------------------------------------------------------------------------
-- Query 8.3: Sample Ratio Mismatch (SRM) Diagnostic Check
-- Ensures randomization was uncompromised (expected 50/50 allocation)
-- -----------------------------------------------------------------------------
SELECT 
    variant,
    COUNT(*) AS observed_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ab_test_events WHERE experiment_id = 'EXP-CHK-2025-Q3'), 2) AS observed_ratio_pct,
    50.00 AS expected_ratio_pct,
    CASE 
        WHEN ABS((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ab_test_events WHERE experiment_id = 'EXP-CHK-2025-Q3')) - 50.0) <= 2.5 
        THEN 'SRM CHECK PASS (Balanced Allocation)'
        ELSE 'SRM CHECK WARNING (Potential Allocation Bias)'
    END AS srm_status
FROM ab_test_events
WHERE experiment_id = 'EXP-CHK-2025-Q3'
GROUP BY variant;
