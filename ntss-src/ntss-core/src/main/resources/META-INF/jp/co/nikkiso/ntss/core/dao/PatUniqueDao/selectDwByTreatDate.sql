select
physical_info.dw,
physical_info.ctr,
physical_info.memo,
physical_info.ctl_no,
physical_info.height,
physical_info.chest_dia,
physical_info.exam_date,
physical_info.breast_dia,
physical_info.ctr_weight,
physical_info.order_class,
to_number( coalesce(nullif(physical_info.indicator_cd,''),'0'), '99999999999999999999' )as indicator_cd,
physical_info.target_weight,
physical_info.pre_scale_lower,
physical_info.pre_scale_upper,
physical_info.indicator_start_date
from pat_unique a
 cross join lateral
  jsonb_to_recordset(a.physical_info)
 as physical_info
 (
  dw numeric,
  ctr numeric,
  memo text,
  ctl_no int,
  height numeric,
  chest_dia numeric,
  exam_date timestamp,
  breast_dia numeric,
  ctr_weight numeric,
  order_class int,
  indicator_cd text,
  target_weight numeric,
  pre_scale_lower numeric,
  pre_scale_upper numeric,
  indicator_start_date text
 )
where
  a.is_del = '0' and
  a.pat_id = /*patId*/3 and
--   mod 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関 start
--   physical_info.exam_date <= /*treatDate*/'00000000' and
  physical_info.exam_date <= TO_TIMESTAMP(/*treatDate*/'000000' || '235959', 'YYYYMMDDHH24MISS') and
--   mod 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関 end
  facility_cd = /*facilityCd*/'000000'
order by
  physical_info.exam_date desc,
  physical_info.ctl_no desc
limit 1
;
