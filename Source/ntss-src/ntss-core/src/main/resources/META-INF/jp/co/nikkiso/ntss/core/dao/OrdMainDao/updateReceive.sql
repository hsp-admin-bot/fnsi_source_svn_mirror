UPDATE
  ord_main
SET
 pat_id = /*ordMain.patId*/null
 ,fn_pat_id = /*ordMain.fnPatId*/null
 ,treat_date = /*ordMain.treatDate*/null
 ,treat_week = /*ordMain.treatWeek*/null
 ,facility_cd = /*ordMain.facilityCd*/null
 ,facility_name = /*ordMain.facilityName*/null
 ,ind_va_cd = /*ordMain.indVaCd*/null
 ,ind_treatment_cd = /*ordMain.indTreatmentCd*/null
 ,ind_treatment_name = /*ordMain.indTreatmentName*/null
 ,ind_kur_cd = /*ordMain.indKurCd*/null
 ,ind_kur_name = /*ordMain.indKurName*/null
 ,ind_treat_start_time = /*ordMain.indTreatStartTime*/null
 ,ind_bed_cd = /*ordMain.indBedCd*/null
 ,ind_bed_name = /*ordMain.indBedName*/null
 /*%if ordMain.indScheduleUserInfo != null && ordMain.indScheduleUserInfo!="" */
   ,ind_schedule_user_info = jsonb_merge_recursive(ind_schedule_user_info::jsonb, /*ordMain.indScheduleUserInfo*/'{}'::jsonb)
 /*%else*/
   ,ind_schedule_user_info = '{}'::jsonb
 /*%end*/
 /*%if ordMain.indCondInfo != null && ordMain.indCondInfo!=""  */
   ,ind_cond_info = jsonb_merge_recursive(ind_cond_info::jsonb, /*ordMain.indCondInfo*/'{}'::jsonb)
 /*%else*/
   ,ind_cond_info = '{}'::jsonb
 /*%end*/
  /*%if ordMain.indMediInfo != null && ordMain.indMediInfo!=""  */
   ,ind_medi_info = jsonb_merge_recursive(ind_medi_info::jsonb, /*ordMain.indMediInfo*/'{}'::jsonb)
 /*%else*/
   ,ind_medi_info = '{}'::jsonb
 /*%end*/
  /*%if ordMain.indEquipInfo != null && ordMain.indEquipInfo!=""  */
   ,ind_equip_info = jsonb_merge_recursive(ind_equip_info::jsonb, /*ordMain.indEquipInfo*/'{}'::jsonb)
 /*%else*/
   ,ind_equip_info = '{}'::jsonb
 /*%end*/
 /*%if ordMain.indIndCommentInfo != null && ordMain.indIndCommentInfo!=""  */
   ,ind_ind_comment_info = jsonb_merge_recursive(ind_ind_comment_info::jsonb, /*ordMain.indIndCommentInfo*/'{}'::jsonb)
 /*%else*/
   ,ind_ind_comment_info = '{}'::jsonb
 /*%end*/
 /*%if ordMain.indTareInfo != null && ordMain.indTareInfo!=""  */
   ,ind_tare_info = jsonb_merge_recursive(ind_tare_info::jsonb, /*ordMain.indTareInfo*/'{}'::jsonb)
 /*%else*/
   ,ind_tare_info = '{}'::jsonb
 /*%end*/
 /*%if ordMain.indOffWaterInfo != null && ordMain.indOffWaterInfo!=""  */
   ,ind_off_water_info = jsonb_merge_recursive(ind_off_water_info::jsonb, /*ordMain.indOffWaterInfo*/'{}'::jsonb)
 /*%else*/
   ,ind_off_water_info = '{}'::jsonb
 /*%end*/
 /*%if ordMain.indDeviceSetInfo != null && ordMain.indDeviceSetInfo != "" */
   ,ind_device_set_info = jsonb_merge_recursive(ind_device_set_info::jsonb, /*ordMain.indDeviceSetInfo*/'{}'::jsonb)
 /*%else*/
   ,ind_device_set_info = '{}'::jsonb
 /*%end*/
 ,is_del = /*ordMain.isDel*/'0'
 ,up_date = CURRENT_TIMESTAMP
 ,treat_type = /*ordMain.treatType*/null
WHERE
  ord_no = /*ordMain.ordNo*/0