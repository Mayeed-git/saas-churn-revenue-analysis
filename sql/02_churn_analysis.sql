-- 02 - Core Churn Analysis
-- Purpose: Measure overall churn and identify high-risk customer segments.

SELECT COUNT(*) AS total_customers,
SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(
100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
2) AS overall_churn_rate
FROM subscriptions;

SELECT
    plan,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM subscriptions
GROUP BY plan
ORDER BY churn_rate DESC;

SELECT
    billing_cycle,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM subscriptions
GROUP BY billing_cycle
ORDER BY churn_rate DESC;


SELECT
    company_size,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM subscriptions
group by company_size
order by churn_rate DESC;


SELECT
    acquisition_channel,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM subscriptions
GROUP BY acquisition_channel
ORDER BY churn_rate DESC;


SELECT month, monthly_churn_rate_pct
FROM monthly_revenue
ORDER BY month;

SELECT
YEAR(month) AS year,
ROUND(AVG(monthly_churn_rate_pct), 2) AS avg_monthly_churn_rate
FROM monthly_revenue
GROUP BY YEAR(month)
ORDER BY year;

SELECT plan, billing_cycle, company_size, COUNT(*) AS customers,
SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(
100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
2
) AS churn_rate
FROM subscriptions
GROUP BY plan, billing_cycle, company_size
HAVING COUNT(*) >= 20
ORDER BY churn_rate DESC;

/*
Churn Analysis — Preliminary Findings
Overall customer churn across the dataset was 52.17%. However, monthly churn has improved substantially over time, declining from an average of 6.81% in 2022 to approximately 3.6% by 2024–2025.
Starter-plan customers showed the highest churn rate at 70.51%, compared with only 22.00% for Enterprise customers. Monthly-billed customers also churned considerably more frequently than annual customers (60.51% vs. 40.32%).
Direct Sales generated the strongest customer retention, while Referral customers had the highest churn rate. At the segment level, Starter customers on monthly billing—particularly smaller companies—appear to represent one of the company's highest-risk customer groups.
Further analysis is required to determine whether churn differences are associated with product engagement, NPS, churn reasons and customer acquisition characteristics.
*/
