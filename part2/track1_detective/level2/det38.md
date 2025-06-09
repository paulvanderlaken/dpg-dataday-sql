## ex38: Flag VIP Overrides for Strategic Exceptions

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 7 / 10

### Business context
After reviewing your audit logs, a senior stakeholder raises a concern:  
> "Some of the customers flagged for negative balances are actually our top clients. Please make sure our pipeline reflects this — but don’t delete history. Add a new flag instead, so we can track these overrides."

You've been asked to:
- Define VIP customers as those in the **top 10%** for either:
  - Number of orders
  - Total revenue
- Add a new audit flag (`status_id = 99`) for these VIPs
- Override any previous flag for this group

This exercise models how audit pipelines evolve to include **strategic business context**, while preserving **full data lineage**.

**Business logic & definitions:**
* VIP customers:
  * Top 10% by order count **OR**
  * Top 10% by total revenue (`L_EXTENDEDPRICE * (1 - L_DISCOUNT)`)
* Flag these customers using:
  * `STATUS_ID = 99`
  * `FLAGGED_AT = CURRENT_TIMESTAMP()`
* Don’t remove other flags — this is an override, not a correction

---

### Starter queries

```sql
-- Step 1: Add FLAGGED_AT column to the audit table (if not already present)
ALTER TABLE WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags
ADD COLUMN FLAGGED_AT TIMESTAMP;
```

```sql
-- Step 2: Add override flag to the status dimension
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.status_dim
VALUES (99, 'vip_override', 'flag removed: customer qualifies as VIP');
```

```sql
-- Step 3: Explore customer order counts to shape VIP definition
SELECT
    O_CUSTKEY,
    COUNT(*) AS num_orders
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
GROUP BY O_CUSTKEY
ORDER BY num_orders DESC
LIMIT 10;
```

---

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`
* `WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags`
* `WORKSHOP_DB.TEMP_SCHEMA.status_dim`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

- Use `NTILE(10)` to isolate the top 10% by either count or revenue
- Combine both customer lists using `UNION`
- Snowflake doesn’t allow `INSERT` to follow `WITH`, so use a `TEMP TABLE` to stage your VIPs
- Always timestamp your inserts

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Step 1: Add VIP override flag to status dimension

```sql
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.status_dim
VALUES (99, 'vip_override', 'flag removed: customer qualifies as VIP');
```

#### Step 2: Identify VIPs and store them in a temp table

```sql
CREATE OR REPLACE TEMP TABLE vip_customers AS
WITH order_counts AS (
    SELECT
        O_CUSTKEY,
        COUNT(*) AS num_orders
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
    GROUP BY O_CUSTKEY
    QUALIFY NTILE(10) OVER (ORDER BY COUNT(*) DESC) = 1
),
order_values AS (
    SELECT
        o.O_CUSTKEY,
        SUM(l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT)) AS total_revenue
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
      ON o.O_ORDERKEY = l.L_ORDERKEY
    GROUP BY o.O_CUSTKEY
    QUALIFY NTILE(10) OVER (ORDER BY SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) DESC) = 1
)
SELECT O_CUSTKEY AS C_CUSTKEY
FROM order_counts
UNION
SELECT O_CUSTKEY FROM order_values;
```

#### Step 3: Insert override flags

```sql
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags (C_CUSTKEY, STATUS_ID, FLAGGED_AT)
SELECT
    C_CUSTKEY,
    99 AS STATUS_ID,
    CURRENT_TIMESTAMP()
FROM vip_customers;
```

#### Step 4: View results

```sql
SELECT
    f.C_CUSTKEY,
    c.C_NAME,
    s.status_flag,
    s.status_description,
    f.FLAGGED_AT
FROM WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags AS f
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
  ON f.C_CUSTKEY = c.C_CUSTKEY
JOIN WORKSHOP_DB.TEMP_SCHEMA.status_dim s
  ON f.status_id = s.status_id
ORDER BY f.C_CUSTKEY, f.status_id
LIMIT 20;
```

#### Why this works

This approach preserves all historical audit flags, while clearly marking those customers who are considered exceptions due to strategic importance. The timestamp ensures full traceability for later analysis or rollback.

#### Business answer

All VIP customers now have a clearly labeled override flag (`status_id = 99`) in the audit log, and the time of their exemption was logged accurately.

#### Take-aways

* Use additive logic to maintain a full audit trail
* Always timestamp inserts for traceability and debugging
* Model business exceptions in a transparent and durable way
* Snowflake requires staging when inserting after CTEs — `TEMP TABLE` solves this

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Create a joined audit log showing:
- `CUSTKEY`
- `C_NAME`
- `STATUS_FLAG`
- `FLAGGED_AT`
- A `CASE`-based column that flags whether the row is a VIP override (`IS_VIP_OVERRIDE`)

This sets up a final summary view for stakeholder review.

</details>
