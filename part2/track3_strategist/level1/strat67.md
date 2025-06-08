## ex67: Total Revenue per Entity

> **Type:** Core | **Track:** Business Strategist  
>
> **Difficulty:** 3 / 10

### Business context
Leadership wants to better understand which entities (customers, suppliers, or other key actors) are most valuable in terms of total transaction volume. This initial view will focus on **total revenue per customer**, giving us a ranked list to guide further analysis or dashboarding.

This output can directly feed into dashboards, strategic prioritization decks, or support entity-level KPI development.

**Business logic & definitions:**
* Net revenue: `L_EXTENDEDPRICE * (1 - L_DISCOUNT)`
* Customer revenue: Sum of net revenue across all line items linked to their orders

### Starter query
```sql
-- Preview of relevant fields for linking customer, order, and line item
SELECT
    C_CUSTKEY,
    C_NAME,
    O_ORDERKEY,
    L_EXTENDEDPRICE,
    L_DISCOUNT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
  ON O.O_ORDERKEY = L.L_ORDERKEY
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

This is a classic 3-table join problem. You need to:
- Join `CUSTOMER` to `ORDERS`, and `ORDERS` to `LINEITEM`
- Derive revenue at the line item level
- Aggregate revenue per customer using `GROUP BY`

To rank or sort them by revenue, use `ORDER BY`.

#### Helpful SQL concepts

`JOIN`, `GROUP BY`, `SUM`, arithmetic expressions, `ORDER BY`

```sql
SELECT column, SUM(expr) 
FROM … 
GROUP BY column 
ORDER BY SUM(expr) DESC;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
SELECT
    C.C_NAME,
    C.C_CUSTKEY,
    SUM(L.L_EXTENDEDPRICE * (1 - L.L_DISCOUNT)) AS TOTAL_REVENUE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
  ON O.O_ORDERKEY = L.L_ORDERKEY
GROUP BY
    C.C_NAME, C.C_CUSTKEY
ORDER BY TOTAL_REVENUE DESC;
```

#### Why this works

We first join the three tables using their natural keys, then compute revenue per line item, and finally group by customer. By ordering the result, we can immediately see which customers contributed the most to total revenue.

#### Business answer

The result identifies which customers generated the highest total revenue, serving as a starting point for prioritization or performance tracking.

#### Take-aways

* The TPCH schema links customers to orders and line items using `C_CUSTKEY → O_CUSTKEY → L_ORDERKEY`.
* `L_EXTENDEDPRICE * (1 - L_DISCOUNT)` is the standard revenue definition in TPCH.
* Sorting your output makes it immediately insight-ready for dashboards and rankings.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Can you add a column showing how much of the total revenue is driven by a single customer?
Can you add a second column showing the percentile each record is at, when it comes to total revenue?

</details>
