select
  A.ord_no,
  A.facility_cd,
  A.pat_id,
  A.treat_date,
  A.treat_week,
  A.rst_weight_info,
  A.rst_dw,
  A.rst_return_home_date,
  A.rst_treatment_cd,
  A.rst_cond_info,
  B.device_mode
from
  ord_main A
  left outer join mst_treatment B on (A.rst_treatment_cd = B.treatment_cd)
where
  A.pat_id = /*patId*/1
and
  A.treat_date >= /*satrttreatDate*/'20180131'
and
  A.treat_date <= /*endtreatDate*/'20180401'
and
  A.facility_cd = /*facilityCd*/'999900'
and
  A.is_del = '0'
order by
  A.treat_date desc,
  COALESCE(A.rst_return_home_date, '3000/01/01 00:00:00.000') desc
;