SELECT * 
  FROM (SELECT
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
      A.pat_id = /*patId*/0
      AND A.use_type = 2 -- 観察記録
      AND A.is_newest = '1'
      AND A.is_del = '0'
      
      /*%if startEventDate != null */
      AND A.event_start_date >= /*startEventDate*/'00010101'
      /*%end */
      /*%if endEventDate != null */
      AND A.event_start_date <= /*endEventDate*/'99991231'
      /*%end */
      /*%if !categoryDataList.isEmpty() */
      AND (A.category_cd,A.sub_category_cd) IN (
        /*%for condition:categoryDataList */
          (/* condition.getLeft() */NULL, /* condition.getRight() */NULL)
          /*%if condition_has_next */
            ,
          /*%end */
        /*%end */
      )
      /*%end */
      /*%if regStaffCd != null */
      AND A.reg_staff_info->>'reg_staff_cd' = /* regStaffCd */NULL
      /*%end */
      /*%if upStaffCd != null */
      AND A.up_staff_info->>'up_staff_cd' = /* upStaffCd */NULL
      /*%end */
  UNION ALL
    SELECT
      B.pat_event_cd,
      B.pat_id,
      B.facility_cd,
      B.fn_ctl_no,
      B.event_status,
      B.template_cd,
      B.template_name,
      B.category_cd,
      B.category_name,
      B.ord_no,
      B.input_params,
      substring(to_timestamp(B.event_start_date, 'YYYYMMDD')::text, 1, 10) AS event_start_date,
      substring(to_timestamp(B.event_end_date, 'YYYYMMDD')::text, 1, 10) AS event_end_date,
      CASE
        WHEN B.event_start_time IS NULL THEN NULL
        WHEN
          B.event_start_time IS NOT NULL
        THEN
          CONCAT(substring(B.event_start_time, 1, 2),':', substring(B.event_start_time, 3, 2))
      END as event_start_time,
      CASE
        WHEN B.event_end_time IS NULL THEN NULL
        WHEN
          B.event_end_time IS NOT NULL
        THEN
          CONCAT(substring(B.event_end_time, 1, 2),':', substring(B.event_end_time, 3, 2))
      END AS event_end_time,
      B.sub_category_cd,
      B.sub_category_name,
      B.result_params,
      B.score_total,
      B.reg_staff_info,
      B.up_staff_info,
      B.bbs_ctl_no,
      B.is_newest,
      B.is_del,
      B.reg_date,
      B.up_date,
      B.letter_info,
      B.report_url,
      B.report_date,
      B.use_type
    FROM
      pat_event B
    WHERE
        1 = 1
        /*%if !patEventList.isEmpty() */
        AND (B.facility_cd,B.pat_id) IN (
          /*%for condition:patEventList */
            (/* condition.facilityCd */NULL, /* condition.patId */NULL)
            /*%if condition_has_next */
              ,
            /*%end */
          /*%end */
        )
        /*%end */
      AND B.use_type = 2 -- 観察記録
      AND B.is_newest = '1'
      AND B.is_del = '0'
      
      /*%if startEventDate != null */
      AND B.event_start_date >= /*startEventDate*/'00010101'
      /*%end */
      /*%if endEventDate != null */
      AND B.event_start_date <= /*endEventDate*/'99991231'
      /*%end */
      /*%if !categoryDataList.isEmpty() */
      AND (B.category_cd,B.sub_category_cd) IN (
        /*%for condition:categoryDataList */
          (/* condition.getLeft() */NULL, /* condition.getRight() */NULL)
          /*%if condition_has_next */
            ,
          /*%end */
        /*%end */
      )
      /*%end */
      /*%if regStaffCd != null */
      AND B.reg_staff_info->>'reg_staff_cd' = /* regStaffCd */NULL
      /*%end */
      /*%if upStaffCd != null */
      AND B.up_staff_info->>'up_staff_cd' = /* upStaffCd */NULL
      /*%end */
  ) AS combined
ORDER BY
  event_start_date DESC,
  pat_event_cd DESC 

/*%if offset != null */
LIMIT 100 
OFFSET /*offset*/0
/*%end */
;