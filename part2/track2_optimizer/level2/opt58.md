## ex58: Parse Incoming JSON Order Payload into Rows

> **Type:** Stretch | **Track:** Query Optimizer  
>
> **Difficulty:** 7 / 10

### Business context
The new customer order portal is live. Customers now place orders through an **API** that sends structured JSON payloads to your backend.

Your team receives the following structure:

```json
{
  "customer_id": 10,
  "order_date": "2024-06-01",
  "items": [
    { "part_id": 123, "quantity": 3 },
    { "part_id": 87, "quantity": 1 },
    { "part_id": 44, "quantity": 10 }
  ]
}
```

You need to ingest this data and **convert it into a proper SQL resultset** — with one row per item.

Later, this structure will be inserted into staging tables and validated. For now, your task is to **parse and unnest the payload** into a flat table with:

- customer_id
- order_date
- part_id
- quantity

---

### Starter query

```sql
-- Sample payload for debugging
WITH raw_input AS (
  SELECT PARSE_JSON('{
    "customer_id": 10,
    "order_date": "2024-06-01",
    "items": [
      { "part_id": 123, "quantity": 3 },
      { "part_id": 87, "quantity": 1 },
      { "part_id": 44, "quantity": 10 }
    ]
  }') AS order_json
)
SELECT * FROM raw_input;
```

---

### Required datasets

* None — data comes from simulated JSON input

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

1. Use `FLATTEN(input => ...)` to explode the `items` array
2. Use `LATERAL` to access nested fields
3. Reference values using `value:<field>` syntax on `VARIANT` data types
4. Make sure to project `customer_id` and `order_date` along with each item

#### Helpful SQL concepts

`PARSE_JSON`, `FLATTEN`, `LATERAL`, `:variant` dereferencing

```sql
SELECT f.value:part_id::int AS part_id
FROM table, LATERAL FLATTEN(input => json_column:items) f;
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

```sql
WITH raw_input AS (
  SELECT PARSE_JSON('{
    "customer_id": 10,
    "order_date": "2024-06-01",
    "items": [
      { "part_id": 123, "quantity": 3 },
      { "part_id": 87, "quantity": 1 },
      { "part_id": 44, "quantity": 10 }
    ]
  }') AS order_json
),
exploded_items AS (
  SELECT 
    order_json:"customer_id"::int AS customer_id,
    order_json:"order_date"::date AS order_date,
    f.value:part_id::int AS part_id,
    f.value:quantity::int AS quantity
  FROM raw_input,
       LATERAL FLATTEN(input => order_json:"items") f
)

SELECT * FROM exploded_items;
```

#### Why this works

- `PARSE_JSON` simulates incoming API data as a `VARIANT`
- `FLATTEN` turns each element of the `items` array into a row
- `LATERAL` allows binding of JSON scope into the `SELECT`
- Explicit casting ensures schema correctness for downstream processing

This approach is robust, fast, and aligns with Snowflake’s best practices for ingesting semi-structured data.

#### Business answer

The order payload is now parsed into 3 separate rows — one for each item. Each row includes customer, order date, part ID, and quantity — ready for validation or insertion into staging tables.

#### Take-aways

* Use `FLATTEN` + `LATERAL` to extract arrays from JSON input
* Always cast `VARIANT` fields into typed columns for safety
* This structure is ideal for **event ingestion**, **ETL pipelines**, or **API-backed warehouses**
* Combine this with `INSERT` to automate order capture in Snowflake

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Write a **stored procedure** `parse_and_stage_order_payload(json_payload STRING)` that:

- Accepts a full JSON order payload as input
- Returns a `TABLE` with the same structure as above
- (Optional) Writes to a staging table `STG_ORDER_ITEMS` using `INSERT INTO ...`

</details>
