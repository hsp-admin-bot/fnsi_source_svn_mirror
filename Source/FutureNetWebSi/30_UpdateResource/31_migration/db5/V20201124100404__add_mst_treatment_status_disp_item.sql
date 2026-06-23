-- mst_treatment_status_disp_itemに装置自己診断を追加：item_cd=110
insert into mst_treatment_status_disp_item(item_cd,data_class,machine_class,item_name,table_name,field_name,json_key_name,disp_order,is_disp,is_del,reg_date,up_date) values (110,'1','0','装置自己診断',null,null,null,0,'1','0',current_timestamp, current_timestamp);
