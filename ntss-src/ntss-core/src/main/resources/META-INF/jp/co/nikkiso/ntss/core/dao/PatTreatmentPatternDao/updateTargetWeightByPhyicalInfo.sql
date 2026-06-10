update
  pat_treatment_pattern ptp
set up_date = current_timestamp ,
    ind_cond_info = jsonb_set(ptp.ind_cond_info, '{"3", "value"}', to_jsonb(/*targetWeight*/''::text))
where pat_id = /*patId*/11782
  and facility_cd = /*facilityCd*/'NKKSBR'
