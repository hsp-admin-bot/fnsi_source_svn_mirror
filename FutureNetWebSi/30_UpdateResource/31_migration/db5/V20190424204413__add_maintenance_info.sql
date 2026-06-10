-- マスタメンテナンスに車いすマスタを追加＋体重計マスタとチェックリストマスタがsys_master_defineになければ追加
INSERT INTO sys_master_define (
    master_physical_name,
    master_name,
    disp_class, mode, allow_sort, allow_add_record, disp_order,
    column_info,
    combo_data,
    reg_date, up_date, reference_combo_def,
    edit_level)
VALUES (
    'mst_wheel_chair',
    '車いすマスタ',
    '2', '2', '1', '1', NULL,
    '{"fields": [{"type": "number", "alias": "code", "title": "車いすコード", "physical_name": "wheel_chair_cd"}, {"type": "string", "alias": "name", "title": "車いす名称", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "wheel_chair_name"}, {"type": "modal", "title": "詳細"}, {"type": "number", "alias": null, "title": "重量(g)", "format": null, "hidden": "false", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "wheel_chair_weight"}, {"type": "date", "alias": null, "title": "重量校正日", "format": null, "hidden": "false", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "scale_date"}, {"type": "number", "alias": null, "title": "重量校正者ID", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "scale_user_id"}, {"type": "number", "alias": null, "title": "所有患者ID", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "pat_id"}, {"type": "combo1", "title": "個人所有", "validation": {"required": true}, "editable": "false", "physical_name": "is_personal"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',
    '{"combos": [{"values": [{"text": "なし", "value": "0"}, {"text": "あり", "value": "1"}], "physical_name": "is_personal"}]}',
    now(), now(), NULL,
    0);

INSERT INTO sys_master_define(
    master_physical_name,
    master_name,
    disp_class, mode, allow_sort, allow_add_record, disp_order,
    column_info,
    combo_data,
    reg_date, up_date, reference_combo_def,
    edit_level)
VALUES
    (
    'mst_weight',
    '体重計マスタ',
    '2','2', '1', '1', 10,
    '{"fields": [{"type": "number", "alias": "code", "title": "体重計コード", "physical_name": "weight_cd"}, {"type": "del", "title": "削除", "physical_name": "is_del"}]}',
    null,
    now(), now(), null,
    0)
ON CONFLICT
DO NOTHING;


INSERT INTO sys_master_define(
    master_physical_name,
    master_name,
    disp_class, mode, allow_sort, allow_add_record, disp_order,
    column_info,
    combo_data,
    reg_date, up_date, reference_combo_def,
    edit_level)
VALUES
    (
    'mst_checklist',
    'チェックリストマスタ',
    '2','2',null,null,null,
    '{"fields": [{"type": "number", "alias": "code", "title": "チェックリストコード", "physical_name": "checklist_cd"}, {"type": "del", "title": "削除", "physical_name": "is_del"}]}',
    null,
    now(), now(), null,
    0)
ON CONFLICT
DO NOTHING;
