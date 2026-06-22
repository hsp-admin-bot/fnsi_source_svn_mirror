WITH RECURSIVE SELECTOR AS (
    SELECT MST.FACILITY_CD
         , SETTINGS.CODE,row_number() over() as index
      FROM MST_SELECTOR MST
     CROSS JOIN JSONB_TO_RECORDSET ( MST.ORDER_SETTINGS -> 'items' ) AS SETTINGS ( CODE BIGINT )
     WHERE MST.FACILITY_CD      = /*facilityCd*/null
       AND MASTER_PHYSICAL_NAME = 'mst_bed'
    )
    , ALL_BED AS (
    SELECT BED.BED_CD
         , BED.FACILITY_CD
         , BED.FN_BED_NO
-- del #10280 ベッドマスタに不要なカラムが存在する dengshen start
--          , BED.BED_NO
-- del #10280 ベッドマスタに不要なカラムが存在する dengshen end
         , BED.BED_NAME
         , BED.SHUNT_POSITION
         , BED.IS_INFECTION
         , BED.EMERGENCY_CLASS
         , BED.MACHINE_NO
         , BED.OUTPUT_PRINTER
         , BED.IS_AUTOPRINT_BEFORE
         , BED.IS_AUTOPRINT_AFTER
         , BED.IS_AUTOPRINT_COMMIT
         , BED.IN_HOSPITAL_CD_1
         , BED.IN_HOSPITAL_CD_2
         , BED.IS_DISP
         , BED.IS_DEL
         , BED.REG_DATE
         , BED.UP_DATE
         , BED.IS_HOME_DIALYSIS
         ,SELECTOR.index
      FROM MST_BED BED
     INNER JOIN SELECTOR
        ON BED.FACILITY_CD    = SELECTOR.FACILITY_CD
       AND BED.BED_CD         = SELECTOR.CODE
     --以下、有効なベッド(=machine_noが有効)を絞り込むために追加
     INNER JOIN MST_MACHINE MACHINE
        ON BED.FACILITY_CD    = MACHINE.FACILITY_CD
       AND MACHINE.MACHINE_NO = BED.MACHINE_NO
       AND MACHINE.IS_DISP    = '1'
       AND MACHINE.IS_DEL     = '0'
     WHERE BED.FACILITY_CD    = /*facilityCd*/NULL
       AND BED.IS_DISP        = '1'
       AND BED.IS_DEL         = '0'
    -- mod #9331  by zhangruixue 2023-08-07 --start
--      ORDER BY SELECTOR.INDEX
    -- mod #9331  by zhangruixue 2023-08-07 --start
    ),
       pat_data_om AS (
           SELECT
               DISTINCT treat_date::date as calendar_date,
               /*kurCd*/0 as kur_cd,
               pat_id,
               facility_cd,
               ord_no,
               CAST(ind_cond_info -> '1' ->> 'value' AS NUMERIC) AS treatment_time,
               COALESCE(ind_treat_start_time::time, null) as treat_start_time
           FROM ord_main
           WHERE
            ord_main.FACILITY_CD = /*facilityCd*/NULL
               /*%if null != searchStartDate*/
             AND ord_main.TREAT_DATE >= /*searchStartDate*/NULL
               /*%end*/
               /*%if null != searchEndDate*/
             AND ord_main.TREAT_DATE <= /*searchEndDate*/NULL
               /*%end*/
               /*%if null != patId*/
             AND ord_main.pat_id = /*patId*/NULL
               /*%end*/
               /*%if 0 != treatWeekList.size() && 0 != treatWeekList.get(0)*/
             AND ord_main.TREAT_WEEK IN /*treatWeekList*/( NULL )
               /*%end*/
               /*%if 0 != indTreatmentCdList.size()*/
             AND ord_main.IND_TREATMENT_CD IN /*indTreatmentCdList*/( NULL )
               /*%end*/
               /*%if 0 != indKurCdList.size()*/
             AND ord_main.IND_KUR_CD IN /*indKurCdList*/( NULL )
               /*%end*/
             AND ord_main.IS_DEL = '0'
       ),
       kur_data_om AS (
           SELECT
               kur_cd,
               kur_start_time::TIME AS kur_start_time,
               kur_end_time::TIME AS kur_end_time,
               kur_standard_start_time::TIME AS kur_standard_start_time
           FROM mst_kur
           WHERE facility_cd = /*facilityCd*/NULL AND is_del = '0'
           ORDER BY kur_start_time
       ),
       recursive_pat_data_om AS (
           SELECT
               TO_CHAR(TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS'), 'YYYYMMDD') as calendar_date,
               ts.kur_cd::bigint,
               ts.pat_id,
               ts.facility_cd,
               ts.ord_no,
               TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') as calendar_datetime,
               ts.treatment_time,
               (TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') + INTERVAL '1 minute' * ts.treatment_time) AS actual_end_time,
               TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT)::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
               ts.treatment_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT)::TIME)) / 60) AS current_remaining_time
            FROM pat_data_om ts JOIN kur_data_om kd ON ts.kur_cd::TEXT = kd.kur_cd::TEXT
            UNION ALL
            SELECT
                TO_CHAR(rt.current_datetime, 'YYYYMMDD') as calendar_date,
                kd.kur_cd,
                rt.pat_id,
                rt.facility_cd,
                rt.ord_no,
                rt.current_datetime AS calendar_datetime,
                rt.treatment_time,
                rt.actual_end_time,
                rt.current_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
                rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) as current_remaining_time
            FROM recursive_pat_data_om rt JOIN kur_data_om kd ON rt.current_datetime::TIME >= kd.kur_start_time AND rt.current_datetime::TIME <= kd.kur_end_time
            WHERE
                rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) >= 0
       ),
     USED_BED AS (
            SELECT
              os1.bed_cd,
              count(1) AS TREAT_DATE_NUM
            FROM
                (SELECT  DISTINCT os.facility_cd,os.ord_no,os.treat_date,os.kur_cd,os.bed_cd
                FROM recursive_pat_data_om rd, ord_schedule os
                WHERE rd.facility_cd = os.facility_cd and rd.calendar_date = os.treat_date and rd.kur_cd = os.kur_cd
                and os.ord_no not in (select ord_no from pat_data_om)) os1
            GROUP BY os1.bed_cd
     ),
     calendar AS (
            SELECT
                generate_series(
                DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' + INTERVAL '1 year',
                DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' + INTERVAL '1 year' + INTERVAL '13 days',
                '1 day'
                )::date AS calendar_date
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
                COALESCE((ind_sch_info ->> 'ind_treat_start_time')::TIME, null) AS treat_start_time
            FROM
                pat_treatment_pattern
            WHERE facility_cd = /*facilityCd*/NULL
                /*%if 0 != treatWeekList.size() && 0 != treatWeekList.get(0)*/
              AND treat_week IN /*treatWeekList*/( NULL )
                /*%end*/
                /*%if 0 != indTreatmentCdList.size() && null != patId*/
              AND (CASE WHEN pat_id = /*patId*/NULL THEN ind_treatment_cd IN /*indTreatmentCdList*/( NULL )
                   ELSE 1=1 END)
                /*%end*/
                /*%if 0 != indKurCdList.size()*/
              AND ind_kur_cd IN /*indKurCdList*/( NULL )
                /*%end*/
              AND (ind_kur_cd != 0 or (pat_id = /*patId*/NULL
                /*%if 0 != treatWeekList.size() && 0 != treatWeekList.get(0)*/
              AND treat_week IN /*treatWeekList*/( NULL )
                /*%end*/
                /*%if 0 != indTreatmentCdList.size() && null != patId*/
              AND (ind_treatment_cd IN /*indTreatmentCdList*/( NULL ))
                /*%end*/
                /*%if 0 != indKurCdList.size()*/
              AND ind_kur_cd IN /*indKurCdList*/( NULL )
                /*%end*/
              ))
              AND ((ind_sch_info ->> 'ind_bed_cd')::INT != 0
                /*%if null != patId*/
               OR pat_id = /*patId*/NULL
                /*%end*/
              )
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
                END AS generation_status
            FROM calendar c CROSS JOIN base_dates b
            WHERE EXTRACT(DOW FROM c.calendar_date) = (b.treat_week % 7)
    ),
    pat_data AS (
            SELECT DISTINCT calendar_date, /*kurCd*/0 as kur_cd, pat_id, ctl_no, facility_cd, treatment_time, treat_start_time
            FROM calendar_with_week_type
            WHERE generation_status = 'on'
                /*%if null != patId*/
                AND pat_id = /*patId*/NULL
                /*%end*/
    ),
    kur_data AS (
            SELECT
                kur_cd,
                kur_start_time::TIME AS kur_start_time,
                kur_end_time::TIME AS kur_end_time,
                kur_standard_start_time::TIME AS kur_standard_start_time
            FROM mst_kur
            WHERE facility_cd = /*facilityCd*/NULL AND is_del = '0'
            ORDER BY kur_start_time
    ),
    recursive_pat_data AS (
            SELECT
                TO_CHAR(TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS'), 'YYYYMMDD') as calendar_date,
                ts.kur_cd::bigint,
                ts.pat_id,
                ts.ctl_no,
                ts.facility_cd,
                TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') as calendar_datetime,
                ts.treatment_time,
                (TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') + INTERVAL '1 minute' * ts.treatment_time) AS actual_end_time,
                TO_TIMESTAMP(ts.calendar_date || ' ' || COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT), 'YYYY-MM-DD HH24:MI:SS') + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT)::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
                ts.treatment_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TEXT, kd.kur_standard_start_time::TEXT)::TIME)) / 60) AS current_remaining_time
            FROM
                pat_data ts JOIN kur_data kd ON ts.kur_cd::TEXT = kd.kur_cd::TEXT
            UNION ALL
            SELECT
                TO_CHAR(rt.current_datetime, 'YYYYMMDD') as calendar_date,
                kd.kur_cd,
                rt.pat_id,
                rt.ctl_no,
                rt.facility_cd,
                rt.current_datetime AS calendar_datetime,
                rt.treatment_time,
                rt.actual_end_time,
                rt.current_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
                rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) as current_remaining_time
            FROM recursive_pat_data rt JOIN kur_data kd ON rt.current_datetime::TIME >= kd.kur_start_time  AND rt.current_datetime::TIME <= kd.kur_end_time
            WHERE rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) >= 0
    ),
    pat_dates as (
            SELECT
                DISTINCT calendar_datetime::date as calendar_date,
                kur_cd,
                pat_id,
                ctl_no,
                facility_cd
            FROM recursive_pat_data
            ORDER BY calendar_date
    ),
    treatment_schedule AS (
            SELECT
                TO_TIMESTAMP(cwt.calendar_date || ' ' || kd.kur_start_time::TEXT, 'YYYY-MM-DD HH24:MI:SS') AS calendar_datetime,
                cwt.kur_cd,
                cwt.bed_cd,
                cwt.treatment_time,
                cwt.treat_start_time,
                cwt.pat_id,
                cwt.ctl_no,
                cwt.facility_cd,
                (TO_TIMESTAMP(cwt.calendar_date || ' ' || kd.kur_start_time::TEXT, 'YYYY-MM-DD HH24:MI:SS') + INTERVAL '1 minute' * cwt.treatment_time) AS actual_end_time
            FROM calendar_with_week_type cwt JOIN pat_dates ad ON cwt.pat_id != /*patId*/NULL JOIN kur_data kd ON cwt.kur_cd = kd.kur_cd
            WHERE cwt.generation_status = 'on'
            ORDER BY cwt.calendar_date
    ),
    recursive_treatment AS (
            SELECT
                TO_CHAR(ts.calendar_datetime, 'YYYYMMDD') as calendar_date,
                ts.kur_cd,
                ts.bed_cd,
                ts.pat_id,
                ts.ctl_no,
                ts.facility_cd,
                ts.calendar_datetime,
                ts.treatment_time,
                ts.actual_end_time,
                ts.calendar_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TIME, kd.kur_standard_start_time::TIME))) / 60) + INTERVAL '1 second' as current_datetime,
                ts.treatment_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - COALESCE(ts.treat_start_time::TIME, kd.kur_standard_start_time::TIME))) / 60) AS current_remaining_time
            FROM treatment_schedule ts JOIN kur_data kd ON ts.kur_cd = kd.kur_cd
            UNION ALL
            SELECT
                TO_CHAR(rt.current_datetime, 'YYYYMMDD') as calendar_date,
                kd.kur_cd,
                rt.bed_cd,
                rt.pat_id,
                rt.ctl_no,
                rt.facility_cd,
                rt.current_datetime AS calendar_datetime,
                rt.treatment_time,
                rt.actual_end_time,
                rt.current_datetime + INTERVAL '1 minute' * (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) + INTERVAL '1 second' as current_datetime,
                rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) as current_remaining_time
            FROM recursive_treatment rt JOIN kur_data kd ON rt.current_datetime::TIME >= kd.kur_start_time  AND rt.current_datetime::TIME <= kd.kur_end_time
            WHERE  rt.current_remaining_time - (EXTRACT(EPOCH FROM (kd.kur_end_time::TIME - kd.kur_start_time::TIME)) / 60) >= 0
    ),
    USED_BED2 AS (
            SELECT DISTINCT rt.bed_cd FROM recursive_treatment rt, pat_dates pd where rt.calendar_date::date = pd.calendar_date and rt.kur_cd = pd.kur_cd
     )
