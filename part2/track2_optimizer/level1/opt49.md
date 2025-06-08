## ex49: Flagging Large or Valuable Shipments

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 3 / 10

### Business context
The logistics team wants to monitor line items that either involve **large shipment quantities** or are **individually high in value**. These line items are often reviewed for special handling, fraud detection, or pricing policy compliance. A previous analyst wrote query below. 

Do you see an opportunity to rewrite it more efficiently? Use `EXPLAIN` to evaluate and compare the two queries.

### Query to optimise

```sql
SELECT
    L_ORDERKEY,
    L_PARTKEY,
    L_QUANTITY,
    L_EXTENDEDPRICE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
WHERE L_QUANTITY > 30

UNION ALL

SELECT
    L_ORDERKEY,
    L_PARTKEY,
    L_QUANTITY,
    L_EXTENDEDPRICE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
WHERE L_EXTENDEDPRICE > 10000;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

The current query performs **two full scans** of the `LINEITEM` table and appends the results — even if the same partitions are read twice. Ask yourself:

- Can a single `WHERE` clause do the job?
- Are overlapping rows acceptable or expected?
- Is performance improved by merging into one pass?

#### Helpful SQL concepts

`WHERE`, `OR`, column projection

```sql
SELECT … FROM … WHERE condition1 OR condition2;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
SELECT
    L_ORDERKEY,
    L_PARTKEY,
    L_QUANTITY,
    L_EXTENDEDPRICE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
WHERE L_QUANTITY > 30
   OR L_EXTENDEDPRICE > 10000;
```

#### Why this works

This rewrite performs a **single scan** of the `LINEITEM` table and evaluates the compound condition using `OR`. For large tables, that can dramatically reduce total I/O compared to scanning the same table twice. If the two filter conditions are not highly selective or touch similar partitions, this version is often faster and cheaper.

However, for **very selective, non-overlapping filters**, the `UNION ALL` version might allow better **parallelism and partition skipping** — so always compare using Snowflake’s query profiler.

#### Business answer

The result lists all line items that either shipped in large quantities or had a high individual extended price — i.e., candidates for review due to volume or value.

#### Take-aways

* Rewriting multi-pass logic (`UNION ALL`) into a **single filtered scan** often improves performance — but not always.
* Query optimization depends on **filter selectivity**, **partition layout**, and **data skew**.
* Learn to test changes using `EXPLAIN` or `QUERY_HISTORY`, not just intuition.
* NOTE: Clean, single-pass logic also improves **maintainability** and **readability** for others.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a `CASE` column called `alert_reason` with three labels:
- `'bulk'` if only `L_QUANTITY > 30`
- `'high_value'` if only `L_EXTENDEDPRICE > 10000`
- `'both'` if both conditions are true

Then filter for only those flagged `'both'`.

</details>
