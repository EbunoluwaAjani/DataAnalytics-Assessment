WITH transaction_data AS (
  -- Count transactions per customer per month
  SELECT
    t.owner_id,
    COUNT(t.owner_id) AS cnt,
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS transaction_month
  FROM adashi_staging.savings_savingsaccount AS t
  INNER JOIN adashi_staging.users_customuser AS b ON t.owner_id = b.id
  GROUP BY t.owner_id, transaction_month
)

SELECT
  segment,
  COUNT(DISTINCT owner_id) AS customer_count,
  AVG(cnt) AS avg_transactions_per_month
FROM (
  -- Categorizing transaction frequency levels
  SELECT
    owner_id,
    cnt,
    transaction_month,
    CASE
      WHEN cnt >= 10 THEN 'High Frequency'
      WHEN cnt BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS segment
  FROM transaction_data
) AS categorized_data
GROUP BY segment;
