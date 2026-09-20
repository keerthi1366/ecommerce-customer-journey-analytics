# Automated SQL Analytics Execution Report
Generated at: 2026-09-20 22:18:48

## 02_data_quality_checks.sql: Data Quality & Integrity Suite

### Query 1
| check_code | check_description | failed_count | check_status |
| --- | --- | --- | --- |
| DQ_REF_01 | Orphaned Web Sessions (Non-null user_id not in users) | 0 | PASS |
| DQ_REF_02 | Orphaned Orders (Invalid user_id or session_id) | 0 | PASS |
| DQ_REF_03 | Orphaned Order Items (Invalid order_id or product_id) | 0 | PASS |
| DQ_REF_04 | Orphaned Funnel Events (Invalid session_id) | 0 | PASS |

### Query 2
| check_code | check_description | failed_count | check_status |
| --- | --- | --- | --- |
| DQ_TIME_01 | Events occurring strictly before session_start | 0 | PASS |
| DQ_TIME_02 | Order timestamp occurring strictly before session_start | 0 | PASS |

### Query 3
| check_code | check_description | failed_count | check_status |
| --- | --- | --- | --- |
| DQ_DOM_01 | Negative or zero total order amount | 0 | PASS |
| DQ_DOM_02 | Invalid item quantity (quantity <= 0) | 0 | PASS |
| DQ_DOM_03 | Negative product retail or cost prices | 0 | PASS |

### Query 4
| check_code | check_description | failed_count | check_status |
| --- | --- | --- | --- |
| DQ_UNIQ_01 | Duplicate user_id in users | 0 | PASS |
| DQ_UNIQ_02 | Duplicate session_id in web_sessions | 0 | PASS |
| DQ_UNIQ_03 | Duplicate order_id in orders | 0 | PASS |

### Query 5
| check_code | check_description | failed_count | check_status |
| --- | --- | --- | --- |
| DQ_FUNNEL_01 | Sessions with purchase_completed but no checkout_initiated | 0 | PASS |

## 03_core_business_metrics.sql: Core Business & Financial KPIs

### Query 1
| total_sessions | total_active_users | total_orders | gross_revenue_usd | net_merchandise_value_usd | discounts_usd | shipping_usd | overall_session_conversion_rate_pct | average_order_value_usd | average_revenue_per_active_user_usd |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 32000.0 | 8769.0 | 857.0 | 89003.07 | 79706.75 | 1179.3 | 3899.12 | 2.68 | 103.85 | 10.15 |

### Query 2
| order_month | monthly_sessions | monthly_active_users | monthly_orders | monthly_revenue | monthly_aov | monthly_conversion_rate_pct | mom_revenue_growth_pct |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2025-01 | 1049 | 115 | 30 | 3405.05 | 113.5 | 2.86 | nan |
| 2025-02 | 1119 | 215 | 33 | 3418.3 | 103.58 | 2.95 | 0.39 |
| 2025-03 | 1326 | 397 | 41 | 4631.92 | 112.97 | 3.09 | 35.5 |
| 2025-04 | 1508 | 556 | 39 | 3854.49 | 98.83 | 2.59 | -16.78 |
| 2025-05 | 1824 | 787 | 56 | 5426.55 | 96.9 | 3.07 | 40.79 |
| 2025-06 | 1925 | 940 | 37 | 3918.0 | 105.89 | 1.92 | -27.8 |
| 2025-07 | 2364 | 1198 | 46 | 4350.04 | 94.57 | 1.95 | 11.03 |
| 2025-08 | 2655 | 1486 | 74 | 8385.67 | 113.32 | 2.79 | 92.77 |
| 2025-09 | 2994 | 1804 | 91 | 9723.34 | 106.85 | 3.04 | 15.95 |
| 2025-10 | 3656 | 2256 | 99 | 10207.46 | 103.11 | 2.71 | 4.98 |

*(Showing top 10 of 13 rows)*

### Query 3
| customer_frequency_tier | user_count | pct_of_customer_base | total_tier_revenue_usd | pct_of_total_revenue |
| --- | --- | --- | --- | --- |
| 1 Order (One-Time Buyer) | 808 | 97.12 | 82796.55 | 93.03 |
| 2 Orders (Repeat Buyer) | 23 | 2.76 | 6037.59 | 6.78 |
| 3-5 Orders (Frequent Buyer) | 1 | 0.12 | 168.93 | 0.19 |

