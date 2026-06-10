-- #10563 日機装施設の初期管理ユーザのデータ不正
UPDATE
  mst_user
SET
  user_settings = '{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["005"], "is_split_frame": 1, "default_setting": {}, "ind_rst_pattern": null, "initial_function": "005", "personal_settings": [], "authorized_functions": ["005"], "authorized_authorities": []}',
  facility_cd = 'nkknkk',
  up_date = now()
WHERE
  user_id = 1;