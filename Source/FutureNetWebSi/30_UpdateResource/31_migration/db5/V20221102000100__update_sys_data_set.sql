DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (20);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (
20
,'{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_charge_staff_info_asc}'
,4
,'[{"preview":"123456789","can_calc":"0","conv_sql":{"sql_cd":-66,"field_name":"disp_user_id","target_var":"@userId"},"data_code":"doctor1_cd","data_name":"担当医1ID","data_type":"string","conv_table":[],"data_class":"既往歴","field_name":"doctor1_cd","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"テスト医師1","can_calc":"0","conv_sql":{"sql_cd":-2,"field_name":"user_name","target_var":"@userId"},"data_code":"doctor1_name","data_name":"担当医1","data_type":"string","conv_table":[],"data_class":"既往歴","field_name":"doctor1_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"123456789","can_calc":"0","conv_sql":{"sql_cd":-66,"field_name":"disp_user_id","target_var":"@userId"},"data_code":"doctor2_cd","data_name":"担当医2ID","data_type":"string","conv_table":[],"data_class":"既往歴","field_name":"doctor2_cd","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"テスト医師2","can_calc":"0","conv_sql":{"sql_cd":-2,"field_name":"user_name","target_var":"@userId"},"data_code":"doctor2_name","data_name":"担当医2","data_type":"string","conv_table":[],"data_class":"既往歴","field_name":"doctor2_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"123456789","can_calc":"0","conv_sql":{"sql_cd":-66,"field_name":"disp_user_id","target_var":"@userId"},"data_code":"staff1_cd","data_name":"担当スタッフ1ID","data_type":"string","conv_table":[],"data_class":"既往歴","field_name":"staff1_cd","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"テスト看護師","can_calc":"0","conv_sql":{"sql_cd":-2,"field_name":"user_name","target_var":"@userId"},"data_code":"staff1_name","data_name":"担当スタッフ1","data_type":"string","conv_table":[],"data_class":"既往歴","field_name":"staff1_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"123456789","can_calc":"0","conv_sql":{"sql_cd":-66,"field_name":"disp_user_id","target_var":"@userId"},"data_code":"staff2_cd","data_name":"担当スタッフ2ID","data_type":"string","conv_table":[],"data_class":"既往歴","field_name":"staff2_cd","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"テスト技士","can_calc":"0","conv_sql":{"sql_cd":-2,"field_name":"user_name","target_var":"@userId"},"data_code":"staff2_name","data_name":"担当スタッフ2","data_type":"string","conv_table":[],"data_class":"既往歴","field_name":"staff2_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"}]',
'0'
,'{"applications": [1]}'
,'{"classes": [1, 2, 3, 9, 10, 11]}'
,'患者情報：担当・スタッフ　@patId使用'
,'2020-03-25 10:30:00'
, CURRENT_TIMESTAMP
,NULL
);
DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (40);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (
40
,'{"collection": "pat_personal_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_other_contact_info}'
,4
,'[{"preview":"キーパーソン","can_calc":"0","data_code":"is_key_person","data_name":"キーパーソン","data_type":"string","conv_table":[{"code":"0","disp":"■","item":"非キーパーソン"},{"code":"1","disp":"□","item":"キーパーソン"}],"data_class":"緊急連絡先","field_name":"is_key_parson","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"ニッキソウ　ジロウ","can_calc":"0","data_code":"other_name_kana","data_name":"氏名フリガナ","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"other_name_kana","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"日機装　次郎","can_calc":"0","data_code":"other_name","data_name":"氏名","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"other_name","disp_format":"","data_category":"患者情報","-facility_table":"","facility_filter_type":"0"},{"preview":"弟","can_calc":"0","data_code":"relation_name","data_name":"続柄","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"relation_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"150-8677","can_calc":"0","data_code":"zip_cd","data_name":"郵便番号","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"zip_cd","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"東京都渋谷区恵比寿2-27-10 日機装第２別館","can_calc":"0","data_code":"address","data_name":"住所・番地・マンション","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"address","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"03-9876-5432","can_calc":"0","data_code":"tel1","data_name":"電話番号1","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"tel1","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"080-9876-5432","can_calc":"0","data_code":"tel2","data_name":"電話番号2","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"tel2","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"03-8765-4321","can_calc":"0","data_code":"fax","data_name":"Fax番号","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"fax","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"xxxxxx@xxxx.xx.xx","can_calc":"0","data_code":"e_mail","data_name":"メール","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"e_mail","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"日機装","can_calc":"0","data_code":"work_name","data_name":"勤務先名","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"work_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"03-5678-1234","can_calc":"0","data_code":"work_tel","data_name":"勤務先電話番号","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"work_tel","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"緊急連絡先メモ１です。","can_calc":"0","data_code":"memo1","data_name":"緊急連絡先メモ1","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"memo1","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"緊急連絡先メモ２です。","can_calc":"0","data_code":"memo2","data_name":"緊急連絡先メモ2","data_type":"string","conv_table":[],"data_class":"緊急連絡先","field_name":"memo2","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"}]',
'1'
,'{"applications": [1]}'
,'{"classes": [1, 2, 3, 9, 10, 11]}'
,'患者情報：緊急連絡先　@patId使用'
,'2020-03-26 01:32:00'
, CURRENT_TIMESTAMP
,NULL
);
DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (43);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (
43
,'WITH pat_in_out_visit_history_tbl AS (
SELECT
	to_number ( info ->> ''ctl_no'', ''99999'' ) AS ctl_no,
	to_number ( info ->> ''disp_order'', ''99999'' ) AS disp_order,
	info ->> ''facility_cd'' AS facility_cd,
	info ->> ''move_in_out'' AS move_in_out,
	info ->> ''period_start'' AS period_start,
	info ->> ''period_end'' period_end,
	info ->> ''in_out'' AS in_out,
	info ->> ''reason'' AS reason,
	info ->> ''from_facility'' AS from_facility,
	info ->> ''from_course'' AS from_course,
	info ->> ''from_doctor'' AS from_doctor,
	info ->> ''to_facility'' AS to_facility,
	info ->> ''to_course'' AS to_course,
	info ->> ''to_doctor'' AS to_doctor,
	info ->> ''is_reply'' AS is_reply,
	info ->> ''comment'' AS COMMENT 
FROM
	pat_unique
	CROSS JOIN lateral json_array_elements ( pat_unique.in_out_visit_history_info :: json ) info 
WHERE
	pat_id = @patId 
	AND is_del = ''0'' 
	) SELECT
	to_date ( pat_in_out_visit_history_tbl.period_start, ''YYYYMMDD'' ) AS period_start,
	pat_in_out_visit_history_tbl.ctl_no,
	pat_in_out_visit_history_tbl.disp_order,
	pat_in_out_visit_history_tbl.facility_cd,
	pat_in_out_visit_history_tbl.move_in_out,
	to_date ( pat_in_out_visit_history_tbl.period_end, ''YYYYMMDD'' ) AS period_end,
	pat_in_out_visit_history_tbl.in_out,
	pat_in_out_visit_history_tbl.reason,
	pat_in_out_visit_history_tbl.from_facility,
	pat_in_out_visit_history_tbl.from_course,
	pat_in_out_visit_history_tbl.from_doctor,
	pat_in_out_visit_history_tbl.to_facility,
	pat_in_out_visit_history_tbl.to_course,
	pat_in_out_visit_history_tbl.to_doctor,
	pat_in_out_visit_history_tbl.is_reply,
	pat_in_out_visit_history_tbl.COMMENT,
