select
    A.monitor_data AS monitor_data,B.ord_no AS ord_no
from
    mnt_machine_state A,
    (
        select
            B1.facility_cd, B1.machine_type_cd, B1.machine_serial, B1.ord_no
        from
            mni_monitor B1,
            (select facility_cd, ord_no, pat_id, max(occur_date) AS occur_date
             from mni_monitor
             where is_del = '0'
               and
                 /*%for  bodyData : bodyDataList*/
                 (facility_cd = /* bodyData.facilityCd */'1'
                     and
                  ord_no = /* bodyData.ordNo */0
                     and
                  pat_id = /* bodyData.patId */0)
                /*%if bodyData_has_next */
                /*# "or" */
                /*%end*/
                /*%end*/
             group by
                 facility_cd, ord_no, pat_id
            ) as B2
        where
                B1.facility_cd = B2.facility_cd
          and
                B1.ord_no = B2.ord_no
          and
                B1.pat_id = B2.pat_id
          and
                B1.occur_date = B2.occur_date
    ) AS B
where
        A.facility_cd = B.facility_cd
  and
        A.machine_type_cd = B.machine_type_cd
  and
        A.machine_serial = B.machine_serial
;
