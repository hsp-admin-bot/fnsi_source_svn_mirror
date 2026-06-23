-- 使用可能機能カラムに拡張機能コードがに存在している場合、削除して拡張設定カラムに追加する。
UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A01"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A01"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A01"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A01"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A01"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A01') 
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

UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A02"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A02"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A02"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A02"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A02"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A02') 
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

UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A03"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A03"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A03"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A03"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A03"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A03') 
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

UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A04"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A04"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A04"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A04"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A04"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A04') 
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

UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A05"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A05"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A05"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A05"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A05"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A05') 
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

UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A06"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A06"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A06"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A06"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A06"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A06') 
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

UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A07"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A07"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A07"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A07"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A07"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A07') 
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

UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A08"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A08"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A08"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A08"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A08"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A08') 
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

UPDATE mst_facility
SET advanced_settings =  '{"func_advcds": [{"func_advcd": "A09"}]}', up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A09"}]'::jsonb) AND advanced_settings IS NUll;

UPDATE mst_facility
SET advanced_settings =  jsonb_set(advanced_settings, '{func_advcds}',(advanced_settings -> 'func_advcds')::jsonb || '[{"func_advcd": "A09"}]'::jsonb), up_date = now()
WHERE (use_function->'func_cds' @>'[{"func_cd": "A09"}]'::jsonb) AND not (advanced_settings->'func_advcds' @>'[{"func_advcd": "A09"}]'::jsonb);

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
      CASE WHEN (each_info ->> 'func_cd') NOT IN ('A09') 
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