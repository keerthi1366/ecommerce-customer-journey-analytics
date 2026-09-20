# Technical & Product Analytics Interview Preparation Guide

This guide compiles **15 advanced interview questions and model answers** directly drawn from this project, tailored for **Data Analyst, Product Analyst, Analytics Engineer, and BI Engineer** interviews at top-tier tech companies and e-commerce leaders.

---

## Section 1: SQL & Analytics Engineering

### Q1: How do you build a multi-stage funnel in SQL, and what is the difference between session-level and user-level funnels?
**Answer**:
A multi-stage funnel can be constructed using Common Table Expressions (CTEs) combined with conditional aggregation (`MAX(CASE WHEN ... THEN 1 ELSE 0 END)`) or sequential self-joins:
1. In a **session-level funnel**, each stage must occur within the boundaries of a single session. This measures immediate conversion intent and UX efficiency (e.g. checkout friction).
2. In a **user-level funnel**, stages can span across multiple sessions over weeks or months. This measures overall customer lifecycle conversion (e.g. onboarding or long-consideration cycles).

For e-commerce checkout analysis, a session-level funnel is strictly preferred because abandoned carts that result in checkout attempts days later represent distinct intent states with differing external drivers (e.g. email retargeting).

---

### Q2: How did you compute the Monthly Customer Cohort Retention Matrix in SQL?
**Answer**:
We use a three-step CTE pipeline:
1. **Define Cohorts**: Derive each user's acquisition cohort month using `DATE_FORMAT(signup_date, '%Y-%m')`.
2. **Calculate Activity Months**: Join orders to users and calculate the integer month delta between signup date and order timestamp using `TIMESTAMPDIFF(MONTH, u.signup_date, o.order_timestamp)`.
3. **Pivot & Normalize**: Aggregate distinct active purchasing users per cohort month, and use conditional aggregation (`MAX(CASE WHEN month_number = 1 THEN active_users END)`) divided by initial cohort size (`COUNT(DISTINCT user_id)`) to compute Month 0 through Month 11 retention percentages.

---

### Q3: Why use `NTILE(5)` over manual thresholding for RFM segmentation, and what are its trade-offs?
**Answer**:
- **Advantage of `NTILE(5)`**: It divides the distribution of customers into 5 equal-sized buckets (quintiles) dynamically, ensuring balanced segment volumes regardless of underlying variance in spend or order volume.
- **Trade-off / Limitation**: If customer behavior is heavily skewed (e.g. 90% of customers have exactly 1 order), `NTILE` will force identical frequency values into different scoring tiers (e.g. some 1-order customers get score 1, others get score 2). To mitigate this in production, we combine `NTILE` for Recency and Monetary spend with discrete bucket thresholds for Frequency.

---

### Q4: How do you optimize large clickstream queries joining millions of events to sessions?
**Answer**:
1. **Partitioning & Clustering**: Partition `funnel_events` by date (`event_timestamp`) to allow partition pruning.
2. **Composite Indexing**: Create composite indexes on `(session_id, event_name, event_timestamp)` so funnel flag aggregations can be resolved purely via Index-Only Scans.
3. **Pre-aggregation**: Roll up clickstream events into an hourly or daily session summary table (`fact_sessions`) during the nightly ETL/ELT batch rather than scanning raw events on every dashboard query.

---

## Section 2: Power BI, Star Schema & DAX

### Q5: Why did you design a Star Schema instead of importing flat tables or a Snowflake schema?
**Answer**:
A Kimball Star Schema with explicit 1-to-many relationships provides three crucial benefits in Power BI:
1. **VertiPaq Engine Optimization**: The columnar in-memory database compresses narrow, high-cardinality dimension tables and integer foreign keys far more efficiently than wide denormalized flat tables.
2. **Simplified DAX Context**: Measures evaluate predictably without unexpected row context transfers or expensive cross-table filtering.
3. **No Bi-Directional Ambiguity**: Unlike snowflake schemas or multi-fact flat joins, a star schema avoids ambiguous filter paths and synthetic bridge tables, preventing inaccurate totals and circular dependency crashes.

