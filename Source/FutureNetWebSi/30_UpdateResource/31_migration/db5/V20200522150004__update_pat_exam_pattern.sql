-- pat_exam_pattern.order_label_info から 'label_cnt' キーを削除
update
  pat_exam_pattern
set
  order_label_info = B.order_label_info
from (
  select
    A.exam_pattern_cd,
    json_agg(A.deleted_info) as order_label_info
  from (
    select
      pat_exam_pattern.exam_pattern_cd,
      each_info - 'label_cnt' as deleted_info
    from
      pat_exam_pattern
    cross join
      jsonb_array_elements(pat_exam_pattern.order_label_info) each_info
    ) A
  group by
    A.exam_pattern_cd
  order by
    A.exam_pattern_cd
  ) B
where
  pat_exam_pattern.exam_pattern_cd = B.exam_pattern_cd;
