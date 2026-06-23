-- #10027 検査セットマスタ・検査項目マスタの院外院内設定について
-- 検査セットマスタ
UPDATE ntss.sys_master_define
SET column_info = '{"fields": [{"type": "number", "alias": "code", "title": "検査セットID", "physical_name": "exam_set_cd"}, {"type": "string", "alias": "name", "title": "検査セット名", "editable": "true", "validation": {"required": "true", "maxlength": 40}, "physical_name": "exam_set_name"}, {"type": "combo1", "title": "院内院外フラグ", "hidden": "true", "physical_name": "is_in_hospital"}, {"type": "string", "alias": "shortname", "title": "省略検査セット名", "editable": "true", "validation": {"maxlength": 40}, "physical_name": "exam_set_short_name"}, {"type": "modal", "title": "詳細"}, {"type": "string", "alias": "examsetclass", "title": "セット使用区分", "hidden": "true", "physical_name": "exam_set_class"}, {"type": "combo1", "title": "至急フラグ", "physical_name": "can_emergency"}, {"type": "string", "alias": "examtime", "title": "その他検査時刻", "hidden": "true", "physical_name": "other_exam_time"}, {"type": "string", "alias": "graphset", "title": "グラフセット", "hidden": "true", "physical_name": "graph_set"}, {"type": "json", "alias": "iteminfo", "title": "検査項目情報", "hidden": "true", "physical_name": "exam_item_info"}, {"type": "json", "alias": "labelinfo", "title": "ラベル情報", "hidden": "true", "physical_name": "label_info"}, {"type": "string", "alias": null, "title": "連携コード1", "format": null, "hidden": "false", "locked": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "false", "maxlength": "20"}, "physical_name": "in_hospital_cd1"}, {"type": "string", "alias": null, "title": "連携コード2", "format": null, "hidden": "false", "locked": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "false", "maxlength": "20"}, "physical_name": "in_hospital_cd2"}, {"type": "string", "alias": null, "title": "連携コード3", "format": null, "hidden": "false", "locked": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "false", "maxlength": "20"}, "physical_name": "in_hospital_cd3"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',
combo_data = '{"combos": [{"values": [{"text": "通常", "value": "0"}, {"text": "至急可", "value": "1"}], "physical_name": "can_emergency"}, {"values": [{"text": "院外", "value": "0"}, {"text": "院内", "value": "1"}], "physical_name": "is_in_hospital"}]}'
WHERE master_physical_name='mst_exam_set';

-- 採血管マスタ
UPDATE ntss.sys_master_define
SET combo_data = '{"combos": [{"values": [{"text": "院外", "value": "0"}, {"text": "院内", "value": "1"}], "physical_name": "is_in_hospital"}]}'
WHERE master_physical_name='mst_spitz';

-- 採血管マスタ　データ更新
UPDATE MST_SPITZ
SET IS_IN_HOSPITAL =
	CASE WHEN IS_IN_HOSPITAL = '0'
		THEN '1'
	WHEN IS_IN_HOSPITAL = '1'
		THEN '0'
	ELSE IS_IN_HOSPITAL
END;
