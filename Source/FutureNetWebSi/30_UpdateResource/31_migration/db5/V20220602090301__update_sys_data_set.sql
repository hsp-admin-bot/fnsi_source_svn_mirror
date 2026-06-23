DELETE FROM ntss.sys_data_set WHERE sql_cd = 7202;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7202, 'UPDATE pat_main 
SET charge_staff_info =
CASE
    ''@chargeStaffInfoFlg'' 
    WHEN '''' THEN
    ''@chargeStaffInfoValue'' ELSE charge_staff_info || ''[{"ctl_no":"@nextCtlNo2", "disp_order":"@chargeStaffInfo.dispOrder", "staff_cd":@chargeStaffInfo.staffCd, "is_main":"@chargeStaffInfo.isMain", "is_charge":"@chargeStaffInfo.isCharge", "is_puncture":"@chargeStaffInfo.isPuncture"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(担当スタッフ情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