---

### Q6: Explain the difference between `DIVIDE(A, B, 0)` and `A / B` in DAX.
**Answer**:
The standard `/` operator performs mathematical division and returns `NaN` or `Infinity` if the denominator `B` is zero, which breaks visuals, card KPIs, and conditional formatting.  
`DIVIDE(A, B, [alternateResult])` includes built-in divide-by-zero intercept logic, safely returning `BLANK()` or an explicit fallback value (like `0`) whenever the denominator is zero or `BLANK`, ensuring enterprise dashboard stability.

---

### Q7: How do you handle multiple date contexts (e.g. Session Date vs Order Date) in Power BI without creating circular relationships?
**Answer**:
We use **Role-Playing Dimensions** or **Inactive Relationships**:
1. Keep one active relationship between `dim_date[date_key]` and `fact_orders[date_key]`.
2. Connect `dim_date[date_key]` to `fact_sessions[date_key]` or `dim_user[signup_date]` using inactive relationships.
3. In DAX measures requiring the secondary time slice, activate the inactive relationship dynamically using `USERELATIONSHIP(dim_date[date_key], fact_sessions[date_key])` inside `CALCULATE`.

---

## Section 3: A/B Testing & Statistical Experimentation

### Q8: What is Sample Ratio Mismatch (SRM), how do you detect it, and why does it invalidate an A/B test?
**Answer**:
**Sample Ratio Mismatch (SRM)** occurs when the observed allocation of traffic between variants differs significantly from the expected randomization ratio (e.g. allocating 50/50 but observing 55/45).  
- **Detection**: We run a **Chi-Square Goodness-of-Fit test** comparing observed variant counts against expected counts. If $p < 0.01$, an SRM is flagged.
- **Why it invalidates results**: An SRM proves that the assignment mechanism was biased or that systematic attrition occurred before variant exposure (e.g. users on slower devices crashing before assignment). Any measured conversion lift could simply reflect selection bias rather than true feature impact. In our experiment `EXP-CHK-2025-Q3`, the Chi-Square statistic was $0.0696$ ($p = 0.7919$), proving clean, unbiased randomization.

---

### Q9: In your checkout experiment, the relative lift was +7.53%, but the p-value was 0.095. Would you ship the feature?
**Answer**:
This is a classic Product Analytics decision requiring balancing statistical rigor with business context:
1. At the conventional scientific threshold ($\alpha = 0.05$), $p = 0.095$ is not statistically significant, meaning there is a 9.5% probability that the observed +4.33 pp lift is random noise.
2. However, guardrail metrics confirmed that checkout duration decreased significantly (-16.6 seconds) and the mobile lift was especially pronounced (+5.28 pp), with zero evidence of Sample Ratio Mismatch or AOV degradation.
3. **Decision**: I would **not ship immediately to 100%**, nor would I kill the experiment. I would recommend extending the test for 7 additional days to collect ~500 more checkout sessions. If the lift holds at N=2,000, the p-value will drop well below 0.05, giving leadership full statistical confidence to roll out globally.

---

### Q10: What is the "peeking problem" in A/B testing, and how do you prevent it?
**Answer**:
The peeking problem occurs when an analyst continuously checks the p-value of an experiment as data flows in and stops the test the moment $p < 0.05$. Because p-values fluctuate randomly over time, repeatedly testing increases the **False Positive Rate (Type I error)** from the nominal 5% to over 30%.  
- **Prevention**: Pre-determine the required sample size and test duration via Power Analysis *before* launch, and only evaluate statistical significance once the target sample size is reached, or adopt **Sequential Testing frameworks** (e.g. mSPRT) that adjust alpha boundaries dynamically.

---

## Section 4: Product Analytics & Root-Cause Investigation

