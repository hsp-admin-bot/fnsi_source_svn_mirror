DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" in (1879);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1879, 'SELECT
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique 
FROM
  pat_unique 
WHERE
  pat_id = @patId 
  AND is_del = ''0''', 2, '[]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報取得JSON', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);




DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" in (1881);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1881, 'update pat_unique set
  medical_hst_info = ''[{"memo":null, "ctl_no":null, "die_date": "@dieDate", "out_come": "10", "course_cd":null, "is_notice":null, "disease_cd": @diseaseCd, "disp_order":null, "disease_day":null, "facility_cd":null, "disease_date":null, "disease_year":null, "is_diagnosed":null, "diagnosis_day":null, "disease_month":null, "out_come_date":null, "course_is_free":null, "diagnosis_date":null, "diagnosis_year":null, "diagnosis_month":null, "is_main_disease":null, "diagnostician_cd":null, "diagnosis_facility_cd":null, "diagnostician_is_free":null, "is_confirmation_biopsy":null, "diagnosis_facility_is_free":null, "is_dialysis_underlying_disease":null}]''
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_生存情報', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

