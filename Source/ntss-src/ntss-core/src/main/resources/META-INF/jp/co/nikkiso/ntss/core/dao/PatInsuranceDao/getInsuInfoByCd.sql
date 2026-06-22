SELECT
  COALESCE ((insu_info::json->>'kki_class')::integer, 0) as kki_class,
  COALESCE ((insu_info::json->>'und_six')::integer, 0) as und_six
FROM
  pat_insurance
WHERE 
    insurance_cd = /*insuranceCd*/NULL
  ;