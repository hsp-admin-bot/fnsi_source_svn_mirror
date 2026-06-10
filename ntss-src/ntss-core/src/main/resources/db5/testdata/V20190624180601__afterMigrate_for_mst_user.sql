UPDATE
  mst_user
SET
  user_settings = user_settings::jsonb || json_build_object(
    'use_functions', array['001', '003', '006']
  )::jsonb
WHERE
  user_id = 8
;

UPDATE
  mst_user
SET
  user_settings = user_settings::jsonb || json_build_object(
    'use_functions', array['001', '002', '003', '004', '005', '006']
  )::jsonb
WHERE
  user_id = 10
;
