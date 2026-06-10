DELETE FROM sys_data_set WHERE sql_cd = 1705;

INSERT INTO ntss.sys_data_set (sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (1705,'WITH in_out_class AS (SELECT (CASE
                                  WHEN ''@inOutClass'' = ''1''
                                      THEN ''1''
                                  ELSE ''0''
    END) AS in_out)
    ,ctl_no_calc AS (
    SELECT
        COUNT(1) + 1 AS ctl_no
    FROM 
        pat_unique 
        CROSS JOIN jsonb_array_elements(pat_unique.in_out_visit_history_info) AS data_calc
    WHERE 
        pat_unique.pat_id = @patId
        AND facility_cd = ''@facilityCd''
        AND is_del = ''0''
    GROUP BY pat_unique.pat_id
	)
   , 
   data_new_info AS (SELECT 
   							COALESCE(ctl_no,1)                                                       AS ctl_no,
                              in_out                                                                 AS in_out,
                              null                                                                   AS reason,
                              null                                                                   AS to_course,
                              null                                                                   AS to_doctor,
                              0                                                                      AS disp_order,
                              null                                                                   AS period_end,
                              ''@facilityCd''                                                          AS facility_cd,
                              null                                                                   AS from_course,
                              null                                                                   AS from_doctor,
                              (CASE in_out WHEN ''0'' THEN ''6'' WHEN ''1'' THEN ''4'' ELSE ''6'' END) :: TEXT AS move_in_out,
                              null                                                                   AS to_facility,
                              to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'')                                 AS period_start,
                              null                                                                   AS from_facility,
                              ''0''                                                                    AS course_is_free,
                              ''0''                                                                    AS doctor_is_free,
                              null                                                                   AS period_end_day,
                              null                                                                   AS period_end_year,
                              ''0''                                                                    AS facility_is_free,
                              null                                                                   AS period_end_month,
                              SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 7, 2)                   AS period_start_day,
                              to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'')                                 AS period_start_date,
                              SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 1, 4)                   AS period_start_year,
                              SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 5, 2)                   AS period_start_month,
                              ''0''                                                                    AS period_end_input_free,
                              ''0''                                                                    AS period_start_input_free,
                              null                                                                   AS to_medicalInstitutionCd,
                              null                                                                   AS from_medicalInstitutionCd
                       from in_out_class
                       left join ctl_no_calc on true)
--                       )
   , data_exists_info AS (SELECT 1   AS order_no
                               , ''1'' AS exists_flag
                          FROM in_out_class ioc
                          WHERE ''@ppmInOutClass'' = ioc.in_out
                          UNION
                          SELECT 2   AS order_no
                               , ''0'' AS exists_flag
                          ORDER BY order_no
                          LIMIT 1)
   , json_data AS (SELECT jsonb_build_object(
                                  ''ctl_no'', ctl_no,
                                  ''in_out'', in_out::integer,
                                  ''reason'', reason,
                                  ''to_course'', to_course,
                                  ''to_doctor'', to_doctor,
                                  ''disp_order'', disp_order,
                                  ''period_end'', period_end,
                                  ''facility_cd'', facility_cd,
                                  ''from_course'', from_course,
                                  ''from_doctor'', from_doctor,
                                  ''move_in_out'', move_in_out,
                                  ''to_facility'', to_facility,
                                  ''period_start'', period_start,
                                  ''from_facility'', from_facility,
                                  ''course_is_free'', course_is_free,
                                  ''doctor_is_free'', doctor_is_free,
                                  ''period_end_day'', period_end_day,
                                  ''period_end_year'', period_end_year,
                                  ''facility_is_free'', facility_is_free,
                                  ''period_end_month'', period_end_month,
                                  ''period_start_day'', period_start_day,
                                  ''period_start_date'', period_start_date,
                                  ''period_start_year'', period_start_year,
                                  ''period_start_month'', period_start_month,
                                  ''period_end_input_free'', period_end_input_free,
                                  ''period_start_input_free'', period_start_input_free,
                                  ''to_medicalInstitutionCd'', to_medicalInstitutionCd,
                                  ''from_medicalInstitutionCd'', from_medicalInstitutionCd) AS new_data
                   FROM data_new_info)
UPDATE pat_unique
SET in_out_visit_history_info = in_out_visit_history_info || new_data
  , up_date                   = CURRENT_TIMESTAMP
from json_data,
     data_exists_info
WHERE pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND ''@isDie'' <> ''1''
  AND ''@inOutClass'' <> ''''
  AND (exists_flag = ''0'' OR in_out_visit_history_info IS NULL OR in_out_visit_history_info = ''[]'');',2,'[{}]','0','{"applications": [4]}',NULL,'(受信用)富士通、日機装標準(xml)、CSIの患者プロファイル_固有情報_入外・転入出情報(死亡以外)','2020-05-25 18:21:40.841',CURRENT_TIMESTAMP,'[{"sql_cd": -100001, "field_name": "in_out_class", "replace_var": "@ppmInOutClass"}]');
