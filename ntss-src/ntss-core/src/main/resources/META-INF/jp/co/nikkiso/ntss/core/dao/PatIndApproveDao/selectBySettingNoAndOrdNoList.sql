SELECT  /*%expand "pat" */*
FROM pat_ind_approve pat
JOIN ord_main ord ON ord.ord_no = pat.ord_no
JOIN mst_facility_setting setting ON ord.facility_cd = setting.facility_cd
WHERE setting.facility_setting_no = /*settingNo*/''
AND setting.value = /*settingValue*/''
  AND pat.ord_no IN /*ordNos*/(null)
