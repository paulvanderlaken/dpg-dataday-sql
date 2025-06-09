## ex30: Identify Top 0.1% Revenue Orders

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 5 / 10

### Business context
As part of your audit pipeline, you're now asked to focus on the **orders** that contributed the most to company revenue. Finance leadership wants to isolate the **top 0.1%** of orders by **net revenue after discount**. These elite transactions may warrant special reporting, controls, or individual review.

Your task is to:
- Calculate total revenue per order
- Identify the **99.9th percentile** revenue cutoff
- Label all qualifying orders with a clear tag
- Store results in your audit schema

This final check will help close out the initial audit pass by highlighting the largest contributors to company revenue — and ensuring none are overlooked for risk or reporting.

**Business logic & definitions:**
* Net revenue per line item: `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* Total order revenue: sum of all line items per `L_ORDERKEY`
* Top 0.1% = any order **above the 99.9th percentile**
* Output: `WORKSHOP_DB.TEMP_SCHEMA.top_orders_by_revenue`

### Starter query
```sql
-- Preview order-level revenue details
SELECT
    l.L_ORDERKEY,
    l.L_EXTENDEDPRICE,
    l.L_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

This is a **percentile-based outlier filter**.

Steps:
1. Aggregate revenue by order (`GROUP BY L_ORDERKEY`)
2. Use `PERCENTILE_CONT(0.999)` to compute the 99.9th percentile
3. Filter for orders exceeding that value
4. Add a literal column (e.g., `'top_0.1_percent'`) to label the flagged group
5. Store result in your audit schema

#### Helpful SQL concepts

`WITH`, `GROUP BY`, `SUM`, `PERCENTILE_CONT`, `literal column`

```sql
PERCENTILE_CONT(0.999) WITHIN GROUP (ORDER BY total_net_revenue)
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
-- Step 1: Calculate and store the top 0.1% orders by net revenue
CREATE OR REPLACE TABLE WORKSHOP_DB.TEMP_SCHEMA.top_orders_by_revenue AS
WITH order_revenue AS (
  SELECT
    L_ORDERKEY,
    SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS total_net_revenue
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
  GROUP BY L_ORDERKEY
),
cutoff AS (
  SELECT
    PERCENTILE_CONT(0.999) WITHIN GROUP (ORDER BY total_net_revenue) AS threshold
  FROM order_revenue
)
SELECT
  o.L_ORDERKEY,
  o.total_net_revenue,
  'top_0.1_percent' AS revenue_flag
FROM order_revenue o, cutoff
WHERE o.total_net_revenue > cutoff.threshold;
```

```sql
-- Step 2: Review results
SELECT * FROM WORKSHOP_DB.TEMP_SCHEMA.top_orders_by_revenue
ORDER BY total_net_revenue DESC;
```

#### Why this works

This query layers aggregation, statistical thresholding, and labeling to isolate **the most impactful orders**. It’s a classic data audit pattern: flag the tail of a distribution and track it separately.

#### Business answer

You’ve identified the **top 0.1% of orders by revenue**. These transactions may reflect strategic accounts or high-value deals that warrant more attention from finance, risk, or leadership teams.

#### Take-aways

* Percentile-based filters help surface statistically extreme values
* Literal columns (`'top_0.1_percent'`) make downstream labeling consistent
* Persisting these segments enables future reconciliation or control processes
* This is a key step in pipeline-based risk scoring and revenue analysis

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Create a second table, `WORKSHOP_DB.TEMP_SCHEMA.bottom_orders_by_revenue`, with the **bottom 0.1% of orders** by revenue.

Then use a `UNION ALL` to combine the top and bottom extremes into a single table with a `revenue_flag` column:
- `'top_0.1_percent'`
- `'bottom_0.1_percent'`

This full-spectrum output will help stakeholders evaluate variance and investigate potential pricing leakage or missed opportunities.

</details>
