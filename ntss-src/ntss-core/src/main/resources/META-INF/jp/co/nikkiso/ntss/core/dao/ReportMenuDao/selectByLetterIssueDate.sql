SELECT DISTINCT
  pe.pat_id
FROM pat_event pe

/*%if ""!= rstDialysisStateFlag && rstDialysisStateFlag == "1" */
INNER JOIN ord_main om ON
  om.pat_id = pe.pat_id
  AND om.facility_cd = /* facilityCd */''
  AND om.treat_date between /* fromDate */'' and /* toDate */''
  AND om.rst_dialysis_state > '0'
  AND om.is_del = '0'
/*%end */

/*%if ""!= rstDialysisStateFlag && rstDialysisStateFlag == "2" */
INNER JOIN ord_main om ON
  om.pat_id = pe.pat_id
  AND om.facility_cd = /* facilityCd */''
  AND om.treat_date between /* fromDate */'' and /* toDate */''
  AND om.rst_dialysis_state >= '0'
  AND om.is_del = '0'
/*%end */

WHERE pe.pat_id IN /* patIds */(null)
  AND pe.facility_cd = /* facilityCd */''
  AND pe.use_type = 3 -- 紹介状
  AND pe.is_del = '0'
  /*%if fromDate != null*/
  AND pe.event_start_date BETWEEN /* fromDate */'' AND /* toDate */''
  /*%end*/
  AND pe.letter_info->>'letter_category' IN /* letterCategoryList */(null)
;