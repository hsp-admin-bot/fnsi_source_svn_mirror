truncate table sys_master_define;
truncate table mnt_motion_record CASCADE;
truncate table mst_facility CASCADE;
truncate table mst_user CASCADE;
truncate table mst_selector CASCADE;
truncate table mst_device_edge CASCADE;

insert into sys_master_define
  (master_name, mode, edit_level, allow_sort, allow_add_record, disp_order, column_info, reg_date, up_date, master_physical_name, combo_data, disp_class, reference_combo_def)
values
  ('マスタ名称1', '1', '1', '0', '1',  2, '{"fields": [{"physical_name": "facility_name", "title": "施設名", "type": "string", "validation": { "maxlength":40 } }, { "physical_name": "facility_name_kana", "title": "施設カナ名", "type": "string", "validation": { "maxlength":50 } }, { "physical_name": "prefectures_cd", "title": "都道府県コード", "type": "string", "validation": { "maxlength":2 }, "hidden": false }, { "physical_name": "department_cd", "title": "部署符号", "type": "string", "validation": { "maxlength":4 }, "hidden": true }, { "physical_name": "alive_moni_interval", "title": "死活監視間隔", "type": "number", "validation": { "min":1, "max":10 } }, {"type": "modal", "title": "詳細"}, { "physical_name": "use_function", "title": "使用可能機能", "type": "json" }, { "physical_name": "certification_key", "title": "認証キー", "type": "combo2" }] }', '2018-05-25 17:16:55', '2018-08-25 17:16:55', 'mst_facility', null, '2', '{"combos":[{"physical_name": "certification_key", "target_table": {"name": "mnt_motion_record", "referenced_column": "machine_type_cd", "display_column": "machine_serial", "identifier": "motion_record_no"}}]}'),
  ('マスタ名称2', '2', '2', '0', '0',  1, '{"fields": [{"physical_name": "user_id", "title": "ユーザーID", "type": "string", "alias": "code"}, {"physical_name": "user_type", "title": "利用者種別", "type": "number"}, {"physical_name": "user_password", "title": "パスワード", "type": "string"}, {"physical_name": "user_last_name", "title": "利用者名_姓", "type": "string"}, {"physical_name": "user_first_name", "title": "利用者名_名", "type": "string"}, {"physical_name": "user_email_address_1", "title": "メールアドレス1", "type": "string", "alias": "name"}, {"physical_name": "job_cd", "title": "職種コード", "type": "string"}] }', '2018-05-25 17:16:55', '2018-08-25 17:16:55', 'mst_user', null, '2', null),
  ('マスタ名称3', '3', '3', '0', '1',  3, '{"fields": [{"physical_name": "motion_record_no", "title": "装置動作記録番号", "type": "number", "alias": "code"}, {"physical_name": "data_type", "title": "データ種別", "type": "number"}, {"physical_name": "machine_type_cd", "title": "型式コード", "type": "string"}, {"physical_name": "machine_serial", "title": "製造番号", "type": "string", "alias": "name"}, { "physical_name": "contents", "title": "内容", "type": "json" }] }', '2018-05-25 17:16:55', '2018-08-25 17:16:55', 'mnt_motion_record', null, '2', null),
  ('マスタ名称4', '4', '4', '0', '1',  3, '{"fields": [{"physical_name": "facility_name", "title": "施設名", "type": "string", "selectable": true, "editable":true, "validation": { "maxlength":40, "min": 1, "max": 100, "required":true }, "format": "string", "alias": "name", "hidden": false, "defaultValue": "1" }] }', '2018-05-25 17:16:55', '2018-08-25 17:16:55', 'test_master', null, '1', null)
;

insert into mst_facility
   (facility_cd, facility_name, facility_name_kana, prefectures_cd, department_cd, alive_moni_interval, use_function, certification_key)
values
   ('000001', '施設名１', 'シセツカナメイ１', '01', 'S1A1', 1, '{"func_cds": [{"func_cd": "001"}]}', '903'),
   ('000002', '施設名２', 'シセツカナメイ２', '02', 'S2A2', 2, '{"func_cds": [{"func_cd": "002"}]}', '901')
;

insert into mst_user
  (user_id, is_provisional)
values
  (1, 0)
;

insert into mnt_motion_record
  (motion_record_no, event_reg_date, m_notice_status, facility_cd, machine_type_cd, machine_serial, data_type, contents, up_date)
values
  (21,  '2018-03-29 12:13:14',  1, '000001', '901', '90000021', 1, '{"key":"value"}', '2019-09-13 14:00:00'),
  (52,  '2018-05-02 09:47:14', -1, '000002', '902', '90000052', 1, '{"key":"value"}', '2019-09-13 14:01:00'),
  (934, '2018-03-29 12:13:14', -1, '000001', '903', '90000001', 1, '{"key":"value"}', '2019-09-13 14:02:00'),
  (935, '2018-03-28 11:22:33', -1, '000001', '904', '90000001', 1, '{"key":"value"}', '2019-09-13 14:03:00')
;

SELECT setval('mnt_motion_record_motion_record_no_seq', 1);

insert into mst_selector
  (facility_cd,master_physical_name,order_settings)
 values
  ('000001','mnt_motion_record','{"items": [{ "code": 52, "name": "name52" }, { "code": 21, "name": "name21" }]}')
;

