update
  ord_main
set
  rst_treatment_info = COALESCE(rst_treatment_info, '[]') ||
  ('[{' ||
--     '"ctl_no": ' || (COALESCE(jsonb_array_length(rst_treatment_info), 0) + 1) ||
--     ',"row_no": ' || (COALESCE(jsonb_array_length(rst_treatment_info), 0) + 1) ||
    '"ctl_no": ' || /*ctl_no*/1 ||
    ',"row_no": ' || /*row_no*/1 ||
/*%if occurDate != null */
   ',"occur_date": ' || /*occurDate*/'null' ||
/*%else */
   ',"occur_date": null' ||
    /*%end */
/*%if param.treatClass != null */
    ',"treat_class": ' || /*param.treatClass*/'null' ||
/*%else */
    ',"treat_class": null' ||
/*%end */
/*%if param.compTreatmentCd　!= null*/
    ',"treat_cd": ' || /*param.compTreatmentCd*/'null' ||
/*%else */
   ',"treat_cd": null' ||
/*%end */
/*%if param.treatment != null */
    ',"treat_name": ' || /*param.treatment*/'null' ||
/*%else */
    ',"treat_name": null' ||
/*%end */
    ',"medicine_cd": null' ||
    ',"medicine_name": null' ||
/*%if param.amount != null */
    ',"amount": ' || /*param.amount*/'null' ||
/*%else */
    ',"amount": null' ||
/*%end */
/*%if param2.unit != null */
    ',"unit": ' || /*param2.unit*/'null' ||
/*%elseif param3.unit != null */
    ',"unit": ' || /*param3.unit*/'null' ||
/*%else */
    ',"unit": null' ||
/*%end */
/*%if param.procedureCd != null */
    ',"procedure_cd": ' || /*param.procedureCd*/'null' ||
/*%else */
    ',"procedure_cd": null' ||
/*%end */
/*%if procedureName != null */
    ',"procedure_name": ' || /*procedureName*/'null' ||
/*%else */
    ',"procedure_name": null' ||
/*%end */
-- mod 10270 仮想端末追加処置時medicine _ type処理 関  start
-- /*%if param.treatMedicineCd != null */
--     ',"treat_medicine_cd": ' || /*param.treatMedicineCd*/'null' ||
-- /*%else */
--     ',"treat_medicine_cd": null' ||
-- /*%end */
/*%if param.treatMedicineCd != null && param.treatClass == 0*/
    ',"treat_medicine_cd": ' || /*param.treatMedicineCd*/'null' ||
    ',"medicine_type": ' || 2 ||
/*%elseif param.treatMedicineCd != null && param.treatClass == 1*/
    ',"treat_medicine_cd": ' || /*param.treatMedicineCd*/'null' ||
    ',"medicine_type": ' || 1 ||
/*%else */
    ',"treat_medicine_cd": null' ||
    ',"medicine_type": null' ||
/*%end */
-- mod 10270 仮想端末追加処置時medicine _ type処理 関  end
/*%if param2.medicineName != null */
    ',"treat_medicine_name":' || /*param2.medicineName*/'null' ||
/*%elseif param3.medicineMixName != null */
    ',"treat_medicine_name":' || /*param3.medicineMixName*/'null' ||
/*%else */
    ',"treat_medicine_name": null' ||
/*%end */
    ',"oxygen_start": null' ||
    ',"oxygen_time": null' ||
    ',"oxygen_amount": null' ||
    ',"oxygen_speed": null' ||
    ',"input_class": 0' ||
    ',"cop_order_no": null' ||
	',"is_editable": "1"' ||
	',"electrocardiogram_type": null' ||
	',"checkFlag": 1' ||
    ',"over_time": null' ||
	',"electrocardiogram_start": null' ||
	',"linkStartDate": null' ||
-- 	del 10270 仮想端末追加処置時medicine _ type処理 関  start
-- 	',"medicine_type": null' ||
-- 	del 10270 仮想端末追加処置時medicine _ type処理 関  end
  '}]')::jsonb,
  up_date = current_timestamp
where
  ord_no = /*ordNo*/1
;
