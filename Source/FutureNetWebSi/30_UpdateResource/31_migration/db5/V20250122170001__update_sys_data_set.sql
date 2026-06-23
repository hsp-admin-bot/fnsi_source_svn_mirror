DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-102, -201, -202, -203, -204, -205, -33, -600001, -600011, -600012, -600013, -600014, -600015, -600016, -600017, -600018, -600019, -600020, -600021, -600103, -600105, -600106, -600107, -600108, -600109, -600110, -600111, -600112, -600113, -600114, -600115, -600116, -600200, -600201, -600300, -600302, -600303, -600401, -600402, -600403, -600404, -600405, -600500, -600501, -600502, -600503, -600504, -600505, -600506, -600507, -600508, -600509, -600510, -600511, -600512, -600513, -600514, -600515, -600516, -600517, -600518, -610901, -98, 9101, 9102, 9103, 9104, 9105, 9106, 9107, 9111, 9112, 9113, 9119, 9205, 9402, 9403, 9404, 9405, 9406, 9407, 9408, 9409, 9410, -600202);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610901, 'SELECT
  user_id,
  base_date
FROM
  sys_coop_journal
WHERE
  ctl_no = @ctlNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_UPDATE_CODE取得事前SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600518, 'DELETE FROM mst_user_authentication
WHERE disp_user_id = ''@inHospitalCd1''
AND facility_cd = ''@facilityCd''
AND EXISTS (
    SELECT 1
    FROM mst_user_authentication
    WHERE disp_user_id = ''@inHospitalCd1''
    AND ''@startDateAfter'' NOT IN (''99999999'', ''00000000'') 
    AND ''@endDateAfter'' NOT IN (''99999999'', ''00000000'') 
    AND (
        CURRENT_DATE < TO_DATE(''@startDateAfter'', ''YYYYMMDD'') 
        OR CURRENT_DATE > TO_DATE(''@endDateAfter'', ''YYYYMMDD'')
    )
);', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600517, 'UPDATE mst_user
SET is_del = 1
WHERE user_id = @userId
AND (
    ''@startDateAfter'' NOT IN (''99999999'', ''00000000'') 
    AND ''@endDateAfter'' NOT IN (''99999999'', ''00000000'') 
    AND (
        CURRENT_DATE < TO_DATE(''@startDateAfter'', ''YYYYMMDD'') 
        OR CURRENT_DATE > TO_DATE(''@endDateAfter'', ''YYYYMMDD'')
    )
);', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600516, 'UPDATE mst_personal_user
SET is_del = 1
WHERE user_id = @userId
AND (
    ''@startDateAfter'' NOT IN (''99999999'', ''00000000'') 
    AND ''@endDateAfter'' NOT IN (''99999999'', ''00000000'') 
    AND (
        CURRENT_DATE < TO_DATE(''@startDateAfter'', ''YYYYMMDD'') 
        OR CURRENT_DATE > TO_DATE(''@endDateAfter'', ''YYYYMMDD'')
    )
);', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600515, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    octet_length(CAST(@userKana AS TEXT)) > 20
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600514, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    octet_length(CAST(@userName AS TEXT)) > 20
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600513, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    octet_length(CAST(@userPassword AS TEXT)) > 16
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600512, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    @userPassword !~ ''^[a-zA-Z0-9]+$''
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600511, 'SELECT 
    1
FROM
    mst_coop_ini AS ini
