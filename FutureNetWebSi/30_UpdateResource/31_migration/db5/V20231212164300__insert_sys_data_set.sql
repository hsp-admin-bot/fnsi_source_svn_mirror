DELETE FROM ntss.sys_data_set
WHERE sql_cd = -603103
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603103, 'WITH in_out_info AS (
SELECT array_to_json(ARRAY_AGG(json_build_object(
    ''ctl_no'', 1,
    ''in_out'', ''@inOutClass'',
    ''reason'', null,
    ''to_course'', null,
    ''to_doctor'', null,
    ''disp_order'', 0,
    ''period_end'', null,
    ''facility_cd'', NULLIF(''@facilityCd'', ''''),
    ''from_course'', null,
    ''from_doctor'', null,
    ''move_in_out'', (CASE ''@inOutClass'' WHEN ''1'' THEN ''4'' ELSE ''6'' END) :: TEXT,
    ''to_facility'', null,
    ''period_start'', to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''),
    ''from_facility'', null,
    ''course_is_free'', ''0'',
    ''doctor_is_free'', ''0'',
    ''period_end_day'', null,
    ''period_end_year'', null,
    ''facility_is_free'', ''0'',
    ''period_end_month'', null,
    ''period_start_day'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 7, 2),
    ''period_start_date'', to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''),
    ''period_start_year'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 1, 4),
    ''period_start_month'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 5, 2),
    ''period_end_input_free'', ''0'',
    ''period_start_input_free'', ''0'',
    ''to_medicalInstitutionCd'', null,
    ''from_medicalInstitutionCd'', null
    ))) AS in_out_info_json
)

INSERT 
INTO pat_unique( 
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique
) 
VALUES ( 
  @patId
  , ''[]''
  , (SELECT in_out_info_json FROM in_out_info)
  , ''[]''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''@facilityCd''
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)MIRAISの患者プロファイル_固有情報登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
