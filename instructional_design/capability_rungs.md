## 🧱 Core SQL Capability Ladder (Universal)

> **Audience:** Everyone (regardless of track)
>
> **Purpose:** Establish foundational and essential SQL fluency required to succeed in *any* track.

| Rung | Name                        | Key SQL Topics                                                             | Learning Objective                                                         | Level        |
| ---- | --------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------ |
| C1   | Table Exploration           | `SELECT`, `LIMIT`, `ORDER BY`, schema inspection                           | Navigate tables and columns; preview structure and sample data.            | Beginner     |
| C2   | Row Filtering               | `WHERE`, logical operators (`AND`, `OR`), `IN`, `BETWEEN`                  | Subset records based on conditions.                                        | Beginner     |
| C3   | Column Derivation           | Expressions, `ALIAS`, built-in functions (`ROUND`, `UPPER`, etc.)          | Create derived columns for clearer insight.                                | Beginner     |
| C4   | Table Joins                 | `JOIN`, `INNER`, `LEFT`, `ON` clauses                                      | Combine related data from multiple tables.                                 | Beginner     |
| C5   | Aggregation & Grouping      | `GROUP BY`, aggregates (`SUM`, `AVG`, `COUNT`), `HAVING`                   | Summarize datasets by categories.                                          | Intermediate |
| C6   | Conditional Logic           | `CASE`, simple subqueries                                                  | Add interpretive logic or tiered logic to queries.                         | Intermediate |
| C7   | Feature Engineering Basics  | `CAST()`, `COALESCE()`, `CONCAT()`, `SUBSTRING()`, `TRIM()`                | Build robust derived fields and clean identifiers for consistent analysis. | Intermediate |
| C8   | Structuring Queries         | `WITH` (CTE), `ROW_NUMBER()`, `QUALIFY`                                    | Write clean, layered, and reusable queries.                                | Intermediate |
| C9   | Metadata & Discovery        | `INFORMATION_SCHEMA`, `SHOW`, `DESCRIBE`                                   | Understand the structure of unfamiliar datasets.                           | Intermediate |
| C10  | Creating & Modifying Tables | `CREATE TABLE`, `CREATE TABLE AS SELECT`, `DROP`, `TRUNCATE`               | Create tables for testing or materialization.                              | Intermediate |
| C11  | Data Reshaping              | Pivot wide: `GROUP BY` + aggregates, Pivot long: `UNION`, `CASE`, `FILTER` | Transform data to suit downstream use cases or visualization prep.         | Advanced     |
| C12  | Snowflake-Specific Behavior | Time Travel, Cloning, Streams, Transient tables                            | Use Snowflake-native features for reproducibility and tracking.            | Advanced     |

## 🕵️ SQL Detective Ladder (Track-Specific)

> **Focus:** Anomaly detection, data integrity, rule validation

| Rung | Name                         | Key Topics & Tactics                                       | Skill Gained                                                  | Level        |
| ---- | ---------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------- | ------------ |
| D1   | NULLs & Gaps                 | `IS NULL`, `IS NOT NULL`, missing values                   | Identify absent or incomplete records                         | Beginner     |
| D2   | Duplicates & Counts          | `GROUP BY`, `HAVING COUNT()>1`                             | Spot likely duplicates and unexpected record distributions    | Beginner     |
| D3   | Anti-Joins & Orphans         | `LEFT JOIN` + `IS NULL`, `NOT EXISTS`                      | Detect mismatches and records missing logical links           | Intermediate |
| D4   | Rule-Based Filters           | `CASE`, numeric or date validations                        | Encode business logic to catch rule violations                | Intermediate |
| D5   | Time-Based Issues            | `DATEDIFF`, `LAG`, order consistency                       | Find temporal anomalies, churn risks, or invalid sequences    | Intermediate |
| D6   | Feature Engineering I        | Combining fields, categorizing values                      | Construct identifiers, transform fields, patch missing values | Intermediate |
| D7   | Feature Engineering II       | `CASE` + `COALESCE`, flag creation, conditional categories | Create reliable flags and business rule columns               | Intermediate |
| D8   | Statistical Outliers         | `AVG`, `STDDEV`, z-scores, window analytics                | Detect numeric anomalies and unexpected patterns              | Advanced     |
| D9   | Multi-Dataset Reconciliation | Multi-joins, comparative metrics                           | Audit consistency between sources or stages                   | Advanced     |
| D10  | Auditing Row Changes         | Time Travel, Streams, Change Data Capture                  | Track and validate changes to data over time                  | Advanced     |

