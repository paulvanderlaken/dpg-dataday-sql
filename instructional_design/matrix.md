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

✅ Use this roadmap to pick the right exercises for your current skill level or business focus. Tracks are self-contained but build naturally from Part 1 foundations.

## 🚦 Part 1: Core SQL Fluency

#### Level 1: Beginner

| Ex # | Title                                | Business Question                                                                                  | SQL Concept                      | Difficulty | Dataset Familiarity Focus                                | Track    | Core/Stretch | Stretch/Core Notes                                                  |
|:----:|--------------------------------------|----------------------------------------------------------------------------------------------------|----------------------------------|:----------:|----------------------------------------------------------|----------|:-------------:|------------------------------------------------------------------------|
| ex01 | Top 10 Customers by Balance          | “Which customers should we prioritize for a loyalty program based on balances?”                   | `SELECT` + `ORDER BY` + `LIMIT`  |     2      | **CUSTOMER**: C_CUSTKEY, C_NAME, C_ACCTBAL                | Part 1   | Core         | Introduces sorting and value-based prioritization                   |
| ex02 | Filter Q1 Orders with Priority | “Which high-priority orders were placed in Q1 1995?” | `WHERE` with `AND`, date filtering |      2     | **ORDERS**: O\_ORDERDATE, O\_ORDERPRIORITY | Part 1 |     Core     | Adds basic filtering and date filter logic |
| ex03 | Top 3 Orders from the BUILDING Segment | “Which high-value orders came from customers in the BUILDING segment?” | `JOIN` + `WHERE` + `ORDER BY` + `LIMIT` | 2 | **ORDERS**, **CUSTOMER** | Part 1 | Core | Builds on filtering (ex02) and introduces basic `JOIN` + ranking pattern |
| ex04 | Count Customers by Segment | “How many customers belong to each market segment?” | `GROUP BY` + `COUNT(*)` |      2     | **CUSTOMER**: C\_MKTSEGMENT | Part 1 |     Core     | Introduces grouping logic; prep for later aggregation |
| ex05 | High-Quantity or Low-Price Lineitems | “Which line items qualify for bulk discounts or promotions?”                                      | `WHERE` with `AND/OR`            |     2      | **LINEITEM**: L_QUANTITY, L_EXTENDEDPRICE, L_DISCOUNT    | Part 1   | Core         | Filtering using logical operators                                   |
| ex06 | Compare Table Sizes – Parts vs Suppliers | “How many records exist in the PART and SUPPLIER tables?”                        | `COUNT(*)` + `UNION ALL` + aliasing          |     2      | **PART**, **SUPPLIER**                              | Part 1   | Stretch      | Replaces trivial LIMIT query with comparative summary using derived labels           |
| ex07 | Find Smallest Parts with Longest Names   | “Which small parts have the longest names?”                                      | `ORDER BY` + `LENGTH()` + aliasing + `LIMIT` |     3      | **PART**: P_NAME, P_SIZE                            | Part 1   | Stretch      | Extends sorting with derived columns and mixed ASC/DESC logic                         |
| ex08 | Count Orders Containing Almond Products  | “How many unique orders included a part with ‘almond’ in its name?”             | `JOIN`, `ILIKE`, `COUNT(DISTINCT)`           |     2      | **PART**, **LINEITEM**                             | Part 1   | Stretch      | Pattern match across join; simplified customer-product linkage                        |
| ex09 | Suspected Suppliers with Missing Comments      | “Identify suppliers lacking commentary.”                                                          | `IS NULL` / `IS NOT NULL`        |     1      | **SUPPLIER**: S_SUPPKEY, S_NAME, S_COMMENT                | Part 1   | Stretch      | Introduces NULL logic                                               |
| ex10 | Compute Price + Tax                  | “What would each line item cost including a 5% tax?”                                              | Arithmetic in `SELECT`           |     2      | **LINEITEM**: L_EXTENDEDPRICE, basic math expr           | Part 1   | Stretch      | Applies calculations in SELECT                                      |

----

#### Level 2: Intermediate

