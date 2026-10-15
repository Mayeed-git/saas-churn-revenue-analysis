-- 05 - Unit Economics
-- Purpose: Estimate customer lifetime, CLV, CAC, and CLV:CAC by plan.

SELECT
plan,
ROUND(
AVG(TIMESTAMPDIFF(MONTH, signup_date, churn_date)),
2
) AS avg_lifetime_months
FROM subscriptions
WHERE churned = 'Yes'
GROUP BY plan
ORDER BY avg_lifetime_months DESC;

SELECT plan, ROUND(AVG(monthly_revenue), 2) AS avg_mrr_per_customer
FROM subscriptions
GROUP BY plan
ORDER BY avg_mrr_per_customer DESC;

SELECT
    plan,

    ROUND(AVG(monthly_revenue), 2) AS avg_mrr_per_customer,

    ROUND(
        AVG(
            CASE
                WHEN churned = 'Yes'
                THEN TIMESTAMPDIFF(MONTH, signup_date, churn_date)
            END
        ),
        2
    ) AS avg_lifetime_months

FROM subscriptions
GROUP BY plan
ORDER BY plan;

SELECT
plan,
ROUND(AVG(monthly_revenue), 2) AS avg_mrr, ROUND(AVG(
CASE
WHEN churned = 'Yes'
THEN TIMESTAMPDIFF(MONTH, signup_date, churn_date)
END
),
2
) AS avg_lifetime_months,

ROUND(
AVG(monthly_revenue)
*
AVG(
CASE
WHEN churned = 'Yes'
THEN TIMESTAMPDIFF(MONTH, signup_date, churn_date)END),2) AS estimated_clv
FROM subscriptions
GROUP BY plan
ORDER BY estimated_clv DESC;

SELECT
ROUND(AVG(customer_acquisition_cost), 2) AS avg_cac
FROM monthly_revenue;

SELECT
YEAR(month) AS year,
ROUND(AVG(customer_acquisition_cost), 2) AS avg_cac
FROM monthly_revenue
GROUP BY YEAR(month)
ORDER BY year;

WITH plan_clv AS (
    SELECT
        plan,
        AVG(monthly_revenue) AS avg_mrr,
        AVG(CASE WHEN churned = 'Yes'
                 THEN TIMESTAMPDIFF(MONTH, signup_date, churn_date) END) AS avg_lifetime_months
    FROM subscriptions
    GROUP BY plan
),
cac AS (
    SELECT AVG(customer_acquisition_cost) AS avg_cac
    FROM monthly_revenue
),
combined AS (
    SELECT
        p.plan,
        p.avg_mrr,
        p.avg_lifetime_months,
        p.avg_mrr * p.avg_lifetime_months AS clv,
        c.avg_cac
    FROM plan_clv p
    CROSS JOIN cac c
)
SELECT
    plan,
    ROUND(avg_mrr, 2)             AS avg_mrr,
    ROUND(avg_lifetime_months, 2) AS avg_lifetime_months,
    ROUND(clv, 2)                 AS estimated_clv,
    ROUND(avg_cac, 2)             AS avg_cac,
    ROUND(clv / NULLIF(avg_cac, 0), 2) AS clv_cac_ratio
FROM combined
ORDER BY clv_cac_ratio DESC;

SELECT
    plan,

    COUNT(*) AS customers,

    ROUND(
        100.0 *
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(AVG(monthly_revenue), 2) AS avg_mrr,

    ROUND(
        AVG(
            CASE
                WHEN churned = 'Yes'
                THEN TIMESTAMPDIFF(MONTH, signup_date, churn_date)
            END
        ),
        2
    ) AS avg_lifetime_months,

    ROUND(
        AVG(monthly_revenue)
        *
        AVG(
            CASE
                WHEN churned = 'Yes'
                THEN TIMESTAMPDIFF(MONTH, signup_date, churn_date)
            END
        ),
        2
    ) AS estimated_clv

FROM subscriptions
GROUP BY plan
ORDER BY estimated_clv DESC;

/*
Unit Economics Findings
Enterprise customers demonstrate the strongest unit economics, with an estimated CLV of approximately £42.9k and the lowest churn rate at 22%. Business customers also perform strongly, with an estimated CLV of £18.5k.
Starter customers have the weakest economics, with an estimated CLV of only £1.34k, driven by low monthly revenue and a short average lifetime of 6.22 months. This aligns with the previously observed 70.51% churn rate in the Starter segment.
The results suggest that customer retention and value increase substantially with plan tier, making Enterprise and Business customers particularly important to long-term revenue performance.
*/