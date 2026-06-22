select
  ifeh.ctl_no,
  ifeh.facility_cd,
  -- modify by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --start
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
--   ifeh.coop_version,
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  -- modify by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --end
  ifeh.if_edge_no,
  ifeh.healthmon_facility_conn,
  ifeh.healthmon_server_conn,
  ifeh.reg_date,
  ifeh.up_date
from
  mnt_if_edge_healthmon ifeh, mst_if_edge ife
where
  ifeh.facility_cd = /* facilityCd */null
  -- modify by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --start
-- -- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
-- /*%if coopVersion != null */
--   and ifeh.coop_version = /* coopVersion */''
-- /*%end*/
-- -- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  -- modify by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --end
  and ifeh.if_edge_no = /* ifEdgeNo */null
  and ifeh.facility_cd = ife.facility_cd
  and ifeh.if_edge_no = ife.if_edge_no
  and ife.is_del = '0'
;
