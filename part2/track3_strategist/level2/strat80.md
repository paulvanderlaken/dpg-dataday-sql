## ex80: Evolving Margin–Revenue Alignment — Correlation Over Time

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 9 / 10

### Business context
Over the past months, you’ve helped the CFO understand where profitability aligns — or misaligns — with sales volume. But leadership wants to go one step further:  
**Is this relationship improving over time?**  
Are our **pricing and margin strategies** working — or drifting?

One final task in the "Margin Matters" initiative is to **calculate the correlation between product revenue and margin for each year** and deliver a year-over-year table that shows how this relationship evolves.

This analysis will help detect whether **recent years show stronger alignment**, or whether high revenue continues to mask low profitability.

**Business logic & definitions:**
* Net revenue = `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* Cost = `PS_SUPPLYCOST * L_QUANTITY`
* Margin % = `(Revenue − Cost) / Revenue * 100`
* Each year’s correlation = `CORR(total_revenue, margin_pct)` **across all parts in that year**
* Each part’s metrics are calculated **per year** (based on order date)

### Starter query
```sql
-- Check how sales dates relate to margin drivers
SELECT
    L.L_PARTKEY,
    L.L_EXTENDEDPRICE,
    L.L_DISCOUNT,
    PS.PS_SUPPLYCOST,
    L.L_QUANTITY,
    O.O_ORDERDATE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP PS
    ON L.L_PARTKEY = PS.PS_PARTKEY AND L.L_SUPPKEY = PS.PS_SUPPKEY
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

1. Join `LINEITEM` to `ORDERS` and `PARTSUPP`
2. Truncate `O_ORDERDATE` to year
3. For each `(PARTKEY, YEAR)`, calculate:
   - Total revenue
   - Margin %
4. Then, for each year, run `CORR(total_revenue, margin_pct)` across all parts

Optional: filter to post-1994 years to ensure meaningful sample sizes.

#### Helpful SQL concepts

`DATE_TRUNC`, `CORR`, nested aggregation, `GROUP BY`

```sql
-- Sample correlation pattern
SELECT DATE_TRUNC('YEAR', O_ORDERDATE) AS year, CORR(x, y) FROM …
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
)

SELECT
    order_year,
    COUNT(*) AS num_parts,
    ROUND(CORR(total_revenue, margin_pct), 4) AS revenue_margin_corr
FROM part_year_metrics
GROUP BY order_year
ORDER BY order_year;
```

#### Why this works

This solution calculates yearly correlation between total revenue and margin %, using part-level aggregates per year. It captures the **evolving relationship** between these key financial metrics.

#### Business answer

The CFO now has year-by-year visibility into whether high sales volumes are more consistently tied to strong margins.  
There indeed seems to be a relationship of around `0.15`, signalling that products generating high revenue tend to have slightly better margins.
However, while consistent, the relationship is weak. This suggests that while recent margin improvements may be helping, there is still a need to actively monitor and manage top-selling products, as revenue does not reliably predict profitability.

#### Take-aways

* Introduced statistical tracking using SQL (`CORR`)
* Combined time-based aggregation with performance analysis
* Delivered a compact, insight-rich table ready for line chart visualization

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Use Snowflake's worksheet charting to plot this table as a **line graph** over time.  
Then:  
- Filter to parts in the top 25% by revenue per year  
- Recalculate the correlation **only for that subset** — is the alignment stronger or weaker among top sellers?

</details>
