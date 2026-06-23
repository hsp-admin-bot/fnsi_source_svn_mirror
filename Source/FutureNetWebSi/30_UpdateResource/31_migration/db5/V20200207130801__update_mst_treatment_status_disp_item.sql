-- 治療状況レイアウト選択項目マスタ更新
-- 機械室装置のモニタ項目定義分を削除
delete from
  mst_treatment_status_disp_item
where
  machine_class != '0'
;

-- モニタ項目を使用不可とする
update
  mst_treatment_status_disp_item
set
  is_disp = '0' ,
  is_del = '1',
  up_date = current_timestamp
where
  table_name = 'mni_monitor'
  and field_name ='monitor_data'
  and json_key_name is not null
;

-- 新たな選択項目を追加
-- 治療日
insert into mst_treatment_status_disp_item( item_cd,data_class,machine_class,item_name,table_name,field_name,json_key_name,disp_order,is_disp,is_del,reg_date,up_date)
  values (60,'1','0','治療日',null,null,null,-2,'1','0',current_timestamp,current_timestamp);
-- クール
insert into mst_treatment_status_disp_item( item_cd,data_class,machine_class,item_name,table_name,field_name,json_key_name,disp_order,is_disp,is_del,reg_date,up_date)
  values (61,'1','0','クール',null,null,null,-1,'1','0',current_timestamp,current_timestamp);