SELECT DISTINCT
       ALL_BED.BED_CD
     , ALL_BED.FACILITY_CD
     , ALL_BED.FN_BED_NO
-- del #10280 ベッドマスタに不要なカラムが存在する dengshen start
--       , ALL_BED.BED_NO
-- del #10280 ベッドマスタに不要なカラムが存在する dengshen end
     , ALL_BED.BED_NAME
     , ALL_BED.SHUNT_POSITION
     , ALL_BED.IS_INFECTION
     , ALL_BED.EMERGENCY_CLASS
     , ALL_BED.MACHINE_NO
     , ALL_BED.OUTPUT_PRINTER
     , ALL_BED.IS_AUTOPRINT_BEFORE
     , ALL_BED.IS_AUTOPRINT_AFTER
     , ALL_BED.IS_AUTOPRINT_COMMIT
     , ALL_BED.IN_HOSPITAL_CD_1
     , ALL_BED.IN_HOSPITAL_CD_2
     , ALL_BED.IS_DISP
     , ALL_BED.IS_DEL
     , ALL_BED.REG_DATE
     , ALL_BED.UP_DATE
     , ALL_BED.IS_HOME_DIALYSIS
     , ALL_BED.INDEX from (
         select ALLBED.*,USED_BED.TREAT_DATE_NUM from ALL_BED ALLBED left join USED_BED on ALLBED.BED_CD=USED_BED.BED_CD
         -- mod #9331  by zhangruixue 2023-08-07 --start
--          ORDER BY ALLBED.INDEX
          -- mod #9331  by zhangruixue 2023-08-07 --end
         ) as ALL_BED
		 where 1=1
    /*%if false == isAll */
    --施設設定マスタのしきい値よりも予定件数が多いベッドを除外
    AND (TREAT_DATE_NUM  <= /*ms_max_treat*/NULL or TREAT_DATE_NUM is null)
    /*%if null == searchEndDate*/
    AND ALL_BED.BED_CD::text NOT IN ( SELECT BED_CD::text FROM USED_BED2 )
    /*%end*/
    /*%end*/
ORDER BY ALL_BED.INDEX
;
