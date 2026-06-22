SELECT
 B.facility_setting_no As facility_setting_no,
 A.facility_cd As facility_cd,
 B.setting_name As setting_name,
 (CASE 
  WHEN A.facility_setting_no IS NULL THEN B.default_value
  ELSE A.value
  END) As value,
 B.input_type As input_type,
 B.option_value As option_value,
 B.function_name As function_name,
 B.maker_setting As maker_setting,
 B.description As description,
 B.disp_order As disp_order,
 B.system_use_disp As system_use_disp
FROM ntss.mst_facility_setting A
RIGHT OUTER JOIN ntss.sys_facility_setting B
ON A.facility_setting_no = B.facility_setting_no
AND
  A.facility_cd = /*facilityCd*/'000000'
WHERE
  B.facility_setting_no = /*facilitySettingNo*/'0001'
;
