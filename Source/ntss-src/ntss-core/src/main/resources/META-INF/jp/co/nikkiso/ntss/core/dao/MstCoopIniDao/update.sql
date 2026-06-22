UPDATE
  mst_coop_ini A
SET
  facility_cd = /*mci.facilityCd*/null,
  coop_ini_memo = /*mci.coopIniMemo*/null,
  coop_ini_info = /*mci.coopIniInfo*/null,
  key_mapping = /*mci.keyMapping*/null,
  is_disp = /*mci.isDisp*/null,
  is_del = /*mci.isDel*/null,
  up_date = to_timestamp(/*mci.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
WHERE
  A.coop_ini_cd = /*mci.coopIniCd */'999999'
