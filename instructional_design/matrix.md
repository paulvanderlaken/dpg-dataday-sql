# 🧭 Snowflake SQL Workshop Roadmap

This full-day workshop is structured across two parts:

- **Part 1** builds baseline fluency and confidence in SQL querying, with dedicated exercises for beginners, intermediate, and advanced users.
- **Part 2** splits into three thematic learning tracks — each deepening specific skill sets — again offered at two specific capability-levels.

---

## 🚦 Part 1: Core SQL Fluency

| Level              | Exercises      | Skills & Focus Areas                                                                 |
|-------------------|----------------|---------------------------------------------------------------------------------------|
| 1: Beginner | ex01–ex10   | Filtering, joining, grouping basics | Learn to extract, sort, and combine relevant data from key TPCH tables             |
| 2: Intermediate | ex11–ex20 | Aggregates, derived logic, time filtering | Add business logic, derived metrics, and multi-table design                         |
| 3: Advanced | ex21–ex25   | Windows, cohorts, statistical flags   | Track growth, rank entities, flag outliers with advanced SQL patterns               |

---

## 🎯 Part 2: Thematic Mastery Tracks

Each track builds from a Level 1 (Intermediate) base and ascends to Level 2 (Advanced). All are self-contained but benefit from strong Part 1 fundamentals.

### 🔍 Track 1: SQL Detective

| Level | Exercises    | Skills & Focus Areas                                                    |
|-------|--------------|---------------------------------------------------------------------------|
| 1: Beginner → Intermediate | ex25–ex30   | Detect gaps, nulls, missing records; pattern matching; suspicious records |
| 2: Intermediate → Advanced | ex36–ex40   | Audit flag modeling, version tracking with Time Travel, dimensional enrichment |

> **Ideal for:** Analysts auditing pipelines, ensuring data completeness, or building operational flags.

---

### ⚙️ Track 2: Query Optimizer

| Level | Exercises    | Skills & Focus Areas                                                               |
|-------|--------------|---------------------------------------------------------------------------|
| 1: Beginner → Intermediate | ex46–ex54   | Filter pushdown, column pruning, subquery rewrites, CASE vs mapping joins |
| 2: Intermediate → Advanced | ex55–ex61   | Procedural SQL, dynamic thresholds, JSON handling, window vs GROUP BY benchmarking |

> **Ideal for:** Analysts and engineers optimizing query performance and compute efficiency in Snowflake.

---

### 🧠 Track 3: Business Strategist

| Level | Exercises    | Focus Areas                                                               |
|-------|--------------|---------------------------------------------------------------------------|
| 1: Beginner → Intermediate | ex67–ex73   | Time trends, segment growth, product share, per-nation rankings |
| 2: Intermediate → Advanced | ex74–ex81   | Profitability mapping, volume vs margin quadrants, correlation analysis, significance testing |

> **Ideal for:** Commercial, finance, or strategy analysts using SQL for performance insights and data storytelling.

---



## 🚦 Part 1: Core SQL Fluency

#### Level 1: Beginner

