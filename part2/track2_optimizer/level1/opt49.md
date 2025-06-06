## ex49: Is Group-Level Discount Estimation Worth It?

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 4 / 10

### Business context
Your Snowflake cost dashboard flagged a revenue summary query as “potentially inefficient.” It calculates the **total value lost to discounts** by summing up the per-row discount value across all line items — grouped by **shipping year**.

An engineer has proposed a refactor: instead of calculating discount per row, we could compute the **gross revenue and average discount per year**, and then multiply those values at the group level.

You're asked to:
1. Rewrite the query using this suggestion,
2. Compare performance and accuracy,
3. Decide whether this tradeoff makes sense — and when it might.

**Business logic & definitions:**
* Total discount per year = `SUM(L_EXTENDEDPRICE * L_DISCOUNT)` for all shipped items
* Refactor strategy: `SUM(L_EXTENDEDPRICE) * AVG(L_DISCOUNT)`

### Query to optimise

```sql
-- Original: computes row-level discount then aggregates by year
SELECT
  YEAR(L.L_SHIPDATE) AS SHIP_YEAR,
  SUM(L.L_EXTENDEDPRICE * L.L_DISCOUNT) AS TOTAL_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM L
GROUP BY SHIP_YEAR;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Try separating the components of the formula:
- `L_EXTENDEDPRICE`: total gross value
- `L_DISCOUNT`: average discount per group

You can calculate both **per year**, then apply the formula once per group — avoiding the row-level math.

But don’t assume faster means better — test both performance and output.

#### Helpful SQL concepts

`GROUP BY`, `YEAR()`, `SUM`, `AVG`, performance reasoning

```sql
SELECT SUM(value) * AVG(rate)
FROM table
GROUP BY date_key;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Refactored query

```sql
SELECT
  YEAR(L.L_SHIPDATE) AS SHIP_YEAR,
  SUM(L.L_EXTENDEDPRICE) AS GROSS_REVENUE,
  AVG(L.L_DISCOUNT) AS AVG_DISCOUNT,
  SUM(L.L_EXTENDEDPRICE) * AVG(L.L_DISCOUNT) AS ESTIMATED_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM L
GROUP BY SHIP_YEAR;
```

#### Performance and result comparison

In practice:
* You may observe **slightly faster runtime** for the refactored query (e.g., 1.2–1.4×), especially on cold cache.
* Both queries scan the same rows and partitions — but the second version avoids per-row multiplication.
* Results will differ: the original gives **exact discount totals**, while the refactor gives **an estimate** using group-level aggregates.
* `SUM(gross) * AVG(discount)` can **over- or underestimate** total discounts applies the **same average discount to all revenue**

#### Business answer

This refactor provides **only minor compute savings** and the result is **no longer mathematically exact**.

For production financial reporting, you'd certainly prefer the precise version.

#### Take-aways

* Don't default to refactoring unless it has **meaningful impact** — in this case, the change is minor.
* Use **group-level estimation** for speed when:
  - Precision is not affected (e.g. simple arithmatics)
  - Precision isn’t critical (e.g. high-level KPIs)
  - Or you’re working with very large datasets.
* Be aware that small query shape differences can affect **result accuracy** — not just cost.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Repeat both queries, but only for line items with `L_QUANTITY > 50`.  
Does narrowing the dataset change the performance difference between the approaches?

</details>
