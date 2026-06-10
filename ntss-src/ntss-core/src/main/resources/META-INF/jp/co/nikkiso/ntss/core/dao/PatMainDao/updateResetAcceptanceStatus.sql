update pat_main
  set acceptance_status_info = json_build_object(
        'class',null,
        'start_date_time',null,
        'treatment_time',null
      )::jsonb
    ,up_date = /*upDate*/null
  where
    pat_id = /*patId*/null
;