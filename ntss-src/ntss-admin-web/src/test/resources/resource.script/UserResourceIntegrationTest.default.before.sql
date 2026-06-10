TRUNCATE TABLE mst_user CASCADE;

INSERT INTO mst_user (user_id, user_settings, is_provisional, reg_date, up_date, pat_id) VALUES
  -- getUserAccountInfo
  (1,E'{"theme": 0, "font_size": 3, "is_disp_menu": 1, "use_functions": ["005", "004", "003", "002", "001"], "initial_function": "001", "ind_rst_pattern": 2}',1,NULL,E'2018-11-12 13:58:50.302',1),
  (2,E'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003", "002", "004", "005"], "initial_function": "001", "ind_rst_pattern": 0}',0,NULL,E'2018-11-12 14:03:06.582',2),
  -- alterProvisionalInfo
  (900000000001, '{"is_disp_menu": 0, "font_size": 3, "theme": 0, "use_functions": ["001", "002", "003", "004"], "initial_function": "001"}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405',3),
  (900000000002, '{"is_disp_menu": 1, "font_size": 5, "theme": 1, "use_functions": ["001", "002", "003"], "initial_function": "003"}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405',4),
  (900000000003, '{"is_disp_menu": 1, "font_size": 5, "theme": 1, "use_functions": ["001", "005"], "initial_function": "001"}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405',5),
  -- editUserAccountInfo
  (999900000001, '{"is_disp_menu": 0, "font_size": 3, "theme": 0, "use_functions": ["001"], "initial_function": "001"}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405',6);