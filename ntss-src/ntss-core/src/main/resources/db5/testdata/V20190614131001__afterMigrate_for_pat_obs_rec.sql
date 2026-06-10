--治療記録（観察記録）画面表示確認用データ
INSERT INTO pat_obs_rec
(pat_id,facility_cd,rec_date,up_cnt,kind_info,reg_staff_info,up_staff_info,obs_rec_info,bbs_ctl_no,ord_no,is_newest,is_del,fn_seq_id,reg_date,up_date)
VALUES
(6,'009999','2019/05/31 13:13:00',0,'{"kind_no": 9, "kind_name": "観察メモ", "kind_class": 0, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}',null,'{"detail1": "test", "detail2": "", "detail3": "", "detail4": ""}',null,7,'0','0',null,'2019/05/31 13:13:39.578','2019/05/31 13:13:53.698')
, (6,'009999','2019/05/31 13:13:00',0,'{"kind_no": 9, "kind_name": "観察メモ", "kind_class": 0, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}',null,'{"detail1": "example", "detail2": "", "detail3": "", "detail4": ""}',null,7,'1','0',null,'2019/05/31 13:13:46.362','2019/05/31 13:13:46.362')
, (6,'009999','2019/05/31 13:13:00',1,'{"kind_no": 9, "kind_name": "観察メモ", "kind_class": 0, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}','{"up_staff_cd": 22}','{"detail1": "test2", "detail2": "", "detail3": "", "detail4": ""}',null,7,'0','0',null,'2019/05/31 13:13:53.941','2019/05/31 13:14:02.465')
, (6,'009999','2019/05/31 13:13:00',2,'{"kind_no": 9, "kind_name": "観察メモ", "kind_class": 0, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}','{"up_staff_cd": 22}','{"detail1": "test22", "detail2": "", "detail3": "", "detail4": ""}',null,7,'1','0',null,'2019/05/31 13:14:02.710','2019/05/31 13:14:02.710')
, (6,'009999','2019/05/31 13:19:00',0,'{"kind_no": 10, "kind_name": "SOAP", "kind_class": 1, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}',null,'{"detail1": "a", "detail2": "a", "detail3": "a", "detail4": "a"}',null,7,'0','0',null,'2019/05/31 13:20:02.294','2019/06/05 10:44:26.904')
, (6,'009999','2019/05/31 13:19:00',1,'{"kind_no": 10, "kind_name": "SOAP", "kind_class": 1, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}','{"up_staff_cd": 22}','{"detail1": "a", "detail2": "a", "detail3": "a", "detail4": "a"}',null,7,'1','0',null,'2019/06/05 10:44:27.090','2019/06/05 10:44:27.090')
, (6,'009999','2019/06/14 11:52:00',0,'{"kind_no": 11, "kind_name": "FDAR", "kind_class": 2, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}',null,'{"detail1": "FFFF", "detail2": "DDDD", "detail3": "AAAA", "detail4": "RRRR"}',null,7,'1','0',null,'2019/06/05 11:53:23.971','2019/06/05 11:53:23.971')
, (6,'009999','2019/06/14 11:53:00',0,'{"kind_no": 12, "kind_name": "メモ", "kind_class": 0, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}',null,'{"detail1": "MEMO", "detail2": "", "detail3": "", "detail4": ""}',null,7,'1','0',null,'2019/06/06 11:53:48.753','2019/06/06 11:53:48.753')
, (6,'009999','2019/06/13 11:53:00',0,'{"kind_no": 12, "kind_name": "メモ", "kind_class": 0, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}',null,'{"detail1": "memo1", "detail2": "", "detail3": "", "detail4": ""}',null,7,'0','0',null,'2019/06/06 11:54:08.262','2019/06/06 11:54:19.181')
, (6,'009999','2019/06/13 11:53:00',1,'{"kind_no": 12, "kind_name": "メモ", "kind_class": 0, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}','{"up_staff_cd": 22}','{"detail1": "memo2 rev", "detail2": "", "detail3": "", "detail4": ""}',null,7,'0','0',null,'2019/06/06 11:54:19.429','2019/06/06 11:54:42.932')
, (6,'009999','2019/06/13 11:53:00',2,'{"kind_no": 12, "kind_name": "メモ", "kind_class": 0, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}','{"up_staff_cd": 22}','{"detail1": "memo2 rev rev", "detail2": "", "detail3": "", "detail4": ""}',null,7,'1','0',null,'2019/06/06 11:54:43.180','2019/06/06 11:54:43.180')
, (6,'009999','2019/06/14 11:57:00',0,'{"kind_no": 10, "kind_name": "SOAP", "kind_class": 1, "kind_update": "2019-01-31T00:00:00.000+09:00"}','{"reg_staff_cd": 22}',null,'{"detail1": "S", "detail2": "OO", "detail3": "AAA", "detail4": "PPPP"}',null,7,'1','0',null,'2019/06/06 11:57:49.643','2019/06/06 11:57:49.643')
;

INSERT INTO mst_obs_kind
(kind_no, facility_cd, kind_name, kind_class, is_post_bbs, post_period, post_address_class, is_link_ord_no, is_disp, is_del, reg_date, up_date, fn_kind_id)
VALUES
(9, '009999', '観察メモ', 0, '0', NULL, NULL, '0', '1', '0', '2019-01-31 00:00:00.000', '2019-01-31 00:00:00.000', NULL)
, (10, '009999', 'SOAP', 1, '0', NULL, NULL, '0', '1', '0', '2019-01-31 00:00:00.000', '2019-01-31 00:00:00.000', NULL)
, (11, '009999', 'FDAR', 2, '0', NULL, NULL, '0', '1', '0', '2019-01-31 00:00:00.000', '2019-01-31 00:00:00.000', NULL)
, (12, '009999', 'メモ', 0, '0', NULL, NULL, '0', '1', '0', '2019-01-31 00:00:00.000', '2019-01-31 00:00:00.000', NULL)
, (13, '009999', 'その他', 0, '0', NULL, NULL, '0', '1', '0', '2019-01-31 00:00:00.000', '2019-01-31 00:00:00.000', NULL)
;

INSERT INTO mst_selector
(facility_cd, master_physical_name, order_settings, reg_date, up_date)
VALUES
('009999', 'mst_obs_kind', '{"items": [{"code": 9, "name": "観察メモ"},{"code": 10, "name": "SOAP"},{"code": 11, "name": "FDAR"},{"code": 12, "name": "メモ"},{"code": 13, "name": "その他"}]}', '2019-02-15 14:48:39.000', '2019-02-15 14:48:39.000')
;
