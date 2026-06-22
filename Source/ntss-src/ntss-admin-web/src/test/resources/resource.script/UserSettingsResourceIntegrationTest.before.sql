INSERT INTO mst_user (user_id, user_settings, is_provisional, reg_date, up_date) VALUES
  (900000000001, '{"is_disp_menu": 0, "font_size": 3, "theme": 0, "use_functions": ["001", "002", "003", "004"], "initial_function": "001", "is_split_frame": 0}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405');

UPDATE
  mst_user
SET
  user_settings = user_settings::jsonb || json_build_object(
    'personal_settings', json_build_array('{"tab_define_cd":1,"values": [{"setting_identifier": "1","value": "val1"},{"setting_identifier": "2","value": 2},{"setting_identifier": "3","value": 1.45}]}')
  )::jsonb
WHERE
  user_id = 900000000001
;
