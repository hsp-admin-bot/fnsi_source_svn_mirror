SELECT
    /*%expand "A" */*
FROM
    mst_comsv_setting A,
    jsonb_array_elements(lcd_npat->'npat_item') AS elem(item)
WHERE
  A.facility_cd = /*facilityCd*/'NKKSBR'
  AND A.is_disp = '1'
  AND A.is_del = '0'
/*%if codeList.size() > 0 */
  and (
    /*%for code : codeList */
    (elem->>'code')::int = /* code */0
    /*%if code_has_next */
      or
    /*%end */
    /*%end */
    )
/*%end */
;
