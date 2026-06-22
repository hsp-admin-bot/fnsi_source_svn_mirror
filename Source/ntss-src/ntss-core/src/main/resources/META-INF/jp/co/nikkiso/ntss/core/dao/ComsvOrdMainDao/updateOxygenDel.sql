update
  ord_main
set
  rst_treatment_info = COALESCE((SELECT jsonb_agg(elem)
    FROM jsonb_array_elements(COALESCE(rst_treatment_info, '[]')) AS elem
    WHERE elem ->> 'ctl_no' != CAST(/*ctl_no*/1 as text)), '[]') ||
  ('[{' ||
    '"ctl_no": ' || /*ctl_no*/'1' ||
    ',"row_no": ' || /*row_no*/'1' ||
    ',"occur_date": ' || /*occurDate*/'null' ||
    ',"treat_class": 3' ||
    ',"treat_cd": null' ||
    ',"treat_name": null' ||
    ',"medicine_cd": null' ||
    ',"medicine_name": null' ||
    ',"amount": null' ||
    ',"unit": null' ||
    ',"procedure_cd": null' ||
    ',"procedure_name": null' ||
    ',"treat_medicine_cd": null' ||
    ',"treat_medicine_name": null' ||
    ',"oxygen_start": ' || /*oxygenStart*/'null' ||
    ',"oxygen_time": null' ||
    ',"oxygen_amount": ' || /*oxygenAmount*/'null' ||
    ',"oxygen_speed": null' ||
    ',"input_class": 0' ||
    ',"cop_order_no": null' ||
	',"is_editable": "1"' ||
	',"electrocardiogram_type": null' ||
	',"checkFlag": 1' ||
    ',"over_time": null' ||
	',"electrocardiogram_start": null' ||
	',"linkStartDate": ' || /*linkStartDate*/'null' ||
	',"medicine_type": null' ||
  '}]')::jsonb,
  up_date = current_timestamp
where
  ord_no = /*ordNo*/1
;
