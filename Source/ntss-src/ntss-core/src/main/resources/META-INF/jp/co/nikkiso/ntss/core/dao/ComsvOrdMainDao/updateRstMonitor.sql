update
  ord_main
set
/*%if param.rstBloodCirculate != null */
  rst_blood_circulate_total = to_number(/*param.rstBloodCirculate*/'0', '999.99'),
/*%else */
  rst_blood_circulate_total = null,
/*%end */
/*%if param.rstRunningTime != null */
  rst_running_time = to_number(/*param.rstRunningTime*/'0', '9999'),
/*%else */
  rst_running_time = null,
/*%end */
/*%if param.rstKtv != null */
  rst_kt_v = to_number(/*param.rstKtv*/'0', '9.99'),
/*%else */
  rst_kt_v = null,
/*%end */
  rst_weight_info = rst_weight_info ||
  ('{' ||
/*%if param.addTotal != null */
  '"water_removal_rst": ' || to_number(/*param.addTotal*/'0', '99.99') ||
  ',"add_total": ' || to_number(/*param.addTotal*/'0', '99.99') ||
/*%else */
  '"water_removal_rst": null' ||
  ',"add_total": null' ||
/*%end */
/*%if param.addWaterTotal != null */
  ',"add_water_total": ' || to_number(/*param.addWaterTotal*/'0', '99.99') ||
/*%else */
  ',"add_water_total": null' ||
/*%end */
/*%if param.ktvMeasure != null */
  ',"kt_v_measure": ' || to_number(/*param.ktvMeasure*/'0', '9.99') ||
/*%else */
  ',"kt_v_measure": null' ||
/*%end */
/*%if param.ufr != null */
  ',"urr": ' || to_number(/*param.ufr*/'0', '999.9') ||
/*%else */
  ',"urr": null' ||
/*%end */
  '}')::jsonb,
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  ord_no = /*param.ordNo*/1
;
