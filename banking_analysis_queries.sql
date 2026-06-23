USE banking_project;
 
-- GROUP A: CUSTOMER & ACCOUNT PROFILING
 
SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;
 
SELECT status, COUNT(*) AS total_accounts
FROM accounts
GROUP BY status
ORDER BY total_accounts DESC;
 
SELECT account_type, ROUND(AVG(balance), 2) AS avg_balance
FROM accounts
GROUP BY account_type
ORDER BY avg_balance DESC;
 
SELECT DATE_FORMAT(signup_date, '%Y-%m') AS signup_month, COUNT(*) AS new_customers
FROM customers
GROUP BY signup_month
ORDER BY signup_month;
 
SELECT
  CASE
    WHEN monthly_income < 25000  THEN 'Below 25k'
    WHEN monthly_income < 50000  THEN '25k - 50k'
    WHEN monthly_income < 100000 THEN '50k - 1L'
    WHEN monthly_income < 200000 THEN '1L - 2L'
    ELSE '2L and above'
  END AS income_bucket,
  COUNT(*) AS total_customers
FROM customers
GROUP BY income_bucket
ORDER BY total_customers DESC;
 
SELECT city, ROUND(AVG(risk_score), 1) AS avg_risk_score
FROM customers
GROUP BY city
ORDER BY avg_risk_score ASC;
 
SELECT accounts_held, COUNT(*) AS number_of_customers
FROM (
  SELECT customer_id, COUNT(*) AS accounts_held
  FROM accounts
  GROUP BY customer_id
) AS per_customer_counts
GROUP BY accounts_held
ORDER BY accounts_held;

-- GROUP B: TRANSACTIONS & MERCHANT BEHAVIOR
 
SELECT * FROM daily_txn_summary ORDER BY txn_day;
 
SELECT m.category,
  ROUND(SUM(ABS(CASE WHEN t.amount < 0 THEN t.amount ELSE 0 END)), 2) AS total_spend
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.category
ORDER BY total_spend DESC;
 
SELECT channel, COUNT(*) AS txn_count
FROM transactions
GROUP BY channel
ORDER BY txn_count DESC;
 
SELECT txn_type, ROUND(AVG(ABS(amount)), 2) AS avg_ticket_size
FROM transactions
GROUP BY txn_type
ORDER BY avg_ticket_size DESC;
 
SELECT DATE_FORMAT(txn_datetime, '%Y-%m') AS txn_month, ROUND(SUM(amount), 2) AS net_amount
FROM transactions
GROUP BY txn_month
ORDER BY txn_month;
 
SELECT m.merchant_name,
  ROUND(SUM(ABS(CASE WHEN t.amount < 0 THEN t.amount ELSE 0 END)), 2) AS total_spend
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_name
ORDER BY total_spend DESC
LIMIT 25;
 
SELECT DATE_FORMAT(txn_datetime, '%Y-%m') AS txn_month, COUNT(*) AS upi_txns
FROM transactions
WHERE txn_type = 'UPI'
GROUP BY txn_month
ORDER BY txn_month;
 
SELECT c.city,ROUND(
    SUM(CASE WHEN t.txn_type = 'ATM' THEN ABS(t.amount) ELSE 0 END)
    / SUM(ABS(t.amount)) * 100
  , 2) AS atm_share_pct
FROM transactions t
JOIN accounts a  ON t.account_id  = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY c.city
ORDER BY atm_share_pct DESC;
 
-- GROUP C: RISK & ANOMALY DETECTION
 
WITH txn_amounts AS (
  SELECT transaction_id, ABS(amount) AS abs_amount
  FROM transactions
),
ranked_amounts AS (
  SELECT
    transaction_id,
    abs_amount,
    ROW_NUMBER() OVER (ORDER BY abs_amount) AS row_num,
    COUNT(*) OVER () AS total_rows
  FROM txn_amounts
),
percentile_99 AS (
  SELECT abs_amount AS threshold_value
  FROM ranked_amounts
  WHERE row_num = CEIL(0.99 * total_rows)
)
SELECT t.*
FROM transactions t
WHERE ABS(t.amount) > (SELECT threshold_value FROM percentile_99);
 
