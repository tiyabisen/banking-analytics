# Banking Analytics — SQL, Python & Power BI

End-to-end analytics project on a retail banking dataset, covering database design, data cleaning, KPI analysis, and a 5-page interactive dashboard. Built to practice the full analyst workflow: SQL → Python → Power BI.

## Project Overview

This project analyzes a retail bank's customers, accounts, loans, cards, and transactions to build a complete picture of bank operations — customer profiles, transaction behavior, loan and credit risk, and branch performance. The dataset is structured in a relational database, validated and analyzed in Python, and presented as a multi-page, interactive Power BI dashboard.

## Tech Stack

- **SQL (MySQL):** Schema design (7 tables), bulk data load, 2 helper views, 30 analysis queries
- **Python (pandas, matplotlib):** Data validation, KPI calculations, visualizations, anomaly flagging
- **Power BI:** 5-page interactive dashboard with cross-page navigation

## Data Model

Seven tables: `customers`, `accounts`, `branches`, `loans`, `cards`, `transactions`, `merchants`. This project uses a structured, synthetic dataset built to simulate realistic retail banking operations, since real bank data isn't accessible to students for privacy reasons.

**Relationships:**
- `customers` → `accounts` (a customer can hold multiple accounts)
- `accounts` → `transactions` (every transaction belongs to an account)
- `accounts` → `branches` (each account is opened at a branch)
- `customers` → `loans`, `customers` + `accounts` → `cards`
- `transactions` → `merchants` (every transaction maps to a merchant/category)

**Helper Views:**
- `daily_txn_summary` — daily transaction count, net amount, debit/credit split
- `customer_balance_summary` — total balance and account count per customer

## SQL Analysis (30 queries, 5 groups)

1. **Customer & Account Profiling** — city distribution, account status mix, income buckets, risk score by city
2. **Transactions & Merchant Behavior** — channel mix, top merchant categories, UPI growth, ATM share by city
3. **Risk & Anomaly Detection** — high-value transaction outliers (window functions + CTEs), dormant-but-active accounts, customer risk deciles
4. **Loans & Credit Risk** — loan book composition, delinquency rate by city, loan vintage performance, cross-sell targeting
5. **Branch Performance** — branch-wise balances and loan books, customer tenure vs balance

## Python Workflow

- Loaded 7 source tables and ran independent data quality checks (nulls, duplicate PANs, zero-amount transactions, balance ranges)
- Calculated headline KPIs (active accounts, average risk score, total balance)
- Built visualizations: monthly transaction trend, merchant category mix, channel mix, average ticket size by transaction type
- Applied a threshold-based rule (>₹50,000) to flag high-value transactions for review
- Exported summary tables for use in Power BI

## Power BI Dashboard

Five connected pages, with consistent navigation across all of them:

- **Executive Summary** — bank-level KPIs, monthly transaction trend, customer distribution by city, income buckets
- **Customer & Accounts** — KYC status, account type mix, customer-level detail table
- **Transactions & Merchants** — channel mix, top merchant categories, flagged high-value transactions
- **Loans & Cards** — loan book by type, delinquency rate by city, card type distribution
- **Branch Performance** — branch-wise balance and loan book, customer/loan density per branch

## Key Insights

- **Account mix is current-account heavy:** Current accounts make up 59.79% of the ~60K customer base, followed by Savings (19.95%), Salary (15.16%), and NRE (5.1%) — indicating the bank's customer base skews toward transactional rather than long-term savings relationships.
- **UPI is a meaningful but not dominant channel:** UPI accounts for 22.07% of the 180K total transactions, with an average ticket size of ₹3.44K, alongside POS, mobile, ATM, and branch channels.
- **High-value transaction flagging surfaces concentrated risk:** Applying a ₹50,000 threshold flagged a distinct set of BillPay, UPI, and NEFT transactions (many routed through mobile and POS channels) for manual review — most flagged transactions cluster between ₹70K–₹170K.
- **Loan delinquency varies significantly by city:** Delinquency rates show a clear geographic spread, with Lucknow, Ahmedabad, and Bengaluru showing the highest rates versus Mumbai and Kolkata showing the lowest — useful for prioritizing collections effort.
- **Home loans anchor the loan book:** Of ~15K total loans (₹13bn total principal, 11.08% average APR), Home loans lead at 5.2K, followed by Personal (3.7K) and Auto (3.1K), with Gold and Education loans smaller at 1.5K each.
- **Credit cards outnumber debit cards 70:30:** Of the active card base, 69.79% are credit cards versus 30.21% debit — a skew worth noting for cross-sell and credit-risk strategy.
- **Branch lending is concentrated, not evenly spread:** Despite ~120 branches averaging ~500 customers and 125 loans each, cities like Surat and Chennai carry disproportionately higher total loan principal than their peers, pointing to geographic concentration in lending exposure.

## Dashboard Preview

| Executive Summary | Customer & Accounts |
|---|---|
| ![Executive Summary](dashboards/executive_summary.png) | ![Customer & Accounts](dashboards/customer_accounts.png) |

| Transactions & Merchants | Loans & Cards |
|---|---|
| ![Transactions & Merchants](dashboards/transactions_merchants.png) | ![Loans & Cards](dashboards/loans_cards.png) |

| Branch Performance |
|---|
| ![Branch Performance](dashboards/branch_performance.png) |

## Repository Structure

```
banking-analytics/
├── banking_setup.sql              # Database, tables, data load, helper views
├── banking_analysis_queries.sql   # 30 analysis queries (5 groups)
├── banking_analysis.ipynb         # Python: cleaning, KPIs, visuals, anomaly detection
├── banking_dashboard.pbix         # Power BI dashboard (5 pages)
└── README.md
```
