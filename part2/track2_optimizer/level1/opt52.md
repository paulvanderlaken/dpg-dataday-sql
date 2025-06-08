## ex52: IN or JOIN? Let the Query Profiler Decide

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 4 / 10

### Business context
The customer analytics team wants a list of all customers who placed at least one order during 1995. A junior analyst writes a query using `IN (SELECT …)` to filter those customers. Another teammate suggests this might be inefficient, and recommends rewriting it as a `JOIN`.

You're brought in to help settle the debate.

Your task is to write **both versions** of the query — one using `IN (SELECT)` and the other using `JOIN` — and then **compare their performance** using Snowflake’s Query Profile. Which version is actually faster on TPCH SF1000?

**Business logic & definitions:**
* Only include customers with at least one order between `1995-01-01` and `1995-12-31`.
* The TPCH data is clean: every order has a customer, and no `NULL`s are involved.

### Starter query
```sql
-- Preview some order dates and their customers
SELECT
    O_ORDERKEY,
    O_CUSTKEY,
    O_ORDERDATE
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

You're comparing two logically equivalent queries:
- One using `IN (SELECT)` to check for existence of an order
- One using `JOIN` and filtering on order date

Your goal is not just correctness, but to **diagnose which approach Snowflake handles more efficiently**. Use the **Query Profile** to examine:
- Partitions scanned
- Time spent per stage
- Bytes spilled or materialized

#### Helpful SQL concepts

`IN (SELECT)`, `JOIN`, filter pushdown, semi-joins, `DISTINCT`

```sql
-- Query A: IN (SELECT …)
-- Query B: JOIN … ON … WHERE …
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Query A — Using IN (SELECT)

```sql
SELECT C.C_CUSTKEY, C.C_NAME
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER C
WHERE C.C_CUSTKEY IN (
    SELECT O_CUSTKEY
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS
    WHERE O_ORDERDATE BETWEEN '1995-01-01' AND '1995-12-31'
);
```

#### Query B — Using JOIN

```sql
SELECT DISTINCT C.C_CUSTKEY, C.C_NAME
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER C
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS O
  ON C.C_CUSTKEY = O.O_CUSTKEY
WHERE O.O_ORDERDATE BETWEEN '1995-01-01' AND '1995-12-31';
```

#### Why this works

Both queries return the same customers — but their **execution paths differ**:

- Query A uses `IN`, which Snowflake internally rewrites as a **semi-join**.
- Query B performs a full `JOIN`, which may produce duplicates — hence the need for `DISTINCT`.

In Snowflake, **Query A is often faster**:
- It avoids joining and de-duplicating entire result sets.
- It leverages semi-join optimization with early filter pruning.
- You can confirm this by inspecting the **Query Profile**: look at partition pruning, scan duration, and data exchanged.

#### Business answer

Both queries return identical results, but **the `IN (SELECT)` version executed ~10% faster**, avoided a full join, and used fewer compute resources on SF1000.

#### Take-aways

* In Snowflake, `IN (SELECT)` is **not slow** — it’s often rewritten efficiently.
* Use `IN` for **existence checks** and `JOIN` for **enrichment**.
* Always validate assumptions using Query Profile — not outdated SQL folklore.
* `DISTINCT` adds overhead; avoid it unless necessary.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Update your queries to return **how many 1995-ordering customers** exist in each market segment.

Use `GROUP BY C_MKTSEGMENT`, and compare whether `IN` or `JOIN` still performs better.

</details>
