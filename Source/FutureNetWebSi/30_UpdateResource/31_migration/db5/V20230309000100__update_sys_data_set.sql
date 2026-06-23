DELETE FROM  "ntss"."sys_data_set" where sql_cd=1904;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1904, 'UPDATE pat_coop_detail 
SET
  is_del = ''1'' ,
	up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd'' 
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND coop_version = ''@coopVersion''
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND pat_id = @patId
  AND is_del = ''0''
  AND save_2->>''ord_no''::TEXT = ''@save2.ordNo''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者連携情報削除(論理:削除フラグ=''1'')', '2022-01-07 18:21:46',CURRENT_TIMESTAMP , NULL);


