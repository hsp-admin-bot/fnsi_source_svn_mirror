DELETE FROM ntss.sys_data_set
WHERE sql_cd = -442
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-442, '-- 【SQL_CD=-442】
WITH staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
),
exam_data AS(
  SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    pat_id
  FROM
    ntss.pat_exam_main
  WHERE
    exam_main_cd = @ordNo
),
ord_data AS(
  SELECT
    ord_main.ind_treat_start_time,
    ord_main.ind_cond_info -> ''1'' ->> ''value'' AS ind_dialysis_time
  FROM
    ord_main
  WHERE
    pat_id = (SELECT pat_id FROM exam_data)
  AND treat_date = (SELECT exam_date FROM exam_data)
  AND ord_main.is_del = ''0''
  ORDER BY
    ind_treat_start_time ASC
  LIMIT 1
)
 SELECT
   CASE M1.reg_order_class
   WHEN ''1'' THEN ''0''
   WHEN ''2'' THEN ''1''
   ELSE ''2''
   END reg_order_class,
   TO_CHAR( M1.reg_exam_date, ''YYYYMMDD'' ) AS reg_exam_date,
   M1.ind_user_id,
   M1.reg_staff,
   M1.up_staff,
   TO_CHAR( M1.up_date, ''YYYY/MM/DD HH24:MI:SS'' ) AS up_date,
   -- 診療科マスタ
   pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
   course.course_name AS course_name,
   COALESCE ( TRIM ( course.in_hospital_cd_1 ), CAST ( course.course_cd AS VARCHAR ) ) AS course_cd1,
   -- 透析前/透析後開始時刻
   (SELECT ind_treat_start_time FROM ord_data) || ''00'' AS standard_start_time,
   -- 透析後予定透析時間
   (SELECT ind_dialysis_time FROM ord_data) AS ind_dialysis_time,
   -- その他開始時刻
   mes.other_exam_time AS other_exam_time,
   -- 血液検査セットコード
   info ->> ''set_cd'' AS exam_set_cd,
   -- 医師1
   staff1.staff_cd AS staff_cd1,
   -- 医師2
    staff2.staff_cd AS staff_cd2 
 FROM
   pat_exam_main AS M1
   LEFT JOIN LATERAL json_array_elements ( M1.order_exam_set_info :: json ) info ON info ->> ''set_name'' LIKE''%血液%''
   INNER JOIN pat_main AS pat ON pat.pat_id = M1.pat_id
   LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
   LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
   LEFT JOIN mst_course AS course ON course.course_cd :: TEXT = pat.medical_care_info ->> ''main_course_cd'' 
   LEFT JOIN mst_exam_set AS mes ON mes.exam_set_cd::text = (order_exam_set_info -> 0 ->> ''set_cd'')
 WHERE
   M1.is_del = ''0'' 
   AND M1.exam_status = ''0'' 
   AND M1.exam_main_cd = @ordNo
   LIMIT 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI検査オーダ(連携電文の検査スケジュール)', '2023-09-28 13:12:38.000', CURRENT_TIMESTAMP, NULL);