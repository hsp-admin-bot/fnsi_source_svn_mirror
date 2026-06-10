SELECT A.machine_type_cd,
       A.machine_serial,
       B.machine_record_cd
FROM
    (
        SELECT
            machine_type_cd,
            machine_serial,
            MAX ( motion_record_no ) motion_record_no
        FROM
            mnt_motion_record
        WHERE
           facility_cd = /*facilityCd*/'1'
          -- add #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
          AND machine_type_cd = /*machineTypeCd*/null
          AND data_type = 1
          AND machine_serial = /*machineSerial*/null
          AND reg_date >= /*beginDate*/null
          AND reg_date < /*endDate*/null
          -- add #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
--           AND ( machine_record_cd = '- ' OR machine_record_cd = '-   ' OR machine_record_cd = '-  ' )
          --mod #10063 by zhangruixue 2023-11-17  --start
          AND ( machine_record_cd = 'G100' OR machine_record_cd = 'G101' OR machine_record_cd = 'G102')
          --mod #10063 by zhangruixue 2023-11-17 --end
        GROUP BY
            machine_type_cd,
            machine_serial
    ) A,
    mnt_motion_record B
WHERE A.machine_serial = B.machine_serial
  AND A.machine_type_cd = B.machine_type_cd
  AND A.motion_record_no = B.motion_record_no
;
