-- CloudTask Pro SaaS Revenue & Churn Analysis
-- 01 - Data Quality & Validation
-- Purpose: Create/validate tables, clean date fields, and verify data quality.

CREATE TABLE subscriptions (
    customer_id VARCHAR(20) PRIMARY KEY,
    plan VARCHAR(50),
    billing_cycle VARCHAR(20),
    industry VARCHAR(100),
    company_size VARCHAR(20),
    seats INT,
    monthly_revenue DECIMAL(10,2),
    acquisition_channel VARCHAR(50),
    region VARCHAR(50),
    signup_date DATE,
    churned VARCHAR(5),
    churn_date DATE,
    churn_reason VARCHAR(100),
    support_tickets_12mo INT,
    nps_score INT,
    feature_usage_pct INT,
    upgraded VARCHAR(5)
);

CREATE TABLE monthly_revenue (
    month DATE,
    total_active_customers INT,
    new_customers INT,
    churned_customers INT,
    monthly_churn_rate_pct DECIMAL(6,2),
    total_mrr DECIMAL(12,2),
    avg_revenue_per_customer DECIMAL(10,2),
    customer_acquisition_cost DECIMAL(10,2)
);

SELECT count(*) FROM subscriptions;
SELECT count(*) FROM monthly_revenue;

SELECT customer_id, COUNT(*) AS occurrence 
FROM subscriptions GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT month, COUNT(*) AS occurrence 
FROM monthly_revenue GROUP BY month
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)
        AS missing_customer_id,

    SUM(CASE WHEN plan IS NULL THEN 1 ELSE 0 END)
        AS missing_plan,

    SUM(CASE WHEN billing_cycle IS NULL THEN 1 ELSE 0 END)
        AS missing_billing_cycle,

    SUM(CASE WHEN monthly_revenue IS NULL THEN 1 ELSE 0 END)
        AS missing_revenue,

    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END)
        AS missing_signup_date,

    SUM(CASE WHEN churned IS NULL THEN 1 ELSE 0 END)
        AS missing_churn_status,

    SUM(CASE WHEN churn_date IS NULL THEN 1 ELSE 0 END)
        AS missing_churn_date,

    SUM(CASE WHEN churn_reason IS NULL THEN 1 ELSE 0 END)
        AS missing_churn_reason

FROM subscriptions;

SELECT customer_id FROM subscriptions
WHERE churn_date IS NULL;


SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN churn_date = '' THEN 1 ELSE 0 END) AS blank_churn_date,

    SUM(CASE WHEN churn_reason = '' THEN 1 ELSE 0 END) AS blank_churn_reason

FROM subscriptions;

DESCRIBE subscriptions;
DESCRIBE monthly_revenue;

UPDATE subscriptions
SET churn_reason = NULL
WHERE churn_reason = '';

SELECT signup_date, churn_date
FROM subscriptions
LIMIT 10;

ALTER TABLE subscriptions
MODIFY signup_date DATE;

UPDATE subscriptions
SET churn_date = NULL
WHERE churn_date = '';


ALTER TABLE subscriptions
MODIFY churn_date DATE;

ALTER TABLE monthly_revenue
ADD COLUMN month_date DATE;

UPDATE monthly_revenue
SET month_date = STR_TO_DATE(
    CONCAT(month, '-01'),
    '%Y-%m-%d'
);

ALTER TABLE monthly_revenue
DROP COLUMN month;

ALTER TABLE monthly_revenue
CHANGE month_date month DATE;


DESCRIBE subscriptions;
DESCRIBE monthly_revenue;

SELECT churned, COUNT(*) AS customers
FROM subscriptions
GROUP BY churned;

SELECT *
FROM subscriptions
WHERE churned = 'Yes'
AND churn_date IS NULL;

SELECT plan, COUNT(*) AS customers
FROM subscriptions
GROUP BY plan
ORDER BY customers DESC;

SELECT billing_cycle, COUNT(*) AS customers
FROM subscriptions
GROUP BY billing_cycle;

SELECT company_size, COUNT(*) AS customers
FROM subscriptions
GROUP BY company_size
ORDER BY customers DESC;

SELECT acquisition_channel, COUNT(*) AS customers
FROM subscriptions
GROUP BY acquisition_channel
ORDER BY customers DESC;

SELECT
    MIN(monthly_revenue) AS min_revenue,
    MAX(monthly_revenue) AS max_revenue,
    AVG(monthly_revenue) AS avg_revenue,

    MIN(seats) AS min_seats,
    MAX(seats) AS max_seats,

    MIN(nps_score) AS min_nps,
    MAX(nps_score) AS max_nps,

    MIN(feature_usage_pct) AS min_usage,
    MAX(feature_usage_pct) AS max_usage

FROM subscriptions;

SELECT
MIN(signup_date) AS first_signup,
MAX(signup_date) AS latest_signup,
MIN(churn_date) AS earliest_churn,
MAX(churn_date) AS latest_churn
FROM subscriptions;

SELECT *
FROM subscriptions
WHERE churn_date < signup_date;

SELECT *
FROM monthly_revenue
ORDER BY month;

/* 
DATA QUALITY SUMMARY

subscriptions.csv
- 600 rows
- 600 unique customer IDs
- No duplicate customer records
- 17 fields
- 313 churned customers
- 287 active customers
- Missing churn_date and churn_reason values correspond to active customers
- Signup data covers 2022–2025
- Plan, billing cycle and company-size categories were checked for consistency

monthly_revenue.csv
- 48 rows
- One observation per month
- Covers Jan 2022–Dec 2025
- No missing values identified
- Contains company-level MRR, customer, churn and CAC metrics
*/