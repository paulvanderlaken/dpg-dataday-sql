## ex37: Append New Audit Flags for Duplicate Customer Records

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 6 / 10

### Business context
As the audit trail grows, new patterns of concern are emerging. This time, your stakeholders have noticed several customer accounts showing a **negative balance** — which could point to data entry mistakes, invalid refunds, or untracked credit activity.

Your task is to:
- Identify customers with a negative balance
- Define your own **audit flag** and **status description**
- Insert those flags into the shared audit log using `status_id = 2`
- Return the table showing all flagged customers 

> 🎯 This is a chance to define a flag that your stakeholders will **actually understand**. Use meaningful naming.

**Business logic & definitions:**
* A customer with `C_ACCTBAL < 0` should be flagged
* Reruns should clean out old `status_id = 2` entries first
- Then **summarize the full audit trail**, grouped by flag and description


### Starter code
```sql
-- Step 2: Add a new audit flag definition for negative balances

-- Delete previous status_id = 2 (clean rerun)
DELETE FROM WORKSHOP_DB.TEMP_SCHEMA.status_dim WHERE status_id = 2;

-- ✏️ Replace the values below with your own meaningful label and description
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.status_dim (
    status_id,
    status_flag,
    status_description
) VALUES (
    2,
    '{insert your flag name}}',  -- replace this string
    '{insert your flag description}}'  -- replace this string
);
```

> Note, if you are using a flag or description containing more characters than you've defined/allowed in exercise 36, Snowflake will throw an error!

```sql
-- Step 3: Preview customers with negative balances
SELECT
    C_CUSTKEY,
    C_NAME,
    C_ACCTBAL
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
WHERE C_ACCTBAL < 0
ORDER BY C_ACCTBAL;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags`
* `WORKSHOP_DB.TEMP_SCHEMA.status_dim`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

This is a **classic anomaly flag** — simple condition, but real business impact.

Start with:
- A clear and concise `status_flag` name (max 50 characters)
- A readable `status_description` (e.g. 100–200 characters)
Then:
- Use a basic `INSERT INTO … SELECT` to push those customer keys into the fact table

You don't need to store names or balances — only the key and flag reference.

#### Helpful SQL concepts

`DELETE`, `INSERT`, `WHERE`, `JOIN`, incremental pipeline logic

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Step 1: Clean up previous flag version

```sql
DELETE FROM WORKSHOP_DB.TEMP_SCHEMA.status_dim WHERE status_id = 2;
```

#### Step 2: Insert custom label for this anomaly

```sql
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.status_dim (
    status_id,
    status_flag,
    status_description
) VALUES (
    2,
    'neg_balance',
    'account shows negative balance, likely due to refund or data issue'
);
```

#### Step 3: Append negative-balance customers to audit flags

```sql
INSERT INTO WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags (C_CUSTKEY, STATUS_ID)
SELECT
    C_CUSTKEY,
    2 AS status_id
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
WHERE C_ACCTBAL < 0;
```

#### Step 4: Summarize enriched output

```sql
SELECT
    s.status_flag,
    s.status_description,
    COUNT(DISTINCT f.C_CUSTKEY) AS flagged_customers
FROM WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags f
JOIN WORKSHOP_DB.TEMP_SCHEMA.status_dim s
  ON f.status_id = s.status_id
GROUP BY s.status_flag, s.status_description
ORDER BY flagged_customers DESC;
```

#### Why this works

You’ve introduced a clean new audit rule without touching prior logic. Your fact table grows by appending — your labels live in one place — and you maintain full interpretability.

This pattern allows you to scale your audit framework by just adding new flags and targeting new anomalies.

#### Business answer

You’ve flagged dozens of customers for negative balances and produced a clean audit summary showing all flagged categories so far.

#### Take-aways

* Use conditions (`WHERE`) to define anomaly types
* Separate flag labels from the data itself
* Always check and clean flags before re-running logic
* Good flag design communicates intent and value clearly

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Modify your logic so that **only customers who are not already flagged with `status_id = 2`** are inserted.

This ensures your audit table doesn’t accumulate duplicate flags.

(Hint: use `WHERE NOT EXISTS` or `LEFT JOIN … IS NULL` against `customer_audit_flags`)

</details>