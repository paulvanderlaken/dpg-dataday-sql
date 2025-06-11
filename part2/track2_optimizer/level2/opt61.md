## ex61: Refactor Windowed Recency Logic with JOIN or GROUP BY

> **Type:** Stretch | **Track:** Query Optimizer  
>
> **Difficulty:** 8 / 10

### Business context
Customer success managers often ask for **the most recent order date per customer**, especially when preparing quarterly outreach campaigns. A junior analyst wrote a query using a **window function** (`ROW_NUMBER()`) to rank each customer's orders and then filtered to keep only the most recent one.

It works — but on large datasets, it's become noticeably slower. You've been asked to **refactor this query** using a `JOIN` or `GROUP BY` approach and compare performance and result integrity.

> Bonus: Can you also explore the use of `QUALIFY`, and determine when it makes more sense?

---

### Query to optimise

```sql
-- Original window function version
WITH ranked_orders AS (
  SELECT
    c.C_CUSTKEY,
    c.C_NAME,
    o.O_ORDERKEY,
    o.O_ORDERDATE,
    ROW_NUMBER() OVER (PARTITION BY c.C_CUSTKEY ORDER BY o.O_ORDERDATE DESC) AS rn
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER c
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS o
    ON c.C_CUSTKEY = o.O_CUSTKEY
)
SELECT *
FROM ranked_orders
WHERE rn = 1;
```

---

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

There are two alternative strategies:

**Option A: GROUP BY + JOIN**
- Aggregate to get the latest order date per customer
- Then identify the “most recent” order row — using a tie-breaker like the minimum `O_ORDERKEY`

**Option B: QUALIFY**
- Use `ROW_NUMBER()` inline and filter with `QUALIFY ROW_NUMBER() = 1`

> Be cautious: the join-based version may return **duplicates** if customers have multiple orders on the same date, unless you break ties deliberately.

#### How to compare performance

1. Run each version on both **TPCH_SF1** and **TPCH_SF10**
2. Use the **Query Profile** to inspect:
   - **Execution time**
   - **Join strategy**
   - **Sort cost** (especially for window functions)
3. Use `EXPLAIN USING PLAN` to see logical differences

#### Helpful SQL concepts

`ROW_NUMBER()`, `QUALIFY`, `GROUP BY`, `JOIN`, tie-breaker logic

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### ✅ Option A: Join with tie-breaker to ensure one row per customer

```sql
WITH latest_order_dates AS (
  SELECT
    O_CUSTKEY,
    MAX(O_ORDERDATE) AS latest_order_date
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS
  GROUP BY O_CUSTKEY
),
disambiguated_orders AS (
  SELECT
    o.O_CUSTKEY,
    MIN(o.O_ORDERKEY) AS most_recent_orderkey
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS o
  JOIN latest_order_dates l
    ON o.O_CUSTKEY = l.O_CUSTKEY AND o.O_ORDERDATE = l.latest_order_date
  GROUP BY o.O_CUSTKEY
)
SELECT
  c.C_CUSTKEY,
  c.C_NAME,
  o.O_ORDERKEY,
  o.O_ORDERDATE
FROM disambiguated_orders do
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS o
  ON o.O_CUSTKEY = do.O_CUSTKEY AND o.O_ORDERKEY = do.most_recent_orderkey
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER c
  ON c.C_CUSTKEY = o.O_CUSTKEY;
```

#### ✅ Option B: QUALIFY version (simpler, window-based)

```sql
SELECT
  c.C_CUSTKEY,
  c.C_NAME,
  o.O_ORDERKEY,
  o.O_ORDERDATE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER c
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS o
  ON c.C_CUSTKEY = o.O_CUSTKEY
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY c.C_CUSTKEY ORDER BY o.O_ORDERDATE DESC, o.O_ORDERKEY DESC
) = 1;
```

#### Why this works

- The `JOIN` version ensures **exactly one row per customer** by explicitly resolving ties
- The `QUALIFY` version achieves the same goal more concisely — but **still relies on a window sort**
- Both produce identical results; performance differences may vary by warehouse size and data volume

#### Business answer

You now have one **most recent order** per customer — useful for building engagement dashboards or prioritizing sales follow-up. Both approaches work, but the `QUALIFY` version is often faster for small workloads, while the join version may scale better in pipelines. Still the original `ROW_NUMBER()` might be the simplest and cleanest solution. 

#### Take-aways

* `ROW_NUMBER()` is elegant but can be costly on large data due to **global sorting**
* `GROUP BY + JOIN` is modular and flexible, but requires **tie-breaking** to ensure row uniqueness
* `QUALIFY` is Snowflake-specific and often a clean middle ground
* Always validate row counts when refactoring ranking logic

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Extend the logic to also compute:
- **Average days between orders** for each customer who placed more than 2 orders
- Compare the cost and clarity between:
  - A `LAG()` based window solution
  - A `GROUP BY` solution using `DATEDIFF()` and intermediate tables

Which version is faster, and why?

</details>
