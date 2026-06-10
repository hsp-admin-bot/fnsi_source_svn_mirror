delete from mnt_device_edge_manage;

insert into mnt_device_edge_manage
  (manage_no, facility_cd, device_edge_no, order_class, user_id, order_target_class, response_status, reg_date, up_date, manage_info)
values
  (1, '431833', 99, 0, 0, 0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '{"message": "", "payload": "", "upload_file": null, "download_file": null, "upload_bucket": null, "download_bucket": null}' )
;