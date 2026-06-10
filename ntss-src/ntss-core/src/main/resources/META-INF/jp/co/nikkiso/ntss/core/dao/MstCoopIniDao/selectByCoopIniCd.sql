SELECT
    A.coop_ini_cd,
    A.facility_cd,
    A.coop_ini_memo,
    A.coop_ini_info,
    A.key_mapping,
    A.is_disp,
    A.is_del,
    A.reg_date,
    A.up_date
FROM
  mst_coop_ini A
WHERE
  A.coop_ini_cd = /* coopIniCd */'999999'
AND
  A.is_disp = '1'
AND
  A.is_del = '0'
