truncate table mst_user CASCADE;
truncate table mst_staff_facility CASCADE;
truncate table mst_facility CASCADE;
truncate table mnt_machine_state;
truncate table sys_prefectures;
truncate table mst_personal_tab_define;
truncate table sys_personal_settings_define;

insert into mst_facility
   (facility_cd, facility_name, facility_name_kana, department_cd, prefectures_cd, use_function)
values
   ('900001', 'テスト施設1', 'テストシセツ1', '9001', '01', '{"func_cds": [{"func_cd": "00a"}, {"func_cd": "00b"}, {"func_cd": "00c"}]}'),
   ('900002', 'テスト施設2', 'テストシセツ2', '9002', '02', '{"func_cds": []}'),
   ('900003', 'テスト施設3', 'テストシセツ3', '9003', '01', NUll)
;

INSERT INTO mst_user (user_id, user_settings, is_provisional, reg_date, up_date) VALUES
  (900000000001, '{"is_disp_menu": 0, "font_size": 3}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405');


insert into mst_staff_facility
  (user_id, facility_cd)
values
  (900000000001, '900001'),
  (900000000001, '900002')
;

insert into mnt_machine_state
  (facility_cd, machine_type_cd, machine_serial, m_notice_cnt, preventive_mainte_cnt, is_preventive_mainte, service_support_cnt)
values
  ('900001', '901', '90000001', 1, 1, 1, 1),
  ('900001', '901', '90000002', 1, 2, 1, 0),
  ('900001', '901', '90000003', 1, 3, 0, 1),
  ('900002', '902', '90000004', 2, 0, 0, 0),
  ('900002', '902', '90000005', 0, 1, 0, 1)
;

insert into sys_prefectures
  (pref_cd, pref_name)
values
  ('01', '東京都'),
  ('02', '福井県')
;

insert into mst_personal_tab_define
  (facility_cd, tab_define_cd, display_name, contents_id, disp_order, is_disp, is_del, mode)
values
  ('009999', 1, 'タブA', 'tab-contents-A', 5, '1', '0', '0')
  , ('009999', 2, 'タブB', 'tab-contents-B', 7, '0', '1', '0')
  , ('009999', 3, 'タブC', 'tab-contents-C', 2, '1', '0', '1')
  , ('009999', 4, 'タブD', 'tab-contents-D', 3, '1', '1', '1')
  , ('009999', 5, 'タブE', 'tab-contents-E', 4, '0', '0', '0')
  , ('000001', 6, 'タブF', 'tab-contents-F', 1, '1', '0', '1')
;
INSERT INTO
  sys_personal_settings_define(
    personal_settings_cd
    , tab_define_cd
    , edit_level
    , item_info
    , combo_data
    , reference_combo_def
  )
VALUES
  (1, 1, '1', NULL, NULL, NULL),
  (2, 2, '1', NULL, NULL, NULL),
  (3, 3, '1', NULL, NULL, NULL),
  (4, 4, '1', NULL, NULL, NULL),
  (5, 5, '1', NULL, NULL, NULL),
  (6, 6, '1', NULL, NULL, NULL)
;
