-- Identify patients aged over 65 who are active and have no flu vaccine this season

WITH active_patients AS (
    SELECT
        p.patient_id,
        p.first_name,
        p.last_name,
        p.date_of_birth
    FROM patients p
    WHERE p.registration_status = 'Active'
),

age_data AS (
    SELECT
        patient_id,
        first_name,
        last_name,
        date_of_birth,
        DATE_PART('year', AGE(CURRENT_DATE, date_of_birth)) AS age
    FROM active_patients
),

eligible AS (
    SELECT
        patient_id,
        first_name,
        last_name,
        age
    FROM age_data
    WHERE age >= 65
),

flu_vaccines_this_season AS (
    SELECT
        v.patient_id
    FROM vaccinations v
    WHERE v.vaccine_code IN (
        'FLU001',
        'FLU002',
        'FLU003'
    )
    AND v.vaccine_date >= DATE_TRUNC('year', CURRENT_DATE)
),

contraindications AS (
    SELECT
        c.patient_id
    FROM clinical_events c
    WHERE c.code IN (
        'FLU_CONTRA',
        'FLU_ALLERGY'
    )
),

declines AS (
    SELECT
        c.patient_id
    FROM clinical_events c
    WHERE c.code IN (
        'FLU_DECLINED'
    )
)

SELECT
    e.patient_id,
    e.first_name,
    e.last_name,
    e.age
FROM eligible e
LEFT JOIN flu_vaccines_this_season f
    ON e.patient_id = f.patient_id
LEFT JOIN contraindications ci
    ON e.patient_id = ci.patient_id
LEFT JOIN declines d
    ON e.patient_id = d.patient_id
WHERE f.patient_id IS NULL
AND ci.patient_id IS NULL
AND d.patient_id IS NULL
ORDER BY e.last_name, e.first_name;
