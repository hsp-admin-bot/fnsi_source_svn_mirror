-- sys_master_define のデータ更新(メーカー通知の定義を追加)
UPDATE sys_master_define
SET
  column_info = '{"fields": [{"type": "number", "alias": "code", "title": "送信先グループコード", "physical_name": "destination_group_cd"}, {"type": "string", "alias": "name", "title": "送信先グループ名", "validation": {"required": true}, "physical_name": "destination_group_name"}, {"type": "modal", "title": "詳細"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "json", "title": "送信対象", "hidden": "true", "physical_name": "destination_target"}, {"type": "string", "title": "メーカー通知", "hidden": "true", "physical_name": "is_notice"}]}'
WHERE master_physical_name = 'mst_destination_group'
;
