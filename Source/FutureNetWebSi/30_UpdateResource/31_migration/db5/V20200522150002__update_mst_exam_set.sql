-- mst_exam_set.label_info から 'label_cnt' キーを削除
update
  mst_exam_set
set
  label_info = B.label_info
from (
  select
    A.exam_set_cd,
    json_agg(A.deleted_info) as label_info
  from (
    select
      mst_exam_set.exam_set_cd,
      each_info - 'label_cnt' as deleted_info
    from
      mst_exam_set
    cross join
      jsonb_array_elements(mst_exam_set.label_info) each_info
    ) A
  group by
    A.exam_set_cd
  order by
    A.exam_set_cd
  ) B
where
  mst_exam_set.exam_set_cd = B.exam_set_cd;