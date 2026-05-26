-- Cost impact of individual and combined risk factors
WITH risk_analysis AS (
    SELECT
        smoker,
        bmi_category,
        CASE
            WHEN age >= 60 THEN '60+'
            WHEN age >= 50 THEN '50-59'
            WHEN age >= 40 THEN '40-49'
            WHEN age >= 30 THEN '30-39'
            ELSE '18-29'
        END                                         AS age_group,
        children,
        COUNT(*)                                    AS total_patients,
        ROUND(AVG(charges)::NUMERIC, 2)             AS avg_charges,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
            (ORDER BY charges)::NUMERIC, 2)         AS median_charges,
        ROUND(MAX(charges)::NUMERIC, 2)             AS max_charges,
        COUNT(CASE WHEN high_cost = 1 THEN 1 END)   AS high_cost_count
    FROM patients
    WHERE bmi_category IS NOT NULL
    GROUP BY smoker, bmi_category,
             CASE
                 WHEN age >= 60 THEN '60+'
                 WHEN age >= 50 THEN '50-59'
                 WHEN age >= 40 THEN '40-49'
                 WHEN age >= 30 THEN '30-39'
                 ELSE '18-29'
             END,
             children
)
SELECT *,
    ROUND(high_cost_count * 100.0 /
        NULLIF(total_patients, 0)::NUMERIC, 2)      AS high_cost_rate_pct,
    RANK() OVER (
        ORDER BY avg_charges DESC)                  AS risk_rank
FROM risk_analysis
ORDER BY avg_charges DESC;