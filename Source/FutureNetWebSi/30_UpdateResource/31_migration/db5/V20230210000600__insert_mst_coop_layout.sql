DELETE FROM "ntss"."mst_coop_layout" WHERE ctl_no IN (8677);
INSERT INTO "ntss"."mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (8677, 'nkknkk', 'exam_ord', '', 'S', 'del', 'text', '日機装標準', 'nikkiso', '検査依頼(※電文フォーマットはMedicomと一致しています。直接にMedicomのフォーマットを使います。)', '1', '<root name="検査依頼">
</root>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
