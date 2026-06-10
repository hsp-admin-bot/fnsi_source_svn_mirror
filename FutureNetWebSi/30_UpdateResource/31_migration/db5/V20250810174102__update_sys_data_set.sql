DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1107008;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107008, 'UPDATE ntss.ord_coop_no
SET  status=''1''
WHERE 
  facility_cd = @facilityCd
  AND pat_id = @patId
  AND ord_no = @ordNo
  AND coop_cd = @coopCd
  AND is_disp = ''1''
  AND is_del = ''0''
  AND coop_version = @coopVersion', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, 'セコム　指示変更履歴　スキップじのord_coop_no更新処理', '2025-08-10 12:59:50.555', '2025-08-10 12:59:59.283', NULL);