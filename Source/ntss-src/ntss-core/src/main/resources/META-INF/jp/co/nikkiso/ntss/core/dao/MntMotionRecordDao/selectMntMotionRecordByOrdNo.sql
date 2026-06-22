select
  event_reg_date
 ,m_notice_status
 ,facility_cd
 ,device_edge_no
 ,machine_type_cd
 ,machine_serial
 ,com_format_cd
 ,data_type
 ,test_type
 ,gathering_manage_no
 ,email_send_date
 ,email_text
 ,machine_record_cd
 ,machine_record_message
 ,contents
 ,machine_record_aux_data
 ,email_address
 ,email_name
 ,remarks
 ,is_correction
 ,user_id
 ,is_correction_up_date
 ,service_support_type
 ,service_support_user_id
 ,service_support_up_date
 ,ord_no
 ,log_type
 ,reg_date
 ,up_date
 ,report_disp_flg
from
 mnt_motion_record
where
 facility_cd = /*facilityCd*/'1'
 and
 machine_type_cd = /*machineTypeCd*/'1'
 and
 machine_serial = /*machineSerial*/'1'
 and
 ord_no = /*ordNo*/0
order by
 motion_record_no desc
;
