WITH table_01 AS (
  SELECT
    a.owner_id AS id,
    -- Unique savings accounts
    COUNT(DISTINCT CASE WHEN a.is_regular_savings = 1 THEN a.id END)
      AS savings_count,
    -- Unique investment accounts
    COUNT(DISTINCT CASE WHEN a.is_a_fund = 1 THEN a.id END) AS investment_count,
    -- Unique accounts with both
    COUNT(
      DISTINCT CASE
        WHEN a.is_regular_savings = 1 AND a.is_a_fund = 1 THEN a.id
      END
    ) AS multiple_prod,
    SUM(COALESCE(c.confirmed_amount, 0)) AS total_deposit
  FROM adashi_staging.plans_plan AS a
  LEFT JOIN adashi_staging.savings_savingsaccount AS c
    ON
      a.owner_id = c.owner_id
      AND a.id = c.plan_id
  GROUP BY a.owner_id
),

table_02 AS (
  SELECT
    id,
    savings_count,
    investment_count,
    total_deposit
  FROM
    table_01
  WHERE multiple_prod = 1
)

SELECT
  t2.id AS owner_id,
  t2.savings_count,
  t2.investment_count,
  t2.total_deposit,
  CONCAT(u.first_name, ' ', u.last_name) AS name
FROM
  table_02 AS t2
INNER JOIN
  adashi_staging.users_customuser AS u
  ON t2.id = u.id
ORDER BY
  t2.total_deposit DESC;
