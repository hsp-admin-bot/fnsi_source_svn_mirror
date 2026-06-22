select
  exam_set_cd as unique_serial,
  exam_item_info as json_value
from
  mst_exam_set
where
  facility_cd = /* facilityCd */null
and
  exam_set_cd in /* examSetCdList */(0)
