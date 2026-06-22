delete from ntss.sys_data_set
where sql_cd in (-1107054);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107054, '{
  "collection": "ind_history",
  "eq": {
    "pat_id": "@patId",
    "facility_cd": "@facilityCd"
  },
  "lt": {
    "log_date": "@reg_date"
  },
  "sort": {
    "log_date": "desc"
  },
  "slice": {
    "log_date": 0
  }
}', 4, '[]'::jsonb, '0', '{"applications": [5]}'::jsonb, '{}'::jsonb, 'セコム　指示変更履歴 最新ログ取得', '2020-07-31 18:29:49.000', '2020-07-31 18:29:49.000', '[{"sql_cd": -1107006, "field_name": "reg_date", "replace_var": "reg_date"}]'::jsonb);
