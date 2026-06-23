---------------------------------------------------
-- sys_master_defineの項目追加　MOR高田　2019/08/06
---------------------------------------------------
-- 施設設定マスタの項目を追加
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
  'mst_facility_setting'
  , '施設設定マスタ'
  , '2'
  , '2'
  , '1'
  , '1'
  , null
  , null
  , null
  , now()
  , now()
  , null
  , '1'
);