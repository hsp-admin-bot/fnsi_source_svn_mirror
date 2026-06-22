SELECT
    om.ord_no
FROM
    ord_main om
WHERE
        om.facility_cd = /*facilityCd*/'000000'
  AND om.rst_dialysis_state = '0'
  AND EXISTS ( SELECT 1 FROM ord_checklist WHERE ord_no = om.ord_no )
;
