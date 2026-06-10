insert into mst_facility
  (facility_cd, facility_name)
 values
  ('mwtest', 'mwtest')
  ;

insert into mst_weight
  (weight_cd, facility_cd,  weight_no, weight_name,
   port_name, device_class, is_auto_send_before, is_auto_send_after, wait_auto_send_before, wait_auto_send_after,
   is_default_print_before, is_default_print_after, printer_class, bed_group_cd, is_has_card_reader, check_content, print_setting, color_setting,
   audio_setting, is_disp, is_del, reg_date, up_date)
values
  (0, 'mwtest', 0, 'hoge',
  'COM1', 0, '0', '0', 0, 0,
  '0', '0', 0, 0, '0', E'{}', E'{}', E'{}',
  E'{}', '1', '0', '2019/02/04 20:00:00.000', '2019/02/04 20:00:00.000')
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_weight
ADD COLUMN dummy character varying(1) -- ダミー列
;
