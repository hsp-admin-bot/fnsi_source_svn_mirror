UPDATE pat_ind_approve
SET is_content_changed = '1',
  is_content_appd_changed = '1',
  is_content_changed_for_map = '1',
  up_date = /*param.upDate*/null
WHERE ord_no IN (
  SELECT ord.ord_no
  FROM ord_main as ord
  JOIN mst_facility_setting as setting
  ON ord.facility_cd = setting.facility_cd
  WHERE ord.ord_no = /*ord_no*/0
  AND setting.facility_setting_no = '1022'
  AND value = '1'
)
;
