## ex69: Average Value per Transaction Entity (1997 Only)

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 3 / 10

### Business context
Your team wants to evaluate **average order value per customer**, but only for orders placed during the year **1997**. This scoped analysis will help compare performance during a single calendar year and support benchmarking or targeted reviews.

**Business logic & definitions:**
* Net revenue: `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* Order revenue: sum of net revenue across line items per order
* Average order value (AOV): total revenue / number of orders
* Time scope: only include `O_ORDERDATE` in 1997

### Starter query
```sql
-- Preview of 1997 orders and related customer and line item fields
SELECT
    C.C_NAME,
    O.O_ORDERKEY,
    O.O_ORDERDATE,
    L.L_EXTENDEDPRICE,
    L.L_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
  ON O.O_ORDERKEY = L.L_ORDERKEY
WHERE O.O_ORDERDATE BETWEEN '1997-01-01' AND '1997-12-31'
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Use a **CTE** to:
1. Filter to orders in 1997
2. Aggregate net revenue at the **order level**
3. Then group by customer to compute AOV

Use `BETWEEN '1997-01-01' AND '1997-12-31'` to constrain the timeframe.

#### Helpful SQL concepts

`CTE`, `JOIN`, `WHERE`, `GROUP BY`, `AVG`, `ROUND`

```sql
WITH subquery AS (
  SELECT …
  WHERE O_ORDERDATE BETWEEN …
)
SELECT …
FROM subquery
GROUP BY …;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
WITH order_revenue_1997 AS (
    SELECT
        O.O_ORDERKEY,
        O.O_CUSTKEY,
        SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS ORDER_REVENUE
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
      ON O.O_ORDERKEY = L.L_ORDERKEY
    WHERE O.O_ORDERDATE BETWEEN '1997-01-01' AND '1997-12-31'
    GROUP BY O.O_ORDERKEY, O.O_CUSTKEY
)
SELECT
    C.C_NAME,
    C.C_CUSTKEY,
    COUNT(ORV.O_ORDERKEY) AS NUM_ORDERS_1997,
    SUM(ORV.ORDER_REVENUE) AS TOTAL_REVENUE_1997,
    ROUND(AVG(ORV.ORDER_REVENUE), 2) AS AVG_ORDER_VALUE_1997
FROM order_revenue_1997 ORV
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
  ON ORV.O_CUSTKEY = C.C_CUSTKEY
GROUP BY C.C_NAME, C.C_CUSTKEY
ORDER BY AVG_ORDER_VALUE_1997 DESC;
```

#### Why this works

The inner CTE computes revenue per order within 1997. The outer query aggregates this per customer, giving a clean and scoped AOV view.

#### Business answer

This result shows which customers placed the highest-value orders during 1997 — a useful lens for reviewing historical client performance.

#### Take-aways

* Adding a date filter in the CTE is a clean way to scope an analysis.
* Two-step aggregation is a key pattern for entity-level summaries.
* AOV is a powerful normalized metric to compare across customers.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Can you return **only customers who placed more than 3 orders in 1997**?

Hint: Use `HAVING COUNT(…) > 3` at the customer aggregation level.

</details>
