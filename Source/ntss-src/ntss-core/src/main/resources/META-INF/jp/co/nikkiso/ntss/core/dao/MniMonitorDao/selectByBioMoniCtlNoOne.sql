SELECT mni.reg_date
     , mni.up_date
     , mni.bio_moni_ctl_no
     , mni.facility_cd
     , mni.machine_type_cd
     , mni.machine_serial
     , mni.ord_no
     , mni.pat_id
     , mni.data_type
     , mni.monitor_data
     , mni.is_del
     , mni.occur_date
     , mni.upd_staff_id
FROM mni_monitor mni

WHERE mni.bio_moni_ctl_no = /* bioMoniCtlNo */0
    AND mni.is_del = '0'
;
