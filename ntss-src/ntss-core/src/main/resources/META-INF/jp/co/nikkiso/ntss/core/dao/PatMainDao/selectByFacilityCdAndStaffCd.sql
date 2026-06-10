SELECT
/*%expand "A" */*
FROM pat_main A,
     jsonb_array_elements(charge_staff_info) AS staff_info
WHERE
  A.facility_cd = /*facilityCd*/'NKKSBR'
  and A.is_del = '0'
/*%if staffCdList.size() > 0 */
  and (
    /*%for code : staffCdList */
    (staff_info->>'staff_cd')::int = /* code */0
    /*%if code_has_next */
      or
    /*%end */
    /*%end */
    AND staff_info->>'is_main' = '1'
    )
/*%end */
;
