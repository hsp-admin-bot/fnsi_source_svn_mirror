
update
  mnt_machine_state MNT
set
    -- mod #9872  by zhangruixue 2023-10-09 --start
--     machine_status = /*mntParams.machineStatus*/0,
    machine_status = 0,
    process_state = CASE WHEN MST.com_type <> 0 THEN '99' ELSE process_state END,
    is_preventive_mainte = CASE WHEN MST.com_type <> 0 THEN 1 ELSE 0 END,
    -- mod #9872  by zhangruixue 2023-10-09 --end
    up_date = /*mntParams.upDate*/null
    from
-- mod #9872  by zhangruixue 2023-10-09 --start  com_type 0：通信なし(オフライン運用)、1：新通信、2：NX通信、3：医器工V4
  (select facility_cd, machine_type_cd, machine_serial,com_type from mst_machine
    where facility_cd = /*facilityCd*/'1' and machine_no in /*codeList*/(null)) MST
-- mod #9872  by zhangruixue 2023-10-09 --end
where
  MNT.facility_cd = MST.facility_cd
  and MNT.machine_type_cd = MST.machine_type_cd
  and MNT.machine_serial = MST.machine_serial
;
