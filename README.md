# 🎓 DPG Data Day: Snowflake SQL Workshop

> **Quick Navigation**
>
> - [🧭 Workshop Format](#-workshop-format)  
> - [📂 Repository Structure](#-repository-structure)  
> - [🗂️ Exercise Overview](#️-exercise-overview)  
> - [🛠️ Before You Begin](#️-before-you-begin)  
> - [🗺️ Learning Journey Map](#️-learning-journey-map)  
> - [🧑‍💻 Getting Started](#-getting-started)  
> - [🧗 Self-Managing Your Learning Path](#-self-managing-your-learning-path)  
> - [🧵 Track Case Arcs](#-track-case-arcs)  
> - [💾 The TPCH Database](#-the-tpch-database)  
> - [🤝 Need Help?](#-need-help)

---

Welcome to the **DPG Snowflake SQL Workshop** — a hands-on, real-world training experience designed for data analysts and analytical engineers. 

Whether you’re brushing up on foundations or sharpening advanced techniques, this workshop is your launchpad to confident and efficient querying in **Snowflake**, using the TPCH sample database.

---

## 🧭 Workshop Format

The day is structured into two main components:

### 🔁 Part 1: Self-Paced Capability Ladder

Work through a progressively structured set of SQL exercises across three levels ([browse files](./part1/)):

- **Level 1 (Foundations)** – Core SQL fluency (filtering, joining, aggregating)
- **Level 2 (Intermediate)** – Logic, expressions, grouping, subqueries
- **Level 3 (Advanced)** – CTEs, windows, cohorting, multi-table design

Each challenge is found in a standalone `.md` file:
- Framed as a **realistic business question**
- Targeted toward **specific SQL capabilities**
- Supported with **starter queries**, **hints**, and **stretch goals**

### 🔀 Part 2: Track-Based Mini-Challenges

In the second half of the workshop, you’ll choose from one of three themed tracks — each focused on a different mindset: auditing (Detective), optimizing (Engineer), or strategic planning (Strategist).

You’ll work through 5–7 exercises that form a coherent case.  
👉 + See [Track Case Arcs](#-track-case-arcs) for full storylines and learning goals.

---

## 📂 Repository Structure

This current repository contains the following contents that are relevant for you:

```
dpg-dataday-sql/
│
├── part1/                         ← Self-paced ladder (Levels 1–3)
│   ├── level1/
│   ├── level2/
│   └── level3/
│
├── part2/                         ← Track-based challenges
│   ├── track1_detective/
│   ├── track2_optimizer/
│   └── track3_strategist/
│       ├── level1/                ← Each track contains two levels/cases
│       └── level2/
│
├── img/                           ← Diagrams, schema snapshots, solutions
└── instructional_design/
    ├── matrix.md                  ← Full list of exercises
    └── sql_concepts.md            ← Mapping of SQL concepts to exercises
```

Each `.md` file contains:

✅ A clear business question  
🧠 Context-specific logic and definitions  
🔧 A starter SQL snippet  
💡 Optional hint and reasoning guidance  
🎯 A verified solution (facilitator only)  
🎁 Bonus challenges to stretch your thinking  

---

## 🗂️ Exercise Overview
Consult the [`matrix.md` file](./instructional_design/matrix.md) for the full table of exercises and metadata.

---

## 🛠️ Before You Begin

This workshop uses **Snowflake** as the SQL execution environment. You can work from a browser — no installation needed.

To participate fully:

1. ✅ **Create or access a Snowflake account**  
   - Use your company's internal account if provided, **or**  
   - Sign up for a free trial: [https://signup.snowflake.com](https://signup.snowflake.com)

2. ✅ **Open the Snowflake Web UI**  
   - Navigate to the **Snowsight** interface (works best in Chrome/Edge)
   - Familiarize yourself with the worksheet layout, schema explorer, and results pane

3. ✅ **Verify access to `SNOWFLAKE_SAMPLE_DATA`**  
   - All exercises use `TPCH_SF1` (and in some tracks, `TPCH_SF10`)
   - Confirm this shared database is visible in your sidebar under `Databases`

4. ✅ **No setup needed for data or permissions**  
   - You will not need to create any objects unless explicitly instructed (usually in Part 2)

---

> If you're unsure whether your setup is correct, check with a facilitator or run this test query:

```sql
SELECT COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;
```
---

## 🗺️ Learning Journey Map

Not sure where to start? Use this high-level guide to pick a path that suits your background and goals:

```
START HERE → Part 1: Capability Ladder
    |
    |--> Level 1: Foundations (ex01–ex10)
    |      For: New analysts with limited or rusty SQL experience
    |
    |--> Level 2: Intermediate Logic (ex11–ex20)
    |      For: Regular SQL users comfortable with joins and grouping
    |
    |--> Level 3: Advanced SQL (ex21–ex25)
           For: Confident SQL users exploring CTEs, windows, and cohorting
           
↓ Ready for deeper challenges?

→ Part 2: Choose Your Thematic Track

  🕵️ Track 1: SQL Detective
      Audit flags, anomaly detection, pipeline QA
        For: SQL users who want to go beyond standard query construction and analysis
      - Case 1 (ex26–ex30): Explore and identify issues
      - Case 2 (ex36–ex40): Build audit pipelines with time travel

  ⚙️ Track 2: Query Optimizer
      Improve slow queries, boost compute efficiency
        For: SQL users looking to engineer performant code using advanced patterns
      - Case 1: (ex46–ex54): Rewrite poor SQL and reflect on performance
      - Case 2: (ex55–ex61): Rewrite poor SQL and advanced data transformations

  🧠 Track 3: Business Strategist
      Spot trends, uncover insights, transform, visualize and analyze data
        For: SQL users who want to transform and prepare data for advanced analysis
      - Case 1 (ex67–ex73): Time trends and momentum
      - Case 2 (ex77–ex81): Visual analysis and statistical diagnostics
```

---

## 🧑‍💻 Getting Started

1. Navigate to any `.md` file and read the problem description.
2. Open the Snowflake Web UI.
3. Paste the starter query, apply your reasoning, and experiment.
4. If you get stuck, try the `hint` to work your way through.
5. Use the solution to check your code and answers.  
6. Try the bonus task if you want to go beyond!

---

## 🧗 Self-Managing Your Learning Path

This workshop is **non-linear and learner-led**. You are in control.

### In Part 1:

* **Level 1** introduces foundational SQL skills.
* **Level 2** offers intermediate users the chance to expand their fluency.
* **Level 3** teaches advanced transformations, windows, and cohorting.
* Step up or down depending on your confidence — growth is the goal.

### In Part 2:

* Tracks are self-contained. Pick one, or try them all.
* Each track comes with two cases, respectively with intermediate and advanced challenges.
* Feel free to change tracks and cases at any time.
* Done with one path? Switch it up and keep learning.

> **No pressure to finish everything. Focus on quality over quantity.**

---

## 🧵 Track Case Arcs

This workshop includes three distinct tracks, each with **two progressive narrative cases** designed to simulate real-world analytics and engineering workflows. Each arc builds from a realistic business scenario and layers complexity through multiple exercises.

### Track 1: 🕵️ SQL Detective

#### **Case 1: Sourcing Clues from the Data**

> **A sales anomaly has surfaced.**
> As a data detective, you’re tasked with investigating inconsistencies in ordering behavior, supplier patterns, and missing links between countries.

This case focuses on **data exploration, flagging anomalies, and targeted filtering** using joins, anti-joins, and pattern detection.
You’ll learn to create reliable audit flags, build dimensionally modeled audit tables, and prepare data for deeper investigation.

🔍 Output: Diagnostic tables with flagged issues, light audit flags, and investigative joins

---

#### **Case 2: Building a Forensic Audit Pipeline**

> **The audit has escalated.**
> Now equipped with forensic-level access, you’ll simulate a full audit pipeline, enriching flagged records, appending new anomaly categories, and preserving historical traceability.

This case emphasizes **efficient data storage, modular audit flagging with timestamps, and using Snowflake’s Time Travel** to validate and trace data changes.
You’ll conclude by synthesizing audit data with customer and geography metadata for stakeholder reporting.

🔍 Output: Modular audit flags with timestamping, VIP overrides, time-travel validation queries, and comprehensive staging views ready for business use

---

### Track 2: 🛠️ Query Optimizer

#### **Case 1+2: Code Cleanup Mission**

> **You’re the new engineer on the analytics team.**
> Your first task: refactor a pile of slow, unoptimized legacy queries that are wasting compute and confusing your teammates.

Each assignment gives you an inefficient query that technically “works” — but performs poorly. You’ll diagnose bottlenecks and rewrite smarter versions using best practices.

⚙️ Output: Clean, performant queries — and performance reflection on row scan savings

---

### Track 3: 🧠 Business Strategist

#### **Case 1: Momentum Matters**

> **The Strategy Director needs your help.**
> You’ve been asked to identify TPCH’s strongest growth signals — and its hidden risks — across time, product lines, and customer segments.

You’ll start by confirming which years are complete and safe for trend analysis, then build toward uncovering concentration risks and segment-level momentum.
This arc builds critical business awareness and time-series fluency.

🔍 Output: Mismatch tables, filtered diagnostics, investigative joins

---

#### **Case 2: Margin Matters**

> **The CFO is concerned.**
> Revenue is up — but are we actually making money? You’re asked to assess profitability at every level: product, supplier, and region.

You’ll trace margin performance across parts and suppliers, visualize strategic quadrants of high-volume vs. high-margin items, and even compute correlation coefficients and their statistical significance.

📊 Output: Strategic quadrant maps, profit-risk matrices, correlation diagnostics

---

![alt text](img/three-tracks-explainer.png)

---

## 💾 The TPCH Database

We use the `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1` dataset — a simplified business schema modeling customers, orders, parts, and suppliers.

| Table      | Description                                                                 |
|------------|-----------------------------------------------------------------------------|
| `CUSTOMER` | Customer profiles with segmentation and balance fields                     |
| `ORDERS`   | Order headers with status, priority, and date info                         |
| `LINEITEM` | Order lines with price, discount, and shipping detail                      |
| `PART`     | Individual products or SKUs with names and sizes                           |
| `SUPPLIER` | Supplier identities and comments                                            |
| `PARTSUPP` | Many-to-many mapping of parts to their suppliers and supply costs          |
| `NATION`   | Nation identifiers with region linkage                                     |
| `REGION`   | Continent-level grouping of nations                                        |

### Dataset Variants

- You’ll work primarily with **`TPCH_SF1`**, suitable for foundational learning.
- There are other variants of this database that **S**cale its records by a **F**actor, `TPCH_SF10`, `TPCH_SF100` and `TPCH_SF1000`. 
- You'll sometimes encounter exercises using these larger datasets to highlight performance and cost tradeoffs (particularly in **Part 2: Query Optimizer** track)

### Database Schema
You can find full database schema in the `img/` folder

![alt text](img/tpch_database_schema.png)

---

## 🤝 Need Help?

* Facilitators are available throughout the day.
* Use hints when needed — or ask a peer for help.
* Finished early? Try a bonus, revisit a level, or challenge another track.

---

Let’s sharpen your SQL — with smart queries, real insights, and a community of curious minds.

**Happy querying!**


