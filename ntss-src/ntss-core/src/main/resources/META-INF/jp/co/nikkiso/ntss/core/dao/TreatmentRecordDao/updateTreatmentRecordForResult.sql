update
  ord_main
set
  rst_kur_cd = /*entity.rstKurCd*/1
  , rst_kur_name = /*entity.rstKurName*/''
  , rst_bed_cd = /*entity.rstBedCd*/1
  , rst_bed_name = /*entity.rstBedName*/''
  , rst_start_date = /*entity.rstStartDate*/'2000-01-01 01:00:00'
  , rst_end_date = /*entity.rstEndDate*/'2000-01-01 02:00:00'
  , rst_in_out_class = /*entity.rstInOutClass*/1
  , rst_dialysis_cnt = /*entity.rstDialysisCnt*/0
  , rst_ward_cd = /*entity.rstWardCd*/1
  , rst_ward_name = /*entity.rstWardName*/''
  , rst_course_cd = /*entity.rstCourseCd*/1
  , rst_course_name = /*entity.rstCourseName*/''
  , rst_treatment_cd = /*entity.rstTreatmentCd*/''
  , rst_treatment_name = /*entity.rstTreatmentName*/''
  , rst_purification_cnt = /*entity.rstPurificationCnt*/''
/*%if entity.rstPunctureUserInfo != null*/
  , rst_puncture_user_info = /*entity.rstPunctureUserInfo.getValue()*/null
/*%else*/
  , rst_puncture_user_info = null
/*%end*/
/*%if entity.rstReturnUserInfo != null*/
  , rst_return_user_info = /*entity.rstReturnUserInfo.getValue()*/null
/*%else*/
  , rst_return_user_info = null
/*%end*/
/*%if entity.rstChargeUserInfo != null*/
  , rst_charge_user_info = /*entity.rstChargeUserInfo.getValue()*/null
/*%else*/
  , rst_charge_user_info = null
/*%end*/
  , is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end
  , up_date = /*entity.upDate*/'2000-01-01 00:00:00'
-- del 8277 周安寧 start
--   , up_user_id =/*entity.upUserId*/null
-- del 8277 周安寧 end
-- add by chamaojia 2025-03-03 [11471] add fields that need to be modified --start
/*%if entity.rstDeviceMode != null*/
  , rst_device_mode = /*entity.rstDeviceMode*/null
/*%end*/
-- add by chamaojia 2025-03-03 [11471] add fields that need to be modified --end
where
  ord_no = /*ordNo*/1
  and is_del = '0'
;
