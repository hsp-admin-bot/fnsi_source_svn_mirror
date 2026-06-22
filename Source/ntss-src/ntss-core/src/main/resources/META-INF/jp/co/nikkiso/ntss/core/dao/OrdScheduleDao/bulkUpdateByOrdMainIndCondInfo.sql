WITH RECURSIVE
  pat_data AS (
    SELECT DISTINCT
      ord_no,
      ind_treatment_cd,
      treat_date AS treat_date_str,
      treat_date :: DATE AS calendar_date,
      ind_kur_cd AS kur_cd,
      pat_id,
      ind_bed_cd,
      facility_cd,
      treat_week,
      CAST(ind_cond_info -> '1' ->> 'value' AS NUMERIC) AS treatment_time,
      COALESCE(ind_treat_start_time::time, null) as treat_start_time
    FROM ord_main
    WHERE facility_cd = /*facilityCd*/'NKKSBR'
      and ord_no in /*ordNoList*/('6594736','6594754','6594728','6594747')
  ),
  kur_data AS (
    SELECT
      kur_cd,
      kur_start_time::TIME AS kur_start_time,
      kur_standard_start_time::TIME AS kur_standard_start_time,
      kur_end_time::TIME AS kur_end_time
    FROM
      mst_kur
    WHERE
      facility_cd = /*facilityCd*/'NKKSBR'
      AND is_del = '0'
    ORDER BY
      kur_start_time
  )
  ,recursive_pat_data AS (
  SELECT
    ord_no,
    ind_treatment_cd,
    TO_CHAR(TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS'), 'YYYYMMDD') as calendar_date,
    ts.kur_cd::bigint,
    ind_bed_cd,
    ts.pat_id,
    '0' as dummy,
    ts.facility_cd,
    ts.treat_week,
    TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') as calendar_datetime,
    ts.treatment_time,
    (TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') + INTERVAL '1 minute' * ts.treatment_time) AS actual_end_time,
    TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT)::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
  CASE
  WHEN ts.treatment_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT)::TIME)) / 60) > 0
  THEN ts.treatment_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT)::TIME)) / 60)
  ELSE 0
END AS current_remaining_time
  FROM pat_data ts JOIN kur_data kd ON ts.kur_cd = kd.kur_cd
where ts.ind_bed_cd <> '0' and ts.kur_cd <> '0'
  UNION ALL
SELECT
  ord_no,
  ind_treatment_cd,
  TO_CHAR(rt.current_datetime, 'YYYYMMDD') as calendar_date,
  kd.kur_cd,
  ind_bed_cd,
  rt.pat_id,
  '1' as dummy,
  rt.facility_cd,
  rt.treat_week,
  rt.current_datetime AS calendar_datetime,
  rt.treatment_time,
  rt.actual_end_time,
  rt.current_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
  rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) as current_remaining_time
FROM
  recursive_pat_data rt
  JOIN kur_data kd ON rt.current_datetime::TIME >= kd.kur_start_time AND rt.current_datetime::TIME <= kd.kur_end_time
WHERE
  rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) >= 0
  ),
new_ord_schedule as (
SELECT
  facility_cd,
  ord_no,
  calendar_date AS treat_date,
  kur_cd,
  ind_bed_cd AS bed_cd,
  pat_id,
  dummy AS is_dummy,
  treat_week
FROM
  recursive_pat_data

UNION ALL

SELECT
facility_cd,
ord_no,
treat_date_str as treat_date,
kur_cd,
ind_bed_cd AS bed_cd,
pat_id,
'0' AS is_dummy,
treat_week
FROM
  pat_data
where ind_bed_cd = '0' or kur_cd = '0'
),
  resident_data as (
SELECT
  nos.*
FROM
  new_ord_schedule nos
  INNER JOIN ord_schedule os ON nos.facility_cd = os.facility_cd
  AND nos.ord_no = os.ord_no
  AND nos.treat_date = os.treat_date
  AND nos.kur_cd = os.kur_cd
  AND nos.bed_cd = os.bed_cd
  AND nos.pat_id = os.pat_id
  AND nos.is_dummy = os.is_dummy
  AND nos.treat_week = os.treat_week

  ),
del AS (
  DELETE FROM ord_schedule os WHERE os.facility_cd = /*facilityCd*/'NKKSBR'
    and os.ord_no in /*ordNoList*/('6594736','6594754','6594728','6594747')
    and NOT EXISTS (select 1 from resident_data rd where os.facility_cd = rd.facility_cd
    AND os.ord_no = rd.ord_no
    AND os.treat_date = rd.treat_date
    AND os.kur_cd = rd.kur_cd
    AND os.bed_cd = rd.bed_cd
    AND os.pat_id = rd.pat_id
    AND os.treat_week = rd.treat_week)
)
INSERT INTO ord_schedule (
  facility_cd, ord_no, treat_date, kur_cd, bed_cd,
  pat_id, is_dummy, up_date, treat_week, reg_date
)
select
  nos.facility_cd,
  nos.ord_no,
  nos.treat_date,
  nos.kur_cd,
  nos.bed_cd,
  nos.pat_id,
  nos.is_dummy,
  now(),
  nos.treat_week,
  now()
from new_ord_schedule nos
where NOT EXISTS (
  select 1 from resident_data rd
  where nos.facility_cd = rd.facility_cd
   AND nos.ord_no = rd.ord_no
   AND nos.treat_date = rd.treat_date
   AND nos.kur_cd = rd.kur_cd
   AND nos.bed_cd = rd.bed_cd
   AND nos.pat_id = rd.pat_id
   AND nos.treat_week = rd.treat_week
) ON CONFLICT (facility_cd, ord_no, treat_date, kur_cd, bed_cd)
DO UPDATE
SET
  is_dummy   = EXCLUDED.is_dummy,
  up_date    = now()
  RETURNING *
