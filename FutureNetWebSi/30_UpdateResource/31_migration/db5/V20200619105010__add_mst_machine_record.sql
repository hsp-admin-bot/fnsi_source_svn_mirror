-- 装置記録マスタにG003~005を追加

insert into mst_machine_record
  (machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model)
values
  ('G003','デバイスエッジ接続USBメモリー故障', now(), now(),'0','6','6') on conflict do nothing;

insert into mst_machine_record
  (machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model)
values
  ('G004','デバイスエッジ接続SDメモリーカード故障', now(), now(),'0','6','6') on conflict do nothing;

insert into mst_machine_record
  (machine_record_cd,machine_record_message,reg_date,up_date,is_default,log_class,target_model)
values
  ('G005','デバイスエッジ通信異常・異常から復旧', now(), now(),'0','6','6') on conflict do nothing;