/* 職種マスタ デフォルト職種の追加 */

/* 職種：医師の追加 */
INSERT INTO mst_job (facility_cd, job_name, is_doctor, default_menu_settings, is_disp, is_del, reg_date, up_date)
SELECT
  A.facility_cd,
  '医師' AS job_name,
  '1' AS is_doctor,
  '{"initial_menu_function": "005", "default_menu_functions": ["005"]}' AS default_menu_settings,
  '1' AS is_disp,
  '0' AS is_del,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM
  mst_facility A
WHERE NOT EXISTS
  (
    SELECT
      facility_cd
    FROM
      mst_job B
    WHERE
      A.facility_cd = B.facility_cd
    AND
      B.job_name = '医師'
  );

/* 職種：看護師の追加 */
INSERT INTO mst_job (facility_cd, job_name, is_doctor, default_menu_settings, is_disp, is_del, reg_date, up_date)
SELECT
  A.facility_cd,
  '看護師' AS job_name,
  '0' AS is_doctor,
  '{"initial_menu_function": "005", "default_menu_functions": ["005"]}' AS default_menu_settings,
  '1' AS is_disp,
  '0' AS is_del,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM
  mst_facility A
WHERE NOT EXISTS
  (
    SELECT
      facility_cd
    FROM
      mst_job B
    WHERE
      A.facility_cd = B.facility_cd
    AND
      B.job_name = '看護師'
  );

/* 職種：臨床工学技士の追加 */
INSERT INTO mst_job (facility_cd, job_name, is_doctor, default_menu_settings, is_disp, is_del, reg_date, up_date)
SELECT
  A.facility_cd,
  '臨床工学技士' AS job_name,
  '0' AS is_doctor,
  '{"initial_menu_function": "005", "default_menu_functions": ["005"]}' AS default_menu_settings,
  '1' AS is_disp,
  '0' AS is_del,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM
  mst_facility A
WHERE NOT EXISTS
  (
    SELECT
      facility_cd
    FROM
      mst_job B
    WHERE
      A.facility_cd = B.facility_cd
    AND
      B.job_name = '臨床工学技士'
  );
