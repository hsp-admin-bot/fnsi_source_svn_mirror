UPDATE
  mnt_if_edge_client_connect
SET
  ip_address=/*mntIfEdgeClientConnect.ipAddress*/null,
  up_date=to_timestamp(/* mntIfEdgeClientConnect.upDate */null, 'YYYY-MM-DD HH24:MI:SS')
WHERE
  facility_cd=/*mntIfEdgeClientConnect.facilityCd*/null
  and if_edge_type = /*mntIfEdgeClientConnect.ifEdgeType*/0;
