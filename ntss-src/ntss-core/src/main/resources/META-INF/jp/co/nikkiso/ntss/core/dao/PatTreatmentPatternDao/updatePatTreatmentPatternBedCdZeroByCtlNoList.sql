UPDATE pat_treatment_pattern
SET
  ind_sch_info = jsonb_set(ind_sch_info, '{ind_bed_cd}', '0'::jsonb),
  up_date = transaction_timestamp()
WHERE
  facility_cd = /*facilityCd*/NULL
  AND pat_id = /*patId*/NULL
  AND ctl_no in /*ctlNoList*/(null)
