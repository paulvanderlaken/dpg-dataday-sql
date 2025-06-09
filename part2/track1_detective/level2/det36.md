## ex36: Model an Efficient Audit Flag for Inactive Customers

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 6 / 10

### Business context
As part of your forensic audit responsibilities, you’ve been asked to flag all customers who have **never placed an order** and output an annotated table showing:

- the customer name
- the audit status (`'inactive'`)
- a status description (`'no order record found as of audit'`)

This result will be shown to internal stakeholders — but must be **stored efficiently** in the audit pipeline.

Rather than writing full names and descriptions into a wide table, your task is to build a **lean audit model** using **separate dimension and fact tables**.

Do not forget to add a timestamp to each record to indicate when they were flagged in the audit. 

**Business logic & definitions:**
* Inactive customer: present in `CUSTOMER` but with **no orders** in `ORDERS`
* Status ID: `'1'`
* Status flag: `'inactive'`
* Status description: `'no order record found as of audit'`
* Fact table output: `WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags`
* Dimension table: `WORKSHOP_DB.TEMP_SCHEMA.status_dim`

### Starter queries

```sql
-- Step 1: Identify customers with no matching orders
SELECT
    c.C_CUSTKEY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
  ON c.C_CUSTKEY = o.O_CUSTKEY
WHERE o.O_ORDERKEY IS NULL
LIMIT 10;
```

```sql
-- Step 2: Create the status dimension table (explicitly define column types!)
CREATE OR REPLACE TABLE WORKSHOP_DB.TEMP_SCHEMA.status_dim (
    status_id INTEGER,
    status_flag VARCHAR(50),
    status_description VARCHAR(200)
);

-- Educational note:
-- ❗ Snowflake will infer very short column lengths if you use `CREATE TABLE AS SELECT`
-- For example, it might set VARCHAR(8) if your first value is `'inactive'`,
-- causing later inserts with longer flags or descriptions to fail.
```

```sql
-- Step 3: Insert your first audit label
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.status_dim
VALUES (1, 'inactive', 'no order record found as of audit');
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

While the final **visual output** includes name, status, and description — storing all of that in one table is costly and repetitive.

Instead:
- Store only customer key + status ID in your audit flag table
- Use the `status_dim` table to join in flags and descriptions when needed
- Reuse the `CUSTOMER` table for names rather than duplicating

This reflects efficient, real-world data modeling principles.

#### Helpful SQL concepts

`LEFT JOIN`, `IS NULL`, `CREATE TABLE`, dimension joins

```sql
-- Your fact table should store:
C_CUSTKEY | STATUS_ID | FLAGGED_AT

-- Then join to get:
C_NAME | STATUS_FLAG | STATUS_DESCRIPTION
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Step 1: Create the dimension table with explicit types

```sql
CREATE OR REPLACE TABLE WORKSHOP_DB.TEMP_SCHEMA.status_dim (
    status_id INTEGER,
    status_flag VARCHAR(50),
    status_description VARCHAR(200)
);
```

#### Step 2: Insert the first audit label

```sql
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.status_dim
VALUES (1, 'inactive', 'no order record found as of audit');
```

#### Step 3: Create the audit flag table

```sql
-- Step 4: Define the fact table schema explicitly with a timestamp
CREATE OR REPLACE TABLE WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags (
    C_CUSTKEY INTEGER,
    STATUS_ID INTEGER,
    FLAGGED_AT TIMESTAMP
  );
```

#### Step 4: Fill the audit flag table

```sql
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags (C_CUSTKEY, STATUS_ID, FLAGGED_AT)
SELECT
    c.C_CUSTKEY,
    1 AS status_id,
    CURRENT_TIMESTAMP
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
  ON c.C_CUSTKEY = o.O_CUSTKEY
WHERE o.O_ORDERKEY IS NULL;
```

#### Step 4: Reconstruct the full annotated output (on demand)

```sql
SELECT
    f.C_CUSTKEY,
    c.C_NAME,
    s.status_flag,
    s.status_description
    f.FLAGGED_AT
FROM WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags f
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
  ON f.C_CUSTKEY = c.C_CUSTKEY
JOIN WORKSHOP_DB.TEMP_SCHEMA.status_dim s
  ON f.status_id = s.status_id;
```

#### Why this works

This structure avoids repetitive storage of text-heavy audit labels and customer names. Instead, you’re storing **keys only** in the fact table and joining to reference dimensions when needed. This aligns with best practices in data warehousing and audit pipeline design. The timestamp allows for full traceability.

#### Business answer

Inactive customers have been flagged efficiently, using status IDs and a separate commentary table — making the audit layer both lean and interpretable.

#### Take-aways

* Always explicitly define schemas for shared tables — don’t rely on inferred structure
* Storing only keys makes audit tables efficient and maintainable
* Descriptions and names should be joined in only when needed
* This pattern mirrors star-schema thinking used in scalable pipelines

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add **two more status records** to your `status_dim` table:
- `2`, `'potential duplicate'`, `'matches similar customer name and contact info'`
- `3`, `'missing contact'`, `'customer has no listed email or phone'`

Think about how your `customer_audit_flags` table might support **multiple statuses per customer** in the future. What would change?

</details>
