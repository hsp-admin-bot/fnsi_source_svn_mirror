--  add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　start
SELECT
  A.machine_no,
  B.machine_name,
  A.survey_type_cd,
  C.survey_type_name,
  A.survey_point_cd,
  A.point_name
FROM
  mst_water_survey_point AS A
    LEFT JOIN mst_machine AS B
              ON A.machine_no = B.machine_no
                AND B.facility_cd = /*facilityCd*/''
    LEFT JOIN mst_water_survey_type AS C
              ON A.survey_type_cd = C.survey_type_cd
                AND C.facility_cd = /*facilityCd*/''
WHERE
    A.is_disp = '1'
  AND A.is_del = '0'
  AND A.facility_cd = /*facilityCd*/''
/*%if machineTypeCd != null && machineTypeCd != "0" */
  AND B.machine_type_cd = /*machineTypeCd*/''
/*%end */;
--  add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　end
