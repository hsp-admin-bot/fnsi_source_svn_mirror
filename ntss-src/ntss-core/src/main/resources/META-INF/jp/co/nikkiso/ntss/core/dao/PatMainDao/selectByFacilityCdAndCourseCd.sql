SELECT
/*%expand "A" */*
FROM pat_main A
WHERE
  A.facility_cd = /*facilityCd*/'NKKSBR'
  and A.is_del = '0'
/*%if courseCdList.size() > 0 */
  and (
    /*%for code : courseCdList */
    jsonb_extract_path_text(medical_care_info, 'main_course_cd')::int = /* code */0
    /*%if code_has_next */
      or
    /*%end */
    /*%end */
    )
/*%end */
;
