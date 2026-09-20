-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 03: Core Business & Financial Performance Metrics
-- Engine: MySQL 8.0+
-- Description: Calculates overall KPIs, monthly growth trends, Average Order
--              Value (AOV), Conversion Rate, and Repeat Purchase Dynamics.
-- =============================================================================

USE ecommerce_analytics;

-- -----------------------------------------------------------------------------
-- Query 3.1: Executive Summary KPIs (Overall Portfolio Benchmark)
-- -----------------------------------------------------------------------------
WITH summary_stats AS (
    SELECT 
        COUNT(DISTINCT s.session_id) AS total_sessions,
        COUNT(DISTINCT s.user_id) AS total_active_users,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_gross_revenue,
        SUM(o.subtotal) AS total_net_merchandise_value,
        SUM(o.discount_amount) AS total_discounts_granted,
        SUM(o.shipping_fee) AS total_shipping_collected
    FROM web_sessions s
    LEFT JOIN orders o ON s.session_id = o.session_id
)
SELECT 
    total_sessions,
    total_active_users,
    total_orders,
    ROUND(total_gross_revenue, 2) AS gross_revenue_usd,
    ROUND(total_net_merchandise_value, 2) AS net_merchandise_value_usd,
    ROUND(total_discounts_granted, 2) AS discounts_usd,
    ROUND(total_shipping_collected, 2) AS shipping_usd,
    ROUND((total_orders * 100.0) / NULLIF(total_sessions, 0), 2) AS overall_session_conversion_rate_pct,
    ROUND(total_gross_revenue / NULLIF(total_orders, 0), 2) AS average_order_value_usd,
    ROUND(total_gross_revenue / NULLIF(total_active_users, 0), 2) AS average_revenue_per_active_user_usd
FROM summary_stats;

-- -----------------------------------------------------------------------------
-- Query 3.2: Monthly Executive Performance & MoM Revenue Trajectory
-- -----------------------------------------------------------------------------
WITH monthly_metrics AS (
    SELECT 
        DATE_FORMAT(s.session_start, '%Y-%m') AS order_month,
        COUNT(DISTINCT s.session_id) AS monthly_sessions,
        COUNT(DISTINCT s.user_id) AS monthly_active_users,
        COUNT(DISTINCT o.order_id) AS monthly_orders,
        ROUND(SUM(COALESCE(o.total_amount, 0)), 2) AS monthly_revenue,
        ROUND(AVG(o.total_amount), 2) AS monthly_aov,
        ROUND((COUNT(DISTINCT o.order_id) * 100.0) / NULLIF(COUNT(DISTINCT s.session_id), 0), 2) AS monthly_conversion_rate_pct
    FROM web_sessions s
    LEFT JOIN orders o ON s.session_id = o.session_id
    GROUP BY DATE_FORMAT(s.session_start, '%Y-%m')
)
SELECT 
    order_month,
    monthly_sessions,
    monthly_active_users,
    monthly_orders,
    monthly_revenue,
    monthly_aov,
    monthly_conversion_rate_pct,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY order_month)) * 100.0 
        / NULLIF(LAG(monthly_revenue, 1) OVER (ORDER BY order_month), 0), 
        2
    ) AS mom_revenue_growth_pct
FROM monthly_metrics
ORDER BY order_month ASC;

-- -----------------------------------------------------------------------------
-- Query 3.3: Customer Repeat Purchase Rate & Order Frequency Distribution
-- -----------------------------------------------------------------------------
WITH user_orders AS (
    SELECT 
        user_id,
        COUNT(order_id) AS lifetime_orders,
        SUM(total_amount) AS lifetime_spend
    FROM orders
    GROUP BY user_id
),
order_buckets AS (
    SELECT 
        CASE 
            WHEN lifetime_orders = 1 THEN '1 Order (One-Time Buyer)'
            WHEN lifetime_orders = 2 THEN '2 Orders (Repeat Buyer)'
            WHEN lifetime_orders BETWEEN 3 AND 5 THEN '3-5 Orders (Frequent Buyer)'
            ELSE '6+ Orders (VIP)'
        END AS customer_frequency_tier,
        COUNT(user_id) AS user_count,
        SUM(lifetime_spend) AS tier_revenue
    FROM user_orders
    GROUP BY 
        CASE 
            WHEN lifetime_orders = 1 THEN '1 Order (One-Time Buyer)'
            WHEN lifetime_orders = 2 THEN '2 Orders (Repeat Buyer)'
            WHEN lifetime_orders BETWEEN 3 AND 5 THEN '3-5 Orders (Frequent Buyer)'
            ELSE '6+ Orders (VIP)'
        END
)
SELECT 
    customer_frequency_tier,
    user_count,
    ROUND((user_count * 100.0) / (SELECT SUM(user_count) FROM order_buckets), 2) AS pct_of_customer_base,
    ROUND(tier_revenue, 2) AS total_tier_revenue_usd,
    ROUND((tier_revenue * 100.0) / (SELECT SUM(tier_revenue) FROM order_buckets), 2) AS pct_of_total_revenue
FROM order_buckets
ORDER BY user_count DESC;

-- -----------------------------------------------------------------------------
-- Query 3.4: Repeat Purchase Rate Calculation
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT user_id) AS total_purchasing_customers,
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN user_id END) AS repeat_purchasing_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN user_id END) * 100.0 
        / COUNT(DISTINCT user_id), 
        2
    ) AS repeat_purchase_rate_pct
FROM (
    SELECT user_id, COUNT(order_id) AS order_count
    FROM orders
    GROUP BY user_id
) customer_order_summary;
