DELETE FROM sys_data_set a WHERE a.sql_cd in (-2030);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2030, 'SELECT
	ntss_db6_ppm.hosp_pat_id AS patid --患者ID
	,personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| '' '' ||personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS name --氏名
	,ntss_db6_ppm_json ->> ''ctl_no'' AS ctlno --管理番号
	,to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,to_char(ntss_db6_ppm.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS regdate --登録日時
	,personal_info_decrypt(ntss_db6_ppm_json ->> ''relation_name'') AS relationname --続柄
	,personal_info_decrypt(ntss_db6_ppm_json ->> ''last_name'')|| '' '' || personal_info_decrypt(ntss_db6_ppm_json ->> ''first_name'') AS rname --連絡先氏名
	,personal_info_decrypt(ntss_db6_ppm_json ->> ''zip_cd'') AS zipcode --郵便番号
	,personal_info_decrypt(ntss_db6_ppm_json ->> ''address'') AS address --住所(市町村）
	,'''' AS addressdetail --住所(番地アパート）
	,personal_info_decrypt(ntss_db6_ppm_json ->> ''tel1'') AS telno1 --電話番号１
	,personal_info_decrypt(ntss_db6_ppm_json ->> ''tel2'') AS telno2 --電話番号２
	,personal_info_decrypt(ntss_db6_ppm_json ->> ''memo1'')|| '' '' || personal_info_decrypt(ntss_db6_ppm_json ->> ''memo2'') AS memo --メモ
FROM
	pat_personal_main ntss_db6_ppm
	CROSS JOIN LATERAL json_array_elements(ntss_db6_ppm.other_contact_info ::json) ntss_db6_ppm_json
WHERE 
	ntss_db6_ppm_json ->> ''ctl_no'' = ''1''
	AND ntss_db6_ppm.is_del = ''0''
	AND ntss_db6_ppm.facility_cd = @facilityCd
	AND ntss_db6_ppm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate , ''YYYYMMDDHH24MISS'' );', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者情報1：患者イベント テキスト　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
