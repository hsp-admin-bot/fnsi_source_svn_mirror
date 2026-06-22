update
  ord_main
set
  rst_treat_staff_info = COALESCE((SELECT jsonb_agg(elem)
    FROM jsonb_array_elements(COALESCE(rst_treat_staff_info, '[]')) AS elem
    WHERE elem ->> 'ctl_no' != CAST(/*ctl_no*/1 as text)), '[]'),
  up_date = current_timestamp
where
  ord_no = /*ordNo*/1
;
