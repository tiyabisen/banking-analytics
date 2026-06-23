CREATE DATABASE banking_project;
USE banking_project;
 
CREATE TABLE customers (
  customer_id BIGINT PRIMARY KEY,
  full_name VARCHAR(200),
  pan_number CHAR(10),
  dob  DATE,
  city VARCHAR(100),
  monthly_income INT,
  risk_score INT,
  kyc_status  VARCHAR(20),
  signup_date DATE,
  preferred_branch_id BIGINT
);
 
CREATE TABLE branches (
  branch_id BIGINT PRIMARY KEY,
  city  VARCHAR(100),
  ifsc VARCHAR(20),
  opened_date  DATE
);
 
CREATE TABLE merchants (
  merchant_id BIGINT PRIMARY KEY,
  merchant_name VARCHAR(200),
  category  VARCHAR(100),
  city   VARCHAR(100)
);
 
CREATE TABLE accounts (
  account_id BIGINT PRIMARY KEY,
  customer_id BIGINT,
  branch_id BIGINT,
  account_type VARCHAR(20),
  status VARCHAR(20),
  opened_date DATE,
  balance DECIMAL(18,2),
  INDEX idx_acc_customer (customer_id),
  INDEX idx_acc_branch (branch_id)
);
 
CREATE TABLE loans (
  loan_id  BIGINT PRIMARY KEY,
  customer_id BIGINT,
  branch_id BIGINT,
  loan_type VARCHAR(30),
  principal_amount DECIMAL(18,2),
  interest_rate_apr DECIMAL(9,4),
  tenure_months  INT,
  status  VARCHAR(20),
  issue_date  DATE,
  INDEX idx_loan_customer (customer_id),
  INDEX idx_loan_branch (branch_id)
);
 
CREATE TABLE cards (
  card_id BIGINT PRIMARY KEY,
  customer_id BIGINT,
  account_id BIGINT,
  card_type VARCHAR(20),
  network  VARCHAR(20),
  credit_limit  INT,
  is_active TINYINT(1),
  INDEX idx_card_customer (customer_id),
  INDEX idx_card_account (account_id)
);
 
CREATE TABLE transactions (
  transaction_id  BIGINT PRIMARY KEY,
  account_id BIGINT,
  txn_datetime DATETIME,
  txn_type VARCHAR(20),
  amount DECIMAL(18,2),
  merchant_id  BIGINT,
  channel VARCHAR(20),
  INDEX idx_txn_account (account_id),
  INDEX idx_txn_date (txn_datetime),
  INDEX idx_txn_merchant (merchant_id)
);
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, full_name, pan_number, dob, city, monthly_income, risk_score, kyc_status, signup_date, preferred_branch_id);
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/branches.csv'
INTO TABLE branches
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(branch_id, city, ifsc, opened_date);
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/merchants.csv'
INTO TABLE merchants
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(merchant_id, merchant_name, category, city);
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/accounts.csv'
INTO TABLE accounts
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(account_id, customer_id, branch_id, account_type, status, opened_date, balance);
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loans.csv'
INTO TABLE loans
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(loan_id, customer_id, branch_id, loan_type, principal_amount, interest_rate_apr, tenure_months, status, issue_date);
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cards.csv'
INTO TABLE cards
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(card_id, customer_id, account_id, card_type, network, credit_limit, is_active);
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(transaction_id, account_id, txn_datetime, txn_type, amount, merchant_id, channel);
 
SELECT 'customers' AS table_name, COUNT(*) AS rows_loaded FROM customers
UNION ALL SELECT 'branches', COUNT(*) FROM branches
UNION ALL SELECT 'merchants', COUNT(*) FROM merchants
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'loans', COUNT(*) FROM loans
UNION ALL SELECT 'cards', COUNT(*) FROM cards
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;
 
CREATE OR REPLACE VIEW daily_txn_summary AS
SELECT
  DATE(txn_datetime) AS txn_day,
  COUNT(*) AS total_txns,
  ROUND(SUM(amount), 2) AS net_amount,
  ROUND(SUM(CASE WHEN amount < 0 THEN -amount ELSE 0 END), 2) AS total_debit,
  ROUND(SUM(CASE WHEN amount > 0 THEN  amount ELSE 0 END), 2) AS total_credit
FROM transactions
GROUP BY DATE(txn_datetime);
 
CREATE OR REPLACE VIEW customer_balance_summary AS
SELECT
  customer_id,
  ROUND(SUM(balance), 2) AS total_balance,
  COUNT(*) AS num_accounts
FROM accounts
GROUP BY customer_id;
 
SELECT * FROM daily_txn_summary ORDER BY txn_day LIMIT 5;
SELECT * FROM customer_balance_summary ORDER BY total_balance DESC LIMIT 5;