### Query 4
| total_purchasing_customers | repeat_purchasing_customers | repeat_purchase_rate_pct |
| --- | --- | --- |
| 832.0 | 24.0 | 2.88 |

## 04_funnel_analysis.sql: Funnel Drop-off & Stage Conversion

### Query 1
| funnel_stage | session_count | pct_of_initial_visits | stage_dropoff_pct |
| --- | --- | --- | --- |
| 1. Session Visit | 32000 | 100.0 | 0.0 |
| 2. Browse / Search | 20376 | 63.67 | 36.33 |
| 3. Product View | 13841 | 43.25 | 32.07 |
| 4. Add to Cart | 4823 | 15.07 | 65.15 |
| 5. Checkout Initiated | 1436 | 4.49 | 70.23 |
| 6. Payment Attempted | 900 | 2.81 | 37.33 |
| 7. Purchase Completed | 857 | 2.68 | 4.78 |

### Query 2
| total_cart_sessions | abandoned_cart_sessions | cart_abandonment_rate_pct | total_checkout_sessions | abandoned_checkout_sessions | checkout_abandonment_rate_pct |
| --- | --- | --- | --- | --- | --- |
| 4823.0 | 3966.0 | 82.23 | 1436.0 | 579.0 | 40.32 |

### Query 3
| device_type | total_sessions | cart_sessions | checkout_sessions | purchase_sessions | visit_to_cart_rate_pct | cart_abandonment_rate_pct | checkout_abandonment_rate_pct | overall_conversion_rate_pct |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Desktop | 11329 | 1953 | 686 | 447 | 17.24 | 64.87 | 34.84 | 3.95 |
| Mobile | 19072 | 2644 | 693 | 383 | 13.86 | 73.79 | 44.73 | 2.01 |
| Tablet | 1599 | 226 | 57 | 27 | 14.13 | 74.78 | 52.63 | 1.69 |

### Query 4
| traffic_source | total_sessions | cart_sessions | purchase_sessions | visit_to_cart_rate_pct | cart_abandonment_pct | overall_conversion_rate_pct |
| --- | --- | --- | --- | --- | --- | --- |
| Email | 3261 | 579 | 127 | 17.76 | 60.28 | 3.89 |
| Direct | 5717 | 1002 | 203 | 17.53 | 68.96 | 3.55 |
| Organic Search | 8919 | 1324 | 221 | 14.84 | 71.0 | 2.48 |
| Paid Search | 6968 | 1071 | 172 | 15.37 | 72.83 | 2.47 |
| Affiliate | 1311 | 185 | 29 | 14.11 | 71.35 | 2.21 |
| Paid Social | 5824 | 662 | 105 | 11.37 | 74.77 | 1.8 |

## 05_customer_cohort_rfm.sql: Customer Cohorts & RFM Segmentation

### Query 1
| cohort_month | cohort_size | m0_users | m0_retention_pct | m1_users | m1_retention_pct | m2_users | m2_retention_pct | m3_users | m3_retention_pct | m4_users | m4_retention_pct | m5_users | m5_retention_pct | m6_users | m6_retention_pct |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2025-01 | 827 | 4 | 0.5 | 5 | 0.6 | 9 | 1.1 | 7 | 0.8 | 7 | 0.8 | 5 | 0.6 | 5 | 0.6 |
| 2025-02 | 770 | 5 | 0.6 | 6 | 0.8 | 6 | 0.8 | 7 | 0.9 | 7 | 0.9 | 4 | 0.5 | 8 | 1.0 |
| 2025-03 | 890 | 5 | 0.6 | 8 | 0.9 | 9 | 1.0 | 5 | 0.6 | 4 | 0.4 | 10 | 1.1 | 8 | 0.9 |
| 2025-04 | 801 | 2 | 0.2 | 11 | 1.4 | 4 | 0.5 | 6 | 0.7 | 9 | 1.1 | 11 | 1.4 | 3 | 0.4 |
| 2025-05 | 793 | 6 | 0.8 | 5 | 0.6 | 4 | 0.5 | 7 | 0.9 | 5 | 0.6 | 7 | 0.9 | 14 | 1.8 |
| 2025-06 | 846 | 2 | 0.2 | 10 | 1.2 | 11 | 1.3 | 8 | 0.9 | 9 | 1.1 | 7 | 0.8 | 13 | 1.5 |
| 2025-07 | 857 | 2 | 0.2 | 13 | 1.5 | 14 | 1.6 | 16 | 1.9 | 10 | 1.2 | 11 | 1.3 | 0 | 0.0 |
| 2025-08 | 818 | 7 | 0.9 | 10 | 1.2 | 11 | 1.3 | 12 | 1.5 | 20 | 2.4 | 0 | 0.0 | 0 | 0.0 |
| 2025-09 | 815 | 8 | 1.0 | 13 | 1.6 | 14 | 1.7 | 15 | 1.8 | 0 | 0.0 | 0 | 0.0 | 0 | 0.0 |
| 2025-10 | 916 | 16 | 1.7 | 22 | 2.4 | 25 | 2.7 | 0 | 0.0 | 0 | 0.0 | 0 | 0.0 | 0 | 0.0 |

