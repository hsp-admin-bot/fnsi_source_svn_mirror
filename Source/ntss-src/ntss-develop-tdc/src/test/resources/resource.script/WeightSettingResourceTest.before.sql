delete from mst_weight;

insert into mst_weight
  ( facility_cd, weight_no, port_no, device_class, is_auto_send_before, is_auto_send_after,
    wait_auto_send_before, wait_auto_send_after, is_default_print_before, is_default_print_after, printer_class, bed_group_cd, 
    is_has_card_reader, check_content, print_setting, color_setting, audio_setting, is_disp, 
    is_del, reg_date, up_date
  )
values
  ('999999', 1, 1, 0, '0', '0', 
   0, 0, NULL, NULL, NULL, NULL, 
   '0', NULL, NULL, NULL, NULL, '0',
   '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
  ;
 