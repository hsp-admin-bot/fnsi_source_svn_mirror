UPDATE "ntss"."sys_data_set" SET "sql" = 'with pat_taboo_tbl as (
  select
    to_number( info->>''ctl_no'', ''99999'') as ctl_no,
    to_number( info->>''disp_order'', ''99999'') as disp_order,
    info->>''content'' as content,
    info->>''memo'' as memo,
    info->>''category_class'' as category_class,
    info->>''taboo_allergy_class'' as taboo_allergy_class,
    info->>''taboo_allergy_cd'' as taboo_allergy_cd
  from
    pat_main
    cross join lateral
      json_array_elements (pat_main.taboo_allergy_info :: json) info
  where
    pat_id = @patId
	and is_del = ''0''
)

select
  ctl_no,
  disp_order,
  content,
  memo,
  category_class,
  taboo_allergy_class,
  taboo_allergy_cd
from
  pat_taboo_tbl
order by
  disp_order, ctl_no
'WHERE "sql_cd" = 22;