CASE
	
	WHEN from_facility_tbl.facility_name IS NULL THEN
		CASE WHEN from_sys_facility_tbl.facility_name IS NOT NULL THEN
		from_sys_facility_tbl.facility_name 
		END
	ELSE from_facility_tbl.facility_name  
	END AS from_facility_name,
CASE
		
		WHEN from_course_tbl.course_name IS NULL THEN
		pat_in_out_visit_history_tbl.from_course ELSE from_course_tbl.course_name 
	END AS from_course_name,
CASE 
	WHEN pat_in_out_visit_history_tbl.move_in_out = ''7''
	OR pat_in_out_visit_history_tbl.move_in_out = ''8''
	OR pat_in_out_visit_history_tbl.move_in_out = ''10''
	THEN NULL
ELSE	
CASE
		
		WHEN to_facility_tbl.facility_name IS NULL THEN
			CASE WHEN to_sys_facility_tbl.facility_name IS NOT NULL THEN
			to_sys_facility_tbl.facility_name 
			ELSE
				CASE WHEN from_sys_facility_tbl.facility_name IS NULL THEN
				from_facility_tbl.facility_name
				ELSE from_sys_facility_tbl.facility_name
				END
			END 
		ELSE to_facility_tbl.facility_name
		END 
	END AS to_facility_name,
	
	CASE
		
		WHEN facility_cd_tbl.facility_name IS NULL THEN
		pat_in_out_visit_history_tbl.facility_cd ELSE facility_cd_tbl.facility_name 
	END AS facility_cd_name,
	
CASE 
	WHEN pat_in_out_visit_history_tbl.move_in_out = ''7''
	OR pat_in_out_visit_history_tbl.move_in_out = ''8''
	OR pat_in_out_visit_history_tbl.move_in_out = ''10''
	THEN NULL
ELSE	
CASE
		
		WHEN to_course_tbl.course_name IS NULL THEN
			CASE WHEN from_course_tbl.course_name IS NOT NULL THEN
			from_course_tbl.course_name 
			END 
		ELSE to_course_tbl.course_name 
		END
	END AS to_course_name 
