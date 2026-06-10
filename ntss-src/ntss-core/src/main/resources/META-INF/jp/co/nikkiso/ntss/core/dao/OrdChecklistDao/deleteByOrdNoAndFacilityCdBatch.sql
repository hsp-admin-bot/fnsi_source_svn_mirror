DELETE
FROM
    ord_checklist
WHERE
    -- EXISTS ( SELECT 1 FROM ord_main A WHERE A.ord_no IN /*delOrdNoList*/(1) AND ord_checklist.facility_cd = A.facility_cd )
    facility_cd = /*facilityCd*/null
  AND ord_no IN /*delOrdNoList*/(null)


