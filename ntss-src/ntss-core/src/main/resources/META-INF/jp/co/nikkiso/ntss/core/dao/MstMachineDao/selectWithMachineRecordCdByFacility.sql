SELECT
    machine_no,
    machine_type_cd,
    machine_serial,
    (
        SELECT
            machine_record_cd
        FROM
            mnt_motion_record
        WHERE
                data_type = 1
          AND facility_cd = machine.facility_cd
          AND machine_type_cd = machine.machine_type_cd
          AND machine_serial = machine.machine_serial
--           AND ( machine_record_cd = '- ' OR machine_record_cd = '-   ' OR machine_record_cd = '-  ')
    --mod #10063 by zhangruixue 2023-11-17  --start
          AND ( machine_record_cd = 'G100' OR machine_record_cd = 'G101' OR machine_record_cd = 'G102')
    --mod #10063 by zhangruixue 2023-11-17 --end
        order by machine_record_cd desc limit 1
    ) machine_record_cd
FROM
    mst_machine machine
WHERE
    facility_cd =/*facilityCd*/'1'
;
