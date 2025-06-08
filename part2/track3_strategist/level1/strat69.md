## ex69: Identify Top 10 Revenue-Generating Products

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 4 / 10

### Business context
As part of the ongoing **Momentum Matters** initiative, the strategy team now wants to shift focus from customer segments to **individual product performance**. They suspect that a few high-performing parts may account for a substantial share of TPCH’s total revenue.

Your task is to identify the **top 10 parts by total net revenue** and calculate their **contribution share** — i.e., what percentage of total company revenue they represent. This will help the executive team understand whether TPCH’s portfolio is broadly balanced, or overly reliant on a small set of products.

**Business logic & definitions:**
* net revenue = `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* part name = `P_NAME` (from `PART`)
* revenue share = part revenue ÷ total revenue (across all parts)

### Starter query
```sql
-- Preview part names and prices for joined order lines
SELECT
    L.L_PARTKEY,
    P.P_NAME,
    L.L_EXTENDEDPRICE,
    L.L_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
  ON L.L_PARTKEY = P.P_PARTKEY
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Start by computing net revenue per part using a `JOIN` and `GROUP BY`. Then calculate the total revenue across all parts using a **window function** without partitioning. Finally, compute the **percent-of-total** metric.

#### Helpful SQL concepts

`JOIN`, `GROUP BY`, `SUM()`, `OVER ()`

```sql
SELECT
  category,
  SUM(metric) / SUM(SUM(metric)) OVER () AS share
FROM …
GROUP BY category;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
SELECT
    P.P_NAME AS part_name,
    SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS net_revenue,
    SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) / 
        SUM(SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT))) OVER () AS pct_of_total_revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
  ON L.L_PARTKEY = P.P_PARTKEY
GROUP BY P.P_NAME
ORDER BY net_revenue DESC
LIMIT 10;
```

<details>
<summary>Alternative query using CTE</summary>

This version separates revenue calculation and overall total using a `CROSS JOIN`. Slightly more readable, but marginally less performant on large data.

```sql
WITH part_revenue AS (
  SELECT
    P.P_NAME AS part_name,
    SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS net_revenue
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
    ON L.L_PARTKEY = P.P_PARTKEY
  GROUP BY P.P_NAME
),
total_revenue AS (
  SELECT SUM(net_revenue) AS total FROM part_revenue
)
SELECT
  pr.part_name,
  pr.net_revenue,
  pr.net_revenue / tr.total AS pct_of_total_revenue
FROM part_revenue pr
CROSS JOIN total_revenue tr
ORDER BY pr.net_revenue DESC
LIMIT 10;
```
</details>

#### Why this works

The query calculates per-part net revenue, and uses a **window function without partition** to compute the overall revenue total. This avoids subqueries and gives a **percent-of-total** metric in a single step.

#### Business answer

The top 10 products contribute a surprisingly small percentage of overall revenue — suggesting that TPCH has a **diversified portfolio** with no overexposure to a single product line. This is a healthy baseline, but further investigation may reveal if margins tell a different story.

#### Take-aways

* Window functions like `SUM(...) OVER ()` are ideal for full-table comparisons.
* Percent-of-total metrics help contextualize raw figures for strategic insights.
* You can compute contribution shares inline without needing nested queries.
* A balanced top 10 may look healthy — but profitability might still vary sharply.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a column that shows the **cumulative revenue share** (running total ordered by descending revenue).  
Which products together cover 25% of total revenue? How many are needed to reach 50%?

</details>
