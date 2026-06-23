delete from "sys_data_set" where "sql_cd" >= -2391 and  "sql_cd" <= -2010;INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2010, 'SELECT
	ntss_db6_ppm.hosp_pat_id AS PATID --患者ID
	,
	personal_info_decrypt ( ntss_db6_ppm.pat_last_name ) || '' '' || personal_info_decrypt ( ntss_db6_ppm.pat_first_name ) AS NAME --氏名
	,
	personal_info_decrypt ( ntss_db6_ppm.pat_last_name_kana ) || '' '' || personal_info_decrypt ( ntss_db6_ppm.pat_first_name_kana ) AS NAME_KANA --患者名カナ
	,
	ntss_db6_ppm.pat_blood_type_abo AS BLOOD_TYPE_ABO --血液型ABO
	,
	ntss_db6_ppm.pat_blood_type_rh AS BLOOD_TYPE_RH --血液型RH
	,
	ntss_db6_ppm.pat_birthday AS BIRTHDAY --生年月日
	,
	ntss_db6_ppm.pat_sex AS SEX_CD --性別
	,
CASE
		
		WHEN ( ntss_db6_pi.insu_class = ''0'' AND ntss_db6_pi.is_selected = ''1'' ) THEN
		ntss_db6_pi.insu_info ->> ''insu_pat_no'' 
		WHEN ( ntss_db6_pi.insu_class = ''1'' AND ntss_db6_pi.is_selected = ''1'' ) THEN
		ntss_db6_pi.insu_pub_info ->> ''insu_pub_no'' 
		WHEN ( ntss_db6_pi.insu_class = ''1'' AND ntss_db6_pi.is_selected = ''2'' ) THEN
		ntss_db6_pi.insu_set_info ->> ''insu_pat_no'' 
	END AS INSURANCE_NO --保険者番号
	,
CASE
		
		WHEN ( ntss_db6_pi.insu_class = ''2'' AND ntss_db6_pi.is_selected = ''1'' ) THEN
		ntss_db6_pi.insu_set_info ->> ''insu_pub1_cd'' ELSE ntss_db6_pi.insu_pub_info ->> ''insu_pub_no'' 
	END AS PUB_INSU_NO1 --公費負担者番号1
	,
CASE
		
		WHEN ( ntss_db6_pi.insu_class = ''2'' AND ntss_db6_pi.is_selected = ''1'' ) THEN
		ntss_db6_pi.insu_set_info ->> ''insu_pub2_cd'' ELSE ntss_db6_pi.insu_pub_info ->> ''insu_pub_no'' 
	END AS PUB_INSU_NO2 --公費負担者番号2
	,
CASE
		
		WHEN ( ntss_db6_pi.insu_class = ''0'' AND ntss_db6_pi.is_selected = ''1'' ) THEN
		ntss_db6_pi.insu_info ->> ''insu_pat_no'' 
		WHEN ( ntss_db6_pi.insu_class = ''2'' AND ntss_db6_pi.is_selected = ''1'' ) THEN
		ntss_db6_pi.insu_set_info ->> ''insu_cd'' 
	END AS INSURANCE_CD --保険区分
	,
CASE
		
		WHEN ( ntss_db6_pi.insu_class = ''0'' AND ntss_db6_pi.is_selected = ''1'' ) THEN
		ntss_db6_pi.insu_info ->> ''insu_pat_mark'' 
		WHEN ( ntss_db6_pi.insu_class = ''2'' AND ntss_db6_pi.is_selected = ''1'' ) THEN
		ntss_db6_pi.insu_set_info ->> ''insu_cd'' 
	END AS HIINSURANCE_CODE --被保険者記号番号
	,
	ntss_db6_ppm.in_out_class AS INOUT --入院外来
	,
	to_char(ntss_db6_ppm.die_date, ''YYYY-MM-DD hh24:mi:ss'') AS DIE_DATE --死亡日
	,
	personal_info_decrypt ( ntss_db6_mpu.user_first_name ) || '' '' || personal_info_decrypt ( ntss_db6_mpu.user_last_name ) AS DOCTOR_NAME1 --担当医1
	,
	personal_info_decrypt ( ntss_db6_mpu.user_first_name ) || '' '' || personal_info_decrypt ( ntss_db6_mpu.user_last_name ) AS DOCTOR_NAME2 --担当医2
	,
	personal_info_decrypt ( ntss_db6_mpu.user_first_name ) || '' '' || personal_info_decrypt ( ntss_db6_mpu.user_last_name ) AS STAFF_NAME1 --担当スタッフ１
	,
	personal_info_decrypt ( ntss_db6_mpu.user_first_name ) || '' '' || personal_info_decrypt ( ntss_db6_mpu.user_last_name ) AS STAFF_NAME2 --担当スタッフ２
	,
	ntss_db6_ppm.dial_diff_com_info AS DIAL_DIFF --透析困難
	,
	to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
	,
CASE
		
		WHEN ntss_db6_ppm.in_out_class = ''0'' THEN
		ntss_db6_pi.insu_info ->> ''futan-g'' 
		WHEN ntss_db6_ppm.in_out_class = ''0'' THEN
		ntss_db6_pi.insu_info ->> ''futan-n'' 
	END AS INSURANCE_RATIO --保険区分
	
FROM
	pat_personal_main ntss_db6_ppm
	LEFT JOIN pat_insurance ntss_db6_pi ON ntss_db6_ppm.pat_id = ntss_db6_pi.pat_id
	INNER JOIN mst_personal_user ntss_db6_mpu ON ntss_db6_ppm.facility_cd = ntss_db6_mpu.facility_cd 
WHERE
	ntss_db6_ppm.is_del = ''0'' 
	AND ntss_db6_ppm.facility_cd = @facilityCd', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者情報1：患者イベント テキスト　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2011, 'SELECT
	ntss_db5_pm.medical_care_info ->> ''dialysis_count'' AS DIAL_COUNT --透析回数
	,
	ntss_db5_mv.va_direct AS SHANT_PART --シャント位置
	,
	ntss_db5_pu.physical_info ->> ''ctr'' AS CTR --CTR
	,
	ntss_db5_pu.physical_info ->> ''exam_date'' AS CTR_UPDATE --CTR更新日時
	,
	ntss_db5_pm.medical_care_info ->> ''hospital_start_date'' AS START_DATE --当院開始日
	,
	ntss_db5_pm.is_infect AS INFECT --感染症有無
	,
	ntss_db5_pm.medical_care_info ->> ''main_course_cd'' AS WARD --病棟名
	,
	ntss_db5_pm.medical_care_info ->> ''ward_cd'' AS COURSE --診療科名
	,
CASE
		
		WHEN info ->> ''ctl_no'' = ''1'' THEN
		info ->> ''content'' 
	END AS MEMO --患者メモ
	,
	ntss_db5_mdd.in_hospital_cd_1 AS DIALDIFF_CD --透析困難コメントコード
	,
	ntss_db5_mdd.dialysis_difficulty_name AS DIAL_DIFF_COMMENT --透析困難コメント
	,
	ntss_db5_ms.in_hospital_cd_1 AS INJURY_CD --重傷度コード
	,
	ntss_db5_ms.severity_name AS INJURY_NAME --重傷度名称
	,
	ntss_db5_md.in_hospital_cd_1 AS BASE_DISEASE_CD --原疾患コード
	,
	ntss_db5_md.disease_name AS BASE_DISEASE_NAME --原疾患名称
	,
	ntss_db5_mt.in_hospital_cd_1 AS TRANSPORT_CD --輸送区分コード
	,
	ntss_db5_mt.transport_name AS TRANSPORT_NAME --輸送区分名称
	,
	ntss_db5_pg.pat_group_name AS PAT_GROUP_NAME --患者グループ
	,
	ntss_db5_pgd.pat_group_cd AS PAT_GROUP_CD --患者グループコード
	,
	ntss_db5_pm.medical_care_info ->> ''dialysis_start_date'' AS DIAL_START_DATE --透析導入日
	
FROM
	pat_main ntss_db5_pm
	INNER JOIN mst_va ntss_db5_mv ON ntss_db5_pm.facility_cd = ntss_db5_mv.facility_cd
	LEFT JOIN pat_unique ntss_db5_pu ON ntss_db5_pm.pat_id = ntss_db5_pu.pat_id
	CROSS JOIN LATERAL json_array_elements ( ntss_db5_pm.pat_memo_info :: json ) info
	INNER JOIN mst_dialysis_difficulty ntss_db5_mdd ON ntss_db5_pm.facility_cd = ntss_db5_mdd.facility_cd
	INNER JOIN mst_severity ntss_db5_ms ON ntss_db5_pm.facility_cd = ntss_db5_ms.facility_cd
	INNER JOIN mst_disease ntss_db5_md ON ntss_db5_pm.facility_cd = ntss_db5_md.facility_cd
	INNER JOIN mst_transport ntss_db5_mt ON ntss_db5_pm.facility_cd = ntss_db5_mt.facility_cd
	LEFT JOIN pat_group ntss_db5_pg ON ntss_db5_pm.facility_cd = ntss_db5_pg.facility_cd
	LEFT JOIN pat_group_detail ntss_db5_pgd ON ntss_db5_pm.facility_cd = ntss_db5_pgd.facility_cd 
	AND ntss_db5_pg.pat_group_cd = ntss_db5_pgd.pat_group_cd 
WHERE
	ntss_db5_pm.is_del = ''0'' 
	AND ntss_db5_pm.facility_cd = @facilityCd 
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
	AND to_date( @toDate, ''YYYYMMDD'' )', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者情報1：患者イベント テキスト　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2020, 'SELECT
	ntss_db6_ppm.pat_id AS pat_id,
	ntss_db6_ppm.hosp_pat_id AS PATID,
	personal_info_decrypt(ntss_db6_ppm.pat_last_name) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS NAME,
	NULL AS ctl_no,
	NULL AS up_date,
	NULL AS taboo,
	NULL AS memo 
FROM
	pat_personal_main ntss_db6_ppm 
WHERE
	ntss_db6_ppm.is_del = ''0'' 
	AND ntss_db6_ppm.facility_cd = @facilityCd', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者情報1：患者イベント テキスト　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2021, 'SELECT
  ntss_db5_pm.pat_id,
	ntss_db5_pm.taboo_allergy_info ->> ''ctl_no'' AS CTL_NO,
	to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE,
	ntss_db5_pm.taboo_allergy_info ->> ''content'' AS TABOO,
	ntss_db5_pm.taboo_allergy_info ->> ''memo'' AS MEMO 
FROM
	pat_main ntss_db5_pm
