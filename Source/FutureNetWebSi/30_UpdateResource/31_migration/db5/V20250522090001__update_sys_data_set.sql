DELETE FROM sys_data_set WHERE sql_cd IN (-1101004);

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

    -- 性別コード：M→1, F→2, その他→NULL
    pat_sex             = CASE NULLIF(''@sex'','''')
                            WHEN ''M'' THEN 1
                            WHEN ''F'' THEN 2
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
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル(profile)(CSV):患者個人情報の取得の更新', '2025-05-13 14:38:12.928', CURRENT_TIMESTAMP, NULL);