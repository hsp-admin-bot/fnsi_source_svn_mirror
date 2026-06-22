delete from
  pat_treatment_pattern 
where
  pat_id = /*pat_id*/null
and
  facility_cd = /*facility_cd*/null
/*%if null != ctl_no*/
and
  ctl_no = /*ctl_no*/null
/*%end*/
/*%if 0 != ind_treatment_cd.size()*/
and
  ind_treatment_cd in /*ind_treatment_cd*/(1)
/*%end*/
/*%if 0 != ind_kur_cd.size()*/
and
  ind_kur_cd in /*ind_kur_cd*/(1)
/*%end*/
/*%if 0 != treat_week_list.size() && 0 != treat_week_list.get(0)*/
and
  treat_week in /*treat_week_list*/(null)
/*%end */
;