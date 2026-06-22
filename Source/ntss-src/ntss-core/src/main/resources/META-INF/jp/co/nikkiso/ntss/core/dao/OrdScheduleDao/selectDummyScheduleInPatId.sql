WITH RECURSIVE calendar AS (
    SELECT
        generate_series(
                    DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' + INTERVAL '1 year',
                    DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' + INTERVAL '1 year' + INTERVAL '27 days',
                    '1 day' )::date AS calendar_date
    ),
    base_dates AS (
       SELECT
           TO_DATE(ind_treat_start_date, 'YYYYMMDD') AS start_date,
           ind_treat_start_date,
           treat_week,
           treat_type,
           ind_kur_cd AS kur_cd,
           ind_sch_info ->> 'ind_bed_cd' AS bed_cd,
           pat_id,
           ctl_no,
           facility_cd,
           (ind_cond_info -> '1' ->> 'value')::NUMERIC AS treatment_time,
           COALESCE((ind_sch_info ->> 'ind_treat_start_time')::TIME, null) AS treat_start_time,
           ind_treatment_cd
       FROM pat_treatment_pattern
       WHERE
         facility_cd = /*facilityCd*/NULL
         and ind_sch_info ->> 'ind_bed_cd' != '0' and ind_kur_cd != 0
         and pat_id = /*patId*/NULL
         and treat_week in /*weeksArray*/(1,2)
          /*%if indTreatmentCdList != null && 0 != indTreatmentCdList.size()*/
         AND ind_treatment_cd IN /*indTreatmentCdList*/( NULL )
          /*%end*/
          /*%if indKurCdList != null && 0 != indKurCdList.size()*/
         AND ind_kur_cd IN /*indKurCdList*/( NULL )
          /*%end*/
  ),
    calendar_with_week_type AS (
        SELECT
            MOD(EXTRACT(WEEK FROM c.calendar_date) - EXTRACT(WEEK FROM b.start_date), 2) AS week_type,
            EXTRACT(DOW FROM c.calendar_date) AS day_of_week,
            c.calendar_date,
            b.ind_treat_start_date,
            b.treat_week,
            b.treat_type,
            b.pat_id,
            b.ctl_no,
            b.facility_cd,
            b.kur_cd,
            b.bed_cd,
            b.treatment_time,
            b.treat_start_time,
            CASE
            WHEN b.treat_type = '1' THEN 'on'
            WHEN b.treat_type = '2' THEN
            CASE
            WHEN EXTRACT(DOW FROM c.calendar_date) = (b.treat_week % 7)
            AND MOD(EXTRACT(WEEK FROM c.calendar_date) - EXTRACT(WEEK FROM b.start_date), 2) = 0
            AND EXTRACT(DOW FROM b.start_date) IN (0, 1, 3, 5)
            AND EXTRACT(DOW FROM c.calendar_date) IN (0, 1, 3, 5) THEN 'on'
            WHEN EXTRACT(DOW FROM c.calendar_date) = (b.treat_week % 7)
            AND MOD(EXTRACT(WEEK FROM c.calendar_date) - EXTRACT(WEEK FROM b.start_date), 2) = 1
            AND EXTRACT(DOW FROM b.start_date) IN (0, 1, 3, 5)
            AND EXTRACT(DOW FROM c.calendar_date) IN (2, 4, 6) THEN 'on'
            WHEN EXTRACT(DOW FROM c.calendar_date) = (b.treat_week % 7)
            AND MOD(EXTRACT(WEEK FROM c.calendar_date) - EXTRACT(WEEK FROM b.start_date), 2) = 1
            AND EXTRACT(DOW FROM b.start_date) IN (2, 4, 6)
            AND EXTRACT(DOW FROM c.calendar_date) IN (0, 1, 3, 5) THEN 'on'
            WHEN EXTRACT(DOW FROM c.calendar_date) = (b.treat_week % 7)
            AND MOD(EXTRACT(WEEK FROM c.calendar_date) - EXTRACT(WEEK FROM b.start_date), 2) = 0
            AND EXTRACT(DOW FROM b.start_date) IN (2, 4, 6)
            AND EXTRACT(DOW FROM c.calendar_date) IN (2, 4, 6) THEN 'on'
            ELSE 'off'
            END
            WHEN b.treat_type = '3' THEN
            CASE
            WHEN EXTRACT(DOW FROM c.calendar_date) = (b.treat_week % 7)
            AND MOD(EXTRACT(WEEK FROM c.calendar_date) - EXTRACT(WEEK FROM b.start_date), 2) = 0 THEN 'on'
            ELSE 'off'
            END
            ELSE NULL
            END AS generation_status,
            b.ind_treatment_cd
        FROM
            calendar c
            CROSS JOIN
            base_dates b
        WHERE EXTRACT(DOW FROM c.calendar_date) = (b.treat_week % 7)
    ),
    kur_data AS (
        SELECT
            kur_cd,
            kur_start_time::TIME AS kur_start_time,
            kur_end_time::TIME AS kur_end_time,
            kur_standard_start_time::TIME AS kur_standard_start_time
        FROM mst_kur
        WHERE facility_cd = /*facilityCd*/NULL
          AND is_del = '0'
        ORDER BY
            kur_start_time
    ),
    treatment_schedule AS (
        SELECT
            TO_TIMESTAMP(cwt.calendar_date || ' ' || COALESCE(cwt.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') AS calendar_datetime,
            cwt.kur_cd,
            cwt.bed_cd,
            cwt.treatment_time,
            cwt.treat_start_time,
            cwt.pat_id,
            cwt.ctl_no,
            cwt.facility_cd,
            cwt.treat_week,
            (TO_TIMESTAMP(cwt.calendar_date || ' ' || COALESCE(cwt.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') + INTERVAL '1 minute' * cwt.treatment_time) AS actual_end_time,
            cwt.ind_treatment_cd
        FROM calendar_with_week_type cwt JOIN kur_data kd ON cwt.kur_cd = kd.kur_cd
        WHERE cwt.generation_status = 'on'
        ORDER BY
            cwt.calendar_date
    ),
    recursive_treatment AS (
        SELECT
            TO_CHAR(ts.calendar_datetime, 'YYYYMMDD') as calendar_date,
            ts.kur_cd,
            ts.bed_cd,
            ts.pat_id,
            ts.ctl_no,
            ts.facility_cd,
            ts.treat_week,
            ts.calendar_datetime,
            ts.treatment_time,
            ts.actual_end_time,
            ts.calendar_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TIME, kd.kur_standard_start_time::TIME))) / 60) + INTERVAL '1 second' as current_datetime,
            ts.treatment_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TIME, kd.kur_standard_start_time::TIME))) / 60)AS current_remaining_time,
            ts.ind_treatment_cd
        FROM treatment_schedule ts JOIN kur_data kd ON ts.kur_cd = kd.kur_cd
        UNION ALL
        SELECT
            TO_CHAR(rt.current_datetime, 'YYYYMMDD') as calendar_date,
            kd.kur_cd,
            rt.bed_cd,
            rt.pat_id,
            rt.ctl_no,
            rt.facility_cd,
            rt.treat_week,
            rt.current_datetime AS calendar_datetime,
            rt.treatment_time,
            rt.actual_end_time,
            rt.current_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
            rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) as current_remaining_time,
            rt.ind_treatment_cd
        FROM recursive_treatment rt JOIN kur_data kd ON rt.current_datetime::TIME >= kd.kur_start_time AND rt.current_datetime::TIME <= kd.kur_end_time
        WHERE
            rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) >= 0
    )
select pat_id, ctl_no as key_no, ind_treatment_cd, calendar_date as treat_date, kur_cd, bed_cd from recursive_treatment order by calendar_date, kur_cd, pat_id, treat_week
