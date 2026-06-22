SELECT count(1)
FROM pat_exam_main
WHERE facility_cd = /* facility_cd */null
  AND pat_id = /* pat_id */null
  AND is_order = '1'
  AND is_del = '0'
  AND exam_status = '0'
  AND result_exam_date IS NULL
  AND (
    /*%for moveOutDate : moveOutDateMapList*/
        (
                reg_exam_date >= /*moveOutDate.get("ind_start_date")*/null
                AND
                reg_exam_date <= /*moveOutDate.get("ind_end_date")*/null)
        /*%if moveOutDate_has_next */
        OR
    /*%end*/
    /*%end*/
    )
;
