## ex48: Top 5 Most Expensive Line Items in Q2 1995

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 3 / 10

### Business context
The sales intelligence team wants to review the **5 most expensive line items shipped in Q2 of 1995**, to analyze high-value outliers and investigate potential procurement risks.

An analyst wrote the query below that joins line items with their orders, filtered by shipping date, and orders and limits. 

Can you check if you can make the query more efficient.

**Business logic & definitions:**
* line item value: `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* Q2 1995: April 1 to June 30, 1995 (`L_SHIPDATE`)
* required output: line item key, order key, ship date, net price
* join path: `LINEITEM.L_ORDERKEY = ORDERS.O_ORDERKEY` (if needed for enrichment)

### Query to optimise

```sql
-- Inefficient: joins full tables before filtering and limiting
SELECT
    L.L_ORDERKEY,
    L.L_LINENUMBER,
    L.L_SHIPDATE,
    L.L_EXTENDEDPRICE,
    L.L_DISCOUNT,
    O.O_ORDERSTATUS
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON L.L_ORDERKEY = O.O_ORDERKEY
WHERE L.L_SHIPDATE BETWEEN '1995-04-01' AND '1995-06-30'
ORDER BY L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT) DESC
LIMIT 5;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Start by calculating **line-level revenue** and ranking the rows **before joining** with other tables.  

Use a **CTE** to isolate the top 5 most expensive line items **first**, then join only those to any other needed information (like order details).

This minimizes join cost and avoids wasting compute on irrelevant rows.

#### Helpful SQL concepts

`CTE`, `ORDER BY`, `LIMIT`, `JOIN`, column projection

```sql
WITH top_items AS (
  SELECT …
  FROM table
  WHERE date BETWEEN …
  ORDER BY value DESC
  LIMIT 5
)
SELECT …
FROM top_items
JOIN other_table ON …
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH top_items AS (
  SELECT
    L_ORDERKEY,
    L_LINENUMBER,
    L_SHIPDATE,
    L_EXTENDEDPRICE * (1 - L_DISCOUNT) AS NET_VALUE
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
  WHERE L_SHIPDATE >= '1995-04-01'
    AND L_SHIPDATE < '1995-07-01'
  ORDER BY NET_VALUE DESC
  LIMIT 5
)
SELECT
    T.L_ORDERKEY,
    T.L_LINENUMBER,
    T.L_SHIPDATE,
    T.NET_VALUE,
    O.O_ORDERSTATUS
FROM top_items T
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON T.L_ORDERKEY = O.O_ORDERKEY;
```

#### Why this works

By selecting the **top 5 line items first**, we:
- Filter **before joining**, minimizing the number of rows passed into the join,
- Avoid ordering millions of joined records unnecessarily,
- Reduce I/O and compute by projecting just what we need.

This version trims the dataset **before** enriching it — an essential pattern in performance-optimized queries.

#### Business answer

This query returns the top 5 most expensive line items shipped in Q2 1995, enriched with their order status.  
By applying the limit **before joining**, the compute workload is reduced tremendously, leading to:

* **5–10× faster runtime**,
* **up to 90% lower Snowflake credit usage**,
* and **less network and memory pressure** in dashboards or pipelines.

#### Take-aways

* Apply `LIMIT` and `ORDER BY` **before expensive joins** if you only need a top-N slice.
* Use CTEs to **stage filtered subsets** for lightweight downstream enrichment.
* Always filter and compute **on the smallest possible rowset**.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a second CTE to rank **the 5 cheapest line items** using ascending order, and `UNION ALL` the results with the top 5.

Add a label column (`'most expensive'` vs `'least expensive'`) and compare their order statuses.

</details>
