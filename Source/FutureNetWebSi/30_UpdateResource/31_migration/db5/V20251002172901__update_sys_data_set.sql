DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1107002,-1107006,-1107055,-1107056,-1107008);
DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1107003);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107003, '{
  "collection": "ind_history",
  "eq": {
    "pat_id": "@patId",
    "facility_cd": "@facilityCd",
    "log_date": "@ordNo"
  },
  "sort": {
    "log_date": "desc"
  }
}', 4, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　指示変更履歴　カルテ記録 データ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

