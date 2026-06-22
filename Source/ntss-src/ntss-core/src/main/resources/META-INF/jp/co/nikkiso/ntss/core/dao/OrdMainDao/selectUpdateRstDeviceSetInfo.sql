SELECT
  ord_no
FROM
  ord_main
WHERE
/*%if null != ordNo*/
  ord_no = /*ordNo*/0
/*%else*/
  pat_id = /*patId*/0
AND
  facility_cd = /*facilityCd*/'000000'
  /*%if null != startDate*/
AND
  treat_date >= /*startDate*/'20180401'
  /*%end*/ 
  /*%if null != endDate*/
AND
  treat_date <= /*endDate*/'20180431'
  /*%end*/
  /*%if 0 != week.size()*/
AND
  treat_week in /*week*/(0)
  /*%end*/
  /*%if 0 != treatMethod.size()*/
AND
  ind_treatment_cd in /*treatMethod*/()
  /*%end*/
  /*%if 0 != kurCd.size()*/
AND
  ind_kur_cd in /*kurCd*/(0)
  /*%end*/
/*%end*/