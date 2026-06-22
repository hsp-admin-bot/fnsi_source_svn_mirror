DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307084;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307139;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307084, 'select
  @modelType ||
  ''_'' ||
  case when ltrim(ppm.hosp_pat_id,''0'')='''' then ''0''
  else ltrim(ppm.hosp_pat_id,''0'') end ||
  ''_'' ||
  @rstStartDate ||
	''_'' ||
  to_char(current_timestamp, ''YYYYMMDDHH24MISS_'') ||
  ''0001'' ||
  ''.xml'' as filename
from
  ntss.pat_personal_main as ppm
where
  pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'パナ処方ファイル名取得(削除オーダ)', '2025-04-09 17:44:00.125', current_timestamp, '[{"sql_cd": -307085, "field_name": "rst_start_date", "replace_var": "@rstStartDate"}, {"sql_cd": -307085, "field_name": "model_type", "replace_var": "@modelType"}]'::jsonb);

INSERT INTO ntss.sys_data_set (sql_cd, "sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (-307139, 'select
  @modelType ||
  ''_'' ||
  case when ltrim(ppm.hosp_pat_id,''0'')='''' then ''0''
  else ltrim(ppm.hosp_pat_id,''0'') end ||
  ''_'' ||
  @rstStartDate ||
	''_'' ||
  to_char(current_timestamp, ''YYYYMMDDHH24MISS_'') ||
  ''0001'' ||
  ''.xml'' as filename
from
  ntss.pat_personal_main as ppm
where
  pat_id = @patId',3,'[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 新規/更新 ファイル名取得用','2025-04-28 10:20:23.473',current_timestamp,'[{"sql_cd": -307140, "field_name": "rst_start_date", "replace_var": "@rstStartDate"}, {"sql_cd": -307140, "field_name": "model_type", "replace_var": "@modelType"}]'::jsonb);
