## ex47: Early Order Filtering with Date Range

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 3 / 10

### Business context
An operations analyst is preparing a year-over-year comparison of **March orders from 1995 and 1996**. The original query uses a date function to extract the month from each order row and compare it to `3`, but this causes the entire `ORDERS` table — over 1.5 million rows — to be scanned.

Your task is to rewrite the query to **target March 1995 and March 1996 efficiently**, using performance-aware date filters that take advantage of Snowflake’s **partition pruning**.

**Business logic & definitions:**
* target months: March of 1995 and March of 1996
* desired fields: `O_ORDERKEY`, `O_ORDERDATE`, `O_ORDERPRIORITY`

### Query to optimise

```sql
-- Inefficient: disables pruning by using EXTRACT()
SELECT
    O_ORDERKEY,
    O_ORDERDATE,
    O_ORDERPRIORITY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
WHERE EXTRACT(MONTH FROM O_ORDERDATE) = 3
  AND EXTRACT(YEAR FROM O_ORDERDATE) IN (1995, 1996);
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Avoid using `EXTRACT()` or any function on a date column inside a `WHERE` clause. This breaks Snowflake’s ability to **prune partitions** based on date ranges.

Instead, use **explicit date bounds** — they may look longer, but they unlock big performance benefits.

#### Helpful SQL concepts

`WHERE`, partition pruning with multiple OR’ed date ranges

```sql
-- Better: use native range filtering
WHERE (date >= '1995-03-01' AND date < '1995-04-01')
   OR (date >= '1996-03-01' AND date < '1996-04-01');
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
SELECT
    O_ORDERKEY,
    O_ORDERDATE,
    O_ORDERPRIORITY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
WHERE (O_ORDERDATE >= '1995-03-01' AND O_ORDERDATE < '1995-04-01')
   OR (O_ORDERDATE >= '1996-03-01' AND O_ORDERDATE < '1996-04-01');
```

#### Why this works

This rewritten query uses **two precise date ranges**, one for each March. Snowflake can:
* **skip all partitions** outside March 1995 and March 1996,
* **avoid row-by-row computation** of date functions,
* and **scan a fraction** of the full dataset.

All while returning the exact same result.

Plus, the query is arguably more readible, as each `WHERE` statement reflects an isolated, intentional filter, with the demarcations mentioned explictly. 

#### Business answer

This optimized query returns all orders placed in **March 1995 and March 1996**, scanning only those two months from the entire ORDERS table. Compared to the original:

* Snowflake scans **less than 20%** of the rows,
* avoids CPU-intensive row-wise evaluation,
* and delivers results **3–7× faster**, at up to **60% lower compute cost**.

#### Take-aways

* Avoid `EXTRACT()` on filtered columns if you care about performance.
* Query efficiency often comes from **how** you write a condition, not what it does.
* Do not forget about readability and understandability while optimizing for performance.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Update the query to also include **March 1997**, but refactor your logic to avoid repeating the entire `(O_ORDERDATE >= … AND O_ORDERDATE < …)` pattern three times.

Can you write a **CTE or derived table** to store date boundaries for reuse?

</details>
