INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (159, '
   select
    pat_id
    , 
    hosp_pat_id
    , ntss.personal_info_decrypt(pat_last_name)||ntss.personal_info_decrypt(pat_first_name) as pat_name
    , ntss.personal_info_decrypt(pat_last_name_kana)||ntss.personal_info_decrypt(pat_first_name_kana) as pat_name_kana
from
    ntss.pat_personal_main
where
    is_del = ''0''
and
    pat_id  IN (@patIds)
order by pat_id
  ', 3, '[{"preview": "123456789012", "can_calc": "0", "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "患者情報", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "data_code": "pat_name", "data_name": "氏名", "data_type": "string", "conv_table": [], "data_class": "患者情報", "field_name": "pat_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストカンジャ１", "can_calc": "0", "data_code": "pat_name_kana", "data_name": "カナ氏名", "data_type": "string", "conv_table": [], "data_class": "患者情報", "field_name": "pat_name_kana", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "pat_id", "field_name": "pat_id"}]', '0', '{"applications": [1]}', '{"classes": [8]}', 'ラベル', '2020-03-17 14:17:00', '2021-05-13 19:34:54', NULL);
