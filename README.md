# 🎓 SQL Proficiency Workshop: Mastering Queries in Snowflake

Welcome to the **SQL Proficiency Workshop** — a hands-on, real-world training experience designed for analysts and analytical translators. 

Whether you’re brushing up on foundations or sharpening advanced techniques, this workshop is your launchpad to confident and efficient querying in **Snowflake**, using the TPCH sample database.

---

## 🧭 Workshop Format

The day is structured into two main components:

### 🔁 Part 1: Self-Paced Capability Ladder

Work through a progressively structured set of SQL exercises across three levels:

- **Level 1 (Foundations)** – Core SQL fluency (filtering, joining, aggregating)
- **Level 2 (Intermediate)** – Logic, expressions, grouping, subqueries
- **Level 3 (Advanced)** – CTEs, windows, cohorting, multi-table design

Each challenge is:
- Framed as a **realistic business question**
- Targeted toward **specific SQL capabilities**
- Supported with **starter queries**, **hints**, and **stretch goals**

### 🔀 Part 2: Track-Based Mini-Challenges

In the second half of the workshop, you’ll choose from one of three themed tracks — each focused on a different mindset: auditing (Detective), optimizing (Engineer), or strategic planning (Strategist).

You’ll work through 5–7 exercises that form a coherent case.  
👉 See [Track Narratives & Case Arcs](#-track-narratives--case-arcs) for full storylines and learning goals.

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
│   ├── track1\_detective/
│   ├── track2\_optimizer/
│   └── track3\_strategist/
│
├── img/                           ← Diagrams, schema snapshots
└── matrix.md                      ← Full list of exercises and metadata

```

Each `.md` file contains:

✅ A clear business question  
🧠 Context-specific logic and definitions  
🔧 A starter SQL snippet  
💡 Optional hint and reasoning guidance  
🎯 A verified solution (facilitator only)  
🎁 Bonus challenges to stretch your thinking  

---

## 🗂️ Exercise Overview (Placeholder)
Consult the `matrix.md` file for the full table of exercises and metadata.

<details>
<summary>Summary of exercises</summary>

| Part     | Track             | Level   | Exercise # | Title                        |
|----------|------------------|---------|------------|------------------------------|
| Part 1   | –                | Level 1 | ex01       | Top 10 Customers by Balance  |
| Part 1   | –                | Level 2 | ex11       | Revenue by Part and Discount |
| Part 1   | –                | Level 3 | ex21       | Cohort Revenue Growth        |
| Part 2   | Detective         | Level 1 | ex26       | Tag Food-Related Parts       |
| Part 2   | Optimizer         | Level 2 | ex58       | Optimized Join Order         |
| Part 2   | Strategist        | Level 2 | ex78       | Top Parts by Region          |

</details>

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
* Move to **Level 2** when ready to expand your fluency.
* **Level 3** offers advanced transformations, windows, and cohorting.
* Step up or down depending on your confidence — growth is the goal.

### In Part 2:

* Tracks are self-contained. Pick one, or try them all.
* Feel free to change tracks or difficulty levels at any time.
* Done with one path? Switch it up and keep learning.

> **No pressure to finish everything. Focus on quality over quantity.**

---

### 🧵 Case-Driven Learning Paths

This workshop includes three distinct tracks, each with **two progressive narrative cases** designed to simulate real-world analytics and engineering workflows. Each arc builds from a realistic business scenario and layers complexity through multiple exercises.

### 🕵️ SQL Detective Track

#### **Level 1: Sourcing Clues from the Data**

> **A sales anomaly has surfaced.**
> As a data detective, you’re tasked with investigating inconsistencies in ordering behavior, supplier patterns, and missing links between countries.

This case focuses on **data exploration, flagging anomalies, and targeted filtering** using joins, anti-joins, and pattern detection.
You’ll learn to create reliable audit flags, build dimensionally modeled audit tables, and prepare data for deeper investigation.

🔍 Output: Diagnostic tables with flagged issues, light audit flags, and investigative joins

---

#### **Level 2: Building a Forensic Audit Pipeline**

> **The audit has escalated.**
> Now equipped with forensic-level access, you’ll simulate a full audit pipeline, enriching flagged records, appending new anomaly categories, and preserving historical traceability.

This case emphasizes **efficient data storage, modular audit flagging with timestamps, and using Snowflake’s Time Travel** to validate and trace data changes.
You’ll conclude by synthesizing audit data with customer and geography metadata for stakeholder reporting.

🔍 Output: Modular audit flags with timestamping, VIP overrides, time-travel validation queries, and comprehensive staging views ready for business use

---

### 🛠️ Query Optimizer Track

#### **Level 1+2: Code Cleanup Mission**

> **You’re the new engineer on the analytics team.**
> Your first task: refactor a pile of slow, unoptimized legacy queries that are wasting compute and confusing your teammates.

Each assignment gives you an inefficient query that technically “works” — but performs poorly. You’ll diagnose bottlenecks and rewrite smarter versions using best practices.

⚙️ Output: Clean, performant queries — and performance reflection on row scan savings

---

### 🧠 Business Strategist Track

#### **Level 1: Momentum Matters**

> **The Strategy Director needs your help.**
> You’ve been asked to identify TPCH’s strongest growth signals — and its hidden risks — across time, product lines, and customer segments.

You’ll start by confirming which years are complete and safe for trend analysis, then build toward uncovering concentration risks and segment-level momentum.
This arc builds critical business awareness and time-series fluency.

🔍 Output: Mismatch tables, filtered diagnostics, investigative joins

---

#### **Level 2: Margin Matters**

> **The CFO is concerned.**
> Revenue is up — but are we actually making money? You’re asked to assess profitability at every level: product, supplier, and region.

You’ll trace margin performance across parts and suppliers, visualize strategic quadrants of high-volume vs. high-margin items, and even compute correlation coefficients and their statistical significance.

📊 Output: Strategic quadrant maps, profit-risk matrices, correlation diagnostics

---


## 🤝 Need Help?

* Facilitators are available throughout the day.
* Use hints when needed — or ask a peer for help.
* Finished early? Try a bonus, revisit a level, or challenge another track.

---

Let’s sharpen your SQL — with smart queries, real insights, and a community of curious minds.

**Happy querying!**


