-- 指定管理番号のモニタデータ取得
-- mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou start
-- select
--   /*%expand "A" */*
-- from
--   mni_monitor A
-- where
--   bio_moni_ctl_no in /* bioMoniCtlNo */(0)
-- and
--   is_del = '0'
SELECT mni.reg_date
     , mni.up_date
     , mni.bio_moni_ctl_no
     , mni.facility_cd
     , mni.machine_type_cd
     , mni.machine_serial
     , mni.ord_no
     , mni.pat_id
     , mni.data_type
     , mnt.monitor_data
     , mni.is_del
     , mni.occur_date
     , mni.upd_staff_id
FROM mni_monitor mni
    LEFT JOIN mnt_machine_state mnt
    ON mni.facility_cd = mnt.facility_cd
    AND mni.machine_type_cd = mnt.machine_type_cd
    AND mni.machine_serial = mnt.machine_serial
    AND mni.ord_no = mnt.ord_no
    AND mni.pat_id = mnt.pat_id
WHERE mni.bio_moni_ctl_no IN /* bioMoniCtlNo */(NULL)
    AND mni.is_del = '0'
-- mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou end
;
