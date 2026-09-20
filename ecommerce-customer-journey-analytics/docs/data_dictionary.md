# Data Dictionary: E-commerce Customer Journey & Conversion Analytics

This document provides a comprehensive reference for all entities, tables, fields, data types, constraints, and business rules across the relational database and Power BI Star Schema.

---

## 1. Relational Entities (MySQL 8.0 Primary Database)

### 1.1 `users` Table
Stores registered customer demographic and registration profiles.
- **Grain**: 1 row per registered customer.

| Column Name | Data Type | Nullable | Primary Key | Foreign Key | Description | Example / Allowed Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `user_id` | `INT` | No | Yes | No | Unique surrogate customer identifier | `1042` |
| `first_name` | `VARCHAR(50)` | No | No | No | Customer's first name | `'Sophia'` |
| `last_name` | `VARCHAR(50)` | No | No | No | Customer's family name | `'Garcia'` |
| `email` | `VARCHAR(120)` | No | No | No | Customer's primary contact email (Unique) | `'sophia.garcia1042@example.com'` |
| `gender` | `VARCHAR(20)` | No | No | No | Self-reported customer gender | `'Female'`, `'Male'`, `'Other'` |
| `age_group` | `VARCHAR(20)` | No | No | No | Demographic age bracket | `'18-24'`, `'25-34'`, `'35-44'`, `'45-54'`, `'55+'` |
| `country` | `VARCHAR(50)` | No | No | No | Customer country of residence | `'USA'`, `'Canada'`, `'UK'` |
| `state` | `VARCHAR(50)` | No | No | No | Customer state or province | `'California'`, `'New York'`, `'Texas'` |
| `city` | `VARCHAR(50)` | No | No | No | Customer municipality | `'Los Angeles'`, `'Austin'`, `'Seattle'` |
| `signup_date` | `DATETIME` | No | No | No | Account registration timestamp | `'2025-03-14 18:22:04'` |

---

### 1.2 `products` Table
Merchandise catalog containing pricing, categorization, and inventory.
- **Grain**: 1 row per unique stock-keeping unit (SKU).

| Column Name | Data Type | Nullable | Primary Key | Foreign Key | Description | Example / Allowed Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `product_id` | `INT` | No | Yes | No | Unique product SKU identifier | `17` |
| `product_name` | `VARCHAR(150)` | No | No | No | Commercial marketing title | `'Automatic Espresso & Cappuccino Machine'` |
| `category` | `VARCHAR(50)` | No | No | No | Macro product department | `'Home & Kitchen'`, `'Electronics'`, `'Apparel'`, `'Beauty'`, `'Sports'` |
| `sub_category` | `VARCHAR(50)` | No | No | No | Micro departmental division | `'Coffee & Tea'`, `'Audio'`, `'Skincare'` |
| `cost_price` | `DECIMAL(10,2)`| No | No | No | Unit manufacturing / acquisition cost | `160.00` |
| `retail_price` | `DECIMAL(10,2)`| No | No | No | Listed consumer retail price | `349.00` |
| `stock_quantity`| `INT` | No | No | No | Warehoused units available | `450` |
| `created_at` | `DATETIME` | No | No | No | Catalog onboarding timestamp | `'2024-12-15 00:00:00'` |

---

### 1.3 `web_sessions` Table
Top-level clickstream session headers recording entry device, channel, and high-level conversion.
- **Grain**: 1 row per user browsing session.

