delete from "mst_coop_layout_detail" where "facility_cd" = 'N_hosp' and "coop_cd" = 'ind_dial';
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000001, 'N_hosp', 'ind_dial', 'S', '指示詳細', 'pre', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析指示詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="種別" len="32"  key="種別" value="dataset:-204.sbt_key"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.コメントコード1" len="6" type="string"/>
    <item  name="明細.コメントコード1世代" len="1" type="string"/>
    <item  name="明細.コメントコード2" len="6" type="string"/>
    <item  name="明細.コメントコード2世代" len="1" type="string"/>
    <item  name="明細.コメントコード3" len="6" type="string"/>
    <item  name="明細.コメントコード3世代" len="1" type="string"/>
	<item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{"key": {"種別": {"VA": "VA", "A針": "穿刺針", "V針": "穿刺針", "SN針": "穿刺針", "加算": "加算", "医材": "医材", "補液": "補液", "調製": "調製", "1次膜": "膜", "2次膜": "膜", "穿刺針": "穿刺針", "透析液": "透析液", "所要時間": "所要時間", "投与薬剤": "投与薬剤", "抗凝固剤": "抗凝固剤", "治療項目": "治療項目", "ダイアライザ": "ダイアライザ"}}}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000002, 'N_hosp', 'ind_dial', 'S', '指示詳細', '加算', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000003, 'N_hosp', 'ind_dial', 'S', '指示詳細', 'VA', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000004, 'N_hosp', 'ind_dial', 'S', '指示詳細', '治療項目', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000005, 'N_hosp', 'ind_dial', 'S', '指示詳細', 'ダイアライザ', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000006, 'N_hosp', 'ind_dial', 'S', '指示詳細', '抗凝固剤', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000007, 'N_hosp', 'ind_dial', 'S', '指示詳細', '透析液', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000008, 'N_hosp', 'ind_dial', 'S', '指示詳細', '補液', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000009, 'N_hosp', 'ind_dial', 'S', '指示詳細', '投与薬剤', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000010, 'N_hosp', 'ind_dial', 'S', '指示詳細', '調製', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000011, 'N_hosp', 'ind_dial', 'S', '指示詳細', '穿刺針', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000012, 'N_hosp', 'ind_dial', 'S', '指示詳細', '医材', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000013, 'N_hosp', 'ind_dial', 'S', '指示詳細', '膜', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000014, 'N_hosp', 'ind_dial', 'S', '指示詳細', '所要時間', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-304000015, 'N_hosp', 'ind_dial', 'S', '指示詳細', '指示詳細', 'NEC', '指示送信', '1', '<root name="詳細指示">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-204.e01"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e02"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-204.e03"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-204.e04"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-204.e05"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-204.e06"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}', '1', '0', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
