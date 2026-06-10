DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-2,-3,-4,-5,-6);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2, 'SELECT
	1 AS OrderNo,
	personal_info_decrypt(user_last_name)       || '' '' || personal_info_decrypt(user_first_name) as user_name,
  personal_info_decrypt(user_last_name_kana)  || '' '' || personal_info_decrypt(user_first_name_kana) as user_name_kana,
  personal_info_decrypt(user_last_name_alpha) || '' '' || personal_info_decrypt(user_first_name_alpha) as user_name_alpha 
FROM
	mst_personal_user 
WHERE
	user_id = TO_NUMBER( CASE WHEN ( @userId ~ ''^([0-9]+[.]?[0-9]*|[.][0-9]+)$'' ) = TRUE THEN @userId ELSE''-1'' END, ''FM9999999'' ) 
	AND is_disp = ''1'' 
	AND is_del = ''0'' 
UNION
SELECT
	2 AS OrderNo,
	@userId AS user_name ,
	''''as user_name_kana,
	''''as user_name_alpha
ORDER BY
	OrderNo ASC 
	LIMIT 1', 3, '[]', '0', '{"applications": []}', '{"classes": []}', 'スタッフ名取得用　@userId使用', '2020-03-31 14:39:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-3, 'select
  *

from
  mst_dialysis_difficulty
where
  dialysis_difficulty_cd = @dialysisDifficultyCd
and
  is_disp = ''1''
and
  is_del = ''0''
', 2, '[]', '0', '{"applications": []}', '{"classes": []}', '透析困難理由取得用　@dialysisDifficultyCd使用', '2020-03-31 14:47:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-6, 'select
  *

from
  mst_disease
where
  disease_cd = @diseaseCd
and
  is_disp = ''1''
and
  is_del = ''0''
', 2, '[]', '0', '{"applications": []}', '{"classes": []}', '病名(死因)取得用　@diseaseCd', '2020-03-31 14:58:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-4, 'select
  *

from
  mst_severity
where
  severity_cd = @severityCd
and
  is_disp = ''1''
and
  is_del = ''0''
', 2, '[]', '0', '{"applications": []}', '{"classes": []}', '重症度取得用　@severityCd使用', '2020-03-31 14:48:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-5, 'select
  *

from
  mst_transport
where
  transport_cd = @transportCd
and
  is_disp = ''1''
and
  is_del = ''0''
', 2, '[]', '0', '{"applications": []}', '{"classes": []}', '搬送区分名取得用　@transportCd使用', '2020-03-31 14:50:00', CURRENT_TIMESTAMP, NULL);
