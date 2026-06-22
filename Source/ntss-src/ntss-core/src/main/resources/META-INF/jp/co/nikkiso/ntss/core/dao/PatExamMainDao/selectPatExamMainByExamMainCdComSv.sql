select
  exam ->> 'item_cd' as item_cd,
  exam ->> 'result' as result,
  mst.data_type as data_type
from
  pat_exam_main as pat,
  mst_exam_item as mst
cross join lateral
  json_array_elements (pat.exam_result_info :: json)
with ordinality as info(exam, idx)
where
  pat.exam_main_cd = /* examMainCd */-1 and
  pat.is_del = '0' and
  mst.console_class = '1' and
  mst.exam_item_cd = cast(exam ->> 'item_cd' as int)
order by
  info.idx
limit 100
;
