update
  mnt_if_edge_manage
set
  response_status = /*mntIfEdgeManage.responseStatus*/null,
  edge_result = /*mntIfEdgeManage.edgeResult*/'{}'::JSONB,
  up_date = CURRENT_TIMESTAMP
where
  ctl_no = /*mntIfEdgeManage.ctlNo*/null;