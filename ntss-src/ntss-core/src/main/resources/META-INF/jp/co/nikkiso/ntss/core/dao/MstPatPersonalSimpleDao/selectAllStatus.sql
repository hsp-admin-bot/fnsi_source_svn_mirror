SELECT
  pat_id AS "patId",
  hosp_pat_id AS "hospPatId",
  COALESCE(personal_info_decrypt(pat_last_name), '') AS "patLastName",
  COALESCE(personal_info_decrypt(pat_first_name), '') AS "patFirstName",
  (COALESCE(personal_info_decrypt(pat_last_name), '') || COALESCE(personal_info_decrypt(pat_first_name), '')) AS "patName",
  facility_cd AS "facilityCd",
  is_del AS "isDel"
FROM pat_personal_main
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND (
    is_del = '0'
    /*%if params.get("initHospPatId") != null && !params.get("initHospPatId").trim().isEmpty() */
    OR hosp_pat_id = /* params.get("initHospPatId") */''
    /*%end*/
  )
  /*%if params.get("excludePatId") != null && !params.get("excludePatId").trim().isEmpty() */
  AND pat_id <> (/* params.get("excludePatId") */0)::bigint
  /*%end*/
ORDER BY
  COALESCE(personal_info_decrypt(pat_last_name_kana), personal_info_decrypt(pat_last_name)),
  COALESCE(personal_info_decrypt(pat_first_name_kana), personal_info_decrypt(pat_first_name)),
  pat_id;
