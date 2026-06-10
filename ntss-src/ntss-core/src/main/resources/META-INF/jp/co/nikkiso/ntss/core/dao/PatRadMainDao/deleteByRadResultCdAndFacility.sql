--   add FNSI-「幹対応残課題一覧.xlsx」№10対応 田
DELETE
FROM
  pat_rad_main
WHERE
  rad_result_cd = /*patRadMain.radResultCd*/'0'
  AND facility_cd = /*patRadMain.facilityCd*/'0'
;