| Ex # | Title                                  | Business Question                                                                                                            | SQL Concept                           | Difficulty | Dataset Familiarity Focus                                             | Track    | Core/Stretch | Stretch/Core Notes                                                  |
|:----:|----------------------------------------|------------------------------------------------------------------------------------------------------------------------------|---------------------------------------|:----------:|------------------------------------------------------------------------|----------|:-------------:|------------------------------------------------------------------------|
| ex11 | Revenue by Part and Discount Tier      | “Which parts generated the most revenue in 1998, and how does this vary by discount tier?”                               | `GROUP BY` + `SUM` + expression logic |     4      | **LINEITEM**: P_PARTKEY, L_EXTENDEDPRICE, L_DISCOUNT, date filter     | Part 1   | Core         | Builds on beginner aggregation with derived column logic             |
| ex12 | High-Volume Parts with Tiered Revenue  | “Which parts sold ≥ 1,000 units and generated over $100K in revenue?”                                                       | `HAVING` on multiple aggregates       |     5      | **LINEITEM**: aggregate quantity and extended price                   | Part 1   | Core         | Dual filters on aggregates; sharpens business criteria               |
| ex13 | Orders per Customer in 1995            | “List each customer's orders placed in 1995, including name, nation, and order date.”                                       | `INNER JOIN` + date filtering         |     4      | **ORDERS**, **CUSTOMER**, **NATION**                                 | Part 1   | Core         | Builds on JOINs by adding filtering and 3-table logic                |
| ex14 | Detailed Order Feed with Derived Cost  | “Build a full order-detail feed including extended price after discount for each item.”                                     | Multi-table `JOIN` + expressions      |     5      | **LINEITEM**, **ORDERS**, **PART**                                   | Part 1   | Core         | Combines joins and column derivations                                |
| ex15 | Customers with Recency and Order Count| “For each customer, show their most recent order date and total number of orders.”                                          | Subquery in `FROM` + `JOIN`           |     6      | **CUSTOMER**, **ORDERS**                                             | Part 1   | Core         | Recency logic + aggregation per customer                             |
| ex16 | Rank Orders with Total Spend           | “Rank each customer's orders by total spend (including discount), from highest to lowest.”                                  | `ROW_NUMBER()` OVER () + expression   |     6      | **ORDERS**, **LINEITEM**                                             | Part 1   | Core         | Extends ranking with computation                                     |
| ex17 | Supplier-Part List with Cost Flag      | “Generate a supplier-part listing and flag if the supply cost is above average for that part.”                              | `WITH` / CTE + comparison to AVG()    |     6      | **PARTSUPP**, **PART**, **SUPPLIER**                                 | Part 1   | Stretch      | Adds conditional logic to CTE use                                    |
| ex18 | Rewrite Scalar Subquery to Count Lineitems per Order | “Rewrite an inefficient per-order scalar subquery that counts line items using a `JOIN` and `GROUP BY`.” | Scalar subquery vs `GROUP BY` rewrite | 6 | **ORDERS**, **LINEITEM** | Part 1 | Stretch | Reinforces performance-minded thinking by replacing scalar subquery with set-based aggregation |
| ex19 | Deep Discount Lineitems per Order      | “Find the top 5 line items per order with the highest discount rates above 10%.”                                            | `RANK()` + `PARTITION BY` + filter    |     6      | **LINEITEM**                                                         | Part 1   | Stretch      | Builds on window + conditional filtering                             |
| ex20 | Rolling Daily Revenue Since Jan 1 1996 | “Show daily cumulative sales for all orders shipped since January 1, 1996.”                                                 | `SUM() OVER (ORDER BY)` + date filter |     6      | **LINEITEM**, **ORDERS**                                             | Part 1   | Stretch      | Builds on cumulative logic with filtered timeframe                   |


#### Level 3: Advanced

