## ex70: Top 5 Products per Nation — Wide Format Table

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 5 / 10

### Business context
While we could not uncover clear revenue drivers in our global portfolio, there might be specific products that generate **most of the local, country-based revenue**. 

Instead of listing rows for each product, executives have requested a **pivoted summary table**: one row per nation, with the IDs of the **top 3 parts** listed as columns.

Your task is to identify the **top 3 revenue-generating products per nation**, and format the output so that each column shows the part key for that rank (`top_part_1`, `top_part_2`, `top_part_3`). This table will be directly copied into presentation slides, so clarity and structure matter.

**Business logic & definitions:**
* net revenue = `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* part ID = `PART_KEY`
* customer nation = `N_NAME` from the customer side
* output structure = one row per nation, three columns (`top_part_1` → `top_part_3`)

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

First, calculate the total net revenue per `(nation, part)` pair. Then use `RANK()` or `ROW_NUMBER()` with a `PARTITION BY NATION` to assign top 3 ranks. Finally, pivot the output so each rank becomes a column using a `CASE WHEN` pattern and grouped `MAX()` aggregation.

#### Helpful SQL concepts

`RANK()`, `ROW_NUMBER()`, `PARTITION BY`, `CASE`, `MAX()`, conditional pivoting

```sql
SELECT
  nation,
  MAX(CASE WHEN rank = 1 THEN part END) AS top_part_1,
  ...
FROM ranked_parts
GROUP BY nation;
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
ranked_parts AS (
  SELECT
    nation,
    part_key,
    net_revenue,
    ROW_NUMBER() OVER (PARTITION BY nation ORDER BY net_revenue DESC) AS rank
  FROM part_revenue
),
pivoted AS (
  SELECT
    nation,
    MAX(CASE WHEN rank = 1 THEN part_key END) AS top_part_1,
    MAX(CASE WHEN rank = 2 THEN part_key END) AS top_part_2,
    MAX(CASE WHEN rank = 3 THEN part_key END) AS top_part_3
  FROM ranked_parts
  WHERE rank <= 3
  GROUP BY nation
)
SELECT * FROM pivoted
ORDER BY nation;
```

#### Why this works

This pattern first ranks parts by revenue within each nation, then pivots those rankings into columns. It cleanly separates the steps: aggregation → ranking → reshaping — and results in a readable, presentation-ready output.

> Note: Often it's preferable to keep data in a long format and perform the pivot in your BI tool.

#### Business answer

Each nation has a distinct set of top-revenue parts. While some products appear frequently across countries, others are nation-specific — suggesting potential for localized marketing or sourcing strategies.

#### Take-aways

* Use `ROW_NUMBER()` or `RANK()` to create ranked lists within groups.
* Convert long-format rankings into wide-format dashboards using `CASE` + `MAX()`.
* Clean separation of logic into CTEs helps with debugging and readability.
* Wide tables are better suited for presentation — long tables are better for deep dives.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a column for each product showing its **revenue share within the nation** (as a percentage of total revenue from that nation). Which nations are more top-heavy?

</details>
