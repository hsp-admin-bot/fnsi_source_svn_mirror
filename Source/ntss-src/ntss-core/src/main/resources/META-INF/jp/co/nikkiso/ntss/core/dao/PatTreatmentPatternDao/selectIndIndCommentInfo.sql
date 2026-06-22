SELECT DISTINCT on (iici->'no')
  pat_id, facility_cd, treat_week, ind_treatment_cd, ind_kur_cd, iici as ind_ind_comment_info
FROM
  pat_treatment_pattern,
  LATERAL jsonb_array_elements(ind_ind_comment_info) AS iici
WHERE
  pat_id = /*patId*/0
/*%if null != facilityCd*/
AND
  facility_cd = /*facilityCd*/'000000'
/*%end*/
/*%if 0 != weeks.get(0)*/
AND
  treat_week in /*weeks*/(0)
/*%end*/
/*%if 0 != treats.size()*/
AND
  ind_treatment_cd in /*treats*/(0)
/*%end*/
/*%if 0 != kurs.size()*/
AND
  ind_kur_cd in /*kurs*/(0)
/*%end*/
AND ind_ind_comment_info is not null
ORDER BY iici->'no'
