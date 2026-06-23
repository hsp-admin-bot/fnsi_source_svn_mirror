DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-304000001, -304000002, -304000003, -304000004, -304000005, -304000006, -304000007, -304000008, -304000009, -304000010, -304000011, -304000012, -304000013, -304000014, -304000015, -307000001, -307000002, -307000003, -307000004, -307000005, -307000006, -307000007, -307000008, -307000009, -307000010, -307000011, -307000012, -307000013, -307000014, -307000015, -307000016, -307000017, -307000018, -307000019, -307000020, -307000021, -308000001, -309000001, -309000002, -316000001, -316000002, -316000003, -316000004, -316000005, -316000006, -316000007, -316000008, -316000009, -316000010, -316000011, -316000012, -316000013, -316000014, -316000015, -316000016, -316000017, -316000018, -316000019, -316000020, -316000021, -316000022, -316000023, -316000024, -316000025, -316000026, -316000027, -3010000001, -3010000002, -3010000003, -3010000004, -3010000005, -3010000006, -3010000007, -3010000008, -3010000009, -3010000010, -3010000011, -3010000012, -3010000013, -3010000014, -3010000015, -3010000016, -3010000017, -3010000018, -3010000019, -3010000020, -3010000021, -3010000022, -3010000023, -3010000024, -3010000025, -3010000026, -3010000027, -3010000028);

INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000001, 'N_hosp', 'ind_dial', 'S', '指示詳細', 'pre', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析指示詳細(pre)">
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
</root>', '{"key": {"種別": {"VA": "VA", "A針": "穿刺針", "V針": "穿刺針", "SN針": "穿刺針", "加算": "加算", "医材": "医材", "補液": "補液", "調製": "調製", "1次膜": "膜", "2次膜": "膜", "穿刺針": "穿刺針", "透析液": "透析液", "所要時間": "所要時間", "投与薬剤": "投与薬剤", "抗凝固剤": "抗凝固剤", "治療項目": "治療項目", "ダイアライザ": "ダイアライザ"}}}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000002, 'N_hosp', 'ind_dial', 'S', '指示詳細', '加算', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000003, 'N_hosp', 'ind_dial', 'S', '指示詳細', 'VA', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000004, 'N_hosp', 'ind_dial', 'S', '指示詳細', '治療項目', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000005, 'N_hosp', 'ind_dial', 'S', '指示詳細', 'ダイアライザ', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000006, 'N_hosp', 'ind_dial', 'S', '指示詳細', '抗凝固剤', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000007, 'N_hosp', 'ind_dial', 'S', '指示詳細', '透析液', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000008, 'N_hosp', 'ind_dial', 'S', '指示詳細', '補液', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000009, 'N_hosp', 'ind_dial', 'S', '指示詳細', '投与薬剤', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000010, 'N_hosp', 'ind_dial', 'S', '指示詳細', '調製', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000011, 'N_hosp', 'ind_dial', 'S', '指示詳細', '穿刺針', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000012, 'N_hosp', 'ind_dial', 'S', '指示詳細', '医材', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000013, 'N_hosp', 'ind_dial', 'S', '指示詳細', '膜', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000014, 'N_hosp', 'ind_dial', 'S', '指示詳細', '所要時間', 'NEC', '指示送信(★無効設定)', '1', '<root name="透析実績詳細(pre)">
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
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-304000015, 'N_hosp', 'ind_dial', 'S', '指示詳細', '指示詳細', 'NEC', '指示送信', '1', '<root name="詳細指示">
  <item name="明細.項目連番" len="3" type="string" value="dataset:-204.cost_no"/>
  <item name="明細.項目コード" len="6" type="string" value="dataset:-204.e01"/>
  <item name="明細.項目世代番号" len="1" type="string" value="dataset:-204.e02"/>
  <item name="明細.機能コード" len="2" type="string" value="dataset:-204.e03"/>
  <item name="明細.数量" len="9" type="string" value="dataset:-204.e04"/>
  <item name="明細.単位" len="2" type="string" value="dataset:-204.e05"/>
  <item name="明細.速度" len="9" type="string" value="dataset:-204.e06"/>
  <item name="明細.速度単位" len="2" type="string" value="dataset:-204.e07"/>
  <item name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
  <item name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
  <item name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
  <item name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
  <item name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
  <item name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
  <item name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string" value="$BLANK"/>
  <item name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000001, 'N_hosp', 'rst_dial', 'S', '実績詳細', 'pre', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="種別" len="32"  key="種別" value="dataset:-202.sbt_key"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
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
</root>', '{"key": {"種別": {"VA": "VA", "A針": "穿刺針", "V針": "穿刺針", "SN針": "穿刺針", "加算": "加算", "医材": "医材", "補液": "補液", "調製": "調製", "1次膜": "膜", "2次膜": "膜", "穿刺針": "穿刺針", "透析液": "透析液", "処置薬剤": "処置薬剤", "所要時間": "所要時間", "投与薬剤": "投与薬剤", "抗凝固剤": "抗凝固剤", "治療項目": "治療項目", "ダイアライザ": "ダイアライザ"}}}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000002, 'N_hosp', 'rst_dial', 'S', '実績詳細', '加算', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000003, 'N_hosp', 'rst_dial', 'S', '実績詳細', 'VA', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000004, 'N_hosp', 'rst_dial', 'S', '実績詳細', '治療項目', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000005, 'N_hosp', 'rst_dial', 'S', '実績詳細', 'ダイアライザ', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000006, 'N_hosp', 'rst_dial', 'S', '実績詳細', '抗凝固剤', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000007, 'N_hosp', 'rst_dial', 'S', '実績詳細', '透析液', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000008, 'N_hosp', 'rst_dial', 'S', '実績詳細', '補液', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000009, 'N_hosp', 'rst_dial', 'S', '実績詳細', '投与薬剤', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000010, 'N_hosp', 'rst_dial', 'S', '実績詳細', '調製', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000011, 'N_hosp', 'rst_dial', 'S', '実績詳細', '処置薬剤', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000012, 'N_hosp', 'rst_dial', 'S', '実績詳細', '穿刺針', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000013, 'N_hosp', 'rst_dial', 'S', '実績詳細', '医材', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000014, 'N_hosp', 'rst_dial', 'S', '実績詳細', '膜', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000015, 'N_hosp', 'rst_dial', 'S', '実績詳細', '所要時間', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析実績詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
    <item  name="明細.項目コード" len="6" type="string" value="dataset:-202.e1"/>
    <item  name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e2"/>
    <item  name="明細.機能コード" len="2"  type="string" value="dataset:-202.e3"/>
    <item  name="明細.数量" len="9" type="string" value="dataset:-202.e4"/>
    <item  name="明細.単位" len="2" type="string" value="dataset:-202.e5"/>
    <item  name="明細.速度" len="9" type="string" value="dataset:-202.e6"/>
    <item  name="明細.速度単位" len="2" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
    <item  name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
	<item  name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
    <item  name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000016, 'N_hosp', 'rst_dial', 'S', 'コメント', 'pre', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析コメント詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-203.com_no"/>
    <item  name="種別" len="2"  key="種別" value="dataset:-203.fin_cd"/>
    <item  name="明細.項目コード" len="60" type="string" value="dataset:-203.com_text"/>
</root>', '{"key": {"種別": {"01": "原疾患", "40": "透析困難", "60": "会計"}}}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000017, 'N_hosp', 'rst_dial', 'S', 'コメント', '会計', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析コメント詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-203.com_no"/>
    <item  name="種別" len="2"  key="種別" value="dataset:-203.fin_cd"/>
    <item  name="明細.項目コード" len="60" type="string" value="dataset:-203.com_text"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000018, 'N_hosp', 'rst_dial', 'S', 'コメント', '透析困難', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析コメント詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-203.com_no"/>
    <item  name="種別" len="2"  key="種別" value="dataset:-203.fin_cd"/>
    <item  name="明細.項目コード" len="60" type="string" value="dataset:-203.com_text"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000019, 'N_hosp', 'rst_dial', 'S', 'コメント', '原疾患', 'NEC', '実績送信(★無効設定。)', '1', '<root name="透析コメント詳細(pre)">
    <item  name="明細.項目連番" len="3" type="string" value="dataset:-203.com_no"/>
    <item  name="種別" len="2"  key="種別" value="dataset:-203.fin_cd"/>
    <item  name="明細.項目コード" len="60" type="string" value="dataset:-203.com_text"/>
