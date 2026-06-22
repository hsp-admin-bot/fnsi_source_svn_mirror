TRUNCATE sys_coop_journal RESTART IDENTITY;
DELETE FROM mst_coop_distribute;
DELETE FROM mst_if_edge;
DELETE FROM mnt_if_edge_healthmon;
DELETE FROM mst_coop_layout;
DELETE FROM sys_data_set;

INSERT INTO
  sys_coop_journal
  (
  facility_cd
  , coop_cd
  , coop_cd_index
  , crud
  , direction
  , ana_result
  , out_reg_date
  , out_ana_date
  , coop_result
  , in_reg_date
  , in_ana_date
  , dump_path
  , dump
  , is_editable
  , reg_date
  , up_date
  , is_del
  , user_id
  )
  VALUES
    ('TEST04', '1', '', 'C' , 'S' , '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , null, null , '1' , current_timestamp , current_timestamp , '0', null),
    ('TEST99', 'error', '', 'C' , 'S' , '0' , '2019-11-12 15:00:00' , null, '0' , '2019-11-12 15:00:00' , null , null, null , '1' , current_timestamp , current_timestamp , '0', 1001),
    ('TEST91', 'ustxt', '', 'C' , 'S' , '0' , '2019-11-12 15:00:00' , null , '0' , '2019-11-12 15:00:00' , null , null, null , '1' , current_timestamp , current_timestamp , '0', 1001),
    ('TEST92', 'usxml', '', 'C' , 'S' , '0' , '2019-11-12 15:00:00' , null , '0' , '2019-11-12 15:00:00' , null , null, null , '1' , current_timestamp , current_timestamp , '0', 1001),
    ('TEST93', 'usxml2', '', 'C' , 'S' , '0' , '2019-11-12 15:00:00' , null , '0' , '2019-11-12 15:00:00' , null , null, null , '1' , current_timestamp , current_timestamp , '0', 1001),
    ('TEST94', '0', '', 'C' , 'S' , '0' , '2019-11-12 15:00:00' , null , '0' , '2019-11-12 15:00:00' , null , null, null , '1' , current_timestamp , current_timestamp , '0', 1001);

INSERT INTO
  mst_coop_layout
  (
  facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
  )
  VALUES
  ('TEST04', '1', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="test"><item name="test" len="4" type="string" value="const:HOGE"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST91', 'ustxt', '', 'S', 'cre', 'text','', '','', '1', XMLPARSE(DOCUMENT '<root name="test"><item name="ユーザ" len="12" value="auth_id:-1.user_id"/></root>'), '{"dataset": [{"ctlNo": 2, "sqlCode": -1}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST92', 'usxml', '', 'S', 'cre', 'xml','', '','', '1', XMLPARSE(DOCUMENT '<item name="auth" value="auth_id:-1.user_id"/>'), '{"dataset": [{"ctlNo": 3, "sqlCode": -1}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST93', 'usxml2', '', 'S', 'cre', 'xml','', '','', '1', XMLPARSE(DOCUMENT '<MCSSData ver="Ver.03.80 2020-03-25"><Header><DrCd>auth_id:-1.user_id</DrCd></Header></MCSSData>'), '{"dataset": [{"ctlNo": 4, "sqlCode": -1}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST94', '0', '', 'S', 'cre', 'xml','test','test','', '1', XMLPARSE(DOCUMENT '<Content><Row _sqlCode="-300" _detail="テスト明細"/></Content>'), '{"dataset": [{"dsMerge": [-300, -301], "sqlCode": -300}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00');

insert into sys_data_set (
  sql_cd
, sql
, db_class
, detail
, can_repeat
) values
(-1, 'select ctl_no, facility_cd, user_id from sys_coop_journal where ctl_no = @ctlNo', 2, '[{}]', '0'),
(-300, 'select ''350'' as detail_id, ''351'' as masterid union select ''350'' as detail_id, ''352'' as masterid', 2, '[{}]', '0'),
(-301, 'select ''350'' as detail_id, ''353'' as masterid union select ''350'' as detail_id, ''354'' as masterid', 2, '[{}]', '0'),
(-360, 'select ''351'' as masterid, ''item1'' as inputdata', 2, '[{}]', '0');

insert into mst_coop_facility values ('-2','TEST94',NULL,'1','0',NULL,'{"coop_ord_cd": [{"ord_cd": "ini_dial"}, {"ord_cd": "profile"}, {"ord_cd": "accept"}, {"ord_cd": "rst_dial"}, {"ord_cd": "karte_ord"}, {"ord_cd": "ind_dial"}, {"ord_cd": "vit_cop"}, {"ord_cd": "rep_dial", "report": true}, {"ord_cd": "exam_ord"}, {"ord_cd": "rad_ord"}]}',NULL,NULL,NULL);
