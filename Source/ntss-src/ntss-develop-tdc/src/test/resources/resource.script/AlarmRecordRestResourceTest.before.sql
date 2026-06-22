delete from mnt_alarm_record;
delete from mst_moni_item;
delete from mst_machine_type;


insert into mnt_alarm_record
  (facility_cd, machine_type_cd, machine_serial, occur_date, occur_class, moni_no, alarm_class,
   pat_id, ord_no, alarm_record_message, is_disp, is_del, reg_date, up_date)
values
  ('999999', '999', '99999999', '2018/01/01 00:00:00', 1, 1, 1, '123456789012', 1, 'hogehoge', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('999999', '999', '99999999', '2018/01/02 00:00:00', 1, 1, 1, '123456789012', 1, 'hogehoge', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('999999', '999', '99999999', '2018/01/03 00:00:00', 1, 1, 1, '123456789012', 1, 'hogehoge', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('999999', '999', '99999999', '2018/01/04 00:00:00', 1, 1, 1, '123456789012', 1, 'hogehoge', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('999999', '999', '99999999', '2018/01/05 00:00:00', 1, 1, 1, '123456789012', 1, 'hogehoge', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('999999', '999', '99999999', '2018/01/06 00:00:00', 1, 1, 1, '123456789012', 1, 'hogehoge', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('999999', '999', '99999999', '2018/01/07 00:00:00', 1, 1, 1, '123456789012', 1, 'hogehoge', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('999999', '999', '99999999', '2018/01/08 00:00:00', 1, 1, 1, '123456789012', 1, 'hogehoge', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
;

insert into mst_moni_item
  (facility_cd, model, moni_no, mon_data_name, mon_data_short_name)
values
  ('999999', '005', 1, 'モニタデータ名称', 'モ名')
;

insert into mst_machine_type
  (machine_type_cd, machine_type, model, maker, reg_date, up_date)
values
  ('999', 'machine', '005', 'TDC', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
;