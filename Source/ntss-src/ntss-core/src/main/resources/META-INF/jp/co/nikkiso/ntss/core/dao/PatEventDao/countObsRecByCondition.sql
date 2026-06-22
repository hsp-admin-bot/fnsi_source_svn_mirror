SELECT
  COUNT(*)
FROM
  pat_event
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
;