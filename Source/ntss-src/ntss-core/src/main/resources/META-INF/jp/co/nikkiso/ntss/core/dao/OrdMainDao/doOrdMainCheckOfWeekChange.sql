WITH RECURSIVE update_rules AS (
                 SELECT pat_id
                       ,ind_treatment_cd
                       ,old_treat_week
                       ,new_treat_week
                   from (
                          VALUES
                          (0,0,0,0)
                          /*%for updInfo : updateList */
                          ,(/*updInfo.patId*/0,
                            /*updInfo.indTreatmentCd*/null,
                            /*updInfo.oldTreatWeek*/null,
                            /*updInfo.newTreatWeek*/null)
                          /*%end*/
                        ) AS t(pat_id, ind_treatment_cd, old_treat_week, new_treat_week)
               ),
               copy_rules AS (
                 SELECT pat_id
                       ,ind_treatment_cd
                       ,old_treat_week
                       ,new_treat_week
                 from (
                        VALUES
                        (0,0,0,0)
                         /*%for copyInfo : copyList */
                         ,(/*copyInfo.patId*/0,
                           /*copyInfo.indTreatmentCd*/null,
                           /*copyInfo.oldTreatWeek*/null,
                           /*copyInfo.newTreatWeek*/null)
                        /*%end*/
                      ) AS t(pat_id, ind_treatment_cd, old_treat_week, new_treat_week)
               ),
               exclude_rules AS (
                 SELECT pat_id
                      ,ind_treatment_cd
                      ,treat_week
                 from (
                        VALUES
                        (0,0,0)
                         /*%for delInfo : delList */
                         ,(/*delInfo.patId*/0,
                           /*delInfo.indTreatmentCd*/null,
                           /*delInfo.treatWeek*/null)
                        /*%end*/
                      ) AS t(pat_id, ind_treatment_cd, treat_week)
               ),
-- クールマスタデータ --
               kur_data AS (
                 SELECT
                   kur_cd,
                   kur_start_time::TIME AS kur_start_time,
                   kur_end_time::TIME AS kur_end_time,
                   kur_standard_start_time::TIME AS kur_standard_start_time
                 FROM mst_kur
                 WHERE facility_cd = /*facilityCd*/null
                   AND is_del = '0'
                 ORDER BY
                   kur_start_time
               ),
  own_ord as (
     SELECT treat_date
           ,ind_treat_start_time
           ,ind_kur_cd
           ,ind_schedule_user_info
           ,ind_bed_cd
           ,ind_cond_info
           ,pat_id
           ,ord_no
           ,facility_cd
           ,treat_week
           ,ind_treatment_cd
           ,is_del
           ,'own' as flag
       FROM ord_main
      WHERE facility_cd = /*facilityCd*/null
        AND pat_id = /*patId*/0
        AND is_del = '0'
        AND ind_kur_cd <> 0
        AND ind_bed_cd <> 0
        AND treat_date >= /*startDate*/null
        /*%if null != endDate */
        and treat_date <= /*endDate*/null
        /*%end*/
        and ind_treatment_cd = /*indTreatmentCd*/null
  ),
  oth_ord as (
    SELECT treat_date
         ,ind_treat_start_time
         ,ind_kur_cd
         ,ind_schedule_user_info
         ,ind_bed_cd
         ,ind_cond_info
         ,pat_id
         ,ord_no
         ,facility_cd
         ,treat_week
         ,ind_treatment_cd
         ,is_del
         ,'other' as flag
    FROM ord_main
  WHERE facility_cd = /*facilityCd*/null
    AND is_del = '0'
    AND ind_kur_cd <> 0
    AND ind_bed_cd <> 0
    AND treat_date >= /*startDate*/null
    AND NOT EXISTS (
            SELECT 1
              FROM own_ord ood
             WHERE ord_main.ord_no =  ood.ord_no
            )),
  all_ord as (
    select * from own_ord
            WHERE NOT EXISTS (
                      SELECT 1
                        FROM exclude_rules er
                       WHERE own_ord.pat_id = er.pat_id
                         AND own_ord.ind_treatment_cd = er.ind_treatment_cd
                         AND own_ord.treat_week = er.treat_week)
    union all
    select * from oth_ord
  ),
  base_ord as (
   SELECT
     flag,
     treat_date,
     COALESCE((ind_treat_start_time)::TIME, null) AS treat_start_time,
     ind_kur_cd as kur_cd,
     ind_schedule_user_info ->> 'ind_kur_cd' as before_kur_cd,
     ind_bed_cd as bed_cd,
     (ind_cond_info -> '1' ->> 'value')::NUMERIC AS treatment_time,
     pat_id,
     ord_no,
     facility_cd,
     treat_week,
     ind_treatment_cd
FROM all_ord
WHERE facility_cd = /*facilityCd*/null
  AND is_del = '0'
  AND ind_kur_cd <> 0
  AND ind_bed_cd <> 0
  AND NOT EXISTS (
  SELECT 1
  FROM exclude_rules er
  WHERE all_ord.pat_id = er.pat_id
  AND all_ord.ind_treatment_cd = er.ind_treatment_cd
  AND all_ord.treat_week = er.treat_week
  )
  ),
  calendar_base AS (
SELECT
  TO_CHAR(date::DATE, 'YYYYMMDD') AS calendar_date,
  EXTRACT(ISODOW FROM date)::INT AS week_day
FROM generate_series(
  /*startDate*/null::DATE,
  (date_trunc('month', CURRENT_DATE + INTERVAL '1 year') + INTERVAL '1 month - 1 day')::DATE,
  INTERVAL '1 day'
  ) AS date
  ),
  needs_update AS (
SELECT bo.*
FROM base_ord bo
  JOIN update_rules ur ON bo.pat_id = ur.pat_id AND bo.ind_treatment_cd = ur.ind_treatment_cd
  AND bo.treat_week = ur.old_treat_week
  JOIN own_ord ood on ood.ord_no = bo.ord_no
  ),
-- mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
  update_with_new_date AS (
SELECT
  nu.*,
  ur.new_treat_week,
  (
  SELECT cb.calendar_date FROM calendar_base cb
  WHERE cb.week_day = ur.new_treat_week
  AND cb.calendar_date >= to_char(to_date(nu.treat_date, 'YYYYMMDD') + ((1-CAST(ur.new_treat_week AS INTEGER)) || ' days')::interval, 'YYYYMMDD')
  AND cb.calendar_date <= to_char(to_date(nu.treat_date, 'YYYYMMDD') + ((7-CAST(ur.new_treat_week AS INTEGER)) || ' days')::interval, 'YYYYMMDD')
  AND cb.calendar_date >= /*startDate*/null
  /*%if null != endDate */
  and cb.calendar_date <= /*endDate*/null
  /*%end*/
  ORDER BY cb.calendar_date DESC
  LIMIT 1
  ) AS calendar_date
FROM needs_update nu
  JOIN update_rules ur
ON nu.pat_id = ur.pat_id
  AND nu.ind_treatment_cd = ur.ind_treatment_cd
  AND nu.treat_week = ur.old_treat_week
  ),
  needs_copy AS (
SELECT bo.*
FROM base_ord bo
  JOIN copy_rules cr ON bo.pat_id = cr.pat_id AND bo.ind_treatment_cd = cr.ind_treatment_cd
  AND bo.treat_week = cr.old_treat_week
  JOIN own_ord ood on ood.ord_no = bo.ord_no
  ),
  copy_with_new_date AS (
SELECT
  nc.*,
  cr.new_treat_week,
  (  SELECT cb.calendar_date FROM calendar_base cb
  WHERE cb.week_day = cr.new_treat_week
  AND cb.calendar_date >= to_char(to_date(nc.treat_date, 'YYYYMMDD') + ((1-CAST(nc.treat_week AS INTEGER)) || ' days')::interval, 'YYYYMMDD')
  AND cb.calendar_date <= to_char(to_date(nc.treat_date, 'YYYYMMDD') + ((7-CAST(nc.treat_week AS INTEGER)) || ' days')::interval, 'YYYYMMDD')
  AND cb.calendar_date >= /*startDate*/null
  /*%if null != endDate */
  and cb.calendar_date <= /*endDate*/null
  /*%end*/
  ORDER BY cb.calendar_date DESC
  LIMIT 1) AS calendar_date
FROM needs_copy nc
  JOIN copy_rules cr
ON nc.pat_id = cr.pat_id
  AND nc.ind_treatment_cd = cr.ind_treatment_cd
  AND nc.treat_week = cr.old_treat_week
  ),
  -- mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
  calendar_with_week_type AS (
SELECT
  u.*
FROM update_with_new_date u
UNION ALL
SELECT
  bo.*,
  bo.treat_week as new_treat_week,
  bo.treat_date as calendar_date
FROM base_ord bo
  LEFT JOIN update_with_new_date u ON bo.ord_no = u.ord_no
WHERE u.ord_no IS NULL
UNION ALL
SELECT
  c.*
FROM copy_with_new_date c
  ),
  -- クールマスターデータで２８日分治療予定に対して、ダミースケジュールを作成（Step1） --
  treatment_schedule AS (
SELECT
  cwt.flag,
  TO_TIMESTAMP(cwt.calendar_date || ' ' || COALESCE(cwt.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYYMMDD HH24:MI:SS') AS calendar_datetime,
  cwt.kur_cd,
  cwt.before_kur_cd,
  cwt.bed_cd,
  cwt.treatment_time,
  cwt.treat_start_time,
  cwt.pat_id,
  cwt.ord_no,
  cwt.facility_cd,
  cwt.treat_week,
  cwt.ind_treatment_cd,
  (TO_TIMESTAMP(cwt.calendar_date || ' ' || COALESCE(cwt.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYYMMDD HH24:MI:SS') + INTERVAL '1 minute' * cwt.treatment_time) AS actual_end_time
FROM calendar_with_week_type cwt JOIN kur_data kd ON cwt.kur_cd = kd.kur_cd
ORDER BY
  cwt.calendar_date
  ),
  -- クールマスターデータで２８日分治療予定に対して、ダミースケジュールを作成（Step2最終） --
  recursive_treatment AS (
SELECT
  ts.flag,
  TO_CHAR(ts.calendar_datetime, 'YYYYMMDD') as calendar_date,
  ts.kur_cd,
  ts.before_kur_cd,
  ts.bed_cd,
  ts.pat_id,
  ts.ord_no,
  ts.facility_cd,
  ts.treat_week,
  ts.ind_treatment_cd,
  ts.calendar_datetime,
  ts.treatment_time,
  ts.actual_end_time,
  ts.calendar_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TIME, kd.kur_standard_start_time::TIME))) / 60) + INTERVAL '1 second' as current_datetime,
  ts.treatment_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TIME, kd.kur_standard_start_time::TIME))) / 60)AS current_remaining_time