</root>', '{}'::jsonb, '1', '1', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000020, 'N_hosp', 'rst_dial', 'S', '実績詳細', '実績詳細', 'NEC', '実績送信', '1', '<root name="透析実績詳細(実績詳細)">
  <item name="明細.項目連番" len="3" type="string" value="dataset:-202.cost_no"/>
  <item name="明細.項目コード" len="6" type="string" value="dataset:-202.e01"/>
  <item name="明細.項目世代番号" len="1" type="string" value="dataset:-202.e02"/>
  <item name="明細.機能コード" len="2" type="string" value="dataset:-202.e03"/>
  <item name="明細.使用量" len="9" type="string" value="dataset:-202.e04"/>
  <item name="明細.使用量単位" len="2" type="string" value="dataset:-202.e05"/>
  <item name="明細.速度" len="9" type="string" value="dataset:-202.e06"/>
  <item name="明細.速度単位" len="2" type="string" value="dataset:-202.e07"/>
  <item name="明細.コメントコード1" len="6" type="string" value="$BLANK"/>
  <item name="明細.コメントコード1世代" len="1" type="string" value="$BLANK"/>
  <item name="明細.コメントコード2" len="6" type="string" value="$BLANK"/>
  <item name="明細.コメントコード2世代" len="1" type="string" value="$BLANK"/>
  <item name="明細.コメントコード3" len="6" type="string" value="$BLANK"/>
  <item name="明細.コメントコード3世代" len="1" type="string" value="$BLANK"/>
  <item name="明細.フリーコメント" len="60" type="string" value="$BLANK"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string" value="const:1"/>
  <item name="明細.予備" len="30" type="string" value="$BLANK"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2023-07-17 21:00:59.145', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-307000021, 'N_hosp', 'rst_dial', 'S', 'コメント', 'コメント', 'NEC', '実績送信', '1', '<root name="透析コメント詳細(コメント)">
  <item name="明細.項目連番" len="3" type="string" value="dataset:-203.com_no"/>
  <item name="種別" len="2" key="種別" value="dataset:-203.fin_cd"/>
  <item name="明細.項目コード" len="60" type="string" value="dataset:-203.com_text"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2023-07-17 21:00:59.145', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-308000001, 'N_hosp', 'rep_dial', 'S', 'report', '05', 'rep_dial', 'rep_dial', '1', '<root>
  <REPORT STARTDATE="dataset:-600006.start_date8a" STARTTIME="dataset:-600006.start_date6a" DATETIMEVALUE="dataset:-600006.start_date14" BEDNAME="dataset:-600006.bed_name" DIALYSIS_NO="dataset:-600006.dialysis_no" EDITION="dataset:-600006.edition" UPDATE_DATETIME="dataset:-600006.up_date"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -600006}]}'::jsonb, '1', '0', 4, '2023-07-17 21:00:58.899', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-309000001, 'N_hosp', 'exam_rst', 'R', '検査結果詳細', 'all', 'NEC想定検査結果受信', 'For test', '1', '<root name="検査結果詳細">
  <item name="病院番号" len="2" type="string"/>
  <item name="患者番号" len="10" type="string"/>
  <item name="採取日" len="8" type="string"/>
  <item name="採取時間" len="4" type="string"/>
  <item name="オーダ番号" len="13" type="string"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号" len="13" type="string"/>
  <item name="報告書区分" len="2" type="string"/>
  <item name="項目コード" len="6" col="$journal.detail.pat_exam_main.exam_result_info.item_cd" type="string"/>
  <item name="負荷時間" len="10" type="string"/>
  <item name="負荷時間ソート順" len="6" type="string"/>
  <item name="検査状況" len="1" type="string"/>
  <item name="緊急区分" len="1" type="string"/>
  <item name="検査結果値" len="8" type="string"/>
  <item name="付加コメント1" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd1" type="string"/>
  <item name="付加コメント2" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd2" type="string"/>
  <item name="基準値外マーク" len="1" col="$journal.detail.pat_exam_main.exam_result_info.hl" type="string"/>
  <item name="材料コード" len="3" type="string"/>
  <item name="編集結果値" len="12" col="$journal.detail.pat_exam_main.exam_result_info.result" type="string"/>
  <item name="更新日付" len="14" col="$journal.detail.pat_exam_main.exam_result_info.result_date" type="string"/>
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="未使用" len="10" type="string"/>
  <item name="基準上限値" len="8" col="$journal.detail.pat_exam_main.exam_result_info.upper" type="string"/>
  <item name="基準下限値" len="8" col="$journal.detail.pat_exam_main.exam_result_info.lower" type="string"/>
  <item name="JLAC-10コード" len="20" type="string"/>
