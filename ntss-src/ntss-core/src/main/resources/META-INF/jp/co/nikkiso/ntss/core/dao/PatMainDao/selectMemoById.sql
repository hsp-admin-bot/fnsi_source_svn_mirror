select
  memo ->> 'content' as content
from
  pat_main as pat
cross join lateral
  json_array_elements (pat.pat_memo_info :: json) memo
where
  pat.pat_id = /*patId*/1
;