*(Showing top 10 of 12 rows)*

### Query 2
| customer_segment | total_customers | pct_of_customer_base | avg_recency_days | avg_order_frequency | avg_customer_spend_usd | total_segment_revenue_usd | revenue_contribution_pct |
| --- | --- | --- | --- | --- | --- | --- | --- |
| At Risk / Need Attention | 193 | 23.2 | 230.9 | 1.03 | 153.46 | 29618.45 | 33.28 |
| Champions | 145 | 17.43 | 29.6 | 1.1 | 177.55 | 25744.55 | 28.93 |
| Loyal Customers | 160 | 19.23 | 68.9 | 1.04 | 115.91 | 18545.61 | 20.84 |
| Lost Customers | 141 | 16.95 | 223.0 | 1.0 | 44.61 | 6289.76 | 7.07 |
| Potential Loyalists / Recent Buyers | 123 | 14.78 | 23.9 | 1.0 | 44.84 | 5515.86 | 6.2 |
| Promising / Developing | 70 | 8.41 | 94.1 | 1.0 | 46.98 | 3288.84 | 3.7 |

## 06_product_category_analysis.sql: Product & Category Conversion

### Query 1
| category | view_count | cart_count | orders_count | units_sold | category_revenue_usd | gross_profit_usd | gross_margin_pct | view_to_cart_rate_pct | cart_to_order_rate_pct | overall_product_conversion_rate_pct | revenue_contribution_pct |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Home & Kitchen | 2972 | 951 | 162 | 201 | 24384.0 | 13902.0 | 57.01 | 32.0 | 17.03 | 5.45 | 30.59 |
| Electronics | 3286 | 980 | 166 | 225 | 20172.75 | 10029.75 | 49.72 | 29.82 | 16.94 | 5.05 | 25.31 |
| Apparel | 2923 | 1165 | 219 | 277 | 17071.0 | 11046.0 | 64.71 | 39.86 | 18.8 | 7.49 | 21.42 |
| Sports | 2082 | 690 | 117 | 163 | 9340.0 | 5837.0 | 62.49 | 33.14 | 16.96 | 5.62 | 11.72 |
| Beauty | 2578 | 1037 | 193 | 254 | 8739.0 | 5973.5 | 68.35 | 40.22 | 18.61 | 7.49 | 10.96 |