| Ex # | Title | Business Question | SQL Concept | Difficulty | Dataset Familiarity Focus |
| :----: | -------------------------------------- | ------------ | ---------------------------------------------------------- | :---------: | ---------------------------------------------------------- |
| ex01 | Top 10 Customers by Balance | “Which customers should we prioritise for a loyalty programme based on balances?” | `SELECT` + `ORDER BY` + `LIMIT` | 2 | **CUSTOMER**: C_CUSTKEY, C_NAME, C_ACCTBAL |
| ex02 | Filter Q1 Orders with Priority | “Which high-priority orders were placed in Q1 1995?” | `WHERE` with `AND`, date filtering | 2 | **ORDERS**: O_ORDERDATE, O_ORDERPRIORITY |
| ex03 | Top 3 Orders from the BUILDING Segment | “Which high-value orders came from customers in the BUILDING segment?” | `JOIN` + `WHERE` + `ORDER BY` + `LIMIT` | 2 | **ORDERS**, **CUSTOMER** |
| ex04 | Count Customers by Segment | “How many customers belong to each market segment?” | `GROUP BY` + `COUNT(*)` | 2 | **CUSTOMER**: C_MKTSEGMENT |
| ex05 | High-Quantity or Low-Price Lineitems | “Which line items qualify for bulk discounts or promotions?” | `WHERE` with `AND/OR` | 2 | **LINEITEM**: L_QUANTITY, L_EXTENDEDPRICE, L_DISCOUNT |
| ex06 | Compare Table Sizes – Parts vs Suppliers | “How many records exist in the PART and SUPPLIER tables?” | `COUNT(*)` + `UNION ALL` + aliasing | 2 | **PART**, **SUPPLIER** |
| ex07 | Find Smallest Parts with Longest Names | “Which small parts have the longest names?” | `ORDER BY` + `LENGTH()` + aliasing + `LIMIT` | 3 | **PART**: P_NAME, P_SIZE |
| ex08 | Count Orders Containing Almond Products | “How many unique orders included a part with ‘almond’ in its name?” | `JOIN`, `ILIKE`, `COUNT(DISTINCT)` | 2 | **PART**, **LINEITEM** |
| ex09 | Suspected Suppliers with Missing Comments | “Identify suppliers lacking commentary.” | `IS NULL` / `IS NOT NULL` | 1 | **SUPPLIER**: S_SUPPKEY, S_NAME, S_COMMENT |
| ex10 | Compute Price + Tax | “What would each line item cost including a 5 % tax?” | Arithmetic in `SELECT` | 2 | **LINEITEM**: L_EXTENDEDPRICE, basic math expr |

----

#### Level 2: Intermediate

| Ex # | Title | Business Question | SQL Concept | Difficulty | Dataset Familiarity Focus |
| :----: | ---------------------------------------- | ------------ | --------------------------------------- | :---------: | -------------------------------------------------------------------- |
| ex11 | Revenue by Part and Discount Tier | “Which parts generated the most revenue in 1998, and how does this vary by discount tier?” | `GROUP BY` + `SUM` + expression logic | 4 | **LINEITEM**: P_PARTKEY, L_EXTENDEDPRICE, L_DISCOUNT, date filter |
| ex12 | High-Volume Parts with Tiered Revenue | “Which parts sold ≥ 1 000 units and generated over $100 K in revenue?” | `HAVING` on multiple aggregates | 5 | **LINEITEM**: aggregate quantity and extended price |
| ex13 | Orders per Customer in 1995 | “List each customer’s orders placed in 1995, including name, nation, and order date.” | `INNER JOIN` + date filtering | 4 | **ORDERS**, **CUSTOMER**, **NATION** |
| ex14 | Detailed Order Feed with Derived Cost | “Build a full order-detail feed including extended price after discount for each item.” | multi-table `JOIN` + expressions | 5 | **LINEITEM**, **ORDERS**, **PART** |
| ex15 | Customers with Recency and Order Count | “For each customer, show their most recent order date and total number of orders.” | Sub-query in `FROM` + `JOIN` | 6 | **CUSTOMER**, **ORDERS** |
| ex16 | Rank Orders with Total Spend | “Rank each customer’s orders by total spend (including discount), from highest to lowest.” | `ROW_NUMBER()` OVER () + expression | 6 | **ORDERS**, **LINEITEM** |
| ex17 | Supplier-Part List with Cost Flag | “Generate a supplier-part listing and flag if the supply cost is above average for that part.” | `WITH` / CTE + comparison to `AVG()` | 6 | **PARTSUPP**, **PART**, **SUPPLIER** |
| ex18 | Rewrite Scalar Sub-query to Count Line-items per Order | “Rewrite an inefficient per-order scalar sub-query that counts line items using a `JOIN` and `GROUP BY`.” | scalar sub-query vs `GROUP BY` rewrite | 6 | **ORDERS**, **LINEITEM** |
| ex19 | Deep-Discount Line-items per Order | “Find the top 5 line items per order with the highest discount rates above 10 %.” | `RANK()` + `PARTITION BY` + filter | 6 | **LINEITEM** |
| ex20 | Rolling Daily Revenue since 1 Jan 1996 | “Show daily cumulative sales for all orders shipped since 1 Jan 1996.” | `SUM()` OVER (ORDER BY) + date filter | 6 | **LINEITEM**, **ORDERS** |