WHERE
    (
        NOT (@endDateAfter ~ ''^\d{8}$'') 
        OR TO_DATE(@endDateAfter, ''YYYYMMDD'') IS NULL
    )
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600510, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
        @endDateAfter = ''''
	LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600509, 'SELECT 
    1
FROM
    mst_coop_ini AS ini
WHERE
    (
        NOT (@startDateAfter ~ ''^\d{8}$'') 
        OR TO_DATE(@startDateAfter, ''YYYYMMDD'') IS NULL
    )
    AND @startDateAfter NOT IN (''00000000'', ''99999999'')
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600508, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
        @startDateAfter = ''''
	LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600507, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    @inHospitalCd !~ ''^[a-zA-Z0-9]+$''
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600506, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
    octet_length(CAST(@inHospitalCd AS TEXT)) > 10
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600505, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
        @inHospitalCd = ''''
	LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600504, 'SELECT
	1
FROM 
	mst_coop_ini
WHERE facility_cd = ''CONV76'' 
	AND NOT (@crud IN (''C'', ''U'', ''D''))
LIMIT 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者削除(mst_user_authentication 物理削除)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600503, 'SELECT
	1
FROM
	mst_coop_ini AS ini
WHERE
        @inHospitalCd = ''ScalApp4''
        OR @inHospitalCd = ''CardApp4''
        OR @inHospitalCd = ''PrintSrvApp4''
	LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600502, 'SELECT
	1
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
	facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''key0'' = @key0
	AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
	AND info ->> ''key2'' = ''PROTECT_STAFF''
	AND @inHospitalCd = ANY(string_to_array(
	COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''), '',''
	))
	LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の連携設定.PROTECT_STAFFの制御', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600501, 'SELECT
	1
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
	facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''key0'' = @key0
	AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
	AND info ->> ''key2'' = ''STAFF_NAME_EMPTY''
	AND (
		CASE
			WHEN COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') = ''0'' THEN false
			WHEN COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') = ''1'' THEN @userName = ''''
			ELSE false
		END
	)
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の連携設定.PROTECT_STAFFの制御', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600500, 'SELECT
	1
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
	facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''key0'' = @key0
	AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
	AND info ->> ''key2'' = ''STAFF_PASSWORD_EMPTY''
	AND (
		CASE
			WHEN COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') = ''0'' THEN false
			WHEN COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') = ''1'' THEN @userPassword = ''''
			ELSE false
		END
	)
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の連携設定.PROTECT_STAFFの制御', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600405, 'with KOU_COAG_RESOLVE_MODE_cd AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsON_array_elements(ini.coop_ini_info ::jsON) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
),
XMLSND_INTERACTIONTIME AS(--データ属性日時切替取得
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsON_array_elements(ini.coop_ini_info ::jsON) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
    AND COALESCE(info ->> ''key0'', '''') = @key0
    AND info ->> ''key1'' = ''NEC''
    AND info ->> ''key2'' = ''XMLSND_INTERACTIONTIME''
)
SELECT
  ord.ord_no AS ord_no,
  ord.treat_date AS treat_date,--透析日
  COALESCE(mkr.in_hospital_cd_1, '''') AS kur_cd1,--クール
  COALESCE(ord.rst_kur_name, '''') AS kur_name,--クール名
  COALESCE(ord.rst_dialysis_cnt, 0) AS dialysis_cnt,--透析回数
  COALESCE(ord.rst_machine_no, 0) AS machine_no,--装置番号
  COALESCE(ord.rst_machine_name, '''') AS machine_name,--装置名
  COALESCE(ord.rst_course_name, '''') AS course_name,--診療科名
  COALESCE(mcs.in_hospital_cd_1, '''') AS course_cd,--診療科コード１
  COALESCE(ord.rst_ward_name, '''') AS ward_name,--病棟名
  COALESCE(mwd.in_hospital_cd_1, '''') AS ward_cd,--病棟コード１
  COALESCE(ord.rst_treatment_name, '''') AS treatment_name,--治療項目
  COALESCE(mtt.in_hospital_cd_a1, '''') AS treatment_cd,--治療項目コード１
  (CASE  mtt.device_mode 
    WHEN ''0'' THEN
      ''HD'' 
    WHEN ''1'' THEN
      ''ECUM'' 
    WHEN ''2'' THEN
      ''HDF'' 
    WHEN ''3'' THEN
      ''HF'' 
    WHEN ''4'' THEN
      ''HD+補液'' 
    WHEN ''5'' THEN
      ''ECUM+補液'' 
    WHEN ''6'' THEN
      ''AFBF'' 
    WHEN ''7'' THEN
      ''OHDF'' 
    WHEN ''8'' THEN
      ''OHF'' 
    WHEN ''9'' THEN
      ''特殊浄化'' 
    WHEN ''10'' THEN
      ''i-HDF'' ELSE''不明'' 
    END) AS device_mode,--装置モード
  COALESCE(ord.rst_dw, 0) AS dw,--dw
--mbd.bed_cd as bed_cd,--ベッドコード
  COALESCE(mbd.in_hospital_cd_1, '''') AS bed_cd1,
  COALESCE(mbd.bed_name, '''') AS bed_name,--ベッド名
  COALESCE(( CASE mbd.shunt_position WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS shunt_position,--シャント位置名称
  COALESCE(( CASE mbd.is_infection WHEN ''0'' THEN ''感染症無'' WHEN ''1'' THEN ''感染症対応'' ELSE''不明'' END ), '''') AS is_infection,--感染症フラグ
  COALESCE(( CASE mbd.emergency_class WHEN ''0'' THEN ''通常ベッド'' WHEN ''1'' THEN ''救急ベッド'' ELSE''不明'' END ), '''') AS emergency_class,--救急対応
  ord.rst_accept_date AS accept_date,--受付日時
  ord.rst_start_date AS start_date,--透析開始日時
  COALESCE(TO_CHAR( ord.rst_start_date, ''YYYYMMDDHH24MISS'' ), '''') AS start_date14,
  ord.rst_end_date AS end_date,--透析終了日時
  COALESCE(TO_CHAR( ord.rst_end_date, ''YYYYMMDDHH24MISS'' ), '''') AS end_date14,
  CASE (SELECT value FROM XMLSND_INTERACTIONTIME) 
      WHEN ''1'' THEN ord.rst_cond_send_date   --透析実績．送信日時
      ELSE ord.rst_start_date                --透析実績．開始日時
      END as patient_interactiontime, --透析開始日時
  COALESCE(TO_CHAR( CASE (SELECT value FROM XMLSND_INTERACTIONTIME) 
      WHEN ''1'' THEN ord.rst_cond_send_date   --透析実績．送信日時
      ELSE ord.rst_start_date                --透析実績．開始日時
      END , ''YYYYMMDDHH24MISS'' ), '''') AS patient_interactiontime14,
  ord.rst_return_home_date AS return_home_date,--帰宅時刻
  ord.rst_in_out_class AS in_out_class,--入外コード
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''外来'' WHEN ''1'' THEN ''入院'' ELSE NULL END ), '''') AS in_out_name,--入外区分
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''') AS in_out_f,--入外区分（F)
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE NULL END ), '''') AS in_out_s,--入外区分（S)
  COALESCE(RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999'' ), 60 ), 2 ), '''') AS treatment_time,
  COALESCE(ord.rst_cond_info -> ''1'' ->> ''value'', '''') AS treatment_time_m,
  COALESCE(ord.rst_cond_info -> ''2'' ->> ''value_name_1'', '''') AS va,--シャント
  COALESCE(mva.in_hospital_cd_1, '''') AS va_cd1,--シャントコード１
  COALESCE(( CASE mva.va_direct WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS va_direct,--シャント方向
  COALESCE(ord.rst_cond_info -> ''3'' ->> ''value'', '''') AS target_weight,
  COALESCE(( CASE WHEN ord.rst_cond_info -> ''3'' ->> ''value'' = ''-1'' THEN ''DWと同じ'' ELSE''目標体重指定'' END ), '''') AS target_mode,--目標体重指定設定
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_cond_info -> ''4'' ->> ''value'', ''FM99.99'' ), ''FM90.99'' ), '''') AS water_removal_amount_limit,
  COALESCE(ord.rst_cond_info -> ''5'' ->> ''value_name_1'', '''') AS dialyzer,
  COALESCE(TRIM ( mdr.in_hospital_cd_1 ), '''') AS dialyzer_cd1,--ダイアライザコード１
  COALESCE(mdr.maker, '''') AS dialyzer_maker,--ダイアライザメーカ
  COALESCE(mdr.function_class, '''') AS function_class,--ダイアライザ機能分類
  COALESCE(mdr.area, 0) AS dialyzer_area,--ダイアライザ面積
  COALESCE(mdr.ufr, 0) AS dialyzer_ufr,--ダイアライザUFR
  COALESCE(mdr.koa, 0) AS dialyzer_KoA,--ダイアライザKoA
  COALESCE(mdr.material, '''') AS dialyzer_material,--ダイアライザ材質
  COALESCE(( CASE mdr.membrane_wash WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE''不明'' END ), '''') AS membrane_wash,--膜洗浄（中空糸）
  COALESCE(( CASE mdr.wetdry WHEN ''0'' THEN ''不明'' WHEN ''1'' THEN ''WET'' WHEN ''2'' THEN ''DRY'' ELSE''不明'' END ), '''') AS dialyzer_wetdry,--WET/DRY
  COALESCE(mdr.substituent_wash_amt, 0) AS substituent_wash_amt,--置換洗浄量（透析液）
  COALESCE(mdr.gas_purge_time, 0) AS gas_purge_time,--ガスパージ時間
  COALESCE(mdr.urea_clearance, 0) AS urea_clearance,--尿素クリアランス
  COALESCE(mdr.alqd_flood_vol, 0) AS alqd_flood_vol,--透析液流量
  COALESCE(mdr.bloodamt, 0) AS dialyzer_bloodamt,--血流量
  COALESCE(mdr.sterilization, '''') AS sterilization,--滅菌
  COALESCE(ord.rst_cond_info -> ''6'' ->> ''value_name_1'', '''') AS adsorption_column,
  COALESCE(meqad.in_hospital_cd_1, '''') AS ad_cd1,--吸着器コード１
  COALESCE(ord.rst_cond_info -> ''7'' ->> ''value_name_1'', '''') AS primary_film,
  COALESCE(meqpr.in_hospital_cd_1, '''') AS pr_cd1,--1次膜コード１
  COALESCE(ord.rst_cond_info -> ''8'' ->> ''value_name_1'', '''') AS secondary_film,
  COALESCE(meqse.in_hospital_cd_1, '''') AS se_cd1,--2次膜コード１
  COALESCE(ord.rst_cond_info -> ''9'' ->> ''value_name_1'', '''') AS puncture_needle_a,
  COALESCE(meqa.in_hospital_cd_1, '''') AS a_cd1,--穿刺針Aコード１
  COALESCE(ord.rst_cond_info -> ''10'' ->> ''value_name_1'', '''') AS puncture_needle_v,
  COALESCE(meqv.in_hospital_cd_1, '''') AS v_cd1,--穿刺針Vコード１
  COALESCE(ord.rst_cond_info -> ''11'' ->> ''value_name_1'', '''') AS puncture_needle_sn,
  COALESCE(meqsn.in_hospital_cd_1, '''') AS sn_cd1,--穿刺針SNコード１
  COALESCE(( CASE ord.rst_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END ), '''') AS single_needle,
  COALESCE(ord.rst_cond_info -> ''13'' ->> ''value'', '''') AS blood_circuit,
  COALESCE(meqbc.in_hospital_cd_1, '''') AS bc_cd1,--血液回路コード１
  COALESCE(ord.rst_cond_info -> ''14'' ->> ''value'', '''') AS blood_flow,--血流量
  COALESCE(ord.rst_cond_info -> ''15'' ->> ''value_name_1'', '''') AS dialysate,
  COALESCE(( CASE ord.rst_cond_info -> ''15'' ->> ''medicine_type'' WHEN ''1'' THEN med15.in_hospital_cd_1 WHEN ''2'' THEN mmmx.in_hospital_cd_1 END ), '''') AS ds_cd,
  COALESCE(ord.rst_cond_info -> ''16'' ->> ''value'', '''') AS dialysate_flow_rate,
  COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', '''') AS dialysate_amount,
  COALESCE(ord.rst_cond_info -> ''17'' ->> ''unit'', '''') AS dialysate_amount_unit,
  COALESCE(ord.rst_cond_info -> ''18'' ->> ''value'', '''') AS dialysate_temperature,
  COALESCE(ord.rst_cond_info -> ''19'' ->> ''value_name_1'', '''') AS fluid_replacement,
-- 	ds_cd1抗凝固剤コード１繰り返すので取り除きます
   COALESCE(( CASE ord.rst_cond_info -> ''19'' ->> ''medicine_type'' WHEN ''1'' THEN med19.in_hospital_cd_1 WHEN ''2'' THEN mmmmx.in_hospital_cd_1 END ), '''') AS ds_cd1,--補液コード１
  COALESCE(ord.rst_cond_info -> ''20'' ->> ''value'', '''') AS fluid_replacement_amount,
  COALESCE(( CASE ord.rst_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ), '''') AS fluid_replacement_timing,
  COALESCE(ord.rst_cond_info -> ''21'' ->> ''value'', '''') AS fluid_replacement_timing_ssi,
  COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', '''') AS fluid_replacement_use_count,
  COALESCE(ord.rst_cond_info -> ''22'' ->> ''unit'', '''') AS fluid_replacement_use_count_unit,
  COALESCE(ord.rst_cond_info -> ''23'' ->> ''value'', '''') AS fluid_replacement_temperature,
  COALESCE(ord.rst_cond_info -> ''24'' ->> ''value'', '''') AS fluid_replacement_speed,
  COALESCE(ord.rst_cond_info -> ''25'' ->> ''value_name_1'', '''') AS anti_coagulant,
--   COALESCE(( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''1'' THEN med25.in_hospital_cd_1 WHEN ''2'' THEN mmx.in_hospital_cd_1 END ), '''') AS ds_cd1,--抗凝固剤コード１
  COALESCE(( CASE WHEN ord.rst_cond_info -> ''25'' ->> ''medicine_type'' =''1'' THEN med25.in_hospital_cd_1 WHEN
	ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2'' 
	and (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) in (''0'',''1''))
	THEN mmx.in_hospital_cd_1 END ), '''') AS ds_cd2,--抗凝固剤コード１
  COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', '''') AS anti_coagulant_one_shot_amount,
--   COALESCE(ord.rst_cond_info -> ''26'' ->> ''unit'', '''') AS anti_coagulant_one_shot_amount_unit,
 case when (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd)) in (''0'',''1'') or 
ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
then 
 COALESCE(ord.rst_cond_info -> ''26'' ->> ''unit'', '''') else '''' end AS anti_coagulant_one_shot_amount_unit,
  COALESCE(ord.rst_cond_info -> ''27'' ->> ''value'', '''') AS anti_coagulant_sustained_speed,
  COALESCE(ord.rst_cond_info -> ''27'' ->> ''unit'', '''') AS anti_coagulant_sustained_speed_unit,
  COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', '''') AS anti_coagulant_sustained_amount,
  COALESCE(ord.rst_cond_info -> ''28'' ->> ''unit'', '''') AS anti_coagulant_sustained_amount_unit,
  COALESCE(TO_NUMBER( ord.rst_cond_info -> ''26'' ->> ''value'', ''FM999999999999'' ) + TO_NUMBER( ord.rst_cond_info -> ''28'' ->> ''value'', ''FM999999999999'' ), 0) AS anti_coagulant_total_amount,--抗凝固剤総量
  COALESCE(( CASE ord.rst_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''') AS ip,
  COALESCE(( CASE ord.rst_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ), '''') AS ip_start,
  COALESCE(ord.rst_cond_info -> ''30'' ->> ''value'', '''') AS ip_start_ssi,
  COALESCE(ord.rst_cond_info -> ''31'' ->> ''value'', '''') AS ip_one_short_amount,
  COALESCE(ord.rst_cond_info -> ''32'' ->> ''value'', '''') AS ip_speed,
  COALESCE(ord.rst_cond_info -> ''33'' ->> ''value'', '''') AS ip_speed_max,
  COALESCE(( CASE ord.rst_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''') AS auto_one_shot,
  COALESCE(ord.rst_cond_info -> ''34'' ->> ''value'', '''') AS auto_one_shot_ssi,
  COALESCE(( CASE ord.rst_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''') AS ip_auto_off,
  COALESCE(ord.rst_cond_info -> ''35'' ->> ''value'', '''') AS ip_auto_off_ssi,
  COALESCE(ord.rst_cond_info -> ''36'' ->> ''value'', '''') AS ip_auto_off_time,
  COALESCE(( CASE ord.rst_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''') AS ip_monitor_auto_off,
  COALESCE(ord.rst_cond_info -> ''37'' ->> ''value'', '''') AS ip_monitor_auto_off_ssi,
  COALESCE(ord.rst_cond_info -> ''38'' ->> ''value'', '''') AS ip_monitor_auto_off_time,
  ord.rst_puncture_user_info -> ''date'' AS puncture_date,--穿刺時刻
  ord.rst_puncture_user_info -> ''user_id_1'' AS puncture1_id,--穿刺者１ID
  COALESCE(concat ( ord.rst_puncture_user_info ->> ''user_last_name_1'', ord.rst_puncture_user_info ->> ''user_first_name_1'' ), '''') AS puncture1_name,--穿刺者1
  ord.rst_puncture_user_info -> ''date_1''AS puncture1_date,--穿刺時刻1
  ord.rst_puncture_user_info -> ''user_id_2'' AS puncture2_id,--穿刺者２ID
  COALESCE(concat ( ord.rst_puncture_user_info ->> ''user_last_name_2'', ord.rst_puncture_user_info ->> ''user_first_name_2'' ), '''') AS puncture2_name,--穿刺者2
  ord.rst_puncture_user_info -> ''date_2'' AS puncture2_date,--穿刺時刻2
  ord.rst_return_user_info -> ''date'' AS return_date,--回収時刻
  ord.rst_return_user_info -> ''user_id_1'' AS return1_id,--回収者１ID
  COALESCE(concat ( ord.rst_return_user_info ->> ''user_last_name_1'', ord.rst_return_user_info ->> ''user_first_name_1'' ), '''') AS return1_name,--回収者1
  ord.rst_return_user_info -> ''date_1'' AS return1_date,--回収時刻1
  ord.rst_return_user_info -> ''user_id_2'' AS return2_id,--回収者２ID
  COALESCE(concat ( ord.rst_return_user_info ->> ''user_last_name_2'', ord.rst_return_user_info ->> ''user_first_name_2'' ), '''') AS return2_name,--回収者2
  ord.rst_return_user_info -> ''date_2'' AS return2_date,--回収時刻2
  ord.rst_charge_user_info -> ''user_id_1'' AS charge1_id,--担当者１ID
  COALESCE(concat ( ord.rst_charge_user_info ->> ''user_last_name_1'', ord.rst_charge_user_info ->> ''user_first_name_1'' ), '''') AS charge1_name,--担当者1
  ord.rst_charge_user_info -> ''date_1'' AS charge1_date,--担当時刻1
  ord.rst_charge_user_info -> ''user_id_2'' AS charge2_id,--担当者２ID
  COALESCE(concat ( ord.rst_charge_user_info ->> ''user_last_name_2'', ord.rst_charge_user_info ->> ''user_first_name_2'' ), '''') AS charge2_name,--担当者2
  ord.rst_charge_user_info -> ''date_2'' AS charge2_date,--担当時刻2
  ord.rst_running_time AS running_time,--透析運転時間
  TRIM((to_char((to_number(substring(to_char(ord.rst_end_date-ord.rst_start_date,''HH24MI''),1,2),''99'') * 60 + to_number(substring(to_char(ord.rst_end_date-ord.rst_start_date,''HH24MI''),3,2),''99'')),''999999999''))) AS running_time_cal,--透析運転時間_計算
  COALESCE(ord.pull_leave_amount, 0) AS pull_leave_amount,--引き残し量
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_weight_info ->> ''weight_before'', ''FM999.99'' ), ''FM990.99'' ), '''') AS weight_before,
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_weight_info ->> ''weight_after'', ''FM999.99'' ), ''FM990.99'' ), '''') AS weight_after,
	CASE WHEN LENGTH(TO_CHAR(ord.ord_no, ''FM9999999999999999999'')) >= 12 THEN TO_CHAR(ord.ord_no, ''FM9999999999999999999'') ELSE LPAD(TO_CHAR(ord.ord_no, ''FM9999999999999999999''), 12, ''0'') END AS ord_no12,
  COALESCE(TO_CHAR( ord.up_date, ''YYYYMMDDHH24MISS'' ), '''') AS up_date14,
  COALESCE(ord.ind_schedule_user_info ->> ''ind_user_id'', '''') AS ind_user_id,
  COALESCE(TO_CHAR( ord.up_date, ''YYYYMMDD'' ), '''') AS up_date8,
  COALESCE(TO_CHAR( ord.up_date, ''HH24MISS'' ), '''') AS up_date6 
  FROM
    ord_main AS ord
    LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd
    LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
    LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
    LEFT OUTER JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmx ON mmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmmx ON mmmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
WHERE
  ord.ord_no =  @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC連携）実績）透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600404, 'WITH user_map AS (
SELECT user_id, in_hospital_cd_1,in_hospital_cd_2
FROM mst_personal_user mpu
WHERE facility_cd = @facilityCd
)
SELECT jsonb_agg(user_map)::text AS user_list
FROM user_map', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '利用者マスタ院内コード取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600403, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
)
, get_EXAMINCODE_POSITION AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''USER_COOP_CD_NO''
)
, def_doctor AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''DEF_DOCTOR''
)
, def_course AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''DEF_COURSE''
)
, get_doctor AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''GET_DOCTOR''
)
, get_course AS (
    SELECT
        *
    FROM
        coop_ini_info
    WHERE
        key2 = ''GET_COURSE''
)
, staff_cd_list AS (
    SELECT
        users ->> ''user_id'' AS user_id,
        ROW_NUMBER() OVER(ORDER BY VALUES ->> ''ctl_no'') AS row_no
    FROM
        pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS VALUES
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        VALUES ->> ''staff_cd'' = users ->> ''user_id''
    WHERE
        pm.facility_cd = @facilityCd
        AND pm.pat_id = @patId
        AND pm.is_del = ''0''
        AND VALUES ->> ''is_main'' = ''1''
)
, ind_send_doctor AS (
    SELECT
        CASE
            (@messageType::TEXT)
            WHEN ''1'' THEN encode(substring(scj.dump FROM 163 FOR 10), ''escape'')
            WHEN ''2'' THEN encode(substring(scj.dump FROM 131 FOR 10), ''escape'')
        END AS ind_doctor,
        accept_no
    FROM
        sys_coop_journal scj
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND pat_id = @patId
        AND ord_no = @ordNo
        AND coop_cd = ''ind_dial''
    UNION
    SELECT
        ''          '' AS ind_doctor,
        0 AS accept_no
    ORDER BY
        accept_no DESC
    LIMIT 1
)
, dialysis_course_cd AS (
    SELECT
        pm.medical_care_info ->>''dialysis_course_cd'' AS dialysis_course_cd
    FROM
        pat_main pm
    LEFT JOIN mst_course mc ON
        pm.medical_care_info ->>''dialysis_course_cd'' = mc.course_cd::TEXT
        AND mc.facility_cd = @facilityCd
    WHERE
        pm.facility_cd = @facilityCd
        AND pm.pat_id = @patId
        AND pm.is_del = ''0''
)
, get_request_userid AS (
    SELECT
        CASE (SELECT value FROM get_doctor)
            WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor'', ''''), ''deff'')
            WHEN ''1'' THEN COALESCE(
                NULLIF((SELECT user_id::TEXT FROM staff_cd_list WHERE row_no = ''1''), ''''),
                NULLIF((SELECT user_id::TEXT FROM staff_cd_list WHERE row_no = ''2''), ''''),
                ''deff''
            )
            WHEN ''2'' THEN COALESCE(
                NULLIF((SELECT trim(ind_doctor::TEXT) FROM ind_send_doctor), ''''),
                ''deff''
            )
        END AS ind_doctor
    FROM
        pat_coop_detail pcd
    WHERE
        pcd.pat_id = @patId
        AND is_del = ''0''
        AND coop_version = @coopVersion
)
, collationed_userid AS (
    SELECT
        CASE
            WHEN co.ind_doctor = ''deff'' THEN (
                SELECT value FROM def_doctor
            )
            WHEN (SELECT value FROM get_doctor) = ''0'' THEN co.ind_doctor
            WHEN (SELECT value FROM get_doctor) = ''2'' THEN co.ind_doctor
            WHEN (SELECT value FROM get_doctor) = ''1'' THEN 
            	CASE (SELECT value FROM get_EXAMINCODE_POSITION)
                WHEN ''1'' THEN mpl ->> ''in_hospital_cd_1''
                WHEN ''2'' THEN mpl ->> ''in_hospital_cd_2''
            END
        END AS request_userid
    FROM
        (SELECT ind_doctor FROM get_request_userid) AS co
    LEFT JOIN jsonb_array_elements(@mstPersonalList) AS mpl ON
        co.ind_doctor != ''deff''
        AND co.ind_doctor = mpl ->> ''user_id''
        AND (SELECT value FROM get_doctor) != ''2''
)
, rst_nec_bed_course AS ( --ベッド番号・科コード対応(実績)
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC_BED_COURSE''
        AND info ->> ''key2'' = (SELECT rst_bed_cd FROM ord_main WHERE ord_no = @ordNo)::text
)
, get_ind_department_cd AS (
    SELECT
        CASE
            (SELECT value FROM get_course)
            WHEN ''0'' THEN COALESCE(
                NULLIF(pcd.save_2->>''instruction_department'', ''''),
                (SELECT value FROM def_course)
            )
            WHEN ''1'' THEN COALESCE(
                (SELECT mc.in_hospital_cd_1 FROM mst_course mc WHERE mc.course_cd::TEXT = (SELECT dialysis_course_cd FROM dialysis_course_cd) AND mc.facility_cd = @facilityCd),
                (SELECT value FROM def_course)
            )
            WHEN ''2'' THEN COALESCE(
                NULLIF((SELECT value FROM rst_nec_bed_course), ''''),
                (SELECT value FROM def_course)
            )
        END AS ind_depart_code
    FROM
        pat_coop_detail pcd
    WHERE
        pcd.pat_id = @patId
        AND is_del = ''0''
        AND coop_version = @coopVersion
)
SELECT
    collationed_userid.request_userid,
    get_ind_department_cd.ind_depart_code
FROM
    collationed_userid,
    get_ind_department_cd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '透析レポート連携院内コード取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -600300, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -600404, "field_name": "user_list", "replace_var": "@mstPersonalList"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600402, 'select
	CASE WHEN LENGTH(hosp_pat_id) >= @patidPatidfig THEN hosp_pat_id ELSE LPAD(trim(hosp_pat_id), @patidPatidfig, ''0'') END AS padding_hpid
    from
        pat_personal_main
    where
        is_del = ''0''
        and
        pat_id = @patId', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者ID桁数設定値取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -600401, "field_name": "patid_patidfig", "replace_var": "@patidPatidfig"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600401, 'SELECT
        COALESCE(info->>''value'', info->>''default_v'') as patid_patidfig
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key0'' = @key0
        AND info->>''key1'' = ''NEC''
        AND info->>''key2'' = ''PATID_PATIDFIG''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)
        AND COALESCE(NULLIF(info->>''value'', ''''), NULL) IS NOT NULL', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者ID桁数設定値取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600303, 'WITH IND_ORDER_NO_HEADER_cd AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ind_header_cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''IND_ORDER_NO_HEADER''
)
, DIALYSIS_ORDER_NO_HEADER_cd AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS dialysis_header_cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''DIALYSIS_ORDER_NO_HEADER''
)
, check_ind_dial AS (
    SELECT crud
    FROM sys_coop_journal
    WHERE
        ord_no = @ordNo
        AND facility_cd = @facilityCd
        AND is_del = ''0''
        AND coop_cd = ''ind_dial''
        AND ana_result = ''9''
        AND coop_result = ''9''
    ORDER BY out_reg_date DESC
    LIMIT 1
)
SELECT
    CASE
    WHEN (SELECT crud FROM check_ind_dial) IN (''C'', ''U'') THEN concat((SELECT ind_header_cd FROM IND_ORDER_NO_HEADER_cd), to_char(ord.ord_no, ''FM00000000000''), ''000'')
    ELSE ''0000000000000000''
    END AS ind_ord_no,
    concat((SELECT dialysis_header_cd FROM DIALYSIS_ORDER_NO_HEADER_cd), to_char(ord.ord_no, ''FM00000000000''), ''000'') AS rst_ord_no,
    TO_CHAR(COALESCE(ord.rst_dw, 0), ''FM000V9'') AS dw
FROM
    ord_main AS ord
WHERE
    ord.ord_no =  @ordNo
    AND ord.facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)オーダ番号・DW', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600302, 'SELECT primary_disease_cd ::text AS primary_disease_cd
FROM pat_personal_main
WHERE facility_cd = @facilityCd
AND pat_id = @patId
AND is_del = ''0'';
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600300, 'WITH user_map AS (
SELECT user_id, disp_user_id
FROM mst_user_authentication mua
WHERE facility_cd = @facilityCd
)
SELECT jsonb_agg(user_map)::text AS user_list
FROM user_map', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600201, 'SELECT
	COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS update_flg
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
	facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''key0'' = ''HR''
	AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
	AND info ->> ''key2'' = ''UPDATE_STAFF_CLASS''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携のUPDATE_DEL_FLG', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600200, 'WITH sch_start_time AS (
       SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
       FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
       WHERE facility_cd = @facilityCd
              AND is_del = ''0''
              AND COALESCE(info ->> ''key0'', '''') = @key0
              AND info ->> ''key1'' = ''COOP_CONFIG''
              AND info ->> ''key2'' = ''SCH_START_TIME''
),
orderreqsend_bed_period_extend AS (
       SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
       FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
       WHERE facility_cd = @facilityCd
              AND is_del = ''0''
              AND COALESCE(info ->> ''key0'', '''') = @key0
              AND info ->> ''key1'' = ''NEC''
              AND info ->> ''key2'' = ''ORDERREQSEND_BED_PERIOD_EXTEND''
),
nec_bed_period_conv AS (
       SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
       , info ->> ''key2'' AS key2
       FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
       WHERE facility_cd = @facilityCd
              AND is_del = ''0''
              AND COALESCE(info ->> ''key0'', '''') = @key0
              AND info ->> ''key1'' = ''NEC_BED_PERIOD_CONV''
)
SELECT
    CASE (SELECT value FROM sch_start_time)
        WHEN ''0'' THEN substring(mkr.kur_standard_start_time, 1, 4)
        WHEN ''1'' THEN ord.ind_treat_start_time
        END                                                          AS treatment_start_time,
    CASE (SELECT value FROM orderreqsend_bed_period_extend)
        WHEN ''0'' THEN
            CASE mkr.kur_name
                WHEN ''午前'' THEN ''1''
                WHEN ''午後'' THEN ''2''
                WHEN ''夜間'' THEN ''3''
                ELSE '' ''
                END
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT value FROM nec_bed_period_conv WHERE key2 = mkr.in_hospital_cd_1), ''''), '''')
        END AS bed_reservation_time
    FROM ord_main AS ord
    LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd
    WHERE ord.ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600116, 'SELECT
  user_id,
  CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS user_full_name
FROM mst_personal_user 
WHERE user_id = @userId;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC治療情報「指示：加算情報」の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -600115, "field_name": "user_id", "replace_var": "@userId"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600115, 'SELECT user_id AS user_id
FROM mst_user_authentication
WHERE facility_cd = @facilityCd
AND disp_user_id = @dispUserId;', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC治療情報「指示：加算情報」の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600114, 'UPDATE pat_coop_detail 
SET
  save_3 = save_3 || jsonb_build_array(jsonb_build_object(
    ''comment_number'', NULLIF(''@save3.comment_number'', ''''),
    ''comment_type'', NULLIF(''@save3.comment_type'', ''''),
    ''comment_content'', NULLIF(''@save3.comment_content'', '''')
    )),
  user_id = @userId,
  up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0''
  AND is_disp = ''1''
  AND coop_save_no = @coopSaveNo
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC治療情報「指示：加算情報」の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600113, 'WITH save2_data AS (
SELECT
    concat(''指示医:'', ''@userFullName'', ''
透析開始日:'', save_2 ->> ''start_date_regular'', ''
透析終了日:'',save_2 ->> ''end_date_regular'', ''
血液浄化法:'',save_2 ->> ''blood_purification_method'', ''
DW:'',save_2 ->> ''dw'', ''
オーダ番号:'',save_2 ->> ''ord_no'', ''
'') AS save2_info,
save_3
FROM
  pat_coop_detail
WHERE
  pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND coop_version = ''@coopVersion''
  AND save_2 ->> ''ord_no''::TEXT = ''@save2.ordNo''
  AND is_del = ''0''
  AND is_disp = ''1''
LIMIT 1
), save3_tmp AS (
SELECT elem->>''comment_type'' AS comment_type,
    string_agg(elem->>''comment_content'', E''\n'') AS comment_content
    FROM save2_data
CROSS JOIN
    LATERAL jsonb_array_elements(save_3::jsonb) AS elem
    WHERE
    elem->>''comment_type'' IS NOT NULL
GROUP BY
    elem->>''comment_type''
), save3_data AS (
    SELECT string_agg(CONCAT(
    CASE comment_type 
        WHEN ''01'' THEN ''原疾患:'' 
        WHEN ''20'' THEN ''指示コメント:'' 
        WHEN ''60'' THEN ''会計コメント:'' 
    END, comment_content), E''\n'') AS save3_info
FROM save3_tmp
), result_data AS (
  SELECT CONCAT((SELECT save2_info FROM save2_data), (SELECT save3_info FROM save3_data)) AS result_data
), eve_sub_cate_inhosp_no AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND is_disp = ''1''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''MST''
  AND info ->> ''key2'' = ''PAT_EVENT_SUB_CATEGORY''
), sub_categories AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND is_disp = ''1''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''NEC''
  AND info ->> ''key2'' = ''SUB_CATEGORIES''
), eve_sub_cate_info AS(
SELECT
  facility_cd,
  sub_category_cd,
  sub_category_name,
  use_type,
  template_cd,
  category_cd
FROM
    mst_pat_event_sub_category AS sub
WHERE
    facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND is_disp = ''1''
  AND CASE (SELECT value FROM eve_sub_cate_inhosp_no)
  WHEN ''2'' THEN
  CASE
    WHEN CURRENT_DATE >= in_hosp_a_startdate
    AND CURRENT_DATE >= in_hosp_b_startdate
    THEN CASE
        WHEN in_hosp_a_startdate >= in_hosp_b_startdate
            THEN in_hospital_cd_a2
        WHEN in_hosp_a_startdate < in_hosp_b_startdate
            THEN in_hospital_cd_b2
        END
    WHEN CURRENT_DATE >= in_hosp_a_startdate
    AND (CURRENT_DATE < in_hosp_b_startdate
        OR in_hosp_b_startdate IS NULL)
        THEN in_hospital_cd_a2
    WHEN (CURRENT_DATE < in_hosp_a_startdate
        OR in_hosp_a_startdate IS NULL)
    AND CURRENT_DATE >= in_hosp_b_startdate
        THEN in_hospital_cd_b2
    ELSE NULL
  END
  WHEN ''3'' THEN
  CASE
    WHEN CURRENT_DATE >= in_hosp_a_startdate
    AND CURRENT_DATE >= in_hosp_b_startdate
    THEN CASE
        WHEN in_hosp_a_startdate >= in_hosp_b_startdate
            THEN in_hospital_cd_a3
        WHEN in_hosp_a_startdate < in_hosp_b_startdate
            THEN in_hospital_cd_b3
        END
    WHEN CURRENT_DATE >= in_hosp_a_startdate
    AND (CURRENT_DATE < in_hosp_b_startdate
        OR in_hosp_b_startdate IS NULL)
        THEN in_hospital_cd_a3
    WHEN (CURRENT_DATE < in_hosp_a_startdate
        OR in_hosp_a_startdate IS NULL)
    AND CURRENT_DATE >= in_hosp_b_startdate
        THEN in_hospital_cd_b3
    ELSE NULL
  END
  WHEN ''4'' THEN
  CASE
    WHEN CURRENT_DATE >= in_hosp_a_startdate
    AND CURRENT_DATE >= in_hosp_b_startdate
    THEN CASE
        WHEN in_hosp_a_startdate >= in_hosp_b_startdate
            THEN in_hospital_cd_a4
        WHEN in_hosp_a_startdate < in_hosp_b_startdate
            THEN in_hospital_cd_b4
        END
    WHEN CURRENT_DATE >= in_hosp_a_startdate
    AND (CURRENT_DATE < in_hosp_b_startdate
        OR in_hosp_b_startdate IS NULL)
        THEN in_hospital_cd_a4
    WHEN (CURRENT_DATE < in_hosp_a_startdate
        OR in_hosp_a_startdate IS NULL)
    AND CURRENT_DATE >= in_hosp_b_startdate
        THEN in_hospital_cd_b4
    ELSE NULL
  END
  ELSE
  CASE
    WHEN CURRENT_DATE >= in_hosp_a_startdate
    AND CURRENT_DATE >= in_hosp_b_startdate
    THEN CASE
        WHEN in_hosp_a_startdate >= in_hosp_b_startdate
            THEN in_hospital_cd_a1
        WHEN in_hosp_a_startdate < in_hosp_b_startdate
            THEN in_hospital_cd_b1
        END
    WHEN CURRENT_DATE >= in_hosp_a_startdate
    AND (CURRENT_DATE < in_hosp_b_startdate
        OR in_hosp_b_startdate IS NULL)
        THEN in_hospital_cd_a1
    WHEN (CURRENT_DATE < in_hosp_a_startdate
        OR in_hosp_a_startdate IS NULL)
    AND CURRENT_DATE >= in_hosp_b_startdate
        THEN in_hospital_cd_b1
    ELSE NULL
  END
  END = ANY (string_to_array((SELECT value FROM sub_categories), '',''))
  ), event_info AS (
SELECT
  sub_cata.facility_cd,
  sub_cata.sub_category_cd,
  sub_cata.sub_category_name,
  sub_cata.use_type,
  eve_temp.input_params,
  eve_temp.template_cd,
  eve_temp.template_name,
  eve_cata.category_cd,
  eve_cata.category_name
FROM
  eve_sub_cate_info sub_cata
JOIN mst_pat_event_data_template eve_temp
ON
  sub_cata.template_cd = eve_temp.template_cd
  AND sub_cata.facility_cd = eve_temp.facility_cd
  AND eve_temp.is_del = ''0''
  AND eve_temp.is_disp = ''1''
JOIN mst_pat_event_category eve_cata
ON
  sub_cata.category_cd = eve_cata.category_cd
  AND sub_cata.facility_cd = eve_cata.facility_cd
  AND eve_cata.is_del = ''0''
  AND eve_cata.is_disp = ''1''
WHERE
  (eve_temp.input_params -> 0 ->> ''format_class'') IN (''0'', ''1'') -- 一つ目の要素がテキストエリア or テキストボックス
), processed_data AS (
    SELECT jsonb_build_object(
        ''format_class'', (elem->>''format_class'')::int,
        ''result_value'', 
        CASE
          WHEN idx = 1 THEN (SELECT result_data FROM result_data)
          ELSE ''''
        END
    ) AS new_elem,
    sub_category_cd,
    idx
    FROM event_info
    CROSS JOIN
    LATERAL jsonb_array_elements(input_params) WITH ORDINALITY AS info(elem, idx)
    WHERE elem->>''format_class'' NOT IN (''2'', ''3'', ''4'', ''6'', ''7'', ''8'')
    UNION ALL
    SELECT jsonb_build_object(
        ''format_class'', (elem->>''format_class'')::int,
        ''result_value'', 
        CASE
          WHEN elem->>''format_class'' IN (''3'', ''4'', ''6'', ''7'') THEN ''[]''::jsonb
          WHEN elem->>''format_class'' = ''2'' THEN jsonb_build_array(jsonb_build_object(
            ''file_name'', '''',
            ''file_path'', '''',
            ''file_modified_time'', ''''))
          WHEN elem->>''format_class'' = ''8'' THEN jsonb_build_object(
            ''unit'', '''',
            ''score'', ''0'')
        END
    ) AS new_elem,
    sub_category_cd,
    idx
    FROM event_info
    CROSS JOIN
    LATERAL jsonb_array_elements(input_params) WITH ORDINALITY AS info(elem, idx)
    WHERE elem->>''format_class'' IN (''2'', ''3'', ''4'', ''6'', ''7'', ''8'')
    
    ORDER BY sub_category_cd ASC, idx ASC
), final_data AS (
    SELECT jsonb_agg(new_elem) || jsonb_build_array(jsonb_build_object(''upDate'', to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD"T"HH24:MI:SS.MS"+00:00"''))) AS result_info,
    sub_category_cd
    FROM processed_data
    GROUP BY sub_category_cd
)
INSERT
  INTO
  pat_event
(pat_id,
  facility_cd,
  fn_ctl_no,
  event_status,
  template_cd,
  template_name,
  category_cd,
  category_name,
  ord_no,
  input_params,
  event_start_date,
  sub_category_cd,
  sub_category_name,
  result_params,
  score_total,
  reg_staff_info,
  up_staff_info,
  bbs_ctl_no,
  is_newest,
  is_del,
  reg_date,
  up_date,
  letter_info,
  use_type,
  event_end_date,
  event_start_time,
  event_end_time,
  report_url,
  report_date)
SELECT 
@patId, -- pat_id 
facility_cd, -- facility_cd 
0, -- fn_ctl_no 
''1'', -- event_status 
template_cd, -- template_cd 
template_name, -- template_name 
category_cd, -- category_cd 
category_name, -- category_name 
NULL, -- ord_no 
input_params, -- input_params 
TO_CHAR(CURRENT_DATE, ''YYYYMMDD''), -- event_start_date 
event_info.sub_category_cd, -- sub_category_cd 
sub_category_name, -- sub_category_name 
result_info, -- result_params
NULL, -- score_total 
jsonb_build_object(
  ''reg_staff_cd'', NULLIF(''@userId'', ''''),
  ''reg_staff_name'', NULLIF(''@userFullName'', '''')
), -- reg_staff_info 
jsonb_build_object(
  ''up_staff_cd'', NULLIF(''@userId'', ''''),
  ''up_staff_name'', NULLIF(''@userFullName'', '''')
), -- up_staff_info 
0, -- bbs_ctl_no 
''1'', -- is_newest 
''0'', -- is_del 
CURRENT_TIMESTAMP, -- reg_date 
CURRENT_TIMESTAMP, -- up_date 
NULL, -- letter_info 
use_type, -- use_type 
TO_CHAR(CURRENT_DATE, ''YYYYMMDD''), -- event_end_date 
NULL, -- event_start_time 
NULL, -- event_end_time 
NULL, -- report_url 
NULL -- report_date
FROM event_info
JOIN final_data
ON event_info.sub_category_cd = final_data.sub_category_cd 
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC患者固有情報の取得_削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -600116, "field_name": "user_id", "replace_var": "@userId"}, {"sql_cd": -600116, "field_name": "user_full_name", "replace_var": "@userFullName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600112, 'WITH indication_flg AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = @key0
  AND info ->> ''key1'' = ''NEC''
  AND info ->> ''key2'' = ''INDICATION_FLG''
)
-- 値が取得できない(INDICATION_FLGが''1'')場合登録処理が実行される
SELECT
  1
WHERE
  (SELECT value FROM indication_flg) <> ''1'' 
  OR (SELECT value FROM indication_flg) IS NULL;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC患者固有情報の取得_削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600111, 'WITH pcd_info AS (
SELECT
    ''1'' AS update_target
FROM
  pat_coop_detail 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND coop_version = @coopVersion
  AND save_2 ->> ''ord_no''::TEXT = ''@save2.ordNo''
  AND is_del = ''0''
  AND is_disp = ''1''
)
SELECT pu.pat_id,
       medical_hst_info,
       in_out_visit_history_info,
       physical_info,
       is_del,
       up_date,
       reg_date,
       facility_cd,
       old_up_date_unique
FROM pat_unique pu
WHERE pu.pat_id = @patId
  AND is_del = ''0''
  AND ''1'' = (SELECT update_target FROM pcd_info)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC患者固有情報の取得_削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1604, "field_name": "pat_id", "replace_var": "@pat_id"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600110, 'WITH pcd_info AS (
SELECT
    ''1'' AS update_target
FROM
  pat_coop_detail 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND coop_version = @coopVersion
  AND save_2 ->> ''ord_no''::TEXT = ''@save2.ordNo''
  AND is_del = ''0''
  AND is_disp = ''1''
)
SELECT
    pat_id,
    facility_cd,
    is_same,
    is_implant,
    is_infect,
    is_diabetes,
    is_blood_suger_exam,
    in_out_current_state,
    in_out_plan_state,
    in_out_plan_date,
    pat_memo_info,
    addition_info,
    charge_staff_info,
    pat_group_info,
    taboo_allergy_info,
    infect_info,
    implant_info,
    tare_info,
    off_water_info,
    device_set_info,
    acceptance_status_info,
    is_del,
    up_date,
    reg_date,
    is_wheel_chair,
    medical_care_info,
    sch_ext_end_date,
    sch_ext_status,
    card_idm,
    old_up_date,
    host_notification_info,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl1
        CROSS JOIN LATERAL json_array_elements ( tbl1.pat_memo_info :: json ) RESULT 
    WHERE
        tbl1.pat_id = @patId 
    ) AS next_ctl_no_1,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl2
        CROSS JOIN LATERAL json_array_elements ( tbl2.charge_staff_info :: json ) RESULT 
    WHERE
        tbl2.pat_id = @patId 
    ) AS next_ctl_no_2,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl3
        CROSS JOIN LATERAL json_array_elements ( tbl3.taboo_allergy_info :: json ) RESULT 
    WHERE
        tbl3.pat_id = @patId 
    ) AS next_ctl_no_3,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl4
        CROSS JOIN LATERAL json_array_elements ( tbl4.infect_info :: json ) RESULT 
    WHERE
        tbl4.pat_id = @patId 
    ) AS next_ctl_no_4,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl5
        CROSS JOIN LATERAL json_array_elements ( tbl5.implant_info :: json ) RESULT 
    WHERE
        tbl5.pat_id = @patId 
    ) AS next_ctl_no_5 
FROM
    pat_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId
    AND ''1'' = (SELECT update_target FROM pcd_info)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC患者基本情報の取得_削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600109, 'select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
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
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = ''0''
and
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd
and
  ''1'' = @updateTarget', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC患者個人情報の取得_削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -600108, "field_name": "update_target", "replace_var": "@updateTarget"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600108, 'SELECT update_target FROM (
SELECT
    ''1'' AS update_target
FROM
  pat_coop_detail 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND coop_version = @coopVersion
  AND save_2 ->> ''ord_no''::TEXT = @save2.ordNo
  AND is_del = ''0''
  AND is_disp = ''1''
UNION SELECT
    ''0'' AS update_target
) AS T
ORDER BY update_target DESC
LIMIT 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC患者連携情報の取得_削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600107, 'UPDATE pat_coop_detail 
SET
  is_del = ''1'',
  is_disp = ''0'',
  up_date = CURRENT_TIMESTAMP
WHERE
  coop_save_no = @coopSaveNo
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND save_2 ->> ''ord_no''::TEXT = ''@save2.ordNo''
  AND is_del = ''0''
  AND is_disp = ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者連携情報の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600106, 'SELECT user_id
FROM ntss.mst_user_authentication
WHERE disp_user_id = @chargeStaffInfo.staffCd
AND facility_cd = @facilityCd', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC　UserID取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600105, 'UPDATE pat_personal_main 
SET
  in_out_class = CASE
    WHEN ''@dieDate_Date'' != '''' THEN 2
    ELSE in_out_class
    END
  , is_die = CASE ''@dieDate_Date'' 
    WHEN '''' THEN ''0''
    ELSE ''1'' 
    END
  , die_cd = CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , die_date = CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId''  
  AND facility_cd = ''@facilityCd''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者連携情報の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600103, 'WITH coop_no AS (
SELECT
  -- 最大値を超えた場合には最小値に設定する
  CASE
    WHEN cur_coop_ord_no + 1 > range_max
    THEN range_min
    ELSE cur_coop_ord_no + 1
  END new_coop_ord_no,
  no_of_digit,
  padding_char,
  padding_pos,
  prefix_char,
  suffix_char
FROM
  sys_coop_no
WHERE
  facility_cd = ''@facilityCd''
  AND EXISTS (
  SELECT
    1
  FROM
    jsonb_array_elements(coop_ord_cd) AS elem
  WHERE
    elem->>''ord_cd'' = ''ini_dial''
)
  AND is_disp = ''1''
  AND is_del = ''0''
  AND coop_version = ''@coopVersion''
)
-- 連携オーダ番号、パディング文字、位置、前置文字、後置文字等を用いて連携オーダ番号（文字列）を作成する
, coop_ord_no AS (
SELECT
  CONCAT(prefix_char,
  CASE
    padding_pos WHEN ''right''
    THEN RPAD(new_coop_ord_no ::TEXT,
    no_of_digit ::int,
    COALESCE(padding_char ::TEXT,
    ''0''))
    ELSE LPAD(new_coop_ord_no ::TEXT,
    no_of_digit ::int,
    COALESCE(padding_char ::TEXT,
    ''0''))
  END ::TEXT,
  suffix_char) AS coop_ord_no
FROM
  coop_no
  )
INSERT
  INTO
  pat_coop_detail( 
  facility_cd,
  pat_id,
  save_1,
  save_2,
  save_3,
  save_4,
  save_5,
  save_6,
  save_7,
  save_8,
  save_9,
  save_10,
  is_disp,
  is_del,
  user_id,
  coop_version,
  up_date,
  reg_date
)
VALUES (
  ''@facilityCd'',
  @patId,
  jsonb_build_object(''pkg'', ''HR''),
  jsonb_build_object(''ord_no'', NULLIF((SELECT coop_ord_no FROM coop_ord_no), '''')),
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  ''1'',
  ''0'',
  @userId,
  ''@coopVersion'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者連携情報の登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600021, 'WITH coop_ini_info AS (
SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
FROM
        mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
      ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND ini.is_disp = ''1''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' = ''NEC''
  AND info ->> ''key2'' = ''GET_COURSE''
        )
SELECT
  1
FROM
  coop_ini_info
WHERE
  value <> ''0''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 指示科取得先設定判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600020, 'WITH coop_ini_info AS (
SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
FROM
        mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
      ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND ini.is_disp = ''1''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' = ''NEC''
  AND info ->> ''key2'' = ''GET_DOCTOR''
        )
SELECT
  1
FROM
  coop_ini_info
WHERE
  value <> ''0''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 指示医取得先設定判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600019, 'SELECT CASE WHEN COALESCE(ord.rst_fn_dialysis_no, 0) = 0 THEN (SELECT COALESCE(NULLIF(ini_info ->> ''value'', ''''), ini_info ->> ''default_v'') FROM mst_coop_ini AS ini CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info WHERE ini.is_del = ''0'' AND ini.is_disp = ''1'' AND ini.facility_cd = @facilityCd AND COALESCE(ini_info->>''key0'','''') = ''HR'' AND TRIM(ini_info ->> ''key1'') = ''NEC'' AND TRIM(ini_info ->> ''key2'') = ''XMLGEN_DEVICE_NAME'') || ''_'' || to_char(NOW(), ''YYYYMMDDHH24MISS'') || ''_'' || journal.hosp_pat_id || ''_0.pdf'' ELSE journal.hosp_pat_id || lpad(trim(to_char(ord.rst_fn_dialysis_no, ''999999999999'')), 12, ''0'')  || lpad(trim(to_char(ord.rst_edition, ''9999'')), 4, ''0'') ||''.pdf'' END AS filename FROM sys_coop_journal journal INNER JOIN ord_main ord ON ord.ord_no = journal.ord_no WHERE journal.ord_no = @ordNo AND journal.direction = ''S'' AND journal.ana_result = ''1'' AND journal.is_del = ''0'' LIMIT 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600018, 'SELECT (SELECT COALESCE(NULLIF(ini_info ->> ''value'', ''''), ini_info ->> ''default_v'') FROM mst_coop_ini AS ini CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info WHERE ini.is_del = ''0'' AND ini.is_disp = ''1'' AND ini.facility_cd = @facilityCd AND COALESCE(ini_info->>''key0'','''') = ''HR'' AND TRIM(ini_info ->> ''key1'') = ''NEC'' AND TRIM(ini_info ->> ''key2'') = ''XMLGEN_DEVICE_NAME'') || ''_'' || to_char(NOW(), ''YYYYMMDDHH24MISS'') || ''_'' || journal.hosp_pat_id || ''_0.'' || @extension AS filename FROM sys_coop_journal journal WHERE journal.ord_no = @ordNo AND journal.direction = ''S'' AND journal.ana_result = ''1'' AND journal.is_del = ''0'' LIMIT 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600017, 'select    disp_user_id from    mst_user_authentication where    user_id = @userId', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC 透析レポート連携 データ作成者ユーザID取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -610901, "field_name": "user_id", "replace_var": "@userId"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600016, 'WITH take_cource_info AS (
  SELECT
    1 AS order_no,
    CASE
      TRIM(ini_info ->> ''value'')
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'')
      ELSE TRIM(ini_info ->> ''value'')
    END AS take_cource_flg
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) AS ini_info
  WHERE
    ini.is_del = ''0''
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd''
    AND COALESCE(ini_info ->> ''key0'', '''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND''
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG''
  UNION
  SELECT
    2 AS order_no,
    ''1'' AS take_cource_flg
  ORDER BY
    order_no ASC
  LIMIT
    1
), mst_ward_cd AS (
  SELECT
    ward_cd
  FROM
    mst_ward
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' :: TEXT
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, mst_course_cd AS (
  SELECT 
    course_cd
  FROM
    mst_course
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND facility_cd = ''@facilityCd''
    AND is_del = ''0''
)
, cource_ward_info AS (
  SELECT
    (
      CASE
        WHEN (
          SELECT
            take_cource_flg
          FROM
            take_cource_info
        ) = ''1''
        AND (''@inOutClass'') = ''1'' -- ''1''：入院
        THEN CAST((SELECT course_cd FROM mst_course_cd) AS TEXT)
        ELSE medical_care_info ->> ''main_course_cd''
      END
    ) AS main_course_cd,
    (
      select
        ward_cd
      from
        mst_ward_cd
    ) AS ward_cd
  FROM
    pat_main
  WHERE
    is_del = ''0''
    AND pat_id = @patId
)
, dialysis_start_date_info AS (
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS dialysis_start_date_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''NEC'' 
    AND TRIM(ini_info ->> ''key2'') = ''INTRODUCTION_DATE_FLG''
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS dialysis_start_date_flg 
  ORDER BY order_no ASC LIMIT 1
)
UPDATE
  pat_main
SET
  up_date = CURRENT_TIMESTAMP,
  in_out_current_state = (
    case
      ''@isDie''
      when ''1'' then ''11''
      else in_out_current_state
    end
  ),
  medical_care_info = json_build_object(
    ''main_course_cd'',
    TO_NUMBER(
      NULLIF(
        (
          SELECT
            main_course_cd
          FROM
            cource_ward_info
        ),
        ''''
      ),
      ''FM999999999''
    ),
    ''dialysis_course_cd'',
    medical_care_info -> ''dialysis_course_cd'',
    ''ward_cd'',
    (
        SELECT
          ward_cd
        FROM
          cource_ward_info
      ),
    ''dialysis_count'',
    medical_care_info -> ''dialysis_count'',
    ''purification_count'',
    medical_care_info -> ''purification_count'',
    ''other_dialysis_count'',
    medical_care_info -> ''other_dialysis_count'',
    ''pat_dialysis_count'',
    medical_care_info -> ''pat_dialysis_count'',
    ''facility_cd'',
    medical_care_info ->> ''facility_cd'',
    ''dialysis_start_date'',
    CASE (SELECT dialysis_start_date_flg FROM dialysis_start_date_info)
      WHEN ''1'' THEN NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      ELSE medical_care_info ->> ''dialysis_start_date''
      END,
    ''hospital_start_date'',
    medical_care_info ->> ''hospital_start_date''
  )
WHERE
  is_del = ''0''
  AND pat_id = @patId
  AND @is_die = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)初回指示連携、患者情報連携、患者死亡退院情報連携_患者基本情報の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600015, 'WITH new_name_info AS (
  SELECT
    CASE
        WHEN POSITION('' '' IN ''@patLastName'') = 0 AND POSITION(''　'' IN ''@patLastName'') = 0 THEN ''@patLastName''
        WHEN POSITION('' '' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM 1 FOR POSITION('' '' IN ''@patLastName'') - 1))
        ELSE TRIM(substring(''@patLastName'' FROM 1 FOR POSITION(''　'' IN ''@patLastName'') - 1))
    END AS patLastName,
    CASE
        WHEN POSITION('' '' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM POSITION('' '' IN ''@patLastName'') + 1))
        WHEN POSITION(''　'' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM POSITION(''　'' IN ''@patLastName'') + 1))
        ELSE ''''
    END AS patFirstName,
    CASE
        WHEN POSITION('' '' IN ''@patLastNmKana'') = 0 AND POSITION(''　'' IN ''@patLastNmKana'') = 0 THEN ''@patLastNmKana''
        WHEN POSITION('' '' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM 1 FOR POSITION('' '' IN ''@patLastNmKana'') - 1))
        ELSE TRIM(substring(''@patLastNmKana'' FROM 1 FOR POSITION(''　'' IN ''@patLastNmKana'') - 1))
    END AS patLastNmKana,
    CASE
        WHEN POSITION('' '' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM POSITION('' '' IN ''@patLastNmKana'') + 1))
        WHEN POSITION(''　'' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM POSITION(''　'' IN ''@patLastNmKana'') + 1))
        ELSE ''''
    END AS patFirstNmKana
)
UPDATE pat_personal_main 
SET
  fn_pat_id = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id = NULLIF(''@hospPatId'', '''')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
  , pat_last_name = personal_info_encrypt((SELECT patLastName FROM new_name_info)) 
  , pat_first_name = personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'', '''')
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = NULLIF(''@patBirthday'', '''')
  , pat_sex = CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , nationality = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , in_out_class = CASE
  	WHEN ''@dieDate_Date'' != '''' THEN 2
    WHEN ''@medicalCareInfo.wardCd'' = '''' THEN 0 
    ELSE 1
    END
  , dial_diff_com_info = ''@dialDiffComInfoValue''
  , severity_cd = CASE ''@mstSeverityCd''
    WHEN ''@'' || ''mstSeverityCd'' THEN NULL 
    ELSE TO_NUMBER(''@mstSeverityCd'', ''FM99999999999999999999999999999999'') 
    END
  , transport_cd = CASE ''@mstTransportCd''
    WHEN ''@'' || ''mstTransportCd'' THEN NULL 
    ELSE TO_NUMBER(''@mstTransportCd'', ''FM99999999999999999999999999999999'') 
    END
  , pat_contact_info = CASE ''@patContactInfoFlg'' 
    WHEN '''' THEN ''@patContactInfoValue'' 
    ELSE json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''')
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
      , ''fax''
      , NULLIF(''@patContactInfo.fax'', '''')
      , ''e_mail''
      , NULLIF(''@patContactInfo.eMail'', '''')
      , ''work_name''
      , NULLIF(''@patContactInfo.workName'', '''')
      , ''work_address''
      , NULLIF(''@patContactInfo.workAddress'', '''')
      , ''work_tel''
      , NULLIF(''@patContactInfo.workTel'', '''')
      , ''memo1''
      , NULLIF(''@patContactInfo.memo1'', '''')
      , ''memo2''
      , NULLIF(''@patContactInfo.memo2'', '''')
    ) 
    END
  , vendor_contact_info = ''@vendorContactInfoValue''
  , insurance_info = ''@insuranceInfoValue''
  , reg_date = ''@regDate''
  , up_date = CURRENT_TIMESTAMP
  , primary_disease_cd = CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE (CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' THEN NULL ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') END) 
    END
  , remote_monitor_service = CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , remote_monitor_user_id = NULLIF(''@remoteMonitorUserId'', '''')
  , remote_monitor_user_pw = NULLIF(''@remoteMonitorUserPw'', '''') 
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId''  
  AND facility_cd = ''@facilityCd''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}, {"sql_cd": -600011, "field_name": "severity_cd", "replace_var": "@mstSeverityCd"}, {"sql_cd": -600012, "field_name": "transport_cd", "replace_var": "@mstTransportCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600014, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, mst_ward_cd AS (
  SELECT
    ward_cd
  FROM
    mst_ward
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' :: TEXT
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, mst_course_cd AS (
  SELECT 
    course_cd
  FROM
    mst_course
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, cource_ward_info AS (
  SELECT 
    CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClass'') = ''1'' -- ''1''：入院
      THEN (SELECT course_cd FROM mst_course_cd)
      ELSE null
    END AS main_course_cd
    , (SELECT ward_cd FROM mst_ward_cd) AS ward_cd
)
, dialysis_start_date_info AS (
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS dialysis_start_date_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''NEC'' 
    AND TRIM(ini_info ->> ''key2'') = ''INTRODUCTION_DATE_FLG''
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS dialysis_start_date_flg 
  ORDER BY order_no ASC LIMIT 1
)
INSERT 
INTO pat_main( 
  pat_id
  , facility_cd
  , is_same
  , is_implant
  , is_infect
  , is_diabetes
  , is_blood_suger_exam
  , in_out_current_state
  , in_out_plan_state
  , in_out_plan_date
  , pat_memo_info
  , addition_info
  , charge_staff_info
  , pat_group_info
  , taboo_allergy_info
  , infect_info
  , implant_info
  , tare_info
  , off_water_info
  , device_set_info
  , acceptance_status_info
  , is_del
  , up_date
  , reg_date
  , is_wheel_chair
  , medical_care_info
  , sch_ext_end_date
  , sch_ext_status
  , card_idm
  , old_up_date
  , host_notification_info
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , NULLIF(''@isSame'', '''')
  , NULLIF(''@isImplant'', '''')
  , NULLIF(''@isInfect'', '''')
  , NULLIF(''@isDiabetes'', '''')
  , NULLIF(''@isBloodSugerExam'', '''')
  , NULLIF(''@inOutCurrentState'', '''')
  , NULLIF(''@inOutPlanState'', '''')
  , CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''@chargeStaffInfoValue''
  , ''@patGroupInfoValue''
  , ''@tabooAllergyInfoValue''
  , COALESCE(NULLIF(''@infectInfo'', ''''), ''[]'') ::JSONB
  , ''@implantInfoValue''
  , ''@tareInfoValue''
  , ''@offWaterInfoValue''
  , ''@deviceSetInfoValue''
  , ''@acceptanceStatusInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@isWheelChair'', '''')
  , json_build_object( 
      ''main_course_cd''
      , (SELECT main_course_cd FROM cource_ward_info)
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
      , ''ward_cd''
      , (SELECT ward_cd FROM cource_ward_info)
      , ''dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCount'', ''''), ''FM999999999'')
      , ''purification_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.purificationCount'', ''''), ''FM999999999'')
      , ''other_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.otherDialysisCount'', ''''), ''FM999999999'')
      , ''pat_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.patDialysisCount'', ''''), ''FM999999999'')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , CASE (SELECT dialysis_start_date_flg FROM dialysis_start_date_info)
      WHEN ''1'' THEN NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      ELSE NULL
      END
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    )
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)初回指示連携、患者情報連携、患者死亡退院情報連携_患者基本情報の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600013, 'WITH new_name_info AS (
  SELECT
    CASE
        WHEN POSITION('' '' IN ''@patLastName'') = 0 AND POSITION(''　'' IN ''@patLastName'') = 0 THEN ''@patLastName''
        WHEN POSITION('' '' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM 1 FOR POSITION('' '' IN ''@patLastName'') - 1))
        ELSE TRIM(substring(''@patLastName'' FROM 1 FOR POSITION(''　'' IN ''@patLastName'') - 1))
    END AS patLastName,
    CASE
        WHEN POSITION('' '' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM POSITION('' '' IN ''@patLastName'') + 1))
        WHEN POSITION(''　'' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM POSITION(''　'' IN ''@patLastName'') + 1))
        ELSE ''''
    END AS patFirstName,
    CASE
        WHEN POSITION('' '' IN ''@patLastNmKana'') = 0 AND POSITION(''　'' IN ''@patLastNmKana'') = 0 THEN ''@patLastNmKana''
        WHEN POSITION('' '' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM 1 FOR POSITION('' '' IN ''@patLastNmKana'') - 1))
        ELSE TRIM(substring(''@patLastNmKana'' FROM 1 FOR POSITION(''　'' IN ''@patLastNmKana'') - 1))
    END AS patLastNmKana,
    CASE
        WHEN POSITION('' '' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM POSITION('' '' IN ''@patLastNmKana'') + 1))
        WHEN POSITION(''　'' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM POSITION(''　'' IN ''@patLastNmKana'') + 1))
        ELSE ''''
    END AS patFirstNmKana
)
INSERT 
INTO pat_personal_main( 
  fn_pat_id
  , hosp_pat_id
  , nkk_pat_id
  , facility_cd
  , pat_last_name
  , pat_first_name
  , pat_last_name_kana
  , pat_first_name_kana
  , pat_last_name_alpha
  , pat_first_name_alpha
  , pat_birth_name
  , pat_birth_name_kana
  , pat_birth_name_alpha
  , pat_birthday
  , pat_sex
  , nationality
  , pat_blood_type_abo
  , pat_blood_type_rh
  , pat_blood_type_serovar
  , in_out_class
  , is_die
  , die_cd
  , die_date
  , dial_diff_com_info
  , severity_cd
  , transport_cd
  , pat_contact_info
  , other_contact_info
  , vendor_contact_info
  , insurance_info
  , is_del
  , up_date
  , reg_date
  , primary_disease_cd
  , remote_monitor_service
  , remote_monitor_user_id
  , remote_monitor_user_pw
) 
VALUES ( 
  NULLIF(''@fnPatId'', '''')
  , NULLIF(''@hospPatId'', '''')
  , NULLIF(''@nkkPatId'', '''')
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt((SELECT patLastName FROM new_name_info)) 
  , personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , NULLIF(''@patBirthday'', '''')
  , CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , NULLIF(''@nationality'', '''')
  , CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , CASE
  	WHEN ''@isDie'' = ''1'' THEN 2
    WHEN ''@medicalCareInfo.wardCd'' = '''' THEN 0 
    ELSE 1
    END
  , NULLIF(''@isDie'', '''')
  , CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') ::JSONB
  , CASE ''@mstSeverityCd'' 
    WHEN ''@'' || ''mstSeverityCd'' THEN NULL
    ELSE TO_NUMBER(''@mstSeverityCd'', ''FM99999999999999999999999999999999'')
    END
  , CASE ''@mstTransportCd'' 
    WHEN ''@'' || ''mstTransportCd'' THEN NULL
    ELSE TO_NUMBER(''@mstTransportCd'', ''FM99999999999999999999999999999999'')
    END
  , CASE ''@patContactInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''zip_cd''
      , NULL
      , ''address''
      , NULL
      , ''tel1''
      , NULL
      , ''tel2''
      , NULL
      , ''fax''
      , NULL
      , ''e_mail''
      , NULL
      , ''work_name''
      , NULL
      , ''work_address''
      , NULL
      , ''work_tel''
      , NULL
      , ''memo1''
      , NULL
      , ''memo2''
      , NULL
    ) 
    ELSE json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''')
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
      , ''fax''
      , NULLIF(''@patContactInfo.fax'', '''')
      , ''e_mail''
      , NULLIF(''@patContactInfo.eMail'', '''')
      , ''work_name''
      , NULLIF(''@patContactInfo.workName'', '''')
      , ''work_address''
      , NULLIF(''@patContactInfo.workAddress'', '''')
      , ''work_tel''
      , NULLIF(''@patContactInfo.workTel'', '''')
      , ''memo1''
      , NULLIF(''@patContactInfo.memo1'', '''')
      , ''memo2''
      , NULLIF(''@patContactInfo.memo2'', '''')
    ) 
    END
  , ''@otherContactInfoValue''
  , ''@vendorContactInfoValue''
  , ''@insuranceInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , NULLIF(''@remoteMonitorUserId'', '''')
  , NULLIF(''@remoteMonitorUserPw'', '''')
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}, {"sql_cd": -600011, "field_name": "severity_cd", "replace_var": "@mstSeverityCd"}, {"sql_cd": -600012, "field_name": "transport_cd", "replace_var": "@mstTransportCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600012, 'SELECT
   mst_transport.transport_cd AS transport_cd
  FROM
    mst_transport
  WHERE
    mst_transport.in_hospital_cd_1 = @transportCd
  AND
    mst_transport.facility_cd = @facilityCd
  AND
    mst_transport.is_disp = ''1''
  AND
    mst_transport.is_del = ''0''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'テスト用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600011, 'SELECT
  mst_severity.severity_cd AS severity_cd
FROM
  mst_severity
WHERE
  mst_severity.in_hospital_cd_1 = @severityCd
AND
  mst_severity.facility_cd = @facilityCd
AND
  mst_severity.is_disp = ''1''
AND
  mst_severity.is_del = ''0''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'テスト用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600001, ' select
 hosp_pat_id,
 lpad(hosp_pat_id, 12, ''0'') AS hosp_pat_id12,
 CASE WHEN LENGTH(hosp_pat_id) >= 8 THEN hosp_pat_id ELSE LPAD(hosp_pat_id, 8, ''0'') END AS hosp_pat_id8,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 pat_birthday as pat_birthday8,
 case when pat_birthday is null then null
 else date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD'')))
 end as pat_age,
 case when pat_sex = 1 then ''M''   when pat_sex = 2 then ''F'' else ''0'' end as pat_sex,
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
 die_cd as die_cd1,
 -- 透析困難有無
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date
 from
 pat_personal_main
 where
 is_del = ''0''
 and
 pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 透析レポート', '2023-07-17 21:00:58.979', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-205, 'SELECT 
    CONCAT(
        CASE
            WHEN LENGTH(trim(@hosp_pat_id_text)) > @digit THEN trim(@hosp_pat_id_text)
            ELSE lpad(trim(@hosp_pat_id_text), @digit, ''0'')
        END, 
        lpad(ord.ord_no::text, 12, ''0'')
    ) AS tar_key,
    CONCAT(
        CASE
            WHEN LENGTH(trim(@hosp_pat_id_text)) > @digit THEN trim(@hosp_pat_id_text)
            ELSE lpad(trim(@hosp_pat_id_text), @digit, ''0'')
        END, 
        lpad(ord.ord_no::text, 12, ''0''),
        lpad(ord.rst_edition::text, 4, ''0'') -- 固定長はそのまま
    ) AS xml_key
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo;
   

', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)TAR,XML送信データキー(pat_id,ord_no)', '2020-05-26 16:49:16.583', CURRENT_TIMESTAMP, '[{"sql_cd": -600401, "field_name": "patid_patidfig", "replace_var": "@digit"}, {"sql_cd": -98, "field_name": "hosp_pat_id_text", "replace_var": "@hosp_pat_id_text"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-204, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
)
, sendmsg_gen AS ( --項目世代番号
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''SENDMSG_GEN''
)
, func_addition AS ( --加算(患者)機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ADDITION''
)
, va_coop_cd_no AS ( --VAの連携コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_COOP_CD_NO''
)
, va_func_cd_no AS ( --VAの機能コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_FUNC_CD_NO''
)
, func_bloodaccess AS ( --VAの機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_BLOODACCESS''
)
, treatment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_COOP_CD_NO''
)
, treatment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_FUNC_CD_NO''
)
, func_treat AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_TREAT''
)
, dialyzer_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_COOP_CD_NO''
)
, dialyzer_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_FUNC_CD_NO''
)
, func_dialyzer AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYZER''
)
, other_dialyzer_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYZER_UNIT''
)
, func_other_item AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_OTHER_ITEM''
)
, medicine_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_COOP_CD_NO''
)
, medicine_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_FUNC_CD_NO''
)
, func_medicine AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_MEDICINE''
)
, func_koucoagulant AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_KOUCOAGULANT''
)
, equipment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_COOP_CD_NO''
)
, equipment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_FUNC_CD_NO''
)
, func_aneedle AS ( --穿刺針
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANEEDLE''
)
, func_consumption AS ( --医療材料
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_CONSUMPTION''
)
, other_koucoagulant_speed_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_KOUCOAGULANT_SPEED_UNIT''
)
, func_another_add AS ( --時間外薬剤
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANOTHER_ADD''
)
, addmed_cd as ( --時間外薬剤コードリスト
	select *
	FROM coop_ini_info
	WHERE key2 like ''MEDICINE_ADDMED_CODE%''
)
, difficult_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_COOP_CD_NO''
)
, difficult_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_FUNC_CD_NO''
)
, addition_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_COOP_CD_NO''
)
, addition_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_FUNC_CD_NO''
)
, other_dialysis_time AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_TIME''
)
, other_dialysis_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_UNIT''
)
, func_item_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ITEM_COMMENT''
)
, func_dialysis_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT''
)
, func_dialysis_comment2 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT2''
)
, func_dialysis_comment3 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT3''
)
, equip_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, equip_order AS (
  SELECT
    index_no ::int AS meq_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment''
)
, equip_class_order as (
  SELECT
    index_no ::int AS meq_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
  SELECT
    equipment_cd
    , equipment_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , equip_order.meq_code_order
    , equip_class_order.meq_class_code_order
  FROM mst_equipment meq
  LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
  LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
  WHERE facility_cd = @facilityCd
)
, medi_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS a1
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, medi_order AS (
  SELECT
    index_no ::int AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
  SELECT
    index_no ::int AS medi_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
  SELECT
    index_no ::int AS timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
  SELECT
    index_no ::int AS procedure_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
  SELECT
    medicine_cd
    , medicine_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , medi_order.medi_code_order
    , medi_class_order.medi_class_code_order
  FROM mst_medicine mmd
  LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
  WHERE facility_cd = @facilityCd
)
, pcd_save_3 AS (
  SELECT
    t.values ->> ''item_code'' AS item_code
    , t.values ->> ''function_code'' AS function_code
    , t.values ->> ''item_generation'' AS item_generation
    , t.idx AS idx
  FROM pat_coop_detail pcd
  CROSS JOIN jsonb_array_elements(pcd.save_3) WITH ORDINALITY AS t(values, idx)
  WHERE pat_id = @patId
)

SELECT
  LPAD(TO_CHAR(ROW_NUMBER() OVER (), ''FM000''), 3, '' '') AS cost_no
  , cost_fin.*
FROM
  (
    SELECT
      all_cost.*
    FROM
      (
        SELECT
          --加算(患者)Ver1
          ''指示詳細'' AS detail_id
          , ''加算(患者)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_addition) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''01'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''20''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION

        SELECT
          --VA情報
          ''指示詳細'' AS detail_id
          , ''VA'' AS sbt_key
          , CASE (SELECT value FROM va_coop_cd_no)
            WHEN ''1'' THEN mva.in_hospital_cd_1
            WHEN ''2'' THEN mva.in_hospital_cd_2
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM va_func_cd_no)
            WHEN ''1'' THEN COALESCE(mva.in_hospital_cd_1, (SELECT value FROM func_bloodaccess))
            WHEN ''2'' THEN COALESCE(mva.in_hospital_cd_2, (SELECT value FROM func_bloodaccess))
            END AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''02'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_va AS mva
            ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND ''2'' = @messageType
        UNION 

        SELECT --治療項目情報
          ''指示詳細'' AS detail_id
          , ''治療項目'' AS sbt_key
          , CASE (SELECT value FROM treatment_coop_cd_no)
            WHEN ''1''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a1
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b1
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a1
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b1
                ELSE NULL
                END
            WHEN ''2'' 
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a2
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b2
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a2
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b2
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a3
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b3
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a3
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b3
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a4
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b4
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a4
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b4
                ELSE NULL
                END
            END AS e1 --治療コード
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM treatment_func_cd_no)
            WHEN ''1''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''2''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                ELSE NULL
                END
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''03'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_treatment AS mtt
            ON mtt.treatment_cd = ord.ind_treatment_cd
        WHERE
          ord.ord_no = @ordNo
          AND ''1'' = @messageType
        UNION 

        SELECT --ダイアライザ情報
          ''指示詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03
          , ''000010000'' AS  e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''04'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --医材内ダイアライザ情報
          ''指示詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND equip ->> ''equip_type'' = ''1''
          
        UNION 
        SELECT --抗凝固剤
        ''指示詳細'' AS detail_id
        , ''抗凝固剤'' AS sbt_key
        , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
        , (SELECT value FROM sendmsg_gen) AS e02
        , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_koucoagulant))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_koucoagulant))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_koucoagulant))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_koucoagulant))
            END AS e03
        , koucoagulant.amount AS e04
        , (SELECT value FROM coop_ini_info WHERE key2 = concat(''26'', mmd.unit)) AS e05
        , ''000000000'' AS e06
        , (SELECT value ::text FROM other_koucoagulant_speed_unit) AS e07
        , ''06'' AS e08
        , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
         FROM (
          SELECT
            --抗凝固剤(単独分）
            1 AS temp_no
            , 1 AS medicine_type
            , 1 AS timing_no
            , 1 AS procedure_no
            , 1 AS interval_no
            , info.value ->> ''value'' AS medi_cd
            , to_char(
                (
                  CASE
                    WHEN ord.ind_cond_info -> ''26'' ->> ''value'' ~ ''^\d+(\.\d+)?$''
                      AND ord.ind_cond_info -> ''28'' ->> ''value'' ~ ''^\d+(\.\d+)?$''
                    THEN
                      (TO_NUMBER(COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', ''0''), ''FM99999.9999'')
                      + TO_NUMBER(COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', ''0''), ''FM99999.9999''))
                    ELSE
                      0
                  END
                ),
                ''FM00000V9999''
              ) AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.ind_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.ind_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
          UNION
          SELECT
            --抗凝固剤(調製分）
            t.idx AS temp_no
            , 2 AS medicine_type
            , 1 AS timing_no
            , 1 AS procedure_no
            , 1 AS interval_no
            , t.mmxd ->> ''cd'' AS medi_cd
            , CASE t.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    (TO_NUMBER(COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                    + TO_NUMBER(COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
                    ) * TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.ind_cond_info) AS info
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.ind_cond_info -> ''25'' ->> ''medicine_type'' = ''2''
        ) AS koucoagulant
        LEFT JOIN mst_medi mmd
          ON koucoagulant.medi_cd = mmd.medicine_cd::text

          UNION
          SELECT --透析液情報
          ''指示詳細'' AS detail_id
          , ''透析液'' AS sbt_key
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03
          , to_char(
            TO_NUMBER(
              COALESCE(ord.ind_cond_info -> ''17'' ->> ''value'', ''0'')
              , ''FM00000.0000''
            )
            , ''FM00000V9999''
          ) AS e4
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 1 AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --補液情報
          ''指示詳細'' AS detail_id
          , ''補液'' AS sbt_key
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03
          , to_char(
              TO_NUMBER(
                COALESCE(ord.ind_cond_info -> ''22'' ->> ''value'', ''0'')
                , ''FM00000.0000''
              )
              , ''FM00000V9999''
            ) AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 2 AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo

        UNION
        SELECT --投与薬剤情報
        ''指示詳細'' AS detail_id
        , ind_medi.sbt_key AS sbt_key
        , ind_medi.e01 AS e01
        , (SELECT value FROM sendmsg_gen) AS e02
        , COALESCE(ind_medi.e03, (SELECT value FROM func_medicine)) AS e03
        , ind_medi.e04 AS e04
        , ind_medi.e05 AS e05
        , ''000000000'' AS e06
        , ''  '' AS e07
        , ind_medi.e07 AS e08
        , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
	    FROM (
	      SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(通常)'' AS kinds
            , CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' THEN mmd.in_hospital_cd_1
              WHEN ''2'' THEN mmd.in_hospital_cd_2
              WHEN ''3'' THEN mmd.in_hospital_cd_3
              WHEN ''4'' THEN mmd.in_hospital_cd_4
              END AS e01
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN CASE (SELECT value FROM medicine_func_cd_no)
                WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
                WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
                WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
                WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
                END
              ELSE (SELECT value FROM func_another_add)
              END AS e03
            , t.medi ->> ''cd'' AS medi_cd
            , to_char(
                to_number(t.medi ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
              ) AS e04
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
              ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
              END AS e05
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN ''08''
              ELSE ''13''
              END AS e07
            , ''投与薬剤'' AS sbt_key
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          LEFT OUTER JOIN addmed_cd
            ON (CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
              WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
              WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
              WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
              END)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''1''
            AND (CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              END)
          UNION
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(調整)'' AS kinds
            , CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' THEN mmd.in_hospital_cd_1
              WHEN ''2'' THEN mmd.in_hospital_cd_2
              WHEN ''3'' THEN mmd.in_hospital_cd_3
              WHEN ''4'' THEN mmd.in_hospital_cd_4
              END AS e01
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN CASE (SELECT value FROM medicine_func_cd_no)
                WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
                WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
                WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
                WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
                END
              ELSE (SELECT value FROM func_another_add)
              END AS e03
            , t.medi ->> ''cd'' AS medi_cd
            , CASE mmxd ->> ''solvent''
              WHEN ''1'' THEN to_char(
                  to_number(mmxd ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
                )
              ELSE to_char(
                  to_number(t.medi ->> ''amount'', ''FM99999.9999'') * to_number(mmxd ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
                )
              END AS e04
          , CASE
              WHEN addmed_cd.value IS NULL
              THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
              ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
              END AS e05
          , CASE
              WHEN addmed_cd.value IS NULL
              THEN ''08''
              ELSE ''13''
              END AS e07
          , ''調製'' AS sbt_key
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) mmxd
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'')
          LEFT OUTER JOIN addmed_cd
            ON (CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
              WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
              WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
              WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
              END)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''2''
            AND (CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              END)
        ) AS ind_medi
        LEFT JOIN mst_medi mmd
        ON ind_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order
        ON ind_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order
        ON ind_medi.procedure_cd = procedure_order.procedure_code
        UNION

        SELECT
          --穿刺針情報
          ''指示詳細'' AS detail_id
          , ''穿刺針'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_aneedle))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_aneedle))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_aneedle))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_aneedle))
            END AS e03
          , TO_CHAR(TO_NUMBER(punc_needle.amount, ''FM00000.0000''), ''FM00000V9999'') AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''28'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''09'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
          FROM (
            SELECT
              --透析条件A針V針SN針
              CASE
                  WHEN info.key = ''9'' THEN 1
                  WHEN info.key = ''10'' THEN 2
                  WHEN info.key = ''11'' THEN 3
                  END AS temp_no
              , info.value ->> ''value'' AS eq_cd
              , ''1'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL jsonb_each(ord.ind_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''9'',''10'',''11'')
            UNION
            SELECT
              --医材内穿刺針
              4 + t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            LEFT JOIN mst_equip
              ON t.equip ->> ''cd'' = mst_equip.equipment_cd ::text
            LEFT JOIN mst_equipment_class
              ON mst_equip.class_cd = mst_equipment_class.class_cd
            WHERE
              ord.ord_no = @ordNo
              AND mst_equipment_class.class_type IN (''2'', ''3'')
          ) AS punc_needle
          LEFT JOIN mst_equip meq
          ON punc_needle.eq_cd = meq.equipment_cd::text
        UNION

        SELECT --医材情報
          ''指示詳細'' AS detail_id
          , ''医材'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03
          , CASE
            WHEN mst_equipment_class.class_type = ''4'' THEN ''000010000''
            ELSE to_char(
              to_number(equip ->> ''amount'', ''99999.9999'')
              , ''FM00000V9999''
            )
            END AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''10'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
          LEFT JOIN mst_equip meq
              ON meq.equipment_cd = TO_NUMBER(t.equip ->> ''cd'', ''FM999999999999'')
            LEFT JOIN mst_equipment_class
              ON meq.class_cd = mst_equipment_class.class_cd
        WHERE
          t.equip ->> ''equip_type'' = ''0''
          AND mst_equipment_class.class_type NOT IN (''2'', ''3'')
          AND ord.ord_no = @ordNo

        --特殊血液浄化
        UNION
        SELECT --1次膜情報
          ''指示詳細'' AS detail_id
          , ''1次膜'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''11'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equip AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --2次膜情報
          ''指示詳細'' AS detail_id
          , ''2次膜'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption)) AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''12'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equipment AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo

        UNION
        SELECT
          --加算(その他)Ver1
          ''指示詳細'' AS detail_id
          , ''加算(その他)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_another_add) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''13'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''30''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType

        UNION
                --
        SELECT
          --加算(患者)、加算(その他)その2、項目コメント、透析コメント1~3Ver2
          ''指示詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e03 --機能コード
          , ind_medi.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN
              CASE mmd.in_hospital_cd_1
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''14''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''2'' THEN
              CASE mmd.in_hospital_cd_2
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''14''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''3'' THEN
              CASE mmd.in_hospital_cd_3
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''14''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''4'' THEN
              CASE mmd.in_hospital_cd_4
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''14''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            END) AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(通常)'' AS kinds
            , t.medi ->> ''cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''1''
          UNION
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''2''
        ) AS ind_medi
        LEFT JOIN mst_medi mmd ON ind_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order ON ind_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON ind_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
          WHEN ''1'' THEN mmd.in_hospital_cd_1 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''2'' THEN mmd.in_hospital_cd_2 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''3'' THEN mmd.in_hospital_cd_3 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''4'' THEN mmd.in_hospital_cd_4 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          END)
        --
        UNION

        SELECT --加算(透析困難理由)
          ''指示詳細'' AS detail_id
          , ''透析困難'' AS sbt_key
          , CASE (SELECT value FROM difficult_coop_cd_no)
            WHEN ''1'' THEN mdd.in_hospital_cd_1
            WHEN ''2'' THEN mdd.in_hospital_cd_2
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM difficult_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdd.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mdd.in_hospital_cd_2, (SELECT value FROM func_another_add))
            END AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''15'' AS e08
          , NULL ::int AS e09
        FROM
          mst_dialysis_difficulty mdd
        WHERE
          ''2'' = @messageType
          AND mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0''
        UNION

        SELECT --その他項目(透析時間)
          ''指示詳細'' AS detail_id
          , ''所要時間'' AS sbt_key
          , (SELECT value FROM other_dialysis_time) AS e01 --コード
          , (SELECT value FROM sendmsg_gen) AS e02
          , (SELECT value FROM func_other_item) AS e03 --項目名
          , to_char(
            TO_NUMBER(
              ord.ind_cond_info -> ''1'' ->> ''value''
              , ''FM999999999999''
            )
            , ''FM00000V9999''
          ) AS e04
          , (SELECT value FROM other_dialysis_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''16'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT
        --項目コメント Ver.1
        ''指示詳細'' AS detail_id
          , ''項目コメント'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_item_comment) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''17'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''32''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント1 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント1'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''18'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3A''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント2 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment2) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''19'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3B''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント3 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント3'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment3) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''20'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3C''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType

      ) all_cost
    WHERE
      all_cost.e01 IS NOT NULL
    ORDER BY
      all_cost.e08
      , CAST(all_cost.e09 as integer)
      , all_cost.e01
  ) cost_fin', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)詳細指示繰り返し部', '2020-05-20 11:39:52.001', CURRENT_TIMESTAMP, '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-203, 'WITH kaikei_comment_flg_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS kaikei_comment_flg
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''KAIKEI_COMMENT_FLG''
)
SELECT
  ''コメント'' AS detail_id
  , to_char(ROW_NUMBER() OVER (), ''FM000'') AS com_no
  , com_fin.*
FROM
  (
    SELECT
      com_all.*
    FROM
      (
        SELECT -- 原疾患
          ''01'' AS fin_cd
          , SUBSTRING(md.disease_name, 1, 30) AS com_text
        FROM
          mst_disease AS md
        WHERE
          md.disease_cd ::text = @primaryDiseaseCd
          and md.is_del = ''0''
          and md.is_disp = ''1''
          AND ''2'' = @messageType
        UNION
        SELECT -- 透析困難コメント
          ''40'' AS fin_cd
          , SUBSTRING(mdd.dialysis_difficulty_name, 1, 30) AS com_text
        FROM
          mst_dialysis_difficulty mdd
        WHERE
          mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0''
          AND ''1'' = @messageType
        UNION
        SELECT
          -- 会計コメント
          ''60'' AS fin_cd
          , TRANSLATE(
            CONCAT(
              ''開始'', TO_CHAR(ord.rst_start_date, ''HH24:MI'')
              , ''　終了'', TO_CHAR(ord.rst_end_date, ''HH24:MI'')
              , ''　時間'', TO_CHAR(date_trunc(''minute'', ord.rst_end_date) - date_trunc(''minute'', ord.rst_start_date), ''HH24:MI'')
            )
            , ''0123456789:'', ''０１２３４５６７８９：''
          ) AS com_text
        FROM
          ord_main ord
        WHERE
          ord.ord_no = @ordNo
        AND EXISTS (SELECT kaikei_comment_flg FROM kaikei_comment_flg_info WHERE kaikei_comment_flg = ''1'')
      ) com_all
    WHERE
      COALESCE(com_all.com_text, ''空白'') <> ''空白''
    ORDER BY fin_cd ASC
  ) com_fin
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'NEC)コメント繰り返し部(要ordno、patid）', '2020-05-19 16:46:18.001', CURRENT_TIMESTAMP, '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}, {"sql_cd": -600302, "field_name": "primary_disease_cd", "replace_var": "@primaryDiseaseCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-202, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NEC''
)
, sendmsg_gen AS ( --項目世代番号
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''SENDMSG_GEN''
)
, func_addition AS ( --加算(患者)機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ADDITION''
)
, va_coop_cd_no AS ( --VAの連携コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_COOP_CD_NO''
)
, va_func_cd_no AS ( --VAの機能コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_FUNC_CD_NO''
)
, func_bloodaccess AS ( --VAの機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_BLOODACCESS''
)
, treatment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_COOP_CD_NO''
)
, treatment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_FUNC_CD_NO''
)
, func_treat AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_TREAT''
)
, dialyzer_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_COOP_CD_NO''
)
, dialyzer_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_FUNC_CD_NO''
)
, func_dialyzer AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYZER''
)
, other_dialyzer_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYZER_UNIT''
)
, medicine_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_COOP_CD_NO''
)
, medicine_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_FUNC_CD_NO''
)
, func_medicine AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_MEDICINE''
)
, func_koucoagulant AS ( --抗凝固剤
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_KOUCOAGULANT''
)
, other_koucoagulant_speed_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_KOUCOAGULANT_SPEED_UNIT''
)
, num_auto_calc AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NUM_AUTO_CALC''
)
, num_auto_calc_ranges AS ( --透析液量自動計算
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS range_string
        , info ->> ''key2'' AS cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NUM_AUTO_CALC''
        and info ->> ''key2'' <> ''AUTO_CALC_FLG''
)
, parsed_ranges AS ( --透析液量自動計算
    SELECT 
        split_part(value, '':'', 1)::numeric AS lower_bound,
        split_part(value, '':'', 2)::numeric AS value,
        lead(split_part(value, '':'', 1)::numeric, 1, 100000) OVER (PARTITION BY ranges.cd ORDER BY split_part(value, '':'', 1)::numeric) -0.0001 AS upper_bound,
        ranges.cd
    FROM num_auto_calc_ranges ranges
    CROSS JOIN unnest(string_to_array(range_string, ''/'')) AS value
)
, rst_minutes as ( --透析時間(分)
    SELECT TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999999999'') as minutes
    FROM ord_main ord
    where ord_no = @ordNo
)
, parsed_table AS ( --透析液量自動計算
    SELECT pr.value, pr.cd
    FROM parsed_ranges pr, rst_minutes
    WHERE rst_minutes.minutes BETWEEN pr.lower_bound AND pr.upper_bound
)
, oxygen_code AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OXYGEN_CODE''
)
, oxygen_used_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OXYGEN_USED_UNIT''
)
, equipment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_COOP_CD_NO''
)
, equipment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_FUNC_CD_NO''
)
, func_aneedle AS ( --穿刺針
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANEEDLE''
)
, func_consumption AS ( --医療材料
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_CONSUMPTION''
)
, func_another_add AS ( --時間外薬剤
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANOTHER_ADD''
)
, addmed_cd as ( --時間外薬剤コードリスト
	select *
	FROM coop_ini_info
	WHERE key2 like ''MEDICINE_ADDMED_CODE%''
)
, difficult_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_COOP_CD_NO''
)
, difficult_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_FUNC_CD_NO''
)
, addition_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_COOP_CD_NO''
)
, addition_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_FUNC_CD_NO''
)
, other_dialysis_time AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_TIME''
)
, other_dialysis_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_UNIT''
)
, func_other_item AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_OTHER_ITEM''
)
, other_off_water AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_OFF_WATER''
)
, other_off_water_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_OFF_WATER_UNIT''
)
, func_item_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ITEM_COMMENT''
)
, func_dialysis_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT''
)
, func_dialysis_comment2 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT2''
)
, func_dialysis_comment3 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT3''
)
, equip_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, equip_order AS (
  SELECT
    index_no ::int AS meq_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment''
)
, equip_class_order as (
  SELECT
    index_no ::int AS meq_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
  SELECT
    equipment_cd
    , equipment_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , equip_order.meq_code_order
    , equip_class_order.meq_class_code_order
  FROM mst_equipment meq
  LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
  LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
  WHERE facility_cd = @facilityCd
)
, medi_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS a1
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, medi_order AS (
  SELECT
    index_no ::int AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
  SELECT
    index_no ::int AS medi_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
  SELECT
    index_no ::int AS timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
  SELECT
    index_no ::int AS procedure_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
  SELECT
    medicine_cd
    , medicine_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , medi_order.medi_code_order
    , medi_class_order.medi_class_code_order
  FROM mst_medicine mmd
  LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
  WHERE facility_cd = @facilityCd
)
, pcd_save_3 AS (
  SELECT
    t.values ->> ''item_code'' as item_code
    , t.values ->> ''function_code'' as function_code
    , t.values ->> ''item_generation'' as item_generation
    , t.idx as idx
  FROM pat_coop_detail pcd
  CROSS JOIN jsonb_array_elements(pcd.save_3) with ORDINALITY AS t(values, idx)
  WHERE pat_id = @patId
)
SELECT
  LPAD(TO_CHAR(ROW_NUMBER() OVER (), ''FM000''), 3, '' '') AS cost_no
  , cost_fin.*
FROM
  (
    SELECT
      all_cost.*
    FROM
      (
        SELECT
          --加算(患者)Ver1
          ''実績詳細'' AS detail_id
          , ''加算(患者)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_addition) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''01'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''20''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --VA情報
          ''実績詳細'' AS detail_id
          , ''VA'' AS sbt_key
          , CASE (SELECT value FROM va_coop_cd_no)
            WHEN ''1'' THEN mva.in_hospital_cd_1
            WHEN ''2'' THEN mva.in_hospital_cd_2
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM va_func_cd_no)
            WHEN ''1'' THEN COALESCE(mva.in_hospital_cd_1, (SELECT value FROM func_bloodaccess))
            WHEN ''2'' THEN COALESCE(mva.in_hospital_cd_2, (SELECT value FROM func_bloodaccess))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''02'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_va AS mva
            ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND ''2'' = @messageType
        UNION ALL
        SELECT
          --透析方法
          ''実績詳細'' AS detail_id
          , ''治療項目'' AS sbt_key
          , CASE (SELECT value FROM treatment_coop_cd_no)
            WHEN ''1''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a1
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b1
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a1
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b1
                ELSE NULL
                END
            WHEN ''2'' 
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a2
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b2
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a2
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b2
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a3
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b3
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a3
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b3
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a4
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b4
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a4
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b4
                ELSE NULL
                END
            END AS e1 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM treatment_func_cd_no)
            WHEN ''1''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''2''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                ELSE NULL
                END
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''04'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_treatment AS mtt
            ON mtt.treatment_cd = ord.rst_treatment_cd
        WHERE
          ord.ord_no = @ordNo
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --ダイアライザ情報
          ''実績詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --医材内ダイアライザ情報
          ''実績詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND equip ->> ''equip_type'' = ''1''
        UNION ALL
        SELECT
          --抗凝固剤
          ''実績詳細'' AS detail_id
          , ''抗凝固剤''
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_koucoagulant))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_koucoagulant))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_koucoagulant))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_koucoagulant))
            END AS e03 --機能コード
          , koucoagulant.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''26'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , (SELECT value ::text FROM other_koucoagulant_speed_unit) AS e07
          , ''06'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --抗凝固剤(単独分）
            1 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , 1 AS timing_no --タイミング
            , 1 AS procedure_no --手技
            , 1 AS interval_no --投与間隔
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
              (
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                + TO_NUMBER(COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
              )
            , ''FM00000V9999'') AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --抗凝固剤(調製分）
            t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , 1 AS timing_no --タイミング
            , 1 AS procedure_no --手技
            , 1 AS interval_no --投与間隔
            , t.mmxd ->> ''cd'' AS medi_cd
            , CASE t.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    (TO_NUMBER(COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                    + TO_NUMBER(COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
                    ) * TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2''
        ) AS koucoagulant
        LEFT JOIN mst_medi mmd
          ON koucoagulant.medi_cd = mmd.medicine_cd::text
        UNION ALL
        SELECT
          --薬剤
          ''実績詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
              WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
              WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
              WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
              END
            ELSE CASE (SELECT value FROM medicine_func_cd_no) --時間外薬剤
              WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_another_add))
              WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_another_add))
              WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_another_add))
              WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_another_add))
              END
            END AS e03 --機能コード
          , CASE (rst_medi.is_auto_calc)
            WHEN ''0'' THEN rst_medi.amount
            WHEN ''1'' THEN
                CASE (SELECT value FROM medicine_coop_cd_no)
                WHEN ''1'' THEN TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_1), ''FM00000V9999'')
                WHEN ''2'' THEN TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_2), ''FM00000V9999'')
                WHEN ''3'' THEN TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_3), ''FM00000V9999'')
                WHEN ''4'' THEN TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_4), ''FM00000V9999'')
                END
            END AS e04
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
            ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
            END AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN ''07''
            ELSE ''11'' --時間外薬剤
            END AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --透析液
            1 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , NULL ::integer AS procedure_cd --手技
            , 999 AS interval_no --投与間隔
            , ''透析液'' AS kinds
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , (SELECT value FROM num_auto_calc WHERE key2 = ''AUTO_CALC_FLG'') AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''15'')
            AND ord.rst_cond_info -> ''15'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --補液
            2 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , NULL ::integer AS procedure_cd --手技
            , 999 AS interval_no --投与間隔
            , ''補液'' AS kinds
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''19'')
            AND ord.rst_cond_info -> ''19'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(通常)'' AS kinds
            , t.medi ->> ''cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''1''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''2''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(通常)
            200 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''処置薬剤情報(通常)'' AS kinds
            , t.tmedi ->> ''treat_medicine_cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.tmedi ->> ''treat_class'' IN (''1'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(調整)
            200 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''処置薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.tmedi ->> ''treat_medicine_cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.tmedi ->> ''treat_class'' IN (''0'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''2''
        ) AS rst_medi
        LEFT JOIN mst_medi mmd ON rst_medi.medi_cd = mmd.medicine_cd::text
        LEFT OUTER JOIN addmed_cd
          ON (CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
            WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
            WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
            WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
            END)
        LEFT JOIN timing_order ON rst_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON rst_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            END)
        UNION ALL
        SELECT
          --酸素吸入情報
          ''実績詳細'' AS detail_id
          , ''酸素吸入''
          , (SELECT value FROM oxygen_code) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_medicine)  AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(tmedi ->> ''oxygen_amount'', ''FM99999.9999''), ''FM00000V9999'') AS e04
          , (SELECT value FROM oxygen_used_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 999 AS e09
        FROM
          ord_main AS ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi
        WHERE
          ord.ord_no = @ordNo
          AND tmedi ->> ''treat_class'' = ''3''
          AND tmedi ->> ''oxygen_amount'' IS NOT NULL
        UNION ALL
        SELECT
          --穿刺針情報
          ''実績詳細'' AS detail_id
          , ''穿刺針''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_aneedle))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_aneedle))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_aneedle))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_aneedle))
            END AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(punc_needle.amount, ''FM00000.0000''), ''FM00000V9999'') AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''28'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''08'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
          FROM (
            SELECT
              --透析条件A針V針SN針
              CASE
                  WHEN info.key = ''9'' THEN 1
                  WHEN info.key = ''10'' THEN 2
                  WHEN info.key = ''11'' THEN 3
                  END AS temp_no
              , info.value ->> ''value'' AS eq_cd
              , ''1'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL jsonb_each(ord.rst_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''9'',''10'',''11'')
            UNION ALL
            SELECT
              --医材内穿刺針
              4 + t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            WHERE
              ord.ord_no = @ordNo
              AND t.equip ->> ''class_type'' IN (''2'', ''3'')
          ) AS punc_needle
          LEFT JOIN mst_equip meq
          ON punc_needle.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --医材情報
          ''実績詳細'' AS detail_id
          , ''医材''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03 --機能コード
          , CASE
            WHEN rst_equip.class_type = ''4'' THEN ''000010000'' --吸着カラム使用量1固定
            ELSE TO_CHAR(TO_NUMBER(rst_equip.amount, ''FM99999.9999''), ''FM00000V9999'') 
            END AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''09'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
          FROM (
            SELECT
              t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
              , t.equip ->> ''class_type'' AS class_type
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            WHERE
              ord.ord_no = @ordNo
              AND t.equip ->> ''equip_type'' = ''0''
              AND t.equip ->> ''class_type'' NOT IN (''2'', ''3'')
          ) AS rst_equip
          LEFT JOIN mst_equip meq
          ON rst_equip.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --1次膜2次膜情報
          ''実績詳細'' AS detail_id
          , ''1次膜2次膜''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''10'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq.meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq.meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq.meq_code_order END, meq.meq_code_order
            ) AS e09
          FROM (
            SELECT
              CASE
                WHEN info.key = ''7'' THEN 1
                WHEN info.key = ''8'' THEN 2
                END AS temp_no
              ,info.value ->> ''value'' AS eq_cd
            FROM ord_main ord
            CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''7'',''8'')
          ) AS rst_equip
          LEFT JOIN mst_equip meq
          ON rst_equip.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --加算(その他)その2Ver1
          ''実績詳細'' AS detail_id
          , ''加算(その他)その2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_another_add) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''12'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''30''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --加算(患者)Ver2、加算(その他)その2Ver2、項目コメントVer2、透析コメント1~3Ver2
          ''実績詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03 --機能コード
          , rst_medi.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN
              CASE mmd.in_hospital_cd_1
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''2'' THEN
              CASE mmd.in_hospital_cd_2
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''3'' THEN
              CASE mmd.in_hospital_cd_3
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''4'' THEN
              CASE mmd.in_hospital_cd_4
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            END) AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(通常)'' AS kinds
            , t.medi ->> ''cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''1''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''2''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(通常)
            200 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''加算処置薬剤情報(通常)'' AS kinds
            , t.tmedi ->> ''treat_medicine_cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.tmedi ->> ''treat_class'' IN (''1'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(調整)
            200 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''加算処置薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.tmedi ->> ''treat_medicine_cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.tmedi ->> ''treat_class'' IN (''0'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''2''
        ) AS rst_medi
        LEFT JOIN mst_medi mmd ON rst_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order ON rst_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON rst_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
          WHEN ''1'' THEN mmd.in_hospital_cd_1 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''2'' THEN mmd.in_hospital_cd_2 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''3'' THEN mmd.in_hospital_cd_3 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''4'' THEN mmd.in_hospital_cd_4 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          END)
        UNION ALL 
        SELECT
          --加算(透析困難)
          ''実績詳細'' AS detail_id
          , ''加算'' AS sbt_key
          , CASE (SELECT value FROM difficult_coop_cd_no)
            WHEN ''1'' THEN mdd.in_hospital_cd_1
            WHEN ''2'' THEN mdd.in_hospital_cd_2
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM difficult_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdd.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mdd.in_hospital_cd_2, (SELECT value FROM func_another_add))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''13'' AS e08
          , NULL ::int AS e09
        FROM
          mst_dialysis_difficulty mdd
        WHERE
          ''2'' = @messageType
          AND mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0''
        UNION ALL
        SELECT
          --加算(レセプトメモ)
          ''実績詳細'' AS detail_id
          , ''加算'' AS sbt_key
          , CASE (SELECT value FROM addition_coop_cd_no)
            WHEN ''1'' THEN mad.in_hospital_cd_1
            WHEN ''2'' THEN mad.in_hospital_cd_2
            WHEN ''3'' THEN mad.in_hospital_cd_3
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM addition_func_cd_no)
            WHEN ''1'' THEN COALESCE(mad.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mad.in_hospital_cd_2, (SELECT value FROM func_another_add))
            WHEN ''3'' THEN COALESCE(mad.in_hospital_cd_3, (SELECT value FROM func_another_add))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''14'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) addi
          LEFT OUTER JOIN mst_addition AS mad
            ON mad.addition_cd = TO_NUMBER(addi ->> ''cd'', ''FM9999999999'')
        WHERE
          ''2'' = @messageType
          AND ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --透析所要時間情報
          ''実績詳細'' AS detail_id
          , ''所要時間'' AS sbt_key
          , (SELECT value FROM other_dialysis_time) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_other_item) AS e03 --機能コード
          , TO_CHAR((FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', ord.rst_end_date) - date_trunc(''minute'', ord.rst_start_date))) / 60)), ''FM00000V9999'') AS e04
          , (SELECT value FROM other_dialysis_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''15'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
        WHERE
          ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --透析除水量情報
          ''実績詳細'' AS detail_id
          , ''除水量'' AS sbt_key
          , (SELECT value FROM other_off_water) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_other_item) AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(rst_weight_info ->> ''add_total'', ''FM99999.9999''), ''FM00000V9999'') AS e04
          , (SELECT value FROM other_off_water_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''16'' AS e08
          , NULL ::int AS e09
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --項目コメントVer1
          ''実績詳細'' AS detail_id
          , ''項目コメント'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_item_comment) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''17'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''32''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント1Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント1'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''18'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3A''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント2Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment2) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''19'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3B''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント3Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント3'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment3) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''20'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3C''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
      ) all_cost
    WHERE
      all_cost.e01 IS NOT NULL
    ORDER BY
      all_cost.e08
      , CAST(all_cost.e09 as integer)
      , all_cost.e01
  ) cost_fin
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)実績繰り返し部１', '2020-05-18 18:12:46.000', CURRENT_TIMESTAMP, '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-201, 'WITH trend_interval_value AS (
    SELECT
        COALESCE(info->>''value'', info->>''default_v'') AS trend_value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key1'' = ''NEC_MSTVAITALSEND''
        AND info->>''key0'' = ''HR''
        AND info->>''key2'' = ''TREND_INTERVAL''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)
),
coop_ini_extracted AS (
    SELECT
        COALESCE(info->>''value'', info->>''default_v'') AS trend_value,
        info->>''value'' AS value,
        info->>''default_v'' AS default_v,
        CASE
            WHEN info->>''key2'' = ''BP_MAX_VAITAL_CD'' THEN ''90''
            WHEN info->>''key2'' = ''BP_MIN_VAITAL_CD'' THEN ''91''
            WHEN info->>''key2'' = ''PULSE_VAITAL_CD'' THEN ''93''
            WHEN info->>''key2'' = ''TEMPERATURE_VAITAL_CD'' THEN ''94''
            WHEN info->>''key2'' = ''ELAPSED_TIME_VAITAL_CD'' THEN ''1''
            WHEN info->>''key2'' = ''TREAT_MODE_VAITAL_CD'' THEN ''31''
            WHEN info->>''key2'' = ''BLOOD_FLOW_VAITAL_CD'' THEN ''8''
            WHEN info->>''key2'' = ''OFFWATER_SPEED_VAITAL_CD'' THEN ''33''
            WHEN info->>''key2'' = ''OFFWATER_ADD_VAITAL_CD'' THEN ''5''
            WHEN info->>''key2'' = ''OFFWATER_TERGET_VAITAL_CD'' THEN ''32''
            WHEN info->>''key2'' = ''VENOUS_PRESSURE_VAITAL_CD'' THEN ''11''
            WHEN info->>''key2'' = ''DIALYSATE_PRESSURE_VAITAL_CD'' THEN ''12''
            WHEN info->>''key2'' = ''TMP_VAITAL_CD'' THEN ''13''
            WHEN info->>''key2'' = ''IP_TOTAL_AMOUNT_VAITAL_CD'' THEN ''9''
            WHEN info->>''key2'' = ''IP_SPEED_VAITAL_CD'' THEN ''37''
            WHEN info->>''key2'' = ''DIALYSATE_TEMPERATURE_VAITAL_CD'' THEN ''21''
            WHEN info->>''key2'' = ''NA_CONCENTRATION_VAITAL_CD'' THEN ''20''
            WHEN info->>''key2'' = ''DIALYSATE_FLOW_VAITAL_CD'' THEN ''22''
            WHEN info->>''key2'' = ''REPLENISH_SPEED_VAITAL_CD'' THEN ''73''
            WHEN info->>''key2'' = ''REPLENISH_VALUE_VAITAL_CD'' THEN ''72''
            WHEN info->>''key2'' = ''REPLENISH_TEMPERATURE_VAITAL_CD'' THEN ''74''
            WHEN info->>''key2'' = ''DELTA_BV_VAITAL_CD'' THEN ''17''
            WHEN info->>''key2'' = ''DELTA_BV_CHANGE_RATE_CD'' THEN ''80''
            WHEN info->>''key2'' = ''TEMPERATURE_VAITAL_CD'' THEN ''104''
            WHEN info->>''key2'' = ''WEIGHT_BEFORE_VAITAL_CD'' THEN ''105''
            WHEN info->>''key2'' = ''WEIGHT_AFTER_VAITAL_CD'' THEN ''106''
            ELSE NULL
        END AS target_key
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key1'' = ''NEC_MSTVAITALSEND''
        AND info->>''key0'' = ''HR''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)
        AND COALESCE(NULLIF(info->>''value'', ''''), NULL) IS NOT NULL
),
query_1 AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS vital_cd,
        monitor_data->>vit_ini.target_key AS vital_data,
        vital_all.occur_date
    FROM (
        SELECT
            to_char(occur_date, ''YYYYMMDDHH24MI'') AS occur_date,
            monitor_data
        FROM
            mni_monitor
        WHERE
            1 = 1
            AND ord_no = @ordNo
            AND data_type IN (0, 2, 4, 5, 6)
            AND is_del = ''0''
    ) AS vital_all
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v,
            target_key
        FROM
            coop_ini_extracted
        WHERE
            1 = 1
            AND target_key IS NOT NULL
    ) AS vit_ini
    WHERE
        1 = 1
        AND vit_ini.target_key IS NOT NULL
        AND COALESCE(NULLIF(monitor_data->>vit_ini.target_key, ''''), NULL) IS NOT NULL
),
query_2 AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS bw_cd, -- coop_ini から取得した値
        ord.rst_weight_info->>''weight_before'' AS bw_w,
        to_char((ord.rst_weight_info->>''weight_before_date'')::timestamp, ''YYYYMMDDHH24MI'') AS bw_date
    FROM
        ord_main ord
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v
        FROM
            coop_ini_extracted
        WHERE
            target_key = ''105'' -- 重量コード「105」を確認
    ) AS vit_ini
    WHERE
        ord.ord_no = @ordNo
        AND COALESCE(ord.rst_weight_info->>''weight_before_date'', ''NODATE'') <> ''NODATE''
),
query_3 AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS aw_cd, -- coop_ini から取得した値
        ord.rst_weight_info->>''weight_after'' AS aw_w,
        to_char((ord.rst_weight_info->>''weight_after_date'')::timestamp, ''YYYYMMDDHH24MI'') AS aw_date
    FROM
        ord_main ord
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v
        FROM
            coop_ini_extracted
        WHERE
            target_key = ''106'' -- 重量コード「106」を確認
    ) AS vit_ini
    WHERE
        ord.ord_no = @ordNo
        AND COALESCE(ord.rst_weight_info->>''weight_after_date'', ''NODATE'') <> ''NODATE''
)
, query_4 AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS vital_cd,
        monitor_data->>vit_ini.target_key AS vital_data,
        monitor_data,
        vital_all.occur_date
    FROM (
        SELECT
            to_char(occur_date, ''YYYYMMDDHH24MI'') AS occur_date,
            monitor_data
        FROM
            mni_monitor
        WHERE
            1 = 1
            AND ord_no = @ordNo
            AND data_type = 1
            AND is_del = ''0''
    ) AS vital_all
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v,
            target_key
        FROM
            coop_ini_extracted
        WHERE
            1 = 1
            AND target_key IS NOT NULL
    ) AS vit_ini
    JOIN trend_interval_value ON TRUE
    WHERE
        1 = 1
        AND vit_ini.target_key IS NOT NULL
        AND to_number(monitor_data->>''1'', ''999'') > 0
        AND (to_number(monitor_data->>''1'', ''999'') % trend_interval_value.trend_value::numeric = 0)
        AND COALESCE(NULLIF(monitor_data->>vit_ini.target_key, ''''), NULL) IS NOT NULL
),
query_4_sorted AS (
    SELECT
        detail_id, vital_cd, vital_data, occur_date, monitor_data
    FROM (
        SELECT
            *,
            DENSE_RANK() OVER (PARTITION BY monitor_data->>''1'' ORDER BY occur_date ASC) AS rank_within_value,
            MAX(occur_date) OVER () AS max_occur_date
        FROM query_4
    ) AS ranked
    WHERE
        1 = 1
        AND rank_within_value = 1
        AND occur_date <> max_occur_date
    ORDER BY
        occur_date,
        vital_cd
)
SELECT * FROM query_1
UNION ALL
SELECT * FROM query_2
UNION ALL
SELECT * FROM query_3
UNION ALL
SELECT detail_id, vital_cd, vital_data, occur_date FROM query_4_sorted', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)バイタル繰り返し部', '2020-05-15 10:28:50.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-102, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
)
, get_course AS ( --指示科取得先設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''GET_COURSE''
)
, def_course AS ( --デフォルト指示科
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_COURSE''
)
, get_XMLGEN_obj_type AS ( --データ種別
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_OBJ_TYP''
)
, get_XMLGEN_cd as ( -- システム識別子
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_SYSTEM_CODE''
)
, get_XMLGEN_hosp_cd as ( -- 施設コード
    SELECT btrim(value) as value
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_HOSP_CODE''
)
,bed_code_conv as (
    SELECT *
    FROM coop_ini_info 
    WHERE key2 = ''BED_CODE_CONV''
)
, get_bed_mst as ( -- ベッドマスタ
    SELECT
    bed_cd as bed_cd ,
    CASE (SELECT value FROM bed_code_conv)
        WHEN ''1'' THEN in_hospital_cd_1
        WHEN ''2'' THEN in_hospital_cd_2
		END AS in_hospital_cd
    FROM mst_bed
    WHERE facility_cd = @facilityCd
    AND bed_cd = (SELECT ind_bed_cd FROM ord_main WHERE ord_no = @ordNo)
)
, ind_nec_bed_course AS ( --ベッド番号・科コード対応(指示)
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC_BED_COURSE''
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM get_bed_mst)::text
)
, rst_nec_bed_cd AS (
    SELECT
    bed_cd AS bed_cd ,
    CASE (SELECT value FROM bed_code_conv)
        WHEN ''1'' THEN in_hospital_cd_1
        WHEN ''2'' THEN in_hospital_cd_2
		END AS in_hospital_cd
    FROM mst_bed
    WHERE facility_cd = @facilityCd
    AND bed_cd = (SELECT rst_bed_cd FROM ord_main WHERE ord_no = @ordNo)
)
, rst_nec_bed_course AS ( --ベッド番号・科コード対応(実績)
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC_BED_COURSE''
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM rst_nec_bed_cd)
)
, rst_del_nec_bed_cd AS (
    (
        SELECT
            rst_bed_cd AS rst_bed_cd
            , CASE (SELECT value FROM bed_code_conv)
                WHEN ''1'' THEN mb.in_hospital_cd_1
                WHEN ''2'' THEN mb.in_hospital_cd_2
                END AS in_hospital_cd
            , ord.del_date AS up_date
        FROM ord_main_restore AS ord
        CROSS JOIN sys_coop_journal AS journal
        LEFT JOIN mst_bed mb ON ord.rst_bed_cd = mb.bed_cd
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY ord.del_date DESC
        LIMIT 1
    )
    UNION ALL
    (
        SELECT
            rst_bed_cd AS rst_bed_cd
            , CASE (SELECT value FROM bed_code_conv)
                WHEN ''1'' THEN mb.in_hospital_cd_1
                WHEN ''2'' THEN mb.in_hospital_cd_2
                END AS in_hospital_cd
            , ord.rst_edition_date AS up_date
        FROM ord_main AS ord
        CROSS JOIN sys_coop_journal AS journal
        LEFT JOIN mst_bed mb ON rst_bed_cd = mb.bed_cd
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
    )
    ORDER BY up_date DESC
    LIMIT 1
)
, rst_del_nec_bed_course AS ( --ベッド番号・科コード対応(実績_削除時)
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC_BED_COURSE''
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM rst_del_nec_bed_cd)::text
)
, get_doctor AS ( --指示医取得設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''GET_DOCTOR''
)
, def_doctor AS ( --デフォルト指示医
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_DOCTOR''
)
, dialysis_course_cd AS ( --透析実施科
    SELECT
        pm.medical_care_info ->>''dialysis_course_cd'' AS dialysis_course_cd
    FROM pat_main pm
    LEFT JOIN mst_course mc
    ON pm.medical_care_info ->>''dialysis_course_cd'' = mc.course_cd::text
    AND mc.facility_cd = @facilityCd
    WHERE pm.facility_cd = @facilityCd
    AND pm.pat_id = @patId
    AND pm.is_del = ''0''
)
, main_course_cd AS ( --診療科
    SELECT
        mc.in_hospital_cd_1 AS main_course_cd
    FROM pat_main pm
    LEFT JOIN mst_course mc
    ON pm.medical_care_info ->>''main_course_cd'' = mc.course_cd::text
    AND mc.facility_cd = @facilityCd
    WHERE pm.facility_cd = @facilityCd
    AND pm.pat_id = @patId
    AND pm.is_del = ''0''
)
, staff_cd_list AS ( --担当医1,2
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
        , users ->> ''user_id'' AS user_id
        , row_number() OVER(ORDER BY values ->> ''disp_order'') AS row_no
    FROM pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS values
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON values ->> ''staff_cd'' = users ->> ''user_id''
    WHERE pm.facility_cd = @facilityCd
    AND pm.pat_id = @patId
    AND pm.is_del = ''0''
    AND values ->> ''is_main'' = ''1''
)
,up_ind_user_id AS ( --最終更新指示者の表示用ID
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM ord_main ord
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON ord.up_ind_user_id::text = users ->> ''user_id''
    WHERE ord.ord_no = @ordNo
)
,up_user_id AS ( --最終更新者の表示用ID
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM ord_main ord
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON ord.up_user_id::text = users ->> ''user_id''
    WHERE ord.ord_no = @ordNo
)
, ind_send_doctor_v1 AS ( --詳細指示連携で送信した指示医
    SELECT
        encode(substring(scj.dump from 163 for 10), ''escape'') AS ind_doctor
        , accept_no
    FROM
        sys_coop_journal scj
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND pat_id = @patId
        AND ord_no = @ordNo
        AND coop_cd = ''ind_dial''
    UNION
    SELECT
        ''          '' AS ind_doctor
        , 0 AS accept_no
    ORDER BY
        accept_no DESC LIMIT 1
)
, ind_send_doctor_v2 AS ( --詳細指示連携で送信した指示医
    SELECT
        encode(substring(scj.dump from 131 for 10), ''escape'') AS ind_doctor
        , accept_no
    FROM
        sys_coop_journal scj
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND pat_id = @patId
        AND ord_no = @ordNo
        AND coop_cd = ''ind_dial''
    UNION
    SELECT
        ''          '' AS ind_doctor
        , 0 AS accept_no
    ORDER BY
        accept_no DESC LIMIT 1
)
, def_update_terminal AS ( --デフォルト更新端末
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_UPDATE_TERMINAL''
)
, medicine_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_COOP_CD_NO''
)
, own_expense_medicine_code_list AS (
    SELECT unnest(string_to_array(value, '','')) AS split_cd
    FROM coop_ini_info
    WHERE key2 = ''OWN_EXPENSE_MEDICINE_CODE''
)
, get_XMLGEN_title_cd AS ( -- タイトル識別コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_TITLE_CODE''
)
, get_XMLGEN_title_name AS ( -- タイトル識別名称
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_TITLE_NAME''
)
, get_XMLGEN_fs_disp AS ( -- フローシート表示文字列
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_FS_DISP''
)
, get_XMLGEN_content_number AS ( -- 識別番号
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_CONTENT_NUMBER''
)
, get_XMLGEN_content_type AS ( -- コンテンツタイプ
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_CONTENT_TYPE''
)
, get_XMLGEN_extent_name AS ( -- 拡張子
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_EXTENT_NAME''
)
, get_XMLGEN_device_name AS ( -- デバイス名
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_DEVICE_NAME''
)
, get_XMLGEN_ip_address AS ( -- IPアドレス
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_IP_ADDRESS''
)
, medicine_order as (
    SELECT
    t.value ->> ''code'' AS cd
    , t.idx AS idx
    FROM mst_selector ms
    CROSS JOIN jsonb_array_elements(ms.order_settings -> ''items'') WITH ORDINALITY AS t(value,idx)
    WHERE ms.facility_cd =@facilityCd
    AND ms.master_physical_name = ''mst_medicine''
)
, own_expense_medicine_code AS (
    SELECT
    CASE (SELECT value FROM medicine_coop_cd_no)
        WHEN ''1'' THEN mmd.in_hospital_cd_1
        WHEN ''2'' THEN mmd.in_hospital_cd_2
        WHEN ''3'' THEN mmd.in_hospital_cd_3
        WHEN ''4'' THEN mmd.in_hospital_cd_4
        END AS own_med_cd
    , mco.idx AS idx
    from own_expense_medicine_code_list oemc
    inner JOIN mst_medicine mmd
    ON (CASE (SELECT value FROM medicine_coop_cd_no)
        WHEN ''1'' THEN mmd.in_hospital_cd_1 = oemc.split_cd
        WHEN ''2'' THEN mmd.in_hospital_cd_2 = oemc.split_cd
        WHEN ''3'' THEN mmd.in_hospital_cd_3 = oemc.split_cd
        WHEN ''4'' THEN mmd.in_hospital_cd_4 = oemc.split_cd
        END)
    LEFT JOIN medicine_order mco
    ON mmd.medicine_cd::text = mco.cd
    UNION
    SELECT '''' AS own_med_cd, 0 AS idx
)
, orderreqsend_start_end_flg AS ( --開始日終了日設定フラグ 
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ORDERREQSEND_START_END_FLG''
)
SELECT
    pcd.save_2->>''ord_no'' as ord_no,
    pcd.save_2->>''updater'' as updater,
    pcd.save_2->>''addition'' as addition,
    pcd.save_2->>''dialysis_type'' as dialysis_type,
    pcd.save_2->>''dialysis_course'' as dialysis_course,
    pcd.save_2->>''update_terminal'' as update_terminal,
    pcd.save_2->>''dialysis_pattern'' as dialysis_pattern,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''end_date_regular''
    END as end_date_regular,
    pcd.save_2->>''insurance_code_01'' as insurance_code_01,
    pcd.save_2->>''insurance_code_02'' as insurance_code_02,
    pcd.save_2->>''insurance_code_03'' as insurance_code_03,
    pcd.save_2->>''instruction_doctor'' as instruction_doctor,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''start_date_regular''
    END as start_date_regular,
    pcd.save_2->>''implementation_place'' as implementation_place,
    pcd.save_2->>''updater_generation_no'' as updater_generation_no,
    pcd.save_2->>''addition_generation_no'' as addition_generation_no,
    pcd.save_2->>''instruction_department'' as instruction_department,
    pcd.save_2->>''blood_purification_method'' as blood_purification_method,
    pcd.save_2->>''blood_purification_generation_no'' as blood_purification_generation_no,
    pcd.save_2->>''instruction_doctor_generation_no'' as instruction_doctor_generation_no,
    pcd.save_2->>''kur_cd1'' as kur_cd1,
    pcd.save_2->>''va3'' as va3,
    pcd.save_2->>''va_direct'' as va_direct,
    pcd.save_2->>''dw'' as dw,
    --ind_dial_V1_指示科_指示医_指示医世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM ind_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS ind_depart_code,
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT main_course_cd FROM main_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM ind_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS ind_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(
            NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM up_ind_user_id), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        END AS ind_doctor,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor_generation_no'', ''''), ''0'')
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''0''
        END AS ind_doctor_generation_no,
    --rst_dial_V1_実施診療科_実施医師_実施医師世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT main_course_cd FROM main_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS rst_course,
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT main_course_cd FROM main_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_del_nec_bed_course), ''''), (SELECT value FROM def_course))
        ELSE NULL
        END AS rst_del_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v1), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v1,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v2), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v2,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor_generation_no'', ''''), ''0'')
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''0''
        END AS rst_doctor_generation_no,
    '''' AS own_medi_code,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_obj_type), '''')) as obj_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_cd), '''')) as xml_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_hosp_cd), '''')) as hosp_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_cd), '''')) as title_cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_name), '''')) as title_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_fs_disp), '''')) as fs_disp,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_number), '''')) as content_number,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_type), '''')) as content_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_extent_name), '''')) as extent_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_device_name), '''')) as device_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address
FROM
    pat_coop_detail pcd
WHERE
    pcd.pat_id = @patId
    AND is_del = ''0''
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    AND coop_version = @coopVersion
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    AND ''1'' = @messageType
UNION
SELECT
    pcd.save_2->>''ord_no'' as ord_no,
    (SELECT disp_user_id FROM up_user_id) as updater,
    pcd.save_2->>''addition'' as addition,
    pcd.save_2->>''dialysis_type'' as dialysis_type,
    pcd.save_2->>''dialysis_course'' as dialysis_course,
    (SELECT value FROM def_update_terminal) as update_terminal,
    pcd.save_2->>''dialysis_pattern'' as dialysis_pattern,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''end_date_regular''
    END as end_date_regular,
    pcd.save_2->>''insurance_code_01'' as insurance_code_01,
    pcd.save_2->>''insurance_code_02'' as insurance_code_02,
    pcd.save_2->>''insurance_code_03'' as insurance_code_03,
    pcd.save_2->>''instruction_doctor'' as instruction_doctor,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''start_date_regular''
    END as start_date_regular,
    pcd.save_2->>''implementation_place'' as implementation_place,
    pcd.save_2->>''updater_generation_no'' as updater_generation_no,
    pcd.save_2->>''addition_generation_no'' as addition_generation_no,
    pcd.save_2->>''instruction_department'' as instruction_department,
    pcd.save_2->>''blood_purification_method'' as blood_purification_method,
    pcd.save_2->>''blood_purification_generation_no'' as blood_purification_generation_no,
    pcd.save_2->>''instruction_doctor_generation_no'' as instruction_doctor_generation_no,
    pcd.save_2->>''kur_cd1'' as kur_cd1,
    pcd.save_2->>''va3'' as va3,
    pcd.save_2->>''va_direct'' as va_direct,
    pcd.save_2->>''dw'' as dw,
    --ind_dial_V2_指示科_指示医_指示医世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM ind_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS ind_depart_code,
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT main_course_cd FROM main_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM ind_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS ind_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN NULL
        WHEN ''1'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM up_ind_user_id), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        END AS ind_doctor,
    ''0'' AS ind_doctor_generation_no,
    --rst_dial_V2_実施診療科_実施医師_実施医師世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT main_course_cd FROM main_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS rst_course,
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT main_course_cd FROM main_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_del_nec_bed_course), ''''), (SELECT value FROM def_course))
        ELSE NULL
        END AS rst_del_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v1), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v1,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v2), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v2,
    ''0'' AS rst_doctor_generation_no,
    CASE WHEN (SELECT count(*) FROM own_expense_medicine_code) = 1
    THEN ''   ''
    ELSE (SELECT own_med_cd FROM own_expense_medicine_code WHERE idx <> 0 ORDER BY idx LIMIT 1)
    END AS own_medi_code,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_obj_type), '''')) as obj_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_cd), '''')) as xml_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_hosp_cd), '''')) as hosp_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_cd), '''')) as title_cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_name), '''')) as title_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_fs_disp), '''')) as fs_disp,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_number), '''')) as content_number,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_type), '''')) as content_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_extent_name), '''')) as extent_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_device_name), '''')) as device_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address
FROM pat_coop_detail pcd
WHERE pcd.pat_id = @patId
    AND is_del = ''0''
    AND coop_version = @coopVersion
    AND ''2'' = @messageType
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者補完情報20個', '2020-05-01 09:43:15.820', CURRENT_TIMESTAMP, '[{"sql_cd": -600300, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-98, 'select
	to_char(to_number(ppm.hosp_pat_id,''999999999999''),''0000000000'') as hosp_pat_id10,
	to_char(to_number(ppm.hosp_pat_id,''999999999999''),''000000000000'') as hosp_pat_id12,
	to_char(to_number(ppm.hosp_pat_id,''999999999999''),''999999999999'') as hosp_pat_id,
	to_number(ppm.hosp_pat_id,''999999999999'') as hosp_pat_id_int,
	ppm.hosp_pat_id::TEXT AS hosp_pat_id_text
from
	pat_personal_main ppm
where
	ppm.pat_id = @patId
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）pat_id→hosp_pat_id', '2020-05-26 15:36:09.236', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-33, 'SELECT
  lpad(to_char(ord.rst_dw * 100, ''FM99999''), 4, '' '') AS dw
  , lpad(
    to_char(
      to_number(
        ord.rst_weight_info ->> ''weight_before''
        , ''999.99''
      ) * 100
      , ''FM00000''
    )
    , 5
    , '' ''
  ) AS weight_before
  , lpad(
    to_char(
      to_number(
        ord.rst_weight_info ->> ''weight_after''
        , ''999.99''
      ) * 100
      , ''FM00000''
    )
    , 5
    , '' ''
  ) AS weight_after
FROM
  ord_main ord
WHERE
  ord.ord_no = @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)透析前後体重（9(5,2)）', '2020-05-18 12:55:11.326', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9101, 'UPDATE pat_personal_main 
SET
  in_out_class = CASE ''@medicalCareInfo.wardCd'' 
    WHEN '''' THEN 0
    ELSE 1
    END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''
  AND COALESCE(NULLIF(''@medicalCareInfo.wardCd'', ''''), ''NONE'') <> ''NONE''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの入外区分の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9102, 'UPDATE pat_personal_main 
SET
  other_contact_info = ''[]''
  , dial_diff_com_info = COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') :: JSONB
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの「連絡先情報、透析困難情報」のクリア', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9103, 'WITH pat_name AS (
SELECT
    CASE
        WHEN POSITION('' '' IN ''@otherContactInfo.patName'') = 0 AND POSITION(''　'' IN ''@otherContactInfo.patName'') = 0 THEN ''@otherContactInfo.patName''
        WHEN POSITION('' '' IN ''@otherContactInfo.patName'') > 0 THEN TRIM(substring(''@otherContactInfo.patName'' FROM 1 FOR POSITION('' '' IN ''@otherContactInfo.patName'') - 1))
        ELSE TRIM(substring(''@otherContactInfo.patName'' FROM 1 FOR POSITION(''　'' IN ''@otherContactInfo.patName'') - 1))
    END AS last_name,
    CASE
        WHEN POSITION('' '' IN ''@otherContactInfo.patName'') > 0 THEN TRIM(substring(''@otherContactInfo.patName'' FROM POSITION('' '' IN ''@otherContactInfo.patName'') + 1))
        WHEN POSITION(''　'' IN ''@otherContactInfo.patName'') > 0 THEN TRIM(substring(''@otherContactInfo.patName'' FROM POSITION(''　'' IN ''@otherContactInfo.patName'') + 1))
        ELSE ''''
    END AS first_name,
    CASE
        WHEN POSITION('' '' IN ''@otherContactInfo.patNameKana'') = 0 AND POSITION(''　'' IN ''@otherContactInfo.patNameKana'') = 0 THEN ''@otherContactInfo.patNameKana''
        WHEN POSITION('' '' IN ''@otherContactInfo.patNameKana'') > 0 THEN TRIM(substring(''@otherContactInfo.patNameKana'' FROM 1 FOR POSITION('' '' IN ''@otherContactInfo.patNameKana'') - 1))
        ELSE TRIM(substring(''@otherContactInfo.patNameKana'' FROM 1 FOR POSITION(''　'' IN ''@otherContactInfo.patNameKana'') - 1))
    END AS last_name_kana,
    CASE
        WHEN POSITION('' '' IN ''@otherContactInfo.patNameKana'') > 0 THEN TRIM(substring(''@otherContactInfo.patNameKana'' FROM POSITION('' '' IN ''@otherContactInfo.patNameKana'') + 1))
        WHEN POSITION(''　'' IN ''@otherContactInfo.patNameKana'') > 0 THEN TRIM(substring(''@otherContactInfo.patNameKana'' FROM POSITION(''　'' IN ''@otherContactInfo.patNameKana'') + 1))
        ELSE ''''
    END AS first_name_kana
),
json_data AS (
  SELECT 
  ''[{"ctl_no":1,"disp_order":0,"is_key_person":null,"pat_id":null,"last_name":"''||(select last_name from pat_name)||''","first_name":"''||(select first_name from pat_name)||''","last_name_kana":"''||(select last_name_kana from pat_name)||''","first_name_kana":"''||(select first_name_kana from pat_name)||''","relation_cd":null,"relation_name":null,"zip_cd":"@otherContactInfo.zipCd","address":"@otherContactInfo.address","e_mail":null,"work_name":null,"work_address":null,"work_tel":null,"tel1":"@otherContactInfo.tel1","tel2":null,"fax":null,"memo1":null,"memo2":null}]'' AS otherContactInfo
)
UPDATE pat_personal_main 
SET
  other_contact_info = CASE WHEN ''@otherContactInfo.tel1''='''' AND ''@otherContactInfo.zipCd''='''' AND ''@otherContactInfo.address''='''' THEN other_contact_info ELSE (SELECT otherContactInfo FROM json_data) :: jsonb END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの「死亡患者、連絡先情報、透析困難情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9104, 'UPDATE pat_main 
SET charge_staff_info = CASE 
        WHEN charge_staff_info IS NULL THEN ''[]'' 
        ELSE charge_staff_info 
    END, 
--  infect_info = ''[]'', 
  taboo_allergy_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND @is_die = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの「担当スタッフ情報、感染症情報、禁忌・アレルギー情報」のクリア', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9105, 'WITH infection_nec_sub AS ( 
  -- NECから、感染症情報
  SELECT
    1 AS order_no
    , ''@infectInfo1'' AS CONTENT
  UNION 
  SELECT
    2 AS order_no
    , ''@infectInfo2'' AS CONTENT
  UNION 
  SELECT
    3 AS order_no
    , ''@infectInfo3'' AS CONTENT
  UNION 
  SELECT
    4 AS order_no
    , ''@infectInfo4'' AS CONTENT
  UNION 
  SELECT
    5 AS order_no
    , ''@infectInfo5'' AS CONTENT
  UNION 
  SELECT
    6 AS order_no
    , ''@infectInfo6'' AS CONTENT
  UNION 
  SELECT
    7 AS order_no
    , ''@infectInfo7'' AS CONTENT
  UNION 
  SELECT
    8 AS order_no
    , ''@infectInfo8'' AS CONTENT
  UNION 
  SELECT
    9 AS order_no
    , ''@infectInfo9'' AS CONTENT
  UNION 
  SELECT
    10 AS order_no
    , ''@infectInfo10'' AS CONTENT
  UNION 
  SELECT
    11 AS order_no
    , ''@infectInfo11'' AS CONTENT
  UNION 
  SELECT
    12 AS order_no
    , ''@infectInfo12'' AS CONTENT
  UNION 
  SELECT
    13 AS order_no
    , ''@infectInfo13'' AS CONTENT
  UNION 
  SELECT
    14 AS order_no
    , ''@infectInfo14'' AS CONTENT
  UNION 
  SELECT
    15 AS order_no
    , ''@infectInfo15'' AS CONTENT
  UNION 
  SELECT
    16 AS order_no
    , ''@infectInfo16'' AS CONTENT
  UNION 
  SELECT
    17 AS order_no
    , ''@infectInfo17'' AS CONTENT
  UNION 
  SELECT
    18 AS order_no
    , ''@infectInfo18'' AS CONTENT
  UNION 
  SELECT
    19 AS order_no
    , ''@infectInfo19'' AS CONTENT
  UNION 
  SELECT
    20 AS order_no
    , ''@infectInfo20'' AS CONTENT
  ORDER BY
    order_no ASC
) 
, infection_ini AS ( 
  SELECT
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''INFECT_'', '''')
      , ''FM99''
    ) AS order_no
    , CASE 
      WHEN NULLIF(ini_info ->> ''value'', '''') IS NULL 
        THEN ini_info ->> ''default_v'' 
      ELSE ini_info ->> ''value'' 
      END AS hospital_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
    AND ini_info ->> ''key1'' = ''NEC'' 
    AND ini_info ->> ''key2'' LIKE ''INFECT_%'' 
  ORDER BY
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''INFECT_'', '''')
      , ''FM99''
    ) ASC
) 
, infection_nec AS ( 
  SELECT
    ini.hospital_cd
    , CASE sub.CONTENT 
      WHEN ''+'' THEN ''2'' 
      WHEN ''-'' THEN ''1''  
      ELSE ''0'' 
      END AS CONTENT 
  FROM
    infection_nec_sub AS sub 
    INNER JOIN infection_ini AS ini 
      ON sub.order_no = ini.order_no
) 
, infection_ntss AS ( 
  SELECT
    A.infection_cd
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_infection A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_infection''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.infection_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, infectInfo AS ( 
  SELECT
    array_to_json( 
      ARRAY_AGG( 
        CASE 
          WHEN NULLIF(infection_nec.CONTENT, '''') IS NULL 
            THEN info.* 
          ELSE json_build_object( 
            ''infect''
            , infection_nec.CONTENT
            , ''exam_date''
            , info ->> ''exam_date''
            , ''up_date''
            , TO_CHAR(CURRENT_DATE, ''YYYYMMDD'')
            , ''infection_cd''
            , (info ->> ''infection_cd'')::integer
          ) 
          END
      )
    ) AS infect_info_new 
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.infect_info ::json) info 
    LEFT OUTER JOIN infection_ntss 
      ON infection_ntss.infection_cd ::TEXT = info ->> ''infection_cd'' 
    LEFT OUTER JOIN infection_nec 
      ON infection_nec.hospital_cd = infection_ntss.hospital_cd 
      AND NULLIF(infection_nec.CONTENT, '''') IS NOT NULL 
  WHERE
    pat.pat_id = @patId
)
, taboo_allergy_nec_sub AS ( 
  -- NECから、薬剤禁忌情報
  SELECT
    1 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 1, 1) AS CONTENT 
  UNION 
  SELECT
    2 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 2, 1) AS CONTENT 
  UNION 
  SELECT
    3 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 3, 1) AS CONTENT 
  UNION 
  SELECT
    4 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 4, 1) AS CONTENT 
  UNION 
  SELECT
    5 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 5, 1) AS CONTENT 
  UNION 
  SELECT
    6 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 6, 1) AS CONTENT 
  UNION 
  SELECT
    7 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 7, 1) AS CONTENT 
  UNION 
  SELECT
    8 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 8, 1) AS CONTENT 
  UNION 
  SELECT
    9 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 9, 1) AS CONTENT 
  UNION 
  SELECT
    10 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 10, 1) AS CONTENT 
  UNION 
  SELECT
    11 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 11, 1) AS CONTENT 
  UNION 
  SELECT
    12 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 12, 1) AS CONTENT 
  UNION 
  SELECT
    13 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 13, 1) AS CONTENT 
  UNION 
  SELECT
    14 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 14, 1) AS CONTENT 
  UNION 
  SELECT
    15 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 15, 1) AS CONTENT 
  UNION 
  SELECT
    16 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 16, 1) AS CONTENT 
  UNION 
  SELECT
    17 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 17, 1) AS CONTENT 
  UNION 
  SELECT
    18 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 18, 1) AS CONTENT 
  UNION 
  SELECT
    19 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 19, 1) AS CONTENT 
  UNION 
  SELECT
    20 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 20, 1) AS CONTENT 
  ORDER BY
    order_no ASC
) 
, taboo_allergy_ini AS ( 
  SELECT
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''TABOO_'', '''')
      , ''FM99''
    ) AS order_no
    , CASE 
      WHEN NULLIF(ini_info ->> ''value'', '''') IS NULL 
        THEN ini_info ->> ''default_v'' 
      ELSE ini_info ->> ''value'' 
      END AS hospital_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
    AND ini_info ->> ''key1'' = ''NEC'' 
    AND ini_info ->> ''key2'' LIKE ''TABOO_%'' 
    AND ini_info ->> ''key2'' <> ''TABOO_CTL_NO'' 
  ORDER BY
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''TABOO_'', '''')
      , ''FM99''
    ) ASC
) 
, taboo_allergy_nec AS ( 
  SELECT
    ini.order_no
    , ini.hospital_cd
    , ROW_NUMBER() OVER () AS index_no 
  FROM
    taboo_allergy_nec_sub AS sub 
    INNER JOIN taboo_allergy_ini AS ini 
      ON sub.order_no = ini.order_no 
  WHERE
    sub.CONTENT = ''1'' 
  ORDER BY
    ini.order_no
) 
, taboo_allergy_ntss AS ( 
  SELECT
    A.taboo_allergy_cd
    , A.in_hospital_cd_1 AS hospital_cd
    , A.CONTENT 
  FROM
    mst_taboo_allergy A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_taboo_allergy''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.taboo_allergy_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, tabooAllergyInfo AS ( 
  SELECT
    array_to_json( 
      ARRAY_AGG(
        json_build_object(
          ''memo'',
          NULL,
          ''ctl_no'',
          nec.index_no,
          ''content'',
          ntss_hospital_cd.content,
          ''disp_order'',
          nec.index_no,
          ''category_class'',
          ''0'',
          ''taboo_allergy_cd'',
          ntss_hospital_cd.taboo_allergy_cd,
          ''taboo_allergy_class'',
          ''1''
        )
      )
    ) AS taboo_allergy_info_new 
  FROM
    taboo_allergy_nec AS nec 
    LEFT OUTER JOIN taboo_allergy_ntss AS ntss_hospital_cd 
      ON nec.hospital_cd = ntss_hospital_cd.hospital_cd 
  WHERE ntss_hospital_cd.taboo_allergy_cd IS NOT NULL
)
, check_staff_code AS (
  SELECT (CASE
    -- Case 1: スタッフコードが空またはNULLの場合
    WHEN  '''' = ''@user_id''
         OR ''@'' || ''user_id'' = ''@user_id''
    THEN 
        ''-999999''
    -- Case 2: スタッフコードが数値でない場合
    WHEN NOT ''@user_id'' ~ ''^[0-9]+$''
    THEN
        ''-999999''
    -- Case 3: 該当するユーザーが存在しない場合
    WHEN NOT EXISTS (
        SELECT 1
        FROM mst_user
        WHERE facility_cd = ''@facilityCd''
          AND user_id::text = ''@user_id''
          AND is_disp = ''1''
          AND is_del = ''0''
    )
    THEN
        ''-999999''
    -- Case 4: すでに同じstaff_cdが存在する場合
    WHEN EXISTS (
        SELECT 1
        FROM pat_main, jsonb_array_elements(charge_staff_info) elem
        WHERE pat_id = @patId 
        AND facility_cd = ''@facilityCd''
        AND elem ->> ''staff_cd''::text = ''@user_id''
    )
    THEN
        ''-999999''
    -- Case 5: すべての条件を満たさない場合のみ新規追加
    ELSE ''@user_id''
    END) AS staff_code
)

UPDATE pat_main 
SET
charge_staff_info = CASE 
    WHEN  (SELECT staff_code FROM check_staff_code) = ''-999999''
    THEN 
        charge_staff_info
    ELSE 
        charge_staff_info || jsonb_build_array(
            jsonb_build_object(
                ''ctl_no'', (SELECT jsonb_array_length(charge_staff_info)) + 1,
                ''disp_order'', (SELECT jsonb_array_length(charge_staff_info)) + 1,
                ''staff_cd'', (SELECT staff_code FROM check_staff_code) :: int,
                ''is_main'', ''0'',
                ''is_charge'', ''0'',
                ''is_puncture'', ''0''
            )
        )
END
  , infect_info = (SELECT infect_info_new FROM infectInfo) ::JSONB
  , taboo_allergy_info = COALESCE( 
    NULLIF( 
      ( 
        SELECT
          taboo_allergy_info_new 
        FROM
          tabooAllergyInfo
      ) ::TEXT
      , ''''
    ) 
    , ''[]''
  ) ::JSONB 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND @is_die = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの「担当スタッフ情報、感染症情報、禁忌・アレルギー情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}, {"sql_cd": -600106, "field_name": "user_id", "replace_var": "@user_id"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9106, 'INSERT INTO pat_unique(
  pat_id,
  medical_hst_info,
  in_out_visit_history_info,
  physical_info,
  is_del,
  up_date,
  reg_date,
  facility_cd,
  old_up_date_unique
) 
VALUES (
  @patId,
  ''[]'',
  ''[]'',
  CASE
    WHEN ''@physicalInfo.height'' = '''' THEN ''[]'' :: jsonb
    ELSE jsonb_build_array(
      jsonb_build_object(
        ''ctl_no'', 1,
        ''exam_date'', CURRENT_DATE :: text,
        ''order_class'', @physicalInfo.orderClass,
        ''height'', TO_CHAR(@physicalInfo.height, ''FM999.0''),
        ''ctr_weight'', NULL,
        ''breast_dia'', NULL,
        ''chest_dia'', NULL,
        ''ctr'', NULL,
        ''dw'', NULL,
        ''indicator_cd'', NULL,
        ''indicator_start_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''memo'', NULL,
        ''pre_scale_upper'', NULL,
        ''pre_scale_lower'', NULL,
        ''facility_cd'', NULL,
        ''inspect_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''changer_cd'', NULL,
        ''target_weight'', NULL
      )
    )
  END,
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  ''@facilityCd'',
  NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者固有情報「身体情報」の登録', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9107, 'WITH latest_element AS (
    SELECT pat_id, p_info.value AS elem
    FROM pat_unique
    CROSS JOIN LATERAL jsonb_array_elements(physical_info) AS p_info
    WHERE pat_id = @patId
    ORDER BY p_info->>''exam_date'' DESC
    LIMIT 1
),
updated_elements AS (
    SELECT pat_id, jsonb_agg(
        CASE
            WHEN elem->>''exam_date'' = CURRENT_DATE :: text
            THEN jsonb_set(elem, ''{height}'', ''"@physicalInfo.height"'')
            ELSE elem
        END
    ) AS updated_data,
    bool_or(elem->>''exam_date'' = CURRENT_DATE :: text) AS has_date,
    bool_or((SELECT elem->>''height'' FROM latest_element) != ''@physicalInfo.height'') AS is_change,
    max((elem->>''ctl_no'')::int) + 1 AS next_ctl_no
    FROM pat_unique,
    jsonb_array_elements(physical_info) AS elem
    WHERE pat_id = @patId
    GROUP BY pat_id
),
final_update AS (
    SELECT pat_id,
           CASE
               WHEN has_date OR NOT is_change THEN updated_data
               ELSE updated_data || jsonb_build_array(
      jsonb_build_object(
        ''ctl_no'', next_ctl_no,
        ''exam_date'', CURRENT_DATE :: text,
        ''order_class'', ''@physicalInfo.orderClass'',
        ''height'', (
          SELECT
            CASE
              ''@physicalInfo.height''
              WHEN '''' THEN NULL
              ELSE TO_CHAR(@physicalInfo.height, ''FM999.0'')
            END
        ),
        ''ctr_weight'', NULL,
        ''breast_dia'', NULL,
        ''chest_dia'', NULL,
        ''ctr'', NULL,
        ''dw'', NULL,
        ''indicator_cd'', NULL,
        ''indicator_start_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''memo'', NULL,
        ''pre_scale_upper'', NULL,
        ''pre_scale_lower'', NULL,
        ''facility_cd'', NULL,
        ''inspect_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''changer_cd'', NULL,
        ''target_weight'', NULL
      )
    )
           END AS final_data
    FROM updated_elements
)
UPDATE pat_unique
SET physical_info = CASE 
  WHEN physical_info IS NULL OR physical_info = ''[]''
  THEN jsonb_build_array(
      jsonb_build_object(
        ''ctl_no'', 1,
        ''exam_date'', CURRENT_DATE :: text,
        ''order_class'', ''@physicalInfo.orderClass'',
        ''height'', TO_CHAR(@physicalInfo.height, ''FM999.0''),
        ''ctr_weight'', NULL,
        ''breast_dia'', NULL,
        ''chest_dia'', NULL,
        ''ctr'', NULL,
        ''dw'', NULL,
        ''indicator_cd'', NULL,
        ''indicator_start_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''memo'', NULL,
        ''pre_scale_upper'', NULL,
        ''pre_scale_lower'', NULL,
        ''facility_cd'', NULL,
        ''inspect_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''changer_cd'', NULL,
        ''target_weight'', NULL
      )
    )
    ELSE (SELECT final_data FROM final_update)
END
  WHERE pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND @is_die = ''0'';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者固有情報「身体情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9111, 'SELECT
    coop_save_no
  , facility_cd
  , pat_id
  , save_1
  , save_2
  , save_3
  , save_4
  , save_5
  , save_6
  , save_7
  , save_8
  , save_9
  , save_10
  , is_disp
  , is_del
  , user_id
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , coop_version
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , up_date
  , reg_date
FROM
  pat_coop_detail 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd 
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND coop_version = @coopVersion
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND is_del = ''0''
  AND is_disp = ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者連携情報の取得', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9112, 'INSERT INTO pat_coop_detail( 
  facility_cd,
  pat_id,
  save_1,
  save_2,
  save_3,
  save_4,
  save_5,
  save_6,
  save_7,
  save_8,
  save_9,
  save_10,
  is_disp,
  is_del,
  user_id,
  coop_version,
  up_date,
  reg_date
) 
VALUES (
  ''@facilityCd'',
  @patId,
  jsonb_build_object(''pkg'', ''HR''),
  jsonb_build_object(
    ''ord_no'', NULLIF(''@save2.ord_no'', ''''),
    ''instruction_doctor_generation_no'', NULLIF(''@save2.instruction_doctor_generation_no'', ''''),
    ''dialysis_type'', NULLIF(''@save2.dialysis_type'', ''''),
    ''dialysis_course'', NULLIF(''@save2.dialysis_course'', ''''),
    ''dialysis_pattern'', NULLIF(''@save2.dialysis_pattern'', ''''),
    ''start_date_regular'', NULLIF(''@save2.start_date_regular'', ''''),
    ''end_date_regular'', NULLIF(''@save2.end_date_regular'', ''''),
    ''implementation_place'', NULLIF(''@save2.implementation_place'', ''''),
    ''update_terminal'', NULLIF(''@save2.update_terminal'', ''''),
    ''instruction_department'', NULLIF(''@save2.instruction_department'', ''''),
    ''instruction_doctor'', NULLIF(''@save2.instruction_doctor'', ''''),
    ''insurance_code_01'', NULLIF(''@save2.insurance_code_01'', ''''),
    ''insurance_code_02'', NULLIF(''@save2.insurance_code_02'', ''''),
    ''insurance_code_03'', NULLIF(''@save2.insurance_code_03'', ''''),
    ''addition'', NULLIF(''@save2.addition'', ''''),
    ''addition_generation_no'', NULLIF(''@save2.addition_generation_no'', ''''),
    ''blood_purification_method'', NULLIF(''@save2.blood_purification_method'', ''''),
    ''blood_purification_generation_no'', NULLIF(''@save2.blood_purification_generation_no'', ''''),
    ''updater'', NULLIF(''@save2.updater'', ''''),
    ''kur_cd1'', NULLIF(''@save2.kur_cd1'', ''''),
    ''va3'', NULLIF(''@save2.va3'', ''''),
    ''va_direct'', NULLIF(''@save2.va_direct'', ''''),
    ''dw'', NULLIF(''@save2.dw'', ''''),
    ''updater_generation_no'', NULLIF(''@save2.updater_generation_no'', '''')
  ),
  ''[]'',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  ''1'',
  ''0'',
  @userId,
  ''@coopVersion'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者連携情報の登録', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9113, 'UPDATE pat_coop_detail 
SET
    save_1 = jsonb_build_object(''pkg'', ''HR'')
    , save_2 = jsonb_build_object(
        ''ord_no'', NULLIF(''@save2.ord_no'', ''''),
        ''instruction_doctor_generation_no'', NULLIF(''@save2.instruction_doctor_generation_no'', ''''),
        ''dialysis_type'', NULLIF(''@save2.dialysis_type'', ''''),
        ''dialysis_course'', NULLIF(''@save2.dialysis_course'', ''''),
        ''dialysis_pattern'', NULLIF(''@save2.dialysis_pattern'', ''''),
        ''start_date_regular'', NULLIF(''@save2.start_date_regular'', ''''),
        ''end_date_regular'', NULLIF(''@save2.end_date_regular'', ''''),
        ''implementation_place'', NULLIF(''@save2.implementation_place'', ''''),
        ''update_terminal'', NULLIF(''@save2.update_terminal'', ''''),
        ''instruction_department'', NULLIF(''@save2.instruction_department'', ''''),
        ''instruction_doctor'', NULLIF(''@save2.instruction_doctor'', ''''),
        ''insurance_code_01'', NULLIF(''@save2.insurance_code_01'', ''''),
        ''insurance_code_02'', NULLIF(''@save2.insurance_code_02'', ''''),
        ''insurance_code_03'', NULLIF(''@save2.insurance_code_03'', ''''),
        ''addition'', NULLIF(''@save2.addition'', ''''),
        ''addition_generation_no'', NULLIF(''@save2.addition_generation_no'', ''''),
        ''blood_purification_method'', NULLIF(''@save2.blood_purification_method'', ''''),
        ''blood_purification_generation_no'', NULLIF(''@save2.blood_purification_generation_no'', ''''),
        ''updater'', NULLIF(''@save2.updater'', ''''),
        ''kur_cd1'', NULLIF(''@save2.kur_cd1'', ''''),
        ''va3'', NULLIF(''@save2.va3'', ''''),
        ''va_direct'', NULLIF(''@save2.va_direct'', ''''),
        ''dw'', NULLIF(''@save2.dw'', ''''),
        ''updater_generation_no'', NULLIF(''@save2.updater_generation_no'', '''')
  )
  , save_3 = ''[]''
  , user_id = @userId
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND coop_save_no = @coopSaveNo
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者連携情報の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9119, 'UPDATE pat_coop_detail 
SET
  save_3 = save_3 || jsonb_build_array(jsonb_build_object(
    ''addition_pat_cd'', NULLIF(''@save3.addition_pat_cd'', ''''),
    ''addition_other_cd'', NULLIF(''@save3.addition_other_cd'', ''''),
    ''item_comment_cd'', NULLIF(''@save3.item_comment_cd'', ''''),
    ''dialysis_cmt_1_cd'', NULLIF(''@save3.dialysis_cmt_1_cd'', ''''),
    ''dialysis_cmt_2_cd'', NULLIF(''@save3.dialysis_cmt_2_cd'', ''''),
    ''dialysis_cmt_3_cd'', NULLIF(''@save3.dialysis_cmt_3_cd'', ''''),
    ''addition_pat_generation_no'', NULLIF(''@save3.addition_pat_generation_no'', ''''),
    ''addition_other_generation_no'', NULLIF(''@save3.addition_other_generation_no'', ''''),
    ''item_comment_generation_no'', NULLIF(''@save3.item_comment_generation_no'', ''''),
    ''dialysis_cmt_1_generation_no'', NULLIF(''@save3.dialysis_cmt_1_generation_no'', ''''),
    ''dialysis_cmt_2_generation_no'', NULLIF(''@save3.dialysis_cmt_2_generation_no'', ''''),
    ''dialysis_cmt_3_generation_no'', NULLIF(''@save3.dialysis_cmt_3_generation_no'', ''''),
    ''item_number'', NULLIF(''@save3.item_number'', ''''),
    ''item_code'', NULLIF(''@save3.item_code'', ''''),
    ''item_generation'', NULLIF(''@save3.item_generation'', ''''),
    ''item_name'', NULLIF(''@save3.item_name'', ''''),
    ''function_code'', NULLIF(''@save3.function_code'', ''''),
    ''usage_amount'', NULLIF(''@save3.usage_amount'', ''''),
    ''usage_unit'', NULLIF(''@save3.usage_unit'', ''''),
    ''usage_unit_name'', NULLIF(''@save3.usage_unit_name'', ''''),
    ''speed'', NULLIF(''@save3.speed'', ''''),
    ''speed_unit'', NULLIF(''@save3.speed_unit'', ''''),
    ''speed_unit_name'', NULLIF(''@save3.speed_unit_name'', ''''),
    ''comment_code_1'', NULLIF(''@save3.comment_code_1'', ''''),
    ''comment_generation_1'', NULLIF(''@save3.comment_generation_1'', ''''),
    ''comment_name_1'', NULLIF(''@save3.comment_name_1'', ''''),
    ''comment_code_2'', NULLIF(''@save3.comment_code_2'', ''''),
    ''comment_generation_2'', NULLIF(''@save3.comment_generation_2'', ''''),
    ''comment_name_2'', NULLIF(''@save3.comment_name_2'', ''''),
    ''comment_code_3'', NULLIF(''@save3.comment_code_3'', ''''),
    ''comment_generation_3'', NULLIF(''@save3.comment_generation_3'', ''''),
    ''comment_name_3'', NULLIF(''@save3.comment_name_3'', ''''),
    ''free_comment'', NULLIF(''@save3.free_comment'', ''''),
    ''interface_flag'', NULLIF(''@save3.interface_flag'', ''''),
    ''reserve'', NULLIF(''@save3.reserve'', '''')
    )),
  user_id = @userId,
  up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0''
  AND is_disp = ''1''
  AND coop_save_no = @coopSaveNo
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NEC治療情報「指示：加算情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9205, 'WITH exam_item_nec AS ( 
  SELECT
    NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF(''@examResultInfo.type'', '''') AS type
    , NULLIF(''@examResultInfo.unit'', '''') AS unit
    , NULLIF(''@examResultInfo.lower'', '''') AS lower
    , NULLIF(''@examResultInfo.upper'', '''') AS upper
    , NULLIF( 
      ( 
        CASE 
          WHEN ''@examResultInfo.comCd1'' <> '''' AND ''@examResultInfo.comCd2'' <> '''' 
          THEN ''@examResultInfo.comCd1'' || '','' || ''@examResultInfo.comCd2'' 
          ELSE ''@examResultInfo.comCd1'' || ''@examResultInfo.comCd2'' 
          END
      ) , '''') AS com_cd
    , NULLIF(''@examResultInfo.result'', '''') AS result
    , NULLIF(''@examResultInfo.itemCd'', '''') AS item_cd
    , '''' AS freememo
    , NULLIF(''@examResultInfo.itemName'', '''') AS item_name
    , NULLIF(''@nextDispOrder'', '''') AS disp_order
    , NULLIF(''@examResultInfo.examClass'', '''') AS exam_class
    , NULLIF(''@examResultInfo.resultDate_Date'', '''') AS result_date
) 
, exam_item_ntss AS ( 
  SELECT
    A.exam_item_cd
    , A.exam_item_name
    , A.data_type
    , A.unit
    , A.exam_class
    , A.input_upper
    , A.input_lower
    , A.in_hospital_cd1 AS hospital_cd1
    , A.in_hospital_cd2 AS hospital_cd2
    , A.in_hospital_cd3 AS hospital_cd3 
  FROM
    mst_exam_item A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_exam_item''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.exam_item_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, exam_result_nec AS ( 
  SELECT
    nec.hl 
    , COALESCE(nec.type, ntss.data_type) AS type
    , COALESCE(nec.unit, ntss.unit) AS unit
    , COALESCE(nec.lower, ntss.input_lower) AS lower
    , COALESCE(nec.upper, ntss.input_upper) AS upper
    , nec.com_cd
    , nec.result AS result
    , COALESCE((ntss.exam_item_cd ::TEXT), nec.item_cd) AS item_cd
    , nec.freememo
    , COALESCE(nec.item_name, ntss.exam_item_name) AS item_name
    , nec.disp_order
    , COALESCE(COALESCE(nec.exam_class, ntss.exam_class), ''0'') AS exam_class
    , nec.result_date 
  FROM
    exam_item_nec AS nec 
    LEFT OUTER JOIN exam_item_ntss AS ntss ON ntss.hospital_cd1 = nec.item_cd
) 
, exam_result_exists AS ( 
  SELECT
    count(1) AS data_count 
  FROM
    pat_exam_main 
    CROSS JOIN LATERAL jsonb_array_elements(exam_result_info ::JSONB) AS info 
    INNER JOIN exam_result_nec AS nec ON nec.item_cd = info ->> ''item_cd'' 
  WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    AND exam_main_cd = @examMainCd
) 
, exam_result AS ( 
  -- JOSNにNECのデータが有りの場合、UPDATE
  SELECT
    array_to_json( 
      ARRAY_AGG( 
        CASE 
          WHEN nec.item_cd IS NULL 
            THEN info ::JSON 
          ELSE json_build_object( 
            ''hl''
            , nec.hl
            , ''type''
            , nec.type
            , ''unit''
            , nec.unit
            , ''lower''
            , nec.lower
            , ''upper''
            , nec.upper
            , ''com_cd''
            , nec.com_cd
            , ''result''
            , nec.result
            , ''item_cd''
            , nec.item_cd
            , ''freememo''
            , nec.freememo
            , ''item_name''
            , nec.item_name
            , ''disp_order''
            , nec.disp_order
            , ''exam_class''
            , nec.exam_class
            , ''result_date''
            , nec.result_date
          ) 
          END
      )
    ) AS exam_result_info_new 
  FROM
    pat_exam_main 
    CROSS JOIN LATERAL jsonb_array_elements(exam_result_info ::JSONB) AS info 
    LEFT OUTER JOIN exam_result_nec AS nec ON nec.item_cd = info ->> ''item_cd'' 
  WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    AND exam_main_cd = @examMainCd
    AND (SELECT data_count FROM exam_result_exists) > 0

  UNION ALL
  -- JOSNにNECのデータが無しの場合、INSERT
  SELECT
    CAST( 
      exam_result_info || ( 
        SELECT
          json_build_object( 
            ''hl''
            , nec.hl
            , ''type''
            , nec.type
            , ''unit''
            , nec.unit
            , ''lower''
            , nec.lower
            , ''upper''
            , nec.upper
            , ''com_cd''
            , nec.com_cd
            , ''result''
            , nec.result
            , ''item_cd''
            , nec.item_cd
            , ''freememo''
            , nec.freememo
            , ''item_name''
            , nec.item_name
            , ''disp_order''
            , nec.disp_order
            , ''exam_class''
            , nec.exam_class
            , ''result_date''
            , nec.result_date
          ) 
        FROM
          exam_result_nec AS nec
      ) ::JSONB AS JSON
    ) AS exam_result_info_new 
  FROM
    pat_exam_main 
  WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    AND exam_main_cd = @examMainCd 
    AND (SELECT data_count FROM exam_result_exists) = 0
) 
UPDATE pat_exam_main 
SET
  exam_result_info = CASE ''@examResultInfoFlg'' 
    WHEN '''' THEN ''@examResultInfoValue'' 
    ELSE (SELECT exam_result_info_new FROM exam_result WHERE exam_result_info_new is not null) ::JSONB 
    END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = to_timestamp(''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
  AND exam_main_cd = @examMainCd 
  AND NULLIF(''@examResultInfo.result'', '''') IS NOT NULL', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの検査結果(検査結果情報更新)', '2021-11-30 18:21:40.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9402, 'INSERT INTO mst_personal_user( 
  facility_cd
  , user_type
  , user_last_name
  , user_first_name
  , user_last_name_kana
  , user_first_name_kana
  , user_last_name_alpha
  , user_first_name_alpha
  , user_email_address_1
  , user_email_address_2
  , extension_no
  , home_no
  , mobile_phone_no
  , fax_no
  , zipcd_3
  , zipcd_4
  , address
  , address_kana
  , job_cd
  , reg_date
  , up_date
  , administrator
  , is_disp
  , is_del
  , in_hospital_cd_1
  , in_hospital_cd_2
  , info_disp_to_admin
  , anesthesiologist_license_no
  , signin_date
  , patient_shared
  , fn_staff_cd
) 
SELECT
  ''@facilityCd''
  , TO_NUMBER(COALESCE(NULLIF(''@userType'', ''''), ''0''), ''FM9'')
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 1), ''''), '' ''))
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 2), ''''), '' ''))
  , CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 1)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 1)) 
    END
  , CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 2)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 2)) 
    END
  , personal_info_encrypt(NULLIF(''@userLastNameAlpha'', ''''))
  , personal_info_encrypt(NULLIF(''@userFirstNameAlpha'', ''''))
  , personal_info_encrypt(NULLIF(''@userEmailAddress1'', ''''))
  , personal_info_encrypt(NULLIF(''@userEmailAddress2'', ''''))
  , personal_info_encrypt(NULLIF(''@extensionNo'', ''''))
  , personal_info_encrypt(NULLIF(''@homeNo'', ''''))
  , personal_info_encrypt(NULLIF(''@mobilePhoneNo'', ''''))
  , personal_info_encrypt(NULLIF(''@faxNo'', ''''))
  , personal_info_encrypt(NULLIF(''@zipcd3'', ''''))
  , personal_info_encrypt(NULLIF(''@zipcd4'', ''''))
  , personal_info_encrypt(NULLIF(''@address'', ''''))
  , personal_info_encrypt(NULLIF(''@addressKana'', ''''))
  , personal_info_encrypt(NULLIF(''@fnwJobCd'', ''''))
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , TO_NUMBER( COALESCE(NULLIF(''@administrator'', ''''), ''0''), ''FM9'') 
  , ''1''
  , ''0''
  , NULLIF(''@inHospitalCd1'', '''')
  , NULLIF(''@inHospitalCd2'', '''')
  , ''0''
  , personal_info_encrypt(NULLIF(''@anesthesiologistLicenseNo'', ''''))
  , NULL
  , CASE ''@patientShared'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@patientShared'', ''FM9999999999'') 
    END
  , NULLIF(''@fnStaffCd'', '''')
WHERE 
    CURRENT_DATE BETWEEN TO_DATE(''@startDateAfter'', ''YYYYMMDD'') 
    AND TO_DATE(''@endDateAfter'', ''YYYYMMDD'')', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_personal_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, '[{"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9403, 'UPDATE mst_personal_user 
SET
   user_last_name = personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 1), ''''), '' ''))
   , user_first_name = personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 2), ''''), '' ''))
   , user_last_name_kana = CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 1)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 1)) 
    END
   , user_first_name_kana = CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 2)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 2)) 
    END
  , job_cd = CASE 
    WHEN ''@fnwUpdateFlg'' = ''1'' THEN personal_info_encrypt(NULLIF(''@jobCd'', '''')) 
    ELSE job_cd
    END
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND user_id = @userId 
  AND facility_cd = ''@facilityCd'' ', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_personal_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, '[{"sql_cd": -600201, "field_name": "update_flg", "replace_var": "@fnwUpdateFlg"}, {"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9404, '  WITH staff_job_cd AS (
      SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''key0'' = ''HR''
        AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
        AND info ->> ''key2'' = ''DEFAULT_STAFF_JOB_CD''
  )
   , mst_jobs as (
  SELECT
  mst_job.in_hospital_cd_1 job_cd,
  ROW_NUMBER() OVER (ORDER BY 1) AS priority
  FROM
  	mst_job 	
  WHERE 
  	mst_job.in_hospital_cd_1 = @jobCd
  	AND mst_job.facility_cd = @facilityCd
  UNION ALL
  SELECT
  	value job_cd,
  	ROW_NUMBER() OVER (ORDER BY 2) AS priority
  FROM
  	staff_job_cd
  LIMIT 1
  )
 SELECT
  1 AS order_no
  , A.up_date
  , CAST(A.job_cd AS TEXT) AS job_cd
  , A.job_name
  , A.is_doctor
  , A.in_hospital_cd_1 
FROM
  mst_job A
  , ( 
    SELECT
      mss.facility_cd
      , ms.*
      , ROW_NUMBER() OVER () AS INDEX 
      , CAST(mst_jobs.job_cd AS TEXT) AS select_job_cd
    FROM
      mst_selector mss 
      CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      CROSS JOIN mst_jobs AS mst_jobs
    WHERE
      facility_cd = @facilityCd 
      AND master_physical_name = ''mst_job''
  ) ms 
WHERE
  A.facility_cd = ms.facility_cd 
  AND A.is_del = ''0'' 
  AND A.is_disp = ''1'' 
  AND A.in_hospital_cd_1 = select_job_cd
UNION 
SELECT
  2 AS order_no
  , CURRENT_TIMESTAMP AS up_date
  , '''' AS job_cd
  , ''不明'' AS job_name
  , ''0'' AS is_doctor
  , '''' AS in_hospital_cd_1 
ORDER BY
  order_no ASC, up_date DESC LIMIT 1	', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携(連携の職種コードより、FNWの職種コードを取得)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9405, 'SELECT
  user_id
  , facility_cd
  , disp_user_id
  , user_password
  , failure_cnt
  , reg_date
  , up_date
  , user_password_history 
FROM
  mst_user_authentication 
WHERE

  user_id = @userId', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者取得(mst_user_authentication)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9406, 'WITH validated_user_id AS (
 select 
case 
	when 
	    CURRENT_DATE BETWEEN TO_DATE(''@startDateAfter'', ''YYYYMMDD'')
    AND TO_DATE(''@endDateAfter'', ''YYYYMMDD'') then ''@userId ''
    else ''0''
end AS converted_user_id
)
INSERT INTO mst_user_authentication(
  user_id
  , facility_cd
  , disp_user_id
  , user_password
  , failure_cnt
  , reg_date
  , up_date
  , user_password_history
)
SELECT
  (select converted_user_id from validated_user_id) :: bigint
  , ''@facilityCd''
  , NULLIF(''@dispUserId'', '''')
  , COALESCE(NULLIF(''@%%passwordencoder%%_userPassword'', ''''), COALESCE(NULLIF(''@%%passwordencoder%%_dispUserId'', ''''), ''@%%passwordencoder%%_defaultPassword''))
  , 0
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
WHERE
    CURRENT_DATE BETWEEN TO_DATE(''@startDateAfter'', ''YYYYMMDD'')
    AND TO_DATE(''@endDateAfter'', ''YYYYMMDD'')', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_user_authentication)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9407, 'UPDATE mst_user_authentication 
SET
  disp_user_id = NULLIF(''@dispUserId'', '''')
  , user_password = COALESCE(NULLIF(''@%%passwordencoder%%_userPassword'', ''''), COALESCE(NULLIF(''@%%passwordencoder%%_dispUserId'', ''''), ''@%%passwordencoder%%_defaultPassword''))
  , up_date = CURRENT_TIMESTAMP 
WHERE
  user_id = @userId 
  AND facility_cd = ''@facilityCd''
', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_user_authentication)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9408, 'SELECT
  user_id
  , user_settings
  , is_provisional
  , reg_date
  , up_date
  , is_disp
  , is_del
  , pat_id
  , tmp_log_search_condition
  , secret_key
  , is_set_qr_code
  , is_consent
  , consent_date
  , reg_password_date
  , facility_cd 
FROM
  mst_user 
WHERE
  user_id = @userId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者取得(mst_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9409, 'WITH staff_job_cd AS (
      SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = ''@facilityCd'' 
        AND is_del = ''0''
        AND info ->> ''key0'' = ''HR''
        AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
        AND info ->> ''key2'' = ''DEFAULT_STAFF_JOB_CD''
 )
 , mst_jobs as (
  SELECT
  mst_job.in_hospital_cd_1 job_cd,
  ROW_NUMBER() OVER (ORDER BY 1) AS priority
  FROM
  	mst_job 	
  WHERE 
  	mst_job.in_hospital_cd_1 = ''@jobCd''
  	AND mst_job.facility_cd = ''@facilityCd'' 
  UNION 
  SELECT
  	value job_cd,
  	ROW_NUMBER() OVER (ORDER BY 2) AS priority
  FROM
  	staff_job_cd
  ORDER BY priority ASC
  LIMIT 1
  )
, job_settings AS ( 
  SELECT
    1 AS order_no
    , A.job_cd
    , A.up_date
    , A.default_menu_settings ->> ''initial_menu_function'' AS initial_menu_function
    , A.default_menu_settings ->> ''default_menu_functions'' AS default_menu_functions
    , array_to_json(STRING_TO_ARRAY(A.default_authorized_authorities, '','')) ::TEXT AS default_authorized_authorities 
  FROM
    mst_job A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
        , CAST(mst_jobs.job_cd AS TEXT) AS select_job_cd
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
        CROSS JOIN mst_jobs AS mst_jobs
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_job''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.job_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND A.in_hospital_cd_1 = select_job_cd
  UNION 
  SELECT
    2 AS order_no
    , - 1 AS job_cd
    , CURRENT_TIMESTAMP AS up_date
    , NULL AS initial_menu_function
    , NULL AS default_menu_functions
    , NULL AS default_authorized_authorities 
  ORDER BY order_no ASC , up_date DESC  LIMIT 1
) 
, job_user_settings AS ( 
  SELECT
    job_cd
    , ''{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ''
		  || job.default_menu_functions
      || '', "is_split_frame": 1, "default_setting": {}, "ind_rst_pattern": null, "initial_function": "''
			|| job.initial_menu_function
      || ''", "personal_settings": [], "authorized_functions": ''
			|| job.default_menu_functions
      || '', "authorized_authorities": ''
			|| job.default_authorized_authorities
      || ''}'' AS user_settings 
  FROM
    job_settings AS job
) 
, validated_user_id AS (
 select 
case 
	when 
	    CURRENT_DATE BETWEEN TO_DATE(''@startDateAfter'', ''YYYYMMDD'')
    AND TO_DATE(''@endDateAfter'', ''YYYYMMDD'') then ''@userId ''
    else ''0''
end AS converted_user_id
)
INSERT INTO mst_user( 
  user_id
  , user_settings
  , is_provisional
  , reg_date
  , up_date
  , is_disp
  , is_del
  , pat_id
  , tmp_log_search_condition
  , secret_key
  , is_set_qr_code
  , is_consent
  , consent_date
  , reg_password_date
  , facility_cd
) 
SELECT
  (select converted_user_id from validated_user_id) :: bigint
  , CASE WHEN (SELECT job_cd FROM job_user_settings) = -1 THEN
      ''@userSettingsValue''
    ELSE
      (SELECT user_settings FROM job_user_settings) :: JSONB
    END
  , CASE ''@isProvisional'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@isProvisional'', ''FM9'') 
    END
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''1''
  , ''0''
  , CASE ''@patId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@patId'', ''FM9999999999999999999'') 
    END
  , NULL
  , NULLIF(''@secretKey'', '''')
  , CASE ''@isSetQrCode'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER( ''@isSetQrCode'', ''FM9'') 
    END
  , CASE ''@isConsent'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER( ''@isConsent'', ''FM9'') 
    END
  , NULL
  , NULL
  , ''@facilityCd''
WHERE 
    CURRENT_DATE BETWEEN TO_DATE(''@startDateAfter'', ''YYYYMMDD'') 
    AND TO_DATE(''@endDateAfter'', ''YYYYMMDD'')', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9410, 'WITH job_settings AS ( 
  SELECT
    1 AS order_no
    , A.job_cd
    , A.up_date
    , A.default_menu_settings ->> ''initial_menu_function'' AS initial_menu_function
    , A.default_menu_settings ->> ''default_menu_functions'' AS default_menu_functions
    , array_to_json(STRING_TO_ARRAY(A.default_authorized_authorities, '','')) ::TEXT AS default_authorized_authorities 
  FROM
    mst_job A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_job''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.job_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND A.in_hospital_cd_1 = ''@jobCd'' 
  UNION 
  SELECT
    2 AS order_no
    , - 1 AS job_cd
    , CURRENT_TIMESTAMP AS up_date
    , NULL AS initial_menu_function
    , NULL AS default_menu_functions
    , NULL AS default_authorized_authorities 
  ORDER BY order_no ASC , up_date DESC  LIMIT 1
) 
, job_user_settings AS ( 
  SELECT
    job_cd
    , ''{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ''
		  || job.default_menu_functions
      || '', "is_split_frame": 1, "default_setting": {}, "ind_rst_pattern": null, "initial_function": "''
			|| job.initial_menu_function
      || ''", "personal_settings": [], "authorized_functions": ''
			|| job.default_menu_functions
      || '', "authorized_authorities": ''
			|| job.default_authorized_authorities
      || ''}'' AS user_settings 
  FROM
    job_settings AS job
) 
UPDATE mst_user
SET 
  user_settings = CASE WHEN (SELECT job_cd FROM job_user_settings) = -1 THEN
      ''@userSettingsValue''
    ELSE
      (SELECT user_settings FROM job_user_settings) :: JSONB
    END
  , up_date = CURRENT_TIMESTAMP
WHERE
  user_id = @userId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600202, 'WITH sch_start_time AS (
       SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
       FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
       WHERE facility_cd = @facilityCd
              AND is_del = ''0''
              AND COALESCE(info ->> ''key0'', '''') = @key0
              AND info ->> ''key1'' = ''COOP_CONFIG''
              AND info ->> ''key2'' = ''SCH_START_TIME''
),
orderreqsend_bed_period_extend AS (
       SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
       FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
       WHERE facility_cd = @facilityCd
              AND is_del = ''0''
              AND COALESCE(info ->> ''key0'', '''') = @key0
              AND info ->> ''key1'' = ''NEC''
              AND info ->> ''key2'' = ''ORDERREQSEND_BED_PERIOD_EXTEND''
),
nec_bed_period_conv AS (
       SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
       , info ->> ''key2'' AS key2
       FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
       WHERE facility_cd = @facilityCd
              AND is_del = ''0''
              AND COALESCE(info ->> ''key0'', '''') = @key0
              AND info ->> ''key1'' = ''NEC_BED_PERIOD_CONV''
),
treatment_coop_cd_no AS (
    SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''TREATMENT_COOP_CD_NO''
)
SELECT ord.treat_date                                               AS dialysis_date,
       ord.facility_cd                                              AS facility_cd,
       COALESCE(concat(ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '',
                       ord.ind_schedule_user_info ->> ''ind_user_first_name''),
                '''')                                                 AS ind_name,
       COALESCE(LEFT(concat(ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '',
                            ord.ind_schedule_user_info ->> ''ind_user_first_name''), 5),
                '''')                                                 AS ind_name10,
       COALESCE(ord.ind_schedule_user_info ->> ''ind_user_id'', '''')   AS staff_cd_comm,
       COALESCE(ord.ind_treat_start_time, '''')                       AS start_time,
       COALESCE(mkr.in_hospital_cd_1, '''')                           AS kur_cd1,
       COALESCE(mkr.kur_name, '''')                                   AS kur_name,
       COALESCE(mbd.bed_cd, 0)                                      AS bed_cd,
       COALESCE(mbd.in_hospital_cd_1, '''')                           AS bed_cd1,
       COALESCE(mbd.bed_name, '''')                                   AS bed_name,
       CASE (SELECT value FROM orderreqsend_bed_period_extend)
       WHEN ''0'' THEN
              CASE mkr.kur_name
              WHEN ''午前'' THEN ''1''
              WHEN ''午後'' THEN ''2''
              WHEN ''夜間'' THEN ''3''
              ELSE '' ''
              END
       WHEN ''1'' THEN COALESCE(NULLIF((SELECT value FROM nec_bed_period_conv WHERE key2 = mkr.in_hospital_cd_1), ''''), '''')
       END AS bed_reservation_time,
       COALESCE(CASE
                    WHEN mtt.in_hospital_cd_a1 = '''' or mtt.in_hospital_cd_a1 is NULL THEN ''不明''
                    ELSE mtt.treatment_name END,
                '''')                                                 AS treatment_name,
       COALESCE(CASE
                    WHEN mtt.in_hospital_cd_a1 = '''' or mtt.in_hospital_cd_a1 is NULL THEN ''-''
                    ELSE mtt.in_hospital_cd_a1 END,
                '''')                                                 AS treatment_cd,
       TO_CHAR(COALESCE(ord.ind_dw, 0), ''FM000V9'')                  AS dw,
       ord.ind_cond_info -> ''1'' ->> ''value''                         AS dialysis_time_m,
       case
           when RIGHT((COALESCE(
                               RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                     2) ||
                               RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
                               ''0''
                       )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER)::TEXT, 2)::INTEGER >= 60
               then ((COALESCE(
                              RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                    2) ||
                              RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
                              ''0''
                      )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER) + 100 - 60) ::TEXT
           else
               CASE
                   WHEN
                       COALESCE(
                               RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                     2) ||
                               RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
                               ''0''
                       )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER >= 2400
                       THEN
                       LPAD((COALESCE(
                                     RIGHT(''00'' ||
                                           TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                           2) ||
                                     RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60),
                                           2),
                                     ''0''
                             )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER - 2400) ::TEXT, 4, ''0'')
                   ELSE
                       (COALESCE(
                                RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0),
                                      2) ||
                                RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
                                ''0''
                        )::INTEGER + COALESCE(ord.ind_treat_start_time, ''0'')::INTEGER) ::TEXT
                   END
           END                                                      as end_time,
       COALESCE(
               RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0), 2) || '':'' ||
               RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
               ''0''
       )                                                            AS treatment_time,
       COALESCE(
               RIGHT(''00'' || TRUNC(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'') / 60, 0), 2) ||
               RIGHT(''00'' || MOD(TO_NUMBER(ord.ind_cond_info -> ''1'' ->> ''value'', ''999999''), 60), 2),
               ''''
       )                                                            AS treatment_time4,
       COALESCE(ord.rst_cond_info -> ''1'' ->> ''value'', '''')           AS treatment_time_m,--追加
       CASE (SELECT value FROM sch_start_time)
       WHEN ''0'' THEN substring(mkr.kur_standard_start_time, 1, 4)
       WHEN ''1'' THEN ord.ind_treat_start_time
       END                                                          AS treatment_start_time,
       COALESCE(ord.ind_cond_info -> ''2'' ->> ''value_name_1'', '''')    AS va,
       COALESCE(SUBSTRING(ord.ind_cond_info -> ''2'' ->> ''value_name_1'', 1, 3),
                '''')                                                 AS va3,
       COALESCE(mva.in_hospital_cd_1, '''')                           AS va_cd1,
       COALESCE(
               (CASE mva.va_direct
                    WHEN ''0'' THEN ''右''
                    WHEN ''1'' THEN ''左''
                    WHEN ''2'' THEN ''両方''
                    WHEN ''3'' THEN ''無''
                    ELSE ''不明'' END),
               ''''
       )                                                            AS va_direct,
       COALESCE(ord.ind_cond_info -> ''3'' ->> ''value'', '''')           AS target_weight,
       COALESCE(ord.ind_cond_info -> ''4'' ->> ''value'', '''')           AS water_removal_amount_limit,
--ord.ind_cond_info->''5''->>''value_name_1'' as dialyzer,
       COALESCE(mdr.model_number, '''')                               AS dialyzer,
--ord.ind_cond_info->''5''->>''value'' as dialyzer_cd,
       COALESCE(mdr.in_hospital_cd_1, '''')                           AS dialyzer_cd1,
       COALESCE(ord.ind_cond_info -> ''6'' ->> ''value_name_1'', '''')    AS adsorption_column,
       COALESCE(meqad.in_hospital_cd_1, '''')                         AS ad_cd1,
       COALESCE(ord.ind_cond_info -> ''7'' ->> ''value_name_1'', '''')    AS primary_film,
       COALESCE(meqpr.in_hospital_cd_1, '''')                         AS pr_cd1,
       COALESCE(ord.ind_cond_info -> ''8'' ->> ''value_name_1'', '''')    AS secondary_film,
       COALESCE(meqse.in_hospital_cd_1, '''')                         AS se_cd1,
--ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
       COALESCE(meqa.equipment_name, '''')                            AS puncture_needle_a,
       COALESCE(meqa.in_hospital_cd_1, '''')                          AS a_cd1,
--ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
       COALESCE(meqv.equipment_name, '''')                            AS puncture_needle_v,
       COALESCE(meqv.in_hospital_cd_1, '''')                          AS v_cd1,
--ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
       COALESCE(meqsn.equipment_name, '''')                           AS puncture_needle_sn,
       COALESCE(meqsn.in_hospital_cd_1, '''')                         AS sn_cd1,
       COALESCE((CASE ord.ind_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END),
                '''')                                                 AS single_needle,
       COALESCE(ord.ind_cond_info -> ''13'' ->> ''value'', '''')          AS blood_circuit,
       COALESCE(meqbc.in_hospital_cd_1, '''')                         AS bc_cd1,
       COALESCE(ord.ind_cond_info -> ''14'' ->> ''value'', '''')          AS blood_flow,
--ord.ind_cond_info->''15''->>''value_name_1'' as dialysate,
       COALESCE(med15.medicine_name, '''')                            AS dialysate,
       COALESCE(med15.in_hospital_cd_1, '''')                         AS dialysate_cd1,
       COALESCE(ord.ind_cond_info -> ''16'' ->> ''value'', '''')          AS dialysate_flow_rate,
       COALESCE(ord.ind_cond_info -> ''17'' ->> ''value'', '''')          AS dialysate_amount,
--ord.ind_cond_info->''17''->>''unit'' as dialysate_amount_unit,
       COALESCE(med15.unit_second, '''')                              AS dialysate_amount_unit,
       COALESCE(ord.ind_cond_info -> ''18'' ->> ''value'', '''')          AS dialysate_temperature,
--ord.ind_cond_info->''19''->>''value_name_1'' as fluid_replacement,
       COALESCE(med25.medicine_name, '''')                            AS fluid_replacement,
       COALESCE(med25.in_hospital_cd_1, '''')                         AS ds_cd1,
       COALESCE(ord.ind_cond_info -> ''20'' ->> ''value'', '''')          AS fluid_replacement_amount,
       COALESCE(
               (CASE ord.ind_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END),
               '''')                                                  AS fluid_replacement_timing,
       COALESCE(ord.ind_cond_info -> ''22'' ->> ''value'', '''')          AS fluid_replacement_use_count,
       COALESCE(ord.ind_cond_info -> ''22'' ->> ''unit'', '''')           AS fluid_replacement_use_count_unit,
       COALESCE(ord.ind_cond_info -> ''23'' ->> ''value'', '''')          AS fluid_replacement_temperature,
       COALESCE(ord.ind_cond_info -> ''24'' ->> ''value'', '''')          AS fluid_replacement_speed,
--ord.ind_cond_info->''25''->>''value_name_1'' as anti_coagulant,
       COALESCE(med25.medicine_name, '''')                            AS anti_coagulant,
       COALESCE(med25.in_hospital_cd_1, '''')                         AS anti_coagulant_cd1,
       COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', '''')          AS anti_coagulant_one_shot_amount,
--ord.ind_cond_info->''26''->>''unit'' as anti_coagulant_one_shot_amount_unit,
       COALESCE(med25.unit, '''')                                     AS anti_coagulant_one_shot_amount_unit,
       COALESCE(ord.ind_cond_info -> ''27'' ->> ''value'', '''')          AS anti_coagulant_sustained_speed,
       COALESCE(ord.ind_cond_info -> ''27'' ->> ''unit'', '''')           AS anti_coagulant_sustained_speed_unit,
       COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', '''')          AS anti_coagulant_sustained_amount,
       COALESCE(ord.ind_cond_info -> ''28'' ->> ''unit'', '''')           AS anti_coagulant_sustained_amount_unit,
       COALESCE(
               TO_NUMBER(ord.ind_cond_info -> ''26'' ->> ''value'', ''999999999999'') +
               TO_NUMBER(ord.ind_cond_info -> ''28'' ->> ''value'', ''999999999999''),
               0
       )                                                            AS anti_coagulant_total_amount,--抗凝固剤総量
       COALESCE((CASE ord.ind_cond_info -> ''29'' ->> ''value''
                     WHEN ''1'' THEN ''使用する''
                     WHEN ''0'' THEN ''使用しない''
                     ELSE NULL END),
                '''')                                                 AS ip,
       COALESCE((CASE ord.ind_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END),
                '''')                                                 AS ip_start,
       COALESCE(ord.ind_cond_info -> ''31'' ->> ''value'', '''')          AS ip_one_short_amount,
       COALESCE(ord.ind_cond_info -> ''32'' ->> ''value'', '''')          AS ip_speed,
       COALESCE(ord.ind_cond_info -> ''33'' ->> ''value'', '''')          AS ip_speed_max,
       COALESCE((CASE ord.ind_cond_info -> ''34'' ->> ''value''
                     WHEN ''1'' THEN ''使用する''
                     WHEN ''0'' THEN ''使用しない''
                     ELSE NULL END),
                '''')                                                 AS auto_one_shot,
       COALESCE((CASE ord.ind_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END),
                '''')                                                 AS ip_auto_off,
       COALESCE(ord.ind_cond_info -> ''36'' ->> ''value'', '''')          AS ip_auto_off_time,
       COALESCE((CASE ord.ind_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END),
                '''')                                                 AS ip_monitor_auto_off,
       COALESCE(ord.ind_cond_info -> ''38'' ->> ''value'', '''')          AS ip_monitor_auto_off_time,
       COALESCE(pm.medical_care_info ->> ''dialysis_start_date'', '''') AS dialysis_start_date,
       COALESCE(to_char(ord.up_date, ''YYYYMMDD''), '''')               AS update_ymd,
       COALESCE(to_char(ord.up_date, ''HH24MISS''), '''')               AS update_hms,
       COALESCE(
            CASE (SELECT value FROM treatment_coop_cd_no)
            WHEN ''1''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a1
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b1
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a1
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b1
                ELSE NULL
                END
            WHEN ''2''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a2
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b2
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a2
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b2
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a3
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b3
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a3
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b3
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a4
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b4
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a4
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b4
                ELSE NULL
                END
            END
        , '''') AS treatment_cd_coop
FROM pat_main AS pm,
     ord_main AS ord
         LEFT OUTER JOIN mst_equipment AS meqa
                         ON meqa.equipment_cd = cast(ord.ind_cond_info -> ''9'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqv
                         ON meqv.equipment_cd = cast(ord.ind_cond_info -> ''10'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqsn
                         ON meqsn.equipment_cd = cast(ord.ind_cond_info -> ''11'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqad
                         ON meqad.equipment_cd = cast(ord.ind_cond_info -> ''6'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqpr
                         ON meqpr.equipment_cd = cast(ord.ind_cond_info -> ''7'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqbc
                         ON meqbc.equipment_cd = cast(ord.ind_cond_info -> ''13'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_equipment AS meqse
                         ON meqse.equipment_cd = cast(ord.ind_cond_info -> ''8'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_medicine AS med15
                         ON med15.medicine_cd = cast(ord.ind_cond_info -> ''15'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_medicine AS med19
                         ON med19.medicine_cd = cast(ord.ind_cond_info -> ''19'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_medicine AS med25
                         ON med25.medicine_cd = cast(ord.ind_cond_info -> ''25'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
         LEFT OUTER JOIN mst_dialyzer AS mdr
                         ON mdr.dialyzer_cd = cast(ord.ind_cond_info -> ''5'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = cast(ord.ind_cond_info -> ''2'' ->> ''value'' as int)
         LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
         LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd
WHERE ord.ord_no = @ordNo
  and pm.pat_id = ord.pat_id', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)指示) 透析条件', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);