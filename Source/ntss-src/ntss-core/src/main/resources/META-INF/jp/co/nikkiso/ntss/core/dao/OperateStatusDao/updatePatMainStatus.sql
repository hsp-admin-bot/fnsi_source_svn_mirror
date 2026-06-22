update pat_main
  set acceptance_status_info = 
  /*%if clearStatusFlag */
      acceptance_status_info::jsonb || json_build_object(
        'class',null,
        'start_date_time',null,
        'treatment_time',null
      )::jsonb
  /*%else*/
    acceptance_status_info::jsonb || json_build_object(
      'class', query.status
      /*%if updateValueFlag */
      ,
        'start_date_time',to_json(query.start_date_time),
        'treatment_time',query.treat_time
      /*%end*/
    )::jsonb
  /*%end*/
    ,up_date = current_timestamp
  from
	  (
			select 
			  rst_start_date as start_date_time,
			  (ind_cond_info->'1')::jsonb->'value' as treat_time,
			  pat_id,
			  /*%if "1" == status || "2" == status */
			  case when rst_dialysis_state in ('0', '1') then /*status*/'' else rst_dialysis_state end as status
			  /*%else */
			  cast(/*status*/'' as char) as status
			  /*%end*/
			from
			  ord_main
			where
			  ord_no = /*ord_no*/0
	  )	query
  where
    pat_main.pat_id = query.pat_id
