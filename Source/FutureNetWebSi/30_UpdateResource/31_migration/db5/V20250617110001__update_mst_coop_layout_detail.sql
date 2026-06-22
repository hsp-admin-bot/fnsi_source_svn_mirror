DELETE FROM mst_coop_layout_detail WHERE ctl_no IN (
  -103500001,-11030000
  );

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11030000, 'Secom', 'profile', 'R', '患者プロファイル詳細', 'pre', 'セコム患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル連携詳細(pre)">
  <item name="プロファイル項目連番" len="2" type="string"/>
  <item name="プロファイルコード" len="5" col="$journal.detail.pat_main.profile_code" type="string"/>
  <item name="データタイプ" len="2" col="$journal.detail.pat_main.data_type" type="string"/>
  <item name="データ長" len="6" type="string" data_length=""/>
  <item name="データ内容" len="0" col="$journal.detail.pat_main.content" type="string" data_length_use=""/>
</root>
', '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');