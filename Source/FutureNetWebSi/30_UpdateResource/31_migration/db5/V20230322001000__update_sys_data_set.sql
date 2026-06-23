DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (9000, 9001, 9002, 9003, 9004, 9005, 9006, 9007, 9008, 9009, 9010, 9011, 9012, 9013, 9014, 9015);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9000, 'SELECT
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) AS pat_last_name,
  personal_info_decrypt(pat_first_name) AS pat_first_name,
  personal_info_decrypt(pat_last_name_kana) AS pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) AS pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) AS pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) AS pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) AS pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) AS pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) AS pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  personal_info_decrypt_jsonb(pat_contact_info) AS pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) AS other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) AS vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) AS remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) AS remote_monitor_user_pw
FROM
  pat_personal_main
WHERE
  is_del = ''0''
AND
  hosp_pat_id = @hospPatId
AND
  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の患者個人情報を取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9001, 'WITH mediAttr AS (
  SELECT
	  jobj1 
	FROM (
    SELECT
		  jsonb_array_elements(coop_ini_info) AS jobj1 
		FROM
		  mst_coop_ini 
		WHERE
		  facility_cd = ''@facilityCd'') t
WHERE
  jobj1->>''key0'' = ''@key0''
	AND jobj1->>''key1'' = ''FJI_PRESCRIPT''
	AND jobj1->>''key2'' = ''MEDICINE_ATTR''
  AND jobj1->>''value'' like ''%@prescriptionDetail.attr%''
),
medi_hospcode_tbl AS (
  SELECT
	  info ->> ''value'' AS hospCd_val
	FROM
	  mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE
	  facility_cd = ''@facilityCd''
	  AND is_del = ''0''
	  AND info ->> ''key0'' = ''@key0''
	  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	  AND info ->> ''key2'' = ''MEDICINE''
),
medi_disp_tbl AS (
  SELECT
	  info ->> ''value'' AS medi_disp
	FROM
	  mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE
	  facility_cd = ''@facilityCd''
	  AND is_del = ''0''
	  AND info ->> ''key0'' = ''@key0''
	  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	  AND info ->> ''key2'' = ''MST_MEDICINE_DISP_FLG''
),
param_tbl AS (
  SELECT
	  CASE hospCd_val
		WHEN ''1'' THEN
		  ''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode1,
		CASE hospCd_val
		WHEN ''1'' THEN
			NULL
		WHEN ''2'' THEN
			''@prescriptionDetail.code''
		WHEN ''3'' THEN
		  NULL
		WHEN ''4'' THEN
		  NULL
		ELSE
			''@prescriptionDetail.code''
		END AS pCode2,
		CASE hospCd_val
		WHEN ''3'' THEN
			''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode3,
		CASE hospCd_val
		WHEN ''4'' THEN
			''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode4,
		''@prescriptionDetail.unit_name'' AS pUnitName,
		''@prescriptionDetail.name'' AS pName
	FROM
	  medi_hospcode_tbl
)
INSERT INTO mst_medicine(
  facility_cd, 
  in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	unit,
	unit_second,
	medicine_name,
	is_exchange,
	unit_converted_amount,
	unit_converted_amount_second,
	is_disp,
	is_del,
	reg_date,
	up_date
) 
SELECT ''@facilityCd'', pCode1, pCode2, pCode3, pCode4, pUnitName, pUnitName, pName, ''0'', ''1'', ''1'', medi_disp, ''0'', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (
SELECT 1) tmpTbl, medi_disp_tbl, param_tbl
WHERE
 EXISTS(
   SELECT jobj1 FROM mediAttr
 ) 
 AND
 NOT EXISTS(
SELECT medicine_cd, in_hospital_cd_1, in_hospital_cd_2, in_hospital_cd_3, in_hospital_cd_4
FROM mst_medicine, param_tbl
WHERE
 facility_cd = ''@facilityCd''
 AND (in_hospital_cd_1 = pCode1 OR pCode1 IS NULL)
 AND (in_hospital_cd_2 = pCode2 OR pCode2 IS NULL)
 AND (in_hospital_cd_3 = pCode3 OR pCode3 IS NULL)
 AND (in_hospital_cd_4 = pCode4 OR pCode4 IS NULL)
 );', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の薬剤マスタに登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9002, 'WITH tmpTbl_opn AS (
  SELECT @ordPrescriptionNo::integer AS ordPrescriptionNo
)
SELECT
  ord_prescription_no
  , facility_cd
  , pat_id
  , prescription_type
  , issue_date
  , issue_state
  , expiration_date
  , prescription_detail
  , is_disp
  , is_del
  , reg_date
  , up_date 
