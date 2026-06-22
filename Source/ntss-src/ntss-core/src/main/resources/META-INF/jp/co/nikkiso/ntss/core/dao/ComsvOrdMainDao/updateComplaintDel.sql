update
  ord_main
set
  rst_complaint_info = COALESCE((SELECT jsonb_agg(elem)
    FROM jsonb_array_elements(COALESCE(rst_complaint_info, '[]')) AS elem
    WHERE elem ->> 'ctl_no' != CAST(/*ctl_no*/1 as text)), '[]') ||
  ('[{' ||
    '"ctl_no": ' || /*ctl_no*/1 ||
	',"input_class": 0' ||
    ',"row_no": ' || /*row_no*/1 ||
/*%if occurDate != null */
   ',"occur_date": ' || /*occurDate*/'null' ||
/*%else */
   ',"occur_date": null' ||
/*%end */
/*%if param.complaintCd != null */
   ',"comp_cd": ' || /*param.complaintCd*/'null' ||
/*%else */
   ',"comp_cd": null' ||
/*%end */
    ',"checkFlag": 1' ||
/*%if param.complaintName != null */
    ',"complaint": ' || /*param.complaintName*/'null' ||
/*%else */
    ',"complaint": null' ||
/*%end */
  '}]')::jsonb,
  up_date = current_timestamp
where
  ord_no = /*ordNo*/1
;
