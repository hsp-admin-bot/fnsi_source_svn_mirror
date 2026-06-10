select
  A.exam_item_cd,
  A.exam_item_name,
  A.unit,
  A.graph_upper,
  A.graph_lower,
  A.console_class,
  (case
    when A.input_decimal_figure is null then 0
    else A.input_decimal_figure
   end) as input_decimal_figure
from
  mst_exam_item A   --テーブル名
  ,(
    select
      mss.facility_cd, ms.*, row_number() over() as index
    from
      mst_selector mss
      cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
      (
        code bigint,
        name text
      )
    where
    /*%if facilityCd != null */
      facility_cd = /* facilityCd*/'0'
      and
    /*%end */
      master_physical_name = 'mst_exam_item' --テーブル名
    ) ms
where
  A.facility_cd = ms.facility_cd
  and A.exam_item_cd = ms.code --コードのカラム
  and A.console_class = '1'
  and A.is_del = '0'
  and A.is_disp = '1'
order by
  ms.index
limit 100
;