SELECT a.account_id, a.status, MAX(t.txn_datetime) AS last_txn_date
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
WHERE a.status = 'Dormant'
GROUP BY a.account_id, a.status
HAVING last_txn_date > DATE_SUB(CURDATE(), INTERVAL 90 DAY);
 
WITH ranked_balances AS (
  SELECT
    customer_id,
    total_balance,
    ROW_NUMBER() OVER (ORDER BY total_balance) AS row_num,
    COUNT(*) OVER () AS total_rows
  FROM customer_balance_summary
),
percentile_99 AS (
  SELECT total_balance AS threshold_value
  FROM ranked_balances
  WHERE row_num = CEIL(0.99 * total_rows)
)
SELECT cbs.*
FROM customer_balance_summary cbs
WHERE cbs.total_balance > (SELECT threshold_value FROM percentile_99)
ORDER BY cbs.total_balance DESC;
 
SELECT pan_number, COUNT(*) AS record_count
FROM customers
GROUP BY pan_number
HAVING record_count > 1;
 
WITH risk_deciles AS (
  SELECT customer_id, NTILE(10) OVER (ORDER BY risk_score) AS risk_decile
  FROM customers
)
SELECT rd.risk_decile, ROUND(AVG(a.balance), 2) AS avg_balance
FROM risk_deciles rd
JOIN accounts a ON rd.customer_id = a.customer_id
GROUP BY rd.risk_decile
ORDER BY rd.risk_decile;
 
-- GROUP D: LOANS & CREDIT RISK
 
SELECT loan_type, COUNT(*) AS num_loans, ROUND(SUM(principal_amount), 2) AS total_principal
FROM loans
GROUP BY loan_type
ORDER BY total_principal DESC;
 
SELECT b.city,ROUND(AVG(l.status = 'Delinquent') * 100, 2) AS delinquency_rate_pct
FROM loans l
JOIN branches b ON l.branch_id = b.branch_id
GROUP BY b.city
ORDER BY delinquency_rate_pct DESC;
 
SELECT loan_type, ROUND(AVG(interest_rate_apr), 2) AS avg_apr
FROM loans
GROUP BY loan_type
ORDER BY avg_apr DESC;
 
SELECT DATE_FORMAT(issue_date, '%Y-%m') AS vintage_month,COUNT(*) AS loans_issued,
  ROUND(AVG(status = 'Delinquent') * 100, 2) AS delinquency_pct
FROM loans
GROUP BY vintage_month
ORDER BY vintage_month;
 
SELECT ROUND(
    (SELECT COUNT(DISTINCT customer_id) FROM loans)
    / (SELECT COUNT(*) FROM customers) * 100, 2) AS loan_penetration_pct;
 
SELECT c.customer_id,
  SUM(ABS(CASE WHEN t.amount < 0 THEN t.amount ELSE 0 END)) AS card_spend,
  SUM(CASE WHEN cd.card_type = 'Credit' THEN cd.credit_limit ELSE 0 END) AS total_credit_limit
FROM customers c
LEFT JOIN cards cd ON c.customer_id = cd.customer_id
LEFT JOIN accounts a ON cd.account_id = a.account_id
LEFT JOIN transactions t ON t.account_id  = a.account_id
GROUP BY c.customer_id
HAVING total_credit_limit > 0
ORDER BY card_spend DESC
LIMIT 50;
 
SELECT c.customer_id, c.full_name
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id AND a.account_type = 'Salary'
LEFT JOIN cards cd ON c.customer_id = cd.customer_id AND cd.card_type = 'Credit' AND cd.is_active = 1
WHERE cd.card_id IS NULL;
 
-- GROUP E: BRANCH PERFORMANCE

SELECT b.branch_id,b.city,ROUND(AVG(a.balance), 2) AS avg_balance,COUNT(a.account_id)AS num_accounts
FROM branches b
JOIN accounts a ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.city
ORDER BY avg_balance DESC;
 
SELECT b.branch_id,b.city, COUNT(l.loan_id) AS num_loans,ROUND(SUM(l.principal_amount), 2) AS total_principal
FROM branches b
JOIN loans l ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.city
ORDER BY total_principal DESC;
 
SELECT TIMESTAMPDIFF(MONTH, c.signup_date, CURDATE()) AS tenure_months,ROUND(AVG(a.balance), 2) AS avg_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY tenure_months
ORDER BY tenure_months;