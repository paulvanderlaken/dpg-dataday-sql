## ex71: Pivoted Part Rankings per Nation — Executive View

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 6 / 10

### Business context
In the previous step of the **Momentum Matters** initiative, you identified the top 3 revenue-generating products per country. Now, the executive team wants a **presentation-ready summary**: one row per nation, with the **top 3 part keys and their revenue shares side-by-side**.

This format makes it easy to spot:
- Local bestsellers
- Over-concentration (e.g. if a single product accounts for half the national revenue)
- Balanced vs. skewed demand across countries

This pivoted version will feed directly into executive dashboards and board slides.

**Business logic & definitions:**
* net revenue = `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* part rank = revenue rank per nation (1 = highest)
* revenue share = part revenue ÷ total revenue within that nation
* Output format:
  - Columns: `top_part_1`, `share_1`, `top_part_2`, `share_2`, `top_part_3`, `share_3`
  - One row per nation

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Start with the same query used in exercise 70, but this time:
- Add a `revenue_share` using a `SUM(...) OVER (PARTITION BY nation)`
- Use `CASE WHEN` logic to assign values into pivoted columns for rank 1, 2, and 3
- Use `MAX(...)` aggregation to reshape into a wide format

#### Helpful SQL concepts

`ROW_NUMBER()`, `PARTITION BY`, `SUM(...) OVER`, `CASE`, `MAX()`

```sql
MAX(CASE WHEN rank = 1 THEN part_key END) AS top_part_1
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
),
ranked AS (
  SELECT
    nation,
    part_key,
    net_revenue,
    net_revenue / SUM(net_revenue) OVER (PARTITION BY nation) AS revenue_share,
    ROW_NUMBER() OVER (PARTITION BY nation ORDER BY net_revenue DESC) AS part_rank
  FROM part_revenue
),
top3 AS (
  SELECT * FROM ranked WHERE part_rank <= 3
)
SELECT
  nation,
  MAX(CASE WHEN part_rank = 1 THEN part_key END) AS top_part_1,
  MAX(CASE WHEN part_rank = 1 THEN revenue_share END) AS share_1,
  MAX(CASE WHEN part_rank = 2 THEN part_key END) AS top_part_2,
  MAX(CASE WHEN part_rank = 2 THEN revenue_share END) AS share_2,
  MAX(CASE WHEN part_rank = 3 THEN part_key END) AS top_part_3,
  MAX(CASE WHEN part_rank = 3 THEN revenue_share END) AS share_3
FROM top3
GROUP BY nation
ORDER BY nation;
```

#### Why this works

The query uses `ROW_NUMBER()` to identify top parts per nation, calculates each part’s **share of national revenue**, and then uses `CASE WHEN` + `MAX()` to pivot the data into wide format.

> 💡 **Alternative approach**: Snowflake also supports a `PIVOT` clause — but the `CASE WHEN` method is more portable and easier to read/debug when the number of columns is small and fixed.

#### Business answer

This pivoted summary makes it immediately clear:
- Which nations are **dominated by a single product**
- Which have a **broad top 3**
- Which countries have **the same top performers**, hinting at global winners

This view enables faster executive decision-making around localization and focus.

#### Take-aways

* Pivoting ranked data is a common pattern in executive reporting.
* `CASE WHEN` + `MAX()` gives explicit control over reshaping.
* `SUM(...) OVER` helps calculate in-group percentages elegantly.
* A visual-ready table can drive faster insights than long-format lists.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Repeat this exercise using `P_BRAND` instead of `P_PARTKEY`.

Which brands dominate in which countries? Do the same brands top multiple regions?

</details>
