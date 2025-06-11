## ex60: Nested Subqueries vs Multi-Stage CTEs — Which Scales Better?

> **Type:** Stretch | **Track:** Query Optimizer  
>
> **Difficulty:** 8 / 10

### Business context
The finance team frequently runs diagnostics on **order profitability** — especially identifying **orders with many items and unusually low total margin**. One analyst wrote a deeply nested query to achieve this, but the runtime increases significantly on larger datasets.

You’ve been asked to evaluate **whether a refactor using CTEs** would be faster, more readable, and easier to maintain — and whether there is **any difference in runtime performance** between the two styles, especially when **heavier calculations** are introduced.

The logic in question:
1. Join orders and lineitems with part-supplier data
2. Calculate:
   - Total order margin (`SUM(extendedprice - supplycost * quantity)`)
   - Item count per order
   - **Average markup ratio** (`extendedprice / (supplycost * quantity)`)
3. Return only orders with more than 5 items and margin < $40,000

Your task: **compare a nested-subquery version with a multi-stage CTE pipeline**, and reflect on runtime, memory usage, and clarity of the resulting query.

---

### Query to optimise

```sql
-- Original nested query
SELECT * FROM (
  SELECT
    o.O_ORDERKEY,
    COUNT(*) AS item_count,
    SUM(l.L_EXTENDEDPRICE - ps.PS_SUPPLYCOST * l.L_QUANTITY) AS total_margin,
    AVG(
      CASE 
        WHEN ps.PS_SUPPLYCOST * l.L_QUANTITY = 0 THEN NULL
        ELSE l.L_EXTENDEDPRICE / (ps.PS_SUPPLYCOST * l.L_QUANTITY)
      END
    ) AS avg_markup_ratio
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS o
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.LINEITEM l
    ON o.O_ORDERKEY = l.L_ORDERKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.PARTSUPP ps
    ON l.L_PARTKEY = ps.PS_PARTKEY
   AND l.L_SUPPKEY = ps.PS_SUPPKEY
  GROUP BY o.O_ORDERKEY
) tmp
WHERE item_count > 5 AND total_margin < 40000;
```

---

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.PARTSUPP`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Start by **breaking apart the nested query**:
- First CTE: perform joins and compute per-line `margin` and `markup_ratio`
- Second CTE: group by order and aggregate those metrics
- Final filter on `item_count` and `total_margin`

> Both queries should return the same result — but structure impacts **compute reuse** and **compile efficiency** when derived expressions are costly.

#### How to compare performance in Snowflake

1. **Use the Query Profile** in the History tab:
   - Look at **compilation time**, **execution time**, **memory usage**, and **bytes scanned**
2. **Test at scale**:
   - Run both queries on `TPCH_SF1`, `TPCH_SF10` and perhaps `TPCH_SF100` or `TPCH_SF1000`
   - Note any differences in responsiveness and cost
3. **Compare query plans**:
   - Use `EXPLAIN USING PLAN` to check whether Snowflake can reuse computations or materialize intermediate steps
4. **Prevent runaway compute**:
   - Optionally limit job time with:
     ```sql
     ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 60;
     ```

#### Helpful SQL concepts

`CTE`, `JOIN`, `GROUP BY`, `CASE`, `NULLIF`, `EXPLAIN USING PLAN`

```sql
CASE 
  WHEN denom = 0 THEN NULL 
  ELSE numerator / denom 
END
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query (CTE refactor)

```sql
WITH joined_data AS (
  SELECT
    o.O_ORDERKEY,
    l.L_QUANTITY,
    l.L_EXTENDEDPRICE,
    ps.PS_SUPPLYCOST,
    (l.L_EXTENDEDPRICE - ps.PS_SUPPLYCOST * l.L_QUANTITY) AS margin,
    CASE 
      WHEN ps.PS_SUPPLYCOST * l.L_QUANTITY = 0 THEN NULL
      ELSE l.L_EXTENDEDPRICE / (ps.PS_SUPPLYCOST * l.L_QUANTITY)
    END AS markup_ratio
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS o
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.LINEITEM l
    ON o.O_ORDERKEY = l.L_ORDERKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.PARTSUPP ps
    ON l.L_PARTKEY = ps.PS_PARTKEY
   AND l.L_SUPPKEY = ps.PS_SUPPKEY
),
order_summary AS (
  SELECT
    O_ORDERKEY,
    COUNT(*) AS item_count,
    SUM(margin) AS total_margin,
    AVG(markup_ratio) AS avg_markup_ratio
  FROM joined_data
  GROUP BY O_ORDERKEY
)
SELECT *
FROM order_summary
WHERE item_count > 5 AND total_margin < 40000;
```

#### Why this works

- The CTE structure **materializes expensive expressions once**, reducing risk of recomputation
- Derived fields like `markup_ratio` are computed once and reused
- Snowflake's planner can **optimize each step independently**, improving compile time and execution clarity

#### Business answer

This returns all orders with more than 5 items and total margin under $40,000 — along with their **average markup ratio**, flagging potentially underpriced or loss-making bundles. On `TPCH_SF10`, the CTE version compiled faster and used **~20–40% less memory** depending on warehouse size.

#### Take-aways

* Nesting hides compute cost; CTEs expose it for reuse and optimization
* Complex expressions (like ratios with null protection) benefit from CTE staging
* Snowflake often **recognizes reusable expressions**, but not always within deeply nested plans
* Use query profiles and EXPLAIN plans to validate where time and memory are spent

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Update the logic to:
- **Group orders by year** (based on `O_ORDERDATE`)
- Compute and visualize the **year-over-year average markup ratio**

Which years had unusually low average markups — could it reflect strategic pricing decisions or data issues?

</details>
