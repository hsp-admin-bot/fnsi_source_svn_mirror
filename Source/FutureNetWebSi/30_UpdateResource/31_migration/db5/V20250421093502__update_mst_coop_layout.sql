DELETE FROM mst_coop_layout
WHERE ctl_no IN (-4100001, -4100002, -4100003);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100001, 'P_hosp', 'exam_ord', '', 'S', 'cre', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="const:O1"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name_kana"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310010"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100002, 'P_hosp', 'exam_ord', '', 'S', 'upd', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="dataset:-310012.kbn"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name_kana"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310010"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310012, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100003, 'P_hosp', 'exam_ord', '', 'S', 'del', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="dataset:-310013.O1"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd" padding_format="blank" padding_position="left"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310013"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"sqlCode": -310013, "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');