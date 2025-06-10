## ex55: Use DECLARE and BEGIN…END to Create Dynamic Threshold Logic

> **Type:** Stretch | **Track:** Query Optimizer  
>
> **Difficulty:** 7 / 10

### Business context
The compliance team often investigates **orders with unusually high total revenue**. Until now, they’ve relied on analysts manually running percentile queries to determine thresholds.

You’ve been asked to automate this by building a **stored block** that:
- Calculates a **dynamic revenue threshold** based on the 99th percentile,
- Filters orders above that threshold,
- Returns their `order key`, `customer key`, and calculated total revenue.

This logic should be encapsulated using **`DECLARE`**, **`BEGIN...END`**, and **control-of-flow constructs**.

**Business logic & definitions:**
* Revenue per order = sum of `L_EXTENDEDPRICE * (1 - L_DISCOUNT)` grouped by `L_ORDERKEY`
* High revenue threshold = 99th percentile of order revenue across all data

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

You’ll need to:
1. Use a `DECLARE` block to store the dynamic threshold
2. Compute the threshold using `PERCENTILE_CONT`
3. Reference the threshold variable in a second statement that selects order-level revenue above the cutoff

Remember:
- Wrap your logic in a `BEGIN … END` block
- Use `SET` to assign query results to variables
- Variables need a data type

#### Helpful SQL concepts

`DECLARE`, `BEGIN…END`, `SET`, `FLOAT`, `PERCENTILE_CONT`, `GROUP BY`

```sql
DECLARE rev_cutoff FLOAT;
BEGIN
  SET rev_cutoff = (SELECT … FROM …);
  SELECT … FROM … WHERE revenue > rev_cutoff;
END;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query (procedural version)

```sql
DECLARE rev_cutoff FLOAT;

BEGIN
  -- Step 1: calculate threshold
  SET rev_cutoff = (
    SELECT PERCENTILE_CONT(0.99) 
    WITHIN GROUP (ORDER BY revenue)
    FROM (
      SELECT L_ORDERKEY,
             SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS revenue
      FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
      GROUP BY L_ORDERKEY
    )
  );

  -- Step 2: output high-revenue orders
  SELECT L_ORDERKEY,
         SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS order_revenue
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
  GROUP BY L_ORDERKEY
  HAVING order_revenue > rev_cutoff;
END;
```

<details>
<summary>⚡ Non-procedural (set-based) alternative</summary>

```sql
WITH revenue_per_order AS (
  SELECT L_ORDERKEY,
         SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS revenue
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
  GROUP BY L_ORDERKEY
),
threshold AS (
  SELECT PERCENTILE_CONT(0.99) 
  WITHIN GROUP (ORDER BY revenue) AS cutoff
  FROM revenue_per_order
)
SELECT o.L_ORDERKEY, o.revenue
FROM revenue_per_order o, threshold t
WHERE o.revenue > t.cutoff;
```

This version avoids procedural scripting entirely and keeps everything in a single, efficient execution plan using CTEs. It is preferred for performance-critical and ad hoc queries.

</details>

#### Why this works

The procedural version uses `DECLARE` and `SET` to separate threshold calculation from its application — which is helpful in stored logic or when the threshold is reused.  
This approach avoids manually editing the threshold in the query, improving **automation**, **safety**, and **reusability**.

However, for ad hoc queries or dashboards, the **non-procedural CTE version is more efficient**, because it stays fully set-based and can be better optimized by Snowflake's planner.

#### Business answer

The result is a dynamic list of **the top 1% highest-revenue orders** — determined from all transactions using a statistically defined cutoff. This helps compliance isolate financial outliers without hardcoding thresholds.

#### Take-aways

* `DECLARE` + `BEGIN...END` is ideal for building **modular, reusable logic**, especially in stored procedures or templated pipelines.
* But for **performance-sensitive or one-off analysis**, a CTE-based version is usually **simpler and faster**.
* Use `SET` to capture scalar values like percentiles or counts when needed across multiple query stages.
* Always weigh readability and reuse against performance — procedural logic introduces structure but may reduce planner flexibility.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Modify the script to:
- Accept a **parameterized percentile value** (e.g. `0.97` instead of `0.99`)
- Return the **count of orders** above threshold rather than their keys

Can you generalize this to support both modes using an `IF` block?

</details>
