-- 04 - Revenue Analysis
-- Purpose: Analyze MRR growth, customer growth, and unusual revenue movements.

SELECT month, total_mrr
FROM monthly_revenue
ORDER BY month;

WITH mrr_growth AS (
    SELECT
        month,
        total_mrr,
        ROUND(
            100.0 * (total_mrr - LAG(total_mrr) OVER (ORDER BY month))
            / LAG(total_mrr) OVER (ORDER BY month),
            2
        ) AS mrr_growth_pct
    FROM monthly_revenue
)

SELECT *
FROM mrr_growth
WHERE mrr_growth_pct IS NOT NULL
ORDER BY mrr_growth_pct DESC;

SELECT
YEAR(month) AS year,
ROUND(AVG(total_mrr), 2) AS avg_monthly_mrr,
MIN(total_mrr) AS lowest_monthly_mrr,
MAX(total_mrr) AS highest_monthly_mrr
FROM monthly_revenue
GROUP BY YEAR(month)
ORDER BY year;

SELECT
month,
total_active_customers,
new_customers,
churned_customers,
new_customers - churned_customers AS net_customer_change
FROM monthly_revenue
ORDER BY month;

SELECT
month,
new_customers,
churned_customers,
new_customers - churned_customers AS net_customer_change
FROM monthly_revenue
WHERE new_customers - churned_customers < 0
ORDER BY net_customer_change;

SELECT
month,
avg_revenue_per_customer
FROM monthly_revenue
ORDER BY month;

SELECT
    month,
    avg_revenue_per_customer,

    ROUND(
	100.0 * (
	avg_revenue_per_customer
	- LAG(avg_revenue_per_customer) OVER (ORDER BY month)
	) /
	LAG(avg_revenue_per_customer) OVER (ORDER BY month),
	2
    ) AS arpc_growth_pct

FROM monthly_revenue
ORDER BY month;

WITH mrr_changes AS (
    SELECT
	month,
	total_mrr,
	total_mrr - LAG(total_mrr) OVER (ORDER BY month) AS mrr_change
    FROM monthly_revenue
)

SELECT *
FROM mrr_changes
WHERE mrr_change IS NOT NULL
ORDER BY mrr_change DESC;


WITH mrr_changes AS (
    SELECT
	month,
	total_mrr,
	total_mrr - LAG(total_mrr) OVER (ORDER BY month) AS mrr_change
    FROM monthly_revenue
)

SELECT *
FROM mrr_changes
WHERE mrr_change IS NOT NULL
ORDER BY mrr_change ASC;

SELECT
month,
total_mrr,
monthly_churn_rate_pct,
new_customers,
churned_customers,
avg_revenue_per_customer
FROM monthly_revenue
ORDER BY monthly_churn_rate_pct DESC;

SELECT
    month,

    ROUND(
        new_customers * avg_revenue_per_customer,
        2
    ) AS estimated_new_mrr,

    ROUND(
        churned_customers * avg_revenue_per_customer,
        2
    ) AS estimated_churned_mrr,

    ROUND(
        (new_customers - churned_customers)
        * avg_revenue_per_customer,
        2
    ) AS estimated_net_mrr_change

FROM monthly_revenue
ORDER BY month;

SELECT
YEAR(month) AS year,
ROUND(AVG(total_mrr), 2) AS avg_monthly_mrr
FROM monthly_revenue
GROUP BY YEAR(month)
ORDER BY year;

SELECT
month,
avg_revenue_per_customer
FROM monthly_revenue
ORDER BY month;

WITH mrr AS (
    SELECT
	month,
	new_customers,
	churned_customers,
	avg_revenue_per_customer,
	ROUND(new_customers * avg_revenue_per_customer, 2) AS estimated_new_mrr,
	ROUND(churned_customers * avg_revenue_per_customer, 2) AS estimated_churned_mrr,
	ROUND((new_customers - churned_customers) * avg_revenue_per_customer, 2) AS estimated_net_mrr_change
    FROM monthly_revenue
)
SELECT
    *,
    RANK() OVER (ORDER BY estimated_net_mrr_change DESC) AS best_month_rank,
    RANK() OVER (ORDER BY estimated_net_mrr_change ASC)  AS worst_month_rank
FROM mrr
ORDER BY estimated_net_mrr_change DESC;

/*
Revenue Findings
CloudTask Pro’s average monthly MRR increased from approximately £46k in 2022 to £283k in 2025, showing strong long-term revenue growth.
March 2024 produced the strongest estimated net MRR contribution at approximately £15.6k, while April 2025 was the weakest month at approximately -£4.3k.
April and May 2025 were the clearest periods of revenue pressure. In both months, churned customers exceeded new customers, producing negative net customer growth and negative estimated net MRR.
October 2025 also experienced a 3.69% MRR decline despite positive net customer growth, while average revenue per customer fell 5.12%. This suggests customer mix or lower-value revenue contributed to the decline rather than customer losses alone.
Overall, revenue growth remained strong, but elevated churn created identifiable periods of short-term pressure.
*/
