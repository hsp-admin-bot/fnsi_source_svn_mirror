UPDATE ord_main
SET
    ind_medi_info = COALESCE(ind_medi_info, '[]'::jsonb),
    ind_equip_info = COALESCE(ind_equip_info, '[]'::jsonb),
    ind_ind_comment_info = COALESCE(ind_ind_comment_info, '[]'::jsonb)
WHERE ind_cond_info is not null and pat_id is not null and (ind_medi_info IS NULL
    OR ind_equip_info IS NULL
    OR ind_ind_comment_info IS NULL)
