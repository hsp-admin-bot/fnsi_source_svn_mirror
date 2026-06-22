-- mni_monitor(装置モニタデータ)の抽出データ取得SQL
select
  B.bio_moni_ctl_no, B.facility_cd, B.machine_type_cd, B.machine_serial, B.ord_no, B.pat_id, B.monitor_data, B.is_del, B.occur_date, B.reg_date, B.up_date, A.dialysis_date
from
  ord_main A,
  mni_monitor B
where
  A.ord_no = B.ord_no
/*%if null != pat_id */
and
  A.pat_id = /*pat_id*/'000000000001'
/*%end*/
/*%if null != ord_no */
and
  B.ord_no = /*ord_no*/null
/*%end*/
/*%if null != bio_moni_ctl_no */
and
  B.bio_moni_ctl_no = /*bio_moni_ctl_no*/null
/*%end*/
/*%if null !=  dialysis_date_from */
and
  A.dialysis_date >= /*dialysis_date_from*/'20180220'
/*%end*/
/*%if null != dialysis_date_to */
and
  A.dialysis_date <= /*dialysis_date_to*/'20180226'
/*%end*/
order by
  A.dialysis_date, B.occur_date
;
