## ex28: Flag Parts Never Sold in 1996

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 4 / 10

### Business context
After reviewing part naming and customer activity, the audit team turns its attention to **sales coverage**. One of your leads noticed several products that **didn’t appear in any shipments during 1996** — the first full year of operations. This raises questions: Were they added later? Did they underperform?

You’ve been asked to identify any parts that **were not sold at all in 1996**, and store them in your audit schema for product leadership to review.

**Business logic & definitions:**
* A part is considered “sold” if it appears in the `LINEITEM` table
* We're interested only in line items with a `L_SHIPDATE` during calendar year 1996
* Parts that do **not** appear in any such line items should be flagged
* Output: store in `WORKSHOP_DB.TEMP_SCHEMA.parts_never_sold_1996`

### Starter query
```sql
-- Preview part and line item relationship
SELECT
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

This is a **time-bound anti-join**.

Step-by-step:
1. Build a list of all `L_PARTKEY`s that **do** appear in shipments in 1996.
2. Then `LEFT JOIN` that list to the full set of parts.
3. Filter where no match exists (i.e., `sold_1996.L_PARTKEY IS NULL`).

Use date filters like:
```sql
L_SHIPDATE >= '1996-01-01' AND L_SHIPDATE < '1997-01-01'
```

This ensures all records from 1996 are correctly included.

#### Helpful SQL concepts

`LEFT JOIN`, `IS NULL`, `WITH`, `DISTINCT`, date filtering

```sql
-- Anti-join with filtered subquery
SELECT …
FROM PART p
LEFT JOIN (
    SELECT DISTINCT L_PARTKEY
    FROM LINEITEM
    WHERE L_SHIPDATE BETWEEN …
) sold_1996
ON p.P_PARTKEY = sold_1996.L_PARTKEY
WHERE sold_1996.L_PARTKEY IS NULL;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
-- Step 1: Create a table of parts that were never sold in 1996
CREATE OR REPLACE TABLE WORKSHOP_DB.TEMP_SCHEMA.parts_never_sold_1996 AS
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
WHERE s.L_PARTKEY IS NULL;
```

```sql
-- Step 2: Review the result
SELECT * FROM WORKSHOP_DB.TEMP_SCHEMA.parts_never_sold_1996
ORDER BY P_PARTKEY;
```

#### Why this works

By isolating part keys that did ship in 1996, we can anti-join them against the master part list. Filtering for `IS NULL` reveals parts that had **zero shipping activity** that year.

You stored this in your schema for follow-up — perhaps to check whether these parts launched later or were poorly promoted.

#### Business answer

Several parts had **no recorded shipments during 1996**. These may require re-evaluation for timing, pricing, or lifecycle stage alignment.

#### Take-aways

* Anti-joins can be scoped to a time window to detect temporal gaps
* Always use precise date filtering (`>= … AND < …`) for clean year boundaries
* Persisting year-specific audit findings supports lifecycle reviews and time-based comparisons

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Create a second table that shows which of these parts **only started shipping after 1996**. That is, their **first appearance in LINEITEM** occurred after `1997-01-01`.

Use an aggregation or window function to detect **first shipdate per part**, and filter accordingly.

</details>
