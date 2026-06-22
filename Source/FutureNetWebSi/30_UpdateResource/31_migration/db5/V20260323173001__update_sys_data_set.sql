DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-444, -604169);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-444, '-- 【SQL_CD=-444】
 WITH staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
   )
 SELECT
    -- クールマスタ
    ord.rst_kur_cd AS kur_cd,
    mkr.kur_name AS kur_name,
    COALESCE(TRIM(mkr.in_hospital_cd_1), cast(mkr.kur_cd as VARCHAR)) AS kur_cd1,
    LEFT ( mkr.kur_standard_start_time, 4 ) AS kur_standard_start_time,
    -- ベッドマスタ
    ord.rst_bed_cd AS bed_cd,
    mbd.bed_name AS bed_name,
    COALESCE(TRIM(mbd.in_hospital_cd_1), cast(mbd.bed_cd as VARCHAR)) AS bed_cd1,
    -- 基本情報.診療科コード
    pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
    course.course_name AS course_name,
    COALESCE(TRIM(course.in_hospital_cd_1), cast(course.course_cd as VARCHAR)) AS course_cd1,
    -- 実績：診療科コード
    ord.rst_ward_cd AS rst_ward_cd,
    mwd.in_hospital_cd_1 AS in_hospital_cd_1,
    rst_course.course_name AS rst_course_name,
    COALESCE(TRIM(rst_course.in_hospital_cd_1), cast(rst_course.course_cd as VARCHAR)) AS rst_course_cd1,

    -- 透析導入日
    pat.medical_care_info ->> ''dialysis_start_date'' AS dialysis_start_date,
    -- 透析番号
    ord.rst_fn_dialysis_no,
    -- 版番号
    ord.rst_edition,
    -- 治療開始日時
    to_char(ord.rst_start_date, ''yyyy/mm/dd hh24:mi:ss'') as rst_start_date,
    -- 治療終了日時
    to_char(ord.rst_end_date, ''yyyy/mm/dd hh24:mi:ss'') as rst_end_date,
    -- 透析時間
    ord.rst_running_time,
    -- 最終更新指示者ID
    ord.up_ind_user_id,
    -- 医師1
    staff1.staff_cd AS staff_cd1,
    -- 医師2
    staff2.staff_cd AS staff_cd2,

    -- 透析時間
    FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', ord.rst_end_date) - date_trunc(''minute'', ord.rst_start_date))) / 60) AS dialysis_time
 FROM
    ord_main AS ord
    INNER JOIN pat_main AS pat ON pat.pat_id = ord.pat_id 
    LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
    LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
    LEFT JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
    LEFT JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
    LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = pat.medical_care_info ->> ''main_course_cd''
    LEFT JOIN mst_course AS rst_course ON rst_course.course_cd = ord.rst_ward_cd
    LEFT JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd


  WHERE
    ord.ord_no = @ordNo 
  AND pat.pat_id = @patId ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析実績履歴)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604169, '  -- 【SQL_CD=-604169】
  WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        del_date,
        ord.del_date as up_date,
        ord.rst_kur_cd,
        ord.rst_bed_cd, 
        ord.rst_ward_cd,
        ord.rst_start_date,
        ord.rst_end_date,
        ord.rst_fn_dialysis_no,
        ord.rst_edition,
        ord.rst_running_time,
        ord.up_ind_user_id,
        ord.pat_id 
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        null AS del_date,
        ord.rst_edition_date as up_date,
        ord.rst_kur_cd,
        ord.rst_bed_cd,
        ord.rst_ward_cd,
        ord.rst_start_date,
        ord.rst_end_date,
        ord.rst_fn_dialysis_no,
        ord.rst_edition,
        ord.rst_running_time,
        ord.up_ind_user_id,
        ord.pat_id
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  ),
  staff_info AS (
    SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
      info ->> ''staff_cd'' AS staff_cd 
    FROM
      pat_main AS pat
      LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
    WHERE
      pat.pat_id = @patId 
    )
  SELECT
      -- クールマスタ
      ord.rst_kur_cd AS kur_cd,
      mkr.kur_name AS kur_name,
      COALESCE(TRIM(mkr.in_hospital_cd_1), cast(mkr.kur_cd as VARCHAR)) AS kur_cd1,
      LEFT ( mkr.kur_standard_start_time, 4 ) AS kur_standard_start_time,
      -- ベッドマスタ
      ord.rst_bed_cd AS bed_cd,
      mbd.bed_name AS bed_name,
      COALESCE(TRIM(mbd.in_hospital_cd_1), cast(mbd.bed_cd as VARCHAR)) AS bed_cd1,
      -- 基本情報.診療科コード
      pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
      course.course_name AS course_name,
      COALESCE(TRIM(course.in_hospital_cd_1), cast(course.course_cd as VARCHAR)) AS course_cd1,
      -- 実績：診療科コード
      ord.rst_ward_cd AS rst_ward_cd,
      mwd.in_hospital_cd_1 AS in_hospital_cd_1,
      rst_course.course_name AS rst_course_name,
      COALESCE(TRIM(rst_course.in_hospital_cd_1), cast(rst_course.course_cd as VARCHAR)) AS rst_course_cd1,

      -- 透析導入日
      pat.medical_care_info ->> ''dialysis_start_date'' AS dialysis_start_date,
      -- 透析番号
      ord.rst_fn_dialysis_no,
      -- 版番号
      ord.rst_edition,
      -- 治療開始日時
      to_char(ord.rst_start_date, ''yyyy/mm/dd hh24:mi:ss'') as rst_start_date,
      -- 治療終了日時
      to_char(ord.rst_end_date, ''yyyy/mm/dd hh24:mi:ss'') as rst_end_date,
      -- 透析時間
      ord.rst_running_time,
      -- 最終更新指示者ID
      ord.up_ind_user_id,
      -- 医師1
      staff1.staff_cd AS staff_cd1,
      -- 医師2
      staff2.staff_cd AS staff_cd2,
      
      -- 透析時間
      FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', ord.rst_end_date) - date_trunc(''minute'', ord.rst_start_date))) / 60) AS dialysis_time
  FROM
      ord_main_max AS ord
      INNER JOIN pat_main AS pat ON pat.pat_id = ord.pat_id 
      LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
      LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
      LEFT JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
      LEFT JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
      LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = pat.medical_care_info ->> ''main_course_cd''
      LEFT JOIN mst_course AS rst_course ON rst_course.course_cd = ord.rst_ward_cd
      LEFT JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd
      LEFT JOIN sys_coop_journal AS scj ON  scj.ctl_no = @ctlNo
    WHERE
      pat.pat_id = @patId', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);