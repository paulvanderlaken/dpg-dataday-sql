## ex25: Create Your Audit Workspace + Tag Reference Table

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 2 / 10

### Business context
Before beginning your audit journey, you'll need a safe environment to work in. Since the TPch dataset is read-only, you'll create your **own database and schema** to stage flagged records, persist intermediate results, and simulate downstream processing.

To make this concrete, you'll also create your first helper table: a reference list of **suspicious keywords** — in this case, food-related terms — that may indicate inconsistency or legacy naming patterns in the product catalog.

This small setup task will power future audit steps.

**Business logic & definitions:**
* Your working schema: `WORKSHOP_DB.TEMP_SCHEMA`
* Audit helper table: `tag_keywords`
* Food-related terms of interest: `'almond'`, `'tomato'`, `'chocolate'`, `'vanilla'`, `'peach'`

### Starter query
```sql
-- Preview your current context (should not be SNOWFLAKE_SAMPLE_DATA)
SELECT CURRENT_DATABASE(), CURRENT_SCHEMA();
```

### Required datasets

* Your own schema: `WORKSHOP_DB.TEMP_SCHEMA`
* Manually created helper table: `tag_keywords`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

You're creating a **personal staging environment**. In Snowflake, session context (like `USE DATABASE`) only takes effect *after* you run it — so you **must run each step one at a time**, in order.

**Steps:**
1. Run the `CREATE DATABASE` first — this makes the top-level workspace.
2. Then create the `SCHEMA`.
3. After that, use both `USE DATABASE` and `USE SCHEMA` to activate your context.
4. Now you're ready to create your first table.
5. Insert values into it.
6. Finally, query it.

Don't run them all together — Snowflake will throw errors if you try to insert before context is properly set.

#### Helpful SQL concepts

`CREATE DATABASE`, `CREATE SCHEMA`, `USE`, `CREATE TABLE`, `INSERT`, `SELECT`

```sql
-- Example reference table
CREATE TABLE my_schema.my_table (term STRING);
INSERT INTO my_table VALUES ('apple'), ('banana');
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Step-by-step: Run each block individually

```sql
-- Step 1: Create your database
CREATE OR REPLACE DATABASE WORKSHOP_DB;
```

```sql
-- Step 2: Create your schema
CREATE OR REPLACE SCHEMA WORKSHOP_DB.TEMP_SCHEMA;
```

```sql
-- Step 3: Set your session context
USE DATABASE WORKSHOP_DB;
USE SCHEMA TEMP_SCHEMA;
```

```sql
-- Step 4: Create the reference tag table
CREATE OR REPLACE TABLE tag_keywords (
    tag_label STRING
);
```

```sql
-- Step 5: Insert suspicious terms
INSERT INTO tag_keywords (tag_label)
VALUES 
    ('almond'),
    ('tomato'),
    ('chocolate'),
    ('vanilla'),
    ('peach');
```

```sql
-- Step 6: Preview your helper table
SELECT * FROM tag_keywords;
```

#### Why this works

Snowflake requires that `USE DATABASE` and `USE SCHEMA` be executed *before* you attempt to create or query unqualified tables. Running everything at once can result in "table not found" or context-related errors.

You've now established your own working environment and created your first reusable reference table for audit logic.

#### Business answer

You’ve successfully initialized an audit environment and seeded a helper table to flag suspicious naming conventions. This enables modular and scalable audit workflows going forward.

#### Take-aways

* Always separate **source** data (e.g. TPCH) from **audit/output** layers
* Run `USE` commands *before* trying to query or create unqualified tables
* Helper tables simplify logic and make your SQL more maintainable and extensible
* Running complex logic as **isolated steps** avoids cascading errors

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a second column to `tag_keywords` to indicate the **category** of each term. For example, mark all current tags as `"food"`, but imagine in the future you might also want to flag `"color"` or `"material"` tags too.

Update your table to include this structure and reload the values accordingly.

</details>
