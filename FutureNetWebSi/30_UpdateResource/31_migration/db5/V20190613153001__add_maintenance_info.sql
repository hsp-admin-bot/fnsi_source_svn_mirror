-- mst_pat_viewer_layout定義の削除
DELETE FROM sys_master_define WHERE master_physical_name = 'mst_pat_viewer_layout';

-- mst_pat_viewer_layout定義の追加
insert 
into sys_master_define( 
  master_physical_name
  , master_name
  , disp_class
  , mode
  , allow_sort
  , allow_add_record
  , disp_order
  , column_info
  , combo_data
  , reg_date
  , up_date
  , reference_combo_def
  , edit_level
) 
values ( 
  'mst_pat_viewer_layout'
  , '患者経過総合ビューアレイアウトマスタ'
  , '2'
  , '1'
  , '1'
  , '1'
  , null
  , '{"fields": [{"type": "number", "alias": "code", "title": "レイアウトコード", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": "true", "maxlength": null}, "physical_name": "layout_cd"}, {"type": "string", "alias": null, "title": "施設コード", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": "6"}, "physical_name": "facility_cd"}, {"type": "string", "alias": "name", "title": "レイアウト名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "layout_name"}, {"type": "modal", "alias": null, "title": " ", "format": null, "hidden": "false", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "detail"}, {"type": "json", "alias": null, "title": "表示項目", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "disp_item_info"}, {"type": "disp", "alias": null, "title": "削除", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "is_disp"}, {"type": "del", "alias": null, "title": "削除フラグ", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "is_del"}]}'
  , null
  , now()
  , now()
  , null
  , '0'
); 
