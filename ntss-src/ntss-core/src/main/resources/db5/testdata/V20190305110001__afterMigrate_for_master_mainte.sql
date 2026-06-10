-- sys_master_define のデータ更新(削除ボタン位置の修正)
UPDATE sys_master_define
SET
  column_info = '{"fields": [{"type": "number", "alias": "code", "title": "警報通知コード", "physical_name": "alarm_notification_cd"}, {"type": "string", "alias": "name", "title": "警報通知名", "physical_name": "alarm_notification_name"}, {"type": "modal", "title": "詳細"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "string", "title": "送信先施設コード", "hidden": "true", "physical_name": "destination_facility_cd"}, {"type": "string", "title": "送信先グループコード", "hidden": "true", "physical_name": "destination_group_cd"}, {"type": "json", "title": "対象装置記録", "hidden": "true", "physical_name": "target_machine_record"}]}'
WHERE master_physical_name = 'mst_alarm_notification'
;

UPDATE sys_master_define
SET
  column_info = '{"fields": [{"type": "number", "alias": "code", "title": "送信先グループコード", "physical_name": "destination_group_cd"}, {"type": "string", "alias": "name", "title": "送信先グループ名", "physical_name": "destination_group_name"}, {"type": "modal", "title": "詳細"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "json", "title": "送信対象", "hidden": "true", "physical_name": "destination_target"}]}'
WHERE master_physical_name = 'mst_destination_group'
;
