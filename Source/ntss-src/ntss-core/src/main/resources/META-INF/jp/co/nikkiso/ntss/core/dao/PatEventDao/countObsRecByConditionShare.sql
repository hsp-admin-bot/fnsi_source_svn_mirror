SELECT COUNT(*)
  FROM (
    SELECT
      A.*
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
      B.*
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
;