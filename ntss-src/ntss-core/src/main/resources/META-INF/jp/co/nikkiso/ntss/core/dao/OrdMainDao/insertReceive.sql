insert into ord_main
(
/*%if ordMain.ordNo != null */
ord_no,
/*%end*/
pat_id
,fn_pat_id
,treat_date
,treat_week
,facility_cd
,facility_name
,ind_va_cd
,ind_treatment_cd
,ind_treatment_name
,ind_kur_cd
,ind_kur_name
,ind_treat_start_time
,ind_bed_cd
,ind_bed_name
/*%if ordMain.indScheduleUserInfo != null && ordMain.indScheduleUserInfo!="" */
,ind_schedule_user_info
/*%end*/
/*%if ordMain.indCondInfo != null && ordMain.indCondInfo!=""  */
,ind_cond_info
/*%end*/
/*%if ordMain.indMediInfo != null && ordMain.indMediInfo!=""  */
,ind_medi_info
/*%end*/
/*%if ordMain.indEquipInfo != null && ordMain.indEquipInfo!=""  */
,ind_equip_info
/*%end*/
/*%if ordMain.indIndCommentInfo != null && ordMain.indIndCommentInfo!=""  */
,ind_ind_comment_info
/*%end*/
/*%if ordMain.indTareInfo != null && ordMain.indTareInfo!=""  */
,ind_tare_info
/*%end*/
/*%if ordMain.indOffWaterInfo != null && ordMain.indOffWaterInfo!=""  */
,ind_off_water_info
/*%end*/
,ind_device_set_info
,is_del
,up_date
,reg_date
,treat_type
)
values
(
  /*%if ordMain.ordNo != null */
    /*ordMain.ordNo*/'1',
  /*%end*/
  /*ordMain.patId*/'1',
  /*ordMain.fnPatId*/null,
  /*ordMain.treatDate*/null,
  /*ordMain.treatWeek*/null,
  /*ordMain.facilityCd*/null,
  /*ordMain.facilityName*/null,
  /*ordMain.indVaCd*/null,
  /*ordMain.indTreatmentCd*/null,
  /*ordMain.indTreatmentName*/null,
  /*ordMain.indKurCd*/null,
  /*ordMain.indKurName*/null,
  /*ordMain.indTreatStartTime*/null,
  /*ordMain.indBedCd*/null,
  /*ordMain.indBedName*/null,
  /*%if ordMain.indScheduleUserInfo != null && ordMain.indScheduleUserInfo!="" */
    /*ordMain.indScheduleUserInfo*/null,
  /*%end*/
  /*%if ordMain.indCondInfo != null && ordMain.indCondInfo!=""  */
    /*ordMain.indCondInfo*/null,
  /*%end*/
  /*%if ordMain.indMediInfo != null && ordMain.indMediInfo!=""  */
    /*ordMain.indMediInfo*/null,
  /*%end*/
  /*%if ordMain.indEquipInfo != null && ordMain.indEquipInfo!=""  */
    /*ordMain.indEquipInfo*/null,
  /*%end*/
  /*%if ordMain.indIndCommentInfo != null && ordMain.indIndCommentInfo!=""  */
    /*ordMain.indIndCommentInfo*/null,
  /*%end*/
  /*%if ordMain.indTareInfo != null && ordMain.indTareInfo!=""  */
    /*ordMain.indTareInfo*/null,
  /*%end*/
  /*%if ordMain.indOffWaterInfo != null && ordMain.indOffWaterInfo!=""  */
    /*ordMain.indOffWaterInfo*/null,
  /*%end*/
  /*%if ordMain.indDeviceSetInfo != null && ordMain.indDeviceSetInfo != "" */
    /*ordMain.indDeviceSetInfo*/null,
  /*%else*/
    (select
      jsonb_build_object('ufr', (device_set_info->'ord'->'ufr' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('na', (device_set_info->'ord'->'na' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('dc', (device_set_info->'ord'->'dc' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('qbqd', (device_set_info->'ord'->'qbqd' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('ihdf', (device_set_info->'ord'->'ihdf' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('bvufc', (device_set_info->'ord'->'bvufc' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('dia', (device_set_info->'ord'->'dia' || /*ordMain.indDeviceUserInfo*/'{}'))
    from mst_device_set_info_default
    where facility_cd = /*ordMain.facilityCd*/null),
  /*%end*/
  /*ordMain.isDel*/'0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  /*ordMain.treatType*/null
)
;
