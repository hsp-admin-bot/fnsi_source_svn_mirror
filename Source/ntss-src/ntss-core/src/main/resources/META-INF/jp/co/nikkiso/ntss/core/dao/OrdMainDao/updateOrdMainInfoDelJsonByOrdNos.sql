UPDATE ord_main
SET ind_cond_info = (
     SELECT jsonb_object_agg(k, v - 'unit' - 'value_name_1' - 'value_name_2') FROM jsonb_each(ind_cond_info) AS e(k, v))
WHERE ord_no IN /*ordNoList*/(0) AND rst_dialysis_state = '0'
