-- mst_user
delete from sys_master_define where master_physical_name='mst_user';
insert into sys_master_define (master_physical_name,master_name,disp_class,edit_level,mode,allow_sort,allow_add_record,disp_order,column_info,combo_data,reference_combo_def,reg_date,up_date) values ('mst_user','利用者マスタ','2','2','2','0','1',null,null,null,null,now(),now());
