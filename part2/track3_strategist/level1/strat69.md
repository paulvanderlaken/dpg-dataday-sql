## ex69: Identify Top 10 Revenue-Generating Products

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 4 / 10

### Business context
To better understand where our revenue comes from, product managers want to know **which items generate the most net revenue**. A few high-performing parts might drive a large share of total business — uncovering these will help focus future marketing, inventory, and supply efforts.

Your task is to produce a ranked list of the **top 10 parts by total net revenue**. In addition to showing the raw revenue values, you should also compute **what share of total revenue** each part contributes — helping the business assess product concentration risk.

**Business logic & definitions:**
* net revenue = `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* part name = `P_NAME` (from `PART`)
* revenue share = part revenue ÷ total revenue (of whole portfolio!)

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

Start by calculating total net revenue per part. Then compute **total revenue across all parts** using a window function with no partition. Use this to calculate the proportion for each part.

#### Helpful SQL concepts

`JOIN`, `GROUP BY`, `SUM()`, window `SUM() OVER ()`

```sql
SELECT
  category,
  SUM(metric) AS total,
  SUM(metric) / SUM(SUM(metric)) OVER () AS pct_of_total
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

A CTE is often considered more readable and modular, however, in this case, it would be slightly less performant.

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

This query first calculates net revenue per part, then uses a **window function without partitioning** to compute the total net revenue across all parts. Each row’s contribution is expressed as a percentage of that total — allowing clear visibility into product concentration.

#### Business answer

The top 10 parts do not account for significant portions of the total revenue, with limited differentiation in the top 10. 

#### Take-aways

* Window functions can compute totals across the whole dataset for % calculations.
* Revenue share helps contextualize raw dollar values in business decision-making.
* `OVER ()` is a powerful SQL feature for dataset-wide metrics without subqueries.
* Top-N queries can and should go beyond just listing — they can explain contribution.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Calculate the **cumulative revenue share** (running total of `pct_of_total_revenue`) ordered by descending revenue. What % of total revenue is covered by the top 3 products? The top 5?

</details>
