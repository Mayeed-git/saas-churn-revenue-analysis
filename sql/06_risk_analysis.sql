-- 06 - At-Risk Customer Analysis
-- Purpose: Identify churn warning signals and classify active customers by risk.

SELECT
churned,
ROUND(AVG(feature_usage_pct), 2) AS avg_feature_usage
FROM subscriptions
GROUP BY churned;

SELECT
    CASE
        WHEN feature_usage_pct < 25 THEN '0-24%'
        WHEN feature_usage_pct < 50 THEN '25-49%'
        WHEN feature_usage_pct < 75 THEN '50-74%'
        ELSE '75-100%'
    END AS usage_band,

    COUNT(*) AS customers,

    SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate

FROM subscriptions
GROUP BY usage_band
ORDER BY usage_band;

SELECT
churned,
ROUND(AVG(nps_score), 2) AS avg_nps
FROM subscriptions
GROUP BY churned;

SELECT
    CASE
        WHEN nps_score <= 6 THEN 'Detractor'
        WHEN nps_score <= 8 THEN 'Passive'
        ELSE 'Promoter'
    END AS nps_group,

    COUNT(*) AS customers,

    SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 *
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate

FROM subscriptions
GROUP BY nps_group
ORDER BY churn_rate DESC;

SELECT
churned,
ROUND(AVG(support_tickets_12mo), 2) AS avg_support_tickets
FROM subscriptions
GROUP BY churned;

SELECT
    CASE
        WHEN support_tickets_12mo <= 2 THEN '0-2'
        WHEN support_tickets_12mo <= 5 THEN '3-5'
        WHEN support_tickets_12mo <= 10 THEN '6-10'
        ELSE '11+'
    END AS ticket_band,

    COUNT(*) AS customers,

    SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate

FROM subscriptions
GROUP BY ticket_band
ORDER BY churn_rate DESC;

SELECT
    CASE
        WHEN feature_usage_pct < 20 THEN '<20%'
        WHEN feature_usage_pct < 30 THEN '20-29%'
        WHEN feature_usage_pct < 40 THEN '30-39%'
        WHEN feature_usage_pct < 50 THEN '40-49%'
        WHEN feature_usage_pct < 60 THEN '50-59%'
        WHEN feature_usage_pct < 70 THEN '60-69%'
        WHEN feature_usage_pct < 80 THEN '70-79%'
        ELSE '80%+'
    END AS usage_band,

    COUNT(*) AS customers,

    ROUND(
        100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate

FROM subscriptions
GROUP BY usage_band
ORDER BY churn_rate DESC;

-- ------------------------------------------------------------
-- Final risk scoring model
-- ------------------------------------------------------------

WITH risk_scores AS (
    SELECT
        customer_id,
        plan,
        billing_cycle,
        company_size,
        monthly_revenue,
        feature_usage_pct,
        nps_score,
        support_tickets_12mo,
        (CASE WHEN feature_usage_pct < 50 THEN 1 ELSE 0 END) +
        (CASE WHEN nps_score <= 6 THEN 1 ELSE 0 END) +
        (CASE WHEN support_tickets_12mo >= 11 THEN 1 ELSE 0 END) AS risk_score
    FROM subscriptions
    WHERE churned = 'No'
),
customer_risk AS (
    SELECT
        *,
        CASE
            WHEN risk_score >= 2 THEN 'High Risk'
            WHEN risk_score = 1 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM risk_scores
)
SELECT
    risk_level,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_active_customers,
    ROUND(SUM(monthly_revenue), 2) AS total_mrr,
    ROUND(AVG(monthly_revenue), 2) AS avg_customer_mrr
FROM customer_risk
GROUP BY risk_level
ORDER BY
    CASE risk_level
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
    END;

-- High-risk customers and MRR by plan
WITH risk_scores AS (
    SELECT
        customer_id,
        plan,
        monthly_revenue,
        (CASE WHEN feature_usage_pct < 50 THEN 1 ELSE 0 END) +
        (CASE WHEN nps_score <= 6 THEN 1 ELSE 0 END) +
        (CASE WHEN support_tickets_12mo >= 11 THEN 1 ELSE 0 END) AS risk_score
    FROM subscriptions
    WHERE churned = 'No'
)
SELECT
    plan,
    COUNT(*) AS high_risk_customers,
    ROUND(SUM(monthly_revenue), 2) AS high_risk_mrr
FROM risk_scores
WHERE risk_score >= 2
GROUP BY plan
ORDER BY high_risk_mrr DESC;

/*
At-Risk Customer Findings
- Feature usage below 50%, NPS <= 6, and 11+ support tickets are key warning signals.
- Final rule-based risk score classifies 93 of 287 active customers (32.40%) as High Risk,
  132 (45.99%) as Medium Risk, and 62 (21.60%) as Low Risk.
- High-risk MRR is concentrated in Business and Enterprise plans.
*/
