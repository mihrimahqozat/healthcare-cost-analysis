-- Patient cost segmentation and burden analysis
WITH cost_segments AS (
    SELECT
        patient_id,
        age,
        sex,
        bmi,
        smoker,
        region,
        charges,
        age_group,
        bmi_category,
        CASE
            WHEN charges >= 40000 THEN 'Very High (>$40K)'
            WHEN charges >= 20000 THEN 'High ($20K-$40K)'
            WHEN charges >= 10000 THEN 'Medium ($10K-$20K)'
            ELSE 'Low (<$10K)'
        END AS cost_tier,
        smoker_bmi_risk
    FROM patients
),
segmented AS (
    SELECT *,
        ROUND((charges * 100.0 /
            SUM(charges) OVER ())::NUMERIC, 4)      AS pct_of_total_cost,
        RANK() OVER (ORDER BY charges DESC)         AS cost_rank,
        NTILE(10) OVER (ORDER BY charges DESC)      AS cost_decile,
        ROUND(AVG(charges) OVER (
            PARTITION BY region)
            ::NUMERIC, 2)                           AS region_avg_charges,
        ROUND(AVG(charges) OVER (
            PARTITION BY smoker)
            ::NUMERIC, 2)                           AS smoker_avg_charges
    FROM cost_segments
)
SELECT
    cost_tier,
    COUNT(*)                                        AS total_patients,
    ROUND(AVG(charges)::NUMERIC, 2)                 AS avg_charges,
    ROUND(SUM(charges)::NUMERIC, 2)                 AS total_charges,
    ROUND((SUM(charges) * 100.0 /
        SUM(SUM(charges)) OVER ())::NUMERIC, 2)     AS pct_of_total_cost,
    COUNT(CASE WHEN smoker = 'yes' THEN 1 END)      AS smokers,
    COUNT(CASE WHEN smoker_bmi_risk = 1 THEN 1 END) AS high_risk_patients,
    ROUND(AVG(bmi)::NUMERIC, 2)                     AS avg_bmi,
    ROUND(AVG(age)::NUMERIC, 2)                     AS avg_age
FROM segmented
GROUP BY cost_tier
ORDER BY avg_charges DESC;