FROM treatment_schedule ts JOIN kur_data kd ON ts.kur_cd = kd.kur_cd
UNION ALL
SELECT
  rt.flag,
  TO_CHAR(rt.current_datetime, 'YYYYMMDD') as calendar_date,
  kd.kur_cd,
  rt.before_kur_cd,
  rt.bed_cd,
  rt.pat_id,
  rt.ord_no,
  rt.facility_cd,
  rt.treat_week,
  rt.ind_treatment_cd,
  rt.current_datetime AS calendar_datetime,
  rt.treatment_time,
  rt.actual_end_time,
  rt.current_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
  rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) as current_remaining_time
FROM recursive_treatment rt JOIN kur_data kd ON rt.current_datetime::TIME >= kd.kur_start_time AND rt.current_datetime::TIME <= kd.kur_end_time
WHERE
  rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) >= 0
  )
SELECT t.ord_no
      ,t.kur_cd ind_kur_cd
      ,t.bed_cd ind_bed_cd
      ,t.ind_treatment_cd
      ,t.pat_id
      ,t.calendar_date treat_date
FROM recursive_treatment t
WHERE (calendar_date, kur_cd, bed_cd) IN (
  SELECT calendar_date, kur_cd, bed_cd
  FROM recursive_treatment
  GROUP BY calendar_date, kur_cd, bed_cd
  HAVING COUNT(*) > 1
     AND COUNT(DISTINCT flag) > 1
)
  AND NOT EXISTS (
        SELECT 1
          FROM own_ord ood
         WHERE t.ord_no = ood.ord_no
  )
ORDER BY calendar_date, ord_no
