## ex56: Parameterised Procedure for Total Revenue Calculation

> **Type:** Core | **Track:** Query Optimizer
>
> **Difficulty:** 5 / 10

### Business context

Finance teams often need quick revenue totals for ad-hoc queries—monthly campaign checks, quarter closes, or regulatory filings. Right now analysts copy-paste a hard-coded SQL snippet and adjust the dates by hand, an error-prone workflow. You’ve been asked to refactor that query into a **reusable stored procedure** that takes a start and end date as parameters and returns the total revenue for the period.

**Business logic & definitions:**

* **Order revenue:** `SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))`
* **Time window:** `O_ORDERDATE` between the supplied `p_start_date` and `p_end_date` (inclusive)
* **Total revenue:** a single numeric value summarising all order revenue in the window


### Query to rewrite

```sql
-- Hard-coded version: total revenue for calendar year 1995
SELECT
    SUM(l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT)) AS total_revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS   o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
  ON l.L_ORDERKEY = o.O_ORDERKEY
WHERE o.O_ORDERDATE BETWEEN '1995-01-01' AND '1995-12-31';
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

1. Wrap the logic in `CREATE OR REPLACE PROCEDURE … (p_start_date DATE, p_end_date DATE)`.
2. Use `DECLARE` to create a variable for the revenue total.
3. Execute `SELECT … INTO :variable` to assign the aggregate.
4. `RETURN variable;` at the end of the block.
5. Test with `CALL total_revenue_proc('1996-01-01','1996-03-31');`.

#### Helpful SQL concepts

`CREATE OR REPLACE PROCEDURE`, `DECLARE`, `SELECT … INTO`, `RETURN`, `DATE` literals

```sql
CREATE OR REPLACE PROCEDURE demo_proc(p_start DATE, p_end DATE)
RETURNS NUMBER
LANGUAGE SQL
AS
$$
DECLARE rev NUMBER;
BEGIN
  SELECT SUM(...) INTO :rev
  FROM …
  WHERE … BETWEEN :p_start AND :p_end;
  RETURN rev;
END;
$$;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working procedure

```sql
CREATE OR REPLACE PROCEDURE total_revenue_proc(
    p_start_date DATE,
    p_end_date   DATE
)
RETURNS NUMBER
LANGUAGE SQL
AS
$$
DECLARE
  v_revenue NUMBER;
BEGIN
  SELECT  SUM(l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT))
    INTO  :v_revenue
  FROM    SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS   o
  JOIN    SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
         ON l.L_ORDERKEY = o.O_ORDERKEY
  WHERE   o.O_ORDERDATE BETWEEN :p_start_date AND :p_end_date;

  RETURN v_revenue;
END;
$$;
```

> Note: You might need to **create a database** to store the procedure in.

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


#### Why this works

* **Parameterised dates** make the logic reusable for any timeframe.
* `SELECT … INTO` stores the aggregate in a variable, and `RETURN` emits it as the procedure’s result.
* The query scans the joined tables exactly once, keeping the plan simple and efficient.

#### Business answer

Calling

```sql
CALL total_revenue_proc('1995-01-01','1995-12-31');
```

returns a single number—the total sales revenue for calendar-year 1995.

#### Take-aways

* Turning static SQL into a procedure removes hard-coded literals and copy-paste risk.
* Input parameters convert the query into a callable mini-API for dashboards, tasks, or external tools.
* Small, single-purpose procedures are easy to test, version, and grant execute rights on.
* Always ensure date parameters are **inclusive** so totals align with financial reporting periods.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

**Extend the procedure** with an optional customer filter:

```sql
CREATE OR REPLACE PROCEDURE total_revenue_proc(
    p_start_date DATE,
    p_end_date   DATE,
    p_cust_key   NUMBER DEFAULT NULL
)
```

*If `p_cust_key` is `NULL`* → return revenue for **all** customers.
*Else* → return revenue only for that customer.
Hint: add

```sql
AND (:p_cust_key IS NULL OR o.O_CUSTKEY = :p_cust_key)
```

to the `WHERE` clause.

</details>
