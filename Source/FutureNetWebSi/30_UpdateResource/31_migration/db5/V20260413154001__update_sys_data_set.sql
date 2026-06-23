DELETE FROM "ntss"."sys_data_set" where sql_cd in (59);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (59, 'select
  CASE WHEN p.count > 0 THEN ''1'' ELSE ''0'' END as has_plan
from(
  select
    count(m.*) as count
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
      and m.pat_id = @patId
    and m.reg_rad_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    ) p
;', 2, '[{"preview": "〇", "can_calc": "0", "data_code": "has_plan", "data_name": "予定有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "予定無し(変換不可)"}, {"code": "1", "disp": "〇", "item": "予定有り"}], "data_class": "一般撮影検査予定(指定日)", "field_name": "has_plan", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '一般撮影検査予定(指定日)：予定有無 @patId @date 使用', '2020-03-26 22:00:00', CURRENT_TIMESTAMP, NULL);
