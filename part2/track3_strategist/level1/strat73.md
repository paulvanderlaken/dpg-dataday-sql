## ex73: Year-over-Year Revenue Growth by Segment

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 7 / 10

### Business context
With months of work behind them, the Strategy Director is preparing to present a **final growth diagnosis** to TPCH’s leadership team. They need a clear answer to a simple but vital question:

> “Which customer segments are consistently growing — and which ones are falling behind?”

Your role is to provide a **trend-based summary** showing how revenue has evolved year-over-year for each customer segment. The output will shape next year's targeting priorities, marketing budgets, and hiring focus.

Importantly, you’ve already confirmed in earlier tasks that **1995 to 1997** are the only complete years in the dataset. Your analysis should stick to this range and include:
- revenue per segment per year
- percent change from the previous year (YoY % growth)

**Business logic & definitions:**
* segment = `C_MKTSEGMENT`
* net revenue = `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* order year = `YEAR(O_ORDERDATE)`
* YoY change = `(this_year - last_year) / last_year`
* analysis window = years 1995, 1996, 1997 only

> 📊 After running your query, plot the output in a line chart or grouped bar chart by segment to visualize the directional trends.

### Starter query
```sql
-- Preview how customer segments and order dates align with revenue data
SELECT
    C.C_MKTSEGMENT,
    O.O_ORDERDATE,
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

1. Join customers, orders, and line items.
2. Calculate total revenue per `C_MKTSEGMENT` per `YEAR(O_ORDERDATE)`.
3. Use `LAG()` to bring in the prior year’s value **within each segment**.
4. Calculate the YoY % change with a `ROUND(..., 2)` for readability.

#### Helpful SQL concepts

`YEAR()`, `GROUP BY`, `LAG()`, `OVER (PARTITION BY segment ORDER BY year)`

```sql
LAG(metric) OVER (PARTITION BY segment ORDER BY year)
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH segment_revenue AS (
  SELECT
    C.C_MKTSEGMENT AS segment,
    YEAR(O.O_ORDERDATE) AS order_year,
    SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS net_revenue
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
  WHERE O.O_ORDERDATE BETWEEN '1995-01-01' AND '1997-12-31'
  GROUP BY C.C_MKTSEGMENT, YEAR(O.O_ORDERDATE)
),
with_yoy AS (
  SELECT
    segment,
    order_year,
    net_revenue,
    LAG(net_revenue) OVER (PARTITION BY segment ORDER BY order_year) AS last_year_revenue
  FROM segment_revenue
)
SELECT
  segment,
  order_year,
  net_revenue,
  last_year_revenue,
  ROUND((net_revenue - last_year_revenue) / NULLIF(last_year_revenue, 0) * 100, 2) AS yoy_pct_change
FROM with_yoy
ORDER BY segment, order_year;
```

#### Why this works

This query compares each year’s revenue with the prior year for each segment. `LAG()` helps reference the previous value row-wise, and the final division computes the percent change — giving both absolute and directional growth patterns.

#### Business answer

Rather than seeing clear upward momentum, the visual reveals that **most segments either plateaued or declined** in 1997.

Segments like `FURNITURE`, which peaked in 1996, saw sharp reversals. `HOUSEHOLD` and `BUILDING` both show significant downward trends. Even the more stable `AUTOMOBILE` segment failed to grow year-over-year.

These results suggest a **broad deceleration** heading into 1997 — likely requiring a review of commercial strategies, pricing models, or customer engagement across all segments.

#### Take-aways

* Use `LAG()` to compare across time periods within categories.
* `NULLIF(..., 0)` avoids divide-by-zero errors in YoY calculations.
* Trend metrics are strongest when paired with context and baseline values.
* Clear structure helps translate time series data into confident strategy.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Create a wide-format version of this output:
- One row per segment
- Columns: revenue_1995, revenue_1996, revenue_1997, yoy_1996, yoy_1997

Then highlight which segments had **positive growth** in both years.

</details>
