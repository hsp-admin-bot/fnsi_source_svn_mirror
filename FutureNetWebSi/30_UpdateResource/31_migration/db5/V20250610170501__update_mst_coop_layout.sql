DELETE FROM ntss.mst_coop_layout
WHERE ctl_no in (-11035001);
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no in (-1103500001);
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11035001, 'Secom', 'profile', 'detail', 'R', 'all', 'text', 'セコム連携', 'Secom', '患者プロファイル', '1', '<root name="患者プロファイル(pre)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
  <item name="電文種別" len="2" type="string" col="$journal.pat_personal_main.message_type"/>
  <item name="電文長" len="6" type="string" col="$journal.pat_personal_main.total_byte"/>
  <item name="病院ID" len="6" type="string"/>
  <item name="患者ID" len="12" type="string" col="$journal.pat_personal_main.hosp_pat_id"/>
  <occ name="患者プロファイル" len="2" detail="患者プロファイル詳細"/>
</root>
', '{"dataset": {"sqlGroup1": [{"No1": "患者存在チェック", "crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "[セコム連携-患者プロファイル連携][エラー]取込み対象患者が存在しません。", "ExceptionCondition": "=0"}], "sqlGroup2": [{"No1": "電文種別チェック", "crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -1101501, "@messageType": "$journal.pat_personal_main.message_type", "ExceptionMessage": "[セコム連携-患者プロファイル連携][エラー]電文種別の設定値が異常です。", "ExceptionCondition": "=0"}], "sqlGroup3": [{"No1": "データタイプチェック", "crud": "S", "kind": "1", "judge": "$journal.detail.pat_main.profile_code#=#00001", "table": "pat_main", "ctl_no": "1", "sqlCode": -1101507, "@content": "$journal.detail.pat_main.content", "@dataType": "$journal.detail.pat_main.data_type", "ExceptionMessage": "[セコム連携-患者プロファイル連携][エラー][血液型]電文フォーマット異常です。(@content)", "ExceptionCondition": "<>0"}, {"No1": "血液型更新", "crud": "U", "kind": "1", "judge": "$journal.detail.pat_main.profile_code#=#00001", "table": "pat_main", "ctl_no": "1", "sqlCode": -1101502, "@content": "$journal.detail.pat_main.content"}], "sqlGroup4": [{"No1": "データタイプチェック", "crud": "S", "kind": "1", "judge": "$journal.detail.pat_main.profile_code#=#00002", "table": "pat_main", "ctl_no": "1", "sqlCode": -1101507, "@content": "$journal.detail.pat_main.content", "@dataType": "$journal.detail.pat_main.data_type", "ExceptionMessage": "[セコム連携-患者プロファイル連携][エラー][身長]電文フォーマット異常です。", "ExceptionCondition": "<>0"}, {"No1": "身長更新", "crud": "U", "kind": "1", "judge": "$journal.detail.pat_main.profile_code#=#00002", "table": "pat_main", "ctl_no": "1", "sqlCode": -1101504, "@content": "$journal.detail.pat_main.content"}], "sqlGroup5": [{"No1": "データタイプチェック", "crud": "S", "kind": "1", "judge": "$journal.detail.pat_main.profile_code#=#00045", "table": "pat_main", "ctl_no": "1", "sqlCode": -1101507, "@content": "$journal.detail.pat_main.content", "@dataType": "$journal.detail.pat_main.data_type", "ExceptionMessage": "[セコム連携-患者プロファイル連携][エラー][感染症]電文フォーマット異常です。", "ExceptionCondition": "<>0"}, {"No1": "感染症更新", "crud": "U", "kind": "1", "judge": "$journal.detail.pat_main.profile_code#=#00045", "table": "pat_main", "ctl_no": "1", "sqlCode": -1101505, "@content": "$journal.detail.pat_main.content"}]}}'::jsonb, '1', '0', -1, '2025-05-27 13:22:19.970', '2025-06-09 19:55:32.378', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1103500001, 'Secom', 'profile', 'R', '患者プロファイル詳細', 'pre', 'セコム患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル連携詳細(pre)">
  <item name="プロファイル項目連番" len="2" type="string"/>
  <item name="プロファイルコード" len="5" col="$journal.detail.pat_main.profile_code" type="string"/>
  <item name="データタイプ" len="2" col="$journal.detail.pat_main.data_type" type="string"/>
  <item name="データ長" len="6" type="string" data_length=""/>
  <item name="データ内容" len="0" col="$journal.detail.pat_main.content" type="string" data_length_use=""/>
</root>
', '{}'::jsonb, '1', '0', -1, '2025-05-18 22:33:05.959', '2025-05-18 22:33:05.959', 'Secom');