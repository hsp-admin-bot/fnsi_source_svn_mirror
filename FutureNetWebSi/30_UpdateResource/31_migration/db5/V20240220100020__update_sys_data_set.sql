DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (9627)
;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9627, 'WITH 
coop_ini_data AS (
  SELECT
    COALESCE(NULLIF(ini_info ->> ''value'', ''''), ini_info ->> ''default_v'') AS value,
    ini_info ->> ''key2'' as key2
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0''
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd''
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''TABOO_CD'' 
),
taboo_allergy_medicine AS (
  SELECT
     medicine_cd AS cd
  FROM
     mst_medicine
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND is_disp = ''1''
    AND CASE (SELECT value FROM coop_ini_data WHERE key2 = ''MEDICINE'')
		WHEN ''1'' THEN in_hospital_cd_1
		WHEN ''2'' THEN in_hospital_cd_2
		ELSE in_hospital_cd_3
		END = ''@tabooAllergyInfo.tabooAllergyCd''
    limit 1
),
taboo_allergy_equipment AS (
  SELECT
     equipment_cd AS cd
  FROM
     mst_equipment
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND is_disp = ''1''
    AND CASE (SELECT value FROM coop_ini_data WHERE key2 = ''EQUIPMENT'')
		WHEN ''1'' THEN in_hospital_cd_1
		WHEN ''2'' THEN in_hospital_cd_2
		ELSE in_hospital_cd_3
		END = ''@tabooAllergyInfo.tabooAllergyCd''
    limit 1
),
taboo_allergy_dialyzer AS (
  SELECT
     dialyzer_cd AS cd
  FROM
     mst_dialyzer
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND is_disp = ''1''
    AND CASE (SELECT value FROM coop_ini_data WHERE key2 = ''DIALYZER'')
		WHEN ''1'' THEN in_hospital_cd_1
		WHEN ''2'' THEN in_hospital_cd_2
		ELSE in_hospital_cd_3
		END = ''@tabooAllergyInfo.tabooAllergyCd''
    limit 1
),

tabooAllergyCdInfo as (
select
	(case
		when (select nullif(cd, null) from taboo_allergy_medicine) is NOT NULL then (select nullif(cd, null) from taboo_allergy_medicine)
		when (select nullif(cd, null) from taboo_allergy_equipment) is NOT NULL then (select nullif(cd, null) from taboo_allergy_equipment)
		when (select nullif(cd, null) from taboo_allergy_dialyzer) is NOT NULL then (select nullif(cd, null) from taboo_allergy_dialyzer)

		else null
	end) as cd
                                 ,
	(case
		when (select nullif(cd, null) from taboo_allergy_medicine) is NOT NULL then ''1''
		when (select nullif(cd, null) from taboo_allergy_equipment) is NOT NULL then ''3''
		when (select nullif(cd, null) from taboo_allergy_dialyzer) is NOT NULL then ''4''
		else ''5''
	end) as type)
   ,
newTabooAllergyInfo as (
select
	''【分類】薬剤アレルギー'' || E''\n'' || (case
		when ''@tabooAllergyInfo.memo'' != ''''
                                                     then ''【内容】'' || ''@tabooAllergyInfo.memo''
		else ''''
	end) ::text as memo
                                  ,
	coalesce(nullif(''@nextCtlNo3'', ''''), ''1'') as ctl_no
                                  ,
	''@tabooAllergyInfo.content''::text as content
                                  ,
	coalesce(nullif(''@nextCtlNo3'', ''''), ''0'') as disp_order
                                  ,
	type ::text as category_class
                                  ,
	cd as taboo_allergy_cd
                                  ,
	''@tabooAllergyInfo.tabooAllergyClass''::text as taboo_allergy_class
from
	tabooAllergyCdInfo)
update
	pat_main
set 
	up_date = CURRENT_TIMESTAMP,
	taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', memo,
                      ''ctl_no'', ctl_no::integer,
                      ''content'', content,
                      ''disp_order'', disp_order::integer,
                      ''category_class'', category_class,
                      ''taboo_allergy_cd'', taboo_allergy_cd,
                      ''taboo_allergy_class'', taboo_allergy_class,
											''new_flag'', 1)
from
	newTabooAllergyInfo
where
	is_del = ''0''
	and pat_id = @patId
	and facility_cd = ''@facilityCd''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)日機装の患者プロファイル(薬剤アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
