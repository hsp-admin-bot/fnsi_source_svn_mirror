   select T1.machine_record_message
         ,T1.event_reg_date
         ,T1.user_id
         ,T1.up_date
         ,T1.report_disp_flg
         ,T1.motion_record_no
         ,T2.disp_flg
     from mnt_motion_record T1
left join (select a.machine_record_cd
                 ,coalesce(b.disp_flg, a.disp_flg) as disp_flg
             from mst_machine_record a
        LEFT JOIN mst_machine_record_control b
               on a.machine_record_cd = b.machine_record_cd
              and b.facility_cd = /*facilityCd*/'1') T2
               on T1.machine_record_cd = t2.machine_record_cd
            where T1.facility_cd = /*facilityCd*/'1'
              and T1.ord_no = /*ordNo*/1
              and T2.disp_flg in ('1', '2')
