update ntss.sys_data_set set sql = 'SELECT
	info ->> ''item_cd'' AS item_cd,
	item.in_hospital_cd1 AS in_hospital_cd1,
	item.in_hospital_cd2 AS in_hospital_cd2,
	item.in_hospital_cd3 AS in_hospital_cd3,
	item.sbt_cd1 AS sbt_cd1,
	item.sbt_cd2 AS sbt_cd2,
	item.sbt_cd3 AS sbt_cd3,
	info ->> ''item_name'' AS item_name,
	info ->> ''result'' AS RESULT,
	info ->> ''unit'' AS unit,
	info ->> ''freememo'' AS freememo,
	P.result_exam_date AS result_exam_date,
	P.reg_exam_date,
	P.reg_order_class,
	info ->> ''upper'' AS UPPER,
	info ->> ''lower'' AS LOWER,
	P.pat_id AS pat_id,
	P.pat_id AS pat_name,
	p.pat_id AS pat_birthday,
	p.pat_id AS pat_age,
	p.pat_id AS pat_sex,
	p.pat_id AS in_out_class,
	p.pat_id AS pat_blood_type_abo_rh
FROM
	(
	SELECT M
		.* 
	FROM
		pat_exam_main AS M 
	WHERE
		M.is_del = ''0'' 
		AND M.exam_status = ''1'' 
		AND M.pat_id in (@patIds)
		AND M.result_exam_date BETWEEN date_trunc( ''day'', @fromDate :: TIMESTAMP ) 
		AND date_trunc( ''day'', @toDate :: TIMESTAMP ) + ''1 days - 1 milliseconds'' 
	ORDER BY
		M.result_exam_date DESC 
	)
	AS P CROSS JOIN LATERAL json_array_elements ( P.exam_result_info :: json ) info
	Inner JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' ) 
	AND ((@examItemCd
::text is not null and @examItemCd
::text  <> '''') and (item.exam_item_cd = @examItemCd
))
	AND item.facility_Cd = @facilityCd
	AND item.is_del = ''0'' 
	AND is_disp = ''1'' 
ORDER BY
	pat_id;', db_class = 2, detail = '[{"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果（集計項目用）", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "pat_id", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "氏名", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "pat_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1945/01/01", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "pat_birthday", "target_var": "@patId"}, "data_code": "pat_birthday", "data_name": "生年月日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "pat_birthday", "disp_format": "yyyy/mm/dd", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "pat_age", "target_var": "@patId"}, "data_code": "pat_age", "data_name": "年齢", "data_type": "decimal", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "pat_age", "disp_format": "0", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "男性", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "pat_sex", "target_var": "@patId"}, "data_code": "pat_sex", "data_name": "性別", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "男性", "item": "男性"}, {"code": "2", "disp": "女性", "item": "女性"}], "data_class": "検査結果（集計項目用）", "field_name": "pat_sex", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "in_out_class", "target_var": "@patId"}, "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "(不在)", "item": "(不在)"}], "data_class": "検査結果（集計項目用）", "field_name": "in_out_class", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A型 RH-", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "pat_blood_type_abo_rh", "target_var": "@patId"}, "data_code": "pat_blood_type_abo_rh", "data_name": "血液型ABORH", "data_type": "string", "conv_table": [{"code": "00", "disp": "不明", "item": "不明"}, {"code": "10", "disp": "A型 RH不明", "item": "A型 RH不明"}, {"code": "20", "disp": "B型 RH不明", "item": "B型 RH不明"}, {"code": "30", "disp": "O型 RH不明", "item": "O型 RH不明"}, {"code": "40", "disp": "AB型 RH不明", "item": "AB型 RH不明"}, {"code": "01", "disp": "不明 RH+", "item": "不明 RH+"}, {"code": "11", "disp": "A型 RH+", "item": "A型 RH+"}, {"code": "21", "disp": "B型 RH+", "item": "B型 RH+"}, {"code": "31", "disp": "O型 RH+", "item": "O型 RH+"}, {"code": "41", "disp": "AB型 RH+", "item": "AB型 RH+"}, {"code": "02", "disp": "不明 RH-", "item": "不明 RH-"}, {"code": "12", "disp": "A型 RH-+", "item": "A型 RH-"}, {"code": "22", "disp": "B型 RH-", "item": "B型 RH-"}, {"code": "32", "disp": "O型 RH-", "item": "O型 RH-"}, {"code": "42", "disp": "AB型 RH-", "item": "AB型 RH-"}], "data_class": "検査結果（集計項目用）", "field_name": "pat_blood_type_abo_rh", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', can_repeat = '1', use_application = '{"applications": [1]}', report_class = '{"classes": [1, 2, 3, 9, 10, 11]}', memo = '検査結果(指定日)複@patId @date 使用', reg_date = '2020/03/25 18:00:00', up_date = '2020/05/22', pre_sql_info = null where sql_cd = 197;

update ntss.sys_data_set set sql = 'select
hosp_pat_id,
personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
pat_birthday,
case when pat_birthday is null then null
else date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD'')))
end as pat_age,
pat_sex,
pat_blood_type_abo,
pat_blood_type_rh,
pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
pat_blood_type_serovar as pat_blood_type_serovar,
in_out_class,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''zip_cd'')) as pat_zip,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''address'')) as pat_address,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel1'')) as pat_tel1,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel2'')) as pat_tel2,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''fax'')) as pat_fax,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''e_mail'')) as pat_e_mail,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_name'')) as pat_work_name,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_tel'')) as pat_work_tel,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo1'')) as pat_memo1,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo2'')) as pat_memo2,
nationality as nationality,
severity_cd,
transport_cd,
is_die,
die_date,
die_cd,
die_cd as die_cd1
from
pat_personal_main
where
is_del = ''0''
and
pat_id = @patId', db_class = 3, detail = '[]', can_repeat = '0', use_application = '{"applications": [1]}', report_class = '{"classes": [1, 2, 3, 9, 10, 11]}', memo = '', reg_date = '2019/05/29 17:24:00', up_date = '2020/03/24 11:45:00', pre_sql_info = null where sql_cd = 198;
