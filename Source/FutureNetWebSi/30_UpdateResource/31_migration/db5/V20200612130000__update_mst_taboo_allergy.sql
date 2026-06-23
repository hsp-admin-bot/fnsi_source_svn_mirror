-- mst_taboo_allergy.detail_info の 'cd' を数値型に変換
update
  mst_taboo_allergy
set
  detail_info = B.detail_info
from (
  select
    A.taboo_allergy_cd,
    json_agg(A.update_info) as detail_info
  from (
    select
      mst_taboo_allergy.taboo_allergy_cd,
      jsonb_typeof(each_info -> 'cd'),
    case 
      when 
        jsonb_typeof(each_info -> 'cd')::text = 'string'
      then 
        each_info || ('{"cd" :' || replace((each_info -> 'cd')::text, '"', '') || '}')::jsonb
      else 
        each_info
    end as update_info
    from
      mst_taboo_allergy
    cross join
      jsonb_array_elements(mst_taboo_allergy.detail_info) each_info
    ) A
  group by
    A.taboo_allergy_cd
  order by
    A.taboo_allergy_cd
  ) B
where
  mst_taboo_allergy.taboo_allergy_cd = B.taboo_allergy_cd;