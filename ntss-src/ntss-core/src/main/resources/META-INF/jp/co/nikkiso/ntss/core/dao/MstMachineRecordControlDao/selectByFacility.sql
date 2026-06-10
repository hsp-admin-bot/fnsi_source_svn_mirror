SELECT
 null As facility_cd,
 B.machine_record_cd As machine_record_cd,
 (CASE 
  WHEN A.machine_record_message IS NULL THEN B.machine_record_message
  ELSE A.machine_record_message
  END) As machine_record_message,
 (CASE 
  -- WHEN A.disp_flg IS NULL THEN '0'
  WHEN A.disp_flg IS NULL THEN B.disp_flg
  ELSE A.disp_flg
  END) As disp_flg,
  -- (CASE 
  -- WHEN A.machine_flg IS NULL THEN '0'
  -- ELSE A.machine_flg
  -- END) As machine_flg,
  -- (CASE 
  -- WHEN A.alarm_flg IS NULL THEN '0'
  -- ELSE A.alarm_flg
  -- END) As alarm_flg,
	(CASE
  WHEN A.reg_date IS NULL THEN null
  ELSE A.reg_date
  END) As reg_date,
	(CASE
  WHEN A.up_date IS NULL THEN null
  ELSE A.up_date
  END) As up_date
FROM ntss.mst_machine_record_control A
RIGHT OUTER JOIN ntss.mst_machine_record B
ON A.machine_record_cd = B.machine_record_cd
AND 
  A.facility_cd = /* facilityCd */null
WHERE 
/*%if null != machineRecordCd */
  B.machine_record_cd = /* machineRecordCd */null
/*%end */
ORDER BY 
  B.machine_record_cd
;
