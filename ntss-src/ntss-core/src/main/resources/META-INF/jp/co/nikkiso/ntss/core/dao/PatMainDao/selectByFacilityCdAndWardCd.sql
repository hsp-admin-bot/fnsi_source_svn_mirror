SELECT
/*%expand "A" */*
FROM pat_main A
WHERE
  A.facility_cd = /*facilityCd*/'NKKSBR'
  and A.is_del = '0'
/*%if wardCdList.size() > 0 */
  and (
    /*%for code : wardCdList */
    jsonb_extract_path_text(medical_care_info, 'ward_cd')::int = /* code */0
    /*%if code_has_next */
      or
    /*%end */
    /*%end */
    )
/*%end */
;
