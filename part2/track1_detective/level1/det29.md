## ex29: Flag High-Discount, High-Quantity Line Items

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 4 / 10

### Business context
Your earlier checks flagged naming issues and sales gaps. Now, the pricing audit team has asked you to investigate **transaction-level anomalies** — specifically, items that were sold in **very large quantities** and received **steep discounts**.

These may indicate bulk deals, but they could also reflect policy overrides or data entry errors. You’re asked to isolate any line items that satisfy both thresholds and store them for manual review.

**Business logic & definitions:**
* High quantity: more than **45 units**
* High discount: more than **8%** (`L_DISCOUNT > 0.08`)
* Both conditions must be met
* Output: store in `WORKSHOP_DB.TEMP_SCHEMA.flagged_bulk_discount_items`

### Starter query
```sql
-- Preview line item quantities and discounts
SELECT
    L_ORDERKEY,
    L_PARTKEY,
    L_QUANTITY,
    L_DISCOUNT,
    L_EXTENDEDPRICE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Use a `WHERE` clause to apply **both conditions** together:
- `L_QUANTITY > 45`
- `L_DISCOUNT > 0.08`

You're looking for **compound logic**, not either-or. So use `AND`.

After confirming the logic, wrap the query in `CREATE TABLE` to store results.

#### Helpful SQL concepts

`WHERE`, `AND`, numeric comparisons, `CREATE TABLE AS`

```sql
SELECT …
FROM LINEITEM
WHERE L_QUANTITY > 45 AND L_DISCOUNT > 0.08;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
-- Step 1: Create the flagged transaction table
CREATE OR REPLACE TABLE WORKSHOP_DB.TEMP_SCHEMA.flagged_bulk_discount_items AS
SELECT
    L_ORDERKEY,
    L_PARTKEY,
    L_QUANTITY,
    L_DISCOUNT,
    L_EXTENDEDPRICE,
    L_EXTENDEDPRICE * (1 - L_DISCOUNT) AS net_revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
WHERE L_QUANTITY > 45
  AND L_DISCOUNT > 0.08;
```

```sql
-- Step 2: Review results
SELECT * FROM WORKSHOP_DB.TEMP_SCHEMA.flagged_bulk_discount_items
ORDER BY net_revenue DESC;
```

#### Why this works

This query filters the `LINEITEM` table for records that exceed both **volume** and **discount** thresholds. It also computes a derived column `net_revenue` to support prioritization during manual review.

Storing the result enables deeper review by pricing or compliance stakeholders.

#### Business answer

You identified a subset of transactions where **high volumes were sold at unusually steep discounts** — potential outliers that may require approval review or fraud checks.

#### Take-aways

* Compound filters are essential when detecting violations of business rules
* Derived columns like `net_revenue` help downstream prioritization
* Storing transactional outliers is a common step in fraud and pricing pipelines
* This builds toward a rules-based anomaly detection layer

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Enhance your audit by adding a **severity score** to each flagged transaction, using the formula:

```sql
severity_score = L_QUANTITY * L_DISCOUNT
```

1. Add this as a new column to the table
2. Then create a second table with just the **top 10 most severe records**, based on this score:
   `WORKSHOP_DB.TEMP_SCHEMA.top_discount_anomalies`

This score gives stakeholders a quick way to prioritize their manual review efforts.

</details>
