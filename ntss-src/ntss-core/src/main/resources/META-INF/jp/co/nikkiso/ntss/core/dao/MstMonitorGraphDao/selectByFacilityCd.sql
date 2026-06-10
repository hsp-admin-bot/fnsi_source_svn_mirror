SELECT
  /*%expand*/*
FROM
  mst_monitor_graph
WHERE
  facility_cd = /*facilityCd*/'1' and
  is_del = '0'
ORDER BY
  monitor_graph_cd
;
