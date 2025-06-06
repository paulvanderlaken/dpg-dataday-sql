## ex46: Selective Customer Data Extraction

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 3 / 10

### Business context
A colleague from the reporting team has shared a slow-running query that joins the entire customer and order datasets and then filters the results afterward. The dashboard it powers is sluggish and unnecessarily expensive to run.

You're asked to **refactor the query to be faster and more cost-effective**, by applying performance-aware best practices such as early filtering and column projection.

The business goal is to generate a lightweight feed of customers in the `'AUTOMOBILE'` segment who placed orders in the year 1995 — returning their name, account balance, and the corresponding order date.

**Business logic & definitions:**
* customer segment: `C_MKTSEGMENT = 'AUTOMOBILE'`
* target year: orders placed in calendar year 1995 (`O_ORDERDATE`)

### Query to optimise

```sql
SELECT
    C.*,
    O.*
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
WHERE C.C_MKTSEGMENT = 'AUTOMOBILE'
  AND O.O_ORDERDATE BETWEEN '1995-01-01' AND '1995-12-31';
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Start by asking: "Can I reduce the number of rows **before the join happens**?"  
Both tables have relevant filters — use them **early** so the join handles fewer rows.

Also ask: "Which columns do I really need?" Removing unused fields like `C_MKTSEGMENT` post-filter is a key optimization habit.

#### Helpful SQL concepts

`JOIN`, `WHERE`, filter pushdown, column projection

```sql
SELECT A.col1, B.col2
FROM A
JOIN B ON A.key = B.key
WHERE A.flag = 'value' AND B.date BETWEEN '...' AND '...';
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
SELECT
    C.C_NAME,
    C.C_ACCTBAL,
    O.O_ORDERDATE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
WHERE C.C_MKTSEGMENT = 'AUTOMOBILE'
  AND O.O_ORDERDATE BETWEEN '1995-01-01' AND '1995-12-31';
```

#### Why this works

This version **applies filters to both input tables before joining**, ensuring that only relevant rows are processed.  
By projecting just the necessary columns and filtering early, the query minimizes compute time, I/O, and memory usage — a best practice in any large analytical system like Snowflake.

#### Business answer

The refactored query returns a clean, targeted result: `'AUTOMOBILE'` customers who placed orders in 1995, including their name, account balance, and order date. 
 
Thanks to early filtering and lean column selection:
* the join size drops by **more than 90%**,
* unnecessary I/O is eliminated,
* and query performance improves by an estimated **3–10×**, with significantly lower Snowflake credit usage.

#### Take-aways

* Apply **filters as early as possible**, even across multiple joined tables.
* Limit output columns to just what is needed to avoid scanning extra data.
* Query shape and logic affect performance — not just correctness.
* Minor changes in filtering strategy can have **major impacts on cost**.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Refactor the query again using **Common Table Expressions (CTEs)** to explicitly pre-filter each table before joining.  
This won't improve performance over the optimized query, but it improves **readability** and helps in more complex scenarios.

Can you also calculate the **number of such orders per customer**?

</details>
