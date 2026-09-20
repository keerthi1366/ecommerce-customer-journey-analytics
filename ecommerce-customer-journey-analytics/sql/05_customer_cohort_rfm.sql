-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 05: Customer Cohort Retention & RFM Segmentation
-- Engine: MySQL 8.0+
-- Description: Analyzes monthly cohort retention matrices and performs 
--              RFM (Recency, Frequency, Monetary) customer segmentation.
-- =============================================================================

USE ecommerce_analytics;

-- -----------------------------------------------------------------------------
-- Query 5.1: Monthly Customer Acquisition Cohort Retention Matrix
-- Analyzes repeat purchasing activity across Month 0 to Month 11
-- -----------------------------------------------------------------------------
WITH customer_cohorts AS (
    SELECT 
        u.user_id,
        DATE_FORMAT(u.signup_date, '%Y-%m') AS cohort_month
    FROM users u
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
),
customer_activities AS (
    SELECT 
        c.cohort_month,
        TIMESTAMPDIFF(MONTH, u.signup_date, o.order_timestamp) AS month_number,
        COUNT(DISTINCT o.user_id) AS active_users
    FROM orders o
    JOIN users u ON o.user_id = u.user_id
    JOIN customer_cohorts c ON u.user_id = c.user_id
    WHERE TIMESTAMPDIFF(MONTH, u.signup_date, o.order_timestamp) >= 0
    GROUP BY c.cohort_month, TIMESTAMPDIFF(MONTH, u.signup_date, o.order_timestamp)
)
SELECT 
    cs.cohort_month,
    cs.cohort_size,
    MAX(CASE WHEN ca.month_number = 0 THEN ca.active_users ELSE 0 END) AS m0_users,
    ROUND(MAX(CASE WHEN ca.month_number = 0 THEN ca.active_users ELSE 0 END) * 100.0 / cs.cohort_size, 1) AS m0_retention_pct,
    MAX(CASE WHEN ca.month_number = 1 THEN ca.active_users ELSE 0 END) AS m1_users,
    ROUND(MAX(CASE WHEN ca.month_number = 1 THEN ca.active_users ELSE 0 END) * 100.0 / cs.cohort_size, 1) AS m1_retention_pct,
    MAX(CASE WHEN ca.month_number = 2 THEN ca.active_users ELSE 0 END) AS m2_users,
    ROUND(MAX(CASE WHEN ca.month_number = 2 THEN ca.active_users ELSE 0 END) * 100.0 / cs.cohort_size, 1) AS m2_retention_pct,
    MAX(CASE WHEN ca.month_number = 3 THEN ca.active_users ELSE 0 END) AS m3_users,
    ROUND(MAX(CASE WHEN ca.month_number = 3 THEN ca.active_users ELSE 0 END) * 100.0 / cs.cohort_size, 1) AS m3_retention_pct,
    MAX(CASE WHEN ca.month_number = 4 THEN ca.active_users ELSE 0 END) AS m4_users,
    ROUND(MAX(CASE WHEN ca.month_number = 4 THEN ca.active_users ELSE 0 END) * 100.0 / cs.cohort_size, 1) AS m4_retention_pct,
    MAX(CASE WHEN ca.month_number = 5 THEN ca.active_users ELSE 0 END) AS m5_users,
    ROUND(MAX(CASE WHEN ca.month_number = 5 THEN ca.active_users ELSE 0 END) * 100.0 / cs.cohort_size, 1) AS m5_retention_pct,
    MAX(CASE WHEN ca.month_number = 6 THEN ca.active_users ELSE 0 END) AS m6_users,
    ROUND(MAX(CASE WHEN ca.month_number = 6 THEN ca.active_users ELSE 0 END) * 100.0 / cs.cohort_size, 1) AS m6_retention_pct
FROM cohort_sizes cs
LEFT JOIN customer_activities ca ON cs.cohort_month = ca.cohort_month
GROUP BY cs.cohort_month, cs.cohort_size
ORDER BY cs.cohort_month ASC;

-- -----------------------------------------------------------------------------
-- Query 5.2: RFM Customer Segmentation
-- Calculates Recency, Frequency, Monetary values, quintile scores, and segment labels
-- -----------------------------------------------------------------------------
WITH rfm_raw AS (
    SELECT 
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
        u.email,
        DATEDIFF('2025-12-31 23:59:59', MAX(o.order_timestamp)) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(o.total_amount), 2) AS monetary_value
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.first_name, u.last_name, u.email
),
rfm_scores AS (
    SELECT 
        user_id,
        customer_name,
        email,
        recency_days,
        frequency,
        monetary_value,
        -- Lower recency days = higher score (5 is best)
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        -- Higher frequency = higher score
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        -- Higher monetary value = higher score
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS m_score
    FROM rfm_raw
),
rfm_segmented AS (
    SELECT 
        user_id,
        customer_name,
        email,
        recency_days,
        frequency,
        monetary_value,
        r_score,
        f_score,
        m_score,
        CONCAT(r_score, f_score, m_score) AS rfm_cell,
        CASE 
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'Potential Loyalists / Recent Buyers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk / Need Attention'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost Customers'
            ELSE 'Promising / Developing'
        END AS customer_segment
    FROM rfm_scores
)
SELECT 
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM rfm_segmented), 2) AS pct_of_customer_base,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_order_frequency,
    ROUND(AVG(monetary_value), 2) AS avg_customer_spend_usd,
    ROUND(SUM(monetary_value), 2) AS total_segment_revenue_usd,
    ROUND(SUM(monetary_value) * 100.0 / (SELECT SUM(monetary_value) FROM rfm_segmented), 2) AS revenue_contribution_pct
FROM rfm_segmented
GROUP BY customer_segment
ORDER BY total_segment_revenue_usd DESC;
