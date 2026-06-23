DELETE
FROM "ntss"."mnt_if_edge_healthmon"
WHERE ctl_no >= 0
  AND facility_cd = '999999';