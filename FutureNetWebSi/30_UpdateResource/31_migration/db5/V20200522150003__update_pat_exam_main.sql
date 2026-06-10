-- pat_exam_main.order_label_info から 'label_cnt' キーを削除
update
  pat_exam_main
set
  order_label_info = B.order_label_info
from (
  select
    A.exam_main_cd,
    json_agg(A.deleted_info) as order_label_info
  from (
    select
      pat_exam_main.exam_main_cd,
      each_info - 'label_cnt' as deleted_info
    from
      pat_exam_main
    cross join
      jsonb_array_elements(pat_exam_main.order_label_info) each_info
    ) A
  group by
    A.exam_main_cd
  order by
    A.exam_main_cd
  ) B
where
  pat_exam_main.exam_main_cd = B.exam_main_cd;