## ⚙️ Query Optimizer Ladder (Track-Specific)

> **Focus:** Query performance, resource usage, cost-efficiency

| Rung | Name                        | Key Topics & Tactics                                     | Skill Gained                                             | Level        |
| ---- | --------------------------- | -------------------------------------------------------- | -------------------------------------------------------- | ------------ |
| Q1   | Targeted Projections        | `SELECT` specific columns, avoid `*`                     | Reduce scanned data and improve clarity                  | Beginner     |
| Q2   | Filter Early                | Filter pushdown, predicate order                         | Minimize row scan and join volume                        | Beginner     |
| Q3   | Join Order Optimization     | Reorder joins, small-to-large logic                      | Improve execution speed via better join logic            | Intermediate |
| Q4   | Avoid Correlated Subqueries | Convert to joins, use aggregations                       | Enhance scalability and avoid row-by-row execution       | Intermediate |
| Q5   | Use QUALIFY Smartly         | `ROW_NUMBER()` + `QUALIFY` instead of subqueries         | Efficient row filtering without nesting                  | Intermediate |
| Q6   | Feature Engineering III     | `MIN()`, `MAX()`, normalization, ratio creation          | Scale and derive percentage-based features efficiently   | Intermediate |
| Q7   | Explain & Inspect           | `EXPLAIN`, Query Profile, performance metrics            | Debug and measure query performance                      | Advanced     |
| Q8   | Materialization & Caching   | CTEs vs temp tables, result caching, `MATERIALIZED VIEW` | Make decisions that leverage Snowflake’s execution model | Advanced     |
| Q9   | Cost Estimation Awareness   | Snowflake credit use, storage vs compute cost trade-offs | Optimize cost in daily querying decisions                | Advanced     |

## 📊 Business Strategist Ladder (Track-Specific)

> **Focus:** Data storytelling, cohorting, trends, segmentation, and visual-readiness

| Rung | Name                        | Key Topics & Tactics                                             | Skill Gained                                                    | Level        |
| ---- | --------------------------- | ---------------------------------------------------------------- | --------------------------------------------------------------- | ------------ |
| B1   | Aggregates for Insight      | `GROUP BY`, `SUM`, `COUNT`, `AVG`                                | Produce summary metrics and KPIs                                | Beginner     |
| B2   | Time Series Buckets         | `DATE_TRUNC`, `MONTH`, `YEAR`, etc.                              | Track patterns over time                                        | Beginner     |
| B3   | Ranking & Prioritization    | `RANK()`, `ROW_NUMBER()`, `PARTITION BY`                         | Sort and compare within business dimensions                     | Intermediate |
| B4   | Customer Segmentation       | Joins + logic to group customers                                 | Define audiences, cohorts, and personas                         | Intermediate |
| B5   | Feature Engineering IV      | `CASE`, `CONCAT()`, `SUBSTRING()`, `TRIM()`, `COALESCE()`        | Derive segment flags, create clean dimensions                   | Intermediate |
| B6   | Trend & Change Analysis     | `LAG`, `LEAD`, % change, MoM, YoY                                | Analyze directional movement or behavioral shifts               | Intermediate |
| B7   | Funnel & Retention Metrics  | Multi-step filters, conversions, reorders                        | Track business funnels and customer journeys                    | Advanced     |
| B8   | Share & Contribution Logic  | `% of total`, windowed shares, segment contributions             | Visual-ready metrics like market share or contribution by group | Advanced     |
| B9   | KPI Tables & Dashboard Prep | Creating wide flat tables, unpivoting with `UNION`, visual logic | Prepare datasets for visualization tools                        | Advanced     |
