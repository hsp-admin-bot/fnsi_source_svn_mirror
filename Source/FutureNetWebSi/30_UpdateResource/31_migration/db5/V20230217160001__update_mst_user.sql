--デフォルト設定 > 患者検索のベッドグループ設定を初期化
UPDATE
  mst_user
SET
  user_settings = A.changed_user_setting,
  up_date = now()
FROM (
    SELECT 
      user_id,
      -- デフォルト設定 > 患者検索のベッドグループを初期化したものをユーザー設定とマージ
      user_settings || 
        json_build_object(
          'default_setting', default_setting::jsonb || json_build_object(
            'patient-search', patient_search::jsonb || json_build_object(
              'bedCdListString', '{"key":0,"value":"[]"}'
            )::jsonb
          )::jsonb
        )::jsonb as changed_user_setting,
      patient_search
    FROM
      mst_user
    CROSS JOIN
      -- デフォルト設定の患者検索 存在しなければNULLになる
      jsonb_extract_path(jsonb_extract_path(mst_user.user_settings, 'default_setting'),'patient-search') as patient_search,
      -- デフォルト設定全体
      jsonb_extract_path(mst_user.user_settings, 'default_setting') as default_setting
    WHERE
      patient_search IS NOT NULL
) A
WHERE
  mst_user.user_id = A.user_id;