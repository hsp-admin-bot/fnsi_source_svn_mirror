DELETE FROM mst_user;

INSERT INTO "mst_user"("user_id","user_settings","is_provisional","reg_date","up_date")
VALUES
(1,E'{"theme": 0, "font_size": 3, "is_disp_menu": 1, "use_functions": ["005", "004", "003", "002", "001"], "initial_function": "001", "authorized_authorities": ["011", "012", "013"], "ind_rst_pattern": 2, "is_split_frame": 0}',1,NULL,E'2018-11-12 13:58:50.302'),
(2,E'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003", "002", "004", "005"], "initial_function": "001", "authorized_authorities": ["021", "022", "023"], "ind_rst_pattern": 0, "is_split_frame": 1}',0,NULL,E'2018-11-12 14:03:06.582');

UPDATE
  mst_user
SET
  user_settings = user_settings::jsonb || json_build_object(
    'personal_settings', json_build_array('{"tab_define_cd":1,"values": [{"setting_identifier": "1","value": "val1"},{"setting_identifier": "2","value": 2},{"setting_identifier": "3","value": 1.45}]}')
  )::jsonb
WHERE
  user_id = 1
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_user
ADD COLUMN dummy character varying(1) -- ダミー列
;
