select
  comment ->> 'no' as sno,
  comment ->> 'content' as content
from
  ord_main as ord
cross join lateral
  json_array_elements (ord.rst_ind_comment_info :: json) comment
where
  ord.ord_no = /*ordNo*/1
;