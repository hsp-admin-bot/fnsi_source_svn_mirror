SELECT
  A.machine_record_cd
FROM
  mnt_motion_record A JOIN
  (
    SELECT
      MAX(motion_record_no) motion_record_no
    FROM
      mnt_motion_record
    WHERE facility_cd = /*facilityCd*/'1'
    AND machine_type_cd = /*machineTypeCd*/null
    AND machine_serial = /*machineSerial*/null
    AND data_type = 1
    --mod #10063 by zhangruixue 2024-04-08 --start
    AND machine_record_cd IN ('G100', 'G101', 'G102')
--       AND machine_record_cd IN ('- ', '-   ', '-  ')
    --mod #10063 by zhangruixue 2024-04-08 --end
    AND event_reg_date >= CURRENT_DATE
    GROUP BY
      facility_cd,
      machine_type_cd,
      machine_serial
  )  B
  ON A.motion_record_no = B.motion_record_no
;
