--在宅機能の無効化
UPDATE
  mst_facility
SET
  use_function = B.use_function,
  up_date = now()
FROM (
  SELECT 
    A.facility_cd,
    json_build_object(
      'func_cds', COALESCE(json_agg(A.each_info) FILTER (WHERE A.each_info IS NOT NULL), '[]')
    ) AS use_function
  FROM (
    SELECT 
      mst_facility.facility_cd,
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('025', '026')
        THEN each_info 
        ELSE NULL 
      END each_info
    FROM
      mst_facility
    CROSS JOIN
      jsonb_array_elements(jsonb_extract_path(mst_facility.use_function ,'func_cds')) each_info
    ) A
  GROUP BY
      A.facility_cd
  ) B
WHERE
  mst_facility.facility_cd = B.facility_cd;

UPDATE
  mst_facility
SET
  advanced_settings = B.advanced_settings,
  up_date = now()
FROM (
  SELECT 
    A.facility_cd,
    json_build_object(
      'func_advcds', COALESCE(json_agg(A.each_info) FILTER (WHERE A.each_info IS NOT NULL), '[]')
    ) AS advanced_settings
  FROM (
    SELECT 
      mst_facility.facility_cd,
      CASE WHEN (each_info ->> 'func_advcd') NOT IN ('A05')
        THEN each_info 
        ELSE NULL 
      END each_info
    FROM
      mst_facility
    CROSS JOIN
      jsonb_array_elements(jsonb_extract_path(mst_facility.advanced_settings ,'func_advcds')) each_info
    ) A
  GROUP BY
      A.facility_cd
  ) B
WHERE
  mst_facility.facility_cd = B.facility_cd;

