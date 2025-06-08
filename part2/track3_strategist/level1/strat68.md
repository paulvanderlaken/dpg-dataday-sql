## ex68: Monthly Revenue Trend by Category

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 3 / 10

### Business context
To support better strategic planning and visual dashboarding, your team is preparing a **monthly revenue trend** broken down by a categorical attribute. For this analysis, we want to look at **monthly revenue per customer market segment**.

This will help stakeholders understand which segments are growing, stabilizing, or declining over time.

**Business logic & definitions:**
* Monthly revenue: sum of `L_EXTENDEDPRICE * (1 - L_DISCOUNT)` per month
* Order month: extracted from `ORDERS.O_ORDERDATE` via `DATE_TRUNC('MONTH', …)`

### Starter query
```sql
-- Explore how to bucket orders by month and link segments
SELECT
    C.C_MKTSEGMENT,
    DATE_TRUNC('MONTH', O.O_ORDERDATE) AS ORDER_MONTH,
    L.L_EXTENDEDPRICE,
    L.L_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
  ON O.O_ORDERKEY = L.L_ORDERKEY
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

1. Extract the **month** from each order date using `DATE_TRUNC('MONTH', O_ORDERDATE)`
2. Join `CUSTOMER → ORDERS → LINEITEM`
3. Group by both **month** and **market segment**
4. Calculate revenue per group using `SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))`

This will give a clean time series suitable for line or bar chart visualizations.

#### Helpful SQL concepts

`JOIN`, `DATE_TRUNC`, `GROUP BY`, `SUM`

```sql
SELECT group1, group2, SUM(expr)
FROM …
GROUP BY group1, group2;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
SELECT
    C.C_MKTSEGMENT AS SEGMENT,
    DATE_TRUNC('MONTH', O.O_ORDERDATE) AS ORDER_MONTH,
    SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS MONTHLY_REVENUE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
  ON O.O_ORDERKEY = L.L_ORDERKEY
GROUP BY
    C.C_MKTSEGMENT,
    DATE_TRUNC('MONTH', O.O_ORDERDATE)
ORDER BY
    ORDER_MONTH,
    SEGMENT;
```

#### Why this works

The query joins the relevant tables, buckets order dates by month, and aggregates revenue at the intersection of segment and time. This gives a clean 2D view — perfect for a time series breakdown per group.

#### Business answer

This output shows how each customer segment contributes to monthly revenue trends — a key input for strategic planning and budgeting.

#### Take-aways

* Time bucketing with `DATE_TRUNC()` is essential for temporal trend analysis.
* Combining time with segment/grouping gives a flexible structure for visualization.
* Sorting both by date and group enhances readability.
* This pattern generalizes to any other categorical grouping (e.g., supplier region, product size).

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Can you extend this query to calculate the **month-over-month % change** in revenue for each segment?

Hint: Use a window function like `LAG()` and compare current vs previous month's revenue.

</details>
