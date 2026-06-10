DELETE
FROM
  ntss.sys_data_set sds
WHERE
  sql_cd = '217';

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(217, 'SELECT
	hosp_pat_id,
	personal_info_decrypt ( pat_last_name ) || '' '' || personal_info_decrypt ( pat_first_name ) AS pat_name,
	personal_info_decrypt ( pat_last_name_kana ) || '' '' || personal_info_decrypt ( pat_first_name_kana ) AS pat_name_kana,
	personal_info_decrypt ( pat_last_name_alpha ) || '' '' || personal_info_decrypt ( pat_first_name_alpha ) AS pat_name_alpha,
	TO_CHAR(TO_DATE(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
CASE
		
		WHEN pat_birthday IS NULL THEN
		NULL ELSE date_part( ''year'', age( ''now'', to_date( pat_birthday, ''YYYYMMDD'' ) ) ) 
	END AS pat_age,
CASE pat_sex
		WHEN 1 THEN
		''男性'' 
		WHEN 2 THEN
		''女性'' ELSE''不明'' 
	END AS pat_sex,
CASE
		pat_blood_type_abo 
		WHEN 0 THEN
		''不明'' 
		WHEN 1 THEN
		''A型'' 
		WHEN 2 THEN
		''B型'' 
		WHEN 3 THEN
		''O型'' 
        WHEN 4 THEN
        ''AB型''
	ELSE''不明'' 
	END AS pat_blood_type_abo,
	CASE
		pat_blood_type_rh 
		WHEN 0 THEN
		''不明'' 
		WHEN 1 THEN
		''Rh+'' 
	ELSE''Rh-'' 
	END AS pat_blood_type_rh,
	CASE
		pat_blood_type_abo * 10 + pat_blood_type_rh
		WHEN 0 THEN
		''不明'' 
		WHEN 10 THEN
		''A型 RH不明'' 
		WHEN 20 THEN
		''B型 RH不明'' 
		WHEN 30 THEN
		''O型 RH不明'' 
		WHEN 40 THEN
		''AB型 RH不明'' 
		WHEN 1 THEN
		''不明 Rh+'' 
		WHEN 11 THEN
		''A型 Rh+'' 
		WHEN 21 THEN
		''B型 Rh+'' 
		WHEN 31 THEN
		''O型 Rh+''
		WHEN 41 THEN
		''AB型 Rh+'' 
		WHEN 2 THEN
		''不明 Rh-'' 
		WHEN 12 THEN
		''A型 Rh-'' 
		WHEN 22 THEN
		''B型 Rh-''
		WHEN 32 THEN
		''O型 Rh-''
	ELSE''AB型 Rh-'' 
	END AS pat_blood_type_abo_rh,
	CASE
		in_out_class 
		WHEN 0 THEN
		''外来'' 
		WHEN 1 THEN
		''入院'' 
		WHEN 2 THEN
		''死亡''  
	ELSE''(不在)'' 
	END AS in_out_class,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''zip_cd'' ) ) AS pat_zip,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''address'' ) ) AS pat_address,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''tel1'' ) ) AS pat_tel1,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''tel2'' ) ) AS pat_tel2,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''fax'' ) ) AS pat_fax,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''e_mail'' ) ) AS pat_e_mail,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''work_name'' ) ) AS pat_work_name,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''work_tel'' ) ) AS pat_work_tel,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''memo1'' ) ) AS pat_memo1,
	TRIM ( BOTH ''"'' FROM personal_info_decrypt ( pat_contact_info ->> ''memo2'' ) ) AS pat_memo2,
	severity_cd,
	transport_cd,
	CASE when
		is_die = ''0''  THEN
		''存命'' 
	ELSE''死亡'' 
	END AS is_die,
	TO_CHAR(die_date, ''YYYY/MM/DD'') as die_date,
	die_cd as in_hospital_cd_1,
	die_cd as die_name 
FROM
	pat_personal_main 
WHERE
	is_del = ''0'' 
	AND pat_id = @patId', 3, '[{"preview": "123456789012", "can_calc": "0", "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ニッキソウ　タロウ", "can_calc": "0", "data_code": "pat_name_kana", "data_name": "氏名フリガナ", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_name_kana", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "nikkiso　tarou", "can_calc": "0", "data_code": "pat_name_alpha", "data_name": "ローマ字", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_name_alpha", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "data_code": "pat_name", "data_name": "氏名", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1945/01/01", "can_calc": "0", "data_code": "pat_birthday", "data_name": "生年月日", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_birthday", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "data_code": "pat_age", "data_name": "年齢", "data_type": "decimal", "conv_table": [], "data_class": "基本情報", "field_name": "pat_age", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "男性", "can_calc": "0", "data_code": "pat_sex", "data_name": "性別", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "男性", "item": "男性"}, {"code": "2", "disp": "女性", "item": "女性"}], "data_class": "基本情報", "field_name": "pat_sex", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "(不在)", "item": "(不在)"}], "data_class": "基本情報", "field_name": "in_out_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "AB", "can_calc": "0", "data_code": "pat_blood_type_abo", "data_name": "血液型ABO", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "A型", "item": "A型"}, {"code": "2", "disp": "B型", "item": "B型"}, {"code": "3", "disp": "O型", "item": "O型"}, {"code": "4", "disp": "AB型", "item": "AB型"}], "data_class": "基本情報", "field_name": "pat_blood_type_abo", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "RH+", "can_calc": "0", "data_code": "pat_blood_type_rh", "data_name": "血液型RH", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "RH+", "item": "RH+"}, {"code": "2", "disp": "RH-", "item": "RH-"}], "data_class": "基本情報", "field_name": "pat_blood_type_rh", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A型 RH-", "can_calc": "0", "data_code": "pat_blood_type_abo_rh", "data_name": "血液型ABORH", "data_type": "string", "conv_table": [{"code": "00", "disp": "不明", "item": "不明"}, {"code": "10", "disp": "A型 RH不明", "item": "A型 RH不明"}, {"code": "20", "disp": "B型 RH不明", "item": "B型 RH不明"}, {"code": "30", "disp": "O型 RH不明", "item": "O型 RH不明"}, {"code": "40", "disp": "AB型 RH不明", "item": "AB型 RH不明"}, {"code": "01", "disp": "不明 RH+", "item": "不明 RH+"}, {"code": "11", "disp": "A型 RH+", "item": "A型 RH+"}, {"code": "21", "disp": "B型 RH+", "item": "B型 RH+"}, {"code": "31", "disp": "O型 RH+", "item": "O型 RH+"}, {"code": "41", "disp": "AB型 RH+", "item": "AB型 RH+"}, {"code": "02", "disp": "不明 RH-", "item": "不明 RH-"}, {"code": "12", "disp": "A型 RH-+", "item": "A型 RH-"}, {"code": "22", "disp": "B型 RH-", "item": "B型 RH-"}, {"code": "32", "disp": "O型 RH-", "item": "O型 RH-"}, {"code": "42", "disp": "AB型 RH-", "item": "AB型 RH-"}], "data_class": "基本情報", "field_name": "pat_blood_type_abo_rh", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者メモ1です。", "can_calc": "0", "data_code": "pat_memo1", "data_name": "患者メモ1", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "pat_memo1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者メモ2です。", "can_calc": "0", "data_code": "pat_memo2", "data_name": "患者メモ2", "data_type": "string", "conv_table": [], "data_class": "患者メモ", "field_name": "pat_memo2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150-8677", "can_calc": "0", "data_code": "pat_zip", "data_name": "郵便番号", "data_type": "string", "conv_table": [], "data_class": "本人連絡先", "field_name": "pat_zip", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "東京都渋谷区恵比寿3-43-2 日機装第１別館１F", "can_calc": "0", "data_code": "pat_address", "data_name": "住所・番地・マンション", "data_type": "string", "conv_table": [], "data_class": "本人連絡先", "field_name": "pat_address", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-1234-5678", "can_calc": "0", "data_code": "pat_tel1", "data_name": "電話番号1", "data_type": "string", "conv_table": [], "data_class": "本人連絡先", "field_name": "pat_tel1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "090-1234-5678", "can_calc": "0", "data_code": "pat_tel2", "data_name": "電話番号2", "data_type": "string", "conv_table": [], "data_class": "本人連絡先", "field_name": "pat_tel2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-8765-4321", "can_calc": "0", "data_code": "pat_fax", "data_name": "Fax番号", "data_type": "string", "conv_table": [], "data_class": "本人連絡先", "field_name": "pat_fax", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mailto:xxxxxx@xxxx.xx.xx", "can_calc": "0", "data_code": "pat_e_mail", "data_name": "メール", "data_type": "string", "conv_table": [], "data_class": "本人連絡先", "field_name": "pat_e_mail", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "pat_work_name", "data_name": "勤務先名", "data_type": "string", "conv_table": [], "data_class": "本人連絡先", "field_name": "pat_work_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-5678-1234", "can_calc": "0", "data_code": "pat_work_tel", "data_name": "勤務先電話番号", "data_type": "string", "conv_table": [], "data_class": "本人連絡先", "field_name": "pat_work_tel", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期（部分介助）", "can_calc": "0", "conv_sql": {"sql_cd": -4, "field_name": "severity_name", "target_var": "@severityCd"}, "data_code": "severity_cd", "data_name": "重症度", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "severity_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子", "can_calc": "0", "conv_sql": {"sql_cd": -5, "field_name": "transport_name", "target_var": "@transportCd"}, "data_code": "transport_cd", "data_name": "搬送区分名", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "transport_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "死亡", "can_calc": "0", "data_code": "is_die", "data_name": "死亡判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "存命", "item": "存命"}, {"code": "1", "disp": "死亡", "item": "死亡"}], "data_class": "死亡情報", "field_name": "is_die", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "die_date", "data_name": "死亡日", "data_type": "DateTime", "conv_table": [], "data_class": "死亡情報", "field_name": "die_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "急性ウィルス肝炎", "can_calc": "0", "conv_sql": {"sql_cd": -6, "field_name": "disease_name", "target_var": "@diseaseCd"}, "data_code": "die_name", "data_name": "死因", "data_type": "string", "conv_table": [], "data_class": "死亡情報", "field_name": "die_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]'::jsonb, '0', '{"applications": [3]}'::jsonb, '{"classes": []}'::jsonb, '患者イベントテキスト項目取得テスト用 @facilityCd @patId @fromDate @toDate', '2024-03-19 16:02:38.403', current_timestamp, NULL);
