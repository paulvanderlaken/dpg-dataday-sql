## ex50: Filter First, Not After the Join

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 4 / 10

### Business context
The compliance team needs a list of high-risk line items — defined as those that are both **bulk orders** (quantity > 30) and **high-value** (extended price > 10,000). An analyst prepared the reporting pipeline below.

The logic works, but can you do better?

### Query to optimise

```sql
WITH flagged_lineitems AS (
  SELECT
    L_ORDERKEY,
    L_PARTKEY,
    L_QUANTITY,
    L_EXTENDEDPRICE,
    CASE
      WHEN L_QUANTITY > 30 AND L_EXTENDEDPRICE > 10000 THEN 'both'
      WHEN L_QUANTITY > 30 THEN 'bulk'
      WHEN L_EXTENDEDPRICE > 10000 THEN 'high_value'
      ELSE 'neither'
    END AS lineitem_flag
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
)

SELECT
  o.O_ORDERKEY,
  o.O_ORDERDATE,
  f.L_PARTKEY,
  f.L_QUANTITY,
  f.L_EXTENDEDPRICE,
  f.lineitem_flag
FROM flagged_lineitems f
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS o
  ON f.L_ORDERKEY = o.O_ORDERKEY
WHERE f.lineitem_flag = 'both';
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Right now:
- All line items are processed and flagged,
- All rows are joined to `ORDERS` (millions of them),
- Only afterward are rows filtered for `lineitem_flag = 'both'`.

Can we:
- **Push the filter** into the CTE,
- Or avoid evaluating flags for irrelevant rows?

This will reduce:
- Rows read,
- Join cost,
- Expression evaluations.

#### Helpful SQL concepts

`WITH`, `JOIN`, `WHERE`, filter placement, early rejection


</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH filtered_lineitems AS (
  SELECT
    L_ORDERKEY,
    L_PARTKEY,
    L_QUANTITY,
    L_EXTENDEDPRICE
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
  WHERE L_QUANTITY > 30 AND L_EXTENDEDPRICE > 10000
)

SELECT
  o.O_ORDERKEY,
  o.O_ORDERDATE,
  l.L_PARTKEY,
  l.L_QUANTITY,
  l.L_EXTENDEDPRICE,
  'both' AS lineitem_flag
FROM filtered_lineitems l
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS o
  ON l.L_ORDERKEY = o.O_ORDERKEY;
```

#### Why this works

The new version:
- **Pushes filtering into the CTE**, so only relevant rows are processed,
- Avoids computing unnecessary labels for discarded rows,
- Joins only what matters — reducing join compute, memory, and execution time.

The result is **identical**, but likely runs **significantly faster**, especially on large datasets.

#### Business answer

This returns all line items that meet both bulk and value thresholds — now joined with order metadata, and flagged accordingly.

#### Take-aways

* Don’t label everything when you only care about a subset — **filter first**.
* Always ask: “Can I reduce the dataset **before** I join, compute, or group?”
* CTEs don’t guarantee pushdown — it's up to you to structure filters correctly.
* Early rejection reduces join size, cost, and execution time — especially with wide fact tables like `LINEITEM`.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Refactor the query to return **all flagged line items**, including `'bulk'`, `'high_value'`, and `'both'`, but:
- Only join **orders for `'both'`-flagged** rows (for further compliance review),
- Leave other rows unjoined.

Use a `LEFT JOIN` and conditional join logic to achieve this.

</details>
