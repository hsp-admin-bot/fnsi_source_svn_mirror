select
  ind_device_set_info /*%if null!= second_key*/-> /*second_key*/'{}' /*%end*/ as device_info,
  rst_dialysis_state as dialysis_state
from
  ord_main
where
/*%if null != ord_no*/
  ord_no = /*ord_no*/0
/*%else*/
  pat_id = /*pat_id*/0
and
  facility_cd = /*facility_cd*/'000001'
and
  treat_date >= /*start_date*/'20180220'
  /*%if null != end_date*/  
and
  treat_date <= /*end_date*/'20191231'
  /*%end*/
  /*%if 0 != week.size()*/
and
  treat_week in /* week */(1,2,3)
  /*%end*/
  /*%if 0 != treat_method.size()*/
and
  ind_treatment_cd in /*treat_method*/(1,2,3)
  /*%end*/
  /*%if 0 != kur_cd.size()*/
and
  ind_kur_cd in /*kur_cd*/(1,2,3)
  /*%end*/
/*%end*/