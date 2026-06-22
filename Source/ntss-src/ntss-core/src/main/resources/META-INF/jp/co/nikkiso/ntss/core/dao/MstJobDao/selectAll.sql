SELECT /*%expand "job" */*
FROM 
  mst_job job,
  (
    SELECT code, row_number() over() AS index
    FROM mst_selector
    CROSS JOIN lateral jsonb_to_recordset(order_settings->'items') AS ms
    (
      code text,
      name text
    )
    WHERE
      facility_cd = /* facilityCd */'000000'
      AND master_physical_name = 'mst_job'
  ) selector
WHERE 
  facility_cd = /* facilityCd */'000000'
  AND job.job_cd::text = selector.code
  AND is_disp = '1'
  AND is_del = '0'
ORDER BY selector.index;
