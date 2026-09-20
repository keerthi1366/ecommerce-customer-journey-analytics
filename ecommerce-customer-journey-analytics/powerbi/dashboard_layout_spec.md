# Power BI Dashboard Layout Specification (5-Page Suite)

> [!NOTE]
> **Data Note**: This project uses synthetically generated e-commerce data designed to reproduce realistic product behavior for portfolio and analytical demonstration purposes. No real customer data is used.
>
> **Architecture Clarification**: This document specifies the enterprise **Power BI Report Architecture** built on the Ralph Kimball Star Schema (`dim_*` and `fact_*` tables). The accompanying `powerbi/report_preview.html` file provides a lightweight, interactive HTML5/Chart.js simulation for rapid cross-functional design review and browser inspection.

---

## Global Report Standards & Visual Theme
- **Target Dimensions**: 16:9 widescreen canvas (1280 x 720 px)
- **Palette**: Dark Modern Slate (`#0B0F19`), Surface Container (`#0F172A`), Electric Indigo (`#6366F1`), Emerald Metric (`#10B981`), Amber Attention (`#F59E0B`), Coral Leak (`#EF4444`), Muted Text (`#94A3B8`)
- **Reporting Period**: Full Year 2025 (Jan 1, 2025 – Dec 31, 2025)
- **Top Filter Header (Synchronized Across All Pages)**:
  - `dim_date[full_date]` (Date Slider / Quarter Dropdown: Q1–Q4)
  - `dim_device[device_type]` (Desktop, Mobile, Tablet)
  - `dim_channel[traffic_source]` (Organic Search, Direct, Paid Search, Paid Social, Email, Affiliate)
  - `dim_product[category]` (Home & Kitchen, Electronics, Apparel, Sports, Beauty)

---

## Page 1: Executive Overview

### Purpose
Executive pulse check on portfolio health, transaction volume, top-line GMV, and device conversion disparity.

```
+---------------------------------------------------------------------------------------------------+
|  [FILTERS]: Device (All/Desktop/Mobile) | Channel | Quarter (Q1-Q4) | Category                    |
+---------------------------------------------------------------------------------------------------+
|  [KPI Card]          [KPI Card]         [KPI Card]        [KPI Card]           [KPI Card]         |
|  GMV                 Orders             Conversion %      AOV                  Active Users       |
|  $89,003             857                2.68%             $103.85              8,769              |
|  ($79.7K Net)        (832 Buyers)       (Desktop 3.95%)   ($159.2 Free Ship)   (32,000 Sessions)  |
+---------------------------------------------------------------------------------------------------+
| [Line Chart: Monthly GMV Trajectory]               | [Bar Chart: Conversion Rate by Device]       |
| X: dim_date[month_year] (Jan - Dec 2025)           | Y: dim_device[device_type]                   |
| Y: [Total Gross Revenue]                           | X: [Overall Conversion Rate %]               |
+----------------------------------------------------+----------------------------------------------+
| [Table: Funnel Milestone Summary]                  | [Panel: Structured Key Observations]         |
| Stage | Sessions | Reach % | Drop-off %            | • OBSERVED PATTERN: Mobile 2.01% vs Desk 3.95%|
| 1. Visit: 32,000 (100%)                            | • INVESTIGATION: Analyze stage drop-off      |
| 2. Product View: 13,841 (43.3%)                    | • HYPOTHESIS: Form complexity & latency      |
| 3. Add to Cart: 4,823 (15.1%)                      |   are potential contributors to investigate. |
| 4. Order: 857 (2.7%)                               |   (No unverified causal claim).              |
+---------------------------------------------------------------------------------------------------+
```

### Key Field Mappings:
- **GMV**: `SUM(fact_orders[total_amount])` -> `$89,003.07`
- **Orders**: `DISTINCTCOUNT(fact_orders[order_id])` -> `857`
- **Conversion %**: `DIVIDE([Total Orders], [Total Sessions], 0) * 100` -> `2.68%`
- **AOV**: `DIVIDE([Total Gross Revenue], [Total Orders], 0)` -> `$103.85`
- **Active Users**: `DISTINCTCOUNT(fact_sessions[user_key])` -> `8,769`

---

## Page 2: Customer Journey & Funnel Analysis

### Purpose
Answer the core product analytics question: *"Where are users dropping out of the product journey?"*

```
+---------------------------------------------------------------------------------------------------+
| [Funnel Visual: 7-Stage Customer Journey]          | [Bar Chart: Stage Drop-off %]                |
| 1. Visit (32,000)                                  | • View -> Cart: 65.15% drop-off (Leak 1)     |
| 2. Browse/Search (20,376)                          | • Cart -> Checkout: 70.23% drop-off (Leak 2) |
| 3. Product View (13,841)                           | • Checkout -> Pay: 37.33% drop-off (Leak 3)  |
| 4. Add to Cart (4,823)                             | • Payment -> Order: 4.78% drop-off (Declines)|
| 5. Checkout Initiated (1,436)                      |                                              |
| 6. Payment Attempted (900)                         |                                              |
| 7. Purchase Completed (857)                        |                                              |
+----------------------------------------------------+----------------------------------------------+
| [Table: Complete 7-Stage SQL Conversion & Drop-off Grid]                                          |
| Stage | Sessions | Total Reach % | Drop-off Count | Stage Drop-off % | Diagnostic Status         |
+---------------------------------------------------------------------------------------------------+
| [Sub-Matrix 1: Device Funnel Breakdown]            | [Sub-Matrix 2: Channel Funnel Breakdown]     |
| Desktop: 17.2% Cart | 64.9% Abandon | 3.95% Conv   | Email: 3.89% Conv | 60.3% Abandon            |
| Mobile: 13.9% Cart | 73.8% Abandon | 2.01% Conv    | Paid Social: 1.80% Conv | 74.8% Abandon      |
+---------------------------------------------------------------------------------------------------+
```

