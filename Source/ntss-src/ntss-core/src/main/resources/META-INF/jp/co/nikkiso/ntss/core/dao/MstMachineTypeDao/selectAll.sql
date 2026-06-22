select
  /*%expand*/*
from
  mst_machine_type
-- add by chamaojia 2023-10-10 [9186] ソートフィールドの追加   --start
order by machine_type_cd
-- add by chamaojia 2023-10-10 [9186] ソートフィールドの追加   --end
;
