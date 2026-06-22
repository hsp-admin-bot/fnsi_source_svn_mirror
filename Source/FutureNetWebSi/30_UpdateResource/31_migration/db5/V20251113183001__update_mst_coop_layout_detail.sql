DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1104000035,-1104000036,-1104000038,-1104000040);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000035, 'Secom', 'ind_dial', 'S', 'inj_index_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_オーダーインデックス_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100018.send_day"/>
  <item name="SEQ番号" value="dataset:-1100018.seq_no"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="INDEX区分" value="const:2"/>
  <item name="XX区分" value="const:11"/>
  <item name="タイトル" value="dataset:-1102000.shot_title"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd2"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1100006.in_out_class"/>
  <item name="開始日" value="dataset:-1102000.treat_date"/>
  <item name="終了日" value="dataset:-1102000.treat_date"/>
  <item name="実施時刻" value="$BLANK"/>
  <item name="中止フラグ" value="const:1"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="事後入力フラグ" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{
  "dataset": [
    {
      "key0": "-1102021.key0",
      "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss",
      "ctlNo": "-1102021.ctl_no",
      "ordNo": "-1102021.ord_no",
      "patId": "-1102021.pat_id",
      "sqlCode": -1100000,
      "facilityCd": "-1102021.facility_cd"
    },
    {
      "key0": "-1102021.key0",
      "ctlNo": "-1102021.ctl_no",
      "ordNo": "-1102021.ord_no",
      "patId": "-1102021.pat_id",
      "sqlCode": -1102000,
      "facilityCd": "-1102021.facility_cd"
    },
    {
      "key0": "-1102021.key0",
      "patId": "-1102021.pat_id",
      "sqlCode": -1100006,
      "facilityCd": "-1102021.facility_cd"
    },
    {
      "ordNo": "-1102021.ord_no",
      "patId": "-1102021.pat_id",
      "coopCd": "ind_dial",
      "sqlCode": -1100018,
      "position": 4,
      "facilityCd": "-1102021.facility_cd"
    }
  ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000036, 'Secom', 'ind_dial', 'S', 'inj_header_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_注射ヘッダー_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100018.send_day"/>
  <item name="SEQ番号" value="dataset:-1100018.seq_no"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="未使用" value="$BLANK"/>
  <item name="注射種別コード" value="dataset:-1102000.shot_type"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP数" value="dataset:-1102000.rp_num_sum"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処方コメント" value="$BLANK"/>
</root>
', '{
  "dataset": [
    {
      "key0": "-1102022.key0",
      "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss",
      "ctlNo": "-1102022.ctl_no",
      "ordNo": "-1102022.ord_no",
      "patId": "-1102022.pat_id",
      "sqlCode": -1100000,
      "facilityCd": "-1102022.facility_cd"
    },
    {
      "key0": "-1102022.key0",
      "ctlNo": "-1102022.ctl_no",
      "ordNo": "-1102022.ord_no",
      "patId": "-1102022.pat_id",
      "sqlCode": -1102000,
      "facilityCd": "-1102022.facility_cd"
    },
    {
      "key0": "-1102022.key0",
      "patId": "-1102022.pat_id",
      "sqlCode": -1100006,
      "facilityCd": "-1102022.facility_cd"
    },
    {
      "ordNo": "-1102022.ord_no",
      "patId": "-1102022.pat_id",
      "coopCd": "ind_dial",
      "sqlCode": -1100018,
      "position": 4,
      "facilityCd": "-1102022.facility_cd"
    }
  ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000038, 'Secom', 'ind_dial', 'S', 'inj_unit_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100018.send_day"/>
  <item name="SEQ番号" value="dataset:-1100018.seq_no"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="RP番号" value="dataset:-1102010.rp_num"/>
  <item name="処方開始日" value="dataset:-1102000.treat_date"/>
  <item name="投与日数" value="const:1"/>
  <item name="隔日" value="const:0"/>
  <item name="処方終了日" value="dataset:-1102000.treat_date"/>
  <item name="薬品数" value="dataset:-1102010.medi_count"/>
  <item name="手技" value="dataset:-1102010.procedure_hosp_cd"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="一日回数" value="const:1"/>
  <item name="タイミング1" value="$BLANK"/>
  <item name="タイミング2" value="$BLANK"/>
  <item name="タイミング3" value="$BLANK"/>
  <item name="タイミング4" value="$BLANK"/>
  <item name="タイミング5" value="$BLANK"/>
  <item name="コメントコード" value="$BLANK"/>
  <item name="フリーコメント" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{
  "dataset": [
    {
      "key0": "-1102003.key0",
      "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss",
      "ctlNo": "-1102003.ctl_no",
      "ordNo": "-1102003.ord_no",
      "patId": "-1102003.pat_id",
      "sqlCode": -1100000,
      "facilityCd": "-1102003.facility_cd"
    },
    {
      "key0": "-1102003.key0",
      "ctlNo": "-1102003.ctl_no",
      "ordNo": "-1102003.ord_no",
      "patId": "-1102003.pat_id",
      "sqlCode": -1102000,
      "facilityCd": "-1102003.facility_cd"
    },
    {
      "key0": "-1102003.key0",
      "ctlNo": "-1102003.ctl_no",
      "ordNo": "-1102003.ord_no",
      "sortKey": "-1102003.sort_key",
      "sqlCode": -1102010,
      "facilityCd": "-1102003.facility_cd"
    },
    {
      "key0": "-1102003.key0",
      "patId": "-1102003.pat_id",
      "sqlCode": -1100006,
      "facilityCd": "-1102003.facility_cd"
    },
    {
      "ordNo": "-1102003.ord_no",
      "patId": "-1102003.pat_id",
      "coopCd": "ind_dial",
      "sqlCode": -1100018,
      "position": 4,
      "facilityCd": "-1102003.facility_cd"
    }
  ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000040, 'Secom', 'ind_dial', 'S', 'inj_item_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100018.send_day"/>
  <item name="SEQ番号" value="dataset:-1100018.seq_no"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="RP番号(処置番号)" value="dataset:-1102012.rp_num"/>
  <item name="薬品番号" value="dataset:-1102012.medi_num"/>
  <item name="薬品コード" value="dataset:-1102012.medi_cd"/>
  <item name="用量" value="dataset:-1102012.medi_amount"/>
  <item name="未使用" value="$BLANK"/>
  <item name="単位コード" value="dataset:-1102012.unit_convert"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{
  "dataset": [
    {
      "key0": "-1102011.key0",
      "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss",
      "ctlNo": "-1102011.ctl_no",
      "ordNo": "-1102011.ord_no",
      "patId": "-1102011.pat_id",
      "sqlCode": -1100000,
      "facilityCd": "-1102011.facility_cd"
    },
    {
      "key0": "-1102011.key0",
      "ctlNo": "-1102011.ctl_no",
      "ordNo": "-1102011.ord_no",
      "patId": "-1102011.pat_id",
      "sqlCode": -1102000,
      "facilityCd": "-1102011.facility_cd"
    },
    {
      "key0": "-1102011.key0",
      "ctlNo": "-1102011.ctl_no",
      "ordNo": "-1102011.ord_no",
      "sortKey": "-1102011.sort_key",
      "sqlCode": -1102012,
      "facilityCd": "-1102011.facility_cd"
    },
    {
      "key0": "-1102011.key0",
      "patId": "-1102011.pat_id",
      "sqlCode": -1100006,
      "facilityCd": "-1102011.facility_cd"
    },
    {
      "ordNo": "-1102011.ord_no",
      "patId": "-1102011.pat_id",
      "coopCd": "ind_dial",
      "sqlCode": -1100018,
      "position": 4,
      "facilityCd": "-1102011.facility_cd"
    }
  ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