| Column Name | Data Type | Nullable | Primary Key | Foreign Key | Description | Example / Allowed Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `session_id` | `VARCHAR(32)` | No | Yes | No | Unique session tracking code | `'SES-2025-001249'` |
| `user_id` | `INT` | Yes | No | `users(user_id)` | Identified customer ID (NULL for anonymous) | `4812` or `NULL` |
| `session_start` | `DATETIME` | No | No | No | Initial landing timestamp | `'2025-06-18 14:10:22'` |
| `device_type` | `VARCHAR(30)` | No | No | No | Client device hardware form factor | `'Mobile'`, `'Desktop'`, `'Tablet'` |
| `traffic_source`| `VARCHAR(50)` | No | No | No | Inbound attribution acquisition channel | `'Organic Search'`, `'Direct'`, `'Paid Social'`, `'Paid Search'`, `'Email'` |
| `page_views` | `INT` | No | No | No | Total pages rendered in session | `4` |
| `duration_seconds`| `INT` | No | No | No | Session length in seconds | `185` |
| `is_bounced` | `TINYINT(1)` | No | No | No | Single-page immediate exit flag (1/0) | `0` or `1` |
| `has_converted` | `TINYINT(1)` | No | No | No | Order completion indicator (1/0) | `1` or `0` |

---

### 1.4 `funnel_events` Table
Granular clickstream events tracking micro-interactions through the 7-step customer journey.
- **Grain**: 1 row per clickstream action.

| Column Name | Data Type | Nullable | Primary Key | Foreign Key | Description | Example / Allowed Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `event_id` | `BIGINT` | No | Yes | No | Auto-incrementing interaction event ID | `42918` |
| `session_id` | `VARCHAR(32)` | No | No | `web_sessions(session_id)` | Owning clickstream session ID | `'SES-2025-001249'` |
| `user_id` | `INT` | Yes | No | No | Identified user ID | `4812` |
| `event_name` | `VARCHAR(50)` | No | No | No | Stage event name in the customer journey | `'session_visit'`, `'browse_search'`, `'product_view'`, `'add_to_cart'`, `'checkout_initiated'`, `'payment_attempted'`, `'purchase_completed'` |
| `page_type` | `VARCHAR(50)` | No | No | No | UI template classification | `'product_detail'`, `'cart_modal'`, `'checkout_step1'` |
| `product_id` | `INT` | Yes | No | `products(product_id)` | Associated product SKU | `17` |
| `page_load_ms` | `INT` | No | No | No | Frontend render & response latency (ms) | `2410` |
| `event_timestamp`| `DATETIME` | No | No | No | UTC timestamp of action execution | `'2025-06-18 14:12:45'` |

---

### 1.5 `orders` Table
Transactional records representing binding customer purchases.
- **Grain**: 1 row per order placed.

| Column Name | Data Type | Nullable | Primary Key | Foreign Key | Description | Example / Allowed Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `order_id` | `VARCHAR(32)` | No | Yes | No | Unique commercial order invoice number | `'ORD-2025-000412'` |
| `user_id` | `INT` | No | No | `users(user_id)` | Purchasing customer identifier | `4812` |
| `session_id` | `VARCHAR(32)` | No | No | `web_sessions(session_id)` | Session during which order was completed | `'SES-2025-001249'` |
| `order_timestamp`| `DATETIME` | No | No | No | Finalized checkout timestamp | `'2025-06-18 14:15:30'` |
| `subtotal` | `DECIMAL(10,2)`| No | No | No | Pre-tax, pre-shipping item sum | `89.00` |
| `discount_amount`| `DECIMAL(10,2)`| No | No | No | Promotional discount deducted | `0.00` |
| `shipping_fee` | `DECIMAL(10,2)`| No | No | No | Freight charges ($0 if subtotal >= $75) | `0.00` or `7.99` |
| `tax_amount` | `DECIMAL(10,2)`| No | No | No | State/local sales tax collected (8.25%) | `7.34` |
| `total_amount` | `DECIMAL(10,2)`| No | No | No | Final gross transaction settlement | `96.34` |
| `order_status` | `VARCHAR(30)` | No | No | No | Fulfillment lifecycle status | `'Delivered'`, `'Processing'`, `'Shipped'` |
| `shipping_method`| `VARCHAR(50)` | No | No | No | Service carrier tier selected | `'Free Standard'`, `'Standard Ground'` |

