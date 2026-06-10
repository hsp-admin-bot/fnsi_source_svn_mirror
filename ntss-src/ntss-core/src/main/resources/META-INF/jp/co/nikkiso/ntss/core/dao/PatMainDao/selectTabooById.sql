select
  taboo ->> 'disp_order' as disp_order,
  taboo ->> 'content' as content
from
  pat_main as pat
cross join lateral
  json_array_elements (pat.taboo_allergy_info :: json) taboo
where
  pat.pat_id = /*patId*/1
order by
  disp_order
;
