select
  /*%expand */*
from
  mst_if_edge_command
where
  is_del = '0'
;
