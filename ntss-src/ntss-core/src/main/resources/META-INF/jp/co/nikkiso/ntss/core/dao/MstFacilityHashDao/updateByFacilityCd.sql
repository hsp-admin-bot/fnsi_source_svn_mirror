update
  mst_facility_hash
set
/*%for mstFacilitySetting: mstFacilitySettingList */
 /*%if mstFacilitySetting.facilitySettingNo == "1061" */
  account_lock_setting = /* mstFacilitySetting.value */null,
 /*%elseif mstFacilitySetting.facilitySettingNo == "1062" */
  failure_cnt = /* mstFacilitySetting.value */null,
 /*%elseif mstFacilitySetting.facilitySettingNo == "1063" */
  otp_failure_cnt = /* mstFacilitySetting.value */null,
 /*%elseif mstFacilitySetting.facilitySettingNo == "2001" */
  url_signin = /* mstFacilitySetting.value */null,
 /*%elseif mstFacilitySetting.facilitySettingNo == "2002" */
  url_signin_secretkey = /* mstFacilitySetting.value */null,
 /*%elseif mstFacilitySetting.facilitySettingNo == "3144" */
  is_signin_disp = /* mstFacilitySetting.value */null,
 /*%end */
/*%end*/
  up_date = /* upDate */null
where
  facility_cd = /* facilityCd */null
;
