## ex55: Use DECLARE and BEGIN…END to Create Dynamic Threshold Logic

> **Type:** Stretch | **Track:** Query Optimizer  
>
> **Difficulty:** 7 / 10

### Business context
The compliance team routinely audits unusually large orders — but the manual SQL workflow they use is cumbersome and rigid. It involves calculating the **99th percentile** of order-level revenue in a common table expression, then filtering based on that value.

Now that more of these checks are being automated, your team is exploring **procedural SQL logic** to structure and modularize threshold logic for reuse in audits, dashboards, and alerts.

Here's a quick starter on [Procedural SQL](https://www.geeksforgeeks.org/plsql-introduction/) for those new to it.

**Business logic & definitions:**
* Revenue per order = sum of `L_EXTENDEDPRICE * (1 - L_DISCOUNT)` grouped by `L_ORDERKEY`
* High revenue threshold = 99th percentile of order revenue across all data
* Procedural SQL logic: use **`DECLARE`, `SET`, and `BEGIN...END`** so the threshold becomes dynamical and reuseable

### Query to optimise

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

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

You’re being asked to **modularize and generalize** the logic. That means:

1. Use `DECLARE` to define a variable that holds the threshold.
2. Use `SET` to assign the 99th percentile revenue to that variable.
3. Use that variable in a second statement to filter and return the matching orders.
4. Wrap the logic in `BEGIN … END`.

This makes the script **more reusable and parameterizable**, and allows for future branching.

#### Helpful SQL concepts

`DECLARE`, `BEGIN…END`, `SET`, `FLOAT`, `PERCENTILE_CONT`, `GROUP BY`

```sql
DECLARE rev_cutoff FLOAT;
BEGIN
  SET rev_cutoff = (SELECT …);
  SELECT … WHERE revenue > rev_cutoff;
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

#### Why this works

This version refactors the set-based percentile logic into a **procedural control block**, allowing the threshold value to be assigned once and reused in multiple operations or control paths. It increases flexibility, readability, and maintainability for audit logic.

That said, **performance is slightly worse** than the pure CTE version — because query optimization and planner access may be more limited. Use this pattern when you need scripting structure, not just efficiency.

#### Business answer

The result is a dynamic list of **the top 1% of revenue-generating orders**, defined automatically from the dataset. This removes guesswork and manual filtering when flagging high-impact transactions.

#### Take-aways

* `DECLARE` + `BEGIN...END` adds structure to your SQL logic — ideal for audit routines or stored procedures.
* **Use it when you want modular, reusable scripts**, or need variables to persist across multiple blocks.
* But for pure performance and optimization, **a set-based query using CTEs is usually faster**.
* Know when you need control-flow logic, and when a clean SELECT is better.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Modify the script to:
- Accept a **parameterized percentile value** (e.g. `0.97` instead of `0.99`)
- Return the **count of orders** above threshold rather than their keys

Can you generalize this to support both modes using an `IF` block?

</details>