</root>', '{}'::jsonb, '1', '0', 4126, '2019-12-23 07:03:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-309000002, 'N_hosp', 'exam_rst', 'R', '検査コメント詳細', 'all', 'NEC想定検査結果受信', 'For test', '1', '<root name="検査コメント詳細">
  <item name="病院番号" len="2" type="string"/>
  <item name="患者番号" len="10" type="string"/>
  <item name="採取日" len="8" type="string"/>
  <item name="採取時間" len="4" type="string"/>
  <item name="オーダ番号" len="13" type="string"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号" len="13" type="string"/>
  <item name="報告書区分" len="2" type="string"/>
  <item name="検体コメントコード" len="2" type="string"/>
  <item name="検体コメント名称" len="200" type="string"/>
  <item name="更新日付" len="14" type="string"/>
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
</root>', '{}'::jsonb, '1', '0', 4126, '2019-12-23 07:03:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000001, 'N_hosp', 'vit_cop', 'S', 'vital', 'pre', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32"  key="種別" value="dataset:-201.vital_cd"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{"key": {"種別": {"01": "経過時間", "05": "除水積算値", "09": "ＩＰ総量", "11": "静脈圧", "12": "透析液圧", "13": "TMP", "17": "⊿BV", "20": "Ｎａ濃度", "21": "透析液温度", "22": "透析液流量", "31": "治療モード", "32": "除水目標値", "33": "除水速度設定値", "36": "血流量設定値", "37": "ＩＰ速度設定", "72": "補液量現在値", "73": "補液速度設定値", "74": "補液温度", "80": "⊿ＢＶ変化率", "aw": "後体重", "bh": "最高血圧", "bl": "最低血圧", "bw": "前体重", "pl": "脈拍", "te": "体温"}}}'::jsonb, '1', '1', 4, '2020-05-15 12:01:38.830', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000002, 'N_hosp', 'vit_cop', 'S', 'vital', '最高血圧', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:parambh"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000003, 'N_hosp', 'vit_cop', 'S', 'vital', '最低血圧', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:parambl"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000004, 'N_hosp', 'vit_cop', 'S', 'vital', '脈拍', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:parampl"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000005, 'N_hosp', 'vit_cop', 'S', 'vital', '体温', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:paramte"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000006, 'N_hosp', 'vit_cop', 'S', 'vital', '前体重', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:parambw"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000007, 'N_hosp', 'vit_cop', 'S', 'vital', '後体重', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:paramaw"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000008, 'N_hosp', 'vit_cop', 'S', 'vital', '経過時間', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param01"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000009, 'N_hosp', 'vit_cop', 'S', 'vital', '治療モード', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param31"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000010, 'N_hosp', 'vit_cop', 'S', 'vital', '血流量設定値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param36"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000011, 'N_hosp', 'vit_cop', 'S', 'vital', '除水速度設定値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param33"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000012, 'N_hosp', 'vit_cop', 'S', 'vital', '除水積算値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param05"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000013, 'N_hosp', 'vit_cop', 'S', 'vital', '除水目標値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param32"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000014, 'N_hosp', 'vit_cop', 'S', 'vital', '静脈圧', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param11"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000015, 'N_hosp', 'vit_cop', 'S', 'vital', '透析液圧', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param12"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000016, 'N_hosp', 'vit_cop', 'S', 'vital', 'TMP', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param13"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000017, 'N_hosp', 'vit_cop', 'S', 'vital', 'ＩＰ総量', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param09"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000018, 'N_hosp', 'vit_cop', 'S', 'vital', 'ＩＰ速度設定', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param37"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000019, 'N_hosp', 'vit_cop', 'S', 'vital', '透析液温度', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param21"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000020, 'N_hosp', 'vit_cop', 'S', 'vital', 'Ｎａ濃度', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param20"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000021, 'N_hosp', 'vit_cop', 'S', 'vital', '透析液流量', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param22"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000022, 'N_hosp', 'vit_cop', 'S', 'vital', '補液速度設定値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param73"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000023, 'N_hosp', 'vit_cop', 'S', 'vital', '補液量現在値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param72"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000024, 'N_hosp', 'vit_cop', 'S', 'vital', '補液温度', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param74"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000025, 'N_hosp', 'vit_cop', 'S', 'vital', '⊿BV', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param17"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000026, 'N_hosp', 'vit_cop', 'S', 'vital', '⊿ＢＶ変化率', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param80"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-316000027, 'N_hosp', 'vit_cop', 'S', 'バイタル', 'vital', 'NECバイタル送信', 'バイタル送信', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="dataset:-201.vital_cd"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '0', 4, '2020-05-15 12:01:51.647', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000001, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', 'pre', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(pre)">
  <item name="明細.項目連番" len="3" type="string" col="$journal.detail.pat_coop_detail_1.pre_item_number"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.detail.pat_coop_detail_1.pre_item_code"/>
  <item name="明細.項目世代番号" len="1" type="string" col="$journal.detail.pat_coop_detail_1.pre_item_generation"/>
  <item name="明細.項目名称" len="60" type="string" col="$journal.detail.pat_coop_detail_1.pre_item_name"/>
  <item name="明細.機能コード" len="2" key="機能コード" type="string" col="$journal.detail.pat_coop_detail_1.pre_function_code"/>
  <item name="明細.使用量" len="9" type="string" col="$journal.detail.pat_coop_detail_1.pre_usage_amount"/>
  <item name="明細.使用量単位" len="2" type="string" col="$journal.detail.pat_coop_detail_1.pre_usage_unit"/>
  <item name="明細.使用量単位名称" len="60" type="string" col="$journal.detail.pat_coop_detail_1.pre_usage_unit_name"/>
  <item name="明細.速度" len="9" type="string" col="$journal.detail.pat_coop_detail_1.pre_speed"/>
  <item name="明細.速度単位" len="2" type="string" col="$journal.detail.pat_coop_detail_1.pre_speed_unit"/>
  <item name="明細.速度単位名称" len="60" type="string" col="$journal.detail.pat_coop_detail_1.pre_speed_unit_name"/>
  <item name="明細.コメントコード１" len="6" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_code_1"/>
  <item name="明細.コメントコード１世代" len="1" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_generation_1"/>
  <item name="明細.コメント１名称" len="60" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_name_1"/>
  <item name="明細.コメントコード２" len="6" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_code_2"/>
  <item name="明細.コメントコード２世代" len="1" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_generation_2"/>
  <item name="明細.コメント２名称" len="60" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_name_2"/>
  <item name="明細.コメントコード３" len="6" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_code_3"/>
  <item name="明細.コメントコード３世代" len="1" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_generation_3"/>
  <item name="明細.コメント３名称" len="60" type="string" col="$journal.detail.pat_coop_detail_1.pre_comment_name_3"/>
  <item name="明細.フリーコメント" len="60" type="string" col="$journal.detail.pat_coop_detail_1.pre_free_comment"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string" col="$journal.detail.pat_coop_detail_1.pre_interface_flag"/>
  <item name="明細.予備" len="30" type="string" col="$journal.detail.pat_coop_detail_1.pre_reserve"/>
