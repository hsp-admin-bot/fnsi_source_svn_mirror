select
  A.reg_date, A.up_date, A.motion_record_no, A.event_reg_date, A.m_notice_status, A.facility_cd, A.device_edge_no, A.machine_type_cd, A.machine_serial, A.com_format_cd, A.data_type, A.test_type, A.gathering_manage_no, A.email_send_date, A.email_text, A.machine_record_cd, A.contents, A.machine_record_message, A.machine_record_aux_data, A.email_address, A.email_name, A.remarks, A.is_correction, A.user_id, A.ord_no, A.log_type, A.is_correction_up_date, A.service_support_type, A.service_support_user_id, A.service_support_up_date, A.report_disp_flg

from
  mnt_motion_record A

where
  A.facility_cd = /*facilityCd*/'1'
  and
  A.machine_type_cd = /*machineTypeCd*/'1'
  and
  A.machine_serial = /*machineSerial*/'1'
  and
  A.motion_record_no = /*motionRecordNo*/'1'
;
