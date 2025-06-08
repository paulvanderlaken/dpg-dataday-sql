## ex54: Map Segments with CASE or Lookup Table?

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 4 / 10

### Business context
The marketing operations team is mapping customer segments into simplified tiers for an upcoming campaign. 

An analyst wrote the working query below, using a `CASE WHEN` expression that assigns:

- `'BUILDING'` and `'AUTOMOBILE'` → `'Commercial'`  
- `'FURNITURE'` and `'HOUSEHOLD'` → `'Home'`  
- Everything else → `'Other'`

It works fine — but now similar mappings are being reused in dashboards, pipelines, and reports. 
The team wants to know if this logic can be made **more maintainable** using a **lookup table join** instead.

Your task is to **rewrite the current `CASE`-based query** using a small inline `segment_map` lookup table.

Start with the `SF1` dataset, then test the performance of both versions on `SF100`. Does dataset size influence the performance gains?

### Starter query

```sql
-- CASE-based classification of customers into tiers
SELECT 
  C_CUSTKEY,
  C_NAME,
  C_MKTSEGMENT,
  CASE 
    WHEN C_MKTSEGMENT IN ('AUTOMOBILE', 'BUILDING') THEN 'Commercial'
    WHEN C_MKTSEGMENT IN ('FURNITURE', 'HOUSEHOLD') THEN 'Home'
    ELSE 'Other'
  END AS customer_tier
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* (Repeat later with `TPCH_SF100.CUSTOMER`)

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

- Define a `segment_map` inline using `VALUES`
- Join it to the `CUSTOMER` table on `C_MKTSEGMENT`
- Use `LEFT JOIN` so that unmatched rows are still returned
- Use `COALESCE` to default missing values to `'Other'`

#### Helpful SQL concepts

`VALUES`, `LEFT JOIN`, `COALESCE`, mapping tables

```sql
WITH segment_map AS (
  SELECT * FROM VALUES
    ('SEGMENT', 'TIER'),
    …
  AS seg_map(segment, tier)
)
```

Compare performance on `SF1` and `SF100`. Which version scales better?

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Version B — Lookup table with `LEFT JOIN`

```sql
WITH segment_map AS (
  SELECT * FROM VALUES
    ('AUTOMOBILE', 'Commercial'),
    ('BUILDING', 'Commercial'),
    ('FURNITURE', 'Home'),
    ('HOUSEHOLD', 'Home')
  AS seg_map(segment, tier)
)

SELECT 
  C.C_CUSTKEY,
  C.C_NAME,
  C.C_MKTSEGMENT,
  COALESCE(M.tier, 'Other') AS customer_tier
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
LEFT JOIN segment_map M
  ON C.C_MKTSEGMENT = M.segment;
```

#### Why this works

- The mapping is centralized in the `segment_map` table
- New mappings can be added without touching the SQL logic
- The `LEFT JOIN` ensures unmatched rows still appear
- `COALESCE` assigns a default category (`'Other'`) when no match is found

#### Business answer

All customers were grouped into `'Commercial'`, `'Home'`, or `'Other'` using a reusable mapping table.

#### Take-aways

* Replace hardcoded `CASE` blocks with joins when logic is reused or changes often
* `VALUES` + `JOIN` + `COALESCE` is a flexible pattern for business rules
* Joins are more scalable and testable across environments
* What works fast on SF1 might not stay fast at SF100 — always test

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

The campaign team now wants to assign **email cadence strategies** to customer-order pairs based on a combination of:

* `C_MKTSEGMENT` (the customer’s segment), and
* `O_ORDERPRIORITY` (the priority of the order)

You’re given the following mapping:

| Segment     | Priority | Cadence        |
| ----------- | -------- | -------------- |
| AUTOMOBILE  | 1-URGENT | "daily"        |
| HOUSEHOLD   | 2-HIGH   | "every 3 days" |
| FURNITURE   | 3-MEDIUM | "weekly"       |
| *any other* | *any*    | "monthly"      |

Steps:

1. Join `CUSTOMER` and `ORDERS` on `C_CUSTKEY = O_CUSTKEY`
2. Create an inline `cadence_map` with two columns: `segment`, `priority`
3. Join the combined data to the mapping table using **both columns**
4. Use `COALESCE` to assign `"monthly"` to unmatched rows
5. Return `C_NAME`, `O_ORDERKEY`, `segment`, `priority`, and the derived `cadence`

What kind of join do you use, and what happens if you reverse the order of joins?

</details>