WHERE
	ntss_db5_pm.is_del = ''0'' 
	AND ntss_db5_pm.facility_cd = @facilityCd 
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
	AND to_date( @toDate, ''YYYYMMDD'' )', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者情報1：患者イベント テキスト　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2030, 'SELECT                		
    ntss_db6_ppm.hosp_pat_id AS PATID --患者ID  		
		,ntss_db6_ppm.pat_id 
    ,personal_info_decrypt(ntss_db6_ppm.pat_last_name) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS NAME --氏名		
    ,ntss_db6_ppm.other_contact_info ->> ''ctl_no'' AS CTL_NO --管理番号		
	  ,to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --更新日時    	
		,to_char(ntss_db6_ppm.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS REG_DATE
    ,ntss_db6_ppm.other_contact_info ->> ''relation_name'' AS RELATION_NAME --続柄		
    ,ntss_db6_ppm.other_contact_info ->> ''last_name'' || '' '' || ''first_name'' AS RNAME --連絡先氏名		
    ,ntss_db6_ppm.other_contact_info ->> ''zip_cd''  AS ZIPCODE --郵便番号		
    ,ntss_db6_ppm.other_contact_info ->> ''address''  AS ADDRESS --住所(市町村）		
    ,ntss_db6_ppm.other_contact_info ->> ''tel1''  AS TELNO1 --電話番号１		
    ,ntss_db6_ppm.other_contact_info ->> ''tel2''  AS TELNO2 --電話番号２		
    ,ntss_db6_ppm.other_contact_info ->> ''memo1'' || '' '' || ''memo2'' AS MEMO --メモ		
               		
FROM                 		
    pat_personal_main    ntss_db6_ppm 		
WHERE		
	ntss_db6_ppm.is_del = ''0'' 	

  	AND ntss_db6_ppm.facility_cd = @facilityCd', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者情報1：患者イベント テキスト　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2040, 'SELECT                					
    ntss_db6_ppm.pat_id AS pat_id,					
    ntss_db6_ppm.hosp_pat_id AS PATID --患者ID 
			
FROM                 					
    pat_personal_main    ntss_db6_ppm   					
WHERE					
	  ntss_db6_ppm.is_del = ''0'' 				
	  AND ntss_db6_ppm.facility_cd = @facilityCd				
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2041, '    SELECT	
	      ntss_db5_pu.pat_id
				,ntss_db5_pu.medical_hst_info ->> ''disp_order'' AS CTL_NO --管理番号	
        ,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --更新日時	
        ,ntss_db5_pu.medical_hst_info ->> ''disease_cd'' AS DISEASE_CD --病名コード	
        ,ntss_db5_pu.medical_hst_info ->> ''disease_date'' AS DISEASE_DATE --発症日	
        ,ntss_db5_pu.medical_hst_info ->> ''out_come_date'' AS RECOVER_DATE --治癒日	
        ,ntss_db5_pu.medical_hst_info ->> ''is_main_disease'' AS MAIN_DISEASE --主病名	
        ,ntss_db5_pu.medical_hst_info ->> ''out_come'' AS STATUS --転帰	
        ,ntss_db5_pu.medical_hst_info ->> ''is_notice'' AS NOTICE_FLG --告知有無	
        ,CASE	
            WHEN ntss_db5_pu.medical_hst_info ->> ''course_is_free'' = ''1'' THEN ntss_db5_pu.medical_hst_info ->> ''diagnostician_cd''	
         END	
        ,ntss_db5_pu.medical_hst_info ->> ''memo'' AS MEMO --メモ	
	
    FROM 	
        ntss_db5.ntss.pat_unique  ntss_db5_pu	
        ,(SELECT disease_cd FROM ntss_db5.ntss.mst_disease) mst_d	
    WHERE	
        ntss_db5_pu.medical_hst_info ->> ''disease_cd'' = cast(mst_d.disease_cd as character varying)	
                	AND ntss_db5_pu.is_del = ''0'' 
                	AND ntss_db5_pu.facility_cd = @facilityCd 
	AND ntss_db5_pu.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
	AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2050, 'SELECT 
    ntss_db6_ppm.pat_id AS pat_id,	               				
    ntss_db6_ppm.hosp_pat_id AS PATID,--患者ID 
    NULL AS infection_cd,
		NULL AS infection_name,
		NULL AS up_date,					
		NULL AS infect
FROM                 				
    pat_personal_main    ntss_db6_ppm   				
				
WHERE				
    ntss_db6_ppm.is_del = ''0'' 				
    AND ntss_db6_ppm.facility_cd = @facilityCd				
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2051, 'SELECT					
    ntss_db5_pm.pat_id,					
    ntss_db5_mi.in_hospital_cd_1 AS INFECTION_CD --感染症コード					
    ,ntss_db5_mi.infection_name AS INFECTION_NAME --感染症名					
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --更新日時    					
    ,ntss_db5_pm.infect_info ->> ''infect'' AS INFECT --結果コード					
FROM 					
    pat_main  ntss_db5_pm					
inner join 					
    mst_infection    ntss_db5_mi					
ON 					
    ntss_db5_pm.infect_info ->> ''infection_cd'' = cast(ntss_db5_mi.infection_cd as character varying)					
					
WHERE					
	ntss_db5_pm.is_del = ''0'' 				
	AND ntss_db5_pm.facility_cd = @facilityCd 				
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 				
	AND to_date( @toDate, ''YYYYMMDD'' )				
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2060, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id,
    ntss_db6_ppm.hosp_pat_id AS PATID, --患者ID 
		NULL AS up_date,	
		NULL AS	devision,		 	
		NULL AS code,
		NULL AS code_update,
		NULL AS add_flg,
		NULL AS item_name,
		NULL AS main_dial_diff,
		NULL AS in_hospital_cd,
		NULL AS in_hospital_cd2
			 
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2061, 'SELECT                	
    ntss_db5_pm.pat_id,	
    ntss_db5_pm.up_date AS UP_DATE --更新日時	
    ,CASE	
        WHEN ntss_db5_md.addition_class = ''2'' THEN ''1''  	
        ELSE ''0''	
     END AS DIVISION --レセプトメモ区分	
    ,ntss_db5_pm.addition_info ->> ''cd'' AS CODE --コード	
    ,ntss_db5_md.up_date AS CODE_UPDATE --コード更新日時	
    ,CASE	
        WHEN jsonb_array_length(ntss_db5_pm.addition_info::jsonb) > 1 THEN ''1''	
        ELSE ''0''	
     END AS ADD_FLG --加算有無	
    ,ntss_db5_pm.addition_info ->> ''name'' AS ITEM_NAME --項目名称	
    ,CASE 	
        WHEN ntss_db5_md.addition_class = ''2'' THEN ''1''	
        ELSE ''0''	
     END AS MAIN_DIAL_DIFF -- 主たる透析困難 	
    ,ntss_db5_md.in_hospital_cd_1 AS IN_HOSPITAL_CD --院内コード	
     ,ntss_db5_md.in_hospital_cd_2 AS IN_HOSPITAL_CD --院内コード２	
FROM                 	
    pat_main ntss_db5_pm   	
	
INNER JOIN 	
    mst_addition ntss_db5_md	
ON	
    ntss_db5_pm.facility_cd = ntss_db5_md.facility_cd	
	
WHERE	
	ntss_db5_pm.is_del = ''0'' 
	AND ntss_db5_pm.facility_cd = @facilityCd 
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
	AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2070, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id,
    ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,personal_info_decrypt(ntss_db6_ppm.pat_last_name) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS NAME  --氏名
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2071, 'SELECT                	
    ntss_db5_pm.pat_id,	
    ntss_db5_pm.up_date AS UP_DATE --更新日時	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''1'' THEN ntss_db5_pm.off_water_info -> ''1'' ->> ''name_1'' 	
        WHEN extract(DOW FROM now()) = ''2'' THEN ntss_db5_pm.off_water_info -> ''2'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''3'' THEN ntss_db5_pm.off_water_info -> ''3'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''4'' THEN ntss_db5_pm.off_water_info -> ''4'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''5'' THEN ntss_db5_pm.off_water_info -> ''5'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''6'' THEN ntss_db5_pm.off_water_info -> ''6'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''7'' THEN ntss_db5_pm.off_water_info -> ''7'' ->> ''name_1''	
    END AS REVISE_NAME --除水補正名(当日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''1'' THEN ntss_db5_pm.off_water_info -> ''1'' ->> ''weight_1'' 	
        WHEN extract(DOW FROM now()) = ''2'' THEN ntss_db5_pm.off_water_info -> ''2'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''3'' THEN ntss_db5_pm.off_water_info -> ''3'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''4'' THEN ntss_db5_pm.off_water_info -> ''4'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''5'' THEN ntss_db5_pm.off_water_info -> ''5'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''6'' THEN ntss_db5_pm.off_water_info -> ''6'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''7'' THEN ntss_db5_pm.off_water_info -> ''7'' ->> ''weight_1''	
    END AS REVISE_WEIGHT --重量(当日)	
    ,CASE	
        WHEN extract(DOW FROM now()) = ''1'' THEN ntss_db5_pm.off_water_info -> ''1'' ->> ''name_1'' 
    END AS MON_REVISE_NAME --除水補正名(月曜日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''1'' THEN ntss_db5_pm.off_water_info -> ''1'' ->> ''weight_1'' 
    END AS MON_REVISE_WEIGHT --重量(月曜日)	
    ,ntss_db5_pm.up_date AS MON_UP_DATE --更新日時(月曜日)	
    ,CASE	
        WHEN extract(DOW FROM now()) = ''2'' THEN ntss_db5_pm.off_water_info -> ''2'' ->> ''name_1'' 	
    END AS TUE_REVISE_NAME --除水補正名(火曜日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''2'' THEN ntss_db5_pm.off_water_info -> ''2'' ->> ''weight_1'' 	
    END AS TUE_REVISE_WEIGHT --重量(火曜日)	
    ,ntss_db5_pm.up_date AS TUE_UP_DATE --更新日時(火曜日)	
    ,CASE	
        WHEN extract(DOW FROM now()) = ''3'' THEN ntss_db5_pm.off_water_info -> ''3'' ->> ''name_1'' 	
    END AS WED_REVISE_NAME --除水補正名(水曜日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''3'' THEN ntss_db5_pm.off_water_info -> ''3'' ->> ''weight_1'' 	
    END AS WED_REVISE_WEIGHT --重量(水曜日)	
    ,ntss_db5_pm.up_date AS WED_UP_DATE --更新日時(水曜日)	
    ,CASE	
        WHEN extract(DOW FROM now()) = ''4'' THEN ntss_db5_pm.off_water_info -> ''4'' ->> ''name_1'' 	
    END AS THU_REVISE_NAME --除水補正名(木曜日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''4'' THEN ntss_db5_pm.off_water_info -> ''4'' ->> ''weight_1'' 	
    END AS THU_REVISE_WEIGHT --重量(木曜日)	
    ,ntss_db5_pm.up_date AS THU_UP_DATE --更新日時(木曜日)	
    ,CASE	
        WHEN extract(DOW FROM now()) = ''5'' THEN ntss_db5_pm.off_water_info -> ''5'' ->> ''name_1'' 	
    END AS FRI_REVISE_NAME --除水補正名(金曜日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''5'' THEN ntss_db5_pm.off_water_info -> ''5'' ->> ''weight_1'' 	
    END AS FRI_REVISE_WEIGHT --重量(金曜日)	
    ,ntss_db5_pm.up_date AS FRI_UP_DATE --更新日時(金曜日)	
    ,CASE	
        WHEN extract(DOW FROM now()) = ''6'' THEN ntss_db5_pm.off_water_info -> ''6'' ->> ''name_1'' 	
    END AS SAT_REVISE_NAME --除水補正名(土曜日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''6'' THEN ntss_db5_pm.off_water_info -> ''6'' ->> ''weight_1'' 	
    END AS SAT_REVISE_WEIGHT --重量(土曜日)	
    ,ntss_db5_pm.up_date AS SAT_UP_DATE --更新日時(土曜日)	
    ,CASE	
        WHEN extract(DOW FROM now()) = ''7'' THEN ntss_db5_pm.off_water_info -> ''7'' ->> ''name_1'' 	
    END AS SUN_REVISE_NAME --除水補正名(日曜日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''7'' THEN ntss_db5_pm.off_water_info -> ''7'' ->> ''weight_1'' 	
    END AS SUN_REVISE_WEIGHT --重量(日曜日)	
    ,ntss_db5_pm.up_date AS SUN_UP_DATE --更新日時(日曜日)	
FROM                 	
    pat_main ntss_db5_pm   	
	
INNER JOIN 	
    mst_addition ntss_db5_md	
ON	
    ntss_db5_pm.facility_cd = ntss_db5_md.facility_cd	
	
WHERE	
	ntss_db5_pm.is_del = ''0'' 
	AND ntss_db5_pm.facility_cd = @facilityCd 
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
	AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2080, 'SELECT
	ntss_db6_ppm.pat_id AS pat_id,
	ntss_db6_ppm.hosp_pat_id AS PATID, --患者ID
	personal_info_decrypt ( ntss_db6_ppm.pat_last_name ) || '' '' || personal_info_decrypt ( ntss_db6_ppm.pat_first_name ) AS NAME,--氏名
	NULL AS CTL_NO,
	NULL AS UP_DATE,
	NULL AS REVISE_NAME,
	NULL AS REVISE_WEIGHT,
	NULL AS HOSP_WHEELCHAIR_CD,
	NULL AS WHEELCHAIR_NAME,
	NULL AS MON_UP_DATE,
	NULL AS MON_REVISE_NAME,
	NULL AS MON_REVISE_WEIGHT,
	NULL AS MON_HOSP_WHEELCHAIR_CD,
	NULL AS MON_WHEELCHAIR_NAME,
	NULL AS TUE_UP_DATE,
	NULL AS TUE_REVISE_NAME,
	NULL AS TUE_REVISE_WEIGHT,
	NULL AS TUE_HOSP_WHEELCHAIR_CD,
	NULL AS TUE_WHEELCHAIR_NAME,
	NULL AS WED_UP_DATE,
	NULL AS WED_REVISE_NAME,
	NULL AS WED_REVISE_WEIGHT,
	NULL AS WED_HOSP_WHEELCHAIR_CD,
	NULL AS WED_WHEELCHAIR_NAME,
	NULL AS THU_UP_DATE,
	NULL AS THU_REVISE_NAME,
	NULL AS THU_REVISE_WEIGHT,
	NULL AS THU_HOSP_WHEELCHAIR_CD,
	NULL AS THU_WHEELCHAIR_NAME,
	NULL AS FRI_UP_DATE,
	NULL AS FRI_REVISE_NAME,
	NULL AS FRI_REVISE_WEIGHT,
	NULL AS FRI_HOSP_WHEELCHAIR_CD,
	NULL AS FRI_WHEELCHAIR_NAME,
	NULL AS SAT_UP_DATE,
	NULL AS SAT_REVISE_NAME,
	NULL AS SAT_REVISE_WEIGHT,
	NULL AS SAT_HOSP_WHEELCHAIR_CD,
	NULL AS SAT_WHEELCHAIR_NAME,
	NULL AS SUN_UP_DATE,
	NULL AS SUN_REVISE_NAME,
	NULL AS SUN_REVISE_WEIGHT,
	NULL AS SUN_HOSP_WHEELCHAIR_CD,
	NULL AS SUN_WHEELCHAIR_NAME 
FROM
	pat_personal_main ntss_db6_ppm 
WHERE
	ntss_db6_ppm.is_del = ''0''
  AND ntss_db6_ppm.facility_cd = @facilityCd	
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2081, 'SELECT                	
    ntss_db5_pm.pat_id,	
		to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE
   ,CASE	
        WHEN extract(DOW FROM now()) = ''1'' THEN ntss_db5_pm.tare_info -> ''1'' ->> ''name_1'' 	
        WHEN extract(DOW FROM now()) = ''2'' THEN ntss_db5_pm.tare_info -> ''2'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''3'' THEN ntss_db5_pm.tare_info -> ''3'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''4'' THEN ntss_db5_pm.tare_info -> ''4'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''5'' THEN ntss_db5_pm.tare_info -> ''5'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''6'' THEN ntss_db5_pm.tare_info -> ''6'' ->> ''name_1''	
        WHEN extract(DOW FROM now()) = ''7'' THEN ntss_db5_pm.tare_info -> ''7'' ->> ''name_1''	
    END AS REVISE_NAME --風袋補正名(当日)	
   ,CASE	
        WHEN extract(DOW FROM now()) = ''1'' THEN ntss_db5_pm.tare_info -> ''1'' ->> ''weight_1'' 	
        WHEN extract(DOW FROM now()) = ''2'' THEN ntss_db5_pm.tare_info -> ''2'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''3'' THEN ntss_db5_pm.tare_info -> ''3'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''4'' THEN ntss_db5_pm.tare_info -> ''4'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''5'' THEN ntss_db5_pm.tare_info -> ''5'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''6'' THEN ntss_db5_pm.tare_info -> ''6'' ->> ''weight_1''	
        WHEN extract(DOW FROM now()) = ''7'' THEN ntss_db5_pm.tare_info -> ''7'' ->> ''weight_1''	
    END AS REVISE_WEIGHT --重量(当日)	
    ,ntss_db5_mwc.wheel_chair_cd AS HOSP_WHEELCHAIR_CD --車椅子コード(当日)	
    ,ntss_db5_mwc.wheel_chair_name AS WHEELCHAIR_NAME --車椅子名(当日)	
		
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS MON_UP_DATE --更新日時(月曜日)
    ,ntss_db5_pm.off_water_info -> ''1'' ->> ''name_1'' AS MON_REVISE_NAME --風袋補正名(月曜日)	
    ,ntss_db5_pm.off_water_info -> ''1'' ->> ''weight_1'' AS MON_REVISE_WEIGHT --重量(月曜日)	
    ,ntss_db5_mwc.wheel_chair_cd AS MON_HOSP_WHEELCHAIR_CD --車椅子コード(月曜日)	
    ,ntss_db5_mwc.wheel_chair_name AS MON_WHEELCHAIR_NAME --車椅子名(月曜日)	
		
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS TUE_UP_DATE --更新日時(火曜日)	
    ,ntss_db5_pm.off_water_info -> ''2'' ->> ''name_1'' AS TUE_REVISE_NAME --風袋補正名(火曜日)	
    ,ntss_db5_pm.off_water_info -> ''2'' ->> ''weight_1'' AS TUE_REVISE_WEIGHT --重量(火曜日)	
    ,ntss_db5_mwc.wheel_chair_cd AS TUE_HOSP_WHEELCHAIR_CD --車椅子コード(火曜日)	
    ,ntss_db5_mwc.wheel_chair_name AS TUE_WHEELCHAIR_NAME --車椅子名(火曜日)	
		
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS WED_UP_DATE --更新日時(水曜日)	
    ,ntss_db5_pm.off_water_info -> ''3'' ->> ''name_1'' AS WED_REVISE_NAME --風袋補正名(水曜日)	
    ,ntss_db5_pm.off_water_info -> ''3'' ->> ''weight_1'' AS WED_REVISE_WEIGHT --重量(水曜日)	
    ,ntss_db5_mwc.wheel_chair_cd AS WED_HOSP_WHEELCHAIR_CD --車椅子コード(水曜日)	
    ,ntss_db5_mwc.wheel_chair_name AS WED_WHEELCHAIR_NAME --車椅子名(水曜日)	
		
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS THU_UP_DATE --更新日時(木曜日)	
    ,ntss_db5_pm.off_water_info -> ''4'' ->> ''name_1'' AS THU_REVISE_NAME --風袋補正名(木曜日)	
    ,ntss_db5_pm.off_water_info -> ''4'' ->> ''weight_1'' AS THU_REVISE_WEIGHT --重量(木曜日)	
    ,ntss_db5_mwc.wheel_chair_cd AS THU_HOSP_WHEELCHAIR_CD --車椅子コード(木曜日)	
    ,ntss_db5_mwc.wheel_chair_name AS THU_WHEELCHAIR_NAME --車椅子名(木曜日)	
		
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS FRI_UP_DATE --更新日時(金曜日)	
    ,ntss_db5_pm.off_water_info -> ''5'' ->> ''name_1'' AS FRI_REVISE_NAME --風袋補正名(金曜日)	
    ,ntss_db5_pm.off_water_info -> ''5'' ->> ''weight_1'' AS FRI_REVISE_WEIGHT --重量(金曜日)	
    ,ntss_db5_mwc.wheel_chair_cd AS FRI_HOSP_WHEELCHAIR_CD --車椅子コード(金曜日)	
    ,ntss_db5_mwc.wheel_chair_name AS FRI_WHEELCHAIR_NAME --車椅子名(金曜日)	
		
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS SAT_UP_DATE --更新日時(土曜日)	
    ,ntss_db5_pm.off_water_info -> ''6'' ->> ''name_1'' AS SAT_REVISE_NAME --風袋補正名(土曜日)	
    ,ntss_db5_pm.off_water_info -> ''6'' ->> ''weight_1'' AS SAT_REVISE_WEIGHT --重量(土曜日)	
    ,ntss_db5_mwc.wheel_chair_cd AS SAT_HOSP_WHEELCHAIR_CD --車椅子コード(土曜日)	
    ,ntss_db5_mwc.wheel_chair_name AS SAT_WHEELCHAIR_NAME --車椅子名(土曜日)	
		
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS SUN_UP_DATE --更新日時(日曜日)	
    ,ntss_db5_pm.off_water_info -> ''7'' ->> ''name_1'' AS SUN_REVISE_NAME --風袋補正名(日曜日)	
    ,ntss_db5_pm.off_water_info -> ''7'' ->> ''weight_1'' AS SUN_REVISE_WEIGHT --重量(日曜日)	
    ,ntss_db5_mwc.wheel_chair_cd AS SUN_HOSP_WHEELCHAIR_CD --車椅子コード(日曜日)	
    ,ntss_db5_mwc.wheel_chair_name AS SUN_WHEELCHAIR_NAME --車椅子名(日曜日)	
FROM                 	
    pat_main ntss_db5_pm   	
	
INNER JOIN 	
    mst_wheel_chair ntss_db5_mwc	
ON	
    ntss_db5_pm.pat_id = ntss_db5_mwc.pat_id	
WHERE	
	ntss_db5_pm.is_del = ''0'' 

	AND ntss_db5_pm.facility_cd = @facilityCd 
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
	AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2090, 'SELECT                		
    ntss_db6_ppm.pat_id AS pat_id,		
    ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    		
		,personal_info_decrypt ( ntss_db6_ppm.pat_last_name ) || '' '' || personal_info_decrypt ( ntss_db6_ppm.pat_first_name ) AS NAME--氏名
		,NULL AS DIALYSIS_DATE
		,NULL AS DIALYSIS_NO
		,NULL AS UP_DATE
		,NULL AS BED_NO
		,NULL AS BED_NAME
		,NULL AS DEVICE_NO
		,NULL AS DEVICE_NAME
		,NULL AS KUR_CD
		,NULL AS KUR_NAME
		,NULL AS START_DATE
		,NULL AS END_DATE
		,NULL AS DIALYSIS_TIME
		,NULL AS PLAN_DIALYSIS_TIME
		,NULL AS DIALYSIS_NUM
		,NULL AS LAST_WEIGHT
		,NULL AS WEIGHT_BEFORE
		,NULL AS WEIGHT_AFTER
		,NULL AS BP_BEFORE_MAX
		,NULL AS BP_BEFORE_MIN
		,NULL AS BP_BEFORE_AVE
		,NULL AS BP_AFTER_MAX
		,NULL AS BP_AFTER_MIN
		,NULL AS BP_AFTER_AVE
		,NULL AS WATER_REMOVAL_TARGET
		,NULL AS REVISE_NAME1
		,NULL AS REVISE_WEIGHT1
		,NULL AS REVISE_NAME2
		,NULL AS REVISE_WEIGHT2
		,NULL AS REVISE_NAME3
		,NULL AS REVISE_WEIGHT3
		,NULL AS REVISE_NAME4
		,NULL AS REVISE_WEIGHT4
		,NULL AS REVISE_NAME5
		,NULL AS REVISE_WEIGHT5
		,NULL AS PULSE_BEFORE
		,NULL AS PULSE_AFTER
		,NULL AS CHARGE_1_NAME
		,NULL AS CHARGE_2_NAME
		,NULL AS CHARGE_DATE_1
		,NULL AS CHARGE_DATE_2
		,NULL AS PUNCTURE_1_NAME
		,NULL AS PUNCTURE_2_NAME
		,NULL AS PUNCTURE_DATE_1
		,NULL AS PUNCTURE_DATE_2
		,NULL AS COLLECT_1_NAME
		,NULL AS COLLECT_2_NAME
		,NULL AS COLLECT_DATE_1
		,NULL AS COLLECT_DATE_2
		,NULL AS INOUT_FLG
		,NULL AS KT_V_MEASURE
		,NULL AS URR
		,NULL AS RE_LOOP_RATE
		,NULL AS PULL_LEAVE_AMOUNT
		,NULL AS ADD_TOTL
		,NULL AS STATIC_VENOUS_PRESSURE
		,NULL AS VENOUS_ACCESS_PRESSURE_RATIO

FROM                 		
    pat_personal_main    ntss_db6_ppm   		
WHERE		
    ntss_db6_ppm.is_del = ''0'' 		
    AND ntss_db6_ppm.facility_cd = @facilityCd		
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2091, 'SELECT                
    ntss_db5_om.pat_id,
    ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号
		,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_mb.in_hospital_cd_1 AS BED_NO --ベッド番号
    ,ntss_db5_mb.bed_name AS BED_NAME --ベッド名
    ,ntss_db5_om.rst_machine_no AS DEVICE_NO --装置番号
    ,ntss_db5_om.rst_machine_name AS DEVICE_NAME --装置名
    ,ntss_db5_om.rst_kur_cd AS KUR_CD --クール
    ,ntss_db5_om.rst_kur_name AS KUR_NAME --クール名
		,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'')AS START_DATE --透析開始日時
		,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'')AS END_DATE --透析終了日時
		,to_char(ntss_db5_om.rst_end_date - ntss_db5_om.rst_start_date, ''hh24mi'')AS DIALYSIS_TIME --透析時間
    ,ntss_db5_om.rst_cond_info -> ''1'' ->> ''value'' AS PLAN_DIALYSIS_TIME --予定透析時間
		
    ,ntss_db5_om.rst_dialysis_cnt AS DIALYSIS_NUM --透析回数
    ,ntss_db5_om.rst_weight_info ->> ''weight_before'' AS WEIGHT_BEFORE --前体重 
    ,ntss_db5_om.rst_weight_info ->> ''weight_after'' AS WEIGHT_AFTER --後体重
    ,CASE 
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''1'' THEN ntss_db5_om.rst_vital_info ->> ''bp_max''
    END AS BP_BEFORE_MAX --透析前最高血圧
    ,CASE 
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''1'' THEN ntss_db5_om.rst_vital_info ->> ''bp_min''
    END AS BP_BEFORE_MIN --透析前最低血圧
    ,CASE 
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''1'' THEN ntss_db5_om.rst_vital_info ->> ''bp_ave''
    END AS BP_BEFORE_AVE --透析前平均血圧
    ,CASE 
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''2'' THEN ntss_db5_om.rst_vital_info ->> ''bp_max''
    END AS BP_BEFORE_MAX --透析後最高血圧
    ,CASE 
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''2'' THEN ntss_db5_om.rst_vital_info ->> ''bp_min''
    END AS BP_BEFORE_MIN --透析後最低血圧
    ,CASE 
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''2'' THEN ntss_db5_om.rst_vital_info ->> ''bp_ave''
    END AS BP_BEFORE_AVE --透析後平均血圧
    ,ntss_db5_om.rst_weight_info ->> ''water_removal_target'' AS WATER_REMOVAL_TARGET --目標除水量
    ,ntss_db5_om.rst_off_water_info ->> ''name_1'' AS REVISE_NAME1 --除水補正項目１
    ,ntss_db5_om.rst_off_water_info ->> ''weight_1'' AS REVISE_WEIGHT1 --除水補正値１
    ,ntss_db5_om.rst_off_water_info ->> ''name_2'' AS REVISE_NAME2 --除水補正項目2
    ,ntss_db5_om.rst_off_water_info ->> ''weight_2'' AS REVISE_WEIGHT2 --除水補正値2    
    ,ntss_db5_om.rst_off_water_info ->> ''name_3'' AS REVISE_NAME3 --除水補正項目3
    ,ntss_db5_om.rst_off_water_info ->> ''weight_3'' AS REVISE_WEIGHT3 --除水補正値3 
    ,ntss_db5_om.rst_off_water_info ->> ''name_4'' AS REVISE_NAME4 --除水補正項目4
    ,ntss_db5_om.rst_off_water_info ->> ''weight_4'' AS REVISE_WEIGHT4 --除水補正値4 
    ,ntss_db5_om.rst_off_water_info ->> ''name_5'' AS REVISE_NAME5 --除水補正項目5
    ,ntss_db5_om.rst_off_water_info ->> ''weight_5'' AS REVISE_WEIGHT5 --除水補正値5    
    ,CASE 
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''1'' THEN ntss_db5_om.rst_vital_info ->> ''pulse''
    END AS PULSE_BEFORE --透析前脈拍
    ,CASE 
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''2'' THEN ntss_db5_om.rst_vital_info ->> ''pulse''
    END AS PULSE_AFTER --透析後脈拍
    ,ntss_db5_om.rst_charge_user_info ->> ''user_last_name_1'' || '' '' || ''user_first_name_1'' AS CHARGE_1_NAME --担当者１
    ,ntss_db5_om.rst_charge_user_info ->> ''user_last_name_2'' || '' '' || ''user_first_name_2'' AS CHARGE_2_NAME --担当者2
		,to_char(to_timestamp(ntss_db5_om.rst_charge_user_info ->> ''date_1'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS CHARGE_DATE_1 -- 担当日時１
	  ,to_char(to_timestamp(ntss_db5_om.rst_charge_user_info ->> ''date_2'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS CHARGE_DATE_2 -- 担当日時１
    ,ntss_db5_om.rst_puncture_user_info ->> ''user_last_name_1'' || '' '' || ''user_first_name_1'' AS PUNCTURE_1_NAME -- 穿刺者１
    ,ntss_db5_om.rst_puncture_user_info ->> ''user_last_name_2'' || '' '' || ''user_first_name_2'' AS PUNCTURE_2_NAME -- 穿刺者２
		,to_char(to_timestamp(ntss_db5_om.rst_puncture_user_info ->> ''date_1'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS PUNCTURE_DATE_1 -- 穿刺日時1
	  ,to_char(to_timestamp(ntss_db5_om.rst_puncture_user_info ->> ''date_2'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS PUNCTURE_DATE_2 -- 穿刺日時２		
    ,ntss_db5_om.rst_return_user_info ->> ''user_last_name_1'' || '' '' || ''user_first_name_1'' AS COLLECT_1_NAME -- 回収者１
    ,ntss_db5_om.rst_return_user_info ->> ''user_last_name_2'' || '' '' || ''user_first_name_2'' AS COLLECT_2_NAME -- 回収者２
		,to_char(to_timestamp(ntss_db5_om.rst_return_user_info ->> ''date_1'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS COLLECT_DATE_1 -- 回収日時１
	  ,to_char(to_timestamp(ntss_db5_om.rst_return_user_info ->> ''date_2'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS COLLECT_DATE_2 -- 回収日時2		
    ,ntss_db5_om.rst_in_out_class AS INOUT_FLG --入外
    ,ntss_db5_om.rst_kt_v AS KT_V_MEASURE --Kt/v測定値
    ,ntss_db5_om.rst_weight_info ->> ''urr'' AS URR --URR
    ,ntss_db5_om.rst_weight_info ->> ''recrcl_rt'' AS RE_LOOP_RATE --再循環率
    ,ntss_db5_om.rst_weight_info ->> ''ihdf_pll'' AS PULL_LEAVE_AMOUNT --I-HDF引き残し量
    ,ntss_db5_om.rst_weight_info ->> ''add_total'' AS ADD_TOTL --除水積算値
    ,ntss_db5_om.rst_weight_info ->> ''sttc_vns_prssr'' AS STATIC_VENOUS_PRESSURE --静的静脈圧
    ,ntss_db5_om.rst_weight_info ->> ''.iap_rt'' AS VENOUS_ACCESS_PRESSURE_RATIO --IAP ratio
    
FROM                 
    ord_main ntss_db5_om   

INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
INNER JOIN
    mst_bed ntss_db5_mb
ON
    ntss_db5_om.facility_cd = ntss_db5_mb.facility_cd

WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2100, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS DIALYSIS_ITEM_NAME
    ,NULL AS VALUE
    ,NULL AS VALUE_NAME
    ,NULL AS UNIT
    ,NULL AS VALUE_CD1

FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2101, 'SELECT                		
    ntss_db5_om.pat_id,		
    ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日		
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号		
		,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時	
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value'' AS VALUE --設定値		
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value_name_1'' AS VALUE_NAME --名称		
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''unit'' AS UNIT --単位		
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value'' AS VALUE_CD2 --院内コード2		
FROM                 		
    ord_main ntss_db5_om   		
		
INNER JOIN 		
    ord_schedule ntss_db5_os		
ON		
    ntss_db5_om.pat_id = ntss_db5_os.pat_id		
WHERE		
    ntss_db5_om.is_del = ''0'' 		
    AND ntss_db5_om.facility_cd = @facilityCd 		
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 		
    AND to_date( @toDate, ''YYYYMMDD'' )		
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2110, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS DIALYSIS_ITEM_NAME
    ,NULL AS VALUE
    ,NULL AS VALUE_NAME
    ,NULL AS MED_GENERAL_NAME
    ,NULL AS UNIT
    ,NULL AS VALUE_CD1

FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2111, 'SELECT                
    ntss_db5_om.pat_id,
    ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value'' AS VALUE --設定値
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value_name_1'' AS VALUE_NAME --名称
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''unit'' AS UNIT --単位
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value'' AS VALUE_CD1 --院内コード1
FROM                 
    ord_main ntss_db5_om   

INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2120, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS EQUIP_CD
    ,NULL AS EQUIP_CD2
    ,NULL AS EQUIP_NAME
    ,NULL AS EQUIP_CLASS_NAME
    ,NULL AS PUNCTURE_CLASS
    ,NULL AS AMOUNT
    ,NULL AS UNIT
    ,NULL AS COMMENTS
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2121, 'SELECT                
    ntss_db5_om.pat_id,
    ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号
    ,row_number() over(order by ntss_db5_os.treat_date desc)
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_me.in_hospital_cd_1 AS EQUIP_CD --医療材料コード(院内コード1)
    ,ntss_db5_me.in_hospital_cd_2 AS EQUIP_CD2 --医療材料コード(院内コード1)
    ,ntss_db5_om.rst_equip_info ->> ''name'' AS EQUIP_NAME --医療材料名
    ,ntss_db5_om.rst_equip_info ->> ''class_name'' AS EQUIP_CLASS_NAME --医療材料分類名
    ,ntss_db5_om.rst_equip_info ->> ''needle_type'' AS PUNCTURE_CLASS --穿刺針区分
    ,ntss_db5_om.rst_equip_info ->> ''amount'' AS AMOUNT --数量
    ,ntss_db5_om.rst_equip_info ->> ''unit'' AS UNIT --単位
    ,ntss_db5_om.rst_equip_info ->> ''comment'' AS COMMENTS --コメント
    
FROM                 
    ord_main ntss_db5_om   

INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
INNER JOIN 
    mst_equipment ntss_db5_me
ON
    ntss_db5_om.rst_equip_info ->> ''cd'' = cast(ntss_db5_me.equipment_cd as character varying)
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2130, 'SELECT                	
    ntss_db6_ppm.pat_id AS pat_id	
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    	
    ,NULL AS DIALYSIS_DATE	
    ,NULL AS DIALYSIS_NO	
    ,NULL AS CTL_NO	
    ,NULL AS UP_DATE	
    ,NULL AS MEDICINE_CD	
    ,NULL AS MEDICINE_CD2	
    ,NULL AS MEDICINE_NAME	
    ,NULL AS MEDICINE_CLASS_NAME	
    ,NULL AS AMOUNT	
    ,NULL AS UNIT	
    ,NULL AS EFFECT_FLG	
    ,NULL AS EFFECT_DATE	
    ,NULL AS TIMING_NAME	
    ,NULL AS PROCEDURE_CD	
    ,NULL AS PROCEDURE_CD2	
    ,NULL AS PROCEDURE_NAME	
    ,NULL AS STAFF_CD	
    ,NULL AS STAFF_NAME	
    ,NULL AS COMMENTS	
FROM                 	
    pat_personal_main    ntss_db6_ppm   	
WHERE	
    ntss_db6_ppm.is_del = ''0'' 	
    AND ntss_db6_ppm.facility_cd = @facilityCd	
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2131, 'SELECT                	
    ntss_db5_om.pat_id	
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日	
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号	
    ,row_number() over(order by ntss_db5_os.treat_date desc)	
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時	
    ,ntss_db5_mm.in_hospital_cd_1 AS MEDICINE_CD --薬剤コード(院内コード1)	
    ,ntss_db5_mm.in_hospital_cd_2 AS MEDICINE_CD2 --薬剤コード(院内コード2)	
    ,ntss_db5_om.rst_medi_info ->> ''name'' AS MEDICINE_NAME --薬剤名	
    ,ntss_db5_om.rst_medi_info ->> ''class_name'' AS MEDICINE_CLASS_NAME --薬剤分類名	
    ,ntss_db5_om.rst_medi_info ->> ''amount'' AS AMOUNT --数量	
    ,ntss_db5_om.rst_medi_info ->> ''unit'' AS UNIT --単位	
    ,ntss_db5_om.rst_medi_info ->> ''effect_flg'' AS EFFECT_FLG --実施フラグ	
    ,ntss_db5_om.rst_medi_info ->> ''effect_date'' AS EFFECT_DATE --実施日時	
    ,ntss_db5_om.rst_medi_info ->> ''timing_name'' AS TIMING_NAME --投与時間帯名	
    ,ntss_db5_mm.in_hospital_cd_1 AS PROCEDURE_CD --手技コード(院内コード1)	
    ,ntss_db5_mm.in_hospital_cd_2 AS PROCEDURE_CD2 --手技コード(院内コード2)	
    ,ntss_db5_om.rst_medi_info ->> ''procedure_name'' AS PROCEDURE_NAME --手技名	
    ,ntss_db5_om.rst_medi_info ->> ''effect_user_id'' AS STAFF_CD --実施者コード	
    ,ntss_db5_om.rst_medi_info ->> ''effect_user_last_name'' || '' '' || ''effect_user_first_name'' AS STAFF_NAME --実施者名	
    ,ntss_db5_om.rst_medi_info ->> ''comment'' AS COMMENTS --コメント	
FROM                 	
    ord_main ntss_db5_om   	
INNER JOIN 	
    ord_schedule ntss_db5_os	
ON	
    ntss_db5_om.pat_id = ntss_db5_os.pat_id	
INNER JOIN 	
    mst_medicine ntss_db5_mm	
ON	
    ntss_db5_om.rst_medi_info ->> ''cd'' = cast(ntss_db5_mm.medicine_cd as character varying)	
WHERE	
    ntss_db5_om.is_del = ''0'' 	
    AND ntss_db5_om.facility_cd = @facilityCd 	
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 	
    AND to_date( @toDate, ''YYYYMMDD'' )	
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2140, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS MEDICINE_CD
    ,NULL AS MEDICINE_CD2
    ,NULL AS MEDICINE_NAME
    ,NULL AS MED_GENERAL_NAME
    ,NULL AS MEDICINE_CLASS_NAME
    ,NULL AS AMOUNT
    ,NULL AS UNIT
    ,NULL AS EFFECT_FLG
    ,NULL AS EFFECT_DATE
    ,NULL AS TIMING_NAME
    ,NULL AS PROCEDURE_CD
    ,NULL AS PROCEDURE_CD2
    ,NULL AS PROCEDURE_NAME
    ,NULL AS STAFF_CD
    ,NULL AS STAFF_NAME
    ,NULL AS COMMENTS
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2141, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号
    ,row_number() over(order by ntss_db5_os.treat_date desc)
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_om.rst_medi_info -> ''治療条件項目番号'' ->> ''value'' AS MEDICINE_CD --薬剤コード
    ,ntss_db5_mm.in_hospital_cd_1 AS MEDICINE_CD --薬剤コード(院内コード1)
    ,ntss_db5_om.rst_medi_info ->> ''name'' AS MEDICINE_NAME --薬剤名
    ,ntss_db5_om.rst_medi_info ->> ''class_name'' AS MEDICINE_CLASS_NAME --薬剤分類名
    ,ntss_db5_om.rst_medi_info ->> ''amount'' AS AMOUNT --数量
    ,ntss_db5_om.rst_medi_info ->> ''unit'' AS UNIT --単位
    ,ntss_db5_om.rst_medi_info ->> ''effect_flg'' AS EFFECT_FLG --実施フラグ
    ,to_char(to_timestamp(ntss_db5_om.rst_medi_info ->> ''date'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS EFFECT_DATE --実施日時
    ,ntss_db5_om.rst_medi_info ->> ''timing_name'' AS TIMING_NAME --投与時間帯名
    ,ntss_db5_mm.in_hospital_cd_1 AS PROCEDURE_CD --手技コード(院内コード1)
    ,ntss_db5_mm.in_hospital_cd_2 AS PROCEDURE_CD2 --手技コード(院内コード2)
    ,ntss_db5_om.rst_medi_info ->> ''procedure_name'' AS PROCEDURE_NAME --手技名
    ,ntss_db5_om.rst_medi_info ->> ''effect_user_id'' AS STAFF_CD --実施者コード
    ,ntss_db5_om.rst_medi_info ->> ''effect_user_last_name'' || '' '' || ''effect_user_first_name'' AS STAFF_NAME --実施者名
    ,ntss_db5_om.rst_medi_info ->> ''comment'' AS COMMENTS --コメント
FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
INNER JOIN 
    mst_medicine ntss_db5_mm
ON
    ntss_db5_om.rst_medi_info ->> ''cd'' = cast(ntss_db5_mm.medicine_cd as character varying)
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2150, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id,
    ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS EFFECT_FLG
    ,NULL AS EFFECT_DATE
    ,NULL AS ADDITION
    ,NULL AS STAFF_CD
    ,NULL AS STAFF_NAME

FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2151, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号
    ,row_number() over(order by ntss_db5_os.treat_date desc)
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,''0'' AS EFFECT_FLG --実施フラグ

    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS EFFECT_DATE--更新日時
    ,ntss_db5_om.rst_ind_comment_info ->> ''content'' AS ADDITION --補足指示内容
    ,ntss_db5_om.pat_id AS STAFF_CD --実施者コード
    ,ntss_db5_om.rst_ind_comment_info ->> ''upd_user_last_name'' || '' '' || ''upd_user_first_name'' AS STAFF_NAME --実施者名

FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id

WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2160, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS DIVISION
    ,NULL AS CODE
    ,NULL AS CODE_UPDATE
    ,NULL AS ADD_FLG
    ,NULL AS ITEM_NAME
    ,NULL AS MAIN_DIAL_DIFF
    ,NULL AS IN_HOSPITAL_CD
    ,NULL AS IN_HOSPITAL_CD2
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2170, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS BED_NO
    ,NULL AS BED_NAME
    ,NULL AS KUR_CD
    ,NULL AS KUR_NAME
    ,NULL AS PLURAL
    ,NULL AS UP_DATE
    ,NULL AS RESULT_DIALYSISNO
    ,NULL AS OPE_IND_PLAN
    ,NULL AS DUMMY_FLG
    ,NULL AS START_TIME

FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2171, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_om.ord_no AS BED_NO --ベッド番号
    ,ntss_db5_mb.bed_name AS BED_NAME --ベッド名
    ,ntss_db5_mk.in_hospital_cd_1 As KUR_CD --クールコード
    ,ntss_db5_om.rst_kur_name AS KUR_NAME --KUR_NAME
    ,''1'' AS PLURAL --同日複数回
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_om.ord_no AS RESULT_DIALYSISNO --実績透析番号
    ,CASE
        WHEN ntss_db5_om.treat_type = ''0'' THEN ''1''
        ELSE ''0''
    END AS  OPE_IND_PLAN --予定作成区分
    ,ntss_db5_os.is_dummy AS DUMMY_FLG --ダミーフラグ
    ,ntss_db5_om.rst_start_date AS START_TIME --透析開始時刻
FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
INNER JOIN 
    mst_bed ntss_db5_mb
ON
    ntss_db5_om.ind_bed_cd = ntss_db5_mb.bed_cd
INNER JOIN 
    mst_kur ntss_db5_mk
ON
    ntss_db5_om.ind_kur_cd = ntss_db5_mk.kur_cd

WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2180, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS BED_NO
    ,NULL AS BED_NAME
    ,NULL AS KUR_CD
    ,NULL AS KUR_NAME
    ,NULL AS PLURAL
    ,NULL AS UP_DATE
    ,NULL AS RESULT_DIALYSISNO
    ,NULL AS OPE_IND_PLAN
    ,NULL AS DUMMY_FLG
    ,NULL AS START_TIME
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2181, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_mb.in_hospital_cd_1 AS BED_NO --ベッド番号
    ,ntss_db5_mb.bed_name AS BED_NAME --ベッド名
    ,ntss_db5_mk.in_hospital_cd_1 As KUR_CD --クールコード
    ,ntss_db5_mk.kur_name AS KUR_NAME --KUR_NAME
    ,ntss_db5_os.treat_date AS PLURAL --同日複数回
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_om.ord_no AS RESULT_DIALYSISNO --実績透析番号
    ,CASE
        WHEN ntss_db5_om.treat_type = ''0'' THEN ''1''
        ELSE ''0''
    END AS  OPE_IND_PLAN --予定作成区分
    ,ntss_db5_os.is_dummy AS DUMMY_FLG --ダミーフラグ
    ,ntss_db5_om.rst_start_date AS START_TIME --透析開始時刻
FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
INNER JOIN 
    mst_bed ntss_db5_mb
ON
    ntss_db5_om.ind_bed_cd = ntss_db5_mb.bed_cd
INNER JOIN 
    mst_kur ntss_db5_mk
ON
    ntss_db5_om.ind_kur_cd = ntss_db5_mk.kur_cd
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2190, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS PLURAL
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS DIALYSIS_ITEM_NAME
    ,NULL AS VALUE
    ,NULL AS VALUE_NAME
    ,NULL AS UNIT
    ,NULL AS VALUE_CD2
    ,NULL AS INDICATOR_CD
    ,NULL AS OPE_IND_PLAN
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2191, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,''1'' AS PLURAL --同日複数回
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_om.ind_cond_info -> ''治療条件項目番号'' ->> ''value'' AS VALUE --設定値
    ,ntss_db5_om.ind_cond_info -> ''治療条件項目番号'' ->> ''value_name_1'' AS VALUE_NAME --名称
    ,ntss_db5_om.ind_cond_info -> ''治療条件項目番号'' ->> ''unit'' AS UNIT --単位
    ,CASE
        WHEN ntss_db5_om.treat_type = ''0'' THEN ''1''
        ELSE ''0''
    END AS  OPE_IND_PLAN --予定作成区分
    
FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2200, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS PLURAL
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS EQUIP_CD
    ,NULL AS EQUIP_CD2
    ,NULL AS EQUIP_CLASS_NAME
    ,NULL AS EQUIP_NAME
    ,NULL AS PUNCTURE_CLASS
    ,NULL AS AMOUNT
    ,NULL AS UNIT
    ,NULL AS COMMENTS
    ,NULL AS INDICATOR_CD
    ,NULL AS OPE_IND_PLAN
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2201, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,''1'' AS PLURAL --同日複数回
    ,row_number() over(order by ntss_db5_os.treat_date desc)
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_me.in_hospital_cd_1 AS EQUIP_CD --医療材料コード(院内コード1)
    ,ntss_db5_me.in_hospital_cd_2 AS EQUIP_CD2 --医療材料コード(院内コード2)
    ,ntss_db5_om.ind_equip_info ->> ''class_name'' ||  ntss_db5_me.in_hospital_cd_1 AS EQUIP_CLASS_NAME --医療材料分類名
    ,ntss_db5_om.ind_equip_info ->> ''name'' ||  ntss_db5_me.equipment_name AS EQUIP_NAME --医療材料名
    ,ntss_db5_om.rst_equip_info ->> ''amount'' AS AMOUNT --数量
    ,ntss_db5_om.rst_equip_info ->> ''unit'' AS UNIT --単位
    ,ntss_db5_om.rst_equip_info ->> ''comment'' AS COMMENTS --コメント
    ,ntss_db5_om.rst_equip_info ->> ''ind_user_id'' AS INDICATOR_CD --指示者
    ,CASE
        WHEN ntss_db5_om.treat_type = ''0'' THEN ''1''
        ELSE ''0''
    END AS  OPE_IND_PLAN --予定作成区分

FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
INNER JOIN 
    mst_equipment ntss_db5_me
ON
    ntss_db5_om.rst_equip_info ->> ''cd'' = cast(ntss_db5_me.equipment_cd as character varying)
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2210, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS PLURAL
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS MEDICINE_CD
    ,NULL AS MEDICINE_CD2
    ,NULL AS MEDICINE_NAME
    ,NULL AS MEDI_CLASS_NAME
    ,NULL AS AMOUNT
    ,NULL AS UNIT
    ,NULL AS TIMING_NAME
    ,NULL AS PROCEDURE_CD
    ,NULL AS PROCEDURE_CD2
    ,NULL AS PROCEDURE_NAME
    ,NULL AS COMMENTS
    ,NULL AS INDICATOR_CD
    ,NULL AS OPE_IND_PLAN
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2211, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,''1'' AS PLURAL --同日複数回
    ,row_number() over(order by ntss_db5_os.treat_date desc)
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_mm.in_hospital_cd_1 AS MEDICINE_CD --薬剤コード(院内コード1)
    ,ntss_db5_mm.in_hospital_cd_2 AS MEDICINE_CD2 --薬剤コード(院内コード2)
    ,ntss_db5_om.rst_medi_info ->> ''name'' AS MEDICINE_NAME --薬剤名
    ,ntss_db5_om.rst_medi_info ->> ''class_name'' AS MEDICINE_CLASS_NAME --薬剤分類名
    ,ntss_db5_om.rst_medi_info ->> ''amount'' AS AMOUNT --数量
    ,ntss_db5_om.rst_medi_info ->> ''unit'' AS UNIT --単位
    ,ntss_db5_om.rst_medi_info ->> ''timing_name'' AS TIMING_NAME --投与時間帯名
    ,ntss_db5_om.rst_medi_info ->> ''procedure_cd'' AS PROCEDURE_CD --手技コード(院内コード1)
    ,ntss_db5_om.rst_medi_info ->> ''procedure_cd'' AS PROCEDURE_CD2 --手技コード(院内コード2)
    ,ntss_db5_om.rst_medi_info ->> ''procedure_name'' AS PROCEDURE_NAME --手技名
    ,ntss_db5_om.rst_medi_info ->> ''comment'' AS COMMENTS --コメント
    ,ntss_db5_om.rst_medi_info ->> ''ind_user_id'' AS INDICATOR_CD --指示者
    ,CASE
        WHEN ntss_db5_om.treat_type = ''0'' THEN ''1''
        ELSE ''0''
    END AS  OPE_IND_PLAN --予定作成区分

FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
INNER JOIN 
    mst_medicine ntss_db5_mm
ON
    ntss_db5_om.rst_medi_info ->> ''cd'' = cast(ntss_db5_mm.medicine_cd as character varying)
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2220, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS PLURAL
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS ADDITION
    ,NULL AS INDICATOR_CD
    ,NULL AS OPE_IND_PLAN
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2221, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,''1'' AS PLURAL --同日複数回
    ,row_number() over(order by ntss_db5_os.treat_date desc)
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_om.ind_ind_comment_info ->> ''content'' AS ADDITION --指示簿指示
    ,ntss_db5_om.rst_medi_info ->> ''ind_user_id'' AS INDICATOR_CD --指示者
    ,CASE
        WHEN ntss_db5_om.treat_type = ''0'' THEN ''1''
        ELSE ''0''
    END AS  OPE_IND_PLAN --予定作成区分

FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2230, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID   
    ,NULL AS PRESCRIPT_NO
    ,NULL AS UP_DATE
    ,NULL AS EXECUTE_DATE
    ,NULL AS CTL_NO
    ,NULL AS MEDICINE_NAME
    ,NULL AS MEDICINE_CD
    ,NULL AS MEDICINE_CD2
    ,NULL AS QUANTITY
    ,NULL AS UNIT
    ,NULL AS DOSAGE
    ,NULL AS TAKE_MEDICINE_CD
    ,NULL AS TAKE_MEDICINE_NAME
    ,NULL AS DAY_COUNT
    ,ntss_db6_opp.insu_dr_id AS PRESCRIPTER_CD --処方者コード
    ,ntss_db6_opp.insu_dr_name AS PRESCRIPTER_NAME --処方者名
    ,ntss_db6_opp.remarks AS NOTE --備考
FROM                 
    pat_personal_main    ntss_db6_ppm   
LEFT JOIN 
    ord_personal_prescription ntss_db6_opp
ON
    ntss_db6_ppm.pat_id = ntss_db6_opp.pat_id
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2231, 'SELECT                
    ntss_db5_op.pat_id
    ,ntss_db5_op.ord_prescription_no AS PRESCRIPT_NO --処方番号
    ,to_char(ntss_db5_op.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_op.issue_date AS EXECUTE_DATE --交付日
    ,ntss_db5_op.prescription_detail ->> ''rp'' AS CTL_NO --項目番号
    ,CASE
        WHEN ntss_db5_op.prescription_detail ->> ''type'' = ''1'' THEN ntss_db5_op.prescription_detail ->> ''f1''
    END AS MEDICINE_NAME --薬剤名
    ,ntss_db5_mm.in_hospital_cd_1 AS MEDICINE_CD --薬剤コード(院内コード1)
    ,ntss_db5_mm.in_hospital_cd_2 AS MEDICINE_CD2 --薬剤コード(院内コード2)
    ,CASE
        WHEN ntss_db5_op.prescription_detail ->> ''type'' = ''1'' THEN ntss_db5_op.prescription_detail ->> ''F5''
    END AS QUANTITY --分量
    ,CASE
        WHEN ntss_db5_op.prescription_detail ->> ''type'' = ''1'' THEN ntss_db5_op.prescription_detail ->> ''F6''
    END AS UNIT --単位
    ,CASE
        WHEN ntss_db5_op.prescription_detail ->> ''type'' in (''2'',''3'',''4'',''5'') THEN ntss_db5_op.prescription_detail ->> ''F5''
    END AS DOSAGE --用量
    ,CASE
        WHEN ntss_db5_op.prescription_detail ->> ''type'' in (''2'',''3'',''4'',''5'') THEN ntss_db5_op.prescription_detail ->> ''F2''
    END AS TAKE_MEDICINE_CD --用法コード
    ,CASE
        WHEN ntss_db5_op.prescription_detail ->> ''type'' in (''2'',''3'',''4'',''5'') THEN ntss_db5_op.prescription_detail ->> ''F2''
    END AS TAKE_MEDICINE_NAME --用法名
    ,CASE
        WHEN ntss_db5_op.prescription_detail ->> ''type'' = ''2'' THEN ntss_db5_op.prescription_detail ->> ''F5''
    END AS DAY_COUNT --調剤日数
    
FROM                 
    ord_prescription ntss_db5_op  
INNER JOIN 
    mst_medicine ntss_db5_mm
ON
    ntss_db5_op.facility_cd = ntss_db5_mm.facility_cd
WHERE
    ntss_db5_op.is_del = ''0'' 
    AND ntss_db5_op.facility_cd = @facilityCd 
    AND ntss_db5_op.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2240, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS START_DATE
    ,NULL AS OCCUR_DATE
    ,NULL AS BP_MAX
    ,NULL AS BP_MIN
    ,NULL AS BP_AVE
    ,NULL AS PULSE
    ,NULL AS TEMPERATURE
    ,NULL AS BLOOD_SUGAR_LEVEL
    ,NULL AS UP_DATE
    ,NULL AS DIADYSIS_NO
    ,NULL AS BP_CLASS
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2241, 'SELECT                
    ntss_db5_om.pat_id
    ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --開始日時
    ,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --発生日時
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''90''
    END AS BP_MAX --最高血圧
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''91''
    END AS BP_MIN --最低血圧
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''92''
    END AS BP_AVE --平均血圧
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''93''
    END AS PULSE --脈拍
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''93''
    END AS TEMPERATURE --体温
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''-1''
    END AS BLOOD_SUGAR_LEVEL --血糖値
    ,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_mm.ord_no AS DIADYSIS_NO --透析番号
    ,ntss_db5_mm.data_type AS BP_CLASS --血圧区分
FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    mni_monitor ntss_db5_mm
ON
    ntss_db5_om.ord_no = ntss_db5_mm.ord_no
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2250, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS OCCUR_DATE
    ,NULL AS MEASURECLASS
    ,NULL AS REQCODE
    ,NULL AS COMPLAINT
    ,NULL AS TREAT_NAME
    ,NULL AS MEDICINE_CD1
    ,NULL AS MEDICINE_CD2
    ,NULL AS MEDICINE_NAME
    ,NULL AS AMOUNT
    ,NULL AS UNIT
    ,NULL AS PROCEDURE_NAME
    ,NULL AS PROCEDURE_CD1
    ,NULL AS PROCEDURE_CD2
    ,NULL AS TREAT_PERSON_NAME
    ,NULL AS UP_DATE
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2251, 'SELECT                
    ntss_db5_om.pat_id
    ,to_char(to_timestamp(ntss_db5_om.rst_complaint_info ->> ''date'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS OCCUR_DATE --発生日時
    ,CASE
        WHEN ntss_db5_om.rst_complaint_info ->> ''medicine_type'' = ''2'' THEN ''0''
        WHEN ntss_db5_om.rst_complaint_info ->> ''medicine_type'' = ''1'' THEN ''1''
        WHEN ntss_db5_om.rst_complaint_info ->> ''medicine_type'' IS NULL THEN ''2''
        WHEN ntss_db5_om.rst_complaint_info ->> ''medicine_type'' = ''3'' THEN ''3''
    END AS MEASURECLASS --区分
    ,ntss_db5_om.rst_complaint_info ->> ''comp_cd'' AS REQCODE --愁訴コード
    ,ntss_db5_om.rst_complaint_info ->> ''complaint'' AS COMPLAINT  --愁訴内容
    ,ntss_db5_om.rst_complaint_info ->> ''treat_name'' AS TREAT_NAME  --処置名
    ,CASE
        WHEN ntss_db5_om.rst_complaint_info ->> ''medicine_type'' = ''2'' THEN ntss_db5_om.rst_complaint_info ->> ''treat_medicine_cd''
        WHEN ntss_db5_om.rst_complaint_info ->> ''medicine_type'' = ''1'' THEN ntss_db5_om.rst_complaint_info ->> ''treat_medicine_cd''
    END AS MEDICINE_CD2 --薬剤コード2
    ,ntss_db5_om.rst_complaint_info ->> ''medicine_name'' AS MEDICINE_NAME  --薬剤名称
    ,ntss_db5_om.rst_complaint_info ->> ''amount'' AS AMOUNT  --数量
    ,ntss_db5_om.rst_complaint_info ->> ''unit'' AS UNIT  --単位
    ,ntss_db5_om.rst_complaint_info ->> ''procedure_name'' AS PROCEDURE_NAME  --手技名
    ,ntss_db5_mp.in_hospital_cd_a1 AS PROCEDURE_CD1 --手技コード1
    ,ntss_db5_mp.in_hospital_cd_a2 AS PROCEDURE_CD2 --手技コード2
    ,ntss_db5_om.rst_treat_staff_info ->> ''treat_staff_name'' AS TREAT_PERSON_NAME  --処置者名
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    mst_procedure ntss_db5_mp
ON
    ntss_db5_om.facility_cd = ntss_db5_mp.facility_cd
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2260, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS CTL_NO
    ,NULL AS REG_DATE
    ,NULL AS INOUT_CD
    ,NULL AS FACILITY_NAME
    ,NULL AS DR_NAME
    ,NULL AS MEMO
    ,NULL AS CODE_NAME
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2261, 'SELECT                
     ntss_db5_pu.pat_id
    ,row_number() over(order by ntss_db5_pu.in_out_visit_history_info ->> ''disp_order'',''ctl_no'' desc) AS ctl_no --項目番号
    ,to_char(ntss_db5_pu.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS REG_DATE --入外歴発生日
    ,ntss_db5_pu.in_out_visit_history_info ->> ''move_in_out'' AS INOUT_CD --転入出区分
    ,ntss_db5_pu.in_out_visit_history_info ->> ''from_facility'' AS FACILITY_NAME --施設名
    ,ntss_db5_pu.in_out_visit_history_info ->> ''from_doctot'' AS DR_NAME --担当医名
    ,ntss_db5_pu.in_out_visit_history_info ->> ''comment'' AS MEMO --コメント
    ,ntss_db5_pu.in_out_visit_history_info ->> ''reason'' AS CODE_NAME --区分名

FROM                 
    pat_unique ntss_db5_pu 

WHERE
    ntss_db5_pu.is_del = ''0'' 
    AND ntss_db5_pu.facility_cd = @facilityCd 
    AND ntss_db5_pu.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2270, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS EXAM_DATE
    ,NULL AS ORDER_CLASS
    ,NULL AS ITEM_UP_DATE
    ,NULL AS EXAM_ITEM_CODE
    ,NULL AS EXAM_ITEM_CODE2
    ,NULL AS EXAM_ITEM_CODE3
    ,NULL AS EXAM_ITEM_NAME
    ,NULL AS EXAM_RST
    ,NULL AS EXAM_CLASS_RST
    ,NULL AS COMMENTS
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2271, 'SELECT                
    ntss_db5_pem.pat_id
    ,to_char(ntss_db5_pem.result_exam_date, ''YYYY-MM-DD hh24:mi:ss'') AS EXAM_DATE --検査日時
    ,ntss_db5_pem.reg_order_class AS ORDER_CLASS --検査区分
    ,to_char(ntss_db5_pem.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS ITEM_UP_DATE --検査結果更新日時
    ,ntss_db5_mei.in_hospital_cd1 AS EXAM_ITEM_CODE --検査項目コード(院内コード1)
    ,ntss_db5_mei.in_hospital_cd2 AS EXAM_ITEM_CODE2 --検査項目コード(院内コード2)
    ,ntss_db5_mei.in_hospital_cd3 AS EXAM_ITEM_CODE3 --検査項目コード(院内コード3)
    ,ntss_db5_pem.exam_result_info ->> ''exam_item_name'' AS EXAM_ITEM_NAME --検査項目名
    ,ntss_db5_pem.exam_result_info ->> ''exam_result'' AS EXAM_RST --検査結果値
    ,ntss_db5_pem.exam_result_info ->> ''hi'' AS EXAM_CLASS_RST --検査結果形態
     ,ntss_db5_pem.exam_result_info ->> ''freememo'' AS COMMENTS --コメント
FROM                 
    pat_exam_main ntss_db5_pem 
INNER JOIN 
    mst_exam_item ntss_db5_mei
ON
    ntss_db5_pem.exam_main_cd = ntss_db5_mei.exam_item_cd
WHERE
    ntss_db5_pem.is_del = ''0'' 
    AND ntss_db5_pem.facility_cd = @facilityCd 
    AND ntss_db5_pem.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2280, 'SELECT                		
    ntss_db6_ppm.pat_id AS pat_id		
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    		
    ,NULL AS UP_DATE		
    ,NULL AS EXAM_DATE		
    ,NULL AS EXAM_TIME		
    ,NULL AS EXAM_SET_CD		
    ,NULL AS EXAM_SET_NAME		
    ,NULL AS EXAM_DIVISION		
    ,NULL AS EXAM_PROC_CD		
    ,NULL AS DOCTOR_CODE		
    ,NULL AS DOCTOR_NAME		
    ,NULL AS ORDER_STAFF		
    ,NULL AS ORDER_NAME		
    ,NULL AS UPDATE_CODE		
    ,NULL AS UPDATE_NAME		
FROM                 		
    pat_personal_main    ntss_db6_ppm   		
WHERE		
    ntss_db6_ppm.is_del = ''0'' 		
    AND ntss_db6_ppm.facility_cd = @facilityCd		
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2281, 'SELECT                					
    ntss_db5_pem.pat_id										
    ,to_char(ntss_db5_pem.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --更新日時   					
    ,to_char(ntss_db5_pem.reg_exam_date, ''YYYYMMDD'') AS EXAM_DATE --検査予定日
    ,ntss_db5_pem.reg_exam_date AS EXAM_TIME --検査予定時刻					
    ,ntss_db5_mei.in_hospital_cd1 AS EXAM_ITEM_CODE --検査項目コード(院内コード1)					
    ,ntss_db5_pem.order_exam_set_info ->> ''set_name'' AS EXAM_SET_NAME --検査セット名称					
    ,ntss_db5_pem.reg_order_class AS EXAM_DIVISION --検査予定区分					
    ,ntss_db5_pem.exam_status AS EXAM_PROC_CD --検査実施予定コード					
    ,ntss_db5_pem.ind_user_id AS DOCTOR_CODE --指示者					
    ,ntss_db5_pem.ind_user_id AS DOCTOR_NAME --指示者名					
    ,ntss_db5_pem.up_staff AS ORDER_STAFF --オーダー入力者					
    ,ntss_db5_pem.up_staff AS ORDER_NAME --オーダ入力者名					
    ,ntss_db5_pem.up_staff AS UPDATE_CODE --更新者					
    ,ntss_db5_pem.up_staff AS UPDATE_NAME --更新者名					
FROM                 					
    pat_exam_main ntss_db5_pem 					
INNER JOIN 					
    mst_exam_item ntss_db5_mei					
ON					
    ntss_db5_pem.exam_main_cd = ntss_db5_mei.exam_item_cd					
WHERE					
    ntss_db5_pem.is_del = ''0'' 					
    AND ntss_db5_pem.facility_cd = @facilityCd 					
    AND ntss_db5_pem.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 					
    AND to_date( @toDate, ''YYYYMMDD'' )					
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2291, 'SELECT           				
    ntss_db5_mws.survey_data ->> ''point_cd'' AS SURVEY_POINT_CD --調査箇所コード    					
    ,ntss_db5_mwsp.point_name AS SURVEY_POINT_NAME --調査箇所名					
    ,to_char(ntss_db5_mws.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --更新日時   					
    ,to_char(ntss_db5_mws.inspection_date, ''YYYYMMDD'') AS CHECK_DATE --調査日   					
    ,ntss_db5_mws.survey_data ->> ''value'' AS RESULT --調査結果値					
    ,ntss_db5_mws.survey_data ->> ''unit'' AS UNIT --単位					
FROM                 					
    mnt_water_survey ntss_db5_mws					
INNER JOIN 					
    mst_water_survey_point ntss_db5_mwsp					
ON					
    ntss_db5_mws.survey_record_no = ntss_db5_mwsp.survey_point_cd					
WHERE					
    ntss_db5_mws.is_del = ''0'' 					
    AND ntss_db5_mws.facility_cd = @facilityCd 					
    AND ntss_db5_mws.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 					
    AND to_date( @toDate, ''YYYYMMDD'' )					
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2300, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_TIME
    ,NULL AS START_PLAN_DATE
    ,NULL AS ENTER_FLG
    ,NULL AS ENTER_DATE
    ,NULL AS MACHINE_CHECK_FLG
    ,NULL AS MACHINE_CHECK_DATE
    ,NULL AS DIALSIS_START_FLG
    ,NULL AS DIALSIS_START_DATE
    ,NULL AS OFFWATER_FLG
    ,NULL AS OFFWATER_DATE
    ,NULL AS WASTE_FLUID_FLG
    ,NULL AS WASTE_FLUID_DATE
    ,NULL AS WEIGHT_AFTER_FLG
    ,NULL AS WEIGHT_AFTER_DATE
    ,NULL AS RECOVERY_BTN_FLG
    ,NULL AS RECOVERY_BTN_DATE
    ,NULL AS UP_DATE
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2301, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_om.treat_date AS DIALYSIS_DATE --透析日 
    ,to_char(ntss_db5_om.rst_start_date, ''hh24miss'') AS DIALYSIS_TIME --透析開始時刻
    ,CASE
        WHEN ntss_db5_om.rst_dialysis_state IN (''0'',''1'',''2'') THEN ntss_db5_om.ind_treat_start_time
        WHEN ntss_db5_om.rst_dialysis_state IN (''3'',''4'',''5'',''6'') THEN ntss_db5_om.ind_treat_start_time
    END AS START_PLAN_DATE --予定開始日時
    ,CASE
        WHEN ntss_db5_om.rst_cond_send_date IS NULL THEN ''0''
        ELSE ''1''
    END AS ENTER_FLG --入室フラグ（前体重測定） 
    ,to_char(ntss_db5_om.rst_cond_send_date, ''YYYY-MM-DD hh24:mi:ss'') AS ENTER_DATE --初回入室日時
    ,to_char(ntss_db5_mmr.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS MACHINE_CHECK_DATE --透析装置確認日時
    ,CASE
        WHEN ntss_db5_om.rst_start_date IS NULL THEN ''0''
        ELSE ''1''
    END AS DIALSIS_START_FLG --透析運転開始フラグ
    ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS DIALSIS_START_DATE --透析運転開始日時
    ,to_char(ntss_db5_mmr.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS OFFWATER_DATE --除水完了日時
    ,CASE
        WHEN ntss_db5_om.rst_end_date IS NULL THEN ''0''
        ELSE ''1''
    END AS WASTE_FLUID_FLG --排液フラグ
    ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS WASTE_FLUID_DATE --排液日時
    ,CASE
        WHEN ntss_db5_om.rst_weight_info ->> ''weight_after_date'' IS NULL THEN ''0''
        ELSE ''1''
    END AS WEIGHT_AFTER_FLG --後体重測定
    ,to_char(to_timestamp(ntss_db5_om.rst_weight_info ->> ''date'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS WEIGHT_AFTER_DATE --後体重測定日時
    ,CASE
        WHEN ntss_db5_om.rec_set_date  IS NULL THEN ''0''
        ELSE ''1''
    END AS RECOVERY_BTN_FLG --準備回収確認ボタンフラグ
    ,to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'') AS RECOVERY_BTN_DATE --準備回収確認ボタン日時
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --最終更新日時
FROM                 
    ord_main ntss_db5_om   

INNER JOIN 
    mnt_motion_record ntss_db5_mmr
ON
    ntss_db5_om.facility_cd = ntss_db5_mmr.facility_cd
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2310, '    SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS UP_DATE
    ,ntss_db6_ppm.pat_last_name || '''' || ntss_db6_ppm.pat_first_name AS NAME --氏名
    ,ntss_db6_ppm.pat_last_name_kana || '''' || ntss_db6_ppm.pat_first_name_kana AS NAME_KANA --患者名(かな）
    ,NULL AS REG_DATE
    ,NULL AS REG_TIME
    ,NULL AS KIND_ID
    ,NULL AS KIND_NAME
    ,NULL AS STAFF_CD
    ,NULL AS STAFF_NAME
    ,NULL AS EDIT_CD
    ,NULL AS EDIT_NAME
    ,NULL AS DETAIL1
    ,NULL AS DETAIL2
    ,NULL AS DETAIL3
    ,NULL AS DETAIL4
    FROM                 
        pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2311, '    SELECT                
    ntss_db5_pe.pat_id
        ,to_char(ntss_db5_pe.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --更新日時
        ,ntss_db5_pe.reg_date AS REG_DATE --起票日
        ,ntss_db5_pe.reg_date AS REG_TIME --起票時刻
        ,ntss_db5_pe.sub_category_cd AS KIND_ID --種別ID
        ,ntss_db5_pe.sub_category_name AS KIND_NAME --種別名
        ,ntss_db5_pe.reg_staff_info ->> ''reg_staff_cd'' --起票者ID
        ,ntss_db5_pe.reg_staff_info ->> ''reg_staff_name'' --起票者名
        ,ntss_db5_pe.reg_staff_info ->> ''reg_staff_cd'' --編集者ID
        ,ntss_db5_pe.reg_staff_info ->> ''reg_staff_name'' --編集者名
    FROM                 
        pat_event    ntss_db5_pe  
    WHERE
        ntss_db5_pe.is_del = ''0'' 
        AND ntss_db5_pe.facility_cd = @facilityCd 
        AND ntss_db5_pe.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
        AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2320, '    SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,ntss_db6_ppm.pat_last_name || '''' || ntss_db6_ppm.pat_first_name AS NAME --氏名
    ,ntss_db6_ppm.pat_last_name_kana || '''' || ntss_db6_ppm.pat_first_name_kana AS NAME_KANA --患者名(かな）
    ,NULL AS CTL_NO
    ,NULL AS TITLE
    ,NULL AS CONTENT
        
    FROM                 
        pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2321, '    SELECT                
    ntss_db5_pm.pat_id
        ,ntss_db5_pm.pat_memo_info ->> ''ctl_no'' AS CTL_NO --管理番号
        ,ntss_db5_pm.pat_memo_info ->> ''title'' AS TITLE --タイトル
        ,ntss_db5_pm.pat_memo_info ->> ''content'' AS CONTENT --内容
        
    FROM                 
        pat_main    ntss_db5_pm  
    WHERE
        ntss_db5_pm.is_del = ''0'' 
        AND ntss_db5_pm.facility_cd = @facilityCd 
        AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
        AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2330, 'SELECT                		
    ntss_db6_ppm.pat_id AS pat_id,		
    ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    		
		,personal_info_decrypt ( ntss_db6_ppm.pat_last_name ) || '' '' || personal_info_decrypt ( ntss_db6_ppm.pat_first_name ) AS NAME--氏名
		,NULL AS DIALYSIS_DATE
		,NULL AS DIALYSIS_NO
		,NULL AS UP_DATE
		,NULL AS BED_NO
		,NULL AS BED_NAME
		,NULL AS DEVICE_NO
		,NULL AS DEVICE_NAME
		,NULL AS KUR_CD
		,NULL AS KUR_NAME
		,NULL AS START_DATE
		,NULL AS END_DATE
		,NULL AS DIALYSIS_TIME
		,NULL AS PLAN_DIALYSIS_TIME
		,NULL AS DIALYSIS_NUM
		,NULL AS LAST_WEIGHT
		,NULL AS WEIGHT_BEFORE
		,NULL AS WEIGHT_AFTER
		,NULL AS BP_BEFORE_MAX
		,NULL AS BP_BEFORE_MIN
		,NULL AS BP_BEFORE_AVE
		,NULL AS BP_AFTER_MAX
		,NULL AS BP_AFTER_MIN
		,NULL AS BP_AFTER_AVE
		,NULL AS WATER_REMOVAL_TARGET
		,NULL AS REVISE_NAME1
		,NULL AS REVISE_WEIGHT1
		,NULL AS REVISE_NAME2
		,NULL AS REVISE_WEIGHT2
		,NULL AS REVISE_NAME3
		,NULL AS REVISE_WEIGHT3
		,NULL AS REVISE_NAME4
		,NULL AS REVISE_WEIGHT4
		,NULL AS REVISE_NAME5
		,NULL AS REVISE_WEIGHT5
		,NULL AS PULSE_BEFORE
		,NULL AS PULSE_AFTER
		,NULL AS CHARGE_1_NAME
		,NULL AS CHARGE_2_NAME
		,NULL AS CHARGE_DATE_1
		,NULL AS CHARGE_DATE_2
		,NULL AS PUNCTURE_1_NAME
		,NULL AS PUNCTURE_2_NAME
		,NULL AS PUNCTURE_DATE_1
		,NULL AS PUNCTURE_DATE_2
		,NULL AS COLLECT_1_NAME
		,NULL AS COLLECT_2_NAME
		,NULL AS COLLECT_DATE_1
		,NULL AS COLLECT_DATE_2
		,NULL AS INOUT_FLG
		,NULL AS KT_V_MEASURE
		,NULL AS URR
		,NULL AS RE_LOOP_RATE
		,NULL AS PULL_LEAVE_AMOUNT
		,NULL AS ADD_TOTL
		,NULL AS STATIC_VENOUS_PRESSURE
		,NULL AS VENOUS_ACCESS_PRESSURE_RATIO

FROM                 		
    pat_personal_main    ntss_db6_ppm   		
WHERE		
    ntss_db6_ppm.is_del = ''0'' 		
    AND ntss_db6_ppm.facility_cd = @facilityCd		
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2331, 'SELECT                	
    ntss_db5_om.pat_id,	
    ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日	
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号	
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時	
    ,ntss_db5_mb.in_hospital_cd_1 AS BED_NO --ベッド番号	
    ,ntss_db5_mb.bed_name AS BED_NAME --ベッド名	
    ,ntss_db5_om.rst_machine_no AS DEVICE_NO --装置番号	
    ,ntss_db5_om.rst_machine_name AS DEVICE_NAME --装置名	
    ,ntss_db5_om.rst_kur_cd AS KUR_CD --クール	
    ,ntss_db5_om.rst_kur_name AS KUR_NAME --クール名	
    ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'')AS START_DATE --透析開始日時	
    ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'')AS END_DATE --透析終了日時	
    ,to_char(ntss_db5_om.rst_end_date - ntss_db5_om.rst_start_date, ''hh24mi'')AS DIALYSIS_TIME --透析時間	
    ,ntss_db5_om.rst_cond_info -> ''1'' ->> ''value'' AS PLAN_DIALYSIS_TIME --予定透析時間	
	
    ,ntss_db5_om.rst_dialysis_cnt AS DIALYSIS_NUM --透析回数	
    ,ntss_db5_om.rst_weight_info ->> ''weight_before'' AS WEIGHT_BEFORE --前体重 	
    ,ntss_db5_om.rst_weight_info ->> ''weight_after'' AS WEIGHT_AFTER --後体重	
    ,CASE 	
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''1'' THEN ntss_db5_om.rst_vital_info ->> ''bp_max''	
    END AS BP_BEFORE_MAX --透析前最高血圧	
    ,CASE 	
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''1'' THEN ntss_db5_om.rst_vital_info ->> ''bp_min''	
    END AS BP_BEFORE_MIN --透析前最低血圧	
    ,CASE 	
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''1'' THEN ntss_db5_om.rst_vital_info ->> ''bp_ave''	
    END AS BP_BEFORE_AVE --透析前平均血圧	
    ,CASE 	
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''2'' THEN ntss_db5_om.rst_vital_info ->> ''bp_max''	
    END AS BP_BEFORE_MAX --透析後最高血圧	
    ,CASE 	
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''2'' THEN ntss_db5_om.rst_vital_info ->> ''bp_min''	
    END AS BP_BEFORE_MIN --透析後最低血圧	
    ,CASE 	
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''2'' THEN ntss_db5_om.rst_vital_info ->> ''bp_ave''	
    END AS BP_BEFORE_AVE --透析後平均血圧	
    ,ntss_db5_om.rst_weight_info ->> ''water_removal_target'' AS WATER_REMOVAL_TARGET --目標除水量	
    ,ntss_db5_om.rst_off_water_info ->> ''name_1'' AS REVISE_NAME1 --除水補正項目１	
    ,ntss_db5_om.rst_off_water_info ->> ''weight_1'' AS REVISE_WEIGHT1 --除水補正値１	
    ,ntss_db5_om.rst_off_water_info ->> ''name_2'' AS REVISE_NAME2 --除水補正項目2	
    ,ntss_db5_om.rst_off_water_info ->> ''weight_2'' AS REVISE_WEIGHT2 --除水補正値2    	
    ,ntss_db5_om.rst_off_water_info ->> ''name_3'' AS REVISE_NAME3 --除水補正項目3	
    ,ntss_db5_om.rst_off_water_info ->> ''weight_3'' AS REVISE_WEIGHT3 --除水補正値3 	
    ,ntss_db5_om.rst_off_water_info ->> ''name_4'' AS REVISE_NAME4 --除水補正項目4	
    ,ntss_db5_om.rst_off_water_info ->> ''weight_4'' AS REVISE_WEIGHT4 --除水補正値4 	
    ,ntss_db5_om.rst_off_water_info ->> ''name_5'' AS REVISE_NAME5 --除水補正項目5	
    ,ntss_db5_om.rst_off_water_info ->> ''weight_5'' AS REVISE_WEIGHT5 --除水補正値5    	
    ,CASE 	
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''1'' THEN ntss_db5_om.rst_vital_info ->> ''pulse''	
    END AS PULSE_BEFORE --透析前脈拍	
    ,CASE 	
        WHEN ntss_db5_om.rst_vital_info ->> ''bp_class'' = ''2'' THEN ntss_db5_om.rst_vital_info ->> ''pulse''	
    END AS PULSE_AFTER --透析後脈拍	
    ,ntss_db5_om.rst_charge_user_info ->> ''user_last_name_1'' || '' '' || ''user_first_name_1'' AS CHARGE_1_NAME --担当者１	
    ,ntss_db5_om.rst_charge_user_info ->> ''user_last_name_2'' || '' '' || ''user_first_name_2'' AS CHARGE_2_NAME --担当者2	
    ,to_char(to_timestamp(ntss_db5_om.rst_charge_user_info ->> ''date_1'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS CHARGE_DATE_1 -- 担当日時１	
    ,to_char(to_timestamp(ntss_db5_om.rst_charge_user_info ->> ''date_2'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS CHARGE_DATE_2 -- 担当日時１	
    ,ntss_db5_om.rst_puncture_user_info ->> ''user_last_name_1'' || '' '' || ''user_first_name_1'' AS PUNCTURE_1_NAME -- 穿刺者１	
    ,ntss_db5_om.rst_puncture_user_info ->> ''user_last_name_2'' || '' '' || ''user_first_name_2'' AS PUNCTURE_2_NAME -- 穿刺者２	
    ,to_char(to_timestamp(ntss_db5_om.rst_puncture_user_info ->> ''date_1'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS PUNCTURE_DATE_1 -- 穿刺日時1	
    ,to_char(to_timestamp(ntss_db5_om.rst_puncture_user_info ->> ''date_2'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS PUNCTURE_DATE_2 -- 穿刺日時２	
    ,ntss_db5_om.rst_return_user_info ->> ''user_last_name_1'' || '' '' || ''user_first_name_1'' AS COLLECT_1_NAME -- 回収者１	
    ,ntss_db5_om.rst_return_user_info ->> ''user_last_name_2'' || '' '' || ''user_first_name_2'' AS COLLECT_2_NAME -- 回収者２	
    ,to_char(to_timestamp(ntss_db5_om.rst_return_user_info ->> ''date_1'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS COLLECT_DATE_1 -- 回収日時１	
    ,to_char(to_timestamp(ntss_db5_om.rst_return_user_info ->> ''date_2'',''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') AS COLLECT_DATE_2 -- 回収日時2	
    ,ntss_db5_om.rst_in_out_class AS INOUT_FLG --入外	
    ,ntss_db5_om.rst_kt_v AS KT_V_MEASURE --Kt/v測定値	
    ,ntss_db5_om.rst_weight_info ->> ''urr'' AS URR --URR	
    ,ntss_db5_om.rst_weight_info ->> ''recrcl_rt'' AS RE_LOOP_RATE --再循環率	
    ,ntss_db5_om.rst_weight_info ->> ''ihdf_pll'' AS PULL_LEAVE_AMOUNT --I-HDF引き残し量	
    ,ntss_db5_om.rst_weight_info ->> ''add_total'' AS ADD_TOTL --除水積算値	
    ,ntss_db5_om.rst_weight_info ->> ''sttc_vns_prssr'' AS STATIC_VENOUS_PRESSURE --静的静脈圧	
    ,ntss_db5_om.rst_weight_info ->> ''.iap_rt'' AS VENOUS_ACCESS_PRESSURE_RATIO --IAP ratio	
    	
FROM                 	
    ord_main ntss_db5_om   	
	
INNER JOIN 	
    ord_schedule ntss_db5_os	
ON	
    ntss_db5_om.pat_id = ntss_db5_os.pat_id	
INNER JOIN	
    mst_bed ntss_db5_mb	
ON	
    ntss_db5_om.facility_cd = ntss_db5_mb.facility_cd	
	
WHERE	
    ntss_db5_om.is_del = ''0'' 	
    AND ntss_db5_om.facility_cd = @facilityCd 	
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 	
    AND to_date( @toDate, ''YYYYMMDD'' )	
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2340, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS DIALYSIS_ITEM_NAME
    ,NULL AS VALUE
    ,NULL AS VALUE_NAME
    ,NULL AS UNIT
    ,NULL AS VALUE_CD1

FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2341, 'SELECT                		
    ntss_db5_om.pat_id,		
    ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日		
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号		
		,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時	
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value'' AS VALUE --設定値		
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value_name_1'' AS VALUE_NAME --名称		
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''unit'' AS UNIT --単位		
    ,ntss_db5_om.rst_cond_info -> ''治療条件項目番号'' ->> ''value'' AS VALUE_CD2 --院内コード2		
FROM                 		
    ord_main ntss_db5_om   		
		
INNER JOIN 		
    ord_schedule ntss_db5_os		
ON		
    ntss_db5_om.pat_id = ntss_db5_os.pat_id		
WHERE		
    ntss_db5_om.is_del = ''0'' 		
    AND ntss_db5_om.facility_cd = @facilityCd 		
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 		
    AND to_date( @toDate, ''YYYYMMDD'' )		
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2350, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS EQUIP_CD
    ,NULL AS EQUIP_CD2
    ,NULL AS EQUIP_NAME
    ,NULL AS EQUIP_CLASS_NAME
    ,NULL AS PUNCTURE_CLASS
    ,NULL AS AMOUNT
    ,NULL AS UNIT
    ,NULL AS COMMENTS
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2351, 'SELECT                
    ntss_db5_om.pat_id,
    ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号
    ,row_number() over(order by ntss_db5_os.treat_date desc)
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_me.in_hospital_cd_1 AS EQUIP_CD --医療材料コード(院内コード1)
    ,ntss_db5_me.in_hospital_cd_2 AS EQUIP_CD2 --医療材料コード(院内コード1)
    ,ntss_db5_om.rst_equip_info ->> ''name'' AS EQUIP_NAME --医療材料名
    ,ntss_db5_om.rst_equip_info ->> ''class_name'' AS EQUIP_CLASS_NAME --医療材料分類名
    ,ntss_db5_om.rst_equip_info ->> ''needle_type'' AS PUNCTURE_CLASS --穿刺針区分
    ,ntss_db5_om.rst_equip_info ->> ''amount'' AS AMOUNT --数量
    ,ntss_db5_om.rst_equip_info ->> ''unit'' AS UNIT --単位
    ,ntss_db5_om.rst_equip_info ->> ''comment'' AS COMMENTS --コメント
    
FROM                 
    ord_main ntss_db5_om   

INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id
INNER JOIN 
    mst_equipment ntss_db5_me
ON
    ntss_db5_om.rst_equip_info ->> ''cd'' = cast(ntss_db5_me.equipment_cd as character varying)
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2360, 'SELECT                	
    ntss_db6_ppm.pat_id AS pat_id	
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    	
    ,NULL AS DIALYSIS_DATE	
    ,NULL AS DIALYSIS_NO	
    ,NULL AS CTL_NO	
    ,NULL AS UP_DATE	
    ,NULL AS MEDICINE_CD	
    ,NULL AS MEDICINE_CD2	
    ,NULL AS MEDICINE_NAME	
    ,NULL AS MEDICINE_CLASS_NAME	
    ,NULL AS AMOUNT	
    ,NULL AS UNIT	
    ,NULL AS EFFECT_FLG	
    ,NULL AS EFFECT_DATE	
    ,NULL AS TIMING_NAME	
    ,NULL AS PROCEDURE_CD	
    ,NULL AS PROCEDURE_CD2	
    ,NULL AS PROCEDURE_NAME	
    ,NULL AS STAFF_CD	
    ,NULL AS STAFF_NAME	
    ,NULL AS COMMENTS	
FROM                 	
    pat_personal_main    ntss_db6_ppm   	
WHERE	
    ntss_db6_ppm.is_del = ''0'' 	
    AND ntss_db6_ppm.facility_cd = @facilityCd	
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2361, 'SELECT                	
    ntss_db5_om.pat_id	
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日	
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号	
    ,row_number() over(order by ntss_db5_os.treat_date desc)	
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時	
    ,ntss_db5_mm.in_hospital_cd_1 AS MEDICINE_CD --薬剤コード(院内コード1)	
    ,ntss_db5_mm.in_hospital_cd_2 AS MEDICINE_CD2 --薬剤コード(院内コード2)	
    ,ntss_db5_om.rst_medi_info ->> ''name'' AS MEDICINE_NAME --薬剤名	
    ,ntss_db5_om.rst_medi_info ->> ''class_name'' AS MEDICINE_CLASS_NAME --薬剤分類名	
    ,ntss_db5_om.rst_medi_info ->> ''amount'' AS AMOUNT --数量	
    ,ntss_db5_om.rst_medi_info ->> ''unit'' AS UNIT --単位	
    ,ntss_db5_om.rst_medi_info ->> ''effect_flg'' AS EFFECT_FLG --実施フラグ	
    ,ntss_db5_om.rst_medi_info ->> ''effect_date'' AS EFFECT_DATE --実施日時	
    ,ntss_db5_om.rst_medi_info ->> ''timing_name'' AS TIMING_NAME --投与時間帯名	
    ,ntss_db5_mm.in_hospital_cd_1 AS PROCEDURE_CD --手技コード(院内コード1)	
    ,ntss_db5_mm.in_hospital_cd_2 AS PROCEDURE_CD2 --手技コード(院内コード2)	
    ,ntss_db5_om.rst_medi_info ->> ''procedure_name'' AS PROCEDURE_NAME --手技名	
    ,ntss_db5_om.rst_medi_info ->> ''effect_user_id'' AS STAFF_CD --実施者コード	
    ,ntss_db5_om.rst_medi_info ->> ''effect_user_last_name'' || '' '' || ''effect_user_first_name'' AS STAFF_NAME --実施者名	
    ,ntss_db5_om.rst_medi_info ->> ''comment'' AS COMMENTS --コメント	
FROM                 	
    ord_main ntss_db5_om   	
INNER JOIN 	
    ord_schedule ntss_db5_os	
ON	
    ntss_db5_om.pat_id = ntss_db5_os.pat_id	
INNER JOIN 	
    mst_medicine ntss_db5_mm	
ON	
    ntss_db5_om.rst_medi_info ->> ''cd'' = cast(ntss_db5_mm.medicine_cd as character varying)	
WHERE	
    ntss_db5_om.is_del = ''0'' 	
    AND ntss_db5_om.facility_cd = @facilityCd 	
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 	
    AND to_date( @toDate, ''YYYYMMDD'' )	
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2370, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id,
    ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS EFFECT_FLG
    ,NULL AS EFFECT_DATE
    ,NULL AS ADDITION
    ,NULL AS STAFF_CD
    ,NULL AS STAFF_NAME

FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2371, 'SELECT                
    ntss_db5_om.pat_id
    ,ntss_db5_os.treat_date AS DIALYSIS_DATE --透析日
    ,ntss_db5_om.ord_no AS DIALYSIS_NO --透析番号
    ,row_number() over(order by ntss_db5_os.treat_date desc)
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,''0'' AS EFFECT_FLG --実施フラグ

    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS EFFECT_DATE--更新日時
    ,ntss_db5_om.rst_ind_comment_info ->> ''content'' AS ADDITION --補足指示内容
    ,ntss_db5_om.pat_id AS STAFF_CD --実施者コード
    ,ntss_db5_om.rst_ind_comment_info ->> ''upd_user_last_name'' || '' '' || ''upd_user_first_name'' AS STAFF_NAME --実施者名

FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    ord_schedule ntss_db5_os
ON
    ntss_db5_om.pat_id = ntss_db5_os.pat_id

WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2380, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS DIALYSIS_DATE
    ,NULL AS DIALYSIS_NO
    ,NULL AS CTL_NO
    ,NULL AS UP_DATE
    ,NULL AS DIVISION
    ,NULL AS CODE
    ,NULL AS CODE_UPDATE
    ,NULL AS ADD_FLG
    ,NULL AS ITEM_NAME
    ,NULL AS MAIN_DIAL_DIFF
    ,NULL AS IN_HOSPITAL_CD
    ,NULL AS IN_HOSPITAL_CD2
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2390, 'SELECT                
    ntss_db6_ppm.pat_id AS pat_id
    ,ntss_db6_ppm.hosp_pat_id AS PATID --患者ID    
    ,NULL AS START_DATE
    ,NULL AS OCCUR_DATE
    ,NULL AS BP_MAX
    ,NULL AS BP_MIN
    ,NULL AS BP_AVE
    ,NULL AS PULSE
    ,NULL AS TEMPERATURE
    ,NULL AS BLOOD_SUGAR_LEVEL
    ,NULL AS UP_DATE
    ,NULL AS DIADYSIS_NO
    ,NULL AS BP_CLASS
FROM                 
    pat_personal_main    ntss_db6_ppm   
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2391, 'SELECT                
    ntss_db5_om.pat_id
    ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --開始日時
    ,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE --発生日時
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''90''
    END AS BP_MAX --最高血圧
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''91''
    END AS BP_MIN --最低血圧
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''92''
    END AS BP_AVE --平均血圧
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''93''
    END AS PULSE --脈拍
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''93''
    END AS TEMPERATURE --体温
    ,CASE
        WHEN ntss_db5_mm.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm.monitor_data ->> ''-1''
    END AS BLOOD_SUGAR_LEVEL --血糖値
    ,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UP_DATE--更新日時
    ,ntss_db5_mm.ord_no AS DIADYSIS_NO --透析番号
    ,ntss_db5_mm.data_type AS BP_CLASS --血圧区分
FROM                 
    ord_main ntss_db5_om   
INNER JOIN 
    mni_monitor ntss_db5_mm
ON
    ntss_db5_om.ord_no = ntss_db5_mm.ord_no
WHERE
    ntss_db5_om.is_del = ''0'' 
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDD'' ) 
    AND to_date( @toDate, ''YYYYMMDD'' )
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["pat_id"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
