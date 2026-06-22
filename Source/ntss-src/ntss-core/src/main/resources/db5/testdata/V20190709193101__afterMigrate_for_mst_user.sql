UPDATE
  mst_user
SET
  user_settings = user_settings::jsonb || json_build_object(
    'authorized_authorities', array['091']
  )::jsonb
WHERE
  user_id = 8
;

UPDATE
  mst_user
SET
  user_settings = user_settings::jsonb || json_build_object(
    'authorized_authorities', array['091', '092', '093']
  )::jsonb
WHERE
  user_id = 10
;
