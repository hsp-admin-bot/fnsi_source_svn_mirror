UPDATE ord_main
SET
    rst_weight_info  = COALESCE(rst_weight_info , '[]'::jsonb),
    rst_medi_info  = COALESCE(rst_medi_info , '[]'::jsonb),
    rst_equip_info = COALESCE(rst_equip_info, '[]'::jsonb),
    rst_ind_comment_info = COALESCE(rst_ind_comment_info, '[]'::jsonb)
WHERE rst_dialysis_state != '0' and pat_id is not null
  and (rst_weight_info IS NULL
  OR rst_medi_info IS NULL
  OR rst_equip_info IS NULL
	OR rst_ind_comment_info IS NULL)
