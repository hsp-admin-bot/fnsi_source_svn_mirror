insert into mnt_if_edge_manage (
  facility_cd,
  response_status,
  edge_result,
  is_del,
  reg_date,
  up_date
) values (
  /*mntIfEdgeManage.facilityCd*/null,
  /*mntIfEdgeManage.responseStatus*/null,
  /*mntIfEdgeManage.edgeResult*/'{}'::JSONB,
  /*mntIfEdgeManage.isDel*/null,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);