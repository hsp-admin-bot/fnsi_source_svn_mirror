UPDATE
  sys_coop_journal 
SET
  coop_result = CASE WHEN coop_result = '1' THEN '0' ELSE 'R' END
  , up_date = CURRENT_TIMESTAMP
WHERE 
  facility_cd = /* facilityCd */''
  AND ana_result = '9'
  AND coop_result IN ('1', '8');