| Ex # | Title                                              | Business Question                                                                                                                                           | SQL Concepts                                                                                               | Difficulty | Dataset Familiarity Focus                                                                                                            | Track    | Core/Stretch | Stretch/Core Notes                                                  |
|:----:|----------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|:----------:|---------------------------------------------------------------------------------------------------------------------------------------|----------|:-------------:|------------------------------------------------------------------------|
| ex21 | Customer Cohort Revenue Growth                     | “Compare total revenue over time for each customer cohort (by first-purchase month).”                                                                      | CTEs, Window functions (`SUM OVER`, `ROWS BETWEEN`), date bucketing, joins                                              |     8      | **CUSTOMER → ORDERS → LINEITEM**                                                                           | Part 1   | Core         | Cohorting, date-bucketing, cumulative windows – essential pattern     |
| ex22 | Top 3 Parts by Revenue in Each Region              | “Find the highest-revenue parts in each region.”                                                                                                           | Multi-level window (`RANK()`), hierarchical joins, CTEs                                                                |     8      | **REGION → NATION → SUPPLIER → PARTSUPP → LINEITEM**                                                      | Part 1   | Core         | Advanced join traversal + partitioned ranking                         |
| ex23 | Rolling 3-Month Order Momentum by Segment | “How do different market segments ramp up in order activity over time, based on rolling 3-month order averages?” | `DATE_TRUNC`, `JOIN`, `GROUP BY`, `SUM() OVER (…)`, `ROWS BETWEEN` |     7      | **CUSTOMER**, **ORDERS** | Part 1   | Core         | Segment-level windowed analysis; more meaningful trends than sharp MoM acceleration |
| ex24 | Top 10 Customers per Segment – Deep Dive (1995) | “Who were the top 10 customers by revenue per segment in 1995, and how do their order patterns and discount behavior compare?” | `JOIN`, `GROUP BY`, `SUM()`, `COUNT()`, `AVG()`, `RANK() OVER (PARTITION BY …)` | 7 | **CUSTOMER**, **ORDERS**, **LINEITEM** | Part 1 | Stretch | Rich customer profiling using multi-metric aggregation and per-segment ranking |
| ex25 | High/Low Discounting Suppliers per Segment | “Which suppliers gave unusually high or low discounts to the top 10 customers in each segment during 1995?” | `JOIN`, `GROUP BY`, `AVG()`, `STDDEV()`, `CASE`, `RANK()` | 9 | **LINEITEM**, **ORDERS**, **CUSTOMER**, **SUPPLIER** | Part 1 | Stretch | Statistical outlier detection scoped to top customers in each segment |

---

## 🎯 Part 2: Thematic Mastery Tracks

### 🔍 Track 1: SQL Detective

#### Level 1: Beginner → Intermediate
| Ex # | Title                                        | Business Question                                                                                     | SQL Concept                         | Difficulty | Dataset Familiarity Focus                                           | Track         | Core/Stretch | Stretch/Core Notes                                                  |
|:----:|----------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------|:----------:|---------------------------------------------------------------------|---------------|:-------------:|------------------------------------------------------------------------|
| ex25 | Create Audit Workspace + Tag Reference Table | “How can I create a safe audit schema and store a reusable list of suspicious naming patterns?”       | `CREATE DATABASE`, `SCHEMA`, `TABLE`, `INSERT` |     2      | **WORKSHOP_DB.TEMP_SCHEMA** (set up for audit use)                 | SQL Detective | Core         | Prepares personal sandbox and loads food-related tags for future joins |
| ex26 | Tag Parts Named After Keywords               | “Which parts have names that match any suspicious keywords (like almond or chocolate)?”               | `JOIN`, `ILIKE`, `CREATE TABLE AS`  |     4      | **PART**, **tag_keywords** (ref table)                             | SQL Detective | Core         | First audit output table using pattern join with reusable reference logic |
| ex27 | Customers Without Any Orders                 | “Which customers appear in our system but have never placed an order?”                               | `LEFT JOIN` + `IS NULL`             |     3      | **CUSTOMER**, **ORDERS**                                           | SQL Detective | Core         | Classic anti-join to detect orphaned keys; result stored for action |
| ex28 | Parts Never Sold in 1996                     | “Which parts were never sold during the year 1996?”                                                   | `LEFT JOIN`, date filtering         |     4      | **PART**, **LINEITEM**                                            | SQL Detective | Core         | Time-scoped anti-join revealing catalog coverage gaps                |
| ex29 | Flag High-Discount, High-Quantity Items      | “Which line items were sold in high quantity and at steep discounts?”                                | `WHERE`, compound filter, derive net revenue | 4 | **LINEITEM**                                        | SQL Detective | Core         | Combines filters + computed value, materializes for pricing review     |
| ex30 | Identify Top 0.1% Revenue Orders             | “Which orders generated the highest revenue — the top 0.1% of all?”                                  | `PERCENTILE_CONT`, `CTE`, `LABEL`, `CREATE TABLE AS` | 5 | **LINEITEM**                              | SQL Detective | Core         | Distributional audit using statistical cutoff; labels strategic revenue drivers |

