SELECT
  A.pat_event_cd,
  A.pat_id,
  A.facility_cd,
  A.fn_ctl_no,
  A.event_status,
  A.template_cd,
  A.template_name,
  A.category_cd,
  A.category_name,
  A.ord_no,
  A.input_params,
  substring(to_timestamp(A.event_start_date, 'YYYYMMDD')::text, 1, 10) AS event_start_date,
  substring(to_timestamp(A.event_end_date, 'YYYYMMDD')::text, 1, 10) AS event_end_date,
  CASE
    WHEN A.event_start_time IS NULL THEN NULL
    WHEN
      A.event_start_time IS NOT NULL
    THEN
      CONCAT(substring(A.event_start_time, 1, 2),':', substring(A.event_start_time, 3, 2))
  END as event_start_time,
  CASE
    WHEN A.event_end_time IS NULL THEN NULL
    WHEN
      A.event_end_time IS NOT NULL
    THEN
      CONCAT(substring(A.event_end_time, 1, 2),':', substring(A.event_end_time, 3, 2))
  END AS event_end_time,
  A.sub_category_cd,
  A.sub_category_name,
  A.result_params,
  A.score_total,
  A.reg_staff_info,
  A.up_staff_info,
  A.bbs_ctl_no,
  A.is_newest,
  A.is_del,
  A.reg_date,
  A.up_date,
  A.letter_info,
  A.report_url,
  A.report_date,
  A.use_type
FROM
  pat_event A
WHERE
  pat_id = /*patId*/0
  AND use_type = 2 -- 観察記録
  AND is_newest = '1'
  AND is_del = '0'
  
  /*%if startEventDate != null */
  AND event_start_date >= /*startEventDate*/'00010101'
  /*%end */
  /*%if endEventDate != null */
  AND event_start_date <= /*endEventDate*/'99991231'
  /*%end */
  /*%if !categoryDataList.isEmpty() */
  AND (category_cd,sub_category_cd) IN (
    /*%for condition:categoryDataList */
      (/* condition.getLeft() */NULL, /* condition.getRight() */NULL)
      /*%if condition_has_next */
        ,
      /*%end */
    /*%end */
  )
  /*%end */
  /*%if regStaffCd != null */
  AND reg_staff_info->>'reg_staff_cd' = /* regStaffCd */NULL
  /*%end */
  /*%if upStaffCd != null */
  AND up_staff_info->>'up_staff_cd' = /* upStaffCd */NULL
  /*%end */
  
ORDER BY
  event_start_date DESC,
  pat_event_cd DESC 

/*%if offset != null */
LIMIT 100 
OFFSET /*offset*/0
/*%end */
;