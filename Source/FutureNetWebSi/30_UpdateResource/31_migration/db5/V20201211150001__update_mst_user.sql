UPDATE
  mst_user
SET
  user_settings = user_settings::jsonb || json_build_object(
    'default_setting', '{}'::json
  )::jsonb
;