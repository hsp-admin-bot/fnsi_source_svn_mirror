SELECT
  rst_device_set_info /*%if null != second_key*/ -> /*second_key*/'{}' /*%end*/ as device_info,
  rst_dialysis_state as dialysis_state
FROM
  ord_main
WHERE
/*%if null != ord_no*/
  ord_no = /*ord_no*/0
/*%else*/
  pat_id = /*pat_id*/0
AND
  facility_cd = /*facility_cd*/'000000'
AND
  treat_date >= /*start_date*/'20180401'
  /*%if null != end_date*/
AND
  treat_date <= /*end_date*/'20180431'
  /*%end*/
  /*%if 0 != week.size()*/
AND
  treat_week in /*week*/(0)
  /*%end*/
  /*%if 0 != treat_method.size()*/
AND
  ind_treatment_cd in /*treat_method*/(0)
  /*%end*/
  /*%if 0 != kur_cd.size()*/
AND
  ind_kur_cd in /*kur_cd*/(0)
  /*%end*/
/*%end*/