DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1202003;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202003, 'SELECT
  ward.in_hospital_cd_1 AS ward_hosp_cd
  , course.in_hospital_cd_1 AS course_hosp_cd
FROM
  pat_main AS main
  LEFT JOIN mst_ward AS ward ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd''
  LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = main.medical_care_info ->> ''dialysis_course_cd''
WHERE
  main.pat_id = @patId
  AND main.facility_cd = @facilityCd
  AND main.is_del = ''0''
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼病棟・透析実施科', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
