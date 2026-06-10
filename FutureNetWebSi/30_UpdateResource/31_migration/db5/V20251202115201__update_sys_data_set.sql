DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 131;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (131, 'with tmp as(
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
    and kur_name is not null
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
;', 2, '[{"preview": "午後", "can_calc": "", "data_code": "kur_selection_name", "data_name": "選択クール名", "data_type": "string", "conv_table": [], "data_class": "選択クール名", "field_name": "kur_selection_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}]', '0', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド) 選択クール名 @ordNos 使用', '2020-04-09 16:01:00', CURRENT_TIMESTAMP, NULL);
