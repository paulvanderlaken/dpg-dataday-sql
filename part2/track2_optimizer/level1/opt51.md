## ex51: Filter Full Words, Not Rows — Smarter Search in Long Text

> **Type:** Core | **Track:** Query Optimizer  
>
> **Difficulty:** 4 / 10

### Business context
The product analytics team is developing a tagging engine that identifies color terms like “green” in part names. 
An analyst wrote a initial query that works, but on the SF1000 dataset, it’s **noticeably slow**.

They’ve asked you to explore more efficient options. You are thinking of using **string operations** — while ensuring that "green" is matched only as a **full word**, not part of a larger word like `"greenish"` or `"evergreen"`.

Can you rewrite the query twice, using `ILIKE` and `LIKE`, compare their performance, and decide which is faster?

Use Snowflake's Query Profiler (Monitoring > Query History > {select query} > Query Profile) to compare the three solutions. 

### Query to optimise

```sql
SELECT COUNT(*) AS green_word_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART,
     LATERAL FLATTEN(INPUT => SPLIT(P_NAME, ' ')) AS f
WHERE LOWER(f.value::string) = 'green';
```

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

The current query correctly identifies the word `"green"` but scans **millions of exploded tokens**. Instead, try simulating a **whole word match** by:
- Adding a space to the beginning and end of `P_NAME`
- Using `ILIKE` or `LIKE` to match `' green '` in the padded string

Then, compare:
- Does `ILIKE` perform better than `LOWER(...) LIKE`?
- Which query shows lower scan cost and wall time?

Use the **Query Profile** in Snowsight to see the difference.

#### Helpful SQL concepts

`ILIKE`, `LIKE`, string concatenation, `LOWER()`, performance introspection

```sql
SELECT COUNT(*) FROM PART WHERE ' ' || P_NAME || ' ' ILIKE '% green %';
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

#### Working queries

```sql
-- Option 1: Using ILIKE (case-insensitive full word match)
SELECT COUNT(*) AS green_word_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART
WHERE ' ' || P_NAME || ' ' ILIKE '% green %';

-- Option 2: Using LOWER() and LIKE (case-insensitive via normalization)
SELECT COUNT(*) AS green_word_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.PART
WHERE LOWER(' ' || P_NAME || ' ') LIKE '% green %';
```

#### Why this works

- Padding with spaces ensures `"green"` is treated as a full word even at the beginning or end.
- `ILIKE` is Snowflake’s native case-insensitive matcher and avoids needing `LOWER()`.
- The `LIKE` + `LOWER()` form performs the same logical match but incurs **more per-row computation**.

The optimized versions avoid `FLATTEN()` and lateral joins entirely — they scan fewer rows, use less memory, and return results faster.

#### Business answer

All three queries return the same result — but the `ILIKE` version ran **~20–30% faster** than the `FLATTEN` version and **~10–15% faster** than the `LOWER(...) LIKE` variant.

#### Take-aways

* `SPLIT` + `FLATTEN` is expressive but can be computationally expensive on large datasets.
* Simple string tricks (like padding) can simulate full-word matching with less cost.
* `ILIKE` is generally faster than `LOWER(...) LIKE`, especially on large tables.
* Always use Query Profile to measure actual execution time and scan cost — not just logical correctness.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Extend the ILIKE solution to match **any one of the following words** as full words: `"green"`, `"red"`, `"blue"`, `"black"`, `"yellow"`.

For each match, return:
- `P_PARTKEY`
- `P_NAME`
- `matched_color` (the word that matched)

Use a `CASE` or `REGEXP_SUBSTR` to extract the matched word.

</details>
