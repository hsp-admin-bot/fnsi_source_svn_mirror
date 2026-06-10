DELETE FROM sys_coop_journal;
DELETE FROM mst_coop_layout;
DELETE FROM mst_coop_layout_detail;
DELETE FROM mst_coop_facility;

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
  , is_editable
  , reg_date
  , up_date
  , is_del
  , pat_id
  , ord_no
  , report_cd
  , base_date
  )
  VALUES
  ('TEST01', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, '1', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', 0, 0, null,null)
, ('TEST02', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, '1', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', 123, 0, null,null)
, ('TEST03', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, '1', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', 123, 0, null,null)
, ('TEST04', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, '1', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', 123, 0, null,null)
, ('TEST05', 'rep_dial', 'xml', 'C', 'S','0',null, null, '0', null, null, null, '1', '2020-06-22 10:00:00', '2020-06-22 10:00:00','0',101,0, null,null)
, ('TEST06', 'rep_dial', 'tar', 'C', 'S','0',null, null, '0', null, null, 'TEST.pdf', '1', '2020-06-22 10:00:00', '2020-06-22 10:00:00','0',102,0, 10,null)
, ('TEST07', 'ini_dial', '', 'C', 'S','0',null, null, '0', null, null, 'TEST.pdf', '1', '2020-06-22 10:00:00', '2020-06-22 10:00:00','0',102,0, null, '2019-03-12 10:00:00')
, ('TEST07', 'profile', '', 'C', 'S','0',null, null, '0', null, null, null, '1', '2020-06-22 10:00:00', '2020-06-22 10:00:00','0',101,0, null,'2020-07-16')
;

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
  ('TEST01', 'TEST_CD', '', 'S', 'cre', 'xml','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<MCSSData ver="Ver.03.80 2020-03-25"><Header><ContentType>dataset:9999.test_dataset_result</ContentType></Header></MCSSData>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
, ('TEST02', 'TEST_CD', '', 'S', 'cre', 'xml','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<MCSSData ver="Ver.03.80 2020-03-25"><Header><PatientCode>$JOURNAL.pat_id</PatientCode></Header></MCSSData>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
, ('TEST03', 'TEST_CD', '', 'S', 'cre', 'xml','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<MCSSData ver="Ver.03.80 2020-03-25"><Content><Row _detail="test_row" MasterID="dataset:9999.detail_001" _sqlCode="9999"></Row></Content></MCSSData>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
, ('TEST04', 'TEST_CD', '', 'S', 'cre', 'xml','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<MCSSData ver="Ver.03.80 2020-03-25"><Content><Row _detail="test_row" _sqlCode="9999"></Row></Content></MCSSData>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
, ('TEST05', 'rep_dial', 'xml', 'S', 'cre', 'xml', '', '', '', '1', XMLPARSE(DOCUMENT '<rootNode><PATID>dataset:9999.test_dataset_result</PATID></rootNode>'), '{ "dataset": [{"patId": 0, "sqlCode": 9999}] }', '1', '0', 123, '2020-06-22 10:00:00', '2020-06-22 10:00:00' )
, ('TEST06', 'rep_dial', 'tar', 'S', 'cre', 'tar', '', '', '', '1', XMLPARSE(DOCUMENT '<rootNode><PATID>dataset:9999.test_dataset_result</PATID></rootNode>'), '{ "dataset": [{"patId": 0, "sqlCode": 9999}] }', '1', '0', 123, '2020-06-22 10:00:00', '2020-06-22 10:00:00' )
, ('TEST07', 'ini_dial', '', 'S', 'cre', 'xml', '', '', '', '1', XMLPARSE(DOCUMENT '<rootNode><BASEDATE>$JOURNAL.base_date</BASEDATE></rootNode>'), null, '1', '0', 123, '2020-06-22 10:00:00', '2020-06-22 10:00:00' )
, ('TEST07', 'profile', '', 'S', 'cre', 'xml', '', '', '', '1', XMLPARSE(DOCUMENT '<Content><ATTRIBUTES att1="$JOURNAL.ord_no" att2="$JOURNAL.coop_ord_no" att3="$JOURNAL.hosp_pat_id" att4="$JOURNAL.pat_id" att5="$JOURNAL.base_date" /></Content>'), null, '1', '0', 123, '2020-06-22 10:00:00', '2020-06-22 10:00:00' )
;

INSERT INTO
  mst_coop_layout_detail
  (
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  )
  VALUES
  ('TEST03', 'TEST_CD', 'S', 'test_row', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<RowData>dataset:9999.detail_002</RowData>'), null, '1', '0')
, ('TEST04', 'TEST_CD', 'S', 'test_row', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<RowData RowCount="$COUNT" MasterID="dataset:9999.detail_001">dataset:9999.detail_002</RowData>'), null, '1', '0')
;

insert into
  mst_coop_facility
  values
  ('-2','TEST07',NULL,'1','0',NULL,'{"coop_ord_cd": [{"ord_cd": "ini_dial"}, {"ord_cd": "profile"}, {"ord_cd": "accept"}, {"ord_cd": "rst_dial"}, {"ord_cd": "karte_ord"}, {"ord_cd": "ind_dial"}, {"ord_cd": "vit_cop"}, {"ord_cd": "rep_dial", "report": true}, {"ord_cd": "exam_ord"}, {"ord_cd": "rad_ord"}]}',NULL,NULL,NULL)
  ;