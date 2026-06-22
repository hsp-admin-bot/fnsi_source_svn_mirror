-- mni_monitorから指定ord_no、data_typeの情報を古い順で取得
select MM.reg_date,
       MM.up_date,
       MM.bio_moni_ctl_no,
       MM.facility_cd,
       MM.machine_type_cd,
       MM.machine_serial,
       MM.ord_no,
       MM.pat_id,
       MM.data_type,
       MM.monitor_data,
       MM.is_del,
       MM.occur_date,
       MM.upd_staff_id,
       OM.treat_date::DATE AS treat_date
from mni_monitor MM
         LEFT JOIN ord_main OM ON MM.ord_no = OM.ord_no
-- upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start
where MM.is_del = '0'
  AND (MM.facility_cd, MM.ord_no) IN (
    /*%for  bodyData : facilityCdAndOrdNoList*/
        (/* bodyData.get("facility_cd") */null, /* bodyData.get("ord_no") */0)
        /*%if bodyData_has_next */
        /*# "," */
        /*%end*/
    /*%end*/
  )
-- upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end
order by MM.occur_date
;

