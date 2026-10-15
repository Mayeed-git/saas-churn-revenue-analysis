-- 03 - Churn Reasons
-- Purpose: Identify why customers churn and which reasons may be controllable.

SELECT churn_reason, COUNT(*) AS churned_customers,
ROUND(
	100.0 * COUNT(*) /
	(SELECT COUNT(*)
	 FROM subscriptions
	 WHERE churned = 'Yes'),
	2
) AS pct_of_churned_customers
FROM subscriptions
WHERE churned = 'Yes'
GROUP BY churn_reason
ORDER BY churned_customers DESC;

SELECT
plan,
churn_reason,
COUNT(*) AS churned_customers
FROM subscriptions
WHERE churned = 'Yes'
GROUP BY plan, churn_reason
ORDER BY plan, churned_customers DESC;

WITH reason_counts AS (
    SELECT
        company_size,
        churn_reason,
        COUNT(*) AS churned_customers,
        ROUND(
            100.0 * COUNT(*) /
            SUM(COUNT(*)) OVER (PARTITION BY company_size),
            2
        ) AS pct_of_company_size_churn,
        ROW_NUMBER() OVER (
            PARTITION BY company_size
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM subscriptions
    WHERE churned = 'Yes'
    GROUP BY company_size, churn_reason
)
SELECT company_size, churn_reason, churned_customers, pct_of_company_size_churn
FROM reason_counts
WHERE rn <= 2
ORDER BY company_size, pct_of_company_size_churn DESC;

SELECT
    plan,
    company_size,
    churn_reason,
    COUNT(*) AS churned_customers
FROM subscriptions
WHERE churned = 'Yes'
GROUP BY plan, company_size, churn_reason
HAVING COUNT(*) >= 3
ORDER BY churned_customers DESC;

SELECT
    churn_reason,
    COUNT(*) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_segment_churn
FROM subscriptions
WHERE churned = 'Yes'
  AND plan = 'Starter'
  AND billing_cycle = 'Monthly'
GROUP BY churn_reason
ORDER BY churned_customers DESC;

/*
Churn Reason Findings:
Budget cuts, high pricing, and company closures were the three most common churn reasons overall. Lower-tier customers showed stronger price sensitivity: Starter and Professional customers most commonly churned because of price or budget constraints. Business customers were more likely to cite missing features, while Enterprise churn was more associated with company closure or reduced need for the product.
Company size also influenced churn reasons. Small customers frequently cited budget constraints, while poor support emerged as a leading churn reason among 500+ employee companies. This is especially notable because the 500+ segment also had the highest churn rate by company size.
Among high-risk Starter customers on monthly billing, Price Too High and Budget Cuts were the two most common churn reasons, reinforcing the possibility that perceived value and pricing may be contributing to churn in this segment.

54.63% of churn was associated with potentially controllable factors, indicating that more than half of customer losses may be addressable through pricing, product improvements, support quality, or competitive positioning.

Starter customers showed the highest churn rate, with price-related reasons among the most common. Meanwhile, poor support was prominent among the 500+ employee segment. Together, these findings suggest that different retention strategies may be needed for different customer groups.
*/

SELECT
CASE
	WHEN churn_reason IN (
		'Price Too High',
		'Poor Support',
		'Missing Features',
		'Switched Competitor'
	)
	THEN 'Potentially Controllable'

	WHEN churn_reason IN (
		'Budget Cuts',
		'Company Closed',
		'No Longer Needed'
	)
	THEN 'External / Less Controllable'

	ELSE 'Other'
END AS reason_category,

COUNT(*) AS churned_customers,

ROUND(
	100.0 * COUNT(*) /
	SUM(COUNT(*)) OVER (),
	2
) AS pct_of_churn

FROM subscriptions
WHERE churned = 'Yes'
GROUP BY reason_category
ORDER BY churned_customers DESC;