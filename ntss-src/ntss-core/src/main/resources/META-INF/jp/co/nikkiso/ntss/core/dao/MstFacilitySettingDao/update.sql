update mst_facility_setting
set
  value = /* mstFacilitySetting.value  */null,
  up_date = /* mstFacilitySetting.upDate */null
where
  facility_setting_no = /* mstFacilitySetting.facilitySettingNo */null
and
  facility_cd =  /* mstFacilitySetting.facilityCd */null
;