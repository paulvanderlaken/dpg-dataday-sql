## ex56: Build a Reusable Keyword Search Procedure with Dynamic SQL

> **Type:** Stretch | **Track:** Query Optimizer  
>
> **Difficulty:** 6 / 10

### Business context
The audit team frequently scans **comment fields** in the TPCH datasets — such as:
- `S_COMMENT` from `SUPPLIER`
- `O_COMMENT` from `ORDERS`
- `C_COMMENT` from `CUSTOMER`

Their current workflow requires manually writing one-off queries for each table, column, and keyword — a repetitive and error-prone process.

You’ve been asked to create a **general-purpose stored procedure** that lets the team call:

```sql
CALL search_table_by_keyword('SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER', 'S_COMMENT', 'unusual');
```

…and dynamically return all records from that table where the specified comment column contains the keyword.

Your solution must:
- Be dynamic (handle any table/column)
- Be safe (use bind parameters, not string injection)
- Be reusable across TPCH datasets

### Query to rewrite
```sql
-- Static version: searches one specific table and column
SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER
WHERE S_COMMENT ILIKE '%unusual%';
```

---

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* (Any others that contain comment-style fields)

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

1. Define a **stored procedure** with 3 inputs:
   - Table name (as full string path)
   - Column name
   - Keyword to search for

2. Create a new variable like `keyword_pattern := '%' || keyword || '%'`.

3. Construct the query string with a `?` placeholder for the pattern.

4. Use `EXECUTE IMMEDIATE :sql USING (keyword_pattern)` — not inline expressions!

5. Return the `RESULTSET` using `RETURN TABLE(rs)`.

#### Helpful SQL concepts

`CREATE PROCEDURE`, `EXECUTE IMMEDIATE`, `RESULTSET`, parameter binding

```sql
EXECUTE IMMEDIATE :sql USING (pattern);
RETURN TABLE(rs);
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

<details>
<summary> Note: you might need to <b>create a database</b> to store the procedure in. </summary>

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

</details>

#### Working procedure

```sql
CREATE OR REPLACE PROCEDURE search_table_by_keyword(
    target_table STRING,
    target_column STRING,
    keyword STRING
)
RETURNS TABLE ()
LANGUAGE SQL
AS
$$
DECLARE
  rs RESULTSET;
  dyn_sql STRING;
  keyword_pattern STRING;
BEGIN
  -- Step 1: Build LIKE pattern
  keyword_pattern := '%' || keyword || '%';

  -- Step 2: Construct dynamic SQL using parameter placeholder
  dyn_sql := 'SELECT * FROM ' || target_table || 
             ' WHERE ' || target_column || 
             ' ILIKE ?';

  -- Step 3: Execute with bind variable
  rs := (EXECUTE IMMEDIATE :dyn_sql USING (keyword_pattern));

  -- Step 4: Return result
  RETURN TABLE(rs);
END;
$$;
```

#### Example usage

```sql
CALL search_table_by_keyword(
  'SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER',
  'S_COMMENT',
  'unusual'
);
```
Try a few other tables yourself!

#### Why this works

This procedure wraps keyword-based filtering into a **generic, safe, and callable utility**:
- Accepts flexible input across tables and columns
- Avoids SQL injection and parsing issues by using `?` and `USING`
- Returns the full matching result set

It allows analysts to **repeatedly query for suspicious or tagged terms** without rewriting SQL each time.

#### Business answer

This utility enables fast audits across TPCH tables. For example, it identifies all suppliers whose comments include the word `'unusual'` — or any other keyword of interest.

#### Take-aways

* Use dynamic SQL only when structure (table, column) must change — not just values.
* Always use `?` + `USING` for secure bind parameter injection.
* `RETURN TABLE(rs)` lets stored procedures return full dynamic query outputs.
* This pattern is powerful for **text audits, anomaly flagging, and QA tools**.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Update the procedure to:
- Accept a **limit** parameter (e.g., `INT DEFAULT 10`)
- Return only the first N matching rows

Then extend usage to run:

```sql
CALL search_table_by_keyword('SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS', 'O_COMMENT', 'pending');
```

Can you also log the dynamic SQL that was executed?

</details>
