select
  A.m_notice_cnt AS m_notice_cnt,
  A.facility_cd AS facility_cd,
  A.machine_type_cd AS machine_type_cd,
  A.machine_serial AS machine_serial
from
  mnt_machine_state A
    INNER JOIN mnt_motion_record B ON B.motion_record_no = /*motionRecordNo*/0
      AND A.facility_cd = B.facility_cd
      AND A.machine_type_cd = B.machine_type_cd
      AND A.machine_serial = B.machine_serial
LIMIT 1
;
