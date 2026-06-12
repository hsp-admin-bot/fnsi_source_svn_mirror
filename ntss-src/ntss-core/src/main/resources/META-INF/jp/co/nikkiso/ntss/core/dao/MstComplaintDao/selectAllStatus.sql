SELECT
  complaint_cd AS "complaintCd",
  complaint_name AS "complaintName",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel"
FROM mst_complaint
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND is_del = '0'
ORDER BY complaint_cd;
