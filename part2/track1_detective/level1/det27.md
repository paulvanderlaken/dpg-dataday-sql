## ex27: Customers Without Any Orders

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 3 / 10

### Business context
While reviewing our customer activity logs, the operations team noticed that some customer accounts appear to have **never placed an order**. This might indicate onboarding drop-off, abandoned registrations, or incomplete data imports.

You’ve been asked to identify which customers have **no matching orders** in our system.

**Business logic & definitions:**
* inactive customer: a record in `CUSTOMER` with **no corresponding entry** in the `ORDERS` table via `C_CUSTKEY = O_CUSTKEY`

### Starter query
```sql
-- Preview customer keys and a few other attributes
SELECT
    C_CUSTKEY,
    C_NAME,
    C_ACCTBAL
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Use a **LEFT JOIN** from `CUSTOMER` to `ORDERS` to preserve all customers — even those who don’t match. Then use `WHERE O_ORDERKEY IS NULL` to isolate those that never ordered.

This is known as an **anti-join** — a pattern that helps find missing links between tables.

#### Helpful SQL concepts

`LEFT JOIN`, `IS NULL`

```sql
SELECT …
FROM A
LEFT JOIN B ON A.key = B.key
WHERE B.key IS NULL;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
SELECT
    c.C_CUSTKEY,
    c.C_NAME,
    c.C_MKTSEGMENT,
    c.C_ACCTBAL
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
  ON c.C_CUSTKEY = o.O_CUSTKEY
WHERE o.O_ORDERKEY IS NULL
ORDER BY c.C_CUSTKEY;
```

#### Why this works

This query uses a `LEFT JOIN` to retain all customers, including those without orders. By filtering on `O_ORDERKEY IS NULL`, we isolate the customers who have **no orders recorded**.

#### Business answer

Thousands of customers appear in our database without any order history — an opportunity for re-engagement or data quality review.

#### Take-aways

* `LEFT JOIN + IS NULL` is the go-to pattern for detecting missing links
* Anti-joins are valuable for auditing relationships between datasets
* This pattern scales well to more complex relationship integrity checks

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Group the customers without orders by their **market segment (`C_MKTSEGMENT`)**. Which segments have the most inactive customers?

</details>
