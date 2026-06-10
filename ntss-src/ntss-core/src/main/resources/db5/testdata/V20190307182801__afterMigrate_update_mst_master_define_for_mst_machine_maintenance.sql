-- 装置マスタ mst_machine メンテナンスのためのデータ更新
update
  sys_master_define
  set
    column_info = '{"fields": [{"type": "number","alias": "code","title": "装置番号","physical_name": "machine_no"},{"type": "string","alias": "name","title": "装置名","validation": {"required": true,"maxlength": 40},"physical_name": "machine_name"},{"type": "combo1","title": "型式","validation": {"required": true,"maxlength": 3},"physical_name": "machine_type_cd"},{"type": "string","title": "製造番号","validation": {"required": true,"maxlength": 8},"physical_name": "machine_serial"},{"type": "inet","title": "IPアドレス","validation": {"required": true,"maxlength": 15},"physical_name": "ip_address"},{"type": "combo1","title": "通信フォーマット","validation": {"required": true},"physical_name": "com_format_cd"},{"type": "combo1","title": "通信方式","validation": {"required": true},"physical_name": "com_type"},{"type": "combo1","title": "デバイスエッジ番号","validation": {"max": 99,"min": 1,"required": true},"physical_name": "device_edge_no"},{"type": "combo1","title": "データ収集可否","validation": {"required": true},"physical_name": "is_ftp"},{"type": "del", "title": "削除", "physical_name": "is_del"},{"type": "disp", "title": "削除", "physical_name": "is_disp"},{"type": "number","title": "VA画像転送可否","hidden": true,"physical_name": "is_va"}]}'

where
  master_physical_name = 'mst_machine'
;
