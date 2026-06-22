select
  mms.facility_cd,
  mms.machine_type_cd,
  mms.machine_serial,
  mms.ord_no,
  mms.bed_name,
  mms.alarm_list,
  om.pat_id,
  om.rst_treatment_cd,
  om.rst_start_date,
  om.rst_medi_info,
  om.rst_complaint_info,
  om.rst_treatment_info,
  om.rst_treat_staff_info,
  -- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
--   mt.device_mode,
  om.rst_device_mode as device_mode,
  -- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
  -- add by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --start
  mm.com_type,
  -- add by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --end
  CASE WHEN om.pat_id is null
    THEN mds.host_notification_info
    ELSE pm.host_notification_info
  END as host_notification_info
from
  mnt_machine_state as mms
inner join
  mst_device_set_info_default as mds
  on mds.facility_cd = mms.facility_cd
inner join
  mst_machine as mm
  on  mms.facility_cd = mm.facility_cd
  and mms.machine_type_cd = mm.machine_type_cd
  and mms.machine_serial = mm.machine_serial
inner join
  ord_main om
  on mms.ord_no = om.ord_no
-- del by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
-- left outer join
--   mst_treatment as mt
--   on om.rst_treatment_cd = mt.treatment_cd
-- del by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
left outer join
  pat_main as pm
  on mms.pat_id = pm.pat_id
where
  mms.facility_cd = /*facilityCd*/''
  and mm.device_edge_no = /*deviceEdgeNo*/null
  and mms.ord_no is not null
  and om.rst_dialysis_state = '3'
  and mm.is_del = '0'
  and om.is_del = '0'
  -- DEに紐づく治療中装置を対象にデータを収集する
;
