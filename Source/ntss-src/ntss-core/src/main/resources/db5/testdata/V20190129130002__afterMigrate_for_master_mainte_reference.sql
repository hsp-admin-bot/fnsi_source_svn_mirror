-- mst_test_ref_table へのサンプルデータ追加
INSERT INTO mst_test_ref_table(facility_cd,ref_name,is_disp,is_del,reg_date,up_date) VALUES 
	('009997','参照1','1','0','2019/01/29 10:50:20.524','2019/01/29 10:50:20.524'),
	('009997','参照2','1','0','2019/01/29 10:50:20.524','2019/01/29 10:50:20.524'),
	('009997','参照3','1','0','2019/01/29 10:50:20.524','2019/01/29 10:50:20.524'),
	('009997','参照4(削除)','0','0','2019/01/29 10:50:20.524','2019/01/29 10:50:20.524'),
	('009997','参照5','1','0','2019/01/29 10:50:20.524','2019/01/29 10:50:20.524');

-- mst_test_ref_table の mst_selector 作成
INSERT INTO mst_selector(facility_cd,master_physical_name,order_settings,reg_date,up_date) VALUES
 ('009997','mst_test_ref_table','{"items": [{"code": 1, "name": "参照1"}, {"code": 2, "name": "参照2"}, {"code": 3, "name": "参照3"}, {"code": 5, "name": "参照5"}]}','2019/01/29 10:50:20.556','2019/01/29 14:56:11.379');

-- sys_master_define のデータ追加
INSERT INTO sys_master_define(master_physical_name,master_name,disp_class,mode,allow_sort,allow_add_record,disp_order,column_info,combo_data,reg_date,up_date,reference_combo_def) VALUES
	 ('mst_test_ref_table','参照テストマスタ','2','1','1','1',6,'{"fields": [{"type": "number", "alias": "code", "title": "参照コード", "physical_name": "ref_cd"}, {"type": "string", "alias": "name", "title": "参照名", "validation": {"required": true, "maxlength": 80}, "physical_name": "ref_name"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',null,null,null,null);

UPDATE sys_master_define SET
     column_info = '{"fields": [{"type": "number", "alias": "code", "title": "死因コード", "physical_name": "die_cd"}, {"type": "string", "alias": "name", "title": "死因名", "validation": {"required": true, "maxlength": 80}, "physical_name": "die_name"}, {"type": "modal", "title": "詳細"}, {"type": "number", "title": "整数項目", "validation": {"maxlength": 7}, "physical_name": "test_numeric"}, {"type": "number", "title": "小数部あり項目", "format": "n2", "validation": {"max": 99999999.99, "min": 0.0}, "physical_name": "test_numeric2"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}, {"type": "date", "title": "日付項目", "format": "yyyy年MM月dd日", "physical_name": "test_date"}, {"type": "combo1", "title": "固定コンボ1", "physical_name": "combo1a"}, {"type": "combo1", "title": "固定コンボ2", "physical_name": "combo1b"}, {"type": "combo2", "title": "参照コンボ", "physical_name": "combo2"}]}'
   , combo_data = '{"combos": [{"values": [{"text": "文字1", "value": "a"}, {"text": "文字2", "value": "b"}, {"text": "文字3", "value": "c"}, {"text": "文字4", "value": "d"}, {"text": "文字5", "value": "e"}], "physical_name": "combo1a"}, {"values": [{"text": "数値1", "value": "1"}, {"text": "数値2", "value": "2"}, {"text": "数値3", "value": "3"}, {"text": "数値4", "value": "4"}, {"text": "数値5", "value": "5"}], "physical_name": "combo1b"}]}'
   , reference_combo_def = '{"combos": [ {"physical_name": "combo2", "target_table": {"name": "mst_test_ref_table", "referenced_column": "ref_cd", "display_column": "ref_name", "identifier": "ref_cd" } } ] }'
 WHERE master_physical_name = 'mst_test_table';

-- テスト用マスタ
TRUNCATE TABLE mst_test_table;
INSERT INTO mst_test_table (facility_cd,die_cd,die_name,memo,is_del,reg_date,up_date,test_numeric,test_date,test_numeric2,is_disp,combo1a,combo1b,combo2) VALUES
 ('009997',1,'名称３（変更）',null,'0','2019/01/09 10:34:33.316','2019/01/29 14:13:49.303',3,'2019/01/08',3.33,null,'a',null,null),
 ('009997',2,'名称２',null,'0','2019/01/09 10:34:33.332','2019/01/29 14:13:49.471',2,'2019/01/07',2.22,'1','c',1,null),
 ('009997',3,'名称１',null,'0','2019/01/09 10:34:33.347','2019/01/29 14:13:49.396',1,'2019/01/09',1.11,null,'b',null,1),
 ('009997',4,'Iphone変更',null,'0','2019/01/09 11:52:49.408','2019/01/09 11:53:54.070',0,'2019/01/08',0,null,null,null,2),
 ('009997',5,'Iphonez',null,'0','2019/01/09 11:53:54.070','2019/01/09 11:53:54.070',0,'2019/01/09',0,null,null,null,3),
 ('009997',6,'あいふぉん',null,'0','2019/01/09 11:55:26.906','2019/01/09 11:55:26.906',0,'2019/01/09',0,null,null,null,null),
 ('009997',7,'ああい',null,'0','2019/01/09 11:57:10.615','2019/01/29 14:13:49.510',0,'2019/01/09',0,null,null,2,null),
 ('009997',8,'デモ日機装',null,'0','2019/01/10 10:12:51.233','2019/01/29 14:13:49.577',0,'2019/01/10',0,null,null,3,null),
 ('009998',9,'名称１（施設B）変更',null,'0','2019/01/09 10:54:28.762','2019/01/09 10:56:39.771',0,'2019/01/08',0,null,null,null,null),
 ('009998',10,'名称２（施設B）',null,'0','2019/01/09 10:54:28.777','2019/01/09 11:02:43.376',0,'2019/01/08',0,'0',null,null,null),
 ('009998',11,'名称３（施設B）ipadから変更',null,'0','2019/01/09 10:54:28.793','2019/01/09 12:11:08.757',0,'2019/01/07',0,null,null,null,null),
 ('009998',12,'テストユーザーiphone',null,'0','2019/01/09 12:00:29.624','2019/01/09 12:00:29.624',0,'2019/01/09',0,null,null,null,null),
 ('009998',13,'Ipad',null,'0','2019/01/09 12:11:08.757','2019/01/09 12:11:08.757',0,'2019/01/09',0,null,null,null,null),
 ('009998',14,'変更',null,'0','2019/01/09 15:48:29.600','2019/01/09 15:49:29.255',0,'2019/01/08',0,null,null,null,null),
 ('009998',15,'追加',null,'0','2019/01/09 15:49:29.255','2019/01/09 15:49:29.255',0,'2019/01/09',0,null,null,null,null),
 ('009998',16,'テスト',null,'0','2019/01/10 10:15:29.043','2019/01/10 10:15:29.043',0,'2019/01/10',0,null,null,null,null),
 ('009998',17,'追加３',null,'0','2019/01/10 10:21:30.714','2019/01/10 10:21:30.714',0,'2019/01/10',0,null,null,null,null),
 ('009998',18,'追加２',null,'0','2019/01/10 10:21:30.885','2019/01/10 10:21:30.885',0,'2019/01/10',0,null,null,null,null);

