SELECT
  /*%expand*/*
FROM
  mst_selector
WHERE
  (facility_cd in (SELECT a.facility_cd_src
    FROM pat_name_identification AS a
    WHERE a.approve = '1'
      AND a.receive = '1'
      AND a.is_open = '1'
      AND a.facility_cd_dst = /*facilityCd*/'1') OR facility_cd = /*facilityCd*/'1')
AND
  master_physical_name = /*masterPhysicalName*/'1'
ORDER BY
   CASE WHEN facility_cd = /*facilityCd*/'1' THEN 0
        ELSE 1
   END
;