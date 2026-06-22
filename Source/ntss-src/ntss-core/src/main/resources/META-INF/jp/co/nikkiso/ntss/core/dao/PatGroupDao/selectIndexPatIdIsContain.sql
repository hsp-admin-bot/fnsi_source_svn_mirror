select
  ms.index
from
  ntss.pat_group A
  ,(
    select code, row_number() over() as index
    from ntss.mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
    where
      facility_cd = /* facilityCd*/'0'
    and master_physical_name = 'pat_group'
  ) ms
  ,(
    select
      A.pat_group_cd, B.pat_group_name
    from
      pat_group_detail as A LEFT JOIN pat_group as B ON A.pat_group_cd = B.pat_group_cd
    where
      B.is_del = '0' and
      A.pat_id = /* patId*/'0'
  ) pgd
	where
    A.pat_group_cd = ms.code --コードのカラム
  and
    facility_cd = /* facilityCd*/'0'
  and
    A.is_del = '0'
  and
    A.is_disp = '1'
  and
    A.pat_group_cd = pgd.pat_group_cd
  order by
    ms.index
  limit 1
;