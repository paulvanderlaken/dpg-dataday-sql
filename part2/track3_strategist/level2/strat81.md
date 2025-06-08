## ex81: Is It Real? Testing the Significance of Margin–Revenue Correlation

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 9 / 10

### Business context
You've shown the CFO that the **correlation between product margin and revenue** has evolved over the years. But now the executive team asks the obvious next question:

> “Can we trust these trends — or are they just statistical noise?”

As a final analytic step in the “Margin Matters” initiative, you're asked to **evaluate the statistical significance** of each year's correlation using hypothesis testing. This gives the finance team the confidence to act only on **meaningful signals**.

**Business logic & definitions:**
* Each year’s correlation `r` is based on all `(PARTKEY, YEAR)` combinations
* Significance is tested using a **t-test for Pearson correlation**
* The correlation is considered **statistically significant at 95% confidence** if:

```sql
t = (r * sqrt(n - 2)) / sqrt(1 - r^2)
```

Where:
- `r` = correlation coefficient
- `n` = sample size (number of parts for that year)

### Starter query
```sql
-- Confirm how part-year grouping relates to order dates
SELECT
    L.L_PARTKEY,
    O.O_ORDERDATE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
    ON L.L_ORDERKEY = O.O_ORDERKEY
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Build on the previous exercise by reusing the per-year correlation table. Then, add two things:
1. Sample size `n` per year (already included)
2. The formula for the test statistic:

```sql
r * SQRT(n - 2) / SQRT(1 - r * r)
```

Take the absolute value and compare to 1.96 to determine significance.

#### Helpful SQL concepts

`ABS()`, `ROUND()`, mathematical expressions

```sql
ABS(CORR * SQRT(n - 2) / SQRT(1 - CORR * CORR)) > 1.96
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH line_details AS (
    SELECT
        L.L_PARTKEY,
        DATE_TRUNC('YEAR', O.O_ORDERDATE) AS order_year,
        (L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS net_revenue,
        (PS.PS_SUPPLYCOST * L.L_QUANTITY) AS estimated_cost
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP PS
        ON L.L_PARTKEY = PS.PS_PARTKEY AND L.L_SUPPKEY = PS.PS_SUPPKEY
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
        ON L.L_ORDERKEY = O.O_ORDERKEY
),

part_year_metrics AS (
    SELECT
        L_PARTKEY,
        order_year,
        SUM(net_revenue) AS total_revenue,
        ROUND(
            (SUM(net_revenue) - SUM(estimated_cost)) / NULLIF(SUM(net_revenue), 0) * 100, 2
        ) AS margin_pct
    FROM line_details
    GROUP BY L_PARTKEY, order_year
),

correlation_with_n AS (
    SELECT
        order_year,
        COUNT(*) AS num_parts,
        ROUND(CORR(total_revenue, margin_pct), 4) AS revenue_margin_corr
    FROM part_year_metrics
    GROUP BY order_year
)

SELECT
    order_year,
    num_parts,
    revenue_margin_corr,
    ROUND(
        revenue_margin_corr * SQRT(num_parts - 2) / SQRT(1 - revenue_margin_corr * revenue_margin_corr), 3
    ) AS t_statistic,
    CASE
        WHEN ABS(
            revenue_margin_corr * SQRT(num_parts - 2) / SQRT(1 - revenue_margin_corr * revenue_margin_corr)
        ) > 1.96 THEN TRUE
        ELSE FALSE
    END AS is_significant
FROM correlation_with_n
ORDER BY order_year;
```

#### Why this works

This query builds on the prior correlation logic and applies the **Pearson significance test** formula directly in SQL. It produces:
- `t_statistic`
- A final flag `is_significant`

This allows the CFO to **distinguish signal from noise** in margin-revenue alignment trends.

#### Business answer

Only a subset of years shows statistically meaningful correlation between product margin and revenue. Those years can be used to **validate pricing and sourcing policies** — others may require deeper investigation or be treated with caution.

#### Take-aways

* Performed real statistical testing entirely in SQL
* Learned how to evaluate the **strength and reliability** of business correlations
* Equipped decision-makers with both **trend** and **confidence**

</details>

<summary>🎁 Bonus Exercise (click to expand)</summary>

**Segment-Level Correlation Insight**

The CFO suspects that certain customer groups (e.g. government buyers or infrastructure firms) behave differently in terms of margin vs revenue alignment.

Your task:

1. Join in the `CUSTOMER` table and assign each order to a `C_MKTSEGMENT`
2. For each `(year, segment)` combination:

   * Calculate the correlation between `total_revenue` and `margin_pct`
3. Output a table like:

| order\_year | segment    | num\_parts | revenue\_margin\_corr |
| ----------- | ---------- | ---------- | --------------------- |
| 1996        | AUTOMOBILE | 142        | 0.34                  |
| 1996        | BUILDING   | 119        | -0.12                 |
| …           | …          | …          | …                     |

This allows stakeholders to identify **which segments are driving the strongest (or weakest) margin-revenue relationships**, and helps focus commercial strategies accordingly.

</details>
