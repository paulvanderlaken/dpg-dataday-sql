## ex53: Fix the Filters — Cleaning Up a Misfired Query

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 4 / 10

### Business context
The product classification team is reviewing whether certain low-priced anodized metal parts are still worth keeping in the portfolio. The business team asks for a count and breakdown of parts that:

- Contain **"steel"**, **"brass"**, or **"copper"** in their type
- Are **anodized**
- Are **not promotional**
- Have `"green"` in the name
- Are in the **bottom 10%** of retail price
- And have a size of **2, 4, 6, or 8**

An analyst volunteered to write the query — but it’s inefficient and, on closer inspection, wrong as well!

You’ve been asked to fix both the logic and performance.

### Query to optimise

```sql
SELECT P_PARTKEY, P_NAME, P_TYPE, P_RETAILPRICE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART
WHERE 
  LOWER(P_TYPE) LIKE '%steel%' OR
  LOWER(P_TYPE) LIKE '%brass%' OR
  LOWER(P_TYPE) LIKE '%copper%'
  AND LOWER(P_TYPE) LIKE '%anodized%'
  AND P_TYPE <> 'PROMO'
  AND P_NAME LIKE '%green%'
  AND P_SIZE BETWEEN 2 AND 8
  AND P_RETAILPRICE <= (
    SELECT 
      PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY P_RETAILPRICE)
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART
  );
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

There are five problems:
1. `LIKE` is case-sensitive — use `ILIKE`
2. `P_TYPE <> 'PROMO'` doesn’t match types like `'PROMO ANODIZED'`
3. `BETWEEN 2 AND 8` includes sizes 3, 5, 7 — not what was asked
4. The scalar subquery for percentile is re-evaluated row-by-row
5. The `OR` chain for materials isn't grouped — leading to faulty logic

Group related logic, simplify filters, and make the query planner happy.

#### Helpful SQL concepts

`ILIKE`, `NOT ILIKE`, `IN`, `PERCENTILE_CONT`, `WITH`, parentheses

```sql
-- Better patterns:
P_SIZE IN (2, 4, 6, 8)
P_TYPE NOT ILIKE 'promo%'
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

```sql
WITH low_price_threshold AS (
  SELECT 
    PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY P_RETAILPRICE) AS price_cutoff
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART
)

SELECT
  P_PARTKEY,
  P_NAME,
  P_TYPE,
  P_SIZE,
  P_RETAILPRICE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART p,
     low_price_threshold
WHERE 
  P_TYPE NOT ILIKE 'promo%'
  AND P_TYPE ILIKE '%anodized%'
  AND (
    P_TYPE ILIKE '%steel%' OR
    P_TYPE ILIKE '%brass%' OR
    P_TYPE ILIKE '%copper%'
  )
  AND P_NAME ILIKE '%green%'
  AND P_SIZE IN (2, 4, 6, 8)
  AND P_RETAILPRICE <= price_cutoff;
```

#### Why this works

- `ILIKE` handles case-insensitive matches cleanly
- `NOT ILIKE 'promo%'` correctly excludes any promotional variants
- `IN (2, 4, 6, 8)` filters exactly the requested sizes
- `WITH` clause avoids recalculating the percentile per row
- Parentheses around the `OR` logic prevent accidental precedence bugs

#### Business answer

There are **N parts** that meet all the requested conditions — low-priced, anodized, green-themed, non-promotional metal parts with even-numbered small sizes.

#### Take-aways

* Be precise with range logic — `BETWEEN` can include unwanted values
* Avoid repeating `LOWER(...) LIKE` — use `ILIKE`
* Wrap scalar aggregations in a CTE to prevent recomputation
* Always group `OR` conditions with parentheses when mixed with `AND`

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a `material_tag` column that classifies the part as `'steel'`, `'brass'`, or `'copper'` based on which substring appears in the type.

Then return the number of qualifying parts by material type and size.

</details>
