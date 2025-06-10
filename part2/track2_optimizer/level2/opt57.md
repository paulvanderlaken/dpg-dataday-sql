## ex57: Generate a JSON API Payload for Customer Order History

> **Type:** Stretch | **Track:** Query Optimizer  
>
> **Difficulty:** 7 / 10

### Business context
Your team is building a new **customer-facing order portal**, and the backend will expose **monthly order data** through an API.

Each API response should return a structured **JSON object** for a given customer and time window. The response must include:
- The customer’s name and nation
- A list of orders within the timeframe
- For each order: its ID, date, and a nested list of part names and quantities

Your task is to **generate this payload entirely from SQL**, using the TPCH data — which represents your internal ERP system.

---

**API-style output (one JSON per customer)**:

```json
{
  "customer_name": "Customer#000000010",
  "nation": "UNITED STATES",
  "orders": [
    {
      "order_id": 42,
      "order_date": "1995-03-03",
      "parts": [
        { "part_name": "steel green widget", "quantity": 15 },
        { "part_name": "brass fastener", "quantity": 3 }
      ]
    },
    …
  ]
}
```

Your goal is to assemble this structure for `C_CUSTKEY = 10`, restricted to orders placed in March 1995.

---

### Starter query

```sql
-- Preview part-level order detail for customer 10
SELECT 
  O.O_ORDERKEY,
  O.O_ORDERDATE,
  P.P_NAME,
  L.L_QUANTITY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
  ON O.O_ORDERKEY = L.L_ORDERKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
  ON L.L_PARTKEY = P.P_PARTKEY
WHERE O.O_CUSTKEY = 10
  AND O.O_ORDERDATE BETWEEN '1995-03-01' AND '1995-03-31'
ORDER BY O.O_ORDERDATE;
```

---

### Required datasets

* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

Build the JSON from the **inside out**:
1. First create the `parts` array per order using `ARRAY_AGG(OBJECT_CONSTRUCT(...))`
2. Then group those into `orders`, using another `ARRAY_AGG`
3. Finally construct a top-level JSON object using `OBJECT_CONSTRUCT`

You’ll likely need a CTE for each stage: parts → orders → final payload.

#### Helpful SQL functions

`OBJECT_CONSTRUCT`, `ARRAY_AGG`, nested aggregation, date filtering

```sql
ARRAY_AGG(OBJECT_CONSTRUCT('part_name', P.P_NAME, 'quantity', L.L_QUANTITY))
```

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

```sql
WITH part_detail AS (
  SELECT 
    O.O_ORDERKEY,
    O.O_ORDERDATE,
    OBJECT_CONSTRUCT(
      'part_name', P.P_NAME,
      'quantity', L.L_QUANTITY
    ) AS part_obj
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
    ON O.O_ORDERKEY = L.L_ORDERKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
    ON L.L_PARTKEY = P.P_PARTKEY
  WHERE O.O_CUSTKEY = 10
    AND O.O_ORDERDATE BETWEEN '1995-03-01' AND '1995-03-31'
),
order_detail AS (
  SELECT 
    O_ORDERKEY,
    MIN(O_ORDERDATE) AS order_date,
    ARRAY_AGG(part_obj) AS parts
  FROM part_detail
  GROUP BY O_ORDERKEY
),
final_payload AS (
  SELECT 
    C.C_NAME AS customer_name,
    N.N_NAME AS nation,
    ARRAY_AGG(
      OBJECT_CONSTRUCT(
        'order_id', O.O_ORDERKEY,
        'order_date', TO_CHAR(O.order_date, 'YYYY-MM-DD'),
        'parts', O.parts
      )
    ) AS orders
  FROM order_detail O
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS Ord
    ON O.O_ORDERKEY = Ord.O_ORDERKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
    ON Ord.O_CUSTKEY = C.C_CUSTKEY
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
    ON C.C_NATIONKEY = N.N_NATIONKEY
  WHERE C.C_CUSTKEY = 10
  GROUP BY C.C_NAME, N.N_NAME
)

SELECT OBJECT_CONSTRUCT(
  'customer_name', customer_name,
  'nation', nation,
  'orders', orders
) AS customer_order_payload
FROM final_payload;
```

#### Why this works

This approach mirrors how you'd build a **JSON API response** from a relational backend:
- It transforms rows into nested arrays of structured objects
- Preserves parent-child relationships using `GROUP BY` + `ARRAY_AGG`
- Outputs a single clean JSON object ready to be sent over HTTP

It’s **fully Snowflake-native**, and the logic scales across customers and timeframes.

#### Business answer

You’ve now generated a valid **monthly order feed for Customer #10**, in JSON format, containing order and part-level detail — ready to be returned by your API layer.

#### Take-aways

* `OBJECT_CONSTRUCT` + `ARRAY_AGG` is the canonical way to build JSON outputs in SQL.
* Build bottom-up: part → order → customer
* This pattern enables **data products**, APIs, and integrations directly from SQL.
* Snowflake is fully capable of producing structured responses — no middleware required.

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Wrap the logic in a **stored procedure** that accepts:
- `customer_id`
- `start_date`
- `end_date`

Have it return a JSON `RESULTSET` using `RETURN TABLE(...)`, so other systems can call it like:

```sql
CALL get_customer_orders_as_json(10, '1995-03-01', '1995-03-31');
```

</details>
