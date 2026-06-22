DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1100000, -1100001, -1100002, -1100003, -1100004, -1100005, -1100006, -1100007, -1100008);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100000, 'WITH names AS (
  SELECT
    -- 漢字氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@kanjiName'',''''), ''[ 　]+'') AS name_arr,
    -- カナ氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@kanaName'',''''), ''[ 　]+'') AS kana_arr,
    -- その他連絡先漢字氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@otherKanjiName'',''''), ''[ 　]+'') AS oname_arr
)
INSERT INTO ntss.pat_personal_main (
    fn_pat_id,             -- FNW+で管理する施設内の一意な患者ID
    hosp_pat_id,           -- 院内表示用の患者ID
    nkk_pat_id,            -- 日機装内で管理する一意な患者ID
    facility_cd,           -- 登録施設コード

    pat_last_name,         -- 患者氏名(漢字姓)
    pat_first_name,        -- 患者氏名(漢字名)
    pat_last_name_kana,    -- 患者氏名(カタカナ姓)
    pat_first_name_kana,   -- 患者氏名(カタカナ名)

    pat_birthday,          -- 生年月日(YYYYMMDD)
    pat_sex,               -- 性別コード (M→0, F→1, その他→NULL)
    in_out_class,          -- 入外区分

    pat_contact_info,      -- 本人連絡先情報(jsonb)
    other_contact_info,    -- その他連絡先情報(jsonb), NULL可

    is_die,                -- 死亡患者フラグ(固定0)
    is_del,                -- 削除フラグ(固定0)
    reg_date,              -- 登録日時
    up_date                -- 更新日時
)
SELECT
    -- FNW+で管理する施設内の一意な患者ID
    NULLIF(''@fnPatId'','''')                           AS fn_pat_id,
    -- 院内表示用の患者ID
    lpad(NULLIF(''@hospPatId'',''''), 8, ''0'')                         AS hosp_pat_id,
    -- 日機装内で管理する一意な患者ID
    NULLIF(''@nkkPatId'','''')                          AS nkk_pat_id,
    -- 登録施設コード
    NULLIF(''@facilityCd'','''')                        AS facility_cd,

    -- 漢字氏名：姓を暗号化
    personal_info_encrypt(name_arr[1])              AS pat_last_name,
    -- 漢字氏名：名を暗号化（存在しない場合は空文字）
    COALESCE(personal_info_encrypt(name_arr[2]),'''') AS pat_first_name,
    -- カナ氏名：姓を暗号化
    personal_info_encrypt(kana_arr[1])               AS pat_last_name_kana,
    -- カナ氏名：名を暗号化（存在しない場合は空文字）
    COALESCE(personal_info_encrypt(kana_arr[2]),'''')  AS pat_first_name_kana,

    -- 生年月日(YYYYMMDD)スラッシュ除去後そのまま
    NULLIF(REPLACE(''@birthday'',''/'',''''),'''')          AS pat_birthday,
    -- 性別コード：M→0, F→1, その他→NULL
    CASE NULLIF(''@sex'','''')
      WHEN ''M'' THEN 0
      WHEN ''F'' THEN 1
      ELSE NULL
    END::smallint                                   AS pat_sex,
    -- 入外区分コード
    NULLIF(''@homeFlag'','''')::smallint                AS in_out_class,

    -- 本人連絡先情報をJSONB化
    json_build_object(
      ''zip_cd'',  NULLIF(''@zipCd'',''''),
      ''address'', NULLIF(''@address'',''''),
      ''tel1'',    NULLIF(''@tel1'','''')
    )::jsonb                                         AS pat_contact_info,

    -- その他連絡先情報：@otherKanjiName が NULL/空 の場合は登録せず NULL、
    -- 登録する場合は last_name/first_name に分割値を暗号化、
    -- 仮の relation_cd=0（続柄「その他」）を含める
    CASE
      WHEN oname_arr IS NULL OR oname_arr[1] = '''' THEN NULL
      ELSE json_build_object(
        ''last_name'',   personal_info_encrypt(oname_arr[1]),
        ''first_name'',  COALESCE(personal_info_encrypt(oname_arr[2]),''''),
        ''zip_cd'',      NULLIF(''@otherZipCd'',''''),
        ''address'',     NULLIF(''@otherAddress'',''''),
        ''tel1'',        NULLIF(''@otherTel1'',''''),
        ''relation_cd'', 0,        -- 仮の値: 0
      )::jsonb
    END                                              AS other_contact_info,

    -- 死亡患者フラグは常に0
    ''0''                                              AS is_die,
    -- 削除フラグは常に0
    ''0''                                              AS is_del,
    -- 登録日時を現在時刻で
    CURRENT_TIMESTAMP                                AS reg_date,
    -- 更新日時を現在時刻で
    CURRENT_TIMESTAMP                                AS up_date

FROM names

-- 生年月日が "-" の場合は取込み対象外
WHERE NULLIF(''@birthday'','''') <> ''-'';
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル(profile)(CSV):患者個人情報の取得の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100001, 'select pat_id
from
  pat_personal_main
where
  is_del = ''0''
and
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者個人情報の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100002, 'SELECT pu.pat_id,
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
  AND is_del = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル_固有情報取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100001, "field_name": "pat_id", "replace_var": "@pat_id"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100003, 'INSERT 
INTO pat_unique( 
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique
) 
VALUES ( 
  @patId
  , ''[]''
  , ''[]''
  , ''[]''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''@facilityCd''
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル_固有情報登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100006, 'WITH take_cource_info AS ( 
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
    AND ini.facility_cd = ''@facilityCd''
      AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''  
    AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML'' 
    AND TRIM(ini_info ->> ''key2'') = ''HOSPITALIZATION_DEPT_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
        ''@medicalCareInfo.mainCourseCd2'' :: TEXT AS dialysis_course_cd
    ,(CASE WHEN ((SELECT take_cource_flg FROM take_cource_info) = ''0'')
                THEN ''@medicalCareInfo.mainCourseCd2''
                    ELSE (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClassOut'') = ''1'' -- ''1''：入院
                     THEN ''@medicalCareInfo.mainCourseCd''
                     ELSE ''''
                END)
            END) :: TEXT AS main_course_cd
    , (CASE WHEN (''@inOutClassOut'') = ''1'' -- ''1''：入院
      THEN ''@medicalCareInfo.wardCd''
      ELSE '''' END) :: TEXT AS ward_cd
  FROM 
    pat_main
  WHERE 
    is_del = ''0'' 
    AND pat_id = @patId
)
UPDATE pat_main 
SET
  up_date = CURRENT_TIMESTAMP
  , medical_care_info = json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF((SELECT dialysis_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_count''
      , medical_care_info->''dialysis_count''
      , ''purification_count''
      , medical_care_info->''purification_count''
      , ''other_dialysis_count''
      , medical_care_info->''other_dialysis_count''
      , ''pat_dialysis_count''
      , medical_care_info->''pat_dialysis_count''
      , ''facility_cd''
      , medical_care_info->>''facility_cd''
      , ''dialysis_start_date''
      , medical_care_info->>''dialysis_start_date''
      , ''hospital_start_date''
      , medical_care_info->>''hospital_start_date''
    )
WHERE
  is_del = ''0'' 
  AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコムの患者プロファイル_患者基本情報の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100007, '-- @birthday が ''-'' または 8桁数字 (YYYYMMDD) でない場合は 0 行、
-- フォーマット通りの場合は 1 行返す
SELECT
  1 AS birthday_valid
WHERE
  -- ''-'' は除外
  ''@birthday'' <> ''-''  
  -- 8桁の数字にマッチする文字列のみ通過
  AND ''@birthday'' ~ ''^[0-9]{8}$'';
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者属性生年月日判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100008, '-- key0/key1/key2 で絞り込み、
-- value が @homeFlag と一致する要素があれば 1 行、なければ 0 行を返す
SELECT
  1 AS match_exists
FROM ntss.mst_coop_ini AS m
  CROSS JOIN LATERAL jsonb_array_elements(m.coop_ini_info) AS x(elem)
WHERE
    m.is_del     = ''0''                  -- 削除されていない
  AND m.facility_cd = @facilityCd       -- 施設コード
  AND x.elem->>''key0'' = @key0           -- key0 で絞り込み
  AND x.elem->>''key1'' = @key1           -- key1 で絞り込み
  AND x.elem->>''key2'' = @key2           -- key2 で絞り込み
  AND x.elem->>''value'' = @homeFlag      -- value が @homeFlag と一致
LIMIT 1;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者属性在宅フラグ判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100005, 'WITH take_cource_info AS ( 
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
    AND ini.facility_cd = ''@facilityCd''
      AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML'' 
    AND TRIM(ini_info ->> ''key2'') = ''HOSPITALIZATION_DEPT_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
        (''@medicalCareInfo.mainCourseCd2'' :: TEXT) AS dialysis_course_cd
    ,(CASE WHEN ((SELECT take_cource_flg FROM take_cource_info) = ''0'')
                THEN (''@medicalCareInfo.mainCourseCd2'' :: TEXT)
                    ELSE (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClassOut'') = ''1'' -- ''1''：入院
                     THEN (''@medicalCareInfo.mainCourseCd'' :: TEXT) 
                                            ELSE ('''' :: TEXT)
                END)
            END) AS main_course_cd
    , CASE WHEN (''@inOutClassOut'') = ''1'' -- ''1''：入院
      THEN (''@medicalCareInfo.wardCd'' :: TEXT) 
      ELSE ('''' :: TEXT) END AS ward_cd
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
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF((SELECT dialysis_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
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
      , NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
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
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコムの患者プロファイル_患者基本情報の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}, {"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100004, 'WITH names AS (
  SELECT
    -- 漢字氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@kanjiName'',''''), ''[ 　]+'') AS name_arr,
    -- カナ氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@kanaName'',''''), ''[ 　]+'') AS kana_arr,
    -- その他連絡先漢字氏名を全角・半角スペースで分割
    regexp_split_to_array(NULLIF(''@otherKanjiName'',''''), ''[ 　]+'') AS oname_arr
)
UPDATE ntss.pat_personal_main AS t
SET
    -- 漢字氏名：姓を暗号化して更新
    pat_last_name       = personal_info_encrypt(name_arr[1]),
    -- 漢字氏名：名を暗号化（存在しない場合は空文字）して更新
    pat_first_name      = COALESCE(personal_info_encrypt(name_arr[2]),''''),

    -- カナ氏名：姓を暗号化して更新
    pat_last_name_kana  = personal_info_encrypt(kana_arr[1]),
    -- カナ氏名：名を暗号化（存在しない場合は空文字）して更新
    pat_first_name_kana = COALESCE(personal_info_encrypt(kana_arr[2]),''''),

    -- 生年月日(YYYYMMDD)：スラッシュを除去した文字列で更新
    pat_birthday        = NULLIF(REPLACE(''@birthday'',''/'',''''),''''),

    -- 性別コード：M→0, F→1, その他→NULL
    pat_sex             = CASE NULLIF(''@sex'','''')
                            WHEN ''M'' THEN 0
                            WHEN ''F'' THEN 1
                            ELSE NULL
                          END::smallint,

    -- 入外区分コードを更新
    in_out_class        = NULLIF(''@homeFlag'','''')::smallint,

    -- 本人連絡先情報：既存JSONをマージして更新
    pat_contact_info    = t.pat_contact_info ||
                          json_build_object(
                            ''zip_cd'',  NULLIF(''@zipCd'',''''),
                            ''address'', NULLIF(''@address'',''''),
                            ''tel1'',    NULLIF(''@tel1'','''')
                          )::jsonb,

    -- その他連絡先情報：
    --   @otherKanjiName が NULL/空 の場合は変更せず既存値を保持、
    --   登録する場合は新規オブジェクトを作成後、既存JSONをマージして更新。
    other_contact_info  = CASE
                            WHEN oname_arr IS NULL OR oname_arr[1] = '''' THEN
                              t.other_contact_info
                            ELSE
                              coalesce(t.other_contact_info, ''{}''::jsonb) ||
                              json_build_object(
                                ''last_name'',   personal_info_encrypt(oname_arr[1]),
                                ''first_name'',  COALESCE(personal_info_encrypt(oname_arr[2]),''''),
                                ''zip_cd'',      NULLIF(''@otherZipCd'',''''),
                                ''address'',     NULLIF(''@otherAddress'',''''),
                                ''tel1'',        NULLIF(''@otherTel1'',''''),
                              )::jsonb
                          END,


    -- 更新日時を現在時刻に
    up_date             = CURRENT_TIMESTAMP

FROM names
WHERE
    -- 対象レコードの絞り込み：院内患者ID＋施設コード＋削除フラグ未削除
      t.hosp_pat_id  = NULLIF(''@hospPatId'','''')
  AND t.facility_cd = NULLIF(''@facilityCd'','''')
  AND t.is_del      = ''0''
  -- 生年月日が "-" の場合は取込み対象外
  AND NULLIF(''@birthday'','''') <> ''-'';
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル(profile)(CSV):患者個人情報の取得の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);