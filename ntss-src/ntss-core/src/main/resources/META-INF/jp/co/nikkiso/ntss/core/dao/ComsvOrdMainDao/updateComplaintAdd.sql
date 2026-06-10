update
  ord_main
set
  rst_complaint_info = COALESCE(rst_complaint_info, '[]') ||
  ('[{' ||
--     '"ctl_no": ' || (COALESCE(jsonb_array_length(rst_complaint_info), 0) + 1) ||
    '"ctl_no": ' || /*ctl_no*/1 ||
	',"input_class": 0' ||
--     ',"row_no": ' || (COALESCE(jsonb_array_length(rst_complaint_info), 0) + 1) ||
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
