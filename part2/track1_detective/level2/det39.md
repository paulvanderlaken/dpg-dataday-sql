## ex38: Inspect the Raw Audit Log Using Time Travel

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 7 / 10

### Business context
After implementing several audit rules — including an override for VIP customers — your team wants to assure **your ability to review how the audit trail evolved**.

You're asked to use **Snowflake's Time Travel** feature to:
- Look back at the audit table as it existed earlier
- Re-run the audit summary at that historical point
- Compare that to the current state

This simulates how real audit and data teams **trace the effect** of inserts and overrides over time.

Consult the following: [Snowflake docs — AT | BEFORE](https://docs.snowflake.com/en/sql-reference/constructs/at-before)

**Business logic & definitions:**
* `customer_audit_flags` holds all audit flag records
* `status_dim` explains what each `status_id` means
* You should have added a new audit flag for negative balances (`status_id = 2`) and VIPs (`status_id = 99`)
* Use `AT(TIMESTAMP => …)` or `AT(OFFSET => …)` to view the audit log before and after

---

### Starter queries

```sql
-- Step 1: Save the current timestamp BEFORE inserting new flags
SELECT CURRENT_TIMESTAMP();
-- 📝 Copy this timestamp — you can adjust it for usage
```

```sql
-- Step 2: Preview current raw audit records with full description
SELECT
    s.status_flag,
    s.status_description,
    COUNT(DISTINCT f.C_CUSTKEY) AS flagged_customers
FROM WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags f
JOIN WORKSHOP_DB.TEMP_SCHEMA.status_dim s
  ON f.status_id = s.status_id
```

### Required datasets

* `WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags`
* `WORKSHOP_DB.TEMP_SCHEMA.status_dim`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Use `CURRENT_TIMESTAMP()` *before* you run an `INSERT`. That gives you a safe checkpoint for `AT(TIMESTAMP => …)`.

If you forgot to capture a timestamp, or can’t find the exact insert statement, use a **large OFFSET like -1000** — this often rewinds far enough to give you the last "clean" version of the table.

If the raw rows aren’t different, your Time Travel isn’t far back enough.

#### Helpful SQL concepts

`AT(TIMESTAMP => …)`, `AT(OFFSET => …)`, table history, pipeline verification

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Step 1: Save timestamp

```sql
SELECT CURRENT_TIMESTAMP();
-- Example: '2025-06-09 12:40:00'
```

#### Step 2: Current audit rows

```sql
SELECT
    f.C_CUSTKEY,
    c.C_NAME,
    s.status_flag,
    s.status_description,
    f.FLAGGED_AT
FROM WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags f
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
  ON f.C_CUSTKEY = c.C_CUSTKEY
JOIN WORKSHOP_DB.TEMP_SCHEMA.status_dim s
  ON f.status_id = s.status_id
ORDER BY f.C_CUSTKEY, f.status_id
LIMIT 20;
```

#### Step 3a: Audit rows before the insert (via timestamp)

```sql
SELECT
    f.C_CUSTKEY,
    c.C_NAME,
    s.status_flag,
    s.status_description,
    f.FLAGGED_AT
FROM WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags AT(TIMESTAMP => '2025-06-09 12:40:00') f --replace with your relevant datetime
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
  ON f.C_CUSTKEY = c.C_CUSTKEY
JOIN WORKSHOP_DB.TEMP_SCHEMA.status_dim s
  ON f.status_id = s.status_id
ORDER BY f.C_CUSTKEY, f.status_id
LIMIT 20;
```

#### Step 3b: Audit rows before the insert (via OFFSET)

```sql
SELECT
    f.C_CUSTKEY,
    c.C_NAME,
    s.status_flag,
    s.status_description,
    f.FLAGGED_AT
FROM WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags AT(OFFSET => -1000) f --try to replace this with different offset
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
  ON f.C_CUSTKEY = c.C_CUSTKEY
JOIN WORKSHOP_DB.TEMP_SCHEMA.status_dim s
  ON f.status_id = s.status_id
ORDER BY f.C_CUSTKEY, f.status_id
LIMIT 20;
```

#### Why this works

This technique lets you validate and trace **specific pipeline changes** — without snapshot tables or manual backups. You can always look back at what changed, when, and why.

#### Business answer

The customers flagged for negative balances (`status_id = 2`) and those who got (re)flagged as VIPs (`status_id = 3`) are now clearly visible in the current audit log — and absent in the version(s) that came before their insertion. You’ve confirmed exactly what changed.
Going forward, you can now confidently demonstrate which customers were added by a specific rule, and when.

#### Take-aways

* Time Travel is a powerful way to validate and trace changes and record-level comparisons
* This pattern supports pipeline certification, rollback, and QA
* `AT(OFFSET => -N)` is a simple but powerful way to rewind history
* Consider adding `as_of_dt` with the `CURRENT_TIMESTAMP()` to create a lineage

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Can you think of a way in which to keep the original flags (like the negative balance) in the database, even for VIPs?

</details>