FROM
  ord_prescription, tmpTbl_opn
WHERE
  is_del = ''0'' 
	AND facility_cd = @facilityCd
  AND ord_prescription_no = tmpTbl_opn.ordPrescriptionNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の処方情報の取得処理', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9003, 'WITH medi_hospcode_tbl AS (
  SELECT
	  info ->> ''value'' AS hospCd_val
	FROM
	  mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE
	  facility_cd = ''999998''
	  AND is_del = ''0''
	  AND info ->> ''key0'' = ''GX''
	  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	  AND info ->> ''key2'' = ''MEDICINE''
),
param_tbl AS (
  SELECT
	  CASE hospCd_val
		WHEN ''1'' THEN
		  @prescriptionDetail.code
		ELSE
		  NULL
		END AS pCode1,
		CASE hospCd_val
		WHEN ''1'' THEN
			NULL
		WHEN ''2'' THEN
			@prescriptionDetail.code
		WHEN ''3'' THEN
		  NULL
		WHEN ''4'' THEN
		  NULL
		ELSE
			@prescriptionDetail.code
		END AS pCode2,
		CASE hospCd_val
		WHEN ''3'' THEN
			@prescriptionDetail.code
		ELSE
		  NULL
		END AS pCode3,
		CASE hospCd_val
		WHEN ''4'' THEN
			@prescriptionDetail.code
		ELSE
		  NULL
		END AS pCode4
	FROM
	  medi_hospcode_tbl
)
SELECT
  medicine_cd,
	medicine_name,
	unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4
FROM
  mst_medicine,
	param_tbl
WHERE
  facility_cd = @facilityCd
	AND (in_hospital_cd_1 = pCode1 OR pCode1 IS NULL)
	AND (in_hospital_cd_2 = pCode2 OR pCode2 IS NULL)
	AND (in_hospital_cd_3 = pCode3 OR pCode3 IS NULL)
	AND (in_hospital_cd_4 = pCode4 OR pCode4 IS NULL)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の薬剤マスタの取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9004, 'DELETE FROM 
  ord_prescription 
