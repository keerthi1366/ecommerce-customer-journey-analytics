-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 06: Product & Category Conversion & Merchandising Performance
-- Engine: MySQL 8.0+
-- Description: Analyzes view-to-cart rates, cart-to-order conversion, category
--              margin contributions, and Pareto (80/20) revenue distribution.
-- =============================================================================

USE ecommerce_analytics;

-- -----------------------------------------------------------------------------
-- Query 6.1: Category-Level Funnel & Financial Contribution
-- -----------------------------------------------------------------------------
WITH category_views AS (
    SELECT 
        p.category,
        COUNT(DISTINCT fe.event_id) AS view_count
    FROM funnel_events fe
    JOIN products p ON fe.product_id = p.product_id
    WHERE fe.event_name = 'product_view'
    GROUP BY p.category
),
category_carts AS (
    SELECT 
        p.category,
        COUNT(DISTINCT fe.event_id) AS cart_count
    FROM funnel_events fe
    JOIN products p ON fe.product_id = p.product_id
    WHERE fe.event_name = 'add_to_cart'
    GROUP BY p.category
),
category_sales AS (
    SELECT 
        p.category,
        COUNT(DISTINCT oi.order_id) AS orders_count,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.line_total) AS total_category_revenue,
        SUM(oi.quantity * p.cost_price) AS total_cogs,
        SUM(oi.line_total - (oi.quantity * p.cost_price)) AS total_gross_profit
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category
)
SELECT 
    cv.category,
    cv.view_count,
    COALESCE(cc.cart_count, 0) AS cart_count,
    COALESCE(cs.orders_count, 0) AS orders_count,
    COALESCE(cs.total_units_sold, 0) AS units_sold,
    ROUND(COALESCE(cs.total_category_revenue, 0), 2) AS category_revenue_usd,
    ROUND(COALESCE(cs.total_gross_profit, 0), 2) AS gross_profit_usd,
    ROUND((COALESCE(cs.total_gross_profit, 0) * 100.0) / NULLIF(cs.total_category_revenue, 0), 2) AS gross_margin_pct,
    ROUND((COALESCE(cc.cart_count, 0) * 100.0) / NULLIF(cv.view_count, 0), 2) AS view_to_cart_rate_pct,
    ROUND((COALESCE(cs.orders_count, 0) * 100.0) / NULLIF(cc.cart_count, 0), 2) AS cart_to_order_rate_pct,
    ROUND((COALESCE(cs.orders_count, 0) * 100.0) / NULLIF(cv.view_count, 0), 2) AS overall_product_conversion_rate_pct,
    ROUND((COALESCE(cs.total_category_revenue, 0) * 100.0) / (SELECT SUM(line_total) FROM order_items), 2) AS revenue_contribution_pct
FROM category_views cv
LEFT JOIN category_carts cc ON cv.category = cc.category
LEFT JOIN category_sales cs ON cv.category = cs.category
ORDER BY category_revenue_usd DESC;

-- -----------------------------------------------------------------------------
-- Query 6.2: Top 10 Best-Selling Products vs Bottom 10 Products
-- -----------------------------------------------------------------------------
WITH product_summary AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.retail_price,
        COUNT(DISTINCT CASE WHEN fe.event_name = 'product_view' THEN fe.event_id END) AS view_count,
        COUNT(DISTINCT CASE WHEN fe.event_name = 'add_to_cart' THEN fe.event_id END) AS cart_count,
        COUNT(DISTINCT oi.order_id) AS orders_count,
        COALESCE(SUM(oi.line_total), 0) AS total_revenue
    FROM products p
    LEFT JOIN funnel_events fe ON p.product_id = fe.product_id
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.retail_price
)
SELECT 
    product_name,
    category,
    retail_price,
    view_count,
    cart_count,
    orders_count,
    ROUND(total_revenue, 2) AS total_revenue_usd,
    ROUND((orders_count * 100.0) / NULLIF(view_count, 0), 2) AS product_conversion_rate_pct,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM product_summary
ORDER BY total_revenue DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- Query 6.3: Pareto Analysis (80/20 Distribution of Product Revenue)
-- Demonstrates how much revenue is driven by top-tier products
-- -----------------------------------------------------------------------------
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.line_total) AS product_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT 
        product_id,
        product_name,
        category,
        product_revenue,
        ROW_NUMBER() OVER (ORDER BY product_revenue DESC) AS product_rank,
        COUNT(*) OVER () AS total_products,
        SUM(product_revenue) OVER () AS total_catalog_revenue,
        SUM(product_revenue) OVER (ORDER BY product_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
    FROM product_sales
)
SELECT 
    product_rank,
    product_name,
    category,
    ROUND(product_revenue, 2) AS product_revenue_usd,
    ROUND((product_rank * 100.0) / total_products, 1) AS cumulative_catalog_pct,
    ROUND((cumulative_revenue * 100.0) / total_catalog_revenue, 2) AS cumulative_revenue_share_pct
FROM ranked_products
ORDER BY product_rank ASC;
