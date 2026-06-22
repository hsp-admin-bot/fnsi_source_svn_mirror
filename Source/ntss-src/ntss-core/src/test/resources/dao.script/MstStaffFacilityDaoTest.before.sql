truncate table mst_staff_facility;
truncate table mst_facility CASCADE;
truncate table sys_prefectures;

insert into mst_facility
   (facility_cd, facility_name, facility_name_kana, department_cd, prefectures_cd)
values
   ('900001', 'テスト施設1', 'テストシセツ1', '9001', '01'),
   ('900002', 'テスト施設2', 'テストシセツ2', '9002', '02'),
   ('900003', 'テスト施設3', 'テストシセツ3', '9003', '01')
;

INSERT INTO mst_user (user_id, user_settings, is_provisional, reg_date, up_date) VALUES
  (900000000001, '{"is_disp_menu": 0, "font_size": 3}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (990000000001, '{"is_disp_menu": 0, "font_size": 3}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (900000000003, '{"is_disp_menu": 0, "font_size": 3}', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405')
;

insert into mst_staff_facility
  (user_id, facility_cd)
values
  (900000000001, '900001'),
  (900000000001, '900002'),
  (990000000001, '900001'),
  (990000000001, '900003')
;

insert into sys_prefectures
  (pref_cd, pref_name)
values
  ('01', '東京都'),
  ('02', '福井県')
  ;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_staff_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  sys_prefectures
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_user
ADD COLUMN dummy character varying(1) -- ダミー列
;
