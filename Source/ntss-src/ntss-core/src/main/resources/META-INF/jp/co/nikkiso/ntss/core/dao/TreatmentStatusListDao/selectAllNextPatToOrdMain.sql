WITH kur_info AS (
    SELECT
        kur_cd,
        kur_start_time::int AS start_time,
            kur_end_time::int AS end_time
    FROM mst_kur
    WHERE facility_cd = /*facilityCd*/''
      AND is_del = '0'
)
   , last_kur AS (
    SELECT kur_cd, end_time
    FROM kur_info
    ORDER BY end_time DESC
    LIMIT 1
    )
   , first_kur AS (
SELECT kur_cd, start_time
FROM kur_info
ORDER BY start_time ASC
    LIMIT 1
    )
    , current_kur AS (
SELECT kur_cd
FROM kur_info
WHERE to_char(NOW(), 'HH24MISS')::int BETWEEN start_time AND end_time
    LIMIT 1
    )
SELECT
    CASE
        WHEN c.kur_cd <> l.kur_cd THEN to_char(CURRENT_DATE, 'YYYYMMDD')
        ELSE to_char(CURRENT_DATE + INTERVAL '1 day', 'YYYYMMDD')
        END AS target_date,
    CASE
        WHEN c.kur_cd <> l.kur_cd THEN 0
        ELSE 1
        END AS last_flg,
    f.kur_cd AS first_kur_cd
FROM current_kur c
CROSS JOIN last_kur l
CROSS JOIN first_kur f;