#### Level 2: Intermediate → Advanced

| Ex # | Title                                      | Business Question                                                                                       | SQL Concept                         | Difficulty | Dataset Familiarity Focus                                           | Track         | Core/Stretch | Stretch/Core Notes                                                  |
|:----:|--------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------|:----------:|---------------------------------------------------------------------|---------------|:-------------:|------------------------------------------------------------------------|
| ex36 | Model an Efficient Audit Flag for Inactive Customers | “How can we efficiently flag inactive customers while maintaining audit traceability?”                 | `CREATE TABLE`, `ALTER TABLE`, `INSERT`, `LEFT JOIN`, `TIMESTAMP` | 6 | Audit flag tables, customer and orders data                        | SQL Detective | Core         | Explicit schema with timestamp column, dimension/fact modeling for flags |
| ex38 | Flag VIP Overrides for Strategic Exceptions | “How do we flag VIP customers as exceptions in the audit log without deleting previous flags?”         | `ALTER TABLE`, `INSERT`, `TEMP TABLE`, `NTILE`, `QUALIFY` | 7 | Audit flag tables, order counts, lineitem revenue                   | SQL Detective | Core         | Adds timestamp column, creates override flag, uses temp tables for inserts |
| ex39 | Inspect the Raw Audit Log Using Time Travel | “How can we use Snowflake Time Travel to compare audit log states before and after VIP overrides?”     | `AT(TIMESTAMP)`, `AT(OFFSET)`, `JOIN`, `CURRENT_TIMESTAMP` | 7 | Audit flag tables with timestamps, Snowflake time travel           | SQL Detective | Core         | Validates audit pipeline changes, compares raw audit records over time  |
| ex40 | Build a Comprehensive Audit Staging View    | “How can we synthesize all audit flags with customer metadata to enable business reporting and slicing?”| `CREATE VIEW`, `JOIN`, `DIMENSION ENRICHMENT`, `TIMESTAMP` | 8 | Audit flags enriched with customer, nation, and region data         | SQL Detective | Core         | Final capstone view combining audit and business context, ready for dashboards |

---
### ⚙️ Track 2: Query Optimizer

#### Level 1: Beginner → Intermediate

| Ex # | Title                                                | Business Question                                                               | SQL Concept                               | Difficulty | Dataset Focus            | Track           | Core/Stretch | Notes                                                                                            |
| ---- | ---------------------------------------------------- | ------------------------------------------------------------------------------- | ----------------------------------------- | ---------- | ------------------------ | --------------- | ------------ | ------------------------------------------------------------------------------------------------ |
| ex46 | Selective Customer Data Extraction                   | "Extract `C_NAME`, `C_ACCTBAL`, and `C_MKTSEGMENT` for 'AUTOMOBILE' customers, joined with orders." | Column projection + `WHERE` + join       | 3          | **CUSTOMER**, **ORDERS** | Query Optimizer | Core         | Adds join with dual early filters; highlights pushdown and targeted output.                     |
| ex47 | Early Order Filtering with Date Range                | "Retrieve all orders placed in March of 1995 and 1996, efficiently."            | `WHERE` with compound ranges, filter pushdown | 3       | **ORDERS**               | Query Optimizer | Core         | Contrast between date function vs range filter logic; enables partition pruning across years.  |
| ex48 | Top 5 Most Expensive Line Items in Q2 1995           | “Which individual line items shipped in Q2 1995 had the highest net value?”         | `ORDER BY`, `LIMIT`, early filter + CTE | 3          | **LINEITEM**, **ORDERS**     | Query Optimizer | Core         | Focuses on limiting early before joins; teaches slice-then-enrich pattern to reduce compute cost. |
| ex49 | Flagging Large or Valuable Shipments                 | “Which line items represent large-volume or high-value shipments, and how can we retrieve them efficiently?” | `UNION ALL` vs `WHERE`, column projection     | 3          | **LINEITEM**                                             | Query Optimizer | Core         | Highlights inefficiency of using UNION ALL instead of single-pass OR filter; reinforces scan reduction |
| ex50 | Filter First, Not After the Join                     | “How can we avoid processing unnecessary rows when only certain flagged line items are relevant?”            | `CASE`, filter pushdown, CTE, early filtering | 4          | **LINEITEM**, **ORDERS**                                 | Query Optimizer | Core         | Shows inefficiency of flagging and joining before filtering; teaches filter placement in layered queries |
| ex51 | LIKE vs ILIKE Pattern Performance                    | “How many parts have names containing ‘green’? Explore performance difference using `LIKE` vs `ILIKE`.” | Pattern search inefficiency          | 4     | **PART**                 | Query Optimizer | Core         | Demonstrates scan cost with `%text%` pattern matching            |
| ex52 | Rewrite IN-SELECT to Join                            | “List all customers who placed an order in 1995 — once using `IN (SELECT)` and once with a `JOIN`.”     | Subquery vs Join                     | 4     | **CUSTOMER**, **ORDERS** | Query Optimizer | Core         | Direct comparison of subquery vs join performance                |
| ex53 | Fix the Filters — Cleaning Up a Misfired Query | “How many parts are anodized, non-promotional, include green in their name, mention a key metal, and are in the bottom 10% of prices?” | `ILIKE`, `NOT ILIKE`, `OR`, `PERCENTILE_CONT`, `WITH`, `IN` query cleanup | 4 | **PART** | Query Optimizer | Core | Combines logic correction with planning improvement; starts from a broken analyst query that uses wrong filters, scalar subqueries, and ungrouped ORs |
| ex54 | CASE WHEN vs Lookup Table                            | “Map customer segments to broader tiers using `CASE WHEN`. Then try replacing this with a small join.”  | CASE logic vs mapping table          | 4     | **CUSTOMER**             | Query Optimizer | Core         | Encourages dimensional joins over hardcoded logic                |