</root>
', '{"key": {"機能コード": {"20": "加算（患者）", "21": "ブラッドアクセス", "22": "部位", "23": "指示コメント", "24": "透析方法", "25": "ダイアライザ", "26": "抗凝固剤", "27": "薬剤", "28": "穿刺針", "29": "使用材料", "30": "加算（その他）", "31": "その他項目", "32": "項目コメント", "3A": "透析コメント１", "3B": "透析コメント２", "3C": "透析コメント３", "3D": "透析コメント４", "3E": "透析コメント５", "3K": "会計コメント", "_DEFAULT": "空白"}}}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000002, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '加算（患者）', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(加算（患者）)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.detail.pat_coop_detail_1.addition_pat_cd"/>
  <item name="明細.項目世代番号" len="1" type="string" col="$journal.detail.pat_coop_detail_1.addition_pat_generation_no"/>
  <item name="明細.項目名称" len="60" type="string"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000003, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', 'ブラッドアクセス', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(ブラッドアクセス)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000004, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '部位', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(部位)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000005, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '指示コメント', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(指示コメント)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.detail.ord_main_2.ind_ind_comment_info.cd"/>
  <item name="明細.項目世代番号" len="1" type="string"/>
  <item name="明細.項目名称" len="60" type="string" col="$journal.detail.ord_main_2.ind_ind_comment_info.content"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000006, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析方法', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析方法)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.ord_main.ind_treatment_cd"/>
  <item name="明細.項目世代番号" len="1" type="string"/>
  <item name="明細.項目名称" len="60" type="string" col="$journal.ord_main.ind_treatment_name"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000007, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', 'ダイアライザ', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(ダイアライザ)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000008, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '抗凝固剤', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(抗凝固剤)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.ord_main.ind_cond_info.25.value"/>
  <item name="明細.項目世代番号" len="1" type="string"/>
  <item name="明細.項目名称" len="60" type="string" col="$journal.ord_main.ind_cond_info.25.value_name_1"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string" col="$journal.ord_main.ind_cond_info.28.value"/>
  <item name="明細.使用量単位" len="2" type="string" col="$journal.ord_main.ind_cond_info.28.unit"/>
  <item name="明細.使用量単位名称" len="60" type="string" col="$journal.ord_main.ind_cond_info.28.unit_name"/>
  <item name="明細.速度" len="9" type="string" col="$journal.ord_main.ind_cond_info.27.value"/>
  <item name="明細.速度単位" len="2" type="string" col="$journal.ord_main.ind_cond_info.27.unit"/>
  <item name="明細.速度単位名称" len="60" type="string" col="$journal.ord_main.ind_cond_info.27.unit_name"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000009, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '薬剤', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(薬剤)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000010, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '穿刺針', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(穿刺針)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.ord_main.ind_cond_info.9.value"/>
  <item name="明細.項目世代番号" len="1" type="string"/>
  <item name="明細.項目名称" len="60" type="string" col="$journal.ord_main.ind_cond_info.9.value_name_1"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000011, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '使用材料', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(使用材料)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000012, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '加算（その他）', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(加算（その他）)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.detail.pat_coop_detail_1.addition_other_cd"/>
  <item name="明細.項目世代番号" len="1" type="string" col="$journal.detail.pat_coop_detail_1.addition_other_generation_no"/>
  <item name="明細.項目名称" len="60" type="string"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000013, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', 'その他項目', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(その他項目)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000014, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '項目コメント', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(項目コメント)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.detail.pat_coop_detail_1.item_comment_cd"/>
  <item name="明細.項目世代番号" len="1" type="string" col="$journal.detail.pat_coop_detail_1.item_comment_generation_no"/>
  <item name="明細.項目名称" len="60" type="string"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000015, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント１', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント１)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.detail.pat_coop_detail_1.dialysis_cmt_1_cd"/>
  <item name="明細.項目世代番号" len="1" type="string" col="$journal.detail.pat_coop_detail_1.dialysis_cmt_1_generation_no"/>
  <item name="明細.項目名称" len="60" type="string"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000016, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント２', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント２)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.detail.pat_coop_detail_1.dialysis_cmt_2_cd"/>
  <item name="明細.項目世代番号" len="1" type="string" col="$journal.detail.pat_coop_detail_1.dialysis_cmt_2_generation_no"/>
  <item name="明細.項目名称" len="60" type="string"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000017, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント３', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント３)">
  <item name="明細.項目連番" len="3" type="string"/>
  <item name="明細.項目コード" len="6" type="string" col="$journal.detail.pat_coop_detail_1.dialysis_cmt_3_cd"/>
  <item name="明細.項目世代番号" len="1" type="string" col="$journal.detail.pat_coop_detail_1.dialysis_cmt_3_generation_no"/>
  <item name="明細.項目名称" len="60" type="string"/>
  <item name="明細.機能コード" len="2" type="string"/>
  <item name="明細.使用量" len="9" type="string"/>
  <item name="明細.使用量単位" len="2" type="string"/>
  <item name="明細.使用量単位名称" len="60" type="string"/>
  <item name="明細.速度" len="9" type="string"/>
  <item name="明細.速度単位" len="2" type="string"/>
  <item name="明細.速度単位名称" len="60" type="string"/>
  <item name="明細.コメントコード１" len="6" type="string"/>
  <item name="明細.コメントコード１世代" len="1" type="string"/>
  <item name="明細.コメント１名称" len="60" type="string"/>
  <item name="明細.コメントコード２" len="6" type="string"/>
  <item name="明細.コメントコード２世代" len="1" type="string"/>
  <item name="明細.コメント２名称" len="60" type="string"/>
  <item name="明細.コメントコード３" len="6" type="string"/>
  <item name="明細.コメントコード３世代" len="1" type="string"/>
  <item name="明細.コメント３名称" len="60" type="string"/>
  <item name="明細.フリーコメント" len="60" type="string"/>
  <item name="明細.医事インターフェースフラグ" len="1" type="string"/>
  <item name="明細.予備" len="30" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000018, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント４', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント４)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000019, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント５', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント５)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000020, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '会計コメント', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(会計コメント)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000021, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '空白', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(空白)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000022, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', 'pre', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(pre)">
  <item name="明細.コメント連番" len="3" type="string" col="$journal.detail.pat_coop_detail_2.pre_comment_number"/>
  <item name="明細.コメント種別" len="2" key="コメント種別" type="string" col="$journal.detail.pat_coop_detail_2.pre_comment_type"/>
  <item name="明細.コメント内容" len="60" type="string" col="$journal.detail.pat_coop_detail_2.pre_comment_content"/>
</root>
', '{"key": {"コメント種別": {"01": "原疾患", "20": "指示コメント", "60": "会計コメン", "_DEFAULT": "空白"}}}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000023, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', '原疾患', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(原疾患)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000024, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', '指示コメント', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(指示コメント)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000025, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', '会計コメン', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(会計コメン)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000026, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', '空白', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(空白)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000027, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細_空白', 'all', 'NEC想定初回指示-詳細', '初回指示電文ver2、患者情報、患者死亡退院情報用', '1', '<root name="透析指示オーダ明細(all)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010000028, 'N_hosp', 'ini_dial', 'R', '透析コメント明細_空白', 'all', 'NEC想定初回指示-詳細', '初回指示電文ver2、患者情報、患者死亡退院情報用', '1', '<root name="透析コメント明細(all)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, 'HR');