#### Level 3: Advanced

| Ex # | Title | Business Question | SQL Concepts | Difficulty | Dataset Familiarity Focus |
| :----: | ---------------------------------------------------- | ------------ | ------------------------------------------------------------------------- | :---------: | --------------------------------------------------------------------------- |
| ex21 | Customer Cohort Revenue Growth | “Compare total revenue over time for each customer cohort (by first-purchase month).” | CTEs; window functions (`SUM OVER`, `ROWS BETWEEN`); date bucketing; joins | 8 | **CUSTOMER → ORDERS → LINEITEM** |
| ex22 | Top 3 Parts by Revenue in Each Region | “Find the highest-revenue parts in each region.” | Multi-level window (`RANK()`), hierarchical joins, CTEs | 8 | **REGION → NATION → SUPPLIER → PARTSUPP → LINEITEM** |
| ex23 | Rolling 3-Month Order Momentum by Segment | “How do different market segments ramp up in order activity over time, based on rolling 3-month order averages?” | `DATE_TRUNC`, `JOIN`, `GROUP BY`, `SUM() OVER (…)`, `ROWS BETWEEN` | 7 | **CUSTOMER**, **ORDERS** |
| ex24 | Top 10 Customers per Segment – Deep Dive (1995) | “Who were the top 10 customers by revenue per segment in 1995, and how do their order patterns and discount behaviour compare?” | `JOIN`, `GROUP BY`, `SUM()`, `COUNT()`, `AVG()`, `RANK() OVER (PARTITION BY …)` | 7 | **CUSTOMER**, **ORDERS**, **LINEITEM** |
| ex25 | High/Low-Discounting Suppliers per Segment | “Which suppliers gave unusually high or low discounts to the top 10 customers in each segment during 1995?” | `JOIN`, `GROUP BY`, `AVG()`, `STDDEV()`, `CASE`, `RANK()` | 9 | **LINEITEM**, **ORDERS**, **CUSTOMER**, **SUPPLIER** |

---

## 🎯 Part 2: Thematic Mastery Tracks

### 🔍 Track 1: SQL Detective

#### Level 1: Beginner → Intermediate

| Ex # | Title | Business Question | SQL Concept | Difficulty | Dataset Familiarity Focus |
| :----: | ---------------------------------------------- | -------------- | ------------------------------------- | :----------: | --------------------------------------------------- |
| ex25 | Create Audit Workspace + Tag Reference Table | “How can I create a safe audit schema and store a reusable list of suspicious naming patterns?” | `CREATE DATABASE`, `SCHEMA`, `TABLE`, `INSERT` | 2 | **WORKSHOP_DB.TEMP_SCHEMA** (set-up for audit use) |
| ex26 | Tag Parts Named After Keywords | “Which parts have names that match any suspicious keywords (like almond or chocolate)?” | `JOIN`, `ILIKE`, `CREATE TABLE AS` | 4 | **PART**, **tag_keywords** |
| ex27 | Customers without Any Orders | “Which customers appear in our system but have never placed an order?” | `LEFT JOIN` + `IS NULL` | 3 | **CUSTOMER**, **ORDERS** |
| ex28 | Parts never sold in 1996 | “Which parts were never sold during the year 1996?” | `LEFT JOIN`, date filtering | 4 | **PART**, **LINEITEM** |
| ex29 | Flag High-Discount, High-Quantity Items | “Which line items were sold in high quantity and at steep discounts?” | `WHERE`, compound filter, derive net revenue | 4 | **LINEITEM** |
| ex30 | Identify Top 0.1 % Revenue Orders | “Which orders generated the highest revenue — the top 0.1 % of all?” | `PERCENTILE_CONT`, `CTE`, `LABEL`, `CREATE TABLE AS` | 5 | **LINEITEM** |

