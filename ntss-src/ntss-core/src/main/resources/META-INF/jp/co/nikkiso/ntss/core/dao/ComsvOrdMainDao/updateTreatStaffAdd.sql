update
  ord_main
set
  rst_treat_staff_info = COALESCE((SELECT jsonb_agg(elem)
    FROM jsonb_array_elements(COALESCE(rst_treat_staff_info, '[]')) AS elem
    WHERE elem ->> 'ctl_no' != CAST(/*ctl_no*/1 as text)), '[]') ||
    ('[{' ||
--     '"ctl_no": ' || (COALESCE(jsonb_array_length(rst_treat_staff_info), 0) + 1) ||
--     ',"row_no": ' || (COALESCE(jsonb_array_length(rst_treat_staff_info), 0) + 1) ||
    '"ctl_no": ' || /*ctl_no*/1 ||
    ',"row_no": ' || /*row_no*/1 ||
    ',"input_class": 0' ||
    ',"occur_date": ' || /*occurDate*/'null' ||
    ',"treat_staff_cd": ' || /*staffCd*/'null' ||
    ',"treat_staff_name": ' || /*staffName*/'null' || -- 名称
    ',"cop_order_no": null' ||
    ',"checkFlag": 1' ||
	',"is_editable": "1"' ||
  '}]')::jsonb,
  up_date = current_timestamp
where
  ord_no = /*ordNo*/1
;