### Query 2
| product_name | category | retail_price | view_count | cart_count | orders_count | total_revenue_usd | product_conversion_rate_pct | revenue_rank |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Automatic Espresso & Cappuccino Machine | Home & Kitchen | 349.0 | 388 | 114 | 25 | 6989074.0 | 6.44 | 1 |
| Waterproof Trench Coat Jacket | Apparel | 145.0 | 423 | 164 | 32 | 4401910.0 | 7.57 | 2 |
| Ultra-Slim 4K Monitor 27-inch | Electronics | 299.99 | 417 | 95 | 14 | 2876304.12 | 3.36 | 3 |
| Wireless Noise-Canceling Headphones | Electronics | 149.99 | 417 | 127 | 17 | 2283597.75 | 4.08 | 4 |
| Sonic Electric Toothbrush with UV Sanitizer | Beauty | 79.0 | 392 | 147 | 30 | 2102111.0 | 7.65 | 5 |
| Luxury Bamboo Queen Sheet Set | Home & Kitchen | 110.0 | 450 | 154 | 23 | 2061180.0 | 5.11 | 6 |
| Cast Iron Dutch Oven 6-Quart | Home & Kitchen | 89.0 | 455 | 137 | 24 | 2045576.0 | 5.27 | 7 |
| Adjustable Neoprene Dumbbell Set (Pair) | Sports | 85.0 | 415 | 148 | 24 | 1901620.0 | 5.78 | 8 |
| Slim-Fit Stretch Denim Jeans | Apparel | 68.0 | 387 | 157 | 34 | 1890672.0 | 8.79 | 9 |
| Performance Athletic Hoodie | Apparel | 74.0 | 428 | 164 | 28 | 1687422.0 | 6.54 | 10 |

### Query 3
| product_rank | product_name | category | product_revenue_usd | cumulative_catalog_pct | cumulative_revenue_share_pct |
| --- | --- | --- | --- | --- | --- |
| 1 | Automatic Espresso & Cappuccino Machine | Home & Kitchen | 11866.0 | 3.0 | 14.89 |
| 2 | Waterproof Trench Coat Jacket | Apparel | 6235.0 | 6.1 | 22.71 |
| 3 | Ultra-Slim 4K Monitor 27-inch | Electronics | 5099.83 | 9.1 | 29.11 |
| 4 | Wireless Noise-Canceling Headphones | Electronics | 3749.75 | 12.1 | 33.81 |
| 5 | Sonic Electric Toothbrush with UV Sanitizer | Beauty | 3239.0 | 15.2 | 37.88 |
| 6 | Cast Iron Dutch Oven 6-Quart | Home & Kitchen | 3026.0 | 18.2 | 41.67 |
| 7 | Luxury Bamboo Queen Sheet Set | Home & Kitchen | 2970.0 | 21.2 | 45.4 |
| 8 | Adjustable Neoprene Dumbbell Set (Pair) | Sports | 2890.0 | 24.2 | 49.02 |
| 9 | Slim-Fit Stretch Denim Jeans | Apparel | 2856.0 | 27.3 | 52.61 |
| 10 | Smart Home Hub Speaker | Electronics | 2719.66 | 30.3 | 56.02 |

*(Showing top 10 of 33 rows)*

## 07_root_cause_investigation.sql: Root-Cause Friction Analysis

### Query 1
| device_type | traffic_source | user_status | total_sessions | cart_sessions | checkout_sessions | purchased_sessions | visit_to_cart_rate_pct | cart_abandonment_pct | checkout_abandonment_pct | overall_conversion_rate_pct |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Desktop | Affiliate | Guest / Anonymous | 169 | 15 | 1 | 0 | 8.88 | 93.33 | 100.0 | 0.0 |
| Desktop | Direct | Guest / Anonymous | 699 | 112 | 24 | 0 | 16.02 | 78.57 | 100.0 | 0.0 |
| Desktop | Email | Guest / Anonymous | 375 | 66 | 12 | 0 | 17.6 | 81.82 | 100.0 | 0.0 |
| Desktop | Organic Search | Guest / Anonymous | 1049 | 158 | 28 | 0 | 15.06 | 82.28 | 100.0 | 0.0 |
| Desktop | Paid Search | Guest / Anonymous | 802 | 104 | 15 | 0 | 12.97 | 85.58 | 100.0 | 0.0 |
| Desktop | Paid Social | Guest / Anonymous | 715 | 74 | 13 | 0 | 10.35 | 82.43 | 100.0 | 0.0 |
| Mobile | Affiliate | Guest / Anonymous | 282 | 37 | 4 | 0 | 13.12 | 89.19 | 100.0 | 0.0 |
| Mobile | Direct | Guest / Anonymous | 1145 | 149 | 25 | 0 | 13.01 | 83.22 | 100.0 | 0.0 |
| Mobile | Email | Guest / Anonymous | 679 | 108 | 23 | 0 | 15.91 | 78.7 | 100.0 | 0.0 |
| Mobile | Organic Search | Guest / Anonymous | 1873 | 221 | 26 | 0 | 11.8 | 88.24 | 100.0 | 0.0 |

