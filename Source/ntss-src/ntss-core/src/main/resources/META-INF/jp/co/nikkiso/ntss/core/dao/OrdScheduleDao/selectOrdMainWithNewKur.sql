WITH RECURSIVE
  pat_data AS (
  SELECT DISTINCT
	ord_no,
	ind_treatment_cd,
	treat_date :: DATE AS calendar_date,
	ind_kur_cd AS kur_cd,
	pat_id,
	ind_bed_cd,
	facility_cd,
	treat_week,
      CAST(ind_cond_info -> '1' ->> 'value' AS NUMERIC) AS treatment_time,
      COALESCE(ind_treat_start_time::time, null) as treat_start_time
    FROM ord_main
    WHERE facility_cd = /*facilityCd*/null
      and ord_no in /*ordNoList*/(null)
      and ind_bed_cd <> '0'
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
      facility_cd = /*facilityCd*/null
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
  )
select ord_no as key_no, ind_treatment_cd, calendar_date as treat_date, kur_cd, pat_id, ind_bed_cd as bed_cd, facility_cd, dummy, treat_week from recursive_pat_data order by calendar_date, kur_cd, treat_week
