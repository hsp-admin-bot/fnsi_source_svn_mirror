-- add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
SELECT
  B.machine_type_cd, B.machine_serial,
  A.machine_record_cd
FROM
  mnt_motion_record A JOIN
  (
    SELECT
      facility_cd, machine_type_cd, machine_serial,
      MAX(motion_record_no) motion_record_no
    FROM
      mnt_motion_record
    WHERE facility_cd = /*facilityCd*/'1'
    /*%if !mntMotionRecordList.isEmpty() */
    and (machine_type_cd,machine_serial) IN (
     /*%for condition:mntMotionRecordList */
     (/* condition.machineTypeCd */null, /* trim(condition.machineSerial) */null)
      /*%if condition_has_next */
        ,
      /*%end*/
     /*%end*/
     )
    /*%end*/
    AND data_type = 1
    AND machine_record_cd IN ('G100', 'G101', 'G102')
    AND event_reg_date >= CURRENT_DATE
    GROUP BY
      facility_cd,
      machine_type_cd,
      machine_serial
  )  B
  ON A.motion_record_no = B.motion_record_no
;
-- add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
