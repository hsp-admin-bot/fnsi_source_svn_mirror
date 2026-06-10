---------------------------------------------------
-- sys_master_defineの項目変更
---------------------------------------------------
-- 放射線検査項目マスタのマスタ名称を変更
update
  sys_master_define
set
  master_name = '放射線検査項目マスタ'
where
  master_physical_name = 'mst_rad_set';
