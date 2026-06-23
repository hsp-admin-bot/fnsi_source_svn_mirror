-- ベッドマスタ定義編集
update sys_master_define
set mode = 2
where master_physical_name = 'mst_bed';