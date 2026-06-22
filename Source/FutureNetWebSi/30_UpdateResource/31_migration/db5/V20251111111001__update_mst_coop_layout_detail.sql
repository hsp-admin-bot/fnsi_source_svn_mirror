DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1111000008,-1111000009,-1111000010);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1111000008, 'Secom', 'rad_ord', 'S', 'ipn_top_del', '02', 'セコム連携_放射線オーダ', 'セコム連携_放射線オーダ_実施単位_del', '1', '<root name="放射線オーダ_実施単位">
  <item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" len="10" value="dataset:-1100018.send_day"/>
  <item name="SEQ番号" len="8" value="dataset:-1100018.seq_no"/>
  <item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
  <item name="指示順" len="1" value="const:1"/>
  <item name="部位コード" len="4" value="dataset:-1106000.part_cd"/>
  <item name="修飾コード5" len="15" value="dataset:-1106000.mod_cd"/>
  <item name="方向コード5" len="15" value="dataset:-1106000.direction_cd"/>
  <item name="手技コード5" len="15" value="dataset:-1106000.procedure_cd"/>
  <item name="フリーコメント1" len="0" value="$BLANK"/>
  <item name="フリーコメント2" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
</root>
', '{
  "dataset": [
    {
      "key0": "key0",
      "ctlNo": "ctlNo",
      "ordNo": "ordNo",
      "patId": "patId",
      "sqlCode": -1100000,
      "facilityCd": "facilityCd"
    },
    {
      "key0": "key0",
      "patId": "patId",
      "sqlCode": -1100006,
      "facilityCd": "facilityCd"
    },
    {
      "key0": "key0",
      "ordNo": "ordNo",
      "patId": "patId",
      "sqlCode": -1106000,
      "facilityCd": "facilityCd"
    },
    {
      "ordNo": "ordNo",
      "patId": "patId",
      "coopCd": "rad_ord",
      "sqlCode": -1100018,
      "position": 1,
      "facilityCd": "facilityCd"
    }
  ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1111000009, 'Secom', 'rad_ord', 'S', 'idx_top_del', '02', 'セコム連携_放射線オーダ', 'セコム連携_放射線オーダ_オーダーインデックス_del（コンバート）', '1', '<root name="放射線オーダ_オーダーインデックス">
  <item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" len="10" value="dataset:-1100018.send_day"/>
  <item name="SEQ番号" len="8" value="dataset:-1100018.seq_no"/>
  <item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
  <item name="INDEX区分" len="1" value="const:2"/>
  <item name="XX区分" len="2" value="const:30"/>
  <item name="タイトル" len="60" value="dataset:-1106000.title"/>
  <item name="診療科コード" len="3" value="dataset:-1100000.course_cd2"/>
  <item name="事業所コード" len="3" value="const:000"/>
  <item name="入外区分" len="1" value="dataset:-1100006.in_out_class"/>
  <item name="開始日" len="10" value="dataset:-1106000.reg_rad_date"/>
  <item name="終了日" len="10" value="dataset:-1106000.reg_rad_date"/>
  <item name="実施時刻" len="8" value="$BLANK"/>
  <item name="中止フラグ" len="1" value="const:1"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="中止ユーザID" len="6" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="事後入力フラグ" len="1" value="const:0"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
</root>
', '{
  "dataset": [
    {
      "key0": "key0",
      "ctlNo": "ctlNo",
      "ordNo": "ordNo",
      "patId": "patId",
      "sqlCode": -1100000,
      "facilityCd": "facilityCd"
    },
    {
      "key0": "key0",
      "patId": "patId",
      "sqlCode": -1100006,
      "facilityCd": "facilityCd"
    },
    {
      "key0": "key0",
      "ordNo": "ordNo",
      "patId": "patId",
      "sqlCode": -1106000,
      "facilityCd": "facilityCd"
    },
    {
      "ordNo": "ordNo",
      "patId": "patId",
      "coopCd": "rad_ord",
      "sqlCode": -1100018,
      "position": 1,
      "facilityCd": "facilityCd"
    }
  ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1111000010, 'Secom', 'rad_ord', 'S', 'head_top_del', '02', 'セコム連携_放射線オーダ', 'セコム連携_放射線オーダ_処方ヘッダー_del（コンバート）', '1', '<root name="放射線オーダ_処方ヘッダー">
  <item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" len="10" value="dataset:-1100018.send_day"/>
  <item name="SEQ番号" len="8" value="dataset:-1100018.seq_no"/>
  <item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="検査指示数" len="1" value="const:1"/>
  <item name="コメントコード3" len="0" value="$BLANK"/>
  <item name="フリーコメント" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="指示フラグ20" len="8" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="緊急区分" len="1" value="const:0"/>
  <item name="その他" len="0" value="$BLANK"/>
  <item name="移動方法" len="0" value="$BLANK"/>
  <item name="妊娠情報" len="0" value="$BLANK"/>
</root>
', '{
  "dataset": [
    {
      "key0": "key0",
      "ctlNo": "ctlNo",
      "ordNo": "ordNo",
      "patId": "patId",
      "sqlCode": -1100000,
      "facilityCd": "facilityCd"
    },
    {
      "key0": "key0",
      "patId": "patId",
      "sqlCode": -1100006,
      "facilityCd": "facilityCd"
    },
    {
      "key0": "key0",
      "ordNo": "ordNo",
      "patId": "patId",
      "sqlCode": -1106000,
      "facilityCd": "facilityCd"
    },
    {
      "ordNo": "ordNo",
      "patId": "patId",
      "coopCd": "rad_ord",
      "sqlCode": -1100018,
      "position": 1,
      "facilityCd": "facilityCd"
    }
  ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
