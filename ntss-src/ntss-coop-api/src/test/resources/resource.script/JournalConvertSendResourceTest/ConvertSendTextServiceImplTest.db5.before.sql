DELETE FROM mst_coop_layout_detail;

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
  , pat_id
  , ord_no
  )
  VALUES
  ('TEST01', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST02', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST03', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST05', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST06', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST07', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST08', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST09', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST10', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST11', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST12', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST13', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST14', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST15', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST16', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST17', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST18', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST19', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST20', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST21', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST22', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST23', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST24', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST25', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST26', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST27', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST28', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST29', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST30', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST31', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST32', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST33', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0),
  ('TEST34', 'TEST_CD', '', 'C', 'S', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', null, null, '1', current_timestamp, current_timestamp, '0', 0, 0);

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
  ('TEST01', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST02', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="const:HOGE"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST03', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="const:HOGE" padding_format="zero" padding_position="left"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST05', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="const:HOGE" padding_format="blank" padding_position="left"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST06', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="const:HOGE" padding_format="blank" padding_position="right"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST07', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><occ name="オカレンス" len="0" type="string" detail="test_occ" sqlCode="9999"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST08', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><occ name="オカレンス" len="0" type="string" repeat="2" detail="test_occ" sqlCode="9999"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST09', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><occ name="オカレンス" len="3" type="string" detail="test_occ" sqlCode="9999"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST10', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="12" type="string" value="dataset:9999.test_dataset_result"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST11', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別1" len="12" type="string" value="dataset:9999.test_dataset_result"/><item name="電文種別2" len="12" type="string" value="dataset:10000.test_dataset_result"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}, {"hogeParam":"hogehoge", "sqlCode":10000}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST12', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別1" len="12" type="string" value="constHOGE"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST13', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="12" type="string" value="dataset:9999.test_dataset_result"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST14', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="12" type="string" value="dataset:test_dataset_result"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST15', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="8" type="string" value="$SYSDATE"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST16', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="$SYSTIME"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST17', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><occ name="オカレンス" len="3" type="string" detail="test_occ" sqlCode="9999" padding_format="zero" padding_position="left"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST18', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="5" type="string" value="const:&quot;HOGE"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST19', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別1" len="4" type="string" value="const:HOGE"/><item name="終端" len="1" type="string" value="const:\r"/><item name="電文種別2" len="4" type="string" value="const:HOGE"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST20', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="2" type="string" value="const:あいうえお"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST21', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文長" len="6" type="string" value="$LENGTH"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST22', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><item name="電文長" len="6" type="string" value="$LENGTH"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST23', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><item name="電文長" len="6" type="string" value="$LENGTH"/><item name="電文長" len="6" type="string" value="$LENGTH"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST25', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><occ name="オカレンス" len="3" type="string" detail="test_occ" sqlCode="9999"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST26', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><occ name="オカレンス" len="0" type="string" detail="test_occ" repeat="2" sqlCode="9999"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST27', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><occ name="オカレンス" len="4" type="string" detail="test_occ" sqlCode="9999"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST28', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><item name="電文長" len="6" type="string" value="$LENGTH"/><occ name="オカレンス" len="4" type="string" detail="test_occ" sqlCode="9999"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST29', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="const:HOGE" padding_format="fblank" padding_position="left"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST30', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="const:HOGE" padding_format="fblank" padding_position="right"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST31', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="5" type="string" value="const:HOGE" padding_format="fblank" padding_position="right"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST32', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="const:HOGE" padding_format="hoge" padding_position="left"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST33', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="4" type="string" value="const:HOGE"/><occ name="オカレンス" len="3" type="string" detail="test_occ" sqlCode="9999" padding_format="fblank" padding_position="left"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 9999}]}', '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00'),
  ('TEST34', 'TEST_CD', '', 'S', 'cre', 'text     ','test','test','テスト用', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="6" type="string" value="const:HOGE" padding_format="zero" padding_position="right"/></root>'), null, '1', '0', 123, '2019-11-12 15:00:00', '2019-11-12 15:00:00');

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
  ('TEST07', 'TEST_CD', 'S', 'test_occ', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/></root>'), null, '1', '0'),
  ('TEST08', 'TEST_CD', 'S', 'test_occ', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/></root>'), null, '1', '0'),
  ('TEST09', 'TEST_CD', 'S', 'test_occ', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/></root>'), null, '1', '0'),
  ('TEST17', 'TEST_CD', 'S', 'test_occ', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/></root>'), null, '1', '0'),
  ('TEST26', 'TEST_CD', 'S', 'test_occ', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/></root>'), null, '1', '0'),
  ('TEST26', 'TEST_CD', 'S', 'test_occ', 'blank', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/></root>'), null, '1', '0'),
  ('TEST27', 'TEST_CD', 'S', 'test_occ', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/><occ name="オカレンス" len="4" type="string" detail="test_occ" sqlCode="10000"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 10000}]}', '1', '0'),
  ('TEST27', 'TEST_CD', 'S', 'test_occ', 'ut_roop_2', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="明細１" len="5" value="dataset:10000.detail_001" /></root>'), null, '1', '0'),
  ('TEST28', 'TEST_CD', 'S', 'test_occ', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/><occ name="オカレンス" len="4" type="string" detail="test_occ" sqlCode="10000"/></root>'), '{"dataset": [{"hogeParam": "hoge", "sqlCode": 10000}]}', '1', '0'),
  ('TEST28', 'TEST_CD', 'S', 'test_occ', 'ut_roop_2', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="明細１" len="5" value="dataset:10000.detail_001" /></root>'), null, '1', '0'),
  ('TEST33', 'TEST_CD', 'S', 'test_occ', 'ut_roop_1', '1', XMLPARSE(DOCUMENT '<root name="透析初回申し込み"><item name="電文種別" len="3" type="string" value="const:OCC"/></root>'), null, '1', '0'),
  ('TEST94', '0', 'S', 'テスト明細', '350', '1', XMLPARSE(DOCUMENT '<root><INPUTDATA>dataset:-360.inputdata</INPUTDATA></root>'), '{"dataset": [{"sqlCode": -360, "masterId": "dataset:-300.masterid"}]}', '1', '0');
