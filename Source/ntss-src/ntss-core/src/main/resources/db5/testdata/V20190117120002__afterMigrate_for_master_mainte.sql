-- 並び順管理マスタ
TRUNCATE TABLE mst_selector;
INSERT INTO mst_selector (facility_cd, master_physical_name, order_settings, reg_date, up_date) VALUES 
	('009997','mst_test_table','{"items": [{"code": 1, "name": "名称３（変更）"}, {"code": 3, "name": "名称１"}, {"code": 2, "name": "名称２"}, {"code": 7, "name": "Iphone変更"}, {"code": 8, "name": "Iphonez"}, {"code": 9, "name": "あいふぉん"}, {"code": 10, "name": "ああい"}, {"code": 15, "name": "デモ日機装"}]}','2019-01-09 10:34:33.347','2019-01-10 10:12:51.326'),
	('009998','mst_test_table','{"items": [{"code": 12, "name": "Ipad"}, {"code": 11, "name": "テストユーザーiphone"}, {"code": 4, "name": "名称１（施設B）変更"}, {"code": 6, "name": "名称３（施設B）ipadから変更"}, {"code": 13, "name": "変更"}, {"code": 16, "name": "テスト"}, {"code": 14, "name": "追加"}, {"code": 17, "name": "追加３"}, {"code": 18, "name": "追加２"}]}','2019-01-09 10:54:28.793','2019-01-10 10:21:30.901')
;

-- マスタ定義
TRUNCATE TABLE sys_master_define;
INSERT INTO sys_master_define (master_physical_name, master_name, disp_class, mode, allow_sort, allow_add_record, disp_order, column_info, combo_data, reg_date, up_date) VALUES
	('mst_test_table','テストマスタ','2','1','1','1',5,'{"fields": [{"type": "number", "alias": "code", "title": "死因コード", "physical_name": "die_cd"}, {"type": "string", "alias": "name", "title": "死因名", "validation": {"required": true, "maxlength": 80}, "physical_name": "die_name"}, {"type": "number", "title": "整数項目", "validation": {"maxlength": 7}, "physical_name": "test_numeric"}, {"type": "number", "title": "小数部あり項目", "format": "n2", "validation": {"max": 99999999.99, "min": 0.0}, "physical_name": "test_numeric2"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}, {"type": "date", "title": "日付項目", "format": "yyyy年MM月dd日", "physical_name": "test_date"}]}',null,null,null)
;

-- テスト用マスタ
TRUNCATE TABLE mst_test_table;
INSERT INTO mst_test_table (facility_cd,die_name,memo,is_del,reg_date,up_date,test_numeric,test_date,test_numeric2,is_disp) VALUES
  ('009997','名称３（変更）',NULL,'0','2019/01/09 10:34:33.316','2019/01/09 10:40:17.453',3,'2019/01/08',3.33,NULL),
  ('009997','名称２',NULL,'0','2019/01/09 10:34:33.332','2019/01/09 11:37:28.991',2,'2019/01/07',2.22,'1'),
  ('009997','名称１',NULL,'0','2019/01/09 10:34:33.347','2019/01/09 10:34:33.347',1,'2019/01/09',1.11,NULL),
  ('009997','Iphone変更',NULL,'0','2019/01/09 11:52:49.408','2019/01/09 11:53:54.070',0,'2019/01/08',0,NULL),
  ('009997','Iphonez',NULL,'0','2019/01/09 11:53:54.070','2019/01/09 11:53:54.070',0,'2019/01/09',0,NULL),
  ('009997','あいふぉん',NULL,'0','2019/01/09 11:55:26.906','2019/01/09 11:55:26.906',0,'2019/01/09',0,NULL),
  ('009997','ああい',NULL,'0','2019/01/09 11:57:10.615','2019/01/09 11:57:10.615',0,'2019/01/09',0,NULL),
  ('009997','デモ日機装',NULL,'0','2019/01/10 10:12:51.233','2019/01/10 10:12:51.233',0,'2019/01/10',0,NULL),
  ('009998','名称１（施設B）変更',NULL,'0','2019/01/09 10:54:28.762','2019/01/09 10:56:39.771',0,'2019/01/08',0,NULL),
  ('009998','名称２（施設B）',NULL,'0','2019/01/09 10:54:28.777','2019/01/09 11:02:43.376',0,'2019/01/08',0,'0'),
  ('009998','名称３（施設B）ipadから変更',NULL,'0','2019/01/09 10:54:28.793','2019/01/09 12:11:08.757',0,'2019/01/07',0,NULL),
  ('009998','テストユーザーiphone',NULL,'0','2019/01/09 12:00:29.624','2019/01/09 12:00:29.624',0,'2019/01/09',0,NULL),
  ('009998','Ipad',NULL,'0','2019/01/09 12:11:08.757','2019/01/09 12:11:08.757',0,'2019/01/09',0,NULL),
  ('009998','変更',NULL,'0','2019/01/09 15:48:29.600','2019/01/09 15:49:29.255',0,'2019/01/08',0,NULL),
  ('009998','追加',NULL,'0','2019/01/09 15:49:29.255','2019/01/09 15:49:29.255',0,'2019/01/09',0,NULL),
  ('009998','テスト',NULL,'0','2019/01/10 10:15:29.043','2019/01/10 10:15:29.043',0,'2019/01/10',0,NULL),
  ('009998','追加３',NULL,'0','2019/01/10 10:21:30.714','2019/01/10 10:21:30.714',0,'2019/01/10',0,NULL),
  ('009998','追加２',NULL,'0','2019/01/10 10:21:30.885','2019/01/10 10:21:30.885',0,'2019/01/10',0,NULL)
;
