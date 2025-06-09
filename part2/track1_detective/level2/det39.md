## ex39: Flag VIP Overrides for Strategic Exceptions

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
- Include a `FLAGGED_AT` timestamp in your insert
- Keep previous flags intact

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

- Use `NTILE(10)` to find the top 10% by orders or revenue
- Use `UNION` to combine both sets
- Write to a temporary staging table if your `INSERT` would follow a CTE
- Use `CURRENT_TIMESTAMP()` for traceability

This is an **additive** operation — don’t remove previous flags.

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Step 1: Add timestamp column (if missing)

```sql
ALTER TABLE WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags
ADD COLUMN FLAGGED_AT TIMESTAMP;
```

#### Step 2: Add status definition for override

```sql
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.status_dim
VALUES (99, 'vip_override', 'flag removed: customer qualifies as VIP');
```

#### Step 3: Create temporary staging table for VIPs

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

#### Step 4: Insert VIP override flags

```sql
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags (C_CUSTKEY, STATUS_ID, FLAGGED_AT)
SELECT
    C_CUSTKEY,
    99 AS STATUS_ID,
    CURRENT_TIMESTAMP()
FROM vip_customers;
```

#### Why this works

This approach avoids removing previous audit entries, while clearly documenting which customers have been strategically excluded.  
Using a timestamp allows full traceability across pipeline runs.

#### Business answer

All VIP customers now have a clearly labeled override flag (`status_id = 99`) in the audit log, without deleting historical flags.

#### Take-aways

* Audit flags should be additive, not destructive
* Use `TEMP TABLES` to enable INSERTs after CTEs
* Always track changes with a timestamp
* Strategic exceptions must be modeled clearly and documented centrally

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Create a joined audit log view showing:
- `CUSTKEY`
- `C_NAME`
- `STATUS_FLAG`
- `FLAGGED_AT`
- A derived column `IS_VIP_OVERRIDE` using `CASE WHEN STATUS_ID = 99 THEN TRUE ELSE FALSE`

This forms the basis for a governance dashboard or reviewer interface.

</details>
