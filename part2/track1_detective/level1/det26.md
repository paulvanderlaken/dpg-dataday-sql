## ex26: Tag Food-Related Parts

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 3 / 10

### Business context
The marketing team is reviewing our product naming strategy and noticed that several parts seem to be named after **food items** — like "almond", "tomato", or "chocolate". To explore this further, they’d like to understand how often such food-related terms appear in our catalog.

Your task is to tag any part whose name includes specific food-related words and count how many products fall under each tag.

**Business logic & definitions:**
* food tags of interest: `'almond'`, `'tomato'`, `'chocolate'`, `'vanilla'`, `'peach'`
* food term match: case-insensitive substring match in part name

### Starter query
```sql
-- Explore part names to get a feel for naming patterns
SELECT
    P_PARTKEY,
    P_NAME
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART
LIMIT 10;
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Use a `CASE` statement to assign each part a food label if the part name contains a matching term (e.g., `ILIKE '%almond%'`). Group by this tag to count how many times each appears.

Use `LOWER(P_NAME)` or `ILIKE` to make your checks case-insensitive.

#### Helpful SQL concepts

`CASE`, `ILIKE`, `GROUP BY`, `COUNT()`

```sql
-- Example pattern
CASE
  WHEN P_NAME ILIKE '%almond%' THEN 'almond'
  WHEN P_NAME ILIKE '%tomato%' THEN 'tomato'
  …
END
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working query

```sql
SELECT
    CASE
        WHEN P_NAME ILIKE '%almond%' THEN 'almond'
        WHEN P_NAME ILIKE '%tomato%' THEN 'tomato'
        WHEN P_NAME ILIKE '%chocolate%' THEN 'chocolate'
        WHEN P_NAME ILIKE '%vanilla%' THEN 'vanilla'
        WHEN P_NAME ILIKE '%peach%' THEN 'peach'
        ELSE NULL
    END AS food_tag,
    COUNT(*) AS part_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART
WHERE P_NAME ILIKE '%almond%'
   OR P_NAME ILIKE '%tomato%'
   OR P_NAME ILIKE '%chocolate%'
   OR P_NAME ILIKE '%vanilla%'
   OR P_NAME ILIKE '%peach%'
GROUP BY food_tag
ORDER BY part_count DESC;
```

#### Why this works

The `CASE` logic applies a label to each part name based on food terms, and the `GROUP BY` aggregates how many times each label occurs.

#### Business answer

The most common food term in our part catalog is `"tomato"`, followed closely by `"almond"` — showing a clear trend in naming preferences.

#### Take-aways

* `ILIKE` is great for case-insensitive substring checks in unstructured text fields
* `CASE` + `GROUP BY` provides a powerful tagging and counting mechanism
* Smart filtering (`WHERE`) reduces unnecessary compute on irrelevant rows
* You could have used a CTE where you `UNION ALL` the food terms, to later `LEFT JOIN` and `COALESCE` zero-counts as 0

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add a second column to the output that shows the **percentage share** of each food tag in the overall food-tagged part list.

</details>
