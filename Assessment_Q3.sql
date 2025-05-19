WITH last_transaction AS (
  -- Retrieves last transaction date
  SELECT
    c.plan_id,
    a.owner_id,
    CASE
      WHEN a.is_regular_savings = 1 THEN 'Savings'
      WHEN a.is_a_fund = 1 THEN 'Investment'
      ELSE 'Unknown'
    END AS type,
    COALESCE(
      MAX(STR_TO_DATE(LEFT(c.transaction_date, 10), '%Y-%m-%d')), '2000-01-01'
    ) AS last_transaction_date
  FROM adashi_staging.savings_savingsaccount AS c
  LEFT JOIN adashi_staging.plans_plan AS a
    ON c.plan_id = a.id
  GROUP BY 1, 2, type
)

SELECT
  plan_id,
  owner_id,
  type,
  last_transaction_date,
  DATEDIFF(CURRENT_DATE, last_transaction_date) AS inactivity_days
FROM last_transaction
WHERE
  -- Accounts inactive for over a year
  DATEDIFF(CURRENT_DATE, last_transaction_date) > 365
  AND type IN ('Savings', 'Investment')
ORDER BY inactivity_days DESC;