#### Level 2: Intermediate → Advanced

#### Level 2: Intermediate → Advanced

| Ex # | Title                                               | Business Question                                                                                                          | SQL Concept                                              | Difficulty | Dataset Familiarity Focus |
| :--: | --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- | :--------: | -------------------------- |
| ex36 | Model an Efficient Audit Flag for Inactive Customers | How can we efficiently flag inactive customers while maintaining audit traceability?                                      | `CREATE TABLE`, `ALTER TABLE`, `INSERT`, `LEFT JOIN`, `TIMESTAMP` | 6 | Audit flag tables, customer & orders data |
| ex37 | Append New Audit Flags for Duplicate Customer Records | How can we flag customers showing negative balances while maintaining a clean and interpretable audit trail?              | `DELETE`, `INSERT`, conditional anomaly logic, `JOIN`    | 6 | Customer data with account balance |
| ex38 | Flag VIP Overrides for Strategic Exceptions         | How do we flag VIP customers as exceptions in the audit log without deleting previous flags?                              | `TEMP TABLE`, `NTILE`, `QUALIFY`, `INSERT`               | 7 | Orders, line-item revenue, audit tables |
| ex39 | Inspect the Raw Audit Log using Time Travel         | How can we use Snowflake Time Travel to compare audit log states before and after VIP overrides?                          | `AT(TIMESTAMP)`, `AT(OFFSET)`, audit trail verification  | 7 | Snowflake Time Travel on audit logs |
| ex40 | Build a Comprehensive Audit Staging View            | How can we synthesise all audit flags with customer metadata to enable business reporting and slicing?                    | `CREATE VIEW`, `JOIN`, dimension enrichment, `TIMESTAMP` | 8 | Audit logs enriched with customer, nation & region context |

---

### ⚙️ Track 2: Query Optimizer

#### Level 1: Beginner → Intermediate

| Ex # | Title | Business Question | SQL Concept | Difficulty | Dataset Focus |
| :----: | ---------------------------------------------------- | -------------------- | ----------------------------------------- | :----------: | ---------------- |
| ex46 | Selective Customer Data Extraction | “Extract `C_NAME`, `C_ACCTBAL`, and `C_MKTSEGMENT` for 'AUTOMOBILE' customers, joined with orders.” | column projection + `WHERE` + join | 3 | **CUSTOMER**, **ORDERS** |
| ex47 | Early Order Filtering with Date Range | “Retrieve all orders placed in March of 1995 and 1996, efficiently.” | `WHERE` with compound ranges (filter push-down) | 3 | **ORDERS** |
| ex48 | Top 5 Most-Expensive Line Items in Q2 1995 | “Which individual line items shipped in Q2 1995 had the highest net value?” | `ORDER BY` + `LIMIT`, early filter + CTE | 3 | **LINEITEM**, **ORDERS** |
| ex49 | Flagging Large or Valuable Shipments | “Which line items represent large-volume or high-value shipments, and how can we retrieve them efficiently?” | `UNION ALL` vs `WHERE`, column projection | 3 | **LINEITEM** |
| ex50 | Filter First, Not after the Join | “How can we avoid processing unnecessary rows when only certain flagged line items are relevant?” | `CASE`, filter push-down, CTE, early filtering | 4 | **LINEITEM**, **ORDERS** |
| ex51 | `LIKE` vs `ILIKE` Pattern Performance | “How many parts have names containing ‘green’? Explore performance difference using `LIKE` vs `ILIKE`.” | pattern-search inefficiency | 4 | **PART** |
| ex52 | Rewrite `IN (SELECT)` to Join | “List all customers who placed an order in 1995 — once using `IN (SELECT)` and once with a `JOIN`.” | sub-query vs join | 4 | **CUSTOMER**, **ORDERS** |
| ex53 | Fix the Filters — Cleaning up a Mis-fired Query | “How many parts are anodised, non-promotional, include green in their name, mention a key metal, and are in the bottom 10 % of prices?” | `ILIKE`, `NOT ILIKE`, `OR`, `PERCENTILE_CONT`, `WITH`, query cleanup | 4 | **PART** |
| ex54 | `CASE WHEN` vs Lookup Table | “Map customer segments to broader tiers using `CASE WHEN`. Then try replacing this with a small join.” | `CASE` logic vs mapping table | 4 | **CUSTOMER** |

