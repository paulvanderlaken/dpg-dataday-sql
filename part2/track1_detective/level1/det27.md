## ex27: Identify Customers with No Orders

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 3 / 10

### Business context
As part of your audit initiative, the operations lead has asked for a review of **customer activity records**. There are concerns that some accounts were imported from legacy systems but never became active — possibly due to onboarding issues or incomplete migrations.

Your task is to identify all customers who **have never placed a single order** — and store them in a separate table for further investigation by the customer success team.

**Business logic & definitions:**
* Inactive customer: a record in `CUSTOMER` that has **no matching orders** in `ORDERS`
* Matching logic: link on `C_CUSTKEY = O_CUSTKEY`
* Output: store results in `WORKSHOP_DB.TEMP_SCHEMA.inactive_customers`

### Starter query
```sql
-- Preview the customer table
SELECT
    C_CUSTKEY,
    C_NAME,
    C_MKTSEGMENT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

You're detecting **orphaned records**: customers that exist in the system but never made a transaction.

Use a `LEFT JOIN` from `CUSTOMER` to `ORDERS` to retain all customers. Then apply a filter:  
```sql
WHERE O_ORDERKEY IS NULL
```

This is called an **anti-join**, and it's one of the most reliable ways to catch “missing” relationships.

Once you're confident the logic works, wrap it inside a `CREATE TABLE AS` to persist it for later audits.

#### Helpful SQL concepts

`LEFT JOIN`, `IS NULL`, `CREATE TABLE AS`

```sql
-- Anti-join pattern
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
-- Step 1: Create a table of inactive customers
CREATE OR REPLACE TABLE WORKSHOP_DB.TEMP_SCHEMA.inactive_customers AS
SELECT
    c.C_CUSTKEY,
    c.C_NAME,
    c.C_MKTSEGMENT,
    c.C_ACCTBAL
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
  ON c.C_CUSTKEY = o.O_CUSTKEY
WHERE o.O_ORDERKEY IS NULL;
```

```sql
-- Step 2: View your audit result
SELECT * FROM WORKSHOP_DB.TEMP_SCHEMA.inactive_customers
ORDER BY C_CUSTKEY;
```

#### Why this works

The `LEFT JOIN` ensures all customers are kept, even if they didn’t place any orders. Filtering on `O_ORDERKEY IS NULL` isolates those with no match.

You’ve also saved this to your audit schema, so this list can be handed off to the customer success team for follow-up actions.

#### Business answer

There are hundreds of customer records that never placed an order — potentially abandoned signups or incomplete data migrations.

#### Take-aways

* Anti-joins (`LEFT JOIN … IS NULL`) are essential tools for data integrity audits
* These patterns scale well to many-to-many and complex multi-table joins
* Persisting orphaned records in dedicated tables allows downstream remediation
* Every pipeline or data model needs tests for “presence of expected links”

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Group the inactive customers by `C_MKTSEGMENT` and count how many appear in each. Store this as a summary table:  
`WORKSHOP_DB.TEMP_SCHEMA.inactive_customer_counts_by_segment`

This will support visualizations or alerts by segment type.

</details>
