SELECT *
FROM pat_rad_pattern
WHERE facility_cd = /* facilityCd */NULL
  AND pat_id = /* patId */NULL
  AND rad_week IN /* radWeekList */(NULL)
  AND is_del = '0';
