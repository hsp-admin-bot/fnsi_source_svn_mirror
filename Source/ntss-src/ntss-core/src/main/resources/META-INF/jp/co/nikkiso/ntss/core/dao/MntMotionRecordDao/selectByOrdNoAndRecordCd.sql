select
  motion_record_no,
  event_reg_date,
  m_notice_status,
  facility_cd,
  device_edge_no,
  machine_type_cd,
  machine_serial,
  com_format_cd,
  data_type,
  test_type,
  gathering_manage_no,
  email_send_date,
  email_text,
  machine_record_cd,
  machine_record_message,
  contents,
  machine_record_aux_data,
  email_address,
  email_name,
  remarks,
  is_correction,
  user_id,
  ord_no,
  log_type,
  reg_date,
  up_date,
  is_correction_up_date,
  service_support_type,
  service_support_user_id,
  service_support_up_date,
  report_disp_flg
from
 mnt_motion_record
where
 motion_record_no =
 (
 select
  max(motion_record_no)
 from
  mnt_motion_record
 where
  ord_no = /*ordNo*/0
 and
-- add by chamaojia 2023-05-11 [8229] クエリー条件を追加してインデックス効率を向上   --start       
  facility_cd = /*facilityCd*/''
 and
-- add by chamaojia 2023-05-11 [8229] クエリー条件を追加してインデックス効率を向上   --end   
  machine_record_cd = /*machineRecordCd*/'0101'
 and
  data_type = 1
 )
;