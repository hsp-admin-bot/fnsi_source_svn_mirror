DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1101003, -1101000);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101003, 'WITH in_out_info AS (
SELECT array_to_json(ARRAY_AGG(json_build_object(
    ''ctl_no'', 1,
    ''in_out'', 0,
    ''reason'', null,
    ''to_course'', null,
    ''to_doctor'', null,
    ''disp_order'', 0,
    ''period_end'', null,
    ''facility_cd'', NULLIF(''@facilityCd'', ''''),
    ''from_course'', null,
    ''from_doctor'', null,
    ''move_in_out'', ''6'',
    ''to_facility'', null,
    ''period_start'', to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''),
    ''from_facility'', null,
    ''course_is_free'', ''0'',
    ''doctor_is_free'', ''0'',
    ''period_end_day'', null,
    ''period_end_year'', null,
    ''facility_is_free'', ''0'',
    ''period_end_month'', null,
    ''period_start_day'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 7, 2),
    ''period_start_date'', to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''),
    ''period_start_year'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 1, 4),
    ''period_start_month'', SUBSTR(to_char(CURRENT_TIMESTAMP, ''YYYYMMDD''), 5, 2),
    ''period_end_input_free'', ''0'',
    ''period_start_input_free'', ''0'',
    ''to_medicalInstitutionCd'', null,
    ''from_medicalInstitutionCd'', null
    ))) AS in_out_info_json
)
INSERT 
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
  , (SELECT in_out_info_json FROM in_out_info)
  , ''[]''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''@facilityCd''
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル_固有情報登録', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
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
    pat_sex,               -- 性別コード (M→1, F→2, その他→NULL)
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
      WHEN ''M'' THEN 1
      WHEN ''F'' THEN 2
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
          ''relation_name'', ''その他'',
          ''ctl_no'',        1,
          ''disp_order'',    0

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
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル(profile)(CSV):患者個人情報の取得の新規', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);