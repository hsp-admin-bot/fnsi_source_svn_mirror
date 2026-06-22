update pat_main
set
  medical_care_info = medical_care_info || ('{"dialysis_count": ' || ((medical_care_info->>'dialysis_count')::int + 1) || '}')::jsonb,
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  pat_id = /*param.patId*/1
;