#### Level 2: Intermediate → Advanced

| Ex # | Title | Business Question | SQL Concept | Difficulty | Dataset Familiarity Focus |
| :----: | --------------------------------------------------- | ------------------ | -------------------------------------------- | :----------: | ----------------------------------------------------------- |
| ex55 | Use `DECLARE` and `BEGIN…END` to Create Dynamic Threshold Logic | “How can we dynamically compute and reuse a revenue threshold for high-value orders in SQL?” | `DECLARE`, `SET`, `BEGIN…END`, control-flow | 7 | **LINEITEM** |
| ex56 | Build a Reusable Keyword Search Procedure with Dynamic SQL | “How can we scan different comment fields for keywords using one flexible SQL procedure?” | `EXECUTE IMMEDIATE`, dynamic SQL, `USING`, stored procedure | 6 | **SUPPLIER**, **ORDERS**, **CUSTOMER** (comments) |
| ex57 | Generate a JSON API Payload for Customer Order History | “How can we generate nested JSON for a customer’s monthly order history directly from SQL?” | `OBJECT_CONSTRUCT`, `ARRAY_AGG`, JSON nesting | 7 | **ORDERS**, **LINEITEM**, **PART**, **CUSTOMER**, **NATION** |
| ex58 | Parse Incoming JSON Order Payload into Rows | “How can we parse an incoming JSON order and flatten it into relational records?” | `FLATTEN`, `LATERAL`, `VARIANT`, JSON parsing | 7 | simulated input via `PARSE_JSON()` |
| ex59 | Tokenise and Flatten Supplier Comments for Text Mining | “How can we break down supplier comments into individual lowercase words for analysis?” | `REGEXP_REPLACE`, `LOWER`, `SPLIT`, `FLATTEN` | 7 | **SUPPLIER** (S_COMMENT) |
| ex60 | Nested Sub-queries vs Multi-Stage CTEs — Which Scales Better? | “How does query structure affect performance when computing revenue, margins, and derived metrics?” | sub-query vs multi-CTE refactor; performance comparison; `CASE`; `SUM`; `AVG` | 8 | **ORDERS**, **LINEITEM**, **PARTSUPP** |
| ex61 | Refactor Windowed Recency Logic with `JOIN` or `GROUP BY` | “What’s the fastest way to find the most recent order per customer — with correct results?” | `ROW_NUMBER()`, `QUALIFY`, `JOIN`, `GROUP BY`, performance trade-offs | 8 | **CUSTOMER**, **ORDERS** |

---

### Track 3: 🧠 Business Strategist

#### Level 1: Beginner → Intermediate