*(Showing top 10 of 43 rows)*

### Query 2
| device_type | latency_tier | sessions_evaluated | converted_sessions | conversion_rate_pct |
| --- | --- | --- | --- | --- |
| Desktop | 1. Fast (< 1.5s) | 3812 | 568 | 14.9 |
| Desktop | 2. Moderate (1.5s - 2.5s) | 1438 | 254 | 17.66 |
| Desktop | 3. Slow (2.5s - 4.0s) | 387 | 68 | 17.57 |
| Desktop | 4. Critical Latency (> 4.0s) | 36 | 4 | 11.11 |
| Mobile | 1. Fast (< 1.5s) | 1589 | 173 | 10.89 |
| Mobile | 2. Moderate (1.5s - 2.5s) | 2708 | 284 | 10.49 |
| Mobile | 3. Slow (2.5s - 4.0s) | 2435 | 220 | 9.03 |
| Mobile | 4. Critical Latency (> 4.0s) | 845 | 89 | 10.53 |
| Tablet | 1. Fast (< 1.5s) | 310 | 21 | 6.77 |
| Tablet | 2. Moderate (1.5s - 2.5s) | 246 | 17 | 6.91 |

*(Showing top 10 of 12 rows)*

### Query 3
| payment_method | total_payment_attempts | successful_payments | failed_payments | failure_rate_pct | estimated_lost_gmv_usd | reported_error_codes |
| --- | --- | --- | --- | --- | --- | --- |
| Buy Now Pay Later | 58 | 51 | 7 | 12.07 | 405.98 | CREDIT_THRESHOLD_EXCEEDED |
| Debit Card | 185 | 173 | 12 | 6.49 | 984.96 | DECLINED_BY_ISSUER |
| PayPal | 173 | 163 | 10 | 5.78 | 740.97 | DECLINED_BY_ISSUER |
| Apple Pay | 93 | 90 | 3 | 3.23 | 316.0 | DECLINED_BY_ISSUER |
| Credit Card | 391 | 380 | 11 | 2.81 | 775.99 | DECLINED_BY_ISSUER |

### Query 4
| shipping_policy_tier | total_orders | avg_subtotal_usd | avg_shipping_fee_paid | total_shipping_revenue | total_gmv |
| --- | --- | --- | --- | --- | --- |
| Free Shipping Tier ($75+) | 369 | 159.18 | 0.0 | 0.0 | 62693.48 |
| Paid Shipping Tier (< $75) | 488 | 42.97 | 7.99 | 3899.12 | 26309.59 |

## 08_ab_test_checkout_experiment.sql: A/B Testing Experimentation

### Query 1
| variant | total_sample_size | conversions | conversion_rate_pct | absolute_difference_pp | relative_uplift_pct | avg_checkout_duration_sec | total_errors_encountered | guardrail_error_rate_pct |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Treatment | 723 | 447 | 61.83 | 4.33 | 7.53 | 49.7 | 50 | 6.92 |
| Control | 713 | 410 | 57.5 | 0.0 | 0.0 | 66.3 | 37 | 5.19 |

### Query 2
| device | variant | participants | conversions | conversion_rate_pct | avg_duration_sec | error_rate_pct |
| --- | --- | --- | --- | --- | --- | --- |
| Desktop | Control | 349 | 220 | 63.04 | 68.7 | 2.58 |
| Desktop | Treatment | 337 | 227 | 67.36 | 49.9 | 5.34 |
| Mobile | Control | 335 | 176 | 52.54 | 63.8 | 8.36 |
| Mobile | Treatment | 358 | 207 | 57.82 | 49.2 | 8.94 |
| Tablet | Control | 29 | 14 | 48.28 | 65.6 | 0.0 |
| Tablet | Treatment | 28 | 13 | 46.43 | 52.5 | 0.0 |

### Query 3
| variant | observed_count | observed_ratio_pct | expected_ratio_pct | srm_status |
| --- | --- | --- | --- | --- |
| Control | 713 | 49.65 | 50.0 | SRM CHECK PASS (Balanced Allocation) |
| Treatment | 723 | 50.35 | 50.0 | SRM CHECK PASS (Balanced Allocation) |