WHERE
  ord_prescription_no = @ordPrescriptionNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の処方情報の物理削除', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9005, 'WITH mci_medicine_tbl AS (
  SELECT info ->> ''value'' AS value
	FROM mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE facility_cd = ''@facilityCd''
	AND is_del = ''0''
	AND info ->> ''key0'' = ''@key0''
	AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	AND info ->> ''key2'' = ''MEDICINE_ATTR''
), 
mci_editable_tbl AS (
  SELECT
	  CASE WHEN info ->> ''value'' = ''0'' THEN ''x''
		ELSE ''''
		END AS editable_value
	FROM mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE facility_cd = ''@facilityCd''
	AND is_del = ''0''
	AND info ->> ''key0'' = ''@key0''
	AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	AND info ->> ''key2'' = ''EDITABLE_FLG''
), 
medi_hospcode_tbl AS (
  SELECT
	  info ->> ''value'' AS hospCd_val
	FROM
	  mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE
	  facility_cd = ''@facilityCd''
	  AND is_del = ''0''
	  AND info ->> ''key0'' = ''@key0''
	  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	  AND info ->> ''key2'' = ''MEDICINE''
),
hospital_code_tbl AS (
  SELECT
	  CASE hospCd_val
		WHEN ''1'' THEN
		  ''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode1,
		CASE hospCd_val
		WHEN ''1'' THEN
			NULL
		WHEN ''2'' THEN
			''@prescriptionDetail.code''
		WHEN ''3'' THEN
		  NULL
		WHEN ''4'' THEN
		  NULL
		ELSE
			''@prescriptionDetail.code''
		END AS pCode2,
		CASE hospCd_val
		WHEN ''3'' THEN
			''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode3,
		CASE hospCd_val
		WHEN ''4'' THEN
			''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode4,
		''@prescriptionDetail.unit_name'' AS pUnitName,
		''@prescriptionDetail.name'' AS pName
	FROM
	  medi_hospcode_tbl
),
mst_medicine_tbl AS (
  SELECT
	  medicine_cd AS medi_cd,
		CASE WHEN unit_second IS NULL THEN ''''
		ELSE unit_second
		END AS unit2_name
	FROM
	  mst_medicine
	  , hospital_code_tbl
	WHERE
	  facility_cd = ''@facilityCd''
		AND is_del = ''0''
	  AND (in_hospital_cd_1 = pCode1 OR pCode1 IS NULL)
	  AND (in_hospital_cd_2 = pCode2 OR pCode2 IS NULL)
	  AND (in_hospital_cd_3 = pCode3 OR pCode3 IS NULL)
	  AND (in_hospital_cd_4 = pCode4 OR pCode4 IS NULL)
	ORDER BY
	  medicine_cd
	LIMIT 1
),
mci_directions_tbl AS (
  SELECT
	  info ->> ''value'' AS value
	FROM
	  mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE
	  facility_cd = ''@facilityCd''
	  AND is_del = ''0''
	  AND info ->> ''key0'' = ''@key0''
	  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	  AND info ->> ''key2'' = ''DIRECTIONS_ATTR''
), 
default_directions_tbl AS (
  SELECT
	  split_part(list_details, '','', 1) AS default_directions
	FROM
	  mst_take_medicine
	WHERE
	  facility_cd = ''@facilityCd''
		AND list_class = ''10''
),
quantity_tbl AS (
  SELECT
    CASE WHEN CAST(''@prescriptionDetail.quantity'' AS numeric) > 999999.999 THEN CAST(999999.999 AS numeric)
    ELSE CAST(CAST(''@prescriptionDetail.quantity'' AS numeric) AS numeric(10, 3))
    END AS quantity
),
jo_medicine_tbl AS (
  SELECT
	  json_build_object(''Rp'', ''Rp1'', ''type'', 1, ''F1'', ''@prescriptionDetail.name'', ''F2'', '''', ''F3'', '''', ''F4'', '''', ''F5'', quantity, ''F6'', ''@prescriptionDetail.unit_name'', ''medicine_type'', ''1'', ''medicine_cd'', medi_cd, ''R'', ''@prescriptionDetail.name '', ''unchg'', editable_value, ''medicine_unit1'', ''@prescriptionDetail.unit_name'', ''medicine_unit2'', unit2_name) t1_jo
  FROM
	  mci_medicine_tbl, 
		mci_editable_tbl,
		mst_medicine_tbl, 
		quantity_tbl
  WHERE
	  value like ''%@prescriptionDetail.attr%''
    AND exists (
		  SELECT
			  medi_cd 
			FROM
			  mst_medicine_tbl)
),
jo_directions_tbl AS (
  SELECT t1 AS t1_jo 
	FROM (
	  SELECT json_build_object(''Rp'', ''Rp1'', ''type'', 2, ''F1'', default_directions, ''F2'', '''', ''F3'', '''', ''F4'', '''', ''F5'', quantity, ''F6'', ''日分'', ''medicine_type'', '''', ''medicine_cd'', '''', ''R'', '''', ''unchg'', editable_value, ''medicine_unit1'', '''', ''medicine_unit2'', '''') AS t1 
		FROM
		  quantity_tbl, 
			mci_editable_tbl, 
			default_directions_tbl) t2, 
		mci_directions_tbl
  WHERE
	  value like ''%@prescriptionDetail.attr%''
),
expirationDate_tbl AS (
  SELECT
	  CASE WHEN (''@expirationDate'' IS NULL OR ''@expirationDate'' = '''') THEN NULL
		ELSE
		  LEFT(''@expirationDate'', 8)
		END AS expirationDate
)
INSERT INTO ord_prescription( 
  ord_prescription_no
	, facility_cd
  , pat_id
  , prescription_type
  , issue_date
  , issue_state
	, expiration_date
  , prescription_detail
  , is_disp
  , is_del
  , reg_date
  , up_date 
) 
VALUES (
  ''@ordPrescriptionNo''
	, ''@facilityCd''
  , @patId
  , ''2''
  , LEFT(''@issueDate'', 8)
  , ''0''
	, (SELECT expirationDate FROM expirationDate_tbl)
  , CASE WHEN EXISTS(SELECT t1_jo FROM jo_medicine_tbl) THEN concat(concat(''['', (SELECT t1_jo FROM jo_medicine_tbl)), '']'')::jsonb ELSE CASE WHEN EXISTS(SELECT t1_jo FROM jo_directions_tbl) THEN concat(concat(''['', (SELECT t1_jo FROM jo_directions_tbl)), '']'')::jsonb END END
  , ''1''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の処方情報の新規登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9006, 'SELECT
  user_id ,
	pat_id,
	facility_cd,
	user_settings
FROM
  mst_user 
WHERE
  facility_cd = @facilityCd
	AND user_id = @userId
	AND is_disp = ''1''
	AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の利用者マスタの取得処理', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9007, 'WITH authorized_authorities_tbl AS (
  SELECT
	 REPLACE(user_settings::TEXT, (user_settings->>''authorized_authorities'')::TEXT, ''["011", "021", "031", "041", "051", "061", "071", "081", "091", "101", "111"]''::TEXT)  AS new_settings_1
	 FROM
		mst_user 
	 WHERE
		facility_cd = ''@facilityCd''
		AND user_id = ''@userId'' 
		AND is_disp = ''1'' 
		AND is_del = ''0''
),
use_functions_tbl AS (
  SELECT
	  REPLACE(new_settings_1::TEXT, ((new_settings_1)::json->>''use_functions'')::TEXT, ''["005"]''::TEXT) AS new_settings_2
	FROM
	  authorized_authorities_tbl
),
authorized_functions_tbl AS (
  SELECT
	  REPLACE(new_settings_2::TEXT, ((new_settings_2)::json->>''authorized_functions'')::TEXT, ''["005"]''::TEXT) AS new_settings_3
	FROM
	  use_functions_tbl
)
UPDATE
  mst_user
SET
  user_settings = (SELECT new_settings_3 FROM authorized_functions_tbl)::jsonb,
	up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd''
	AND user_id = @userId
	AND is_disp = ''1''
	AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の利用者の権限を更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9008, 'SELECT
  ord_prescription_no, 
  facility_cd, 
  pat_id, 
  insurance_cd, 
  insu_pub_no,
  insu_pub_pat_no,
  insu_no,
  insu_pat_mark,
  insu_pat_no,
  is_insured,
  is_dependent,
  insu_kbn,
  insu_dr_id,
  insu_dr_name,
  insu_dr_sign,
  is_doubt,
  is_information,
  is_elderly,
  is_elderly7,
  is_child,
  remarks,
  is_anesthesia,
  remarks_anesthesia,
  remarks_free
FROM
  ord_personal_prescription 
WHERE 
  ord_prescription_no = @ordPrescriptionNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の処方情報(個人)の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9009, 'DELETE FROM 
  ord_personal_prescription 
WHERE
  ord_prescription_no = @ordPrescriptionNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の処方情報(個人)の物理削除', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9010, 'WITH mci_medicine_tbl AS (
  SELECT 
    info ->> ''value'' AS medi_val
  FROM mst_coop_ini
  CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
  WHERE facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
  AND info ->> ''key2'' = ''MEDICINE_ATTR''
),
mci_editable_tbl AS (
  SELECT
	  CASE WHEN info ->> ''value'' = ''0'' THEN ''x''
		ELSE ''''
		END AS editable_value
	FROM mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE facility_cd = ''@facilityCd''
	AND is_del = ''0''
	AND info ->> ''key0'' = ''@key0''
	AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	AND info ->> ''key2'' = ''EDITABLE_FLG''
), 
mci_directions_tbl AS (
  SELECT 
    info ->> ''value'' AS direction_val
  FROM mst_coop_ini
  CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
  WHERE facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
  AND info ->> ''key2'' = ''DIRECTIONS_ATTR''
),
mci_comment_tbl AS (
  SELECT 
    info ->> ''value'' AS comment_val
  FROM mst_coop_ini
  CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
  WHERE facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
  AND info ->> ''key2'' = ''FREECOMMENT_ATTR''
),
medi_hospcode_tbl AS (
  SELECT
	  info ->> ''value'' AS hospCd_val
	FROM
	  mst_coop_ini
	CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
	WHERE
	  facility_cd = ''@facilityCd''
	  AND is_del = ''0''
	  AND info ->> ''key0'' = ''@key0''
	  AND info ->> ''key1'' = ''FJI_PRESCRIPT''
	  AND info ->> ''key2'' = ''MEDICINE''
),
hospital_code_tbl AS (
  SELECT
	  CASE hospCd_val
		WHEN ''1'' THEN
		  ''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode1,
		CASE hospCd_val
		WHEN ''1'' THEN
			NULL
		WHEN ''2'' THEN
			''@prescriptionDetail.code''
		WHEN ''3'' THEN
		  NULL
		WHEN ''4'' THEN
		  NULL
		ELSE
			''@prescriptionDetail.code''
		END AS pCode2,
		CASE hospCd_val
		WHEN ''3'' THEN
			''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode3,
		CASE hospCd_val
		WHEN ''4'' THEN
			''@prescriptionDetail.code''
		ELSE
		  NULL
		END AS pCode4,
		''@prescriptionDetail.unit_name'' AS pUnitName,
		''@prescriptionDetail.name'' AS pName
	FROM
	  medi_hospcode_tbl
),
mst_medicine_tbl AS (
  SELECT
    medicine_cd AS medi_cd,
		CASE WHEN unit_second IS NULL THEN ''''
		ELSE unit_second
		END AS unit2_name
  FROM
    mst_medicine
    , hospital_code_tbl
  WHERE
    facility_cd = ''@facilityCd''
		AND is_del = ''0''
    AND (in_hospital_cd_1 = pCode1 OR pCode1 IS NULL)
	  AND (in_hospital_cd_2 = pCode2 OR pCode2 IS NULL)
	  AND (in_hospital_cd_3 = pCode3 OR pCode3 IS NULL)
	  AND (in_hospital_cd_4 = pCode4 OR pCode4 IS NULL)
	ORDER BY
	  medicine_cd
	LIMIT 1
),
default_directions_tbl AS (
  SELECT
	  split_part(list_details, '','', 1) AS default_directions
	FROM
	  mst_take_medicine
	WHERE
	  facility_cd = ''@facilityCd''
		AND list_class = ''10''
),
meisai_tbl AS (
 SELECT
   CASE WHEN medi_val like ''%@prescriptionDetail.attr%'' THEN 1
	 ELSE
		CASE WHEN direction_val like ''%@prescriptionDetail.attr%'' THEN 2
	  ELSE
		 CASE WHEN comment_val like ''%@prescriptionDetail.attr%'' THEN 3
	   END
	  END
	 END AS meisai_type
 FROM
   mci_medicine_tbl,
	 mci_directions_tbl,
	 mci_comment_tbl
),
cur_details_tbl AS (
SELECT elem, idx
FROM ord_prescription
CROSS JOIN jsonb_array_elements(prescription_detail) 
WITH ORDINALITY arr(elem, idx)
WHERE
  ord_prescription_no = ''@ordPrescriptionNo''
),
quantity_tbl AS (
  SELECT
    CASE WHEN CAST(''@prescriptionDetail.quantity'' AS numeric) > 999999.999 THEN CAST(999999.999 AS numeric)
    ELSE CAST(CAST(''@prescriptionDetail.quantity'' AS numeric) AS numeric(10, 3))
    END AS quantity
),
cur_count_tbl AS (
  SELECT
    count(*) AS curCount
  FROM (
    SELECT 
      jsonb_array_elements(prescription_detail) 
    FROM 
      ord_prescription 
    WHERE
    ord_prescription_no = ''@ordPrescriptionNo'') detail_jsons
),
last_json_tbl AS (
SELECT 
  (prescription_detail->>(idx-1)::INT)::json->>''type'' AS last_type,
  (prescription_detail->>(idx-1)::INT)::json->>''Rp'' AS last_rp
FROM
  cur_count_tbl,
  ord_prescription	
CROSS JOIN jsonb_array_elements(prescription_detail) WITH ORDINALITY arr(j, idx)
WHERE
  ord_prescription_no = ''@ordPrescriptionNo''
  AND idx = curCount
),
last_directions_idx_tbl AS (
SELECT
  CASE WHEN lastDirectionsIdx_val IS NULL THEN -1
	ELSE
	  lastDirectionsIdx_val
	END AS lastDirecIdx
FROM (
SELECT max(idx) AS lastDirectionsIdx_val
FROM ord_prescription
CROSS JOIN jsonb_array_elements(prescription_detail) 
WITH ORDINALITY arr(e, idx)
WHERE
  ord_prescription_no = ''@ordPrescriptionNo''
	AND e->>''type'' = ''2'') direc_idx_tbl
),
cur_rp_tbl AS (
  SELECT
    last_rp AS cur_rp
  FROM
    last_json_tbl
),
new_rp_tbl AS (
  SELECT
    concat(''Rp'', RIGHT(last_rp, length(last_rp)-2)::INT+1) AS new_rp
  FROM
    last_json_tbl
),
jo_cur_medicine AS (
  SELECT 
    t1 AS cur_medicine_jobj 
  FROM (
    SELECT json_build_object(''Rp'', cur_rp, ''type'', 1, ''F1'', ''@prescriptionDetail.name'', ''F2'', '''', ''F3'', '''', ''F4'', '''', ''F5'', quantity, ''F6'', ''@prescriptionDetail.unit_name'', ''medicine_type'', 1, ''medicine_cd'', medi_cd, ''R'', ''@prescriptionDetail.name '', ''unchg'', editable_value, ''medicine_unit1'', ''@prescriptionDetail.unit_name'', ''medicine_unit2'', unit2_name) AS t1 
    FROM
      mst_medicine_tbl, 
			mci_editable_tbl,
      quantity_tbl, 
      cur_rp_tbl 
    WHERE exists (
      SELECT
        medi_cd
      FROM
        mst_medicine_tbl)) t2, mci_medicine_tbl, mst_medicine_tbl 
      WHERE
        medi_val like ''%@prescriptionDetail.attr%''
),
jo_new_medicine AS (
  SELECT 
    t1 AS new_medicine_jobj 
  FROM (
    SELECT json_build_object(''Rp'', new_rp, ''type'', 1, ''F1'', ''@prescriptionDetail.name'', ''F2'', '''', ''F3'', '''', ''F4'', '''', ''F5'', quantity, ''F6'', ''@prescriptionDetail.unit_name'', ''medicine_type'', 1, ''medicine_cd'', medi_cd, ''R'', ''@prescriptionDetail.name '', ''unchg'', editable_value, ''medicine_unit1'', ''@prescriptionDetail.unit_name'', ''medicine_unit2'', unit2_name) AS t1 
    FROM
      mst_medicine_tbl, 
			mci_editable_tbl,
      quantity_tbl, 
      new_rp_tbl 
    WHERE exists (
      SELECT
        medi_cd
      FROM
        mst_medicine_tbl)) t2, mci_medicine_tbl, mst_medicine_tbl 
      WHERE
        medi_val like ''%@prescriptionDetail.attr%''
),
jo_directions AS (
  SELECT
    t1 AS directions_jobj 
  FROM (
    SELECT 
      json_build_object(''Rp'', cur_rp, ''type'', 2, ''F1'', default_directions, ''F2'', '''', ''F3'', '''', ''F4'', '''', ''F5'', CAST(quantity AS INT), ''F6'', ''日分'', ''medicine_type'', '''', ''medicine_cd'', '''', ''R'', '''', ''unchg'', editable_value, ''medicine_unit1'', '''', ''medicine_unit2'', '''') AS t1 
    FROM
      quantity_tbl, 
			default_directions_tbl,
			mci_editable_tbl,
      cur_rp_tbl) t2, 
      mci_directions_tbl
  WHERE
    direction_val like ''%@prescriptionDetail.attr%''
),
jo_comment AS (
  SELECT
    json_build_object(''Rp'', cur_rp, ''type'', 6, ''F1'', ''@prescriptionDetail.name'', ''F2'', '''', ''F3'', '''', ''F4'', '''', ''F5'', '''', ''F6'', '''', ''medicine_type'', '''', ''medicine_cd'', '''', ''R'', ''@prescriptionDetail.name '', ''unchg'', editable_value, ''medicine_unit1'', '''', ''medicine_unit2'', '''') AS comment_jobj
  FROM 
    cur_rp_tbl,
		mci_editable_tbl
),
jo_newDiv AS (
  SELECT
    json_build_object(''Rp'', new_rp, ''type'', 0, ''F1'', '''', ''F2'', '''', ''F3'', '''', ''F4'', '''', ''F5'', '''', ''F6'', '''', ''medicine_type'', '''', ''medicine_cd'', '''', ''R'', '' '', ''unchg'', editable_value, ''medicine_unit1'', '''', ''medicine_unit2'', '''') AS newDiv_jobj
  FROM 
    new_rp_tbl,
		mci_editable_tbl
),
new_medi_jsonb AS (
  SELECT
	  concat(concat(concat(concat(''['', (SELECT newDiv_jobj FROM jo_newDiv)::TEXT), '',''), (SELECT new_medicine_jobj FROM jo_new_medicine)::TEXT), '']'')::jsonb AS medi_jsonb
),
cur_medi_jsonb AS (
  SELECT
	  concat(concat(''['', (SELECT cur_medicine_jobj FROM jo_cur_medicine)::json), '']'')::jsonb AS medi_jsonb
),
cur_directions_jsonb AS (
  SELECT
	  concat(concat(''['', (SELECT directions_jobj FROM jo_directions)::json), '']'')::jsonb AS directions_jsonb
),
cur_comment_jsonb AS (
  SELECT
	  concat(concat(''['', (SELECT comment_jobj FROM jo_comment)::json), '']'')::jsonb AS comment_jsonb
),
targetMedi_index_tbl AS (
  SELECT 
	  idx AS target_medi_idx
	FROM
	  ord_prescription,
		last_directions_idx_tbl
	CROSS JOIN jsonb_array_elements(prescription_detail) WITH ORDINALITY arr(e, idx)
	WHERE
	  ord_prescription_no = ''@ordPrescriptionNo''
		AND e->>''type'' = ''1''
		AND idx > lastDirecIdx
	ORDER BY
	  idx
	LIMIT 1
),
mediLast_pre_jsonb AS (
  SELECT
    CASE WHEN target_medi_idx = -1 THEN
     prescription_detail::jsonb
    ELSE
      (SELECT
	      jsonb_agg((prescription_detail->>(idx-1)::INT)::jsonb)
	    FROM
	      ord_prescription,
		    targetMedi_index_tbl
	    CROSS JOIN jsonb_array_elements(prescription_detail) WITH ORDINALITY arr(e, idx)
	    WHERE
	      ord_prescription_no = ''@ordPrescriptionNo''
		    AND target_medi_idx > 1
		    AND idx < target_medi_idx)::jsonb
    END AS pre_jsonb
  FROM
    ord_prescription,
    targetMedi_index_tbl
  WHERE
    ord_prescription_no = ''@ordPrescriptionNo''
),
pre_jsonb_tbl AS (
  SELECT
    CASE WHEN target_medi_idx <= 1 THEN
      ''[]''::jsonb
    ELSE
      pre_jsonb::jsonb
    END
	FROM
	  ord_prescription,
		targetMedi_index_tbl,
		(SELECT
	    jsonb_agg((prescription_detail->>(idx-1)::INT)::jsonb) AS pre_jsonb
	FROM
	  ord_prescription,
		targetMedi_index_tbl
	CROSS JOIN jsonb_array_elements(prescription_detail) WITH ORDINALITY arr(e, idx)
	WHERE
	  ord_prescription_no = ''@ordPrescriptionNo''
		AND target_medi_idx > 1
		AND idx < target_medi_idx
		) tmp_tbl
	WHERE
	  ord_prescription_no = ''@ordPrescriptionNo''
),
tail_jsonb_tbl AS (
  SELECT jsonb_agg(tmp_elem) AS tail_jsonb
  FROM (
	  SELECT
  CASE WHEN jsonb_typeof(elem) = ''array'' THEN
	  jsonb_array_elements(elem)
	ELSE
	  elem
	END AS tmp_elem
FROM
  ord_prescription,
 (  
 SELECT jsonb_agg((prescription_detail->>(idx-1)::INT)::jsonb || directions_jsonb::jsonb) AS tail_jsonb
	FROM
	  ord_prescription,
		targetMedi_index_tbl,
		cur_directions_jsonb
	CROSS JOIN jsonb_array_elements(prescription_detail) WITH ORDINALITY arr(e, idx)
	WHERE
	  ord_prescription_no = ''@ordPrescriptionNo''
		AND idx >= target_medi_idx
		AND e->>''type'' = ''1''
) tmp_tbl2
CROSS JOIN jsonb_array_elements(tail_jsonb) WITH ORDINALITY arr(elem, idx)
WHERE ord_prescription_no = ''@ordPrescriptionNo''
	) tmp_tbl3
),
expirationDate_tbl AS (
  SELECT
	  CASE WHEN (''@expirationDate'' IS NULL OR ''@expirationDate'' = '''') THEN NULL
		ELSE
		  LEFT(''@expirationDate'', 8)
		END AS expirationDate
)
UPDATE
  ord_prescription
SET
  prescription_detail = 
    CASE WHEN meisai_type = 1 THEN
		  CASE last_type
			WHEN ''6'' THEN
			  prescription_detail || (SELECT medi_jsonb FROM new_medi_jsonb)::jsonb
			ELSE
			  prescription_detail || (SELECT medi_jsonb FROM cur_medi_jsonb)::jsonb
			END
		ELSE
		  CASE WHEN meisai_type = 2 THEN
			  CASE WHEN lastDirecIdx = jsonb_array_length(prescription_detail) THEN
				  prescription_detail || (SELECT directions_jsonb FROM cur_directions_jsonb)::jsonb
				ELSE
				  (SELECT pre_jsonb FROM pre_jsonb_tbl)::jsonb || (SELECT tail_jsonb FROM tail_jsonb_tbl)::jsonb
				END
			ELSE
			  CASE WHEN meisai_type = 3 THEN
				  prescription_detail || (SELECT comment_jsonb FROM cur_comment_jsonb)::jsonb
				ELSE
				  prescription_detail
				END
			END
		END
 ,issue_date = LEFT(''@issueDate'', 8)
 ,expiration_date = (SELECT expirationDate FROM expirationDate_tbl)
 ,up_date = CURRENT_TIMESTAMP
FROM
  meisai_tbl,
	last_json_tbl,
	last_directions_idx_tbl
WHERE
  ord_prescription_no = ''@ordPrescriptionNo''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の処方情報を更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9011, 'WITH isChild_tbl AS (
  SELECT
  CASE WHEN (pat_birthday IS NOT NULL AND pat_birthday != '''') THEN
	  CASE WHEN (CURRENT_DATE - pat_birthday::DATE)/365 >= 6 THEN ''0''
	    ELSE
	      ''1''
	    END
	ELSE
	  ''0''
	END AS isChild
FROM
  pat_personal_main
WHERE
  pat_id = @patId
),
remarks_tbl AS (
  SELECT
	  CASE WHEN isChild = ''1'' THEN ''６歳未満''
		ELSE
		  NULL
		END AS remarks_val
	FROM
	  isChild_tbl
)
INSERT INTO ord_personal_prescription(
  ord_prescription_no,
	facility_cd,
	pat_id,
	insu_dr_id,
	insu_dr_name,
	is_doubt,
	is_information,
  is_elderly,
  is_elderly7,
  is_child,
	remarks,
  is_anesthesia,
	reg_date,
	up_date
)
VALUES(
  ''@ordPrescriptionNo'',
	''@facilityCd'',
	''@patId'',
	''@docCd'',
	personal_info_encrypt(''@docName''),
	''0'',
	''0'',
	''0'',
	''0'',
	(SELECT isChild FROM isChild_tbl),
	(SELECT remarks_val FROM remarks_tbl),
	''0'',
	CURRENT_TIMESTAMP,
	CURRENT_TIMESTAMP
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の処方情報(個人)の登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9012, 'SELECT
  ctl_no, 
  facility_cd, 
  pat_id, 
  ord_no, 
  coop_cd,
  coop_ord_no,
  is_disp,
  is_del,
  user_id,
  status,
  hosp_pat_id,
  coop_cd_index,
  coop_version
FROM
  ord_coop_no 
WHERE 
  facility_cd = @facilityCd
	AND coop_ord_no = @ordPrescriptionNo
	AND is_disp = ''1''
	AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の連携オーダー番号の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9013, 'INSERT INTO ord_coop_no(
  facility_cd, 
  pat_id, 
  ord_no, 
  coop_cd,
  coop_ord_no,
  is_disp,
  is_del,
  coop_cd_index,
  coop_version,
  reg_date,
  up_date
 )
 VALUES(
   ''@facilityCd'',
	 ''@patId'',
	 ''@ordNo'',
	 ''pre_ord'',
	 ''@ordPrescriptionNo'',
	 ''1'',
	 ''0'',
	 ''@coopCdIndex'',
	 ''@coopVersion'',
	 CURRENT_TIMESTAMP,
	 CURRENT_TIMESTAMP
 )
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の連携オーダー番号の登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9014, 'UPDATE
  ord_coop_no
SET
  pat_id = ''@patId'', 
  coop_ord_no = ''@ordPrescriptionNo'',
  up_date = CURRENT_TIMESTAMP
WHERE
  --facility_cd = ''@facilityCd''
	--AND ord_no = ''@ordNo''
	ctl_no = @ctlNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携の連携オーダー番号の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9015, 'WITH max_no AS (
  SELECT
	  max(ord_prescription_no)::INT AS maxNo
	FROM
	  ord_prescription
),
seq_no AS (
  SELECT nextval(''ord_prescription_ord_prescription_no_seq'')::INT AS seqNo
)
SELECT SETVAL(''ord_prescription_ord_prescription_no_seq'', maxNo)
FROM
  max_no,
	seq_no
WHERE
  maxNo > seqNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)GX処方情報連携を取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
