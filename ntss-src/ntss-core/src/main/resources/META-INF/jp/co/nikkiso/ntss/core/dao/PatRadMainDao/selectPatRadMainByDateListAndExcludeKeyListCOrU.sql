SELECT
    /*%expand "A" */*
FROM
  pat_rad_main A
LEFT JOIN ord_main o ON A.facility_cd = o.facility_cd
AND A.pat_id = o.pat_id
AND TO_CHAR( A.reg_rad_date, 'YYYYMMDD' ) = o.treat_date
AND o.ind_kur_cd != 0
WHERE
  A.facility_cd = /* facilityCd */null
AND
  A.pat_id = /* patId */null
AND
  o.ord_no IS NOT NULL
/*%if excludeRadResultCdList != null && !excludeRadResultCdList.isEmpty() */
AND
  A.rad_result_cd not in  /* excludeRadResultCdList */(-1)
/*%end*/
AND
  A.is_del = '0'
AND not exists (
        select
            1
        from
            pat_rad_main as B
        where
              B.pat_id = A.pat_id
          and B.is_del = '0'
          and B.rad_status = '1'
          and left ( to_char( A.reg_rad_date, 'YYYY-MM-DD' ), 10 ) = left ( to_char( B.reg_rad_date, 'YYYY-MM-DD' ), 10 )
    )
/*%if treatDateList != null && !treatDateList.isEmpty() */
AND
  TO_CHAR(A.reg_rad_date, 'YYYYMMDD') in /* treatDateList */(null)
/*%end*/
;
