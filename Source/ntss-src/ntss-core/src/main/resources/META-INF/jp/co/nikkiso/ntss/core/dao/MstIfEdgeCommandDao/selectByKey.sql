select
  /*%expand */*
from
  mst_if_edge_command
where
  command_key = /*commandKey*/null
and
  is_del = '0'
;
