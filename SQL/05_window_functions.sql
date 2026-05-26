-- Regional cost analysis with percentile rankings
WITH regional_stats AS (
    SELECT
        region,
        sex,
        smoker,
        bmi_category,
        COUNT(*)                                    AS total_patients,
        ROUND(AVG(charges)::NUMERIC, 2)             AS avg_charges,
        ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP
            (ORDER BY charges)::NUMERIC, 2)         AS q1_charges,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
            (ORDER BY charges)::NUMERIC, 2)         AS median_charges,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP
            (ORDER BY charges)::NUMERIC, 2)         AS q3_charges,
        ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP
            (ORDER BY charges)::NUMERIC, 2)         AS p90_charges,
        ROUND(SUM(charges)::NUMERIC, 2)             AS total_charges
    FROM patients
    WHERE bmi_category IS NOT NULL
    GROUP BY 
		region, 
		sex, 
		smoker, 
		bmi_category
)
SELECT *,
    RANK() OVER (ORDER BY avg_charges DESC)         AS global_rank,
    RANK() OVER (
        PARTITION BY region
        ORDER BY avg_charges DESC)                  AS rank_within_region,
    ROUND(total_charges * 100.0 /
        SUM(total_charges) OVER ()
        ::NUMERIC, 4)                               AS pct_of_total_charges,
    ROUND(q3_charges - q1_charges::NUMERIC, 2)      AS iqr_charges
FROM regional_stats
ORDER BY global_rank;