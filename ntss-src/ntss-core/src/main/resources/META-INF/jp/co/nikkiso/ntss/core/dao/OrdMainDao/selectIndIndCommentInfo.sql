SELECT DISTINCT on (iici->'no')
  pat_id, facility_cd, facility_name, treat_date, treat_week, ind_treatment_cd, ind_treatment_name,
  ind_kur_cd, ind_kur_name, iici as ind_ind_comment_info
FROM
  ord_main,
  LATERAL jsonb_array_elements(ind_ind_comment_info) AS iici
WHERE
  is_del = '0'
/*%if null != patId*/
AND
  pat_id = /*patId*/0
/*%end*/
/*%if null != facilityCd*/
AND
  facility_cd = /*facilityCd*/'000000'
/*%end*/
AND
  treat_date >= /*treatDateFrom*/'00000000'
/*%if null != treatDateTo*/
AND
  treat_date <= /*treatDateTo*/'00000000'
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
