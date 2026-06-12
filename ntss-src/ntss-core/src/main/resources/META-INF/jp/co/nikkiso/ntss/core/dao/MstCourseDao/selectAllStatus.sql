SELECT
  course_cd AS "courseCd",
  course_name AS "courseName",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel",
  CASE
    WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
    ELSE ''
  END AS "deleted"
FROM mst_course
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND (
    (is_disp <> '0' AND is_del <> '1')
    OR course_cd = /* params.get("initCourseCd") */0
  )
ORDER BY course_cd;