---

## Page 3: Customer Cohorts & RFM Analytics

### Purpose
Examine customer lifetime retention, Month 0–11 purchasing decay, and RFM segment value.

```
+---------------------------------------------------------------------------------------------------+
|  [KPI Card] Buyers: 832 | [KPI Card] Repeat Rate: 2.88% | [KPI Card] At-Risk GMV: $29.6K (33.3%)   |
+---------------------------------------------------------------------------------------------------+
| [Matrix Heatmap: Monthly Cohort Retention Matrix (Month 0 to Month 11)]                           |
| Rows: dim_user[cohort_month] (2025-01 to 2025-12)                                                 |
| Columns: M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11                                         |
| Values: [Cohort Retention Rate %] (Color Scale: Slate to Emerald)                                 |
+----------------------------------------------------+----------------------------------------------+
| [Line Chart: Avg Retention Curve (%)]              | [Donut Chart: RFM Revenue Contribution %]    |
| X: Month Index (M0 - M6)                           | Legend: RFM Customer Segments                |
| Y: [Cohort Retention Rate %] (~1.0% - 1.2% steady) | Values: Total Segment Spend                  |
+----------------------------------------------------+----------------------------------------------+
| [Structured Retention Insight Panel]                                                              |
| • OBSERVATION: At-Risk customers represent 193 buyers and $29,618 in historic revenue.            |
| • POTENTIAL ACTION: Evaluate targeted win-back campaign with personalized recommendations.       |
| • SUCCESS METRIC: Reactivation rate and repeat purchase expansion from 2.88% to 5.0%.             |
+---------------------------------------------------------------------------------------------------+
```

---

## Page 4: Product & Category Merchandising Performance

### Purpose
Diagnose product-level view-to-cart versus cart-to-order dynamics and catalog concentration.

```
+---------------------------------------------------------------------------------------------------+
| [Quadrant Scatter Plot: View-to-Cart % vs Cart-to-Order %]                                        |
| X-Axis: View-to-Cart Conversion % (25% - 45%)                                                     |
| Y-Axis: Cart-to-Order Conversion % (14% - 22%)                                                     |
| Bubble Size: Total Product Revenue (USD)                                                          |
| Color: dim_product[category]                                                                      |
| Quadrants:                                                                                        |
| • Top-Right (High View / High Conv): Flagship products (Espresso Machine, Trench Coat)            |
| • Bottom-Right (High View / Low Conv): Review pricing / specs (4K Monitor, Gaming Mouse)          |
| • Top-Left (Low View / High Conv): Reallocate ad spend (Hydrating Serum, Cotton T-Shirt)          |
| • Bottom-Left (Low View / Low Conv): Low traction catalog items (Diffuser)                        |
+----------------------------------------------------+----------------------------------------------+
| [Line Chart: Pareto (80/20) Revenue Curve]         | [Table: Category Merchandising Margins]      |
| X: Cumulative Catalog % (0 - 100%)                 | Category | Views | Carts | Orders | GMV | Margin|
| Y: Cumulative Revenue % (Top 20% drives ~50-60%)   | Home & Kitchen: $24.4K (57.0% margin)        |
|                                                    | Beauty: $8.7K (68.4% gross margin)           |
+---------------------------------------------------------------------------------------------------+
```

---

## Page 5: Root-Cause Investigation & Experimentation

### Purpose
Investigate operational friction drivers and present the simulated A/B testing checkout evaluation.

```
+---------------------------------------------------------------------------------------------------+
| [STRUCTURED PRODUCT ANALYTICS INSIGHT PANEL]                                                      |
| OBSERVED PATTERN -> ROOT-CAUSE INVESTIGATION -> HYPOTHESIS -> RECOMMENDATION -> SUCCESS METRIC    |
+----------------------------------------------------+----------------------------------------------+
| [Bar Chart: Page Latency vs Conversion %]          | [Bar Chart: Payment Failure Rate %]          |
| Tiers: <1.5s (Fast), 1.5-2.5s, 2.5-4s, >4s (Crit)  | BNPL: 12.07% fail rate ($405 lost GMV)       |
| Shows step decline at >4.0s critical threshold     | Cards: 2.81% fail rate                       |
+----------------------------------------------------+----------------------------------------------+
| [SIMULATED PRODUCT EXPERIMENT SCORECARD: EXP-CHK-2025-Q3]                                         |
| Control (Multi-Step): 57.50% (713 users) | Treatment (1-Step): 61.83% (723 users)                 |
| Uplift: +4.33 pp (+7.53% relative) | Z = 1.67, p = 0.0950 | SRM Check: PASS (p = 0.7919)          |
| Speed: -16.6s checkout duration | Mobile Lift: +5.28 pp (52.54% -> 57.82%)                       |
| Analytical Conclusion: Directionally positive; requires extended testing for alpha=0.05 validation|
+---------------------------------------------------------------------------------------------------+
```