| Ex # | Title                                                  | Business Question                                                                                                                                    | SQL Concept                                        | Difficulty | Dataset Familiarity Focus                                    |
| :--: | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- | :--------: | ----------------------------------------------------------- |
| ex67 | Yearly Order Coverage and Summary Stats                | Which order years have full data coverage, and what are the gross revenue, discount, and tax totals for each year?                                  | `GROUP BY`, aggregates, `JOIN`                     |     3      | `ORDERS` + `LINEITEM`                                       |
| ex68 | Monthly Revenue Trend by Segment (Since 1997)          | How has monthly net revenue evolved since 1997 across customer segments?                                                                             | `DATE_TRUNC`, `GROUP BY`, segment joins            |     4      | `ORDERS` + `LINEITEM` + `CUSTOMER`                          |
| ex69 | Identify Top 10 Revenue-Generating Products            | Which parts generate the most net revenue, and what share of total company revenue do they represent?                                               | `GROUP BY`, windowed `SUM OVER ()`                 |     4      | `LINEITEM` + `PART`                                         |
| ex70 | Top 3 Products per Nation — Ranked Long Format         | For every nation, which three products drive the highest revenue?                                                                                   | `ROW_NUMBER`, `PARTITION BY`, `JOIN`s              |     5      | `CUSTOMER` + `ORDERS` + `LINEITEM` + `PART` + `NATION`      |
| ex71 | Pivoted Part Rankings per Nation — Executive View      | What are the top three revenue-generating parts in each nation, and what share of national revenue does each contribute, shown in a pivoted format? | `CASE WHEN`, `MAX()`, pivot reshaping              |     6      | `CUSTOMER` + `ORDERS` + `LINEITEM` + `PART` + `NATION`      |
| ex72 | Monthly Revenue Share of Top-Selling Product           | For each month since 1997, which product generated the most revenue and what percentage of that month’s total revenue did it represent?             | `RANK`, `QUALIFY`, percentage-of-total calculation |     6      | `ORDERS` + `LINEITEM` + `PART`                              |
| ex73 | Year-over-Year Revenue Growth by Segment               | Which customer segments grew or declined year-over-year between 1995 and 1997 based on net revenue?                                                 | `LAG`, partitioned time-series trends             |     7      | `CUSTOMER` + `ORDERS` + `LINEITEM`                          |

#### Level 2: Intermediate → Advanced

| Ex # | Title                                                   | Business Question                                                                                                                               | SQL Concept                                                   | Difficulty | Dataset Familiarity Focus                                        |
| :--: | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------- | :--------: | --------------------------------------------------------------- |
| ex77 | Profit Margin per Product — Bottom & Top                | Which products have the highest and lowest profit margins, and how can we isolate the best and worst performers to guide executive decisions?   | `JOIN`, CTEs, `SUM`, `RANK`, `NULLIF`, margin logic           |     6      | `LINEITEM` + `PARTSUPP` + `PART`                                |
| ex78 | Build a Margin Histogram — Bin All Items by Profitability | How are product margins distributed across the portfolio, and how can we visualize this in buckets without verbose `CASE` logic?                 | `FLOOR`, `CONCAT`, `GROUP BY`, bucketing math                 |     6      | `LINEITEM` + `PARTSUPP`                                         |
| ex79 | Strategic Mapping of Revenue vs Margin — 9-Quadrant Table | How aligned are product revenues and margins, and which strategic quadrants do different products fall into?                                     | `PERCENTILE_CONT`, `CASE`, strategic bucketing                |     8      | `LINEITEM` + `PARTSUPP`                                         |
| ex80 | Evolving Margin–Revenue Alignment — Correlation Over Time | Has the relationship between product revenue and profitability improved over the years, indicating pricing strategy success?                     | `CORR`, nested aggregation, time grouping                     |     9      | `LINEITEM` + `PARTSUPP` + `ORDERS`                              |
| ex81 | Is It Real? Testing the Significance of Margin–Revenue Correlation | Are the year-over-year correlations between product revenue and margin statistically significant, or could they be due to random noise?           | `ABS`, math expression, hypothesis testing via `t-statistic`  |     9      | `LINEITEM` + `PARTSUPP` + `ORDERS`                              |
