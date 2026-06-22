-- mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou start
-- select
--   /*%expand */*
-- from
--   mni_monitor
-- where
--   bio_moni_ctl_no =
--   (select
--     max(bio_moni_ctl_no)
--   from
--     mni_monitor
--   where
--     facility_cd = /*facilityCd*/'999900'
--   and
--     machine_type_cd = /*machineTypeCd*/'005'
--   and
--     machine_serial = /*machineSerial*/'TDC0001'
--   and
--     data_type=/*dataType*/1
--   and
--     is_del = '0'
--   )
SELECT mni.reg_date
     , mni.up_date
     , mni.bio_moni_ctl_no
     , mni.facility_cd
     , mni.machine_type_cd
     , mni.machine_serial
     , mni.ord_no
     , mni.pat_id
     , mni.data_type
     , mni.is_del
     , mni.occur_date
     , mni.upd_staff_id
     , mnt.monitor_data
FROM(
        select
            t1.reg_date
             , t1.up_date
             , t1.bio_moni_ctl_no
             , t1.facility_cd
             , t1.machine_type_cd
             , t1.machine_serial
             , t1.ord_no
             , t1.pat_id
             , t1.data_type
             , t1.is_del
             , t1.occur_date
             , t1.upd_staff_id
        from mni_monitor t1
                 INNER JOIN (
            select
                max(bio_moni_ctl_no) bio_moni_ctl_no
            from mni_monitor
            where facility_cd = /*facilityCd*/NULL
              AND machine_type_cd = /*machineTypeCd*/NULL
              AND machine_serial = /*machineSerial*/NULL
              AND data_type = /*dataType*/NULL
              AND is_del = '0' ) t2
                            ON t1.bio_moni_ctl_no = t2.bio_moni_ctl_no
    ) mni
        LEFT JOIN mnt_machine_state mnt ON mni.facility_cd = mnt.facility_cd
    AND mni.machine_type_cd = mnt.machine_type_cd
    AND mni.machine_serial = mnt.machine_serial
    AND mni.ord_no = mnt.ord_no
    AND mni.pat_id = mnt.pat_id
ORDER BY mni.bio_moni_ctl_no DESC
    LIMIT 1
-- mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou end
;