---

### 1.6 `order_items` Table
Line-item breakdown of individual items included within each order.
- **Grain**: 1 row per SKU within an order.

| Column Name | Data Type | Nullable | Primary Key | Foreign Key | Description | Example / Allowed Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `order_item_id`| `BIGINT` | No | Yes | No | Unique line item record key | `1` |
| `order_id` | `VARCHAR(32)` | No | No | `orders(order_id)` | Parent transaction ID | `'ORD-2025-000412'` |
| `product_id` | `INT` | No | No | `products(product_id)` | Product SKU purchased | `17` |
| `quantity` | `INT` | No | No | No | Units purchased (>= 1) | `1` |
| `unit_price` | `DECIMAL(10,2)`| No | No | No | Unit price charged at purchase time | `89.00` |
| `line_total` | `DECIMAL(10,2)`| No | No | No | `quantity * unit_price` | `89.00` |

---

### 1.7 `payments` Table
Records all payment authorization attempts, successes, and gateway decline codes.
- **Grain**: 1 row per payment attempt.

| Column Name | Data Type | Nullable | Primary Key | Foreign Key | Description | Example / Allowed Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `payment_id` | `BIGINT` | No | Yes | No | Unique payment transaction identifier | `89` |
| `order_id` | `VARCHAR(32)` | Yes | No | `orders(order_id)` | Linked order (NULL if payment failed) | `'ORD-2025-000412'` or `NULL` |
| `session_id` | `VARCHAR(32)` | No | No | `web_sessions(session_id)` | Browsing session origin | `'SES-2025-001249'` |
| `payment_method`| `VARCHAR(50)` | No | No | No | Financial tender method utilized | `'Credit Card'`, `'Debit Card'`, `'PayPal'`, `'Apple Pay'`, `'Buy Now Pay Later'` |
| `amount` | `DECIMAL(10,2)`| No | No | No | Transaction dollar amount attempted | `96.34` |
| `payment_status`| `VARCHAR(30)` | No | No | No | Authorization settlement outcome | `'Successful'`, `'Failed'` |
| `error_code` | `VARCHAR(50)` | Yes | No | No | Financial institution decline reason code | `'DECLINED_BY_ISSUER'`, `'CREDIT_THRESHOLD_EXCEEDED'` |
| `payment_timestamp`|`DATETIME` | No | No | No | Authorization attempt timestamp | `'2025-06-18 14:15:20'` |

---

### 1.8 `ab_test_events` Table
Experimental instrumentation tracking checkout variants (Control vs Treatment).
- **Grain**: 1 row per experiment session entry.

| Column Name | Data Type | Nullable | Primary Key | Foreign Key | Description | Example / Allowed Values |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `experiment_id`| `VARCHAR(50)` | No | Yes (Composite) | No | Experiment project code | `'EXP-CHK-2025-Q3'` |
| `session_id` | `VARCHAR(32)` | No | Yes (Composite) | `web_sessions(session_id)` | User session ID | `'SES-2025-001249'` |
| `user_id` | `VARCHAR(50)` | No | No | No | User ID or 'GUEST' | `'4812'` |
| `variant` | `VARCHAR(30)` | No | No | No | Test group allocation | `'Control'`, `'Treatment'` |
| `device` | `VARCHAR(30)` | No | No | No | Hardware client | `'Mobile'`, `'Desktop'`, `'Tablet'` |
| `reached_checkout`|`TINYINT(1)` | No | No | No | Checkout funnel entry flag | `1` |
| `completed_checkout`|`TINYINT(1)`| No | No | No | Order confirmation reach flag | `1` or `0` |
| `checkout_duration_sec`|`INT` | No | No | No | Elapsed seconds inside checkout form | `49` |
| `encountered_error`|`TINYINT(1)`| No | No | No | Form validation or gateway error encountered | `0` or `1` |
