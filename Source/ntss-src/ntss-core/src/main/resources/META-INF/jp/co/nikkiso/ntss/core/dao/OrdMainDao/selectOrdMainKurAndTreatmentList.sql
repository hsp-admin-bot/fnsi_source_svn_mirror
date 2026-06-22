select
  om.facility_cd,
  om.pat_id as pat_id,
  om.ind_kur_cd as ind_kur_cd, 
  case
    when om.ind_kur_cd = 0 then '未登録'
    else mk.kur_name
  end as ind_kur_name,
  om.ind_treatment_cd as ind_treatment_cd, 
  case
    when om.ind_treatment_cd = 0 then '未登録'
    else mt.treatment_name
  end as ind_treatment_name
from
  ord_main om
    left join mst_kur mk
      on (om.ind_kur_cd = mk.kur_cd)
    left join mst_treatment mt
      on (om.ind_treatment_cd = mt.treatment_cd)
where
  om.facility_cd = /*facility_cd*/'000001'
and
  om.pat_id = /*pat_id*/1
/*%if null !=  dialysis_date_from */
and
  om.treat_date >= /*dialysis_date_from*/'20180220'
/*%end*/
/*%if null != dialysis_date_to */
and
  om.treat_date <= /*dialysis_date_to*/'20180226'
/*%end*/
/*%if null != week_pattern && 0 != week_pattern.get(0) */
and
  om.treat_week in /*week_pattern*/(1,2,3)
/*%end */
and
  om.is_del = /*is_del*/'0'
group by
  om.facility_cd, om.pat_id, om.ind_kur_cd, om.ind_treatment_cd, mk.kur_name, mt.treatment_name
;
