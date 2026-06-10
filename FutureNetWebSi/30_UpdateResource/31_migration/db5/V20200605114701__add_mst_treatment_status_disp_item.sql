-- 治療状況レイアウト選択項目マスタに進捗率項目を追加

-- 進捗率
insert into mst_treatment_status_disp_item( item_cd,data_class,machine_class,item_name,table_name,field_name,json_key_name,disp_order,is_disp,is_del,reg_date,up_date)
  values (58,'1','0','進捗率',null,null,null,0,'1','0',current_timestamp,current_timestamp)
on conflict do nothing;
