--水質管理のデフォルト設定を削除
UPDATE
  mst_user
SET
  user_settings = A.changed_user_setting,
  up_date = now()
FROM (
    SELECT 
      user_id,
      -- デフォルト設定のうち水質管理の設定を削除したものをユーザー設定とマージ
      user_settings || 
        json_build_object(
          'default_setting', default_setting - 'water-quality-survey'
        )::jsonb as changed_user_setting,
      water_quality_survey
    FROM
      mst_user
    CROSS JOIN
      -- デフォルト設定の水質管理 存在しなければNULLになる
      jsonb_extract_path(jsonb_extract_path(mst_user.user_settings, 'default_setting'),'water-quality-survey') water_quality_survey,
      -- デフォルト設定全体
      jsonb_extract_path(mst_user.user_settings, 'default_setting') as default_setting
    WHERE
      water_quality_survey IS NOT NULL
) A
WHERE
  mst_user.user_id = A.user_id;