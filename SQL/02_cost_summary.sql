-- Healthcare cost summary by demographic groups
WITH cost_summary AS (
    SELECT
        sex,
        smoker,
        region,
        age_group,
        COUNT(*)                                    AS total_patients,
        ROUND(AVG(charges)::NUMERIC, 2)             AS avg_charges,
        ROUND(MIN(charges)::NUMERIC, 2)             AS min_charges,
        ROUND(MAX(charges)::NUMERIC, 2)             AS max_charges,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
            (ORDER BY charges)::NUMERIC, 2)         AS median_charges,
        ROUND(STDDEV(charges)::NUMERIC, 2)          AS stddev_charges,
        COUNT(CASE WHEN high_cost = 1 THEN 1 END)   AS high_cost_patients
    FROM patients
    GROUP BY 
		sex, 
		smoker, 
		region, 
		age_group
)
SELECT *,
    ROUND(high_cost_patients * 100.0 /
        NULLIF(total_patients, 0)::NUMERIC, 2)      AS high_cost_rate_pct,
    RANK() OVER (
        ORDER BY avg_charges DESC)                  AS cost_rank
FROM cost_summary
ORDER BY avg_charges DESC;