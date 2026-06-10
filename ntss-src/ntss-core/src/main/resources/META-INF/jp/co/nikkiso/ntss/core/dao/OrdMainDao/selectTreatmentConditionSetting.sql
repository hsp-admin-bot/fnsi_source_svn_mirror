SELECT
   A.treat_date
  ,A.treat_week
  ,A.ind_kur_cd
  ,B.treatment_cd
  ,B.treatment_condition_setting
FROM
  ord_main A
LEFT JOIN mst_treatment B
ON A.ind_treatment_cd = B.treatment_cd
AND A.facility_cd = B.facility_cd
WHERE
  A.pat_id = /*patId*/0
/*%if null != facilityCd*/
AND
  A.facility_cd = /*facilityCd*/'000000'
/*%end*/
AND
  A.treat_date >= /*treatDateFrom*/'00000000'
/*%if null != treatDateTo*/
AND
  A.treat_date <= /*treatDateTo*/'00000000'
/*%end*/
/*%if 0 != weeks.get(0)*/
AND
  A.treat_week in /*weeks*/(0)
/*%end*/
/*%if 0 != treats.size()*/
AND
  A.ind_treatment_cd in /*treats*/(0)
/*%end*/
/*%if 0 != kurs.size()*/
AND
  A.ind_kur_cd in /*kurs*/(0)
/*%end*/
