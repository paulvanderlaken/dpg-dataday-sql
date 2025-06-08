## ex70: Top 3 Products per Nation — Ranked Long Format

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 5 / 10

### Business context
Continuing the **Momentum Matters** initiative, leadership now wants to understand **which products drive local performance**. While global rankings give a high-level view, true business insight comes from seeing which parts dominate **within each country**.

You’ve been asked to deliver a long-format breakdown of the **top 3 revenue-generating parts for each nation**. The data will support:
- Local marketing efforts
- Country-level procurement alignment
- Regional product tailoring

Your output should be structured **one row per part per country**, with its local rank and revenue value. A pivoted version for executive slides will follow in the next assignment.

**Business logic & definitions:**
* net revenue = `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* part ID = `P_PARTKEY`
* customer nation = `N_NAME` (from `CUSTOMER` → `NATION`)
* output = `(nation, part_key, net_revenue, part_rank)` for top 3 parts per nation

### Starter query
```sql
-- Preview how part keys and customer nations link together
SELECT
    N.N_NAME AS nation,
    P.P_PARTKEY,
    L.L_EXTENDEDPRICE,
    L.L_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
  ON O.O_ORDERKEY = L.L_ORDERKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
  ON L.L_PARTKEY = P.P_PARTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
  ON C.C_NATIONKEY = N.N_NATIONKEY
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Start by calculating **net revenue per (nation, part)**. Then use `ROW_NUMBER()` or `RANK()` to find the top 3 parts **per nation**, ordered by revenue. Keep the data in long format — one row per part, not one row per nation.

#### Helpful SQL concepts

`ROW_NUMBER()`, `PARTITION BY`, `ORDER BY`, `QUALIFY`

```sql
ROW_NUMBER() OVER (PARTITION BY country ORDER BY revenue DESC)
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH part_revenue AS (
  SELECT
    N.N_NAME AS nation,
    P.P_PARTKEY AS part_key,
    SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS net_revenue
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P ON L.L_PARTKEY = P.P_PARTKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N ON C.C_NATIONKEY = N.N_NATIONKEY
  GROUP BY N.N_NAME, P.P_PARTKEY
)
SELECT
  nation,
  part_key,
  net_revenue,
  ROW_NUMBER() OVER (PARTITION BY nation ORDER BY net_revenue DESC) AS part_rank
FROM part_revenue
QUALIFY part_rank <= 3
ORDER BY nation, part_rank;
```

#### Why this works

This query first computes revenue per part per nation, then ranks each part within its country. By using `ROW_NUMBER()` + `PARTITION BY`, you isolate the top 3 for every nation without needing to hardcode or loop.

#### Business answer

This ranking reveals **localized bestsellers** — enabling marketing and procurement teams to align strategies to national preferences. Some parts appear across many countries, while others dominate in just one — hinting at regional demand patterns.

#### Take-aways

* Use `ROW_NUMBER()` + `PARTITION BY` to rank items within grouped categories.
* Long-format output is better for follow-up pivoting and detailed analysis.
* Even simple group-based ranking can yield actionable geographic insights.
* `QUALIFY` helps filter directly on window function results without nesting.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a column showing each part's **revenue share within its nation**.

Which nations are most dominated by a single product? Which have a flatter distribution?

</details>
