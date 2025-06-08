## ex77: Profit Margin per Product — Bottom & Top

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 6 / 10

### Business context
The executive team at TPCH Industries has launched a profitability initiative called **"Margin Matters"** to identify which products deliver true financial value — not just high revenue, but solid margins. The CFO suspects that several bestsellers may actually **erode profitability** due to hidden supply costs.

Your task: build a table that calculates the **net margin percentage** per part, sorted from least to most profitable. This foundational analysis will guide product line rationalization and shape promotional strategy for the upcoming fiscal year.

However, the executive board wants sharper focus: not just a full list, but a direct spotlight on the **most and least profitable parts** in the entire product catalog.

Identifying these margin outliers will allow the CFO to both:
- Trim unprofitable items dragging down the bottom line
- Double down on high-margin winners in future campaigns

You’ve been asked to deliver a table with the **top 5 and bottom 5 parts** ranked by **net profit margin**. Be mindful of accurate arithmetic and guard against divide-by-zero errors.

**Business logic & definitions:**
* Net revenue: `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* Estimated cost: `PS_SUPPLYCOST * L_QUANTITY`
* Profit margin (%): `(Revenue − Cost) / Revenue * 100`
* Top/bottom logic must be based on computed margin, not total revenue
* Ensure parts with zero revenue do not cause division errors

### Starter query
```sql
-- Preview unit revenue and cost mechanics
SELECT
    L.L_PARTKEY,
    L.L_SUPPKEY,
    L.L_EXTENDEDPRICE,
    L.L_DISCOUNT,
    PS.PS_SUPPLYCOST,
    L.L_QUANTITY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP PS
    ON L.L_PARTKEY = PS.PS_PARTKEY AND L.L_SUPPKEY = PS.PS_SUPPKEY
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Instead of repeating long `SUM(...)` expressions inside arithmetic, use a CTE to pre-calculate revenue and cost per sale, then aggregate them per part. This simplifies your final margin formula and avoids duplicated logic.

Use `NULLIF` in the denominator of the margin calculation to safely handle parts that have no revenue.

To return both **top 5 and bottom 5**, consider assigning a `RANK()` twice — once ascending, once descending — and then use `WHERE` or `QUALIFY` to keep only those 10 rows.

#### Helpful SQL concepts

`JOIN`, `WITH`, `SUM`, `ROUND`, `NULLIF`, `RANK()`, `UNION ALL`

```sql
ROUND((SUM(revenue) - SUM(cost)) / NULLIF(SUM(revenue), 0) * 100, 2)
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH line_details AS (
    SELECT
        L.L_PARTKEY,
        P.P_NAME,
        (L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS net_revenue,
        (PS.PS_SUPPLYCOST * L.L_QUANTITY) AS estimated_cost
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP PS
        ON L.L_PARTKEY = PS.PS_PARTKEY AND L.L_SUPPKEY = PS.PS_SUPPKEY
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
        ON L.L_PARTKEY = P.P_PARTKEY
),

part_margins AS (
    SELECT
        L_PARTKEY,
        P_NAME,
        ROUND((SUM(net_revenue) - SUM(estimated_cost)) / NULLIF(SUM(net_revenue), 0) * 100, 2) AS profit_margin_pct
    FROM line_details
    GROUP BY L_PARTKEY, P_NAME
),

ranked AS (
    SELECT *,
           RANK() OVER (ORDER BY profit_margin_pct ASC) AS bottom_rank,
           RANK() OVER (ORDER BY profit_margin_pct DESC) AS top_rank
    FROM part_margins
)

SELECT L_PARTKEY, P_NAME, profit_margin_pct, 'Top 5' AS category
FROM ranked
WHERE top_rank <= 5

UNION ALL

SELECT L_PARTKEY, P_NAME, profit_margin_pct, 'Bottom 5' AS category
FROM ranked
WHERE bottom_rank <= 5
ORDER BY category, profit_margin_pct;
```

#### Why this works

This query separates detailed row-level math from the aggregation step, avoids repeated expressions, and uses double ranking to extract top and bottom performers. The use of `NULLIF` protects against revenue-less products causing division errors.

#### Business answer

The CFO now has a focused list of **5 margin leaders** and **5 margin laggards**, enabling fast decision-making on retention, renegotiation, or retirement.

The least profitable items — including several parts with **negative margins** — are now clearly identifiable and can be considered for removal or renegotiation with suppliers.


#### Take-aways

* Learned to use layered `WITH` statements to simplify complex calculations
* Applied `RANK()` to perform symmetric top/bottom extraction
* Reinforced use of `NULLIF` for robust financial logic
* Saw how to avoid repeating long expressions in multiple places
* Built a clean, presentation-ready output table for executive stakeholders

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Flag any product that ranks in **both** the bottom 5 for margin and the **top 10 for total revenue**. These are potentially dangerous bestsellers — large sales volume but minimal profitability — and should be flagged as "Revenue Traps".

</details>