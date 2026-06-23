---------------------------------------------------
-- sys_master_defineの項目追加　TDC高瀬　2019/05/09
---------------------------------------------------
-- ベッドレイアウトマスタの項目を追加
insert into ntss.sys_master_define(
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
  'mst_status_map_bed_layout'
  , 'ベッドレイアウトマスタ'
  , '2'
  , '2'
  , '1'
  , '1'
  , 623
  , null
  , null
  , now()
  , now()
  , null
  , '0'
);