update mst_report
SET report_path = jsonb_set(report_path, '{bucket}', /*bucket*/null::text)
where
  facility_cd = /*facilityCd*/null
;
