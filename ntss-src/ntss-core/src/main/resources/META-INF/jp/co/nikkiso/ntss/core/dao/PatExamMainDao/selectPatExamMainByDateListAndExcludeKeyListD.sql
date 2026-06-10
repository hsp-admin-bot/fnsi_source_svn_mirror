SELECT
  /*%expand "A" */*
FROM
  pat_exam_main A
LEFT JOIN ord_main o ON A.facility_cd = o.facility_cd
AND A.pat_id = o.pat_id
AND TO_CHAR( A.reg_exam_date, 'YYYYMMDD' ) = o.treat_date
AND o.ind_kur_cd != 0
WHERE
  A.facility_cd = /* facilityCd */null
AND
  A.pat_id = /* patId */null
AND
  o.ord_no IS NULL
/*%if excludeExamMainCdList != null && !excludeExamMainCdList.isEmpty() */
AND
  A.exam_main_cd not in  /* excludeExamMainCdList */(-1)
/*%end*/
AND
  A.is_del = '0'
and not exists (
  select
    1
  from
    pat_exam_main as B
  where
    B.pat_id = A.pat_id
    and B.is_del = '0'
    and B.exam_result_info IS NOT NULL AND B.exam_result_info != '[]'::jsonb
  and left ( to_char( A.reg_exam_date, 'YYYY-MM-DD' ), 10 ) = left ( to_char( B.result_exam_date, 'YYYY-MM-DD' ), 10 ))
/*%if treatDateList != null && !treatDateList.isEmpty() */
AND
  TO_CHAR(A.reg_exam_date, 'YYYYMMDD') in /* treatDateList */(null)
/*%end*/
;
