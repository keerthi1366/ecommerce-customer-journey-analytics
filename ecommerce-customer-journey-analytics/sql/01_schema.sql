-- =============================================================================
-- E-commerce Customer Journey & Conversion Analytics
-- Script 01: Database Creation & Table Schemas (DDL)
-- Engine: MySQL 8.0+
-- =============================================================================

CREATE DATABASE IF NOT EXISTS ecommerce_analytics
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE ecommerce_analytics;

-- Drop existing tables in reverse dependency order
DROP TABLE IF EXISTS ab_test_events;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS funnel_events;
DROP TABLE IF EXISTS web_sessions;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

-- -----------------------------------------------------------------------------
-- 1. Users Table (Customer entity)
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    user_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    age_group VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    signup_date DATETIME NOT NULL,
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email UNIQUE (email),
    INDEX idx_users_signup (signup_date),
    INDEX idx_users_geo (country, state)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. Products Table (Product catalog)
-- -----------------------------------------------------------------------------
CREATE TABLE products (
    product_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50) NOT NULL,
    cost_price DECIMAL(10, 2) NOT NULL,
    retail_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    INDEX idx_products_cat_price (category, retail_price)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. Web Sessions Table (Clickstream session headers)
-- -----------------------------------------------------------------------------
CREATE TABLE web_sessions (
    session_id VARCHAR(32) NOT NULL,
    user_id INT NULL,
    session_start DATETIME NOT NULL,
    device_type VARCHAR(30) NOT NULL,
    traffic_source VARCHAR(50) NOT NULL,
    page_views INT NOT NULL DEFAULT 1,
    duration_seconds INT NOT NULL DEFAULT 0,
    is_bounced TINYINT(1) NOT NULL DEFAULT 0,
    has_converted TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT pk_web_sessions PRIMARY KEY (session_id),
    CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_sessions_user (user_id),
    INDEX idx_sessions_start (session_start),
    INDEX idx_sessions_device_source (device_type, traffic_source),
    INDEX idx_sessions_converted (has_converted)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. Funnel Events Table (Sequential clickstream log)
-- -----------------------------------------------------------------------------
CREATE TABLE funnel_events (
    event_id BIGINT NOT NULL,
    session_id VARCHAR(32) NOT NULL,
    user_id INT NULL,
    event_name VARCHAR(50) NOT NULL,
    page_type VARCHAR(50) NOT NULL,
    product_id INT NULL,
    page_load_ms INT NOT NULL DEFAULT 0,
    event_timestamp DATETIME NOT NULL,
    CONSTRAINT pk_funnel_events PRIMARY KEY (event_id),
    CONSTRAINT fk_events_session FOREIGN KEY (session_id) REFERENCES web_sessions(session_id) ON DELETE CASCADE,
    CONSTRAINT fk_events_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL,
    INDEX idx_events_session_time (session_id, event_timestamp),
    INDEX idx_events_name_time (event_name, event_timestamp),
    INDEX idx_events_perf (page_load_ms)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 5. Orders Table (E-commerce transactional headers)
-- -----------------------------------------------------------------------------
CREATE TABLE orders (
    order_id VARCHAR(32) NOT NULL,
    user_id INT NOT NULL,
    session_id VARCHAR(32) NOT NULL,
    order_timestamp DATETIME NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    shipping_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    shipping_method VARCHAR(50) NOT NULL,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_orders_session FOREIGN KEY (session_id) REFERENCES web_sessions(session_id),
    INDEX idx_orders_timestamp (order_timestamp),
    INDEX idx_orders_user (user_id),
    INDEX idx_orders_status (order_status)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. Order Items Table (Transaction line items)
-- -----------------------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id BIGINT NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_order_items PRIMARY KEY (order_item_id),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_items_product (product_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. Payments Table (Gateway settlement records)
-- -----------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id BIGINT NOT NULL,
    order_id VARCHAR(32) NULL,
    session_id VARCHAR(32) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    error_code VARCHAR(50) NULL,
    payment_timestamp DATETIME NOT NULL,
    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    INDEX idx_payments_status_method (payment_status, payment_method),
    INDEX idx_payments_session (session_id),
    INDEX idx_payments_order (order_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 8. A/B Test Events Table (Checkout experiment logs)
-- -----------------------------------------------------------------------------
CREATE TABLE ab_test_events (
    experiment_id VARCHAR(50) NOT NULL,
    session_id VARCHAR(32) NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    variant VARCHAR(30) NOT NULL,
    device VARCHAR(30) NOT NULL,
    reached_checkout TINYINT(1) NOT NULL DEFAULT 1,
    completed_checkout TINYINT(1) NOT NULL DEFAULT 0,
    checkout_duration_sec INT NOT NULL DEFAULT 0,
    encountered_error TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT pk_ab_test PRIMARY KEY (experiment_id, session_id),
    INDEX idx_ab_variant (variant),
    INDEX idx_ab_device (device)
) ENGINE=InnoDB;
