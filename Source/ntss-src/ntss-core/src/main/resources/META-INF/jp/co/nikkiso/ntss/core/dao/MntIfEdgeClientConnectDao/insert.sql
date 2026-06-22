insert into mnt_if_edge_client_connect (
  facility_cd,
  ip_address,
  up_date,
  reg_date,
  if_edge_type
) values (
  /*mntIfEdgeClientConnect.facilityCd*/null,
  /*mntIfEdgeClientConnect.ipAddress*/null,
  to_timestamp(/* mntIfEdgeClientConnect.regDate */null, 'YYYY-MM-DD HH24:MI:SS'),
  to_timestamp(/* mntIfEdgeClientConnect.upDate */null, 'YYYY-MM-DD HH24:MI:SS'),
  /* mntIfEdgeClientConnect.ifEdgeType */0
);
