WITH first_order_cohorts AS (
  SELECT
    O_CUSTKEY                              AS custkey,
    DATE_TRUNC('MONTH', MIN(O_ORDERDATE))  AS cohort_month
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
  GROUP BY O_CUSTKEY
),
monthly_revenue AS (
  SELECT
    o.O_CUSTKEY                             AS custkey,
    DATE_TRUNC('MONTH', o.O_ORDERDATE)      AS revenue_month,
    SUM(l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT)) AS revenue
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
    ON o.O_ORDERKEY = l.L_ORDERKEY
  GROUP BY 1, 2
),
cohort_monthly AS (
  SELECT
    f.cohort_month,
    m.revenue_month,
    SUM(m.revenue) AS cohort_month_revenue
  FROM first_order_cohorts f
  JOIN monthly_revenue m
    ON f.custkey = m.custkey
  GROUP BY 1, 2
)
SELECT
  cohort_month,
  revenue_month,
  cohort_month_revenue,
  SUM(cohort_month_revenue)
    OVER (
      PARTITION BY cohort_month
      ORDER BY revenue_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_cohort_revenue
FROM cohort_monthly
ORDER BY cohort_month, revenue_month;
