select
  B.ord_no, B.edition, B.ctl_no, B.input_class, B.bp_class, B.bp_max, B.bp_min, B.bp_ave, B.blood_sugar_level, B.pulse, B.temperature, B.is_del, B.occur_date, B.up_date, A.dialysis_date
from
  ord_main A,
  ord_vital B
where
  A.ord_no = B.ord_no
and
  A.edition = B.edition
/*%if null != pat_id */
and
  A.pat_id = /*pat_id*/'000000000001'
/*%end*/
/*%if null != ord_no */
and
  B.ord_no = /*ord_no*/null
/*%end*/
/*%if null != edition */
and
  B.edition = /*edition*/null
/*%end*/
/*%if null != ctl_no */
and
  B.ctl_no = /*ctl_no*/null
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
