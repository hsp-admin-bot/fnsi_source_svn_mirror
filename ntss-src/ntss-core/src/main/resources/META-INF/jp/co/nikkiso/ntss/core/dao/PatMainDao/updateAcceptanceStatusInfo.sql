update
  pat_main
set
  acceptance_status_info = concat('[',jsonb_set(jsonb_set(jsonb_set((select jsonb_array_elements(acceptance_status_info) from pat_main where
   pat_id = /*patId*/0 limit 1) , '{class}', /*classStatus*/null),
  '{treatment_time}', /*treatmentTime*/null),'{start_date_time}',/*startDateTime*/null),']') ::jsonb,
  up_date = /*upDate*/null
where
  pat_id = /*patId*/0
;
