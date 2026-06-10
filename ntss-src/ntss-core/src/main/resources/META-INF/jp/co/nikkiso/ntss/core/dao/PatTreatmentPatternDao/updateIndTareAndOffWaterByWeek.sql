UPDATE
  pat_treatment_pattern
SET
/*%if null != ind_tare_info*/
  ind_tare_info = /*ind_tare_info*/'{}'::jsonb,
/*%end*/
/*%if null != ind_off_water_info*/
  ind_off_water_info = /*ind_off_water_info*/'{}'::jsonb,
/*%end*/
  up_date = current_timestamp
WHERE
  pat_id = /*pat_id*/0
AND
  facility_cd = /*facility_cd*/null
AND
  treat_week = /*treat_week*/0