#### Level 2: Intermediate → Advanced

| Ex # | Title                                                   | Business Question                                                                                         | SQL Concept                              | Difficulty | Dataset Familiarity Focus                                | Track           | Core/Stretch | Stretch/Core Notes                                                                 |
|:----:|---------------------------------------------------------|------------------------------------------------------------------------------------------------------------|-------------------------------------------|:----------:|----------------------------------------------------------|----------------|:-------------:|-------------------------------------------------------------------------------------|
| ex55 | Use DECLARE and BEGIN…END to Create Dynamic Threshold Logic | “How can we dynamically compute and reuse a revenue threshold for high-value orders in SQL?”               | `DECLARE`, `SET`, `BEGIN...END`, control flow | 7          | `LINEITEM`                                              | Query Optimizer | Stretch       | Introduces procedural scripting in Snowflake; good lead-in to dynamic SQL usage   |
| ex56 | Build a Reusable Keyword Search Procedure with Dynamic SQL | “How can we scan different comment fields for keywords using one flexible SQL procedure?”                  | `EXECUTE IMMEDIATE`, dynamic SQL, `USING`, stored procedure | 6          | `SUPPLIER`, `ORDERS`, `CUSTOMER` (comments)             | Query Optimizer | Stretch       | Demonstrates secure use of dynamic SQL; string injection avoidance with bind vars |
| ex57 | Generate a JSON API Payload for Customer Order History      | “How can we generate nested JSON for a customer's monthly order history directly from SQL?”                | `OBJECT_CONSTRUCT`, `ARRAY_AGG`, JSON nesting | 7          | `ORDERS`, `LINEITEM`, `PART`, `CUSTOMER`, `NATION`      | Query Optimizer | Stretch       | Constructs full JSON output from relational tables; simulates real API payloads   |
| ex58 | Parse Incoming JSON Order Payload into Rows                 | “How can we parse an incoming JSON order and flatten it into relational records?”                          | `FLATTEN`, `LATERAL`, `VARIANT`, JSON parsing | 7          | Simulated input via `PARSE_JSON()`                      | Query Optimizer | Stretch       | Serves as inverse to ex57; teaches ingestion and parsing of nested API inputs     |
| ex59 | Tokenize and Flatten Supplier Comments for Text Mining      | “How can we break down supplier comments into individual lowercase words for analysis?”                    | `REGEXP_REPLACE`, `LOWER`, `SPLIT`, `FLATTEN` | 7          | `SUPPLIER` (S_COMMENT)                                 | Query Optimizer | Stretch       | Great for NLP pre-processing; reinforces `FLATTEN` in a text analytics context    |
| ex60 | Nested Subqueries vs Multi-Stage CTEs — Which Scales Better? | “How does query structure affect performance when computing revenue, margins, and derived metrics?” | Subquery vs multi-CTE refactor, performance comparison, CASE expressions, SUM, AVG | 8 | **ORDERS**, **LINEITEM**, **PARTSUPP** | Query Optimizer | Stretch | Adds expensive derived logic to test impact of query structure on compute and runtime |
| ex61 | Refactor Windowed Recency Logic with JOIN or GROUP BY | “What’s the fastest way to find the most recent order per customer — with correct results?” | `ROW_NUMBER()`, `QUALIFY`, `JOIN`, `GROUP BY`, performance trade-offs | 8 | **CUSTOMER**, **ORDERS** | Query Optimizer | Stretch | Shows how subtle logic changes affect result correctness and performance; highlights alternatives to window functions |

---

### Track 3: 🧠 Business Strategist

#### Level 1: Beginner → Intermediate

| #    | Title                                               | Type | Difficulty | SQL Concept                             | Dataset Focus                |
|------|-----------------------------------------------------|------|------------|------------------------------------------|------------------------------|
| 67   | Yearly Order Coverage and Summary Stats             | Core | 3 / 10     | GROUP BY, aggregates, JOIN               | ORDERS + LINEITEM            |
| 68   | Monthly Revenue Trend by Segment (Since 1997)       | Core | 4 / 10     | DATE_TRUNC, GROUP BY, segment joins      | ORDERS + LINEITEM + CUSTOMER |
| 69   | Identify Top 10 Revenue-Generating Products         | Core | 4 / 10     | GROUP BY, windowed SUM OVER ()           | LINEITEM + PART              |
| 70   | Top 3 Products per Nation — Ranked Long Format      | Core | 5 / 10     | ROW_NUMBER, PARTITION BY, JOINs          | CUSTOMER + ORDERS + PART + NATION |
| 71   | Pivoted Part Rankings per Nation — Executive View   | Core | 6 / 10     | CASE WHEN, MAX(), pivot reshaping        | CUSTOMER + ORDERS + PART + NATION |
| 72   | Monthly Revenue Share of Top-Selling Product        | Core | 6 / 10     | RANK, QUALIFY, % of total                | ORDERS + LINEITEM + PART     |
| 73   | Year-over-Year Revenue Growth by Segment            | Core | 7 / 10     | LAG, partitioned time trends             | CUSTOMER + ORDERS + LINEITEM |

#### Level 2: Intermediate → Advanced

| #    | Title                                               | Type | Difficulty | SQL Concept                             | Dataset Focus                  |
|------|-----------------------------------------------------|------|------------|------------------------------------------|--------------------------------|
| 74   | Product Margin Diagnostics — Flagging Loss Leaders  | Core | 5 / 10     | CASE, derived margin logic               | LINEITEM + PARTSUPP + PART     |
| 75   | Supplier Margin Distribution                        | Core | 5 / 10     | JOIN, GROUP BY, margin spread            | SUPPLIER + PARTSUPP + PART     |
| 76   | Regional Margin Patterns                            | Core | 6 / 10     | JOINs, GROUP BY, margin by region        | REGION + NATION + SUPPLIER + PARTSUPP + PART |
| 77   | Strategic Product Positioning — Volume vs Margin    | Core | 8 / 10     | bucketing, quadrant mapping              | PARTSUPP + LINEITEM            |
| 78   | Long Format Output for Heatmap                      | Core | 8 / 10     | CASE WHEN, GROUP BY, unpivoted structure | PARTSUPP + LINEITEM            |
| 79   | Strategic Mapping of Revenue vs Margin — Heat Table | Core | 8 / 10     | PIVOT, margin vs revenue quadrant        | PARTSUPP + LINEITEM            |
| 80   | Correlation Between Volume and Margin               | Core | 9 / 10     | CORR, exploratory analysis               | PARTSUPP + LINEITEM            |
| 81   | Significance Testing for Correlation Coefficient    | Core | 9 / 10     | correlation testing, t-stat formula      | PARTSUPP + LINEITEM            |