### Q11: How do you distinguish correlation from causation when analyzing cart abandonment?
**Answer**:
Correlation shows two variables moving together (e.g. sessions with >3,000ms latency have higher abandonment). It does not prove that latency *caused* the drop-off—low-intent users might simply browse longer and have higher page counts, inflating measured latency.  
To establish defensible causality:
1. **Control for Confounders**: Segment and cross-tabulate by device, acquisition channel, and new vs returning status.
2. **Formulate Falsifiable Hypotheses**: e.g., *"If form complexity causes mobile drop-off, a 1-step form should improve mobile completion more than desktop."*
3. **Controlled Experimentation**: Validate the hypothesis via an A/B test where only the variable of interest is manipulated while all other factors remain constant.

---

### Q12: Cart abandonment is 82.2%. How would you prioritize whether to fix checkout speed, add payment methods, or adjust shipping policies?
**Answer**:
I use an **Impact vs Effort vs Confidence (ICE)** prioritization matrix based on funnel drop-off volume:
1. **Shipping Policy (Highest Financial Impact / Lowest Code Effort)**: 70.4% of revenue comes from orders over $75 with free shipping. Adding a dynamic free-shipping progress meter in the cart requires minimal frontend code and directly addresses the 70.2% cart-to-checkout drop-off.
2. **Payment Failure Auto-recovery (Immediate Margin Win)**: BNPL has a 12.07% decline rate ($405 lost GMV). Adding an automated fallback retry modal directly salvages ready-to-buy customers.
3. **Checkout Speed / Redesign (Medium Effort / Proven Lift)**: Validated by our A/B test with a +7.53% lift, scheduled for immediate sprint rollout.

---

### Q13: If overall conversion rate drops from 3.0% to 2.4% week-over-week, walk me through your diagnostic triage framework.
**Answer**:
I apply a structured **Top-Down Funnel & Segment Decomposition**:
1. **Data Integrity Check**: Verify tracking telemetry. Did tracking tags fail? Are there duplicate sessions or logging pipeline outages?
2. **Funnel Stage Isolation**: Calculate stage-to-stage transition rates to determine where the drop occurred: Did visits drop? Did View-to-Cart drop? Or did Checkout-to-Purchase drop?
3. **Mix Shift Analysis (Simpson's Paradox)**: Check if underlying traffic composition shifted (e.g. did high-converting Desktop/Email traffic drop while low-converting Mobile/Paid Social surged due to an ad campaign?). If each segment's conversion is unchanged but the mix shifted, the aggregate drop is a mix effect.
4. **External & Technical Audits**: Inspect payment gateway logs (did a major processor experience outages?), page latency metrics (did a deployment increase bundle size?), and competitive pricing changes.

---

### Q14: What guardrail metrics do you track during an e-commerce checkout experiment?
**Answer**:
A successful conversion lift is worthless if it damages unit economics or user trust. We monitor:
1. **Average Order Value (AOV)**: Ensure the streamlined checkout does not inadvertently suppress multi-item basket building.
2. **Checkout Validation Error Rate**: Ensure autofill or condensed layouts do not trigger address rejection or API timeouts.
3. **Payment Authorization Success Rate**: Ensure faster checkout does not increase fraudulent attempts or gateway chargebacks.
4. **Customer Support Contact Rate**: Track escalations regarding unreceived order confirmations or duplicate charges.

---

### Q15: How would you present these findings to an executive vs an engineering team?
**Answer**:
- **For Executives (CCO/VP)**: Focus on the **bottom-line financial narrative**. Lead with GMV ($89.0K), the $65K-$85K unrealized revenue leakage, the +7.53% lift from the checkout experiment, and the 90-day implementation roadmap prioritizing incremental margin. Use high-level KPI cards and waterfall visuals.
- **For Engineering / Product Teams**: Focus on the **mechanics, telemetry, and exact specifications**. Provide P95 latency distributions, device form validation error logs, payment gateway error code frequencies (`CREDIT_THRESHOLD_EXCEEDED`), schema definitions, and the A/B testing statistical test outputs ($Z$-score, sample ratio diagnostics, and CI boundaries).
