## ex29: Suspicious High-Discount, High-Quantity Items

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 4 / 10

### Business context
The pricing and audit team wants to flag outlier transactions where **a large number of units were sold at a steep discount**. These could reflect exceptional bulk deals — or accidental overrides of standard pricing rules.

You're asked to identify any line items where both **quantity and discount** are unusually high, so they can be reviewed for policy compliance.

**Business logic & definitions:**
* high quantity: more than **45 units**
* high discount: more than **8%** (`L_DISCOUNT > 0.08`)
* both conditions must be true

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

Use a `WHERE` clause with an `AND` operator to enforce **both** conditions:
- `L_QUANTITY > 45`
- `L_DISCOUNT > 0.08`

This targets extreme cases by selecting records above the 95th percentile for both fields.

#### Helpful SQL concepts

`WHERE`, compound filters, numeric comparisons

```sql
SELECT …
FROM …
WHERE col1 > value1 AND col2 > value2;
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
    L_DISCOUNT,
    L_EXTENDEDPRICE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
WHERE L_QUANTITY > 45
  AND L_DISCOUNT > 0.08
ORDER BY L_DISCOUNT DESC;
```

#### Why this works

This filters the `LINEITEM` table for records that exceed both business-defined thresholds. The result surfaces **rare but potentially concerning** combinations of high volume and high discount.

#### Business answer

These 34 line items combined **exceptionally large quantities and steep discounts**, which could signal pricing override risks or strategic exceptions.

#### Take-aways

* `AND` is essential for rule-based flagging across multiple dimensions
* Choosing extreme thresholds helps isolate rare, potentially anomalous events
* Real-world anomaly detection often involves combined logic (e.g., volume + pricing)

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a derived column that computes the **net revenue** for each flagged item:  
`L_EXTENDEDPRICE * (1 - L_DISCOUNT)`  
Which items produced the highest net revenue despite the heavy discount?

</details>
