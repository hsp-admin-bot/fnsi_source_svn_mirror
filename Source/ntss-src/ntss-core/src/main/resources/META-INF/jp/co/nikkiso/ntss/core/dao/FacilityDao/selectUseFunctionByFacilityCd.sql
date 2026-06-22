SELECT
  jsonb_array_elements((s.use_function->>'func_cds')::JSONB)->>'func_cd' as f
FROM
  mst_facility s
WHERE
  facility_cd=/*facilityCd*/'009999'
;
