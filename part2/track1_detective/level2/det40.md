## ex40: Build a Comprehensive Audit Staging View for Reporting

> **Type:** Core | **Track:** SQL Detective  
>
> **Difficulty:** 8 / 10

### Business context
Your audit pipeline is mature. Leadership wants a **single, comprehensive view** combining all flagged customers, their audit statuses, and key business attributes for segmentation and prioritization.

Your task is to create a **staging view** that:
- Joins `customer_audit_flags` with `status_dim` to get readable flag names and descriptions  
- Joins with the `CUSTOMER` table to add customer details such as name, region, and market segment  
- Shows the timestamp each flag was applied (`FLAGGED_AT`)  
- Allows filtering or grouping by region or segment for downstream reporting  

This view will be the basis for dashboards, escalation workflows, and audit certification.

---

### Starter query

```sql
-- Preview customer details with region and market segment
SELECT
    C_CUSTKEY,
    C_NAME,
    C_ADDRESS,
    C_PHONE,
    C_ACCTBAL,
    C_MKTSEGMENT,
    N_NAME AS NATION_NAME,
    R_NAME AS REGION_NAME
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n ON c.C_NATIONKEY = n.N_NATIONKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r ON n.N_REGIONKEY = r.R_REGIONKEY
LIMIT 10;
```

---

### Required datasets

* `WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags`
* `WORKSHOP_DB.TEMP_SCHEMA.status_dim`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION`
* `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION`

<details>
<summary>💡 Hint (click to expand)</summary>

#### How to think about it

- Join your audit flags to the customer table on `C_CUSTKEY`  
- Join to `status_dim` to get flag descriptions  
- Join to `NATION` and `REGION` for business geography  
- Include the `FLAGGED_AT` timestamp  
- Create a **view or table** named `customer_audit_staging`  
- Think about including columns useful for filtering or grouping in dashboards

#### Helpful SQL concepts

`JOIN`, `CREATE OR REPLACE VIEW`, column selection, business attribute enrichment

</details>

<details>
<summary>✅ Solution (click to expand)</summary>

```sql
CREATE OR REPLACE VIEW WORKSHOP_DB.TEMP_SCHEMA.customer_audit_staging AS
SELECT
    f.C_CUSTKEY,
    c.C_NAME,
    c.C_MKTSEGMENT,
    n.N_NAME AS nation_name,
    r.R_NAME AS region_name,
    s.status_flag,
    s.status_description,
    f.FLAGGED_AT
FROM WORKSHOP_DB.TEMP_SCHEMA.customer_audit_flags f
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c ON f.C_CUSTKEY = c.C_CUSTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n ON c.C_NATIONKEY = n.N_NATIONKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r ON n.N_REGIONKEY = r.R_REGIONKEY
JOIN WORKSHOP_DB.TEMP_SCHEMA.status_dim s ON f.status_id = s.status_id;
```

#### Why this works

This view consolidates the audit pipeline output into a business-friendly format, blending flags with rich customer context and geography, enabling actionable insights and downstream reporting.

#### Business answer

Leadership can now slice and dice flagged customers by region, segment, and audit reason — accelerating remediation and monitoring.

#### Take-aways

* Views enable reusable, maintainable audit outputs  
* Enriching audit data with customer metadata provides business context  
* This synthesis step is critical for stakeholder communication  
* Well-designed audit layers empower governance and data quality

</details>

<details>
<summary>🎁 Bonus Exercise (click to expand)</summary>

Add columns to your view to show:

- The count of distinct audit flags per customer (i.e., how many different issues a customer has)
- The timestamp of the **most recent** flag per customer

This will help prioritize customers with multiple or recent issues.

Hint: Use `COUNT(DISTINCT ...) OVER (PARTITION BY ...)` and `MAX(...) OVER (PARTITION BY ...)`

</details>
