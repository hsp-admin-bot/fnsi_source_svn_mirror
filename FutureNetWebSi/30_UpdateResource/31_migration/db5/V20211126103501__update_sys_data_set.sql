UPDATE "ntss"."sys_data_set" SET "sql" = 'with tmp as(
  select
    count(distinct mst_kur.kur_name) as num_of_kinds
 from
    ord_main  left  join   mst_kur  on  mst_kur.kur_cd=ord_main.ind_kur_cd  and  mst_kur.is_del= ''0''
  where
    ord_main.is_del = ''0''
   and ord_no in (@ordNos)
)
, kur_name_tbl as(
  select
  mst_kur.kur_name as  ind_kur_name
  from ord_main   left  join   mst_kur  on  mst_kur.kur_cd=ord_main.ind_kur_cd  and  mst_kur.is_del= ''0''
    where  ord_main.is_del = ''0''
    and ord_no in (@ordNos)
    and ind_kur_name is not null
  limit 1
)

select
 case
   when num_of_kinds = 0 then ''クール未登録''
   when num_of_kinds = 1 then (select * from kur_name_tbl)
   else ''複数クール選択''
 end as kur_selection_name
from
  tmp
;' WHERE "sql_cd" = 131;
