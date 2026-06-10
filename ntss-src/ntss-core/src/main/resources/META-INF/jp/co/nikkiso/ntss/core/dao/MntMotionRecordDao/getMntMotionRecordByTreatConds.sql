select
  mms.motion_record_no
  , mms.event_reg_date
  , mms.m_notice_status
  , mms.facility_cd
  , mms.device_edge_no
  , mms.machine_type_cd
  , mms.machine_serial
  , mms.com_format_cd
  , mms.data_type
  , mms.test_type
  , mms.gathering_manage_no
  , mms.email_send_date
  , mms.email_text
  , mms.machine_record_cd
  , mms.machine_record_message
  , mms.contents
  , mms.machine_record_aux_data
  , mms.email_address
  , mms.email_name
  , mms.remarks
  , mms.is_correction
  , mms.user_id
  , mms.ord_no
  , mms.log_type
  , mms.reg_date
  , mms.up_date
  , mms.is_correction_up_date
  , mms.service_support_type
  , mms.service_support_user_id
  , mms.service_support_up_date
  , mms.report_disp_flg
from
  mnt_motion_record  mms
    inner join mst_machine mm on
        mms.facility_cd = mm.facility_cd
      and mms.machine_type_cd = mm.machine_type_cd
      and mms.machine_serial = mm.machine_serial
    inner join mst_bed mb on
        mm.facility_cd = mb.facility_cd
      and mm.machine_no = mb.machine_no
where
    mms.facility_cd = /*facilityCd*/'NKKSBR'
  and mms.ord_no = /*ordNo*/0
  and mb.bed_cd = /*bedCd*/0
