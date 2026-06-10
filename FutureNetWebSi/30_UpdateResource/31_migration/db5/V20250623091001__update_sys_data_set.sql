DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1101000);

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
),
birthday_check AS (
-- 渡された値がYYYYMMDD形式の日付でない場合はNULLにする
SELECT
     CASE 
       WHEN NULLIF(''@birthday'','''') IS NULL THEN NULL
       WHEN ''@birthday'' ~ ''^(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])$'' 
            AND (
                 (''@birthday'' ~ ''^(19|20)\d{2}02(29)$'' AND SUBSTRING(''@birthday'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@birthday'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@birthday'', 1, 4)::int % 400 = 0))
                 OR (''@birthday'' ~ ''^(19|20)\d{2}(0[13578]|1[02])(0[1-9]|[12]\d|3[01])$'')
                 OR (''@birthday'' ~ ''^(19|20)\d{2}(0[469]|11)(0[1-9]|[12]\d|30)$'')
                 OR (''@birthday'' ~ ''^(19|20)\d{2}02(0[1-9]|1\d|2[0-8])$'')
            )
       THEN ''@birthday''
       ELSE NULL
     END AS birthday
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
    ''@hospPatId''                         AS hosp_pat_id,
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
    (SELECT birthday FROM birthday_check)          AS pat_birthday,
    -- 性別コード：M→1, F→2, その他→NULL
    CASE NULLIF(''@sex'','''')
      WHEN ''1'' THEN 1
      WHEN ''2'' THEN 2
      ELSE NULL
    END::smallint                                   AS pat_sex,
    ''0''                                              AS pat_blood_type_abo,
    ''0''                                              AS pat_blood_type_rh,
    ''0''                                              AS pat_blood_type_serovar,
    -- 入外区分コード
    0                AS in_out_class,

    -- 本人連絡先情報をJSONB化
    jsonb_build_object(
        ''fax'', null,
        ''tel1'',    NULLIF(''@tel1'',''''),
        ''tel2'', null,
        ''memo1'', null,
        ''memo2'', null,
        ''e_mail'', null,
        ''zip_cd'',  NULLIF(REPLACE(''@zipCd'', ''-'', ''''),''''),
        ''address'', NULLIF(''@address'',''''),
        ''work_tel'', null,
        ''work_name'', null,
        ''work_address'', null
    )                                                AS pat_contact_info,

    -- その他連絡先情報：otherKanjiName が NULL/空 の場合は登録せず NULL、
    CASE
      WHEN oname_arr IS NULL OR oname_arr[1] = '''' THEN NULL
      ELSE json_build_array(
        json_build_object(
          ''last_name'',     oname_arr[1],
          ''first_name'',    COALESCE(oname_arr[2],''''),
          ''zip_cd'',        NULLIF(REPLACE(''@otherZipCd'', ''-'', ''''), ''''),
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
;
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル(profile)(CSV):患者個人情報の取得の新規', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);