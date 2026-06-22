DELETE FROM mst_coop_layout_detail WHERE ctl_no IN 
(-11040004);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11040004, 'Secom', 'ind_dial', 'S', '処置依頼', '処置依頼', '(未完了）セコム連携_透析指示連携_処置依頼ファイル', '（未完了）透析指示連携_処置依頼ファイル', '1', '<root name="処置依頼">
 <!-- memo:SQLの参照先確認 -->
 <file name="オーダーインデックス" detail="オーダーインデックス" sqlCode="105" />
 <file name="処置ヘッダー" detail="処置ヘッダー" sqlCode="105" />
 <file name="処置単位" detail="処置単位" sqlCode="105" />
 <file name="処置項目" detail="処置項目" sqlCode="105" />
 <file name="ファイル作成終了" detail="ファイル作成終了" sqlCode="106" />
</root>

<root name="処置ヘッダー">
 <item name="病院ID" value="dataset:-1100000.hospital_id"/>
 <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
 <item name="発生日" value="dataset:-1100000.occur_date"/>
 <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
 <item name="ユーザID" value="dataset:-1102000.user_id"/>
 <item name="指示区分" value="const:0"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="依頼発生日" value="$BLANK"/>
 <item name="依頼SEQ番号" value="$BLANK"/>
 <item name="依頼ユーザID" value="$BLANK"/>
</root>

<!-- memo:RP番号(処置番号)について、取得元確認 -->
<root name="処置単位">
 <item name="病院ID" value="dataset:-1100000.hospital_id"/>
 <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
 <item name="発生日" value="dataset:-1100000.occur_date"/>
 <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
 <item name="ユーザID" value="dataset:-1102000.user_id"/>
 <item name="指示区分" value="const:0"/>
 <item name="未使用" value="$BLANK"/>
 <item name="RP番号(処置番号)" value="dataset:-1102002.rp_no"/>
 <item name="処置タイミング" value="const:0"/>
 <item name="処置開始日" value="dataset:-1102000.rst_start_date"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="処置終了日" value="dataset:-1102000.rst_start_date"/>
 <item name="フリーコメント1" value="$BLANK"/>
 <item name="フリーコメント2" value="$BLANK"/>
 <item name="フリーコメント3" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="診療区分コード" value="$BLANK"/>
</root>

<root name="処置項目">
</root>', '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');