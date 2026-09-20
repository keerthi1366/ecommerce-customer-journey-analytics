-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 00: Bulk Data Ingestion Script for MySQL 8.0
-- =============================================================================

USE ecommerce_analytics;

SET FOREIGN_KEY_CHECKS = 0;

-- Loading table: users
LOAD DATA LOCAL INFILE 'C:/Users/lkeer/.gemini/antigravity/scratch/ecommerce-customer-journey-analytics/data/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Loading table: products
LOAD DATA LOCAL INFILE 'C:/Users/lkeer/.gemini/antigravity/scratch/ecommerce-customer-journey-analytics/data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Loading table: web_sessions
LOAD DATA LOCAL INFILE 'C:/Users/lkeer/.gemini/antigravity/scratch/ecommerce-customer-journey-analytics/data/web_sessions.csv'
INTO TABLE web_sessions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Loading table: funnel_events
LOAD DATA LOCAL INFILE 'C:/Users/lkeer/.gemini/antigravity/scratch/ecommerce-customer-journey-analytics/data/funnel_events.csv'
INTO TABLE funnel_events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Loading table: orders
LOAD DATA LOCAL INFILE 'C:/Users/lkeer/.gemini/antigravity/scratch/ecommerce-customer-journey-analytics/data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Loading table: order_items
LOAD DATA LOCAL INFILE 'C:/Users/lkeer/.gemini/antigravity/scratch/ecommerce-customer-journey-analytics/data/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Loading table: payments
LOAD DATA LOCAL INFILE 'C:/Users/lkeer/.gemini/antigravity/scratch/ecommerce-customer-journey-analytics/data/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Loading table: ab_test_events
LOAD DATA LOCAL INFILE 'C:/Users/lkeer/.gemini/antigravity/scratch/ecommerce-customer-journey-analytics/data/ab_test_events.csv'
INTO TABLE ab_test_events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SET FOREIGN_KEY_CHECKS = 1;
SELECT 'Data Ingestion Completed Successfully!' AS status;