FROM
	pat_in_out_visit_history_tbl
	LEFT JOIN mst_facility AS from_facility_tbl ON pat_in_out_visit_history_tbl.from_facility = from_facility_tbl.facility_cd
	LEFT JOIN mst_course AS from_course_tbl ON pat_in_out_visit_history_tbl.from_course = from_course_tbl.course_cd :: text 
	AND from_course_tbl.is_disp = ''1'' 
	AND from_course_tbl.is_del = ''0''
	LEFT JOIN mst_facility AS to_facility_tbl ON pat_in_out_visit_history_tbl.to_facility = to_facility_tbl.facility_cd
	LEFT JOIN mst_course AS to_course_tbl ON pat_in_out_visit_history_tbl.to_course = to_course_tbl.course_cd :: text 
	AND to_course_tbl.is_disp = ''1'' 
	AND to_course_tbl.is_del = ''0''
	LEFT JOIN mst_facility AS facility_cd_tbl ON pat_in_out_visit_history_tbl.facility_cd = facility_cd_tbl.facility_cd 
	LEFT JOIN sys_facility AS from_sys_facility_tbl ON pat_in_out_visit_history_tbl.from_facility = from_sys_facility_tbl.medical_institution_cd
	LEFT JOIN sys_facility AS to_sys_facility_tbl ON pat_in_out_visit_history_tbl.to_facility = to_sys_facility_tbl.medical_institution_cd
ORDER BY
	disp_order,
ctl_no
'
,2
,'[{"preview":"2011/04/21","can_calc":"0","data_code":"period_start","data_name":"発生日","data_type":"DateTime","conv_table":[],"data_class":"転入・転出","field_name":"period_start","disp_format":"yyyy/mm/dd","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"2011/04/21","can_calc":"0","data_code":"period_end","data_name":"転入出期間(終了)","data_type":"DateTime","conv_table":[],"data_class":"転入・転出","field_name":"period_end","disp_format":"yyyy/mm/dd","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"","can_calc":"0","data_code":"facility_cd_name","data_name":"登録施設コード","data_type":"DateTime","conv_table":[],"data_class":"転入・転出","field_name":"facility_cd_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"転出","can_calc":"0","data_code":"move_in_out","data_name":"区分","data_type":"string","conv_table":[{"code":"1","disp":"導入","item":"導入"},{"code":"2","disp":"転入","item":"転入"},{"code":"3","disp":"転出","item":"転出"},{"code":"4","disp":"入院","item":"入院"},{"code":"5","disp":"退院","item":"退院"},{"code":"6","disp":"外来","item":"外来"},{"code":"7","disp":"離脱","item":"離脱"},{"code":"8","disp":"移植","item":"移植"},{"code":"9","disp":"一時転出","item":"一時転出"},{"code":"10","disp":"通院拒否・不明","item":"通院拒否・不明"}],"data_class":"転入・転出","field_name":"move_in_out","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"入院","can_calc":"0","data_code":"in_out","data_name":"入外区分","data_type":"string","conv_table":[{"code":"0","disp":"外来","item":"外来"},{"code":"1","disp":"入院","item":"入院"},{"code":"2","disp":"死亡","item":"死亡"},{"code":"3","disp":"－(不在)","item":"－(不在)"}],"data_class":"転入・転出","field_name":"in_out","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"日機装第二クリニック","can_calc":"0","data_code":"from_facility_name","data_name":"転入元施設名","data_type":"string","conv_table":[],"data_class":"転入・転出","field_name":"from_facility_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"第二透析科","can_calc":"0","data_code":"from_course_name","data_name":"転入元科","data_type":"string","conv_table":[],"data_class":"転入・転出","field_name":"from_course_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"テスト医師１","can_calc":"0","conv_sql":{"sql_cd":-2,"field_name":"user_name","target_var":"@userId"},"data_code":"from_doctor","data_name":"転入元医師","data_type":"string","conv_table":[],"data_class":"転入・転出","field_name":"from_doctor","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"日機装第一クリニック","can_calc":"0","data_code":"to_facility_name","data_name":"転出先施設名","data_type":"string","conv_table":[],"data_class":"転入・転出","field_name":"to_facility_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"第一透析科","can_calc":"0","data_code":"to_course_name","data_name":"転出先科","data_type":"string","conv_table":[],"data_class":"転入・転出","field_name":"to_course_name","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"テスト医師２","can_calc":"0","conv_sql":{"sql_cd":-2,"field_name":"user_name","target_var":"@userId"},"data_code":"to_doctor","data_name":"転出先医師","data_type":"string","conv_table":[],"data_class":"転入・転出","field_name":"to_doctor","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"},{"preview":"転入・転出コメントです。","can_calc":"0","data_code":"reason","data_name":"コメント","data_type":"string","conv_table":[],"data_class":"転入・転出","field_name":"reason","disp_format":"","data_category":"患者情報","facility_table":"","facility_filter_type":"0"}]',
'1'
,'{"applications": [1]}'
,'{"classes": [1, 2, 3, 9, 10, 11]}'
,'患者情報：転入・転出　@patId'
,'2020-03-26 14:18:00'
, CURRENT_TIMESTAMP
,NULL
);