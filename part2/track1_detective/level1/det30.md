## ex30: Top 0.1% Largest Orders by Revenue

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 4 / 10

### Business context
Sales leadership wants to identify the **largest revenue-generating orders overall** — the elite 0.1% of orders that contribute disproportionately to business results.

Your task is to find these top orders by total net revenue after discounts and label them accordingly.

**Business logic & definitions:**
* net revenue per line item = `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* total order net revenue = sum of net revenue for all line items in an order


### Starter query
```sql
-- Preview orders and line items
SELECT
    o.O_ORDERKEY,
    l.L_EXTENDEDPRICE,
    l.L_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
  ON o.O_ORDERKEY = l.L_ORDERKEY
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

1. Aggregate line items into total net revenue per order.
2. Compute the 99.9th percentile revenue cutoff using `PERCENTILE_CONT`.
3. Filter to orders exceeding that cutoff.
4. Add a column `order_category` set to `'top_0.1_percent'`.

#### Helpful SQL concepts

`WITH`, `JOIN`, `GROUP BY`, `PERCENTILE_CONT`, literal columns

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH order_revenue AS (
  SELECT
    L_ORDERKEY,
    SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS total_net_revenue
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
  GROUP BY L_ORDERKEY
),
percentile_cutoff AS (
  SELECT
    PERCENTILE_CONT(0.999) WITHIN GROUP (ORDER BY total_net_revenue) AS cutoff
  FROM order_revenue
)
SELECT
  L_ORDERKEY,
  total_net_revenue,
  'top_0.1_percent' AS order_category
FROM order_revenue, percentile_cutoff
WHERE total_net_revenue > cutoff
ORDER BY total_net_revenue DESC;
```

#### Why this works

This query finds the 99.9th percentile cutoff and returns all orders exceeding it, tagging them clearly with the label `'top_0.1_percent'`.

#### Business answer

This identifies the highest revenue orders for strategic attention and risk management.

#### Take-aways

* Adding literal columns (labels) helps contextualize output for downstream use
* Percentile-based filtering enables dynamic anomaly detection, ensuring your logic will keep performing in changing environments
* CTEs simplify modular, readable query design

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Find the **bottom 0.1% smallest orders** by total net revenue and, after labelling the records, **combine** with the top orders. This provides perspective on both revenue extremes.

</details>
