WITH customer_data AS (
  -- Calculate account tenure in months since signup
  SELECT
    u.id AS customer_id,
    concat(u.first_name, ' ', u.last_name) AS name,
    timestampdiff(month, u.date_joined, current_date) AS tenure_months
  FROM adashi_staging.users_customuser AS u
),

transaction_data AS (
  -- Count total transactions per customer & compute average profit per transaction
  SELECT
    s.owner_id AS customer_id,
    count(s.id) AS total_transactions,
    -- Profit per transaction (0.1% of transaction value)
    avg((s.confirmed_amount / 100) * 0.001) AS avg_profit_per_transaction
  FROM adashi_staging.savings_savingsaccount AS s
  GROUP BY s.owner_id
)

SELECT
  c.customer_id,
  c.name,
  c.tenure_months,
  t.total_transactions,
  round(
    (t.total_transactions / nullif(c.tenure_months, 0))
    * 12
    * t.avg_profit_per_transaction
  ) AS estimated_clv
FROM customer_data AS c
LEFT JOIN transaction_data AS t ON c.customer_id = t.customer_id
ORDER BY estimated_clv DESC;
