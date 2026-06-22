DELETE FROM sys_data_set WHERE sql_cd IN (-1101000, -1101001, -1101002, -1101003, -1101004, -1101005, -1101006, -1101007, -1101008, -1101009, -1101501, -1101502, -1101503, -1101504, -1101505);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101000, 'WITH names AS (
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
    pat_blood_type_abo,    -- 血液型ABO
    pat_blood_type_rh,     -- 血液型RH
    pat_blood_type_serovar,-- 血液型亜型
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
    ''0''                                              AS pat_blood_type_abo,
    ''0''                                              AS pat_blood_type_rh,
    ''0''                                              AS pat_blood_type_serovar,
    -- 入外区分コード
    0                AS in_out_class,

    -- 本人連絡先情報をJSONB化
    json_build_object(
      ''zip_cd'',  NULLIF(''@zipCd'',''''),
      ''address'', NULLIF(''@address'',''''),
      ''tel1'',    NULLIF(''@tel1'','''')
    )::jsonb                                         AS pat_contact_info,

    -- その他連絡先情報：otherKanjiName が NULL/空 の場合は登録せず NULL、
    CASE
      WHEN oname_arr IS NULL OR oname_arr[1] = '''' THEN NULL
      ELSE json_build_array(
        json_build_object(
          ''last_name'',     oname_arr[1],
          ''first_name'',    COALESCE(oname_arr[2],''''),
          ''zip_cd'',        NULLIF(''@otherZipCd'',''''),
          ''address'',       NULLIF(''@otherAddress'',''''),
          ''tel1'',          NULLIF(''@otherTel1'',''''),
          ''relation_cd'',   NULL,
          ''relation_name'', ''その他''
        )
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
VALUES(-1101001, '-- NULL／空文字のときはレコードを返さず、
-- それ以外のときだけ 1 行返す
SELECT
  1 AS required_fields_flag
WHERE
  NULLIF(@hospPatId, '''') IS NOT NULL;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者属性　患者IDが空欄チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101002, '-- kanjiName が NULL／空文字ならレコードを返さず、
-- それ以外のときだけ 1 行返す
SELECT
  1 AS required_fields_flag
WHERE
  NULLIF(@kanjiName, '''') IS NOT NULL;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者属性　漢字氏名が空欄チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101003, 'INSERT 
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
VALUES(-1101004, 'WITH names AS (
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

    -- 本人連絡先情報：既存JSONをマージして更新
    pat_contact_info    = t.pat_contact_info ||
                          json_build_object(
                            ''zip_cd'',  NULLIF(''@zipCd'',''''),
                            ''address'', NULLIF(''@address'',''''),
                            ''tel1'',    NULLIF(''@tel1'','''')
                          )::jsonb,

    -- その他連絡先情報：
    --   otherKanjiName が NULL/空 の場合は変更せず既存値を保持、
    --   登録する場合は新規オブジェクトを作成後、既存JSONをマージして更新。
    other_contact_info = CASE
      -- 値がなければ何もしない
      WHEN oname_arr IS NULL OR oname_arr[1] = '''' THEN
        t.other_contact_info

      -- 復号化した既存配列に同一レコードがあれば何もしない
      WHEN EXISTS (
        SELECT 1
        FROM jsonb_array_elements(
               personal_info_decrypt_jsonb(coalesce(t.other_contact_info, ''[]''::jsonb))
             ) AS x(elem)
        WHERE x.elem ->> ''last_name''    = oname_arr[1]
          AND x.elem ->> ''first_name''   = COALESCE(oname_arr[2], '''')
          AND x.elem ->> ''zip_cd''       = NULLIF(''@otherZipCd'','''')
          AND x.elem ->> ''address''      = NULLIF(''@otherAddress'','''')
          AND x.elem ->> ''tel1''         = NULLIF(''@otherTel1'','''')
          -- JSON null のチェック
          AND x.elem -> ''relation_cd''   IS NOT DISTINCT FROM ''null''::jsonb
          AND x.elem ->> ''relation_name'' = ''その他''
      ) THEN
        t.other_contact_info

      -- それ以外は既存配列に新要素を追記
      ELSE
        coalesce(t.other_contact_info, ''[]''::jsonb)
        || jsonb_build_array(
             jsonb_build_object(
               ''last_name'',     oname_arr[1],
               ''first_name'',    COALESCE(oname_arr[2], ''''),
               ''zip_cd'',        NULLIF(''@otherZipCd'',''''),
               ''address'',       NULLIF(''@otherAddress'',''''),
               ''tel1'',          NULLIF(''@otherTel1'',''''),
               ''relation_cd'',   NULL,
               ''relation_name'', ''その他''
             )
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
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101005, '
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
  , ''{}''
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
VALUES(-1101006, 'UPDATE pat_main 
SET
  up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコムの患者プロファイル_患者基本情報の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101007, '-- birthday が NULL／空文字／''-'' でない ＆ 8桁数字 (YYYYMMDD) の場合のみ 1 行返す
SELECT
  1 AS birthday_valid
WHERE
  NULLIF(@birthday, '''') IS NOT NULL
  AND @birthday <> ''-''
  AND @birthday ~ ''^[0-9]{8}$'';
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者属性生年月日判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101008, '-- key0/key1/key2 で絞り込み、
-- value が homeFlag と一致する要素があれば 1 行、なければ 0 行を返す
SELECT
  1 AS match_exists
WHERE
  EXISTS (
    SELECT
      1
    FROM
      ntss.mst_coop_ini AS m
      CROSS JOIN LATERAL jsonb_array_elements(m.coop_ini_info) AS x(elem)
    WHERE
      m.is_del       = ''0''                      -- 削除されていない
      AND m.facility_cd = @facilityCd            -- 施設コード
      AND x.elem->>''key0'' = @key0                -- key0 で絞り込み
      AND x.elem->>''key1'' = ''SCM_PATINFORCV''         -- key1 で絞り込み
      AND x.elem->>''key2'' = ''TARGET_FLAGS''   -- key2 で絞り込み
      AND @homeFlag = ANY(string_to_array(x.elem->>''value'', '',''))  -- カンマ区切りを分解して比較
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者属性在宅フラグ判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101009, '-- zipCd、address、tel1 がいずれも NULL／空文字でなければ 1 行返す
SELECT
  1 AS contact_info_flag
WHERE
     NULLIF(@zipCd,   '''') IS NOT NULL
  OR NULLIF(@address, '''') IS NOT NULL
  OR NULLIF(@tel1,    '''') IS NOT NULL;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者属性 「電話番号」「郵便番号」「住所」チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101501, 'SELECT 1 WHERE @messageType = ''C1'';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　電文種別チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101502, 'UPDATE
    pat_personal_main
SET
    pat_blood_type_abo = @abo
  , pat_blood_type_rh = @rh
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0'' 
  ;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　身長有効範囲チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1101503, "field_name": "abo", "replace_var": "@abo"}, {"sql_cd": -1101503, "field_name": "rh", "replace_var": "@rh"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101503, 'WITH abo_ini_info AS (
SELECT
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND ini.is_disp = ''1''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''SCM_PATPROFILE_RCV''
        AND info ->> ''key2'' IN (''ABO_A'', ''ABO_B'', ''ABO_O'', ''ABO_AB'')
        AND split_part(@content, '':'', 1) = ANY (string_to_array(COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''), '',''))
),
rh_ini_info AS (
SELECT
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND ini.is_disp = ''1''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''SCM_PATPROFILE_RCV''
        AND info ->> ''key2'' IN (''RH_PLUS'', ''RH_MINUS'')
        AND split_part(@content, '':'', 1) = ANY (string_to_array(COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''), '',''))
)
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM abo_ini_info) <> 1 THEN 0
        ELSE CASE (SELECT key2 FROM abo_ini_info)
            WHEN ''ABO_A''  THEN 1
            WHEN ''ABO_B''  THEN 2
            WHEN ''ABO_O''  THEN 3
            WHEN ''ABO_AB'' THEN 4
            ELSE 0
        END
    END AS abo,
    CASE
        WHEN (SELECT COUNT(*) FROM rh_ini_info) <> 1 THEN 0
        ELSE CASE (SELECT key2 FROM rh_ini_info)
            WHEN ''RH_PLUS''   THEN 1
            WHEN ''RH_MINUS''  THEN 2
            ELSE 0
        END
    END AS rh
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　電文種別チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101504, 'WITH
  -- 配列要素を展開し、exam_dateとctl_noを取り出す
  physical_elems AS (
    SELECT
      pu.pat_id,
      pu.facility_cd,
      pu.is_del,
      elem,
      (elem->>''ctl_no'')::INT    AS ctl_no,
      (elem->>''exam_date'')::DATE AS exam_dt
    FROM
      pat_unique pu
      CROSS JOIN LATERAL
        jsonb_array_elements(
          COALESCE(pu.physical_info::jsonb, ''[]''::jsonb)
        ) AS elem
    WHERE
      pu.pat_id         = @patId
      AND pu.facility_cd = ''@facilityCd''
      AND pu.is_del      = ''0''
  ),
  -- 最新の要素を取得（exam_date DESC, ctl_no DESC）
  latest_elem AS (
    SELECT
      elem
    FROM
      physical_elems
    ORDER BY
      exam_dt DESC,
      ctl_no DESC
    LIMIT 1
  ),
  -- 新しいctl_noを決定
  max_ctl AS (
    SELECT
      COALESCE(MAX(ctl_no), 0) AS max_ctl
    FROM
      physical_elems
  ),
  -- 挿入する新要素を作成
  new_elem AS (
    SELECT
      jsonb_build_object(
        ''dw'',                   NULL,
        ''ctr'',                  NULL,
        ''memo'',                 NULL,
        ''ctl_no'',               max_ctl + 1,
        ''height'',               @content,
        ''chest_dia'',            NULL,
        ''exam_date'',            TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD''),
        ''breast_dia'',           NULL,
        ''ctr_weight'',           NULL,
        ''facility_cd'',          ''@facilityCd'',
        ''order_class'',          2,
        ''indicator_cd'',         NULL,
        ''inspect_date'',         NULL,
        ''target_weight'',        NULL,
        ''pre_scale_lower'',      NULL,
        ''pre_scale_upper'',      NULL,
        ''indicator_start_date'', NULL
      ) AS elem
    FROM
      max_ctl
  ),
  -- 新要素を配列化
  new_array AS (
    SELECT
      jsonb_build_array(elem) AS arr
    FROM
      new_elem
  )
UPDATE
  pat_unique pu
SET
  physical_info = (
    CASE
      WHEN pu.physical_info IS NULL
        OR jsonb_array_length(pu.physical_info::jsonb) = 0
      THEN
        na.arr
      ELSE
        pu.physical_info::jsonb || na.arr
    END
  )::json,
  up_date = CURRENT_TIMESTAMP
FROM
  new_array na
  CROSS JOIN latest_elem le  -- 最新要素を参照
WHERE
  pu.pat_id         = @patId
  AND pu.facility_cd = ''@facilityCd''
  AND pu.is_del      = ''0''
  -- 以下のいずれかなら更新：
  AND (
    pu.physical_info IS NULL
    OR jsonb_array_length(pu.physical_info::jsonb) = 0
    -- 既存の最新要素の height と異なる場合
    OR (le.elem->>''height'')::NUMERIC <> @content::NUMERIC
  )
;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　身長更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101505, 'WITH
-- 1) content をセミコロンで分解
raw_entries AS (
  SELECT unnest(string_to_array(trim(both '';'' FROM ''@content''), '';'')) AS entry
),
-- 2) コロンで分割して ctr_no, name, raw_state を取得
split_info AS (
  SELECT
    split_part(entry, '':'', 1) AS ctr_no,
    split_part(entry, '':'', 2) AS name,
    split_part(entry, '':'', 3) AS raw_state
  FROM raw_entries
  WHERE entry <> ''''
),
-- 3) 生データ(key2)→変換後値(value) のマップ
state_map AS (
  SELECT
    info ->> ''key2''   AS raw_key,
    info ->> ''value''  AS state_val
  FROM mst_coop_ini ini
  CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) AS info
  WHERE
    ini.facility_cd = ''@facilityCd''
    AND ini.is_del    = ''0''
    AND ini.is_disp   = ''1''
    AND info ->> ''key1'' = ''CONV_INFECTION_TO_FNW''
),
-- 4) mst_infection から facility_cd／is_del 絞り込み
infection_map AS (
  SELECT
    infection_cd,
    in_hospital_cd_1
  FROM ntss.mst_infection
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del    = ''0''
),
-- 5) 新しい各エントリを組み立て
new_array AS (
  SELECT
    im.infection_cd,
    -- state_map がヒットすれば変換値、なければ ''0''
    COALESCE(sm.state_val, ''0'')       AS infect,
    to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date,
    NULL::text                        AS exam_date,
    (si.ctr_no)::int                   AS order_no
  FROM split_info si
  -- raw_state → state_val
  LEFT JOIN state_map sm
    ON si.raw_state = sm.raw_key
  -- name で infection_cd を取得
  JOIN infection_map im
    ON im.in_hospital_cd_1 = si.name
),
-- 6) JSONオブジェクト化して ctr_no順にソート
updated_array AS (
  SELECT
    jsonb_build_object(
      ''infect'',       na.infect,
      ''up_date'',      na.up_date,
      ''exam_date'',    to_jsonb(na.exam_date),
      ''infection_cd'', na.infection_cd
    ) AS obj
  FROM new_array na
  ORDER BY na.order_no
)
-- 7) pat_main を更新
UPDATE pat_main pm
SET
  infect_info = (SELECT jsonb_agg(obj) FROM updated_array),
  up_date     = CURRENT_TIMESTAMP
WHERE
  pm.pat_id       = @patId
  AND pm.facility_cd = ''@facilityCd''
  AND pm.is_del    = ''0'';
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　感染症更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);