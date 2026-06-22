-- 利用者マスタ
TRUNCATE TABLE mst_user CASCADE;
INSERT INTO mst_user (user_id, user_settings, is_provisional, reg_date, up_date) VALUES 
	(1,'{"theme": 0, "font_size": 3, "is_disp_menu": 1, "use_functions": ["005", "004", "003", "002", "001"], "initial_function": "001"}',1,null,'2018-11-12 13:58:50.302'),
	(2,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003", "002", "004", "005"], "initial_function": "001"}',0,null,'2018-11-12 14:03:06.582'),
	(3,'{"theme": 0, "font_size": 1, "is_disp_menu": 0, "use_functions": [], "initial_function": ""}',0,null,'2018-11-19 16:51:53.367'),
	(4,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["002", "001", "004", "003"]}',0,null,'2018-10-16 18:12:34.001'),
	(5,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003", "002", "004", "005"], "initial_function": "001"}',0,null,'2018-11-16 10:31:15.222'),
	(6,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["003", "001", "002", "004", "005"], "initial_function": ""}',0,null,'2018-11-26 18:22:28.233'),
	(7,null,0,'2018-06-11 10:26:57.68','2018-11-22 15:59:58.609'),
	(11,'{"theme": 0, "font_size": 0, "is_disp_menu": 1, "use_functions": ["003", "001"], "initial_function": "001"}',0,null,'2019-01-15 09:38:31.849'),
	(16,'{"theme": 0, "font_size": 1, "is_disp_menu": 0, "use_functions": ["001"], "initial_function": "001"}',0,'2018-12-05 11:53:08.931','2018-12-05 11:53:47.442'),
	(17,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003"], "initial_function": "001"}',1,'2018-12-04 13:39:59.666','2018-12-04 13:39:59.666'),
	(18,'{"theme": 1, "font_size": 1, "is_disp_menu": 0, "use_functions": [], "initial_function": ""}',0,null,'2018-12-06 18:21:51.349'),
	(14,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001"], "initial_function": "001"}',1,'2018-05-31 10:17:01.033','2018-12-18 21:32:04.578'),
	(9,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["004", "003", "002", "001", "005"], "initial_function": "001"}',0,'2018-05-25 17:16:55','2018-12-26 10:02:29.153'),
	(8,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003"], "initial_function": "001"}',0,null,null),
	(10,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "002", "003", "004", "005"], "initial_function": "001"}',0,null,'2018-12-05 15:28:18.772'),
	(13,'{"theme": 0, "font_size": 1, "is_disp_menu": 0, "use_functions": ["001"], "initial_function": "001"}',0,null,'2018-12-04 13:54:33.713'),
	(19,'{"theme": 1, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003", "005", "004"], "initial_function": "003"}',0,'2018-05-25 17:16:55','2018-12-19 13:33:30.555'),
	(12,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003", "005"], "initial_function": "001"}',0,null,'2018-12-20 14:40:47.422'),
	(15,'{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ["001", "003", "005", "002"], "initial_function": "001"}',0,null,'2018-12-07 10:39:37.913'),
	(20,null,1,null,'2018-12-19 13:34:59.982')
;

-- 施設マスタ
TRUNCATE TABLE mst_facility CASCADE;
INSERT INTO mst_facility (facility_cd, facility_name, facility_name_kana, prefectures_cd, department_cd, m_notice_mail_template, auto_gathering_start_time, alive_moni_interval, certification_key, use_function, reg_date, up_date) VALUES 
	('009999','ESMテスト施設','ESMテストシセツ','32','S3A2','メールテンプレート６',null,600,null,'{"func_cds": [{"func_cd": "001"}, {"func_cd": "002"}, {"func_cd": "003"}, {"func_cd": "004"}]}','1850-01-01 00:00:00','2018-06-15 21:42:56.842'),
	('000002','日機装病院','ニッキソウビョウイン','17','S3A0','メールテンプレート２','1325',null,null,'{"func_cds": [{"func_cd": "001"}, {"func_cd": "002"}, {"func_cd": "003"}, {"func_cd": "004"}]}','1850-01-01 00:00:00','2018-06-15 22:30:54.948'),
	('000001','テスト病院１','TDCクリニック','16','S3A0','関係者各位

　[施設名] の装置：[装置名]でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：[施設名]
　■装置名：[装置名]
　■発生日時：[発生日時]
　■型式：[型式]
　■製造番号：[製造番号]
　■装置記録コード：[装置記録コード]
　■装置記録メッセージ：[装置記録メッセージ]
　■発報対象者名：[発報対象者名]
　
以上です。
よろしくお願い致します。','1300',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000003','テスト病院２','シセツ３','18','S3A0','メールテンプレート３',null,null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000004','テスト病院３','シセツ４','19','S3A1','メールテンプレート４','1100',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000005','テスト病院４','シセツ５','20','S3A1','メールテンプレート５',null,null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000006','テスト病院５','シセツ６','21','S3A1','メールテンプレート６',null,null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000007','テスト病院６','シセツ７','21','S3A1','メールテンプレート７',null,600,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000008','テスト病院７','シセツ８','22','S3A2','メールテンプレート８',null,600,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000009','テスト病院８','シセツ９','23','S3A3','メールテンプレート９',null,600,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000010','テスト病院９','シセツ１０','24','S3A4','メールテンプレート１０',null,600,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('000011','テスト病院１０','000011','32','S3A2','メールテンプレート６',null,600,null,'{"func_cds": [{"func_cd": "001"}, {"func_cd": "002"}, {"func_cd": "003"}, {"func_cd": "004"}]}','1850-01-01 00:00:00','2018-06-15 21:42:56.842'),
	('009998','永和病院','エイワビョウイン','32','S3A2','メールテンプレート６',null,600,null,'{"func_cds": [{"func_cd": "001"}]}','1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('999900','TDCクリニック2','TDCクリニック','31','S3A8','関係者各位

　[施設名] の装置：[装置名]でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：[施設名]
　■装置名：[装置名]
　■発生日時：[発生日時]
　■型式：[型式]
　■製造番号：[製造番号]
　■装置記録コード：[装置記録コード]
　■装置記録メッセージ：[装置記録メッセージ]
　■発報対象者名：[発報対象者名]
　■稼働ビューア：[URL]
　
以上です。
よろしくお願い致します。',null,600,null,'{"func_cds": [{"func_cd": "001"}, {"func_cd": "002"}, {"func_cd": "003"}, {"func_cd": "004"}]}','1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('900001','テスト施設1',null,null,'9001',null,null,600,null,null,null,null),
	('900002','テスト施設2',null,null,'9002',null,null,600,null,null,null,null),
	('009997','アカウント編集テスト','アカウントヘンシュウテスト','13','S3A5',null,null,600,null,'{"func_cds": [{"func_cd": "001"}, {"func_cd": "002"}, {"func_cd": "003"}, {"func_cd": "004"}]}',null,'2018-06-12 14:25:57.408')
;

-- デバイスエッジ状態管理
TRUNCATE TABLE mnt_device_edge_state;
INSERT INTO mnt_device_edge_state (facility_cd, device_edge_no, alive_moni_status, version_information, last_moni_time, reg_date, up_date) VALUES 
	('000002',2,'00',null,'2018-03-30 09:02:18+09','2018-01-31 15:38:27','2018-03-30 09:02:18'),
	('000001',1,'F1',null,'2018-03-30 19:19:21.493+09','2018-01-31 15:38:27.207','2018-03-30 19:19:21.493'),
	('000001',2,'F0',null,'2018-03-30 09:02:19+09','2018-01-31 15:38:27','2018-03-30 09:02:19'),
	('000002',1,'F2',null,'2018-03-30 09:02:18+09','2018-01-31 15:38:27','2018-03-30 09:02:18')
;

-- データ収集管理
TRUNCATE TABLE mnt_gathering_manage;
INSERT INTO mnt_gathering_manage (gathering_manage_no, facility_cd, gathering_status, gathering_info, ope_info, parent_manage_no, user_id, reg_date, up_date) VALUES 
	(3,'000001',1,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]',1,null,null,'2017-12-01 16:38:52','2017-12-01 17:12:40'),
	(4,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 16:45:32','2017-12-01 16:45:32'),
	(5,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 16:55:58','2017-12-01 16:55:58'),
	(6,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 16:59:49','2017-12-01 16:59:49'),
	(7,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:04:54','2017-12-01 17:04:54'),
	(8,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:05:30','2017-12-01 17:05:30'),
	(9,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:06:21','2017-12-01 17:06:21'),
	(10,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:15:10','2017-12-01 17:15:10'),
	(11,'000001',0,'[{"machine_info": [{"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:15:14','2017-12-01 17:15:14'),
	(12,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:15:36','2017-12-01 17:15:36'),
	(13,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:15:47','2017-12-01 17:15:47'),
	(19,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC00011", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:30:50','2017-12-01 17:30:50'),
	(21,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC00011", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:31:21','2017-12-01 17:31:21'),
	(23,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC000111", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:31:39','2017-12-01 17:31:39'),
	(24,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC00011", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-01 17:31:50','2017-12-01 17:31:50'),
	(26,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-04 09:59:21','2017-12-04 09:59:21'),
	(27,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-04 10:00:35','2017-12-04 10:00:35'),
	(28,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC 0001", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-04 10:01:35','2017-12-04 10:01:35'),
	(29,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC 0001", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-04 10:01:42','2017-12-04 10:01:42'),
	(30,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-04 10:02:02','2017-12-04 10:02:02'),
	(31,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-04 10:26:56','2017-12-04 10:26:56'),
	(32,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2017-12-04 10:26:59','2017-12-04 10:26:59'),
	(33,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2017-12-04 10:35:19','2017-12-04 10:35:19'),
	(34,'000001',1,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]',1,null,null,'2017-12-04 11:03:52','2017-12-04 11:04:00'),
	(35,'000001',1,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]',1,null,null,'2017-12-04 11:05:24','2017-12-04 11:05:26'),
	(36,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-04 14:16:18','2017-12-04 14:16:18'),
	(2,'009999',1,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,15,'2017-12-01 16:35:02','2018-11-29 13:30:49'),
	(37,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2017-12-04 14:16:42','2017-12-04 14:16:42'),
	(38,'000001',-1,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "11"}], "device_edge_no": 1, "device_edge_status": -1}]',1,null,null,'2017-12-05 16:21:47','2017-12-05 16:21:47'),
	(39,'000001',-2,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "20"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "33"}], "device_edge_no": 1, "device_edge_status": -2}]',1,null,null,'2017-12-05 16:22:00','2017-12-05 16:22:00'),
	(40,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2017-12-05 16:34:13','2017-12-05 16:34:13'),
	(41,'000001',0,'[{"machine_info": [{"machine_no": "026MTDあ0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-05 16:45:44','2017-12-05 16:45:44'),
	(42,'111111',0,'[{"machine_info": [{"machine_no": "026MTDあ0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-06 13:44:28','2017-12-06 13:44:28'),
	(43,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-26 12:52:36','2017-12-26 12:52:36'),
	(44,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2017-12-26 12:57:15','2017-12-26 12:57:15'),
	(45,'000002',2,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 2}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 2}]',1,null,null,'2017-12-26 13:11:30','2017-12-26 13:54:30'),
	(46,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2017-12-26 13:13:45','2017-12-26 13:13:45'),
	(47,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001a", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-26 13:15:01','2017-12-26 13:15:01'),
	(48,'000001',0,'[{"machine_info": [{"machine_no": "001 TDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-26 13:15:23','2017-12-26 13:15:23'),
	(49,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001 TDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 13:18:04','2017-12-26 13:18:04'),
	(50,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001 TDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 13:20:04','2017-12-26 13:20:04'),
	(51,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 13:21:04','2017-12-26 13:21:04'),
	(126,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-03-29 22:11:02','2018-03-29 22:11:02'),
	(52,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001 TDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 13:23:34','2017-12-26 13:23:34'),
	(53,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 13:34:34','2017-12-26 13:34:34'),
	(54,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001 TDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 13:34:34','2017-12-26 13:34:34'),
	(55,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001 TDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:16:42','2017-12-26 14:16:42'),
	(56,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:16:42','2017-12-26 14:16:42'),
	(57,'000001',0,'[{"machine_info": [{"machine_no": "001 TDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2017-12-26 14:18:09','2017-12-26 14:18:09'),
	(58,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001 TDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:19:12','2017-12-26 14:19:12'),
	(60,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:19:12','2017-12-26 14:19:12'),
	(61,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:20:42','2017-12-26 14:20:42'),
	(63,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:25:26','2017-12-26 14:25:26'),
	(66,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:27:26','2017-12-26 14:27:26'),
	(68,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:30:31','2017-12-26 14:30:31'),
	(69,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 14:32:00','2017-12-26 14:32:00'),
	(71,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:14:32','2017-12-26 17:14:32'),
	(72,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:14:32','2017-12-26 17:14:32'),
	(74,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:16:38','2017-12-26 17:16:38'),
	(75,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:16:38','2017-12-26 17:16:38'),
	(78,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:18:50','2017-12-26 17:18:50'),
	(79,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:18:50','2017-12-26 17:18:50'),
	(80,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:20:45','2017-12-26 17:20:45'),
	(81,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:20:45','2017-12-26 17:20:45'),
	(83,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:24:25','2017-12-26 17:24:25'),
	(85,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2017-12-26 17:24:25','2017-12-26 17:24:25'),
	(87,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-01-15 18:03:34','2018-01-15 18:03:34'),
	(88,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-01-15 18:03:34','2018-01-15 18:03:34'),
	(89,'000001',1,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2018-01-26 10:13:19','2018-01-26 10:13:21'),
	(90,'000001',1,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2018-01-26 10:29:10','2018-01-26 10:29:13'),
	(91,'000001',2,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "10"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "01"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "10"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "01"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "01"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "01"}], "device_edge_no": 1, "device_edge_status": 2}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2018-01-26 10:44:07','2018-01-26 10:47:05'),
	(92,'000001',2,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "10"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "10"}], "device_edge_no": 1, "device_edge_status": 2}]',1,null,null,'2018-01-26 10:49:53','2018-01-26 10:50:44'),
	(94,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-01-26 13:00:00','2018-01-26 13:00:00'),
	(95,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-01-26 13:25:00','2018-01-26 13:25:00'),
	(96,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-01-30 13:33:50','2018-01-30 13:33:50'),
	(97,'000002',0,'[{"machine_info": [{"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-01-30 13:33:50','2018-01-30 13:33:50'),
	(102,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-01-31 13:00:03','2018-01-31 13:00:03'),
	(103,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-01-31 13:25:03','2018-01-31 13:25:03'),
	(107,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-01 13:00:25','2018-02-01 13:00:25'),
	(108,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-01 13:25:25','2018-02-01 13:25:25'),
	(109,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-09 18:17:12','2018-02-09 18:17:12'),
	(110,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-09 18:17:12','2018-02-09 18:17:12'),
	(113,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-09 18:24:55','2018-02-09 18:24:55'),
	(114,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-09 18:24:55','2018-02-09 18:24:55'),
	(115,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-14 17:34:53','2018-02-14 17:34:53'),
	(117,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-14 17:34:53','2018-02-14 17:34:53'),
	(118,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2018-02-14 17:42:15','2018-02-14 17:42:15'),
	(119,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2018-02-14 17:42:56','2018-02-14 17:42:56'),
	(120,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2018-02-15 09:51:42','2018-02-15 09:51:42'),
	(121,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',1,null,null,'2018-02-15 09:54:28','2018-02-15 09:54:28'),
	(122,'000001',0,'[{"machine_info": [{"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}]',1,null,null,'2018-02-15 09:54:40','2018-02-15 09:54:40'),
	(124,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-15 13:00:06','2018-02-15 13:00:06'),
	(125,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-02-15 13:25:06','2018-02-15 13:25:06'),
	(127,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-03-29 22:11:02','2018-03-29 22:11:02'),
	(130,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-03-29 22:25:37','2018-03-29 22:25:37'),
	(131,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-03-29 22:25:37','2018-03-29 22:25:37'),
	(132,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-03-30 19:17:45','2018-03-30 19:17:45'),
	(134,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-03-30 19:17:45','2018-03-30 19:17:45'),
	(136,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-03-31 13:00:16','2018-03-31 13:00:16'),
	(137,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-03-31 13:25:16','2018-03-31 13:25:16'),
	(139,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-01 13:00:18','2018-04-01 13:00:18'),
	(140,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-01 13:25:18','2018-04-01 13:25:18'),
	(142,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 13:00:20','2018-04-02 13:00:20'),
	(143,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 13:25:20','2018-04-02 13:25:20'),
	(145,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 20:40:49','2018-04-02 20:40:49'),
	(146,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 20:40:49','2018-04-02 20:40:49'),
	(148,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 20:47:01','2018-04-02 20:47:01'),
	(149,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 20:47:01','2018-04-02 20:47:01'),
	(151,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 20:49:45','2018-04-02 20:49:45'),
	(152,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 20:49:45','2018-04-02 20:49:45'),
	(154,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 21:06:18','2018-04-02 21:06:18'),
	(155,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-02 21:06:18','2018-04-02 21:06:18'),
	(159,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-03 13:00:01','2018-04-03 13:00:01'),
	(160,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-03 13:25:01','2018-04-03 13:25:01'),
	(162,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-04 13:00:03','2018-04-04 13:00:03'),
	(163,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-04 13:25:03','2018-04-04 13:25:03'),
	(165,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 13:00:05','2018-04-05 13:00:05'),
	(166,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 13:25:05','2018-04-05 13:25:05'),
	(167,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 21:37:50','2018-04-05 21:37:50'),
	(169,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 21:37:50','2018-04-05 21:37:50'),
	(171,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 21:44:59','2018-04-05 21:44:59'),
	(172,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 21:44:59','2018-04-05 21:44:59'),
	(173,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 21:56:11','2018-04-05 21:56:11'),
	(174,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 21:56:11','2018-04-05 21:56:11'),
	(176,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 21:59:01','2018-04-05 21:59:01'),
	(178,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-05 21:59:01','2018-04-05 21:59:01'),
	(180,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-06 13:00:02','2018-04-06 13:00:02'),
	(181,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-06 13:25:02','2018-04-06 13:25:02'),
	(183,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-07 13:00:05','2018-04-07 13:00:05'),
	(184,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-07 13:25:05','2018-04-07 13:25:05'),
	(186,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-08 13:00:07','2018-04-08 13:00:07'),
	(187,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-08 13:25:07','2018-04-08 13:25:07'),
	(189,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-09 13:00:09','2018-04-09 13:00:09'),
	(190,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-09 13:25:09','2018-04-09 13:25:09'),
	(192,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-10 13:00:11','2018-04-10 13:00:11'),
	(193,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-10 13:25:11','2018-04-10 13:25:11'),
	(195,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-11 13:00:13','2018-04-11 13:00:13'),
	(196,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-11 13:25:13','2018-04-11 13:25:13'),
	(198,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-12 13:00:15','2018-04-12 13:00:15'),
	(199,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-12 13:25:15','2018-04-12 13:25:15'),
	(201,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-13 13:00:17','2018-04-13 13:00:17'),
	(202,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-13 13:25:17','2018-04-13 13:25:17'),
	(204,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-14 13:00:19','2018-04-14 13:00:19'),
	(205,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-14 13:25:19','2018-04-14 13:25:19'),
	(207,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-15 13:00:21','2018-04-15 13:00:21'),
	(208,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-15 13:25:21','2018-04-15 13:25:21'),
	(210,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-16 13:00:23','2018-04-16 13:00:23'),
	(211,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-16 13:25:23','2018-04-16 13:25:23'),
	(213,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-17 13:00:25','2018-04-17 13:00:25'),
	(214,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-17 13:25:25','2018-04-17 13:25:25'),
	(216,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-18 13:00:27','2018-04-18 13:00:27'),
	(217,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-18 13:25:27','2018-04-18 13:25:27'),
	(219,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-19 13:00:29','2018-04-19 13:00:29'),
	(220,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-19 13:25:29','2018-04-19 13:25:29'),
	(222,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-20 13:00:01','2018-04-20 13:00:01'),
	(223,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-20 13:25:01','2018-04-20 13:25:01'),
	(224,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-24 16:10:35','2018-04-24 16:10:35'),
	(226,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-24 16:10:35','2018-04-24 16:10:35'),
	(228,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-26 15:16:19','2018-04-26 15:16:19'),
	(230,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-26 15:16:19','2018-04-26 15:16:19'),
	(232,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-27 13:00:29','2018-04-27 13:00:29'),
	(233,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-04-27 13:25:29','2018-04-27 13:25:29'),
	(234,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-08 16:40:36','2018-05-08 16:40:36'),
	(235,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-08 16:40:36','2018-05-08 16:40:36'),
	(238,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-17 13:00:13','2018-05-17 13:00:13'),
	(239,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-17 13:25:13','2018-05-17 13:25:13'),
	(241,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-18 13:00:15','2018-05-18 13:00:15'),
	(242,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-18 13:25:15','2018-05-18 13:25:15'),
	(244,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-19 13:00:17','2018-05-19 13:00:17'),
	(245,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-19 13:25:17','2018-05-19 13:25:17'),
	(247,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-20 13:00:19','2018-05-20 13:00:19'),
	(248,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-20 13:25:19','2018-05-20 13:25:19'),
	(250,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-21 13:00:21','2018-05-21 13:00:21'),
	(251,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-21 13:25:21','2018-05-21 13:25:21'),
	(253,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-22 13:00:23','2018-05-22 13:00:23'),
	(254,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-22 13:25:23','2018-05-22 13:25:23'),
	(256,'000001',0,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0002 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0003 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0004 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0005 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0006 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0007 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0008 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0009 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0010 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0011 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0012 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0013 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0014 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0015 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0016 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0017 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0018 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0019 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0020 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0021 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0022 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0023 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0024 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0025 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0026 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0027 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0028 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0029 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0030 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0031 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0032 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0033 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0034 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0035 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0036 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0037 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0038 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0039 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0040 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0041 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0042 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0043 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0044 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0045 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0046 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0047 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0048 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0049 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC0050 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0051 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0052 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0053 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0054 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0055 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0056 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0057 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0058 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0059 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0060 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0061 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0062 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0063 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0064 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0065 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0066 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0067 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0068 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0069 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0070 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0071 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0072 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0073 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0074 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0075 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0076 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0077 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0078 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0079 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0080 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0081 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0082 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0083 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0084 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0085 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0086 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0087 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0088 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0089 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0090 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0091 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0092 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0093 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0094 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0095 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0096 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0097 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0098 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0099 ", "machine_err_cd": "00"}, {"machine_no": "026MTDC0100 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC1201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-23 13:00:25','2018-05-23 13:00:25'),
	(257,'000002',0,'[{"machine_info": [{"machine_no": "001M00000002", "machine_err_cd": "00"}, {"machine_no": "001C0000001 ", "machine_err_cd": "00"}, {"machine_no": "001ITDC2101 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 0}, {"machine_info": [{"machine_no": "001ITDC2201 ", "machine_err_cd": "00"}], "device_edge_no": 2, "device_edge_status": 0}]',0,null,null,'2018-05-23 13:25:25','2018-05-23 13:25:25'),
	(1,'009999',1,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]',1,null,11,'2017-12-01 16:33:48','2018-11-29 11:44:18'),
	(999,'009999',2,'[{"machine_info": [{"machine_no": "001M00000A3 ", "machine_err_cd": "00"}, {"machine_no": "999M1234567 ", "machine_err_cd": "00"}], "device_edge_no": 1, "device_edge_status": 1}]',0,null,6,'2018-11-29 11:00:18','2018-11-29 11:00:18')
;

-- 装置状態管理
TRUNCATE TABLE mnt_machine_state;
INSERT INTO mnt_machine_state (facility_cd, machine_type_cd, machine_serial, model, machine_name, bed_cd, bed_name, process_state, m_notice_cnt, preventive_mainte_cnt, is_preventive_mainte, use_time, machine_status, alarm_moni, is_offline, ord_no, next_ord_no, pat_id, next_patid, next_kur_cd, start_plan_date, end_plan_date, weigh_before_date, cond_send_date, cond_set_date, start_date, end_date, weigh_after_date, alarm_list,  reg_date, up_date) VALUES 
	('000002','001','00000002',null,'装置202',1,'ベッド１','04',1,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'2018-01-31 16:06:03','2018-01-31 16:06:03'),
	('000002','001','0000001',null,'装置201',2,'ベッド２','03',0,1,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'2018-01-31 16:06:03','2018-01-31 16:06:03'),
	('000002','001','TDC2101',null,'装置202',3,'ベッド３','02',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000002','001','TDC2201',null,'装置203',4,'ベッド４','01',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000001','001','00000001',null,'テストマシン1',null,null,'01',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000002','003','00000003',null,'テストマシン3',null,null,'03',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000003','001','00999903',null,'装置004',9903,'ベッドA7','10',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000003','004','00000099',null,'RO装置',1,'ベッドA1','04',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000003','005','00999802',null,'DAB1',9802,'ベッドA2','05',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000003','006','00999803',null,'DAD1',9803,'ベッドA3','06',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000003','007','00999804',null,'装置001',9804,'ベッドA4','07',0,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000003','008','00999901',null,'装置002',9901,'ベッドA5','08',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000003','009','00999902',null,'装置003',9902,'ベッドA6','09',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000003','011','00999904',null,'装置005',9904,'ベッドA8','11',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000011','012','00999904',null,'装置006',9905,'ベッドA9','20',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000012','013','00999904',null,'装置007',9906,'ベッドA10','21',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000013','014','00999904',null,'装置008',9907,'ベッドA11','22',0,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000014','015','00999904',null,'装置009',9908,'ベッドA12','23',0,1,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000015','016','00999904',null,'装置010',9909,'ベッドA13','24',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000016','017','00999904',null,'装置011',9910,'ベッドA14','25',2,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000017','018','00999904',null,'装置012',9911,'ベッドA15','26',3,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000018','019','00999904',null,'装置013',9912,'ベッドB01','27',0,5,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000019','020','00999904',null,'装置014',9913,'ベッドB02','28',1,1,5,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000020','021','00999904',null,'装置015',9914,'ベッドB03','29',0,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000021','022','00999904',null,'装置016',9915,'ベッドB04','40',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000022','023','00999904',null,'装置017',9916,'ベッドB05','41',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000023','024','00999904',null,'装置018',9917,'ベッドB06','42',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000024','025','00999904',null,'装置018',9918,'ベッドB07','43',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000025','026','00999904',null,'装置019',9919,'ベッドB08','44',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000026','027','00999904',null,'装置020',9920,'ベッドB09','45',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000027','001','00999904',null,'装置021',9921,'ベッドB10','46',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000028','002','00999904',null,'装置022',9922,'ベッドB11','60',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000029','003','00999904',null,'装置023',9923,'ベッドB12','61',1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000030','004','00999904',null,'装置024',9924,'ベッドC01','62',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','029','00999904',null,'装置034',9904,'ベッドC11','99',0,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0011',null,'テスト装置11',11,'ベッド_011','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0012',null,'テスト装置12',12,'ベッド_012','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0013',null,'テスト装置13',13,'ベッド_013','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0014',null,'テスト装置14',14,'ベッド_014','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0015',null,'テスト装置15',15,'ベッド_015','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0016',null,'テスト装置16',16,'ベッド_016','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0017',null,'テスト装置17',17,'ベッド_017','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0018',null,'テスト装置18',18,'ベッド_018','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0019',null,'テスト装置19',19,'ベッド_019','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0020',null,'テスト装置20',20,'ベッド_020','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','025','ESM0003',null,'テスト装置3',3,'ベッド_003','04',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','009','00999804',null,'装置029',9804,'ベッドC06','99',0,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0006',null,'テスト装置6',6,'ベッド_006','07',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0007',null,'テスト装置7',7,'ベッド_007','08',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0008',null,'テスト装置8',8,'ベッド_008','09',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0009',null,'テスト装置9',9,'ベッド_009','10',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0010',null,'テスト装置10',10,'ベッド_010','11',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','025','00000099',null,'装置030',1,'ベッドC07','06',0,3,1,'{"0": 100, "1": 101, "2": 102, "3": 103, "4": 104, "5": 105, "6": 106, "7": 107, "8": 108, "9": 109, "10": 110, "11": 111, "12": 112, "13": 113, "14": 114, "15": 115, "16": 116, "17": 117, "18": 118, "19": 119, "20": 120, "21": 121, "22": 122, "23": 123, "24": 124, "25": 125, "26": 126, "27": 127, "28": 128, "29": 129, "30": 130, "31": 131, "32": 132, "33": 133, "34": 134, "35": 135}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','008','00999803',null,'装置028',9803,'ベッドC05','99',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','007','00999802',null,'装置027',9802,'ベッドC04','65',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','006','00999801',null,'装置026',9801,'ベッドC03','64',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','005','00000098',null,'装置025',2,'ベッドC02','63',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0005',null,'テスト装置5',5,'ベッド_005','06',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0004',null,'テスト装置4',4,'ベッド_004','05',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0021',null,'テスト装置21',21,'ベッド_021','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0022',null,'テスト装置22',22,'ベッド_022','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0023',null,'テスト装置23',23,'ベッド_023','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0024',null,'テスト装置24',24,'ベッド_024','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0025',null,'テスト装置25',25,'ベッド_025','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('900002','902','90000005',null,null,null,null,null,0,1,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','025','ESM0001',null,'テスト装置1',1,'ベッド_001','02',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','025','ESM0002',null,'テスト装置2',2,'ベッド_002','03',0,0,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0026',null,'テスト装置26',26,'ベッド_026','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0027',null,'テスト装置27',27,'ベッド_027','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0028',null,'テスト装置28',28,'ベッド_028','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0029',null,'テスト装置29',29,'ベッド_029','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0030',null,'テスト装置30',30,'ベッド_030','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0031',null,'テスト装置31',31,'ベッド_031','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0032',null,'テスト装置32',32,'ベッド_032','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0033',null,'テスト装置33',33,'ベッド_033','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0034',null,'テスト装置34',34,'ベッド_034','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0035',null,'テスト装置35',35,'ベッド_035','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0036',null,'テスト装置36',36,'ベッド_036','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0037',null,'テスト装置37',37,'ベッド_037','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0038',null,'テスト装置38',38,'ベッド_038','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0039',null,'テスト装置39',39,'ベッド_039','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0040',null,'テスト装置40',40,'ベッド_040','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0041',null,'テスト装置41',41,'ベッド_041','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0042',null,'テスト装置42',42,'ベッド_042','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0043',null,'テスト装置43',43,'ベッド_043','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0044',null,'テスト装置44',44,'ベッド_044','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0045',null,'テスト装置45',45,'ベッド_045','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0046',null,'テスト装置46',46,'ベッド_046','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0047',null,'テスト装置47',47,'ベッド_047','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0048',null,'テスト装置48',48,'ベッド_048','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0049',null,'テスト装置49',49,'ベッド_049','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0050',null,'テスト装置50',50,'ベッド_050','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0051',null,'テスト装置51',51,'ベッド_051','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0052',null,'テスト装置52',52,'ベッド_052','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0053',null,'テスト装置53',53,'ベッド_053','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0054',null,'テスト装置54',54,'ベッド_054','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0055',null,'テスト装置55',55,'ベッド_055','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0056',null,'テスト装置56',56,'ベッド_056','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0057',null,'テスト装置57',57,'ベッド_057','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0058',null,'テスト装置58',58,'ベッド_058','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0059',null,'テスト装置59',59,'ベッド_059','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0060',null,'テスト装置60',60,'ベッド_060','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0061',null,'テスト装置61',61,'ベッド_061','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0062',null,'テスト装置62',62,'ベッド_062','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0063',null,'テスト装置63',63,'ベッド_063','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0064',null,'テスト装置64',64,'ベッド_064','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0065',null,'テスト装置65',65,'ベッド_065','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0066',null,'テスト装置66',66,'ベッド_066','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0067',null,'テスト装置67',67,'ベッド_067','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0068',null,'テスト装置68',68,'ベッド_068','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0069',null,'テスト装置69',69,'ベッド_069','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0070',null,'テスト装置70',70,'ベッド_070','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0071',null,'テスト装置71',71,'ベッド_071','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0072',null,'テスト装置72',72,'ベッド_072','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0073',null,'テスト装置73',73,'ベッド_073','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0074',null,'テスト装置74',74,'ベッド_074','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0075',null,'テスト装置75',75,'ベッド_075','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0076',null,'テスト装置76',76,'ベッド_076','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0077',null,'テスト装置77',77,'ベッド_077','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0078',null,'テスト装置78',78,'ベッド_078','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0079',null,'テスト装置79',79,'ベッド_079','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0080',null,'テスト装置80',80,'ベッド_080','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0081',null,'テスト装置81',81,'ベッド_081','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0082',null,'テスト装置82',82,'ベッド_082','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0083',null,'テスト装置83',83,'ベッド_083','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0084',null,'テスト装置84',84,'ベッド_084','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0085',null,'テスト装置85',85,'ベッド_085','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0086',null,'テスト装置86',86,'ベッド_086','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0087',null,'テスト装置87',87,'ベッド_087','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0088',null,'テスト装置88',88,'ベッド_088','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0089',null,'テスト装置89',89,'ベッド_089','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0090',null,'テスト装置90',90,'ベッド_090','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0091',null,'テスト装置91',91,'ベッド_091','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0092',null,'テスト装置92',92,'ベッド_092','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0093',null,'テスト装置93',93,'ベッド_093','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0094',null,'テスト装置94',94,'ベッド_094','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0095',null,'テスト装置95',95,'ベッド_095','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0096',null,'テスト装置96',96,'ベッド_096','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0097',null,'テスト装置97',97,'ベッド_097','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0098',null,'テスト装置98',98,'ベッド_098','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0099',null,'テスト装置99',99,'ベッド_099','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0100',null,'テスト装置100',100,'ベッド_100','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0101',null,'テスト装置101',101,'ベッド_101','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0102',null,'テスト装置102',102,'ベッド_102','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0103',null,'テスト装置103',103,'ベッド_103','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0104',null,'テスト装置104',104,'ベッド_104','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0105',null,'テスト装置105',105,'ベッド_105','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0106',null,'テスト装置106',106,'ベッド_106','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0107',null,'テスト装置107',107,'ベッド_107','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0108',null,'テスト装置108',108,'ベッド_108','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0109',null,'テスト装置109',109,'ベッド_109','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0110',null,'テスト装置110',110,'ベッド_110','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0111',null,'テスト装置111',111,'ベッド_111','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0112',null,'テスト装置112',112,'ベッド_112','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0113',null,'テスト装置113',113,'ベッド_113','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0114',null,'テスト装置114',114,'ベッド_114','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0115',null,'テスト装置115',115,'ベッド_115','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0116',null,'テスト装置116',116,'ベッド_116','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0117',null,'テスト装置117',117,'ベッド_117','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0118',null,'テスト装置118',118,'ベッド_118','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0119',null,'テスト装置119',119,'ベッド_119','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0120',null,'テスト装置120',120,'ベッド_120','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0121',null,'テスト装置121',121,'ベッド_121','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0122',null,'テスト装置122',122,'ベッド_122','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0123',null,'テスト装置123',123,'ベッド_123','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0124',null,'テスト装置124',124,'ベッド_124','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0125',null,'テスト装置125',125,'ベッド_125','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0126',null,'テスト装置126',126,'ベッド_126','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0127',null,'テスト装置127',127,'ベッド_127','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0128',null,'テスト装置128',128,'ベッド_128','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0129',null,'テスト装置129',129,'ベッド_129','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0130',null,'テスト装置130',130,'ベッド_130','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0131',null,'テスト装置131',131,'ベッド_131','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0132',null,'テスト装置132',132,'ベッド_132','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0133',null,'テスト装置133',133,'ベッド_133','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0134',null,'テスト装置134',134,'ベッド_134','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0135',null,'テスト装置135',135,'ベッド_135','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0136',null,'テスト装置136',136,'ベッド_136','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0137',null,'テスト装置137',137,'ベッド_137','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0138',null,'テスト装置138',138,'ベッド_138','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0139',null,'テスト装置139',139,'ベッド_139','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0140',null,'テスト装置140',140,'ベッド_140','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0141',null,'テスト装置141',141,'ベッド_141','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0142',null,'テスト装置142',142,'ベッド_142','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0143',null,'テスト装置143',143,'ベッド_143','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0144',null,'テスト装置144',144,'ベッド_144','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0145',null,'テスト装置145',145,'ベッド_145','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0146',null,'テスト装置146',146,'ベッド_146','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0147',null,'テスト装置147',147,'ベッド_147','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0148',null,'テスト装置148',148,'ベッド_148','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0149',null,'テスト装置149',149,'ベッド_149','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0150',null,'テスト装置150',150,'ベッド_150','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0151',null,'テスト装置151',151,'ベッド_151','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0152',null,'テスト装置152',152,'ベッド_152','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0153',null,'テスト装置153',153,'ベッド_153','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0154',null,'テスト装置154',154,'ベッド_154','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0155',null,'テスト装置155',155,'ベッド_155','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0156',null,'テスト装置156',156,'ベッド_156','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0157',null,'テスト装置157',157,'ベッド_157','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0158',null,'テスト装置158',158,'ベッド_158','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0159',null,'テスト装置159',159,'ベッド_159','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0160',null,'テスト装置160',160,'ベッド_160','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0161',null,'テスト装置161',161,'ベッド_161','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0162',null,'テスト装置162',162,'ベッド_162','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0163',null,'テスト装置163',163,'ベッド_163','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0164',null,'テスト装置164',164,'ベッド_164','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0165',null,'テスト装置165',165,'ベッド_165','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0166',null,'テスト装置166',166,'ベッド_166','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0167',null,'テスト装置167',167,'ベッド_167','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0168',null,'テスト装置168',168,'ベッド_168','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0169',null,'テスト装置169',169,'ベッド_169','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0170',null,'テスト装置170',170,'ベッド_170','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0171',null,'テスト装置171',171,'ベッド_171','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0172',null,'テスト装置172',172,'ベッド_172','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0173',null,'テスト装置173',173,'ベッド_173','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0174',null,'テスト装置174',174,'ベッド_174','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0175',null,'テスト装置175',175,'ベッド_175','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0176',null,'テスト装置176',176,'ベッド_176','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0177',null,'テスト装置177',177,'ベッド_177','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0178',null,'テスト装置178',178,'ベッド_178','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0179',null,'テスト装置179',179,'ベッド_179','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0180',null,'テスト装置180',180,'ベッド_180','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0181',null,'テスト装置181',181,'ベッド_181','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0182',null,'テスト装置182',182,'ベッド_182','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0183',null,'テスト装置183',183,'ベッド_183','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0184',null,'テスト装置184',184,'ベッド_184','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0185',null,'テスト装置185',185,'ベッド_185','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0186',null,'テスト装置186',186,'ベッド_186','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0187',null,'テスト装置187',187,'ベッド_187','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0188',null,'テスト装置188',188,'ベッド_188','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0189',null,'テスト装置189',189,'ベッド_189','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0190',null,'テスト装置190',190,'ベッド_190','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0191',null,'テスト装置191',191,'ベッド_191','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0192',null,'テスト装置192',192,'ベッド_192','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0193',null,'テスト装置193',193,'ベッド_193','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0194',null,'テスト装置194',194,'ベッド_194','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0195',null,'テスト装置195',195,'ベッド_195','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0196',null,'テスト装置196',196,'ベッド_196','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0197',null,'テスト装置197',197,'ベッド_197','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0198',null,'テスト装置198',198,'ベッド_198','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0199',null,'テスト装置199',199,'ベッド_199','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0200',null,'テスト装置200',200,'ベッド_200','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0201',null,'テスト装置201',201,'ベッド_201','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0202',null,'テスト装置202',202,'ベッド_202','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0203',null,'テスト装置203',203,'ベッド_203','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0204',null,'テスト装置204',204,'ベッド_204','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0205',null,'テスト装置205',205,'ベッド_205','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0206',null,'テスト装置206',206,'ベッド_206','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0207',null,'テスト装置207',207,'ベッド_207','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0208',null,'テスト装置208',208,'ベッド_208','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0209',null,'テスト装置209',209,'ベッド_209','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0210',null,'テスト装置210',210,'ベッド_210','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0211',null,'テスト装置211',211,'ベッド_211','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0212',null,'テスト装置212',212,'ベッド_212','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0213',null,'テスト装置213',213,'ベッド_213','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0214',null,'テスト装置214',214,'ベッド_214','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0215',null,'テスト装置215',215,'ベッド_215','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0216',null,'テスト装置216',216,'ベッド_216','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0217',null,'テスト装置217',217,'ベッド_217','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0218',null,'テスト装置218',218,'ベッド_218','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0219',null,'テスト装置219',219,'ベッド_219','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0220',null,'テスト装置220',220,'ベッド_220','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0221',null,'テスト装置221',221,'ベッド_221','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0222',null,'テスト装置222',222,'ベッド_222','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0223',null,'テスト装置223',223,'ベッド_223','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0224',null,'テスト装置224',224,'ベッド_224','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0225',null,'テスト装置225',225,'ベッド_225','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0226',null,'テスト装置226',226,'ベッド_226','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0227',null,'テスト装置227',227,'ベッド_227','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0228',null,'テスト装置228',228,'ベッド_228','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0229',null,'テスト装置229',229,'ベッド_229','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0230',null,'テスト装置230',230,'ベッド_230','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0231',null,'テスト装置231',231,'ベッド_231','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0232',null,'テスト装置232',232,'ベッド_232','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0233',null,'テスト装置233',233,'ベッド_233','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0234',null,'テスト装置234',234,'ベッド_234','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0235',null,'テスト装置235',235,'ベッド_235','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0236',null,'テスト装置236',236,'ベッド_236','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0237',null,'テスト装置237',237,'ベッド_237','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0238',null,'テスト装置238',238,'ベッド_238','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0239',null,'テスト装置239',239,'ベッド_239','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0240',null,'テスト装置240',240,'ベッド_240','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0241',null,'テスト装置241',241,'ベッド_241','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0242',null,'テスト装置242',242,'ベッド_242','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0243',null,'テスト装置243',243,'ベッド_243','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0244',null,'テスト装置244',244,'ベッド_244','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0245',null,'テスト装置245',245,'ベッド_245','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0246',null,'テスト装置246',246,'ベッド_246','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0247',null,'テスト装置247',247,'ベッド_247','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0248',null,'テスト装置248',248,'ベッド_248','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0249',null,'テスト装置249',249,'ベッド_249','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0250',null,'テスト装置250',250,'ベッド_250','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0251',null,'テスト装置251',251,'ベッド_251','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0252',null,'テスト装置252',252,'ベッド_252','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0253',null,'テスト装置253',253,'ベッド_253','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0254',null,'テスト装置254',254,'ベッド_254','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0255',null,'テスト装置255',255,'ベッド_255','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0256',null,'テスト装置256',256,'ベッド_256','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0257',null,'テスト装置257',257,'ベッド_257','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0258',null,'テスト装置258',258,'ベッド_258','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0259',null,'テスト装置259',259,'ベッド_259','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0260',null,'テスト装置260',260,'ベッド_260','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0261',null,'テスト装置261',261,'ベッド_261','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0262',null,'テスト装置262',262,'ベッド_262','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0263',null,'テスト装置263',263,'ベッド_263','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0264',null,'テスト装置264',264,'ベッド_264','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0265',null,'テスト装置265',265,'ベッド_265','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0266',null,'テスト装置266',266,'ベッド_266','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0267',null,'テスト装置267',267,'ベッド_267','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0268',null,'テスト装置268',268,'ベッド_268','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0269',null,'テスト装置269',269,'ベッド_269','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0270',null,'テスト装置270',270,'ベッド_270','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0271',null,'テスト装置271',271,'ベッド_271','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0272',null,'テスト装置272',272,'ベッド_272','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0273',null,'テスト装置273',273,'ベッド_273','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0274',null,'テスト装置274',274,'ベッド_274','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0275',null,'テスト装置275',275,'ベッド_275','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0276',null,'テスト装置276',276,'ベッド_276','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0277',null,'テスト装置277',277,'ベッド_277','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0278',null,'テスト装置278',278,'ベッド_278','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0279',null,'テスト装置279',279,'ベッド_279','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0280',null,'テスト装置280',280,'ベッド_280','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0281',null,'テスト装置281',281,'ベッド_281','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0282',null,'テスト装置282',282,'ベッド_282','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0283',null,'テスト装置283',283,'ベッド_283','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0284',null,'テスト装置284',284,'ベッド_284','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0285',null,'テスト装置285',285,'ベッド_285','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0286',null,'テスト装置286',286,'ベッド_286','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0287',null,'テスト装置287',287,'ベッド_287','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0288',null,'テスト装置288',288,'ベッド_288','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0289',null,'テスト装置289',289,'ベッド_289','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0290',null,'テスト装置290',290,'ベッド_290','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0291',null,'テスト装置291',291,'ベッド_291','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0292',null,'テスト装置292',292,'ベッド_292','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0293',null,'テスト装置293',293,'ベッド_293','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0294',null,'テスト装置294',294,'ベッド_294','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0295',null,'テスト装置295',295,'ベッド_295','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0296',null,'テスト装置296',296,'ベッド_296','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0297',null,'テスト装置297',297,'ベッド_297','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0298',null,'テスト装置298',298,'ベッド_298','99',0,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0299',null,'テスト装置299',299,'ベッド_299','99',0,0,0,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000007','025','ESM0300',null,'テスト装置300',300,'ベッド_300','99',0,0,0,null,null,null,2,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','028','00999903',null,'装置033',9903,'ベッドC10','43',0,0,0,'{"1": 101, "2": 102, "3": 1000, "4": 988, "5": 209, "6": 1064, "7": 397, "8": 108}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('900001','901','90000001',null,null,null,null,null,1,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('900001','901','90000002',null,null,null,null,null,1,2,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('900001','901','90000003',null,null,null,null,null,1,3,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('900002','902','90000004',null,null,null,null,null,2,0,0,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('999900','025','TDC0002',null,'テスト装置',1,'ベッド','01',0,0,0,'{"1": 101, "2": 102, "3": 1000, "4": 988, "5": 209, "6": 1064, "7": 397, "8": 108}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('999900','003','TDC0101',null,'TDCテスト装置',1,'ベッド001','01',0,0,0,'{"1": 101, "2": 102, "3": 1000, "4": 988, "5": 209, "6": 1064, "7": 397, "8": 108}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000004','025','TDC0002',null,'テスト装置',1,'ベッド','01',0,0,1,'{"1": 101, "2": 102, "3": 1000, "4": 988, "5": 209, "6": 1064, "7": 397, "8": 108}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000005','025','TDC0002',null,'テスト装置',1,'ベッド','01',0,1,0,'{"1": 101, "2": 102, "3": 1000, "4": 988, "5": 209, "6": 1064, "7": 397, "8": 108}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','027','00999902',null,'装置032',9902,'ベッドC09','11',0,1,1,'{"1": 101, "2": 102, "3": 103, "4": 104, "5": 105, "6": 106, "7": 107, "8": 108, "9": 109}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('000002','002','00000002',null,'テストマシン2',null,null,'02',0,1,1,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'2018-04-26 10:18:21.463',null),
	('009999','026','00999901',null,'装置031',9901,'ベッドC08','06',2,1,0,'{"1": 101, "2": 102, "3": 103, "4": 104, "5": 105, "6": 106, "7": 107, "8": 108, "9": 109, "10": 110, "11": 111, "12": 112, "13": 113, "14": 114, "15": 115, "16": 116, "17": 117}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
	('009999','011','00999901',null,'装置031',9901,'ベッドC08','06',2,1,0,'{"1": 101, "2": 102, "3": 103, "4": 104, "5": 105, "6": 106, "7": 107, "8": 108, "9": 109, "10": 110, "11": 111, "12": 112, "13": 113, "14": 114, "15": 115, "16": 116, "17": 117}',null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
;

-- 装置動作記録
TRUNCATE TABLE mnt_motion_record;
INSERT INTO mnt_motion_record (motion_record_no, event_reg_date, m_notice_status, facility_cd, device_edge_no, machine_type_cd, machine_serial, com_format_cd, data_type, test_type, gathering_manage_no, email_send_date, email_text, machine_record_cd, machine_record_message, contents, machine_record_aux_data, email_address, email_name, remarks, is_correction, user_id, ord_no, log_type, reg_date, up_date) VALUES 
	('21','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-21 17:01:39.255','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：ESM高原（会社）、ESM高原（携帯） ■稼働ビューア：[]
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-21 17:01:09.526','2018-06-21 17:01:39.26'),
	('999992','2018-06-10 15:02:22',1,'009999',1,'026','00999901',null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常２ー０５１７－２',null,'０　０　０　０','kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',19,null,null,null,null),
	('22','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-21 17:09:52.788','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：ESM高原（会社）、ESM高原（携帯） ■稼働ビューア：[]
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-21 17:09:43.171','2018-06-21 17:09:52.79'),
	('1002','2018-05-22 23:59:59.789',1,'009999',1,'026','00999901',null,5,null,null,null,null,null,'デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "6", "6": "280", "7": "160", "8": "41", "9": "180", "10": "40", "11": "23", "12": "0", "13": "1"}',null,null,null,null,null,null,null,null,null,null),
	('1091','2018-03-29 12:13:14',0,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,null,null,null,null,'2018-05-27 18:33:32.431','2018-05-27 18:33:32.431'),
	('1004','2018-05-24 23:59:59.789',1,'009999',1,'026','00999901',null,5,null,null,null,null,null,'デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "8", "6": "280", "7": "160", "8": "41", "9": "180", "10": "40", "11": "23", "12": "0", "13": "1"}',null,null,null,null,null,null,null,null,null,null),
	('1092','2018-03-29 12:13:14',0,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,null,null,null,null,'2018-05-27 19:19:00.864','2018-05-27 19:19:00.864'),
	('1093','2018-03-29 12:13:14',0,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,null,null,null,null,'2018-05-28 09:48:22.869','2018-05-28 09:48:22.869'),
	('36','1980-01-01 23:59:59',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('999815','2018-06-08 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('23','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-21 17:14:45.297','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：ESM高原（会社）、ESM高原（携帯） ■稼働ビューア：
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-21 17:14:35.329','2018-06-21 17:14:45.302'),
	('37','1980-01-01 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('38','1980-11-09 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('39','1980-11-09 00:00:01',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('40','1980-11-09 00:00:02',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('41','1980-11-08 23:59:59',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('42','1980-11-07 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('43','1980-11-06 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('44','1980-11-05 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('45','1980-11-04 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('46','1980-11-03 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('27','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-21 17:22:45.157','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：ESM高原（会社）、ESM高原（携帯） ■稼働ビューア：
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-21 17:22:35.373','2018-06-21 17:22:45.158'),
	('11','2018-05-30 11:04:55',-1,'999900',null,'025','TDC0001 ','I',2,null,null,null,null,'958A',null,null,'0,0,0,0',null,null,'取得できませんでした:装置マスタにレコードなし:[machine_type:025]、[machine_serial:TDC0001]、[facility_cd:999900]
通信種別エラー:[受信データ:303235495444433030303120393939393030201805301104553935384100000000000000009e]',null,null,null,null,'2018-06-11 18:04:40.004','2018-06-11 18:04:40.004'),
	('47','1980-11-02 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('1003','2018-05-23 23:59:59.789',1,'009999',1,'026','00999901',null,5,null,null,null,null,null,'デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "7", "6": "280", "7": "160", "8": "41", "9": "180", "10": "40", "11": "23", "12": "0", "13": "1"}',null,null,null,null,null,null,null,null,null,null),
	('12','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-11 18:05:41.676','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,null,null,null,null,'2018-06-11 18:05:36.484','2018-06-11 18:05:41.682'),
	('48','1980-11-01 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('13','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-11 18:06:15.285','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,null,null,null,null,'2018-06-11 18:06:11.036','2018-06-11 18:06:15.287'),
	('49','2009-09-09 19:09:09',null,'900001',null,'901','90000001',null,9,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('14','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-11 18:06:37.336','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,null,null,null,null,'2018-06-11 18:06:33.118','2018-06-11 18:06:37.338'),
	('50','2010-01-01 00:00:01',null,'900002',null,'902','90000002',null,1,null,null,null,null,null,null,'{"key1": "value1"}',null,null,null,null,null,null,null,null,null,null),
	('15','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-20 12:15:54.707','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,null,null,null,null,'2018-06-20 12:15:44.301','2018-06-20 12:15:54.713'),
	('51','2010-01-02 00:00:02',null,'900002',null,'902','90000002',null,2,null,null,null,null,null,null,'{"key2": "value2", "key3": "value3"}',null,null,null,null,null,null,null,null,null,null),
	('999995','2018-06-08 16:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,null,'G000','溶解記録','{"3": "0", "5": "16", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('53','1980-01-01 23:59:59',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('54','1980-01-01 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('55','1980-11-09 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('56','1980-11-09 00:00:01',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('57','1980-11-09 00:00:02',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('58','1980-11-08 23:59:59',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('59','1980-11-07 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('60','1980-11-06 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('61','1980-11-05 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('62','1980-11-04 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('63','1980-11-03 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('64','1980-11-02 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('65','1980-11-01 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('66','2009-09-09 19:09:09',null,'900001',null,'901','90000001',null,9,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('67','2010-01-01 00:00:01',null,'900002',null,'902','90000002',null,1,null,null,null,null,null,null,'{"key1": "value1"}',null,null,null,null,null,null,null,null,null,null),
	('68','2010-01-02 00:00:02',null,'900002',null,'902','90000002',null,2,null,null,null,null,null,null,'{"key2": "value2", "key3": "value3"}',null,null,null,null,null,null,null,null,null,null),
	('69','1980-01-01 23:59:59',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('70','1980-01-01 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('71','1980-11-09 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('72','1980-11-09 00:00:01',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('73','1980-11-09 00:00:02',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('74','1980-11-08 23:59:59',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('16','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-20 12:43:45.735','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 ■稼働ビューア：http://ntss-platform-public-app-alb02-743132961.ap-northeast-1.elb.amazonaws.com/ntss-admin-web/index.html?func=00103&facilityCd=000001&machineTypeCd=null&machineSerial=null
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,null,null,null,null,'2018-06-20 12:43:35.596','2018-06-20 12:43:45.745'),
	('999996','2018-06-08 17:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,null,'G000','溶解記録','{"3": "0", "5": "17", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('75','1980-11-07 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('30','2018-06-21 20:48:11',-1,'999900',null,'003','TDC0101 ','A',2,null,null,null,'メールテンプレート９０','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','取得できませんでした:装置状態管理にレコードなし:[facility_cd:999900]、[machineTypeCd:003]、[machineSerial:TDC0101]','',null,null,null,'2018-06-21 21:19:37.231','2018-06-21 21:19:37.231'),
	('76','1980-11-06 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('77','1980-11-05 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('29','2018-06-21 20:48:11',-1,'999900',null,'003','TDC0101 ','A',2,null,null,null,null,'958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32',null,null,'通信種別エラー:[受信データ:303033415444433031303120393939393030201806212048113935384100020030000300310033003300040034003000050031003000060032003000070020bd]','',null,null,null,'2018-06-21 21:18:50.954','2018-06-21 21:18:50.954'),
	('78','1980-11-04 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('79','1980-11-03 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('80','1980-11-02 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('32','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-06-21 21:22:19.551','関係者各位

　TDCクリニック2 の装置：TDCテスト装置でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：TDCクリニック2
　■装置名：TDCテスト装置
　■発生日時：2018/06/21 20:48:11
　■型式：DCS-27(I)
　■製造番号：TDC0101 
　■装置記録コード：958A
　■装置記録メッセージ：テストメッセージ
　■発報対象者名：ESM高原（会社）、ESM高原（携帯）
　
以上です。
よろしくお願い致します。','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,'',null,null,null,'2018-06-21 21:22:10.811','2018-06-21 21:22:19.552'),
	('81','1980-11-01 00:00:00',null,'900001',null,'901','90000001',null,1,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('82','2009-09-09 19:09:09',null,'900001',null,'901','90000001',null,9,null,null,null,null,null,null,'{"key": "value"}',null,null,null,null,null,null,null,null,null,null),
	('83','2010-01-01 00:00:01',null,'900002',null,'902','90000002',null,1,null,null,null,null,null,null,'{"key1": "value1"}',null,null,null,null,null,null,null,null,null,null),
	('84','2010-01-02 00:00:02',null,'900002',null,'902','90000002',null,2,null,null,null,null,null,null,'{"key2": "value2", "key3": "value3"}',null,null,null,null,null,null,null,null,null,null),
	('85','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-09-04 08:32:26.157','関係者各位

　TDCクリニック2 の装置：TDCテスト装置でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：TDCクリニック2
　■装置名：TDCテスト装置
　■発生日時：2018/06/21 20:48:11
　■型式：DCS-27(I)
　■製造番号：TDC0101 
　■装置記録コード：958A
　■装置記録メッセージ：テストメッセージ
　■発報対象者名：ESM高原（会社）、ESM高原（携帯）
　■稼働ビューア：
　
以上です。
よろしくお願い致します。','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-09-04 08:32:15.799','2018-09-04 08:32:26.162'),
	('999907','2018-05-19 23:59:59.789',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "6", "5": "2", "6": "210", "7": "290", "8": "35", "9": "160", "10": "26", "11": "38", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('4','2018-05-30 11:04:55',-1,'999900',null,'025','TDC0001','I',2,null,null,null,'メールテンプレート９０','958A','テストメッセージ',null,'0,0,0,0','k-takahara@esm.co.jp','','取得できませんでした:装置状態管理にレコードなし:[facility_cd:999900]、[machineTypeCd:025]、[machineSerial:TDC0001]',null,null,null,null,'2018-05-30 12:25:18.175','2018-05-30 12:25:18.175'),
	('5','2018-05-30 11:04:55',1,'999900',null,'025','TDC0001','I',2,null,null,'2018-05-30 12:27:15.353','メールテンプレート９０','958A','テストメッセージ',null,'0,0,0,0','k-takahara@esm.co.jp','',null,null,null,null,null,'2018-05-30 12:27:09.217','2018-05-30 12:27:15.358'),
	('6','2018-05-30 11:04:55',1,'999900',null,'025','TDC0001 ','I',2,null,null,'2018-05-31 09:19:05.338','メールテンプレート９０','958A','テストメッセージ',null,'0,0,0,0','k-takahara@esm.co.jp','',null,null,null,null,null,'2018-05-31 09:19:00.084','2018-05-31 09:19:05.342'),
	('7','2018-05-30 11:04:55',1,'999900',null,'025','TDC0001 ','I',2,null,null,'2018-05-31 11:53:12.773','メールテンプレート９０','958A','テストメッセージ',null,'0,0,0,0','k-takahara@esm.co.jp','',null,null,null,null,null,'2018-05-31 11:53:06.495','2018-05-31 11:53:12.778'),
	('8','2018-05-30 11:04:55',1,'999900',null,'025','TDC0001 ','I',2,null,null,'2018-05-31 11:54:38.709','メールテンプレート９０','958A','テストメッセージ',null,'0,0,0,0','k-takahara@esm.co.jp','',null,null,null,null,null,'2018-05-31 11:54:33.574','2018-05-31 11:54:38.713'),
	('9','2018-05-30 11:04:55',1,'999900',null,'025','TDC0001 ','I',2,null,null,'2018-05-31 11:55:27.196','メールテンプレート９０','958A','テストメッセージ',null,'0,0,0,0','k-takahara@esm.co.jp','',null,null,null,null,null,'2018-05-31 11:55:22.089','2018-05-31 11:55:27.201'),
	('999910','2018-05-18 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('86','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-09-04 15:58:58.806','関係者各位

　TDCクリニック2 の装置：TDCテスト装置でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：TDCクリニック2
　■装置名：TDCテスト装置
　■発生日時：2018/06/21 20:48:11
　■型式：DCS-27(I)
　■製造番号：TDC0101 
　■装置記録コード：958A
　■装置記録メッセージ：テストメッセージ
　■発報対象者名：ESM高原（会社）、ESM高原（携帯）
　■稼働ビューア：
　
以上です。
よろしくお願い致します。','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-09-04 15:58:46.518','2018-09-04 15:58:58.887'),
	('35','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-06-22 10:48:24.562','関係者各位

　TDCクリニック2 の装置：TDCテスト装置でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：TDCクリニック2
　■装置名：TDCテスト装置
　■発生日時：2018/06/21 20:48:11
　■型式：DCS-27(I)
　■製造番号：TDC0101 
　■装置記録コード：958A
　■装置記録メッセージ：テストメッセージ
　■発報対象者名：ESM高原（会社）、ESM高原（携帯）
　■稼働ビューア：
　
以上です。
よろしくお願い致します。','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-22 10:48:14.456','2018-06-22 10:48:24.566'),
	('87','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-09-04 16:06:43.257','関係者各位

　TDCクリニック2 の装置：TDCテスト装置でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：TDCクリニック2
　■装置名：TDCテスト装置
　■発生日時：2018/06/21 20:48:11
　■型式：DCS-27(I)
　■製造番号：TDC0101 
　■装置記録コード：958A
　■装置記録メッセージ：テストメッセージ
　■発報対象者名：ESM高原（会社）、ESM高原（携帯）
　■稼働ビューア：
　
以上です。
よろしくお願い致します。','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-09-04 16:06:31.129','2018-09-04 16:06:43.337'),
	('999915','2018-05-20 22:53:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常８－０５１８－４','{"53": "4", "54": "2"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('160','2018-05-30 16:47:00.528',null,'009999',1,'026','00999901','I',6,null,263,null,null,null,'【依頼失敗】装置データファイル収集',null,null,null,null,null,null,null,null,null,'2018-05-30 16:47:00.528','2018-05-30 16:47:00.528'),
	('88','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-09-04 16:18:39.202','関係者各位

　TDCクリニック2 の装置：TDCテスト装置でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：TDCクリニック2
　■装置名：TDCテスト装置
　■発生日時：2018/06/21 20:48:11
　■型式：DCS-27(I)
　■製造番号：TDC0101 
　■装置記録コード：958A
　■装置記録メッセージ：テストメッセージ
　■発報対象者名：ESM高原（会社）、ESM高原（携帯）
　■稼働ビューア：
　
以上です。
よろしくお願い致します。','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-09-04 16:18:27.064','2018-09-04 16:18:39.292'),
	('1000','2018-06-09 20:32:22.789',1,'009999',1,'026','00999901',null,6,null,91,null,null,null,'【成功】装置データファイル取得','{"path": "s3://ntss-s3-root/999900", "filename": "259_025_TDC0002_20180530154204_FTP.zip"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',null,null,null,'2018-05-30 16:47:00.528','2018-05-30 16:47:00.528'),
	('999921','2018-05-19 21:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "2.99", "5": "13.9", "6": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999922','2018-05-20 15:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "3", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999826','2018-06-04 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('17','2018-03-29 12:13:14',-1,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：ESM高原（会社）、ESM高原（携帯） ■稼働ビューア：[URL]
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-20 14:11:26.559','2018-06-20 14:11:36.714'),
	('18','2018-03-29 12:13:14',-1,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：ESM高原（会社）、ESM高原（携帯） ■稼働ビューア：[URL]
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-20 14:13:01.02','2018-06-20 14:15:03.69'),
	('19','2018-03-29 12:13:14',0,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：ESM高原（会社）、ESM高原（携帯） ■稼働ビューア：[URL]
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-20 14:15:06.522','2018-06-20 14:15:06.522'),
	('999913','2018-05-19 21:26:45.229',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１３－０５１８－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('20','2018-03-29 12:13:14',1,'000001',1,null,null,null,2,null,null,'2018-06-20 14:17:29.767','関係者各位 
　TDCクリニック の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：TDCクリニック
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：ESM高原（会社）、ESM高原（携帯） ■稼働ビューア：[URL]
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,null,null,null,null,'2018-06-20 14:16:25.208','2018-06-20 14:17:29.773'),
	('999924','2018-05-25 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0001", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999908','2018-05-18 22:53:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常８－０５１８－４','{"53": "1.000", "54": "6.000"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999945','2018-05-31 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999978','2018-06-03 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "0002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999980','2018-06-05 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "0301"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999981','2018-06-06 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "0201"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999925','2018-05-26 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0001", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999994','2018-12-07 15:30:22',0,'009999',1,'025','ESM0001',null,6,null,null,null,null,null,'データファイル収集',null,null,null,null,null,null,null,null,null,null,null),
	('999993','2018-06-10 15:03:22.789',1,'009999',1,'026','00999901',null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常３ー０５１７－３',null,'０　０　０　０','kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',9,null,null,null,null),
	('999971','2018-05-27 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('934','2018-03-29 12:13:14',-1,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',19,null,null,'2018-05-07 11:13:20.005','2018-05-07 11:13:25.545'),
	('935','2018-03-29 12:13:14',-1,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',19,null,null,'2018-05-07 11:16:36.624','2018-05-07 11:16:41.395'),
	('936','2018-03-29 12:13:14',1,'009999',1,'011','00999901',null,2,null,null,'2018-05-07 11:22:39.65','関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-07 11:22:34.306','2018-05-07 11:22:39.656'),
	('999939','2018-05-25 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('1001','2018-05-21 23:59:59.789',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "5", "6": "280", "7": "160", "8": "41", "9": "180", "10": "40", "11": "23", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('937','2018-03-29 12:13:20',1,'009999',1,'011','00999901',null,2,null,null,'2018-05-07 11:26:44.154','関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-07 11:26:39.359','2018-05-07 11:26:44.157'),
	('938','2018-03-29 12:15:14',1,'009999',1,'011','00999901',null,2,null,null,'2018-05-08 14:37:15.498','関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-08 14:37:09.918','2018-05-08 14:37:15.525'),
	('939','2018-04-01 15:12:14',1,'009999',1,'011','00999901',null,2,null,null,'2018-05-08 15:59:07.744','関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-08 15:59:02.718','2018-05-08 15:59:07.759'),
	('940','2018-03-29 12:13:18',1,'009999',1,'011','00999901',null,2,null,null,'2018-05-17 16:45:14.939','関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-17 16:45:09.394','2018-05-17 16:45:19.16'),
	('941','2018-04-02 18:13:14',1,'009999',1,'011','00999901',null,2,null,null,'2018-05-17 23:12:50.762','関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-17 23:12:48.71','2018-05-17 23:12:50.766'),
	('942','2018-04-03 19:13:14',1,'009999',1,'011','00999901',null,2,null,null,'2018-05-17 23:13:49.257','関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-17 23:13:48.609','2018-05-17 23:13:49.258'),
	('943','2018-03-29 12:18:52',1,'009999',1,'011','00999901',null,2,null,null,'2018-05-17 23:14:18.419','関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-17 23:14:17.795','2018-05-17 23:14:18.42'),
	('1088','2018-03-29 12:13:14',0,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',19,null,null,'2018-05-23 18:39:43.767','2018-05-23 18:39:43.767'),
	('1089','2018-03-29 12:13:14',0,'000001',1,null,null,null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常',null,null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',19,null,null,'2018-05-23 18:50:18.92','2018-05-23 18:50:18.92'),
	('999906','2018-06-08 20:32:22.789',1,'009999',1,'026','00999901',null,6,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','【成功】装置データファイル取得','{"path": "s3://ntss-s3-root/999900", "filename": "259_025_TDC0002_20180530154204_FTP.zip"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999905','2018-05-18 16:16:22.789',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常５－０５１８－５','{"3": "5", "5": "1", "6": "100", "7": "120", "8": "50", "9": "190", "10": "10", "11": "14", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999901','2018-05-17 06:01:22.789',1,'009999',1,'026','00999901',null,1,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１ー０５１７－１',null,'０　０　０　０','kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',15,null,null,null,null),
	('999973','2018-05-29 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('28','2018-06-21 20:48:11',-1,'999900',null,'003','TDC0101 ','A',2,null,null,null,null,'958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32',null,null,'取得できませんでした:装置マスタにレコードなし:[machine_type:003]、[machine_serial:TDC0101]、[facility_cd:999900]
通信種別エラー:[受信データ:303033415444433031303120393939393030201806212048113935384100020030000300310033003300040034003000050031003000060032003000070020bd]','1',19,null,null,'2018-06-21 21:16:27.574','2018-06-21 21:16:27.574'),
	('999991','2018-06-10 06:01:22',1,'009999',1,'026','00999901',null,1,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１ー０５１７－１',null,'０　０　０　０','kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',15,null,null,null,null),
	('31','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-06-21 21:21:33.742','メールテンプレート９０','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,'1',19,null,null,'2018-06-21 21:21:23.745','2018-06-21 21:21:33.746'),
	('34','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-06-21 21:26:54.853','関係者各位

　TDCクリニック2 の装置：TDCテスト装置でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：TDCクリニック2
　■装置名：TDCテスト装置
　■発生日時：2018/06/21 20:48:11
　■型式：DCS-27(I)
　■製造番号：TDC0101 
　■装置記録コード：958A
　■装置記録メッセージ：テストメッセージ
　■発報対象者名：ESM高原（会社）、ESM高原（携帯）
　■稼働ビューア：
　
以上です。
よろしくお願い致します。','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,'1',19,null,null,'2018-06-21 21:26:45.047','2018-06-21 21:26:54.858'),
	('999912','2018-05-19 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999911','2018-05-18 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999914','2018-05-20 12:11:22',1,'009999',1,'026','00999901',null,6,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','【成功】装置データファイル取得','{"path": "ntss-s3-root/999900", "filename": "259_025_TDC0001_20180530154204_FTP.zip"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('33','2018-06-21 20:48:11',1,'999900',null,'003','TDC0101 ','A',2,null,null,'2018-06-21 21:23:05.153','関係者各位

　TDCクリニック2 の装置：TDCテスト装置でエラーが発生しました。
　詳細は以下を確認して下さい。
　
　■施設名：TDCクリニック2
　■装置名：TDCテスト装置
　■発生日時：2018/06/21 20:48:11
　■型式：DCS-27(I)
　■製造番号：TDC0101 
　■装置記録コード：958A
　■装置記録メッセージ：テストメッセージ
　■発報対象者名：ESM高原（会社）、ESM高原（携帯）
　■稼働ビューア：
　
以上です。
よろしくお願い致します。','958A','テストメッセージ',null,'2,48,3,49,3342387,4,3407920,5,3211312,6,3276848,7,32','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）',null,'1',19,null,null,'2018-06-21 21:22:56.399','2018-06-21 21:23:05.156'),
	('999976','2018-06-01 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3111"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999916','2018-05-20 23:59:59.789',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "4", "6": "280", "7": "160", "8": "41", "9": "180", "10": "40", "11": "23", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999927','2018-05-28 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0001", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999941','2018-05-27 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999920','2018-05-19 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "10", "5": "60", "6": "0001", "7": "30", "8": "0", "9": "50", "10": "0.0", "11": "3.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('52','2018-05-02 09:47:14',-1,'000002',1,'002','00000002',null,2,null,null,null,null,null,null,null,null,null,null,null,'1',6,null,null,null,null),
	('999977','2018-06-02 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999923','2018-05-19 23:50:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "130", "5": "17", "6": "0001", "7": "90", "8": "25", "9": "100", "10": "1.5", "11": "3.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999990','2018-06-08 15:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "15", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999801','2018-05-25 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999802','2018-05-26 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999803','2018-05-27 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999804','2018-05-28 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999806','2018-05-30 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999805','2018-05-29 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999807','2018-05-31 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999808','2018-06-01 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999809','2018-06-02 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999810','2018-06-03 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999811','2018-06-04 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999812','2018-06-05 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999813','2018-06-06 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999814','2018-06-07 18:33:22',1,'009999',1,'026','00999901',null,4,5,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１１－０５１８－４','{"1": "160", "5": "40", "6": "0001", "7": "120", "8": "-5", "9": "150", "10": "2.0", "11": "2.0"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999816','2018-05-25 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999817','2018-05-26 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999818','2018-05-27 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999819','2018-05-28 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999820','2018-05-29 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999821','2018-05-30 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999822','2018-05-31 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999823','2018-06-01 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999824','2018-06-02 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999825','2018-06-03 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999827','2018-06-05 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999828','2018-06-06 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999829','2018-06-07 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999830','2018-06-08 11:33:22',1,'009999',1,'026','00999901',null,4,6,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１２－０５１８－４','{"4": "4.99", "5": "15.9", "6": "3002"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999943','2018-05-29 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999975','2018-05-31 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999909','2018-05-19 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "400"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999929','2018-05-30 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "3101", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999986','2018-06-06 15:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "11", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999987','2018-06-07 10:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "12", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999988','2018-06-07 15:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "13", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999972','2018-05-28 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999904','2018-05-17 16:00:22.789',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-30", "44": "30", "45": "-20", "46": "50", "47": "0001", "48": "-250", "49": "-15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999974','2018-05-30 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999984','2018-06-04 15:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "9", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999989','2018-06-08 09:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "14", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999942','2018-05-28 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999919','2018-05-19 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "-9.99", "64": "9.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999956','2018-05-27 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999918','2018-05-25 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999917','2018-05-25 16:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-30", "44": "30", "45": "-20", "46": "50", "47": "0001", "48": "-220", "49": "-15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999979','2018-06-04 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3101"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999982','2018-06-07 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "0001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999946','2018-06-01 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999947','2018-06-02 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999983','2018-06-08 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999949','2018-06-04 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999950','2018-06-05 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999951','2018-06-06 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999940','2018-05-26 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999944','2018-05-30 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999948','2018-06-03 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999952','2018-06-07 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999953','2018-06-08 23:00:22',1,'009999',1,'028','00999903',null,4,2,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"53": "3", "54": "4"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999954','2018-05-26 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999955','2018-05-27 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999957','2018-05-28 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999958','2018-05-29 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999959','2018-05-30 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999960','2018-05-31 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999961','2018-06-01 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999962','2018-06-02 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999963','2018-06-03 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999964','2018-06-04 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999965','2018-06-05 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999966','2018-06-06 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999967','2018-06-07 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999968','2018-06-08 16:33:22',1,'009999',1,'028','00999903',null,4,3,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常９－０５１８－４','{"58": "650"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999969','2018-05-25 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999970','2018-05-26 17:33:22',1,'009999',1,'028','00999903',null,4,4,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常１０－０５１８－４','{"63": "7.99", "64": "-3.99", "65": "3001"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999926','2018-05-27 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0001", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999902','2018-05-17 15:02:22.789',1,'009999',1,'026','00999901',null,2,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常２ー０５１７－２',null,'０　０　０　０','kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'1',9,null,null,null,null),
	('999938','2018-06-08 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0001", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999928','2018-05-29 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "9999", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999930','2018-05-31 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0302", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999931','2018-06-01 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0301", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999903','2018-05-17 15:03:22.789',1,'009999',1,'026','00999901',null,3,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常３ー０５１７－３',null,'０　０　０　０','kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',9,null,null,null,null),
	('999932','2018-06-02 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "020A", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999933','2018-06-03 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0202", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999934','2018-06-04 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0201", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999935','2018-06-05 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0004", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999936','2018-06-06 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0003", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999937','2018-06-07 23:00:22',1,'009999',1,'028','00999903',null,4,1,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常４－０５１７－４','{"43": "-20", "44": "-10", "45": "20", "46": "-30", "47": "0002", "48": "-300", "49": "15"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null),
	('999985','2018-06-05 15:28:41',1,'009999',1,'026','00999901',null,5,null,null,null,'関係者各位 
　永和病院 の装置：deviceA1で デバイスエッジ通信異常 が発生しました。
　詳細は以下を確認して下さい。
　
■施設名：永和病院
■デバイスエッジ名：deviceA1
■デバイスエッジ番号：1
■発生日時：2018/03/29 12:13:14
■装置記録コード：G000 
■装置記録メッセージ：デバイスエッジ通信異常 
　
■発報対象者名：NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木 
以上です。
よろしくお願い致します。','G000','デバイスエッジ通信異常７－０５１８－５','{"3": "0", "5": "10", "6": "120", "7": "110", "8": "52", "9": "172", "10": "38", "11": "16", "12": "0", "13": "1"}',null,'kynkjr-0510-taurus@ezweb.ne.jp ','NKK_萩原,NKK_北岡,NKK_青田,ESM_高原,YSK_橋口,YSK_櫨木',null,'0',15,null,null,null,null)
;

-- デバイスエッジマスタ
TRUNCATE TABLE mst_device_edge;
INSERT INTO mst_device_edge (serial_no, facility_cd, device_edge_no, device_name, is_disp, is_del, setting_date, delete_date, memo, reg_date, up_date) VALUES 
	('1','000001',1,'deviceA1','1','0',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('2','000001',2,'deviceA2','1','0',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('3','000002',1,'deviceB1','1','0',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('4','000002',2,'deviceB2','1','0',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('5','000003',1,'deviceC1','1','0',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('6','000003',2,'deviceC2','1','0',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('7','000004',1,'deviceD1','1','0',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('8','000005',1,'deviceE1','1','0',null,null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00')
;

-- 装置マスタ
TRUNCATE TABLE mst_machine;
INSERT INTO mst_machine (facility_cd, machine_type_cd, machine_serial, machine_name, machine_no, ip_address, port, com_format_cd, com_type, device_edge_no, is_ftp, is_va, reg_date, up_date) VALUES 
	('000002','001','00000002','装置202',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.111/32',null,'M',1,1,'0','0','2018-01-31 13:08:15','2018-01-31 13:08:19'),
	('000002','001','0000001','装置201',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.111/32',null,'C',1,1,'0','0','2018-01-31 12:53:02','2018-01-31 12:53:02'),
	('999900','025','TDC0002','テスト装置',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.237/32','00000','I',1,1,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('009999','025','ESM0002','テスト装置2',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.2/32','00001','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('009999','025','ESM0003','テスト装置3',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.3/32','00002','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0005','テスト装置5',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.5/32','00004','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0004','テスト装置4',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.4/32','00003','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0006','テスト装置6',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.6/32','00005','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0007','テスト装置7',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.7/32','00006','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0008','テスト装置8',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.8/32','00007','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0009','テスト装置9',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.9/32','00008','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0010','テスト装置10',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.10/32','00009','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0011','テスト装置11',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.11/32','00010','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0012','テスト装置12',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.12/32','00011','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0013','テスト装置13',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.13/32','00012','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0014','テスト装置14',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.14/32','00013','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0015','テスト装置15',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.15/32','00014','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0016','テスト装置16',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.16/32','00015','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0017','テスト装置17',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.17/32','00016','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0018','テスト装置18',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.18/32','00017','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0019','テスト装置19',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.19/32','00018','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0020','テスト装置20',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.20/32','00019','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0021','テスト装置21',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.21/32','00020','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0022','テスト装置22',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.22/32','00021','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0023','テスト装置23',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.23/32','00022','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0024','テスト装置24',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.24/32','00023','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0025','テスト装置25',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.25/32','00024','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0026','テスト装置26',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.26/32','00025','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0027','テスト装置27',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.27/32','00026','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0028','テスト装置28',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.28/32','00027','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0029','テスト装置29',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.29/32','00028','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0030','テスト装置30',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.30/32','00029','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0031','テスト装置31',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.31/32','00030','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0032','テスト装置32',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.32/32','00031','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0033','テスト装置33',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.33/32','00032','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0034','テスト装置34',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.34/32','00033','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0035','テスト装置35',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.35/32','00034','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0036','テスト装置36',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.36/32','00035','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0037','テスト装置37',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.37/32','00036','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0038','テスト装置38',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.38/32','00037','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0039','テスト装置39',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.39/32','00038','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0040','テスト装置40',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.40/32','00039','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0041','テスト装置41',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.41/32','00040','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0042','テスト装置42',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.42/32','00041','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0043','テスト装置43',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.43/32','00042','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0044','テスト装置44',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.44/32','00043','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0045','テスト装置45',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.45/32','00044','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0046','テスト装置46',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.46/32','00045','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0047','テスト装置47',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.47/32','00046','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0048','テスト装置48',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.48/32','00047','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0049','テスト装置49',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.49/32','00048','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0050','テスト装置50',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.50/32','00049','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0051','テスト装置51',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.51/32','00050','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0052','テスト装置52',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.52/32','00051','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0053','テスト装置53',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.53/32','00052','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0054','テスト装置54',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.54/32','00053','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0055','テスト装置55',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.55/32','00054','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0056','テスト装置56',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.56/32','00055','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0057','テスト装置57',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.57/32','00056','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0058','テスト装置58',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.58/32','00057','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0059','テスト装置59',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.59/32','00058','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0060','テスト装置60',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.60/32','00059','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0061','テスト装置61',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.61/32','00060','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0062','テスト装置62',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.62/32','00061','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0063','テスト装置63',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.63/32','00062','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0064','テスト装置64',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.64/32','00063','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0065','テスト装置65',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.65/32','00064','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0066','テスト装置66',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.66/32','00065','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0067','テスト装置67',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.67/32','00066','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0068','テスト装置68',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.68/32','00067','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0069','テスト装置69',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.69/32','00068','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0070','テスト装置70',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.70/32','00069','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0071','テスト装置71',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.71/32','00070','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0072','テスト装置72',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.72/32','00071','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0073','テスト装置73',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.73/32','00072','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0074','テスト装置74',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.74/32','00073','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0075','テスト装置75',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.75/32','00074','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0076','テスト装置76',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.76/32','00075','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0077','テスト装置77',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.77/32','00076','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0078','テスト装置78',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.78/32','00077','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0079','テスト装置79',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.79/32','00078','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0080','テスト装置80',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.80/32','00079','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0081','テスト装置81',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.81/32','00080','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0082','テスト装置82',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.82/32','00081','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0083','テスト装置83',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.83/32','00082','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0084','テスト装置84',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.84/32','00083','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0085','テスト装置85',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.85/32','00084','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0086','テスト装置86',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.86/32','00085','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0087','テスト装置87',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.87/32','00086','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0088','テスト装置88',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.88/32','00087','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0089','テスト装置89',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.89/32','00088','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0090','テスト装置90',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.90/32','00089','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0091','テスト装置91',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.91/32','00090','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0092','テスト装置92',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.92/32','00091','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0093','テスト装置93',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.93/32','00092','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0094','テスト装置94',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.94/32','00093','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0095','テスト装置95',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.95/32','00094','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0096','テスト装置96',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.96/32','00095','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0097','テスト装置97',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.97/32','00096','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0098','テスト装置98',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.98/32','00097','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0099','テスト装置99',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.99/32','00098','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0100','テスト装置100',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.100/32','00099','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0101','テスト装置101',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.101/32','00100','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0102','テスト装置102',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.102/32','00101','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0103','テスト装置103',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.103/32','00102','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0104','テスト装置104',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.104/32','00103','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0105','テスト装置105',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.105/32','00104','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0106','テスト装置106',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.106/32','00105','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0107','テスト装置107',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.107/32','00106','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0108','テスト装置108',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.108/32','00107','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0109','テスト装置109',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.109/32','00108','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0110','テスト装置110',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.110/32','00109','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0111','テスト装置111',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.111/32','00110','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0112','テスト装置112',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.112/32','00111','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0113','テスト装置113',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.113/32','00112','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0114','テスト装置114',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.114/32','00113','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0115','テスト装置115',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.115/32','00114','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0116','テスト装置116',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.116/32','00115','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0117','テスト装置117',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.117/32','00116','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0118','テスト装置118',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.118/32','00117','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0119','テスト装置119',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.119/32','00118','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0120','テスト装置120',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.120/32','00119','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0121','テスト装置121',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.121/32','00120','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0122','テスト装置122',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.122/32','00121','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0123','テスト装置123',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.123/32','00122','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0124','テスト装置124',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.124/32','00123','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0125','テスト装置125',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.125/32','00124','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0126','テスト装置126',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.126/32','00125','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0127','テスト装置127',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.127/32','00126','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0128','テスト装置128',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.128/32','00127','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0129','テスト装置129',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.129/32','00128','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0130','テスト装置130',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.130/32','00129','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0131','テスト装置131',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.131/32','00130','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0132','テスト装置132',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.132/32','00131','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0133','テスト装置133',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.133/32','00132','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0134','テスト装置134',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.134/32','00133','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0135','テスト装置135',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.135/32','00134','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0136','テスト装置136',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.136/32','00135','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0137','テスト装置137',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.137/32','00136','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0138','テスト装置138',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.138/32','00137','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0139','テスト装置139',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.139/32','00138','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0140','テスト装置140',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.140/32','00139','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0141','テスト装置141',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.141/32','00140','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0142','テスト装置142',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.142/32','00141','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0143','テスト装置143',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.143/32','00142','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0144','テスト装置144',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.144/32','00143','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0145','テスト装置145',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.145/32','00144','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0146','テスト装置146',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.146/32','00145','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0147','テスト装置147',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.147/32','00146','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0148','テスト装置148',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.148/32','00147','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0149','テスト装置149',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.149/32','00148','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0150','テスト装置150',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.150/32','00149','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0151','テスト装置151',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.151/32','00150','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0152','テスト装置152',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.152/32','00151','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0153','テスト装置153',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.153/32','00152','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0154','テスト装置154',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.154/32','00153','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0155','テスト装置155',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.155/32','00154','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0156','テスト装置156',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.156/32','00155','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0157','テスト装置157',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.157/32','00156','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0158','テスト装置158',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.158/32','00157','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0159','テスト装置159',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.159/32','00158','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0160','テスト装置160',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.160/32','00159','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0161','テスト装置161',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.161/32','00160','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0162','テスト装置162',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.162/32','00161','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0163','テスト装置163',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.163/32','00162','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0164','テスト装置164',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.164/32','00163','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0165','テスト装置165',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.165/32','00164','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0166','テスト装置166',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.166/32','00165','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0167','テスト装置167',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.167/32','00166','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0168','テスト装置168',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.168/32','00167','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0169','テスト装置169',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.169/32','00168','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0170','テスト装置170',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.170/32','00169','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0171','テスト装置171',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.171/32','00170','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0172','テスト装置172',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.172/32','00171','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0173','テスト装置173',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.173/32','00172','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0174','テスト装置174',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.174/32','00173','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0175','テスト装置175',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.175/32','00174','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0176','テスト装置176',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.176/32','00175','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0177','テスト装置177',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.177/32','00176','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0178','テスト装置178',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.178/32','00177','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0179','テスト装置179',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.179/32','00178','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0180','テスト装置180',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.180/32','00179','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0181','テスト装置181',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.181/32','00180','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0182','テスト装置182',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.182/32','00181','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0183','テスト装置183',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.183/32','00182','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0184','テスト装置184',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.184/32','00183','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0185','テスト装置185',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.185/32','00184','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0186','テスト装置186',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.186/32','00185','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0187','テスト装置187',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.187/32','00186','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0188','テスト装置188',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.188/32','00187','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0189','テスト装置189',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.189/32','00188','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0190','テスト装置190',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.190/32','00189','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0191','テスト装置191',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.191/32','00190','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0192','テスト装置192',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.192/32','00191','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0193','テスト装置193',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.193/32','00192','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0194','テスト装置194',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.194/32','00193','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0195','テスト装置195',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.195/32','00194','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0196','テスト装置196',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.196/32','00195','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0197','テスト装置197',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.197/32','00196','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0198','テスト装置198',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.198/32','00197','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0199','テスト装置199',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.199/32','00198','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0200','テスト装置200',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.200/32','00199','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0201','テスト装置201',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.201/32','00200','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0202','テスト装置202',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.202/32','00201','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0203','テスト装置203',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.203/32','00202','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0204','テスト装置204',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.204/32','00203','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0205','テスト装置205',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.205/32','00204','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0206','テスト装置206',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.206/32','00205','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0207','テスト装置207',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.207/32','00206','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0208','テスト装置208',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.208/32','00207','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0209','テスト装置209',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.209/32','00208','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0210','テスト装置210',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.210/32','00209','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0211','テスト装置211',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.211/32','00210','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0212','テスト装置212',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.212/32','00211','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0213','テスト装置213',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.213/32','00212','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0214','テスト装置214',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.214/32','00213','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0215','テスト装置215',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.215/32','00214','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0216','テスト装置216',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.216/32','00215','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0217','テスト装置217',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.217/32','00216','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0218','テスト装置218',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.218/32','00217','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0219','テスト装置219',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.219/32','00218','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0220','テスト装置220',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.220/32','00219','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0221','テスト装置221',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.221/32','00220','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0222','テスト装置222',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.222/32','00221','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0223','テスト装置223',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.223/32','00222','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0224','テスト装置224',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.224/32','00223','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0225','テスト装置225',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.225/32','00224','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0226','テスト装置226',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.226/32','00225','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0227','テスト装置227',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.227/32','00226','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0228','テスト装置228',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.228/32','00227','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0229','テスト装置229',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.229/32','00228','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0230','テスト装置230',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.230/32','00229','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0231','テスト装置231',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.231/32','00230','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0232','テスト装置232',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.232/32','00231','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0233','テスト装置233',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.233/32','00232','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0234','テスト装置234',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.234/32','00233','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0235','テスト装置235',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.235/32','00234','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0236','テスト装置236',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.236/32','00235','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0237','テスト装置237',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.237/32','00236','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0238','テスト装置238',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.238/32','00237','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0239','テスト装置239',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.239/32','00238','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0240','テスト装置240',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.240/32','00239','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0241','テスト装置241',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.241/32','00240','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0242','テスト装置242',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.242/32','00241','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0243','テスト装置243',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.243/32','00242','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0244','テスト装置244',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.244/32','00243','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0245','テスト装置245',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.245/32','00244','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0246','テスト装置246',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.246/32','00245','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0247','テスト装置247',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.247/32','00246','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0248','テスト装置248',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.248/32','00247','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0249','テスト装置249',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.249/32','00248','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0250','テスト装置250',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.250/32','00249','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0251','テスト装置251',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.251/32','00250','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0252','テスト装置252',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.252/32','00251','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0253','テスト装置253',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.253/32','00252','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0254','テスト装置254',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.254/32','00253','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0255','テスト装置255',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.1/32','00254','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0256','テスト装置256',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.2/32','00255','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0257','テスト装置257',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.3/32','00256','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0258','テスト装置258',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.4/32','00257','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0259','テスト装置259',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.5/32','00258','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0260','テスト装置260',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.6/32','00259','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0261','テスト装置261',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.7/32','00260','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0262','テスト装置262',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.8/32','00261','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0263','テスト装置263',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.9/32','00262','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0264','テスト装置264',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.10/32','00263','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0265','テスト装置265',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.11/32','00264','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0266','テスト装置266',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.12/32','00265','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0267','テスト装置267',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.13/32','00266','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0268','テスト装置268',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.14/32','00267','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0269','テスト装置269',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.15/32','00268','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0270','テスト装置270',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.16/32','00269','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0271','テスト装置271',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.17/32','00270','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0272','テスト装置272',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.18/32','00271','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0273','テスト装置273',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.19/32','00272','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0274','テスト装置274',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.20/32','00273','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0275','テスト装置275',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.21/32','00274','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0276','テスト装置276',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.22/32','00275','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0277','テスト装置277',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.23/32','00276','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0278','テスト装置278',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.24/32','00277','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0279','テスト装置279',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.25/32','00278','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0280','テスト装置280',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.26/32','00279','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0281','テスト装置281',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.27/32','00280','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0282','テスト装置282',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.28/32','00281','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0283','テスト装置283',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.29/32','00282','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0284','テスト装置284',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.30/32','00283','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0285','テスト装置285',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.31/32','00284','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0286','テスト装置286',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.32/32','00285','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0287','テスト装置287',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.33/32','00286','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0288','テスト装置288',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.34/32','00287','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0289','テスト装置289',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.35/32','00288','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0290','テスト装置290',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.36/32','00289','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0291','テスト装置291',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.37/32','00290','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0292','テスト装置292',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.38/32','00291','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0293','テスト装置293',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.39/32','00292','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0294','テスト装置294',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.40/32','00293','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0295','テスト装置295',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.41/32','00294','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0296','テスト装置296',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.42/32','00295','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0297','テスト装置297',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.43/32','00296','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0298','テスト装置298',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.44/32','00297','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0299','テスト装置299',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.45/32','00298','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('000007','025','ESM0300','テスト装置300',nextval('mst_machine_machine_no_seq'::regclass),'192.168.101.46/32','00299','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('009999','025','00000099','装置030',nextval('mst_machine_machine_no_seq'::regclass),null,'00300','I',1,2,'0','0','2018-06-06 14:58:39.028','2018-06-06 14:58:43.626'),
	('009999','027','00999902','装置032',nextval('mst_machine_machine_no_seq'::regclass),null,'00302','D',2,2,'0','0','2018-06-06 17:13:04.546','2018-06-06 17:13:07.252'),
	('009999','011','00999901','装置031',nextval('mst_machine_machine_no_seq'::regclass),null,'00301','A',2,2,'0','0','2018-06-06 17:11:16.18','2018-06-06 17:11:18.859'),
	('999900','003','TDC0101','TDCテスト装置',nextval('mst_machine_machine_no_seq'::regclass),null,null,'I',2,1,'0','0',null,null),
	('009999','028','00999903','装置033',nextval('mst_machine_machine_no_seq'::regclass),null,'00302','R',2,2,'0','0','2018-06-06 17:13:18.019','2018-06-06 17:13:13.325'),
	('009999','025','ESM0001','テスト装置1',nextval('mst_machine_machine_no_seq'::regclass),'192.168.100.1/32','00000','I',1,2,'0','0','2017-11-15 00:59:34','2017-11-15 00:59:34'),
	('009999','026','00999901','装置031',nextval('mst_machine_machine_no_seq'::regclass),null,'00301','A',2,2,'1','0','2018-06-06 17:11:16.18','2018-06-06 17:11:18.859')
;

-- 装置記録マスタ
TRUNCATE TABLE mst_machine_record;
INSERT INTO mst_machine_record (machine_record_cd, machine_record_message, reg_date, up_date) VALUES 
	('0001',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0002',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0003',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0004',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0005',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0006',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0007',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0008',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0009',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('000A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('000B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('000C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('000D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('000E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('000F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0010',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0011',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0012',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0013',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0014',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0015',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0016',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0039',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('003A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('003B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('003C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('003D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('003E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('003F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0040',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0050','投与薬剤','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0060','酸素吸入開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0061','酸素吸入終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0101','血圧測定','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0102','体温測定','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0103','ケア                                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0104','透析前血圧                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0105','透析後血圧                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0106',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0107',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0108',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0109','引き残し量','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0201','ＬＣＤオープン                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0202','ＬＣＤクローズ                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0203','タッチキー                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0301','ＵＦＲＣ自己診断実施                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0302','漏血自己診断実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0303','濃度自己診断実施                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0304','補液バッグテスト実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0305','荷重計手動ゼロ補正実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0306','静脈圧ゼロ補正実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0307','動脈圧ゼロ補正実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0400','ＤＡＢメンテナンステスト                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0500','警報監視状態の変化                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0600','通信データ異常（治療条件）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('0601','通信データ異常（次患者情報）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2000','装置間通信エラーカウント','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2001','CF高温時間','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2002','CF漏れテスト','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2003','バッテリテスト測定値','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2004','カスケードポンプ出力値','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2005','複式ポンプ出力値','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2006','SV締め切り検出器テスト(SV4,SV5)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2007','SV締め切り検出器テスト(SV6,SV7)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2008','SV締め切り検出器テスト(SV8)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('2009','SV締め切り検出器テスト(SV9,SV10)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('200A','濃度(配管自己診断時)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('200B','透析量モニタ校正 発光値','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('200C','透析量モニタ校正 受光値','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('200D','除水ポンプ吐出テスト','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3000','DAB原注ポンプデータ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3001','DAB濃度セルデータ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3002','DAB透析給水データ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3003','DAB水計量データ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3004','DAB薬液セル','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3005','DAB排液時間','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3006','DAB送液圧','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3007','DAB脱気圧','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3008','DABヒータ立ち上がり','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3009','DAB貯槽セル','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3400','CELL1A25 電圧(V)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3401','CELL1B25 電圧(V)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3402','薬液濃度セル電圧（ピーク値  V）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3403','A原液貯槽の薬液消毒後の排液時間（秒）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3404','B原液貯槽の薬液消毒後の排液時間（秒）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3405','A原液貯槽の電圧変化(V)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3406','B原液貯槽の電圧変化（V)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3407','ヒータ出口のピーク温度（℃）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3408','カッター稼働累積回数','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('3409','カッターリトライ稼働回数','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('340A','B原液立ち上がり濃度までの時間（秒）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('340B','A原液立ち上がり濃度までの時間（秒）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4000','除水完了                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4001','除水速度０運転                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4002','除水量設定０運転                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4003','除水速度の限界                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4004','除水速度を計算できません                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4005','除水ポンプ吐出テスト開始                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4006','補液速度０報知                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4007','補液量設定０報知                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4008','補液空報知                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4009','除水計算が実施できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('400A','補液計算が実施できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('400B','除水・補液計算が実施できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('400C','除水開始遅延中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('400D','TMP補液制御 速度下限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4010','補液完了報知                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4020','除水速度が高すぎます','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4021','除水低下スイッチが「入」になっています ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4030','D-FAS 返血完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4031','運転工程前のスローアップ中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4032','返血不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4033','動脈側穿刺部付近の圧力が上昇しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4040','濾液速度が除水速度操作範囲の上限を超えています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4100','注入完了                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4101','ＩＰ注入時間完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4102','ＩＰスタート（自動）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4103','ＩＰワンショットスタート（自動）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4104','ＩＰ電源自動切り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4105','ＩＰ電源ＯＫモニタ切り（自動）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4106','静脈側気泡検出器電源「入」（自動）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4200','ナースコール                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4201','バイパスコネクタ有り                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4202','透析停止                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4203','ガスパージ終了報知                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4210','洗浄流量アップ動作開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4211','透析準備流量アップ動作開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4212','透析準備流量アップ動作終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4220','血液成分リーク','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4221','漏血初期電圧を読み込んでください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4300','準備回収                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4301','治療入れ忘れ ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4302','除水速度が操作範囲を越えてしまいます','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4303','補液速度が操作範囲を越えてしまいます','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4304','除水速度が限界速度を越えてしまいます','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4305','補液速度が限界速度を越えてしまいます','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4306','ＩＰワンショット量が設定されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4307','HD運転からECUM運転に自動的に移行しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4308','HDF運転からECUM運転に自動的に移行しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4309','OHDF運転からECUM運転に自動的に移行しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('430A','OHF運転からECUM運転に自動的に移行しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4400','血液回路プライミング運転                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4401','プライミング終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4402','生食バック空','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4403','プライミング補助動作中（動脈充填）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4404','プライミング補助動作中（静脈充填）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4405','プライミング補助動作中（気泡抜き）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4406','自動プライミング動作中（待機）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4407','自動プライミング動作中（落差）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4408','自動プライミング動作中（送液）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4409','自動プライミング動作中（循環）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('440A','返血機能動作中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('440B','血液回路排液動作中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('440C','補液プライミング未実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('440D','補液プライミング動作中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('440E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('440F','緊急補液中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4411',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4412',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4413',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4414',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4415',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4416',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4417',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4418',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4419',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('441A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('441B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('441C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('441D','返血機能使用中 (オンライン)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('441E','オンラインプライミング動作中(気泡抜き)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('441F','オンラインプライミング動作中(液面作成)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4420','オンラインプライミング動作中(循環洗浄)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4421','オンラインプライミング終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4422','返血機能使用中 (透析液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4423','D-FASプライミング開始忘れ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4430',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4431','血液回路取り外しを検知したため，推定血流量モニタを中止しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4432','推定血流量の算出に失敗しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4433','推定血流量モニタ校正 正常終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4500','血液ポンプ停止報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4501','血液ポンプ電源「切」                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4502','血液ポンプカバー「開」                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4503','血流量設定「０００」                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4504','血流量に対して除水速度が早すぎます                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4505','動脈　血液ポンプカバ－「開」                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4506','動脈　血流量設定「０００」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4507','静脈　血液ポンプ電源「切」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4508','静脈　血液ポンプカバ－「開」                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4509','動脈側血液ポンプ電源「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('450A','補液ポンプカバー開                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('450B','補液空','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('450C','血液ポンプ速度が低すぎます','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('450D','補液ヒータカバー開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('450E','補液ハンガーを定位置に戻して下さい','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('450F','濾液速度が限界速度を超えてしまいます','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4511','動脈血液ポンプ カバー開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4512','静脈血液ポンプ カバー開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4520','血液回路無し','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4521','静脈側血液ポンプにしごき部がセットされていますか','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4522','生食を検出                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4523','血液回路無し (静脈)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4524','血液回路無し (動脈)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4525','血液回路無し (生食)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4526','血液回路無し (排液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4600','ＩＰ電源「切」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4601','ＩＰ速度０運転                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4602','ＩＰシリンジ無し','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4603','IP自動ワンショットは実施しません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4700','除水開放                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4801','複式ポンプキャップシール交換時期                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4802','複式ポンプポペットバルブ交換時期                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4803','複式ポンプスライダー交換時期                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4804','複式ポンプフィルター交換時期                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4805','背圧弁ダイアフラム交換時期                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4806','除水ポンプキャップシール交換時期                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4807','除水ポンプポペットバルブ交換時期                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4808','カスケードポンプメカニカルシール交換時期                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4809','脱気フィルター交換時期                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('480A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('480B','原液ポンプ背圧ポペット交換時期                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('480C','原液フィルター交換時期                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('480D','原液ポンプキャップシール交換時期                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('480E','原液ポンプポペットバルブ交換時期                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('480F','原液ポンプ 背圧弁４,５ ダイアフラム交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4810','微粒子除去フィルター交換時期                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4811','ＳＶ１３フィルター交換時期                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4812','Ｂ粉カートリッジ廃液用フィルター交換時期                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4813','血液回路トランスデューサー用フィルター交換時期              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4814','ＬＡＰしごき部交換時期                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4815','薬液フィルター交換時期                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4816','透析液戻り口フィルター交換時期                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4817',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4818','エアフィルター交換時期                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4819','透析終了後、荷重計を調整してください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('481A','脱気ポンプ メカニカルシール交換時期 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('481B','加圧ポンプ メカニカルシール交換時期 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('481C','ＳＶ４１用 フィルター交換時期 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('481D','透析液出口逆止弁交換時期 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('481E','パワーユニットファン交換時期 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('481F','Ｂ粉カートリッジホルダOリング交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4820','背圧弁１,２,Ｌ ダイアフラム交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4821','Ｎａ原液吸引ポートOリング交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4822','バイパスポートOリング交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4823','ダイアライザーカップリングOリング交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4824','オンラインポートシール交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4825','電磁弁交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4826','薬液電磁弁交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4827','脱気インペラ交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4828','加圧インペラ交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4829','複式ベアリング交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('482A','逆止弁(CV41)交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('482B','逆止弁(CV42,CV61)交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('482C','ＣＦ１交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('482D','ＣＦ２交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('482E','原液ノズルOリング交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4830','消耗品グループ１交換時期 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4831','消耗品グループ２交換時期 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4832','消耗品グループ３交換時期 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4833','ダイアライザーカップリング交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4834','サンプルポート　ガスケット交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4835','サンプルポート　逆止弁交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4836','CF1使用期間経過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4837','CF2使用期間経過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4838','CF1使用回数超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4839','CF2使用回数超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('483A','CF1交換時期(高温時間)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('483B','CF2交換時期(高温時間)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4841','薬液ポート２補充時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4901','給液圧が低下しました                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4902','透析完了                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4903','タイマー完了                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4904','透析終了                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4905','送液信号が停止しました                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4906','商用電源が供給されています                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4907','外部入力が停止しました                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4908','商用電源が供給されていません                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4909','タイマー１完了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('490A','タイマー２完了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('490B','タイマー３完了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('490C','タイマー４完了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('490D','送液信号が復帰しました                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4911','ＵＦＲＣ自己診断実行開始                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4912','ＵＦＲＣ自己診断実行終了                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4913','補液加温バッグテスト実行済み','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4914','補液回路接続テスト合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4921','ＴＭＰゼロ補正開始                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4922','初期ＵＦＲ測定開始                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4923','ＴＭＰゼロ補正完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4924','初期ＵＦＲ測定完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4930','漏血テスト実行開始                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4941','Ａ原液接手が洗浄口に接続されています                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4942','Ｂ原液接手が洗浄口に接続されています                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4943','Ｎａ原液接手が洗浄口に接続されています                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4944','生食を検出','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4945','Ｂ原液接手が洗浄口に接続されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4946','Ａ原液接手が洗浄口に接続されていません ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4947','Na接手が洗浄口に戻されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4951','濃度自己診断実行開始                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4952','濃度自己診断実行終了                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4961','バッテリー運転開始                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4962','手動バッテリー運転開始                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4963','パワーユニット内の温度が上昇しています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4964','補助パワーユニット内の温度が上昇しています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4965','補助パワーユニットが漏電しています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4966','バッテリ運転スイッチが自動になっていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4970','ＵＦＲＣ自己診断実行できません                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4980','過酢酸消毒時間が不足しています                                     ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4981','自動運転が遅れました                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4982','自動運転が完了しました                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4983','熱水消毒不足                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4984','クリーニング途中終了                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4985','自動運転途中終了                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4986','自動運転スタート','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4987','自動運転スタート（ウィークリータイマー）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4988','クエン酸熱水消毒過剰','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4989','薬液ボトルが空ではないですか','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('498A','薬液ボトルに薬液を満たし警報リセットキーを押して下さい','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('498B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('498C','次亜塩素酸ナトリウム消毒不足','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('498D','次亜塩素酸ナトリウム消毒過剰','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('498E','クエン酸熱水消毒不足','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('498F','RO装置連動待機中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4991','クリップ式気泡センサーが動作していません                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4992','静脈側気泡電源ＳＷ入れ忘れ報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4993','静脈側気泡検出器電源「入」（自動）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49A0','漏水検知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49B0','荷重計異常  HDFモードに入れません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49B1','透析終了後，荷重計を調整してください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49C0','CFカード カード系異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49C1','BV計データ自動出力を実行できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49C2','CFカード 通信系異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49C3','装置記録自動出力を実行できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49C4','自己診断記録自動出力を実行できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49D0','装置間通信断','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49D1','装置間通信復帰','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49D2','工程データが異なります','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49D3','次の洗・消まで装置を使用しません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49E0','除水時間を確保できないため補液しませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('49E1','総補液量上限に達したため補液を終了しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A00','その他','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A01','除水停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A02','除水再開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A03','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A04','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A05','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A06','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A07','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A08','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A09','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A10','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A11','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A12','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A13','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A14','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A15','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A16','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A17','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A18','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A19','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A20','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A21','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A22','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A23','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A24','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A25','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A26','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A27','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A28','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('4A29','予約（BVMS連携イベント）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5000','透析運転入れ忘れ           ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5001','強制洗浄中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5002','洗・消入れ忘れ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5003','クリップ式気泡検出器 未装着','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5004','補液切れ検出器 未装着','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5005','洗浄・消毒を実施してください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5006','未洗浄','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5007','未消毒','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5100','警報発生による血圧測定中止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5101','装置設定変更による血圧測定中止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5102','最高血圧上限警報動作中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5103','最高血圧下限警報動作中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5104','血圧警報下限警報OFF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5105','脈拍警報下限警報OFF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5180','ΔＢＶがΔＢＶ低下警報点１を下回っています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5181','ＢＶ計に血液回路が装着されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5182',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5183','ΔＢＶがΔＢＶ低下警報点２を上回りました。','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5184','ΔＢＶがΔＢＶ低下警報点２を下回っています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5185',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5186',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5187','BV計データ転送完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5188','BV計データ転送エラー','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5189','ΔBVがリファレンスエリアから逸脱しています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('518A','BV計のカバーが開いています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('518B','除水停止(ΔBV算出開始待ち)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5190','透析量モニタ 初期化を中断','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5191','再循環率が設定以上の値になりました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5192','再循環率測定が中止しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5193','前体重が入力されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5200','自動運転１終了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5201','自動運転２終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5202','自動運転３終了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5203','自動運転４終了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5204','自動運転５終了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5205','治療前自動運転終了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5206','洗浄日自動運転終了 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5210','自動運転１終了（警報あり）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5211','自動運転２終了（警報あり）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5212','自動運転３終了（警報あり）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5213','自動運転４終了（警報あり）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5214','自動運転５終了（警報あり）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5300','ＣＦ交換中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5301','ＣＦ交換が終了しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5302','治療に使用する場合は「液置換」を行ってください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5303','治療に使用する場合は「CF漏れテスト」を行ってください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5304','治療に使用しない場合は「洗浄・消毒」を行ってください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5310','カップリング漏れテスト合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5311','カップリング漏れテスト中断','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5320','SV4締切検出器が開状態を検出できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5321','SV5締切検出器が開状態を検出できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5322','SV6締切検出器が開状態を検出できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5323','SV7締切検出器が開状態を検出できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5324','SV9締切検出器が開状態を検出できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5325','SV10締切検出器が閉状態を検出できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('5E01',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6000','自動運転完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6001','サーミスタTH５断線(透析液濃度補正用)                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6002','サーミスタTH６断線(透析液濃度補正用)                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6101','サーミスタTH５短絡(透析液濃度補正用)                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6102','サーミスタTH６短絡(透析液濃度補正用)                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6201','Ｂ原液注入ポンプ（Ｐ１）制御不良                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6202','Ａ原液注入ポンプ（Ｐ２）制御不良                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6301','Ｂ原液注入ポンプ（Ｐ１）過負荷                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6302','Ａ原液注入ポンプ（Ｐ２）過負荷                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7823','RO入口圧低下検知1回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6400','水量計シリンダ速度                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6500','漏水（透析工程）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6600','薬液消毒不足                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6610','透析用監視装置洗消不足','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6611','透析用監視装置洗消不足１','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6612','透析用監視装置洗消不足２','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6700','熱湯消毒不足                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6710','熱湯クエン酸循環流量不足報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6711','熱湯クエン酸消毒温度低報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6712','熱湯クエン酸消毒不足報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6713','熱水クエン酸消毒温度警報（上限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6800','送液圧異常                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6880','RO装置の工程がキャンセルされました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6901','０％濃度異常高↑                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6902','０％濃度異常低↓                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6903','－１０％濃度異常高↑                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6904','－１０％濃度異常低↓                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A01','ＰＲＳ１、ＬＶＳ異常、ＭＶ６リーク                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A02','ＬＶＳ異常                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A03','ＬＶＳ１異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A04','ＬＶＳ２異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A05','ＬＶＳ３異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A06','ＭＶ６リーク                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A07','ＬＶＳ３異常、ＭＶ５異常                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A08','ＭＶ５異常                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6A09','渦流量計異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B01','水計量シリンダリップシール交換時期                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B02','水計量シリンダキャップシール交換時期                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B03','水計量シリンダテープベアリング交換時期                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B04','Ｂ原液注入ポンプキャップシール交換時期                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B05','Ｂ原液注入ポンプテープベアリング交換時期                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B06','Ｂ原液注入ポンプスライダー交換時期                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B07','Ｂ原液注入ポンプポペットバルブ交換時期                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B08','Ａ原液注入ポンプキャップシール交換時期                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B09','Ａ原液注入ポンプテープベアリング交換時期                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B0A','Ａ原液注入ポンプスライダー交換時期                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B0B','Ａ原液注入ポンプポペットバルブ交換時期                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B0C','NaCl原液注入ポンプキャップシール交換時期                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B0D','NaCl原液注入ポンプテープベアリング交換時期                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B0E','NaCl原液注入ポンプスライダー交換時期                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B0F','NaCl原液注入ポンプポペットバルブ交換時期                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B10','送液ポンプメカニカルシール交換時期                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B11','脱気ポンプメカニカルシール交換時期                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B12','パワーユニットファンフィルタ交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('6B13','水計量シリンダ電磁弁交換時期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7801','RO水ドレイン温度','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7802','10μフィルタ入口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7803','カーボン入口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7804','LROポンプ入口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7805','LRO膜入口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7806','LRO膜出口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7807','ROポンプ入口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7808','RO膜入口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7809','RO膜出口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('780A','RO処理水圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('780B','送水ポンプ1出口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('780C','送水ポンプ2出口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('780D','RO水ドレインMV異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('780E','RO排水破棄流量センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('780F','10μフィルタ差圧超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7810','カーボンフィルタ差圧超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7811','LRO膜差圧超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7812','RO膜差圧超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7813','UVランプ積算時間超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7814','カーボンフィルタ積算時間超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7815','RO送水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7816','RO戻り水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7817','RO循環水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7818','RO排水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7819','RO排水戻り水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('781A','LRO処理水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('781B','LRO循環水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('781C','LRO排水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('781D','操作電源遮断','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('781E','操作電源復帰','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('781F','原水ヒータELBトリップ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7820','RO水ヒータELBトリップ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7821','LRO入口圧低下検知1回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7822','LRO入口圧低下検知2回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7824','RO入口圧低下検知2回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7825','RO処理水圧異常検知1回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7826','RO処理水圧異常検知2回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7827','RO水FL3故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7828','RO水FL4故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7829','RO水FL5故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('782A','RO水FL6故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('782B','RO水FL7故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('782C','RO水FL2故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('782D','原水水質センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('782E','LRO水水質センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('782F','RO水水質センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7830','LRO入口圧異常上昇検知1回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7831','LRO入口圧異常上昇検知2回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7832','RO入口圧異常上昇検知1回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7833','RO入口圧異常上昇検知2回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7834','排水回収RO膜差圧超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7835','濃縮水タンクUVランプ積算時間超過','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7836','回収ROポンプ入口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7837','排水回収RO膜入口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7838','排水回収RO膜出口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7839','回収水加圧ポンプ出口圧センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('783A','排水回収RO水水質センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('783B','排水回収タンク渇水検知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('783C','回収RO入口圧低下検知1回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('783D','回収RO入口圧低下検知2回目','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('783E','排水回収RO処理水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('783F','排水回収RO循環水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7840','排水回収RO排水量異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7841','薬液消毒キャンセル：許可信号未入力','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7842','薬液消毒キャンセル：装置停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7843','薬液消毒キャンセル：夜間運転中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7844','薬液消毒キャンセル：前処理バイパス','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7845','薬液消毒キャンセル：LROバイパス','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7846','薬液消毒キャンセル：ROバイパス','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7847','薬液消毒キャンセル：熱水消毒中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7848','薬液消毒キャンセル：緊急送水中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7849','薬液消毒キャンセル：送水P非自動','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('784A','薬液消毒キャンセル：警報発生中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('784B','薬液消毒キャンセル：2号単独選択','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('784C','薬液消毒許可信号入力','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('784D','薬液消毒許可信号切断','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('784E','薬液消毒運転自動開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('784F','薬液強制洗出し手動開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7850','薬液消毒中即中止スイッチ操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7851','薬液消毒中洗出し移行スイッチ操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7852','薬液消毒中警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7853','薬液消毒運転終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7854','熱水消毒キャンセル：要求信号未入力','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7855','熱水消毒キャンセル：装置非自動','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7856','熱水消毒キャンセル：夜間運転中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7857','熱水消毒キャンセル：前処理バイパス','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7858','熱水消毒キャンセル：LROバイパス','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7859','熱水消毒キャンセル：ROバイパス','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('785A','熱水消毒キャンセル：送水P非自動','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('785B','熱水消毒キャンセル：警報発生中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('785C','熱水消毒キャンセル：薬液消毒中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('785D','熱水消毒キャンセル：設定値非適正','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('785E','熱水消毒キャンセル：緊急送水中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('785F','熱水消毒キャンセル：RO水ヒータトリップ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7860','熱水消毒キャンセル：2号単独選択','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7861','熱水要求信号入力','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7862','熱水要求信号切断','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7863','RO水タンク以降熱水消毒自動開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7864','RO水タンク以降熱水消毒手動開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7865','システム熱水消毒自動開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7866','システム熱水消毒手動開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7867','強制冷却手動開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7868','熱水消毒中即中止スイッチ操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7869','熱水消毒中冷却移行スイッチ操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('786A','熱水消毒中警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('786B','熱水消毒運転終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('786C','熱水消毒中温調基盤故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('786D','熱水消毒中温調セル故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('786E','排水高温検知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('786F','熱水消毒RO水タンク補充中タイムアウト','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7870','熱水消毒中RO水タンク高温','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7871','加温/循環中RO水タンク水位低下','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7872','加温循環中温度未達成','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7873','熱水消毒キャンセル：回収タンクバイパス','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7874','薬液消毒キャンセル：回収タンクバイパス','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7875','漏水検知　検知帯','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7876','漏水検知　ポイントセンサ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7877','熱水消毒ｷｬﾝｾﾙ:給水要求信号','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('7878','薬液消毒ｷｬﾝｾﾙ:給水要求信号','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8001','静脈側微小気泡警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8002','静脈側通常気泡警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8003','動脈側微小気泡警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9741',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8004','動脈側通常気泡警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8005','気泡警報（微小気泡）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8006','気泡警報（通常）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8011','生食を検出                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8012','血液判別器オフセット異常                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8013','血液を検出                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8014','【血液を検出】静脈側','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8015','【血液を検出】動脈側','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8016','【血液(動脈側)を検出】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8101','静脈圧フルレンジ上限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8102','静脈圧フルレンジ下限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8103','静脈圧固定上限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8104','静脈圧固定下限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8105','静脈圧自動設定上限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8106','静脈圧自動設定下限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8107','静脈圧手動設定上限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8108','静脈圧手動設定下限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8201','動脈圧フルレンジ上限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8202','動脈圧フルレンジ下限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8203','動脈圧固定上限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8204','動脈圧固定下限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8205','動脈圧自動設定上限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8206','動脈圧自動設定下限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8301','ＴＭＰフルレンジ上限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8302','ＴＭＰフルレンジ下限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8303','ＴＭＰ固定上限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8304','ＴＭＰ固定下限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8305','ＴＭＰ自動設定上限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8306','ＴＭＰ自動設定下限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8307','ＴＭＰ自動追従上限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8308','ＴＭＰ自動追従下限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8401','透析液圧フルレンジ上限警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8402','透析液圧フルレンジ下限警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8403','透析液圧固定上限警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8404','透析液圧固定下限警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8405','透析液圧自動設定上限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8406','透析液圧自動設定下限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8407','透析液圧固定上限警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8500','漏血警報                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8511','補液不足警報                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8512','補液過剰警報                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8513','荷重計異常                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8514','補液不足警報（-600g）                                       ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8515','補液過剰警報（+600g）                                       ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8516','補液液切れ警報                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8517','補液過温度警報                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8518','プレートヒータ開警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8519','荷重計過負荷警報                       ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('851A','補液液切れ積算警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('851B','荷重値検出警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('851C','荷重値検出警報（HD,ECUM,OHDF,OHF）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('851D','【透析開始荷重値異常】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8520',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8521',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8522',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8523',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8524',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8525',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8526','【未接続警報】B原液ノズル','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8527','【未接続警報】A原液ノズル','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8528','【未接続警報】Na原液ノズル','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8529','サンプルポート開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('852A','熱水送水中信号が入力されました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('852B','排液ポート開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8530',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8531',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8532',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8541',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8542',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8543',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8544',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8545',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8546',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8550','サンプルポートを確認してください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8551','CF漏れテストが不合格です','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8552','サンプルポートが開いています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8553','サンプルポートを閉じてください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8554','サンプルポートを開き補液回路を接続してください','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8555','サンプルポートが開きました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8556','CF漏れテストを合格しないとオンライン補充液(透析液)を使用できません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8557','サンプルポートから外して下さい','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8558','サンプルポートノブヒータ  異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8560','【BP締切テスト不合格】タイムアウト','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8561','【BP締切テスト不合格】締切異常（陰圧）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8562','【BP締切テスト不合格】締切異常（復元）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8570','気泡を検出しませんでした(静脈側)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8571','気泡を検出しませんでした(動脈側)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8580','【血流量不足率警報】上限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8581','【血流量不足率警報】固定上限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8582','【推定血流量モニタ 電圧異常】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8583','血液回路　取り外し検知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8601','過温度警報                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8602','温度フルレンジ下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8603','温度上限警報                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8604','温度下限警報                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8605','熱湯消毒温度警報上限                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8606','熱水消毒温度低警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8611','温度警報消毒高                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8612','温度警報消毒低                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8621','ヒータ出口温度異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8622',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8623',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8624','Z-Sコネクタ接続異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8630','消毒未完了警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8631','消毒未実施警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8632','過酢酸消毒時間が不足しています                                     ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8700','給水圧警報                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8701','ダイアライザー血液入口圧フルレンジ上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8702','ダイアライザー血液入口圧フルレンジ下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8703','ダイアライザー血圧入口圧固定上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8704','ダイアライザー血圧入口圧固定下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8705','ダイアライザー血圧入口圧自動上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8706','ダイアライザー血圧入口圧自動下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8710','動脈圧フルレンジ上限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8711','動脈圧フルレンジ下限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8712','動脈圧固定上限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8713','動脈圧固定下限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8714','動脈圧自動設定上限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8715','動脈圧自動設定下限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8800','給液警報                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8811','給液圧警報上限                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8812','給液圧警報下限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8813','給液圧センサ異常                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8900','バイパス警報                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8901','カップリング漏れテスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8902','漏水検知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8903','漏水検知器自己診断 不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8A01','Ｂ液濃度フルレンジ上限警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8A02','Ｂ液濃度フルレンジ下限警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8A03','Ｂ液濃度上限警報                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8A04','Ｂ液濃度下限警報                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8B01','透析液濃度フルレンジ上限警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8B02','透析液濃度フルレンジ下限警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8B03','透析液濃度上限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8B04','透析液濃度下限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8C01','Ｎａ濃度フルレンジ上限警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8C02','Ｎａ濃度フルレンジ下限警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8C03','Ｎａ濃度固定上限警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8C04','Ｎａ濃度固定下限警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8C05','Ｎａ濃度自動設定上限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8C06','Ｎａ濃度自動設定下限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8D00','脱血圧警報                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8D01','脱血警報　動脈側血液判別器','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8D02','脱血警報　静脈側血液判別器','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8D03','返血警報　静水圧','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8D04','返血警報　動脈側血液判別器','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8D05','返血前回路接続テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8E00','停電警報                                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8E01','血液ポンプが停止しています','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8E02','血液ポンプ停止警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8F00','ＴＭＰゼロ補正値異常警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8F01','ＴＭＰゼロ補正値上限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('8F02','ＴＭＰゼロ補正値下限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9001','初期ＵＦＲ上限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9002','初期ＵＦＲ下限警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9100','ＵＦＲ低下警報                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9200','シングルニードル採血時間警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9300','シングルニードル返血時間警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9301','ＳＮ警報上限                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9302','ＳＮ警報下限                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9401','動静脈差圧固定上限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9402','動静脈差圧固定下限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9403','動静脈差圧自動設定上限警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9404','動静脈差圧自動設定下限警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9405','動静脈差圧警報フルレンジ上限                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9406','動静脈差圧警報フルレンジ下限                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9407','ダイアライザー差圧固定上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9408','ダイアライザー差圧固定下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9409','ダイアライザー差圧自動上限警報  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('940A','ダイアライザー差圧自動下限警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('940B','ダイアライザー差圧フルレンジ上限警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('940C','ダイアライザー差圧フルレンジ下限警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9410','【脱血不良】（動脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9411','【脱血不良】（静脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9412','【脱血警報】（透析液圧）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9413','【返血不良】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9414','【動脈返血時に気泡を検知しました】通常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9415','【動脈返血時に気泡を検知しました】微小','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9416','【推定血流量モニタ警報】返血圧異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9480','薬液消毒濃度が設定濃度に達していません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9481','クエン酸熱水消毒濃度が設定濃度に達していません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9482','薬液消毒時間が最低消毒時間に達していません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9483','クエン酸熱水消毒時間が最低消毒時間に達していません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9484','薬液消毒時の注入量が必要液量に達していません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9485','洗浄，熱水消毒中に一時停止しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9501','液圧センサ異常警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9502','透析液圧開放電磁弁異常警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9503','カスケードポンプ異常警報、又は脱ガス電磁弁閉塞','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9504','配管漏れ異常警報                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9505','除水ポンプ異常警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9506','バランス異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9507','バランス温度異常警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9508','ＵＦＲＣ自己診断未実施警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9509','脱ガス器フロートスイッチ異常警報（ＵＦＲＣ）                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('950a','脱ガス器フロートスイッチ異常警報                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('950b','微粒子除去フィルターテスト電磁弁異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('950c','微粒子除去フィルター漏れ異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('950d','微粒子除去フィルターテスト電磁弁異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('950e','透析液出口電磁弁、又はバイパス電磁弁異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('950f','透析液戻り口電磁弁異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9510','ヒータ制御サーミスタ断線警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9511','温度制御サーミスタ断線警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9512','温度指示サーミスタ断線警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9513','Ｂ液濃度サーミスタ断線警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9514','透析液濃度サーミスタ断線警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9515','Ｎａ濃度サーミスタ断線警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9516','濃度制御サーミスタ断線警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('951A','プレートヒータ制御サーミスタ断線警報                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('951B','補液チューブサーミスタ断線警報                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('951C','プレートヒータ指示サーミスタ断線警報                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('951D','ヒータ監視サーミスタ断線警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('951E','濃度サーミスタ断線警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('951F','原液ノズル洗浄サーミスタ断線警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9520','ヒータ制御サーミスタ短絡警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9521','温度制御サーミスタ短絡警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9522','温度指示サーミスタ短絡警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9523','Ｂ液濃度サーミスタ短絡警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9524','透析液濃度サーミスタ短絡警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9525','Ｎａ濃度サーミスタ短絡警報                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9526','ＴＨ１，ＴＨ２比較テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9527','ＴＨ３，ＴＨ４比較テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9528','セル２，セル３比較テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9529','セル４，セル５比較テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('952A','プレートヒータ制御サーミスタ短絡警報                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('952B','補液チューブサーミスタ短絡警報                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('952C','プレートヒータ指示サーミスタ短絡警報                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('952D','ヒータ監視サーミスタ短絡警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('952E','濃度サーミスタ短絡警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('952F','原液ノズル洗浄サーミスタ短絡警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9530',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9531',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9532',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9533','気泡検出器テスト不良警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9534','カスケードポンプ制御不良警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9535','複式ポンプ制御不良警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9536','血液ポンプ制御不良警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9537','動脈血液ポンプ制御不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9538','静脈血液ポンプ制御不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9539',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('953A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('953B','補液ポンプ制御不良警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('953C','血液ポンプ逆転警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('953D','静脈血液ポンプ逆回転警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('953E','脱気ポンプ 制御不良警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('953F','加圧ポンプ 制御不良警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9540','漏血検出器汚れ警報                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9541',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9542','漏血検出器動作不良警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9543','漏血検出器汚れ警報（緑）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9544','漏血検出器汚れ警報（赤）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9545','漏血検出器テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9546',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9547','血液ポンプドライバ CPU Watch Dog警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9548','補液ポンプドライバ CPU Watch Dog警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9550',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9551','濃度自己診断Ｂ液上限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9552','濃度自己診断Ｂ液下限警報                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9553','濃度自己診断透析液上限警報                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9554','濃度自己診断透析液下限警報                                 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9555','濃度自己診断測定不可','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9556',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9557','電導度セル５、電導度セル６比較テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9558','電導度セル１、電導度セル２比較テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9559','電導度セル３、電導度セル４比較テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('955A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('955B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('955C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('955D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('955E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9560','電池容量低下警報                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9561','静脈圧センサ異常警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9562','動脈圧センサ異常警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9563','脱ガス器フロートＳＷ異常警報                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9564','動脈圧センサ比較テスト不合格                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9567',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9568','タッチパネル異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9569','血液ポンプ電源スイッチ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('956A','ブザー停止スイッチ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('956B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('956C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('956D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('956E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('956F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9570','除水ポンプ吐出テスト異常                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9571','＋１５Ｖ異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9572','－１５Ｖ異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9573','＋２４Ｖ異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9574','＋１２Ｖ異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9575','－１２Ｖ異常                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9576','＋１２Ｖ異常（保護側）                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9577','－１２Ｖ異常（保護側）                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9578','＋１２Ｖ異常（制御側）                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9579','－１２Ｖ異常（制御側）                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('957A','５Ｖ 異常（監視側） ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('957B','５Ｖ 異常（制御側） ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('957C','１２Ｖ 異常（監視側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('957D','１２Ｖ 異常（制御側） ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9581','複式ポンプ過負荷                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9582','カスケードポンプ過負荷                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9583','血液ポンプ過負荷                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9584','動脈血液ポンプ過負荷                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9585','静脈血液ポンプ過負荷                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9586','補液ポンプ過負荷                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9587','脱気ポンプ過負荷警','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9588','加圧ポンプ過負荷','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9589','脱気ポンプ ロック警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('958A','加圧ポンプ ロック警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9591','バランス異常（＋）                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9592','バランス異常（－）                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9593',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9594',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9595',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9596',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A1','複式ポンプ速度異常上限                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A2','複式ポンプ速度異常下限                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A3','カスケードポンプ速度異常上限                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A4','カスケードポンプ速度異常下限                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A5','血液ポンプ速度異常上限                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A6','血液ポンプ速度異常下限                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A7','ＩＰ速度異常上限                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A8','ＩＰ速度異常下限                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95A9','カスケ－ドポンプロック                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95AA','補液ポンプ速度異常上限                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95AB','補液ポンプ速度異常下限                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95AC','脱気ポンプ 回転数警報（上限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95AD','脱気ポンプ 回転数警報（下限） ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95AE','加圧ポンプ 回転数警報（上限） ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95AF','加圧ポンプ 回転数警報（下限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B1','気泡検出器テスト不良（動脈側微小気泡検出器）                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B2','気泡検出器テスト不良（動脈側通常気泡検出器）                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B3','気泡検出器テスト不良（静脈側微小気泡検出器）                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B4','気泡検出器テスト不良（静脈側通常気泡検出器）                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B5','液切れ検出器テスト不良                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B6','気包検出器警報（通常）                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B7','気包検出器警報（微小）                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B8','気包検出器警報（テスト）                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95B9','気泡テスト不合格　補液切れ通常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95BA','TFB156 【気泡テスト不合格】動脈側テスト','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95BB','TFB151 【気泡テスト不合格】静脈側テスト','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95BC','TFB159 【気泡テスト不合格】生食液切れ通常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C0','透析液流量低下','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C1','除水ポンプ流量警報 上限                                     ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C2','除水ポンプ流量警報 下限                                     ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C3','除水ポンプセル１（吸込側）電圧異常警報                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C4','除水ポンプセル１（吸込側）締切警報                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C5','除水ポンプセル２（吐出側）電圧異常警報                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C6','除水ポンプセル２（吐出側）締切警報                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C7','複式ポンプ（給液側）流量警報上限                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C8','複式ポンプ（給液側）流量警報下限                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95C9','複式ポンプ（排液側）流量警報上限                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95CA','複式ポンプ（排液側）流量警報下限                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95CB','複式ポンプセル１ （給液側吸込）締切警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95CC','複式ポンプセル２ （給液側吐出）締切警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95CD','複式ポンプセル３ （排液側吸込）締切警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95CE','複式ポンプセル４ （排液側吐出）締切警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95CF','除水ポンプ吐出低警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95D0','複式ポンプセル開閉異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95D1','漏血電圧不良上限警報（緑）                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95D2','漏血電圧不良下限警報（緑）                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95D3','漏血電圧不良上限警報（赤）                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95D4','漏血電圧不良下限警報（赤）                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95D5','漏血検出器テスト未実施警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95D6','漏血オフセット電圧異常（緑 上限） ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95D7','漏血オフセット電圧異常（赤 上限） ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95E1','ＩＰ制御不良                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95E2','【IP閉塞】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95F1','濃度自己診断未実施                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95F2','補液加温バッグテスト未実施警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95F3','補液ヒータリレーテスト不合格　切','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95F4','補液ヒータリレーテスト不合格　入','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95F5','補液ポンプ テスト不合格　停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95F6','補液ポンプ テスト不合格　回転','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('95F7','補液ポンプ逆回転警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9601','動脈血液ポンプ速度異常上限                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9602','動脈血液ポンプ速度異常下限                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9603','静脈血液ポンプ速度異常上限                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9604','静脈血液ポンプ速度異常下限                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9605','ＩＰ逆回転警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9606',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9608','動脈クランプ動作異常 開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9609','動脈クランプ動作異常 閉','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('960A','静脈クランプ動作異常 開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('960B','静脈クランプ動作異常 閉','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('960C','生食クランプ動作異常 開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('960D','生食クランプ動作異常 閉','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('960E','排液クランプ動作異常 開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('960F','排液クランプ動作異常 閉','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9742',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9611','Ｂ液濃度－１０％高異常                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9612','Ｂ液濃度－１０％低異常                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9613','Ｂ液濃度    ０％高異常                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9614','Ｂ液濃度    ０％低異常                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9621','透析液濃度－１０％高異常                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9622','透析液濃度－１０％低異常                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9623','透析液濃度    ０％高異常                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9624','透析液濃度    ０％低異常                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9631','薬液消毒濃度過剰                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9632','薬液消毒濃度不足                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9640','補液加温バッグテスト開始圧異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9641','補液加温バッグテスト加圧不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9642','補液加温バッグテスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9643','補液加温バッグ漏れ検出警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9644','給水圧センサテスト不合格                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9645','熱交換器漏れテスト不合格                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9646',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9647','バランステスト中の温度変化異常                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9648',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9649','ＳＶ１３ テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('964A','除水ポンプ リレーテスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('964B','温度制御不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('964C','エンドトキシン カットフィルタ目詰りテスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('964D','ＳＶ４１ テスト不合格 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('964E','減圧テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('964F','ＴＨ１１テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9650','静脈クランプ「開」テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9651','静脈クランプ「閉」テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9652','動脈血液ポンプ停止テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9653','動脈血液ポンプ回転テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9654','血液系圧力センサ開放テスト不合格                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9655','血液系圧力センサ加圧時間オ－バ－                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9656','血液系圧力センサ加圧テスト不合格                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9657','動脈クランプ「開」テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9658','動脈クランプ「閉」テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9659','静脈血液ポンプ停止テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('965A','ダブルポンプシングルニードル選択出来ません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('965B','ヒータ電源遮断テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('965C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('965D','バイパスリレー テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('965E','配管漏れ テスト（陰圧方式）不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('965F','配管漏れ テスト（陽圧方式）不合格  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9660','静脈血液ポンプ回転テスト不合格                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9661','血液判別器オフセット電圧異常                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9662','［血液以外］判別テスト不合格                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9663','バッテリーコネクタ未接続','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9664','バッテリ－電圧低下                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9665','バッテリ－容量不足                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9666','ＳＮ圧センサテスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9667','血液ポンプ 停止テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9668','血液ポンプ 回転テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9669','バッテリ運転スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('966A','血液回路取付自己診断 不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('966B','クランプ漏れテスト 不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('966C','CF1漏れテスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('966D','CF2漏れテスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('966E','給液圧／透析液圧センサ比較テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9670','給液側背圧弁設定不良警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9671','排液側背圧弁設定不良警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9672','SV31締切検出器閉テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9673','SV31締切検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9674','SV31/32リレーテスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9675',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9676',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9677',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9678',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9680','濃度が立ち上がっていない可能性がありますのでガスパージを延長','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9681','濃度が立ち上がっていない可能性があります','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9685',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9686',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9687',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9688',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9689',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('968A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('968B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('968C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9690','補液バックと補液量設定値を確認して下さい','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96A0','透析液出口電磁弁異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96A1','バイパス電磁弁異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96AB','ＳＶ９締め切り検出器テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96AC','ＳＶ９締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96AD','ＳＶ１０締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9743',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96AE','ＳＶ９締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96AF','ＳＶ１０締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B0','ＳＶ４締め切り検出器テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B1','ＳＶ５締め切り検出器テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B2','ＳＶ６締め切り検出器テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B3','ＳＶ７締め切り検出器テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B4','ＳＶ８締め切り検出器テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B5','ＳＶ４締め切り検出器閉テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B6','ＳＶ５締め切り検出器閉テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B7','ＳＶ６締め切り検出器閉テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B8','ＳＶ７締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96B9','ＳＶ８締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96BA','ＳＶ４締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96BB','ＳＶ５締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96BC','ＳＶ６締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96BD','ＳＶ７締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96BE','ＳＶ８締め切り検出器開テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96BF',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C0','ＳＶ４漏れ警報　（漏れ量：小）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C1','ＳＶ５漏れ警報　（漏れ量：小）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C2','ＳＶ６漏れ警報　（漏れ量：小）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C3','ＳＶ７漏れ警報　（漏れ量：小）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C4','ＳＶ８漏れ警報　（漏れ量：小）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C5','ＳＶ９漏れ警報　（漏れ量：小）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C6','ＳＶ１０漏れ警報　（漏れ量：小）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C7','ＳＶ３１漏れ警報　（漏れ量：小）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C8','ＳＶ４漏れ警報　（漏れ量：大）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96C9','ＳＶ５漏れ警報　（漏れ量：大）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96CA','ＳＶ６漏れ警報　（漏れ量：大）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96CB','ＳＶ７漏れ警報　（漏れ量：大）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96CC','ＳＶ８漏れ警報　（漏れ量：大）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96CD','ＳＶ９漏れ警報　（漏れ量：大）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96CE','ＳＶ１０漏れ警報　（漏れ量：大）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96CF','ＳＶ３１漏れ警報　（漏れ量：大）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96D0','ＳＶ４警報（開いていません）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96D1','ＳＶ５警報（開いていません）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96D2','ＳＶ６警報（開いていません）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96D3','ＳＶ７警報（開いていません）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96D4','ＳＶ６３，６４警報（開いていません）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96D5','ＳＶ８警報（開いていません）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96D6','ＳＶ９警報（開いていません）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96D7','ＳＶ１０警報（開いていません）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96E0','背圧弁Ｈ１（給液側）設定不良警報 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96E1','背圧弁Ｈ２（排液側）設定不良警報  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96E5',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96E6',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96E7',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96E8',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96E9',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96EA',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96EB',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96EC',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F0','TH1,TH2比較テスト不合格　ゼロ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F1','TH3,TH4比較テスト不合格　ゼロ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F2','TH1,TH2比較テスト不合格　スパン','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F3','TH3,TH4比較テスト不合格　スパン','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F4','TH1,TH2比較テスト不合格　高温','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F5','TH3,TH4比較テスト不合格　高温','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F6',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F7',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F8',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('96F9',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9701','Ｂ液洗浄口未接続警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9702','Ａ液洗浄口未接続警報                                 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9703','Ｎａ洗浄口未接続警報                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9710','補液回路接続ﾃｽﾄ不合格・開始圧','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9711','補液回路接続ﾃｽﾄ不合格・加圧','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9712','補液回路接続テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9713','補液回路接続ﾃｽﾄ不合格・ポート接続','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9714',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9715','【補液回路接続エラー】（圧不足）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9716','【補液回路接続エラー】（圧力保持）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9720',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9721',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9722',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9723',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9724',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9725',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9726',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9727',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9728',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9729',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('972A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('972D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('972E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('972F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9730',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9731',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9732',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9733',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9734',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9735',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9736',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9737',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9738',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9739',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('973A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('973B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('973C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('973D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('973E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9740',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9744',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9745',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9746',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9747',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9748',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9749',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('974A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('974B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('974C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('974D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('974E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9752',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9753',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9756',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9757',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9758',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9759',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('975F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9762',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9763',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9766',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9767',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9768',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9769',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('976F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9780',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9781',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9782',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9783',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9784',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9785',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9786',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9787',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9788',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9789',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('978A',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('978B',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('978C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('978D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('978E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('978F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9790',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9791',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9792',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9793',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9794',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9795','ノズルライン洗浄不足警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9796','Na原液ノズルが装置に戻されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A0','動脈クランプ テスト不合格　開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A1','動脈クランプ テスト不合格　閉','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A2','生食クランプ テスト不合格　開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A3','生食クランプ テスト不合格　閉','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A4','ｵｰﾊﾞｰﾌﾛｰｸランプ テスト不合格　開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A5','ｵｰﾊﾞｰﾌﾛｰｸランプ テスト不合格　閉','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A6','生食クランプ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A7','オーバーフロークランプ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A8','動脈クランプ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97A9','静脈クランプ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97AA','動脈側血液判別器オフセット異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97AB','ﾌﾟﾗｲﾐﾝｸﾞｸランプ テスト不合格　開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97AC','ﾌﾟﾗｲﾐﾝｸﾞｸランプ テスト不合格　閉','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97AD','プライミングクランプ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97B0','オーバーフローライン閉塞','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97B1','気泡検知 時間切れ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97B2','オーバーフローライン開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97C0','静脈 血液回路がセットされていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97C1','動脈 血液回路がセットされていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97C2','生食 血液回路がセットされていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97C3','ｵｰﾊﾞｰﾌﾛｰ 血液回路がセットされていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97C4','血液回路装着エラー(静脈圧）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97C5','血液回路装着エラー（ﾀﾞｲｱﾗｲｻﾞｰ入口圧）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97C6','血液回路装着エラー（回数）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97C7',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97D0','生理食塩液　液切れ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97D1','脱血不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97D2','返血不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97D3','脱血不良（動脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97D4','脱血不良（静脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97D5','脱血警報（透析液圧）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97E0','回路検出器エラー（静脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97E1','回路検出器エラー（動脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97E2','回路検出器エラー（生食）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97E3','回路検出器エラー（オーバーフロー）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('97E4',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9801','最高血圧上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9802','最高血圧下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9803',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9804',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9805','血圧測定警報（C11 カフホース点検）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9806','血圧測定警報（C12 再測定（カフ点検））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9807','血圧測定警報（C13 再測定（体動））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9808','血圧測定警報（C14 再測定（加圧不足））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9809','血圧測定警報（C15 再測定（体動・不整脈））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('980A','血圧測定警報（C16 再測定（体動・不整脈））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('980B','血圧測定警報（C17 測定時間オーバー）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('980C','血圧測定警報（C18 再測定（体動））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('980D','血圧測定警報（C19 再測定（異常加圧））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('980E','血圧測定警報（C20 脈検出不能）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('980F','血圧測定警報（C21 再測定（カフサイズ））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9810','血圧計警報（E03 圧力センサ）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9811','血圧計警報（E07 A/Dオフセット）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9812','血圧計警報（E08 サブＣＰＵとの通信タイムアウト）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9813','血圧計警報（E08 メインＣＰＵのWatch Dog）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9814','血圧計警報（E09 カフ圧監視（成人））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9815','血圧計警報（E09 締め付け時間監視（成人））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9816','血圧計警報（E09 ゼロ校正）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9817','血圧計警報（E09 電圧監視（2.5V））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9818','血圧計警報（E09 Watch Dog）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9819','血圧計警報（E09 幼児昇圧監視）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('981A','血圧計警報（E09 圧力比較）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('981B','血圧計警報（E09 短期測定継続時間監視）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('981C','血圧計警報（E09 連続測定継続時間監視）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('981D','血圧計警報（E09 安全確保機能）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('981E','血圧計警報（E09 電圧監視（4.096V））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('981F','血圧計警報（E09 電圧監視（3.25V））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9820','血圧計警報（E09 カフ圧監視（幼児））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9821','血圧計警報（E09 締め付け時間監視（幼児））','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9822','血圧計警報（E09 ROＭテスト）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9823','血圧計警報（E09 ＲＡＭテスト）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9824','血圧計：通信エラー','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9825','平均血圧上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9826','平均血圧下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9827','最低血圧上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9828','最低血圧下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9829','脈拍上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('982A','脈拍下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('982B','血圧計警報（E09 圧力開放時間監視）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('982C','血圧測定異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('982D','血圧計エラー','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9830','透析量モニタ通信不良警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9831','透析量モニタ　バージョン不一致警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9832','透析量モニタキャリブレーション未実施警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9833','透析量モニタ　校正タイムアウト警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9834','透析量モニタ　校正警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9835','透析量モニタ　データ不一致警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9836','透析量モニタ　自己診断警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('983E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('983F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9840',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9841',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9842',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9843',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9844',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9850','血圧測定警報（C50 カフ閉塞）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9851','血圧測定警報（C51 再測定）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9852','血圧測定警報（C52 血圧測定範囲外）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9853','血圧測定警報（C53 測定時間オーバー）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9854','血圧計警報（E09　再測定）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9855','血圧計警報（E09　血圧測定範囲外）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9900','運転入れ忘れ警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9901','ＢＰ電源切り警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9902','ＢＰカバー開警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9903','ＢＰ速度０警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9904','最高血圧上限警報動作が解除されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9905','最高血圧下限警報動作が解除されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9906','血液回路無し (静脈)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9907','血液回路無し (動脈)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9908','血液回路無し (生食)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9909','血液回路無し (排液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9A01','静脈回路の装着位置を確認し、必要ならば','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9A02','静脈回路の位置を変更して下さい。','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9A03','複式ポンプ新旧選択確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B00','漏血警報オーバーライド中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B01','動脈圧警報オーバーライド中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B02','静脈圧警報オーバーライド中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B03','気泡警報オーバーライド中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B04','ダイアライザー入口圧警報オーバーライド中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B20','プライミング警報 液切れ検出器','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B21','プライミング警報 動脈ﾁｬﾝﾊﾞﾚﾍﾞﾙ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B22','プライミング警報 静脈側気泡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B23','プライミング警報 静脈ﾁｬﾝﾊﾞﾚﾍﾞﾙ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B24','SV5テスト　不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B25','SV4,6テスト　不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9B26','【落差工程不良】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C00',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C01','ΔＢＶ変化率警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C04','ΔＢＶ低下警報１','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C05','ΔＢＶ低下警報２','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C06',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C07',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C80','ＢＶ受光電圧比較テスト不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C81','ＢＶ外乱光オフセット電圧異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C82','ＢＶ受光電圧上限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C83','ＢＶ受光電圧下限警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9C84','【BV受光電圧比較テスト(消灯)】不合格','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9CA3',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D00','静脈 血液回路がセットされていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D01','動脈 血液回路がセットされていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D02','生食 血液回路がセットされていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D03','ｵｰﾊﾞｰﾌﾛｰ 血液回路がセットされていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D04','生理食塩液　液切れ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D05','脱血不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D06','血液回路装着エラー(静脈圧）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D07','血液回路装着エラー（ﾀﾞｲｱﾗｲｻﾞｰ入口圧）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D08','血液回路装着エラー（回数）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D09','返血不良','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D0A','脱血不良（動脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D0B','脱血不良（静脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D0C','脱血警報（透析液圧）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D0D','血液回路装着エラー（操作）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D0E','プライミング 血液回路の取り外し操作を検知しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D0F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D10','回路検出器エラー（静脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D11','回路検出器エラー（動脈側）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D12','回路検出器エラー（生食）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D13','回路検出器エラー（オーバーフロー）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D14','サンプルポート接続エラー（圧不足）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D15','サンプルポート接続エラー（圧力保持）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D16','サンプルポート接続エラー（複式セル）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D17','補液回路接続エラー（圧不足）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D18','補液回路接続エラー（圧力保持）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D20',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9D21',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9E01',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9E02',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9E03',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9E04',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F00','液温警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F01','濃度警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F02','静脈圧警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F03','液圧警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F04','ＴＭＰ警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F05','気泡検知警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F06','漏血警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F07','その他警報発生','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F08',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('9F09',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A001','B液濃度警報（下限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A002','B液濃度警報（上限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A003','透析液濃度警報（下限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A004','透析液濃度警報（上限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A005','貯槽液濃度警報（下限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A006','貯槽液濃度警報（上限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A007',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A008',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A010','B原液濃度異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A011','A原液濃度異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A100','過温度警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A200','給水圧警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A300','貯槽液位低警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A401','原液減警報（B）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A402','原液減警報（A）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A403',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A500','バイパス警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A601',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A602',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A603',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A611',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A612',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A613',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A621',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A622',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A623',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A630',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A641',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A642',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A643',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A644',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A650',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A660',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A670','TFD105 RO装置熱水工程警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A701','TFD102 給水監視異常1警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A702','TFD201 給水監視異常2警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A800','熱水消毒温度警報（上限）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A901','配管テスト注水異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A902','配管テストLVS1異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A903','配管テストLVS2異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A904','配管テスト排液異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A905','配管テストLVS3異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A906','配管テスト給水圧力センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A907','配管テスト送液圧力センサ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A908','配管テストヒータ遮断回路異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A90A','配管テストMV17漏れ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A90B','配管テストMV17漏れ未確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A911','希釈テスト B液濃度-10%異常下限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A912','希釈テスト B液濃度-10%異常上限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A913','希釈テスト 透析液濃度-10%異常下限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A914','希釈テスト 透析液濃度-10%異常下限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A915','希釈テスト B液濃度  0%異常下限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A916','希釈テスト B液濃度  0%異常上限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A917','希釈テスト 透析液濃度  0%異常下限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('A918','希釈テスト 透析液濃度  0%異常上限','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA01','TFD251 サーミスタ1断線','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA02','TFD251 サーミスタ2断線','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA03','TFD251 サーミスタ3断線','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA04','TFD251 サーミスタ4断線','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA05','TFD251 サーミスタ5断線','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA06','TFD251 サーミスタ6断線','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA07','TFD251 サーミスタ7断線','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA08','TFD251 サーミスタ8断線','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA11','TFD252 サーミスタ1短絡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA12','TFD252 サーミスタ2短絡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA13','TFD252 サーミスタ3短絡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA14','TFD252 サーミスタ4短絡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA15','TFD252 サーミスタ5短絡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA16','TFD252 サーミスタ6短絡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA17','TFD252 サーミスタ7短絡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA18','TFD252 サーミスタ8短絡','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA20','貯槽サーミスタ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AA21','ヒータ出口サーミスタ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB01','TFD224 B原液ポンプ過負荷報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB02','TFD225 A原液ポンプ過負荷報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB03','TFD226 薬液ポンプ過負荷報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB11','TFD221 B原液ポンプ制御異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB12','TFD222 A原液ポンプ制御異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB13','TFD223 薬液ポンプ制御異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB21','TFD231 B原液ライン逆流報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB22','TFD232 A原液ライン逆流報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB23',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB24','TFD234 薬液ライン逆流報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB25','TFD235 酸洗浄液ライン逆流報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB26','TFD104 薬液注入ライン薬液検知警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB27','TFD273 薬液濃度異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AB30',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC01','TFD202 給水圧センサ異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC02','TFD202 給水圧センサテスト実行不可','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC03','給水圧力負圧報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC04','給水流量上限報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC05','TFD205 水計量シリンダのロータリーエンコーダ異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC06','TFD206 水計量シリンダの電磁弁異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC07','TFD207 予備流量計異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC08','TFD208 予備透析実施不可報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AC09','給水流量下限報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AD01','送液圧力低下報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AD02','TFD212 送液圧力上昇報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AD11',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AD12',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AD13','TFD227 脱気ポンプ異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AE01','TFD241 B原液電導度セル電極汚れ検知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AE02','TFD242 A原液電導度セル電極汚れ検知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AE03','TFXXXX 貯槽液濃度セル異常（CEL3）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AE04','TFXXXX 貯槽液濃度セル異常（CEL4）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AE10','TFD103 溶解装置異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF00','TFD101 漏水警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF01',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF02',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF03',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF04',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF11','薬液減警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF12','酸洗浄減警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF21','補助運転','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF22',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF23',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF30',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF31',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF32','TFD262 MV18異常報知','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF40','TFE900 【タッチパネル異常】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF41','TFE901 【送液スイッチ異常】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF42','TFE101 電気部冷却ファン異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF43','TFE902 【ブザー停止スイッチ異常】','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF44','TFE102 パワーユニット温度異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF45','TFE115 バックアップユニット異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF50',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF51',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('AF80','RO装置のタイマ設定が変更されていません','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B801','原水ポンプインバータ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B802','LROポンプインバータ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B803','ROポンプインバータ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B804','送水ポンプ1インバータ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B805','送水ポンプ2インバータ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B806','原水ポンプインバータ通信異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B807','LROポンプインバータ通信異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B808','ROポンプインバータ通信異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B809','送水ポンプ1インバータ通信異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B80A','送水ポンプ2インバータ通信異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B80B','加圧ポンプ故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B80C','通信ユニットポート1異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B80D','通信ユニットポート2異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B80E','メイン基盤受信異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B80F','メイン基盤送信異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B810','サブ基盤異常：I/O基盤','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B811','サブ基盤異常：温度基盤','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B812','サブ基盤異常：A/D基盤','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B813','サブ基盤異常：D/A基盤','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B814','漏水警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B815','RO水タンク満水警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B816','RO水タンク低水位警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B817','LRO入口圧低下警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B818','RO入口圧低下警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B819','RO処理水圧異常警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B81A','RO送水流量センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B81B','RO戻り流量センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B81C','ROバイパスMV開異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B81D','ROバイパスMV閉異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B81E','薬液遮断MV開異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B81F','薬液遮断MV閉異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B820','原水高温警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B821','RO水タンク高温警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B822','排水高温警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B823','温度セル故障：原水','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B824','温度セル故障：原水監視','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B825','温度セル故障：カーボン出口','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B826','温度セル故障：LRO膜出口','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B827','温度セル故障：RO膜出口','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B828','温度セル故障：RO水','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B829','温度セル故障：排水','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B82A','RO排水流量センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B82B','温度セル故障：原水高温監視','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B82C','温度セル故障：RO水タンク高温監視','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B82D','温度セル故障：排水高温監視','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B82E','LRO入口圧異常上昇','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B82F','RO入口圧異常上昇','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B830','塩素濃度異常：1系','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B831','塩素濃度異常：2系','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B832',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B833','濃縮水ポンプ故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B834','排水回収ROポンプ故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B835','回収水加圧ポンプ故障','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B836','濃縮水タンク高温警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B837','排水回収タンク渇水警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B838','回収RO入口圧低下警報','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B839','排水回収RO処理水流量センサ異常','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('B83A','温度セル故障：濃縮水','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('C001','設定データ変更 [%d] [%d]                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('C002','変更内容（前） [%d] [%d]                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('C003','変更内容（後） [%d] [%d]                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D001','データベース１ＮＣイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D002','データベース１ＮＣイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D003','データベース１Ｃイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D004','データベース１Ｃイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D005','データベース１イニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D006','データベース１イニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D007','データベース２Ｎイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D008','データベース２Ｎイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D009','データベース２Ｃイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D00A','データベース２Ｃイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D00B','データベース２ＫＣイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D00C','データベース２ＫＣイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D00D','データベース３ＮＣイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D00E','データベース３ＮＣイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D00F','データベース３Ｎイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D010','データベース３Ｎイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D011','データベース３Ｃイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D012','データベース３Ｃイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D013','データベース１Ｎイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D014','データベース１Ｎイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D015','データベース２イニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D016','データベース２イニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D017','データベース２Ｋイニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D018','データベース２Ｋイニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D019','データベース３イニシャル(制御)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('D01A','データベース３イニシャル(監視)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F000','警報、報知リセット                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F100','自動応答センサ　ON','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F101','自動応答センサ　OFF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F201','プリセット                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F202','洗浄                                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F203','酸洗                                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F204','消毒','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F205','滞留                                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F206','液置換                                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F207','準備回収（ＨＤ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F208','ガスパージ                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F209','排液                                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F20A','停止（ＨＤ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F20B','運転（ＨＤ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F20C','準備回収（ＥＣＵＭ）                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F20D','停止（ＥＣＵＭ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F20E','運転（ＥＣＵＭ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F20F','準備回収（ＨＤＦ）                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F210','停止（ＨＤＦ）                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F211','運転（ＨＤＦ）                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F212','準備回収（ＨＦ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F213','停止（ＨＦ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F214','運転（ＨＦ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F215','液置換（待機）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F216','洗浄待機（送液停止待ち）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F217','洗浄待機（送液待ち）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F218','準備回収（待機）                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F219','準備回収（ＡＦＢＦ）                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F21A','停止（ＡＦＢＦ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F21B','運転（ＡＦＢＦ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F21C','酢酸消毒','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F21D','次亜塩素酸ナトリウム消毒','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F21E',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F21F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F220',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F221','クエン酸熱水　消毒','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F222','過酢酸消毒                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F223','熱水消毒                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F224','ＤＭテスト                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F225','ＤＭテスト終了                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F226','準備ガスパージ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F227','準備ガスパージ終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F228','膜洗浄                                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F229','膜洗浄終了                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F22A','膜加温','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F22B','クエン酸熱水（待機）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F22C','クエン酸熱水（注入）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F22D','クエン酸熱水（排液）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F22E','クエン酸熱水（循環）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F22F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F230','準備（ＨＤ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F231','治療（ＨＤ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F232','治療停止（ＨＤ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F233','回収（ＨＤ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F234','準備（ＥＣＵＭ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F235','治療（ＥＣＵＭ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F236','治療停止（ＥＣＵＭ）                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F237','回収（ＥＣＵＭ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F238','準備（ＨＤＦ）                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F239','治療（ＨＤＦ）                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F240','治療停止（ＨＤＦ）                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F241','回収（ＨＤＦ）                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F242','準備（ＨＦ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F243','治療（ＨＦ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F244','治療停止（ＨＦ）                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F245','回収（ＨＦ）                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F246','予約','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F247','運転(HD+補液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F248','透析停止(O-HDF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F249','予約','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F24A','運転(OHF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F24B','透析停止(O-HF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F24C','予約','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F24D','予約','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F24E','運転(OHDF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F24F','薬液消毒','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F250','透析準備','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F251','透析準備(洗い流し)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F252','患者接続','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F253','患者接続(洗い流し)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F254','血液回収','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F255','血液回収(洗い流し)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F256','停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F257','停止(洗い流し)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F258','クエン酸熱水（注入待機）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F259','クエン酸熱水（循環１）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F25A','クエン酸熱水（循環２）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F25B','脱血','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F25C','脱血(洗い流し)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F25D','返血','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F25E','返血(洗い流し)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F25F',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F260','D-FAS 運転(HD)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F261','D-FAS 運転(ECUM)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F262','D-FAS ガスパージ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F263','D-FAS 患者接続','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F264','D-FAS 膜加温','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F265','D-FAS 返血','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F266','D-FAS 運転(HDF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F267','D-FAS 運転(HF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F268','D-FAS 運転(OHDF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F269','D-FAS 運転(AFBF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F26A','D-FAS 運転(OHF)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F270','給液管熱洗 前洗浄','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F271','給液管熱洗 後洗浄','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F272','給液管熱洗 洗浄待機','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F273','給液管熱洗 熱洗','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F274','給液管熱洗 熱洗待機','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F275','クエン酸熱水（待機　前）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F276','クエン酸熱水（待機　後）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F277','停止（プログラム補液）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F278','運転（プログラム補液）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F280',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F281',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F282',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F283',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F284',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F2F0','調整モード','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F301','通常運転透析                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F302','通常運転予備透析                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F303','通常運転液置換                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F304','通常運転薬液消毒                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F305','通常運転滞留消毒                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F306','通常運転熱湯消毒                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F307','通常運転酸洗浄                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F308','通常運転洗浄                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F309','通常運転排液                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F30A','通常運転プリセット                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F381','補助運転透析                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F382','補助運転予備透析                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F383','補助運転液置換                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F384','補助運転薬液消毒                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F385','補助運転滞留消毒                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F386','補助運転熱湯消毒                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F387','補助運転酸洗浄                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F44C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F388','補助運転洗浄                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F389','補助運転排液                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F38A','補助運転プリセット                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F401','除水速度変更 [L/h]                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F402','除水目標値変更 [L]                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F403','除水積算値リセット                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F404','ＩＰ速度変更 [mL/h]                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F405','血流量変更 [mL/min]                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F406','通信データ「解除」                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F407','通信データ「確認」                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F408','患者データ「解除」                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F409','患者データ「確認」                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F40A','透析液流量変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F40B','ＩＰ電源自動リセット時間変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F40C','ＩＰワンショット量','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F40D','ＩＰ電源ＯＫモニタ切り時間変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F40E','除水プログラム 速度自動変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F411','血液ポンプ電源「入」                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F412','血液ポンプ電源「切」                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F413',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F414',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F415',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F416',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F417','原液希釈比率変更 [％]                                     ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F418','Aポンプ補正スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F419','Aポンプ補正スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F41A','Bポンプ補正スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F41B','Bポンプ補正スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F41C',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F41D',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F420','ＩＰ早送り                                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F421','ＩＰ電源「入」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F422','ＩＰ電源「切」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F423','シングルニードル「入」                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F424','シングルニードル「切」                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F425','ＵＦＲプロ「入」                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F426','ＵＦＲプロ「切」                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F427','Ｎａ注入「入」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F428','Ｎａ注入「切」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F429','ＨＤへ切替えました                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F42A','ＥＣＵＭへ切替えました                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F42B','透析液洗い流しＳＷ「入」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F42C','透析液洗い流しＳＷ「切」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F42D','ＴＭＰ初期補正ＳＷ「入」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F42E','除水開放ＳＷ「入」                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F42F','除水開放ＳＷ「切」                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F430','補液ＳＷ「入」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F431','補液ＳＷ「切」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F432','透析液流量切替ＳＷ「入」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F433','透析液流量切替ＳＷ「切」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F434','透析液濃度警報解除ＳＷ「入」                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F435','透析液濃度警報解除ＳＷ「切」                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F436','クリップ式気泡検出器切りＳＷ「入」                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F437','クリップ式気泡検出器切りＳＷ「切」                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F438','漏血警報一時解除ＳＷ「入」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F439','漏血警報一時解除ＳＷ「切」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F43A','ＴＭＰ一時解除ＳＷ「入」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F43B','ＴＭＰ一時解除ＳＷ「切」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F43C','ＩＰ電源報知切りＳＷ「入」                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F43D','ＩＰ電源報知切りＳＷ「切」                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F43E','ＩＰ電源自動切りＳＷ「入」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F43F','ＩＰ電源自動切りＳＷ「切」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F440','透析液温度設定変更 [℃]                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F441','シングルニードル切替圧変更                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F442','ＵＦＲプロ設定変更                                          ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F444','除水計算セット                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F445','血流量積算値リセット                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F446','ＨＤＦへ切り替えました                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F447','ＨＦへ切り替えました                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F448','治療モード変更 HD+補液','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F449','シーケンシャルプロ「入」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F44A','治療モード変更 OHF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F44B','治療モード変更 AFBF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F44D','治療モード変更 OHDF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F450','シーケンシャルプロ「切」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F451','血圧計の機種を自動判別できませんでした','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F452','血圧計（Ａ＆Ｄ）の設定をしました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F453','血圧計（日本コーリン）の設定をしました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F454','血圧計（ウエダ製作所）の設定をしました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F455','濃度プログラム「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F456','濃度プログラム「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F457','緊急補液開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F458','緊急補液停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F459','シングルポンプシングルニードル「入」                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F45A','ダブルポンプシングルニードル「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F45B','透析データ確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F45C','補液速度設定値変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F45D','補液量設定値変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F45E','補液積算値リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F45F','透析時間変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F460','透析経過時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F461','濃度プロ設定変更                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F462','透析液目標濃度変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F463','Ｂ液目標濃度変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F464','補液速度変更                                                ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F465','補液目標値変更                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F466','補液積算値リセット            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F467','ＩＰワンショットスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F468','クリーニング開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F469','漏血初期電圧読み込みＳＷ「入」                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F46A','緊急補液「開始」                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F46B','緊急補液「停止」                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F46C','風袋引き「入」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F46D','風袋引き「切」                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F46E','補液バック交換                                              ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F46F','輸液用警報幅ＳＷ「入」                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F470','輸液用警報幅ＳＷ「切」                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F471','補液リセットＳＷ「入り」                                    ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F472','緊急補液積算リセット                                        ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F473','補液温度設定変更 [℃]                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F474','補液ヒータＳＷ「入り」                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F475','補液ヒータＳＷ「切り」                                      ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F476','補液プライミングＳＷ「入」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F477','補液プライミングＳＷ「切」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F478','Ｎａ注入設定変更                                            ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F479','除水ポンプ速度低下ＳＷ「入」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F47A','除水ポンプ速度低下ＳＷ「切」                                  ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F47B','IP積算値リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F47C','静脈圧ゼロ補正実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F47D','動脈圧ゼロ補正実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F47E','荷重計手動ゼロ補正実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F47F','補液加温バッグテスト実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F480','静脈気泡電源「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F481','静脈気泡電源「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F482','薬液残留確認済み','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F483','準備回収大気開放ＳＷ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F484','準備回収大気開放ＳＷ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F485','ＡＦＢＦモードへ切り替えました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F486','ＡＦＢＦモードを解除しました','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F487','確認キーが押されました（運転開始前確認）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F488','後補液選択 ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F489','ＯＨＤＦ複式連動スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F48A','ＯＨＤＦ複式連動スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F48B','Ｂ粉カートリッジホルダ（上）ＳＷ選択 ソフト','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F48C','Ｂ粉カートリッジホルダ（上）ＳＷ選択 ハード ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F48D','ＴＭＰゼロ補正ＯＦＦ スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F48E','ＴＭＰゼロ補正ＯＦＦ スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F48F','ダイアライザー血液入口圧手動ゼロ補正実施','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F491','最高血圧上限警報動作解除','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F492','最高血圧下限警報動作解除','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F493','血圧計：ユーザによる測定中止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F494','加圧値変更 [%d] [%d]','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F495','最高血圧警報点変更 [%d] [%d]','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F496','最低血圧警報点変更 [%d] [%d]','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F497','平均血圧警報点変更 [%d] [%d]','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F498','脈拍警報点変更 [%d] [%d]','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F499','内蔵血圧計無効スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F49A','血圧データリセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F49B','血圧警報下限ＯＦＦスイッチ「入り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F49C','血圧警報下限ＯＦＦスイッチ「切り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F49D','血圧計自動測定スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F49E','血圧計自動測定スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F49F','血圧計連続測定スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4A0','血圧計連続測定スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4A1','脈拍警報下限警報OFFキー「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4A2','脈拍警報下限警報OFFキー「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B0',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B1',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B2',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B3','気泡スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B4','気泡スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B5','ガスパージスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B6','ガスパージスイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B7','シングルニードル設定ＳＮ切替圧上限変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B8','シングルニードル設定ＳＮ切替圧下限変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4B9','ＩＰワンショットスイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4BA','透析液採取スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4BB','漏血オフセット電圧測定スイッチ｢入｣','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4BC','透析液採取スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4BD','オーバーライドスイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4BE','漏血テストスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4BF','漏血電圧初期化スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4C0',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4C1',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D0',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D1',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D2',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D3','ＩＰ自動ワンショット「使用する」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D4','ＩＰ自動ワンショット「使用しない」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D5','ＩＰ使用する','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D6','ＩＰ使用しない','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D7','ブザー停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D8','オーバーライドスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4D9','Ｂ粉水充填スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4DA','Ｂ粉水充填スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4DB','Ｂ粉排液スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4DC','Ｂ粉排液スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4DD','濃度自己診断スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4DE','バッテリーエラースキップ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4DF','ＣＦ運転時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E0','補液バック交換スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E1','治療開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E2','透析終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E3','血液系自己診断中','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E4',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E5','ＥＣＵＭ時間変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E6','ＥＣＵＭ量設定値','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E7','ＥＣＵＭ速度設定値','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E8',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4E9','緊急補液 補液速度','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4EA','前補液選択','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4EB','緊急補液 目標補液量','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4EC','治療モード変更','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4ED',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4EE','回路圧抜きＳＷ入り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4EF','初期ＵＦＲ測定スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4F0','消耗品グループ１  運転時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4F1','消耗品グループ２  運転時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4F2','消耗品グループ３  運転時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4F3','CF2運転時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4F4','薬液ポート１使用量リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F4F5','薬液ポート２使用量リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F500','自動プライミングスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F501','プライミング補助スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F502','返血機能スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F503','血液回路排液スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F504','血液系自己診断スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F505','血液回路非接続 確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F506','血液系自己診断未終了 確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F507','血液系自己診断、ガスパージ未終了 確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F508','プライミング補助　通信設定　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F509','プライミング補助　通信設定　解除','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F50A','自動プライミング　通信設定　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F50B','自動プライミング　通信設定　解除','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F50C','D-FAS 通信設定 確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F50D','D-FAS 通信設定 解除','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F50E','オンラインプライミング　通信設定　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F50F','オンラインプライミング　通信設定　解除','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F510','自動運転１開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F511','自動運転２開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F512','自動運転３開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F513','自動運転４開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F514','自動運転５開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F515','自動運転途中終了　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F516','自動運転　再開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F520','除水自動再計算優先ＳＷ切り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F521','除水自動再計算優先ＳＷ入り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F522','ECUM終了時｢除水量設定値<除水量積算値｣確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F523','除水速度更新スイッチ 操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F524','除水計算スイッチ「計算無し」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F525','除水計算スイッチ「計算有り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F526','除水完了後の除水速度リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F527','透析残り時間延長  確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F528','補液速度自動再計算SW「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F529','補液速度自動再計算SW「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F52A','補液完了後の補液速度リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F52B','補液速度更新スイッチ 操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F52C','メンテナンスモード切替 確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F52D','オンラインプライミングスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F52E','DP=Qd+Qs(補液速度加算) スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F52F','DP=Qd+Qs(補液速度加算) スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F530','ＣＦ交換　ＣＦ水抜き「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F531','ＣＦ交換　ＣＦ水抜き「中止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F532','ＣＦ交換　ダイアライザーカップリング開放確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F533','ＣＦ交換　交換終了　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F534','ＣＦ交換後の液充填未実施　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F540','血液回路非検出時ＢＰ動作可 確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F541','除水速度0　確認済み','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F542','生食プライミングライン送液動作 OFF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F550','返血機能　運転','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F551','返血機能　停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F552','返血機能　終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F553','返血機能　運転 (オンライン)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F554','返血機能　一時停止 (オンライン)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F555','返血機能　終了 (オンライン)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F560','血液回路排液　運転','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F561','血液回路排液　停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F562','血液回路排液　終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F570','治療モード変更 ＨＤ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F571','治療モード変更 ＥＣＵＭ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F572','透析データ自動リセット（時間経過）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F580','原液設定変更　原液１','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F581','原液設定変更　原液２','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F582','原液設定変更　原液３','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F583','原液設定変更　原液４','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F584','原液設定変更　原液５','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F585',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F586',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F587',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F588',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F589','Ｎａ充填「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F58A','Ｎａ充填「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F58B','原液選択変更（目標電導度保持）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F58C','原液選択変更（目標電導度更新）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F58D','Na注入濃度確認「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F58E','Na注入濃度確認「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F590','バッテリー連続充電スイッチ「入り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F591','バッテリー連続充電スイッチ「切り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F592','カップリング漏れテストスイッチ「入り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F593','カップリング漏れテストスイッチ「切り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F594','静脈圧警報一時解除 スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F595','静脈圧警報一時解除 スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F596','ダイアライザー血液入口圧警報一時解除 スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F597','ダイアライザー血液入口圧警報一時解除 スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F598','透析液圧警報一時解除 スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F599','透析液圧警報一時解除 スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F59A','加温バッグ漏れテストスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F59B','加温バッグ漏れテストスイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5A0','装置電源「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5A1','装置使用スイッチ 「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5A2','装置使用スイッチ 「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5A8','透析液流量　自動切替実施（DAB-NX）　「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5A9','透析液流量　自動切替実施（DAB-NX）　「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B0','BV計使用選択スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B1','BV計使用選択スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B2',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B3',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B4','ΔＢＶ初期化','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B5','ブラッドボリュームデータ転送','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B6','前体重','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B7','イベント','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B8','BV-COCスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5B9','BV-COCスイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5BA','BV計一時停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5BB','BV計動作再開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5BC','BV計全データ消去','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5BD','BV計データ出力開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5BE','BV計データ出力中止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5BF','BVM PCB 無効スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5C0','ΔBVリファレンスエリア監視スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5C1','ΔBVリファレンスエリア監視スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5C2','BV計回路なし報知解除','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5D0','AFBF補液比率 「使用する」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5D1','AFBF補液比率 「使用しない」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5D2','AFBF補液比率','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5D3','OHDF/OHF補液比率','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E0','再循環率測定開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E1','再循環率測定中止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E2',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E3',null,'2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E4','血圧測定開始スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E5','補液スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E6','補液スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E7','補液回路接続テストスイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E8','補液回路接続テストスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5E9','補液回路接続，除水・補液設定「確認」ｷｰ操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5EA','回路接続 「確認」キー操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5EB','運転工程前のスローアップ中止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F0','D-FAS プライミング開始(中空糸)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F1','D-FAS ｶﾞｽﾊﾟｰｼﾞ・ﾌﾟﾗｲﾐﾝｸﾞ開始(積層)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F2','D-FAS プライミング一時停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F3','D-FAS プライミング再開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F4','D-FAS ガスパージ開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F5','D-FAS ガスパージ中止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F6','D-FAS 同時脱血開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F7','D-FAS 片側脱血(除水あり)開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F8','D-FAS 片側脱血(除水なし)開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5F9','D-FAS 脱血一時停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5FA','D-FAS 脱血再開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5FB','D-FAS 運転開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5FC','D-FAS 返血開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5FD','D-FAS 返血一時停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5FE','D-FAS 返血再開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F5FF','D-FAS 終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F600','D-FAS プライミング完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F601','D-FAS 膜加温終了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F602','D-FAS 脱血完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F603','D-FAS操作 生食液面調整開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F604','D-FAS操作 回路プライミング開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F605','D-FAS操作 血液回路内洗浄開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F606','D-FAS操作 気泡抜き開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F607','D-FAS操作 同時脱血開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F608','D-FAS操作 片側脱血(除水あり)開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F609','D-FAS操作 片側脱血(除水なし)開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F60A','D-FAS操作 脱血再開（除水P停止）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F60B','D-FAS操作 静脈側返血開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F60C','D-FAS操作 動脈側返血開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F60D','D-FAS操作 静脈側追加返血開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F60E','D-FAS操作 動脈側落差返血開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F60F','D-FAS操作 患者接続移行','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F610','D-FAS操作 ガスパージ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F611','D-FAS操作 膜加温','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F612','D-FAS操作 運転開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F613','D-FAS 機能OFF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F614','D-FAS 治療完了→返血 ON','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F615','D-FAS 治療完了→返血 OFF','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F616','緊急補液開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F617','緊急補液停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F618','緊急補液完了','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F619','生食気泡電源「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F61A','生食気泡電源「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F61B','動脈気泡電源「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F61C','動脈気泡電源「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F61D','IPラインプライミング','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F61E','D-FAS 機能ON','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F61F','ﾀﾞｲｱﾗｲｻﾞｰ設定切替 積層型→中空糸型','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F620','ﾀﾞｲｱﾗｲｻﾞｰ設定切替 中空糸型→積層型','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F621','BP速度','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F622','生食液切れ電源「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F623','生食液切れ電源「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F624','D-FAS 返血開始(透析液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F625','D-FAS 返血一時停止(透析液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F626','D-FAS 返血再開(透析液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F627','D-FAS操作 静脈側返血開始(透析液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F628','D-FAS操作 動脈側返血開始(透析液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F629','D-FAS操作 静脈側追加返血開始(透析液)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F62A','D-FAS操作 静脈側から返血再開','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F62B','ﾀﾞｲｱﾗｲｻﾞｰ切替スイッチ 積層型→中空糸型','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F62C','ﾀﾞｲｱﾗｲｻﾞｰ切替スイッチ 中空糸型→積層型','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F62D','使用液選択 生理食塩液→透析液','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F62E','使用液選択 透析液→生理食塩液','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F62F','D-FAS 脱血 片側脱血（除水なし）へ移行','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F630','D-FAS脱血 除水ポンプ積算値','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F631','サンプルポートの接続 「確認」キー操作','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F632','緊急補液速度  [%3dmL/min]','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F633','緊急補液量  [%3dmL]','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F634','緊急補液方式選択 補液P→血液P','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F635','緊急補液方式選択 血液P→補液P','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F636','漏水検知警報解除キー 「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F637','漏水検知警報解除キー 「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F638','ポートノブヒータ監視解除キー 「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F639','ポートノブヒータ監視解除キー 「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F63A','サンプルポート圧抜きスイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F63B','サンプルポート圧抜きスイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F63C','除水計算時間入力方法　残り時間','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F63D','除水計算時間入力方法　完了時刻','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F63E','補液計算時間入力方法　残り時間','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F63F','補液計算時間入力方法　完了時刻','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F640','D-FAS操作 追加気泡抜き開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F650','プログラム補液　補液速度','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F651','プログラム補液　補液量','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F652','プログラム補液　補液周期','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F653','プログラム補液　補液開始時間','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F654','プログラム補液　除水再開時間','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F655','プログラム補液　除水なし','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F656','プログラム補液　除水あり','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F657','除水計算（プログラム補液）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F660','目標Kt/V(透析量モニタ) ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F661','DDM PCB 無効スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F662','透析量モニタ無効','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F663','再循環率報知解除','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F664','透析液流量監視解除スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F665','透析液流量監視解除スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F666','DDM使用選択スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F667','DDM使用選択スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F680','推定血流量モニタ 使用選択スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F681','推定血流量モニタ 使用選択スイッチ「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F682','推定血流量モニタ 校正スイッチ「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F683','推定血流量モニタの校正に失敗したため，推定血流量モニタを中止します','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F684','非接触ICカード認証','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F685','非接触ICカードログアウト','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F686','非接触ICカード認証2','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F6F0','TMP補液制御 「切」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F6F1','TMP補液制御 「入」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F6F2','TMP補液制御 補液速度低下','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F6F3','TMP補液制御 補液速度復帰','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F6F4','TMP補液制御 「切」(速度維持)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F6F5','TMP補液制御 「切」(速度復帰)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F700','カレンダ情報 初期化','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F701','データレポート 初期化','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F710','開始画面　「治療」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F711','開始画面　「洗浄」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F720','消毒異常画面　「リトライ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F721','消毒異常画面　「スキップ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F730','消毒準備画面　「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F731','強制中止スイッチ　「はい」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F732','強制中止確認画面　「確認」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F733','補液後の運転再開の確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F734','消毒中画面　「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F735','消毒中画面　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F740','血液回路取付自己診断（停止）画面　「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F741','血液回路取付自己診断（停止）画面　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F742','クランプ漏れテスト画面　「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F750','治療前データ入力画面　「入力」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F751','治療前入力データ確認画面　「決定」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F752','治療前入力データ確認画面　「戻り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F753','ガスパージ(準備)画面　「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F760','患者接続(準備)画面　「運転」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F761','患者接続(脱血中)画面　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F762','患者接続(脱血停止)画面　「運転」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F763','患者接続(脱血完了)画面　「運転」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F764','排液１停止画面　「スキップ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F770','透析運転画面　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F771','透析運転画面　「補液」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F772','透析停止画面　「運転」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F773','透析停止画面　「返血」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F774','透析停止画面　「補液」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F780','補液準備画面　「補液開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F781','補液準備画面　「戻り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F782','補液中画面　「補液停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F783','補液停止画面　「補液開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F784','補液停止画面　「戻り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F785','補液後了画面　「補液開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F786','補液後了画面　「戻り」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F790','手動返血中画面　「抜針確認」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F791','返血中画面　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F792','返血停止画面　「返血」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F793','返血停止画面　「終了」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F794','返血完了画面　「動脈返血」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F795','返血完了画面　「静脈返血」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F796','返血完了画面　「抜針確認」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F797','返血警報動脈血液判別器画面　「リトライ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F798','返血警報動脈血液判別器画面　「スキップ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F799','返血静水圧異常画面　「リトライ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F79A','返血静水圧異常画面　「スキップ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F79B','洗浄異常画面　「リトライ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F79C','洗浄異常画面　「スキップ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F79D','患者接続(脱血停止)画面　「返血」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F79E','返血不足(動脈)画面　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F79F','返血不足(静脈)画面　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7B0','排液１準備画面　「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7B1','排液１実行中画面　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7B2','排液１停止画面　「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7C0','排液１準備画面　「スキップ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7D0','血液回路水抜き画面　「開始」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E0','ステップ移行','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E1','強制ステップ移行　「プリセット」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E2','強制ステップ移行　「液置換」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E3','強制ステップ移行　「透析準備」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E4','強制ステップ移行　「自動プラ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E5','強制ステップ移行　「ガスパージ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E6','強制ステップ移行　「クランプ漏れテスト」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E7','強制ステップ移行　「治療前データ入力」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E8','強制ステップ移行　「患者接続」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7E9','強制ステップ移行　「運転」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7EA','強制ステップ移行　「停止」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7EB','強制ステップ移行　「血液回収」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7EC','強制ステップ移行　「排液」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7ED','強制ステップ移行　「消毒」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7F0','透析液流量(透析量プログラム)','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F7F1','目標Kt/V(透析量プログラム) ','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F800','リセット（送液キー）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F801','ブザー停止','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F802','消耗品グループ１  運転時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F803','消耗品グループ２  運転時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F804','消耗品グループ３  運転時間リセット','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F805','水計量連続運転スイッチ切り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F806','水計量連続運転スイッチ入り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F809','配管テストスイッチ入り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F80A','希釈テストスイッチ入り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F80B','Ｂ液目標濃度スイッチ入り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F80C','透析液目標濃度スイッチ入り','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F80E','自動運転開始','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F80F','自動運転途中終了　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F810','バイパス警報出力　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F811','透析工程移行　確認','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F812','透析工程移行（液置換量不足時）「はい」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F813','透析工程移行（液置換量不足時）「いいえ」','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F821','Ａポンプ速度（原液１）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F822','Ｂポンプ速度（原液１）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F823','Ａ目標濃度（原液１）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F824','Ｂ目標濃度（原液１）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F825','Ａポンプ速度（原液２）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F826','Ｂポンプ速度（原液２）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F827','Ａ目標濃度（原液２）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F828','Ｂ目標濃度（原液２）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F829','Ａポンプ速度（原液３）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F82A','Ｂポンプ速度（原液３）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F82B','Ａ目標濃度（原液３）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('F82C','Ｂ目標濃度（原液３）','2017-11-30 00:00:00','2017-11-30 00:00:00'),
	('G000','デバイスエッジ通信異常','2018-03-29 00:00:00','2018-03-29 00:00:00'),
	('G001','デバイスエッジ異常','2018-03-29 00:00:00','2018-03-29 00:00:00')
;

-- 型式マスタ
TRUNCATE TABLE mst_machine_type;
INSERT INTO mst_machine_type (machine_type_cd, machine_type, model, maker, reg_date, up_date) VALUES 
	('001','DCS-73(I)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('002','DCS-73(H)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('003','DCS-27(I)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('004','DCS-27(H)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('005','DCS-28(I)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('006','DCS-28(H)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('007','DBB-73(J)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('008','DBB-73(G)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('009','DBB-27(J)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('010','DBB-27(G)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('011','DBG-03(N)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('012','DBG-03(E)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('013','DCG-03(M)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('014','DCG-03(D)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('015','DCS-72',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('016','DCS-26',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('017','DBB-72',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('018','DBB-26',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('019','DBG-02',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('020','DCG-02',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('021','DAB',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('022','オフライン',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('023','医器工(VER1.0)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('024','医器工(VER2.0)',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('999','サンプル装置',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('025','DCS-100NX',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('026','DBB-100NX',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('027','DCG-03',null,null,'1850-01-01 00:00:00','1850-01-01 00:00:00'),
	('028','DBG-03',null,null,null,'1899-12-30 04:00:00'),
	('029','DCG-02',null,null,null,'1899-12-30 05:00:00'),
	('030','DBG-02',null,null,null,'1899-12-30 04:00:00'),
	('031','DCS-27',null,null,null,'1899-12-30 05:00:00'),
	('032','DBB-27',null,null,null,'1899-12-30 04:00:00'),
	('033','DBB-81',null,null,null,'1899-12-30 04:00:00'),
	('034','DCS-73',null,null,null,'1899-12-30 05:00:00'),
	('035','DBB-73',null,null,null,'1899-12-30 04:00:00'),
	('036','DCS-26',null,null,null,'1899-12-30 05:00:00'),
	('037','DBB-26',null,null,null,'1899-12-30 04:00:00'),
	('038','DCS-72',null,null,null,'1899-12-30 05:00:00'),
	('039','DBB-72',null,null,null,'1899-12-30 04:00:00'),
	('058','DAB-NX',null,null,null,'1899-12-30 02:00:00'),
	('059','DAB-E',null,null,null,'1899-12-30 02:00:00'),
	('072','DAD-50NX',null,null,null,'1899-12-30 03:00:00'),
	('073','DAD-30',null,null,null,'1899-12-30 03:00:00'),
	('074','DRY-50B',null,null,null,'1899-12-30 03:00:00'),
	('075','DRY-50A',null,null,null,'1899-12-30 03:00:00'),
	('076','DRY-11B',null,null,null,'1899-12-30 03:00:00'),
	('077','DRY-11A',null,null,null,'1899-12-30 03:00:00'),
	('078','DRY-01B',null,null,null,'1899-12-30 03:00:00'),
	('079','DRY-01A',null,null,null,'1899-12-30 03:00:00'),
	('098','DRO-NX',null,null,null,'1899-12-30 01:00:00'),
	('099','DRO-EX',null,null,null,'1899-12-30 01:00:00')
;

-- 緊急発報マスタ
TRUNCATE TABLE mst_m_notice;
INSERT INTO mst_m_notice (facility_cd, machine_record_cd, machine_record_message, email_address, email_name, reg_date, up_date) VALUES 
	('000001','0101','血圧測定','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017-11-15 00:54:18','2017-11-15 00:54:18'),
	('000001','0102','','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017-11-15 00:54:18','2017-11-15 00:54:18'),
	('000001','0301','','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017-11-15 00:54:18','2017-11-15 00:54:18'),
	('000001','0400','','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017-11-15 00:54:18','2017-11-15 00:54:18'),
	('000001','G000','デバイスエッジ通信異常','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2018-03-30 01:03:00','2018-03-30 01:03:00'),
	('000001','G001','デバイスエッジ異常','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2018-03-30 01:03:00','2018-03-30 01:03:00'),
	('999900','958A','テストメッセージ','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017-11-15 00:54:18','2017-11-15 00:54:18')
;

-- 担当施設マスタ
TRUNCATE TABLE mst_staff_facility;
INSERT INTO mst_staff_facility (user_id, facility_cd, reg_date, up_date) VALUES 
	(5,'009997','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000001','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000002','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000003','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000004','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000005','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000006','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000007','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000008','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000009','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000010','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'999900','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'000011','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'009999','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(5,'009998','2018-10-30 10:10:45.57','2018-10-30 10:10:45.57'),
	(7,'009997','2018-06-11 10:41:24.514','2018-06-11 10:41:24.514'),
	(6,'009997','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(19,'009999','2018-12-18 17:40:08.875','2018-12-18 17:40:08.875'),
	(19,'009997','2018-12-18 17:40:08.875','2018-12-18 17:40:08.875'),
	(19,'000001','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000002','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000003','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000004','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000005','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000006','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000007','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000008','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000009','2018-12-18 17:40:08.876','2018-12-18 17:40:08.876'),
	(19,'000010','2018-12-18 17:40:08.877','2018-12-18 17:40:08.877'),
	(19,'999900','2018-12-18 17:40:08.877','2018-12-18 17:40:08.877'),
	(19,'000011','2018-12-18 17:40:08.877','2018-12-18 17:40:08.877'),
	(19,'009998','2018-12-18 17:40:08.877','2018-12-18 17:40:08.877'),
	(9,'000004','2018-12-18 17:45:15.745','2018-12-18 17:45:15.745'),
	(9,'000005','2018-12-18 17:45:15.745','2018-12-18 17:45:15.745'),
	(9,'000006','2018-12-18 17:45:15.745','2018-12-18 17:45:15.745'),
	(9,'000007','2018-12-18 17:45:15.745','2018-12-18 17:45:15.745'),
	(9,'000008','2018-12-18 17:45:15.745','2018-12-18 17:45:15.745'),
	(9,'000009','2018-12-18 17:45:15.745','2018-12-18 17:45:15.745'),
	(9,'000010','2018-12-18 17:45:15.746','2018-12-18 17:45:15.746'),
	(9,'999900','2018-12-18 17:45:15.746','2018-12-18 17:45:15.746'),
	(9,'000011','2018-12-18 17:45:15.746','2018-12-18 17:45:15.746'),
	(9,'009999','2018-12-18 17:45:15.746','2018-12-18 17:45:15.746'),
	(9,'009998','2018-12-18 17:45:15.746','2018-12-18 17:45:15.746'),
	(9,'009997','2018-12-18 17:45:15.746','2018-12-18 17:45:15.746'),
	(9,'000001','2018-12-18 17:45:15.746','2018-12-18 17:45:15.746'),
	(9,'000002','2018-12-18 17:45:15.746','2018-12-18 17:45:15.746'),
	(9,'000003','2018-12-18 17:45:15.75','2018-12-18 17:45:15.75'),
	(6,'000001','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000002','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000003','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000004','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000005','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000006','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000007','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000008','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000009','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000010','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'999900','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'000011','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'009999','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(6,'009998','2018-11-26 18:26:24.654','2018-11-26 18:26:24.654'),
	(8,'009998','2018-11-29 15:23:27.83','2018-11-29 15:23:27.83'),
	(8,'000002','2018-11-29 15:23:27.832','2018-11-29 15:23:27.832'),
	(8,'999900','2018-11-29 15:23:27.832','2018-11-29 15:23:27.832'),
	(12,'000001','2018-12-10 19:36:24.535','2018-12-10 19:36:24.535'),
	(12,'000002','2018-12-10 19:36:24.535','2018-12-10 19:36:24.535'),
	(12,'000003','2018-12-10 19:36:24.535','2018-12-10 19:36:24.535'),
	(12,'000004','2018-12-10 19:36:24.535','2018-12-10 19:36:24.535'),
	(12,'000005','2018-12-10 19:36:24.535','2018-12-10 19:36:24.535'),
	(12,'000006','2018-12-10 19:36:24.535','2018-12-10 19:36:24.535'),
	(12,'000007','2018-12-10 19:36:24.535','2018-12-10 19:36:24.535'),
	(12,'000008','2018-12-10 19:36:24.536','2018-12-10 19:36:24.536'),
	(12,'000009','2018-12-10 19:36:24.536','2018-12-10 19:36:24.536'),
	(12,'000010','2018-12-10 19:36:24.536','2018-12-10 19:36:24.536'),
	(12,'999900','2018-12-10 19:36:24.536','2018-12-10 19:36:24.536'),
	(12,'000011','2018-12-10 19:36:24.536','2018-12-10 19:36:24.536'),
	(12,'009999','2018-12-10 19:36:24.536','2018-12-10 19:36:24.536'),
	(12,'009998','2018-12-10 19:36:24.536','2018-12-10 19:36:24.536'),
	(12,'009997','2018-12-10 19:36:24.536','2018-12-10 19:36:24.536'),
	(15,'000002','2018-12-14 11:44:13.985','2018-12-14 11:44:13.985'),
	(11,'009997','2018-11-30 18:31:11.697','2018-11-30 18:31:11.697'),
	(11,'000001','2018-11-30 18:31:11.699','2018-11-30 18:31:11.699'),
	(11,'000002','2018-11-30 18:31:11.7','2018-11-30 18:31:11.7'),
	(15,'000008','2018-12-14 11:44:13.988','2018-12-14 11:44:13.988'),
	(15,'000009','2018-12-14 11:44:13.989','2018-12-14 11:44:13.989'),
	(15,'000010','2018-12-14 11:44:13.989','2018-12-14 11:44:13.989'),
	(15,'999900','2018-12-14 11:44:13.989','2018-12-14 11:44:13.989'),
	(15,'000011','2018-12-14 11:44:13.989','2018-12-14 11:44:13.989'),
	(15,'009999','2018-12-14 11:44:13.99','2018-12-14 11:44:13.99'),
	(15,'009998','2018-12-14 11:44:13.99','2018-12-14 11:44:13.99'),
	(15,'009997','2018-12-14 11:44:13.99','2018-12-14 11:44:13.99')
;

-- 都道府県マスタ
TRUNCATE TABLE sys_prefectures;
INSERT INTO sys_prefectures (pref_cd, pref_name, reg_date, up_date) VALUES 
	('01','北海道','2018-05-25 17:12:40','2018-05-25 17:12:43'),
	('02','青森県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('03','岩手県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('04','宮城県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('05','秋田県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('06','山形県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('07','福島県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('08','茨城県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('09','栃木県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('10','群馬県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('11','埼玉県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('12','千葉県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('13','東京都','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('14','神奈川県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('15','新潟県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('16','富山県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('17','石川県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('18','福井県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('19','山梨県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('20','長野県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('21','岐阜県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('22','静岡県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('23','愛知県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('24','三重県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('25','滋賀県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('26','京都府','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('27','大阪府','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('28','兵庫県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('29','奈良県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('30','和歌山県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('31','鳥取県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('32','島根県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('33','岡山県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('34','広島県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('35','山口県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('36','徳島県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('37','香川県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('38','愛媛県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('39','高知県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('40','福岡県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('41','佐賀県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('42','長崎県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('43','熊本県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('44','大分県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('45','宮崎県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('46','鹿児島県','2018-05-25 17:12:40','2018-05-25 17:12:40'),
	('47','沖縄県','2018-05-25 17:12:40','2018-05-25 17:12:40')
;

-- システム設定
TRUNCATE TABLE sys_system_define;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES 
	(1,'000','緊急発報用デフォルトメールテンプレート','{"mail_template": "[緊急発報_共通テンプレート]\n　異常が発生しています。\n　確認して下さい", "mail_alive_template": "関係者各位 \n　[施設名] の装置：[デバイスエッジ名]で [装置記録メッセージ] が発生しました。\n　詳細は以下を確認して下さい。\n　\n■施設名：[施設名]\n■デバイスエッジ名：[デバイスエッジ名]\n■デバイスエッジ番号：[デバイスエッジ番号]\n■発生日時：[発生日時]\n■装置記録コード：[装置記録コード] \n■装置記録メッセージ：[装置記録メッセージ] \n　\n■発報対象者名：[発報対象者名] ■稼働ビューア：[URL]\n以上です。\nよろしくお願い致します。"}','緊急発報用デフォルトメールテンプレート','1','1850-01-01 00:00:00')
;
