## ex28: Parts Never Sold in 1996

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 4 / 10

### Business context
As part of a historical review, the sales analytics team is checking which parts in our catalog **did not generate any sales in 1996**. They want to assess whether those products were simply launched later — or if they’ve consistently underperformed.

Your task is to identify all parts that were **never sold** in the year 1996.

**Business logic & definitions:**
* A part is considered “sold” if it appears in a `LINEITEM`
* Only line items with `L_SHIPDATE` during the year 1996 count
* We're looking for parts with **no such line items in 1996**

### Starter query
```sql
-- Preview part and line item relationships
SELECT
    l.L_ORDERKEY,
    l.L_PARTKEY,
    l.L_SHIPDATE,
    p.P_NAME
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART p
  ON l.L_PARTKEY = p.P_PARTKEY
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

This is a **time-bound anti-join**. First, find all parts that *were* sold in 1996 (i.e., appear in `LINEITEM` where `L_SHIPDATE` is in 1996).

Then, exclude them from the full parts list using `LEFT JOIN` or `NOT IN` / `NOT EXISTS`.

Make sure your date filter captures all of 1996 using `>= '1996-01-01'` and `< '1997-01-01'`.

#### Helpful SQL concepts

`LEFT JOIN`, `IS NULL`, date filtering, anti-join logic

```sql
-- Anti-join using a date condition
SELECT …
FROM A
LEFT JOIN (
    SELECT DISTINCT key
    FROM B
    WHERE date BETWEEN …
) filtered
ON A.key = filtered.key
WHERE filtered.key IS NULL;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH parts_sold_1996 AS (
    SELECT DISTINCT L_PARTKEY
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
    WHERE L_SHIPDATE >= DATE '1996-01-01'
      AND L_SHIPDATE < DATE '1997-01-01'
)
SELECT
    p.P_PARTKEY,
    p.P_NAME,
    p.P_RETAILPRICE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART p
LEFT JOIN parts_sold_1996 s
  ON p.P_PARTKEY = s.L_PARTKEY
WHERE s.L_PARTKEY IS NULL
ORDER BY p.P_PARTKEY;
```

#### Why this works

This query isolates parts **not present** in any 1996 shipment by:
- First identifying all part keys that were shipped in 1996
- Then left joining this list to the full parts table
- Filtering for `NULL` values to find parts that were excluded

#### Business answer

These parts did not generate any sales in 1996 and may require further investigation by product or marketing teams.

#### Take-aways

* Anti-joins are flexible: they work for structural gaps (e.g. no orders) or **temporal gaps**
* CTEs make filters easier to modularize and reuse
* Always apply precise date filtering when defining a year

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

How many of these parts **started being sold only after 1996**? Modify your logic to check for parts whose **first recorded sale** occurred after January 1, 1997.

</details>
