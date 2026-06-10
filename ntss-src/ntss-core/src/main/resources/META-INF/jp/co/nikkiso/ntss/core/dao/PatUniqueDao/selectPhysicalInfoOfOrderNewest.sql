-- upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start
/*%if patShareMode == 0 */
WITH pat_ids AS (
    SELECT /*patId*/0 AS pat_id
    UNION
    SELECT spi.from_pat_id
    FROM shr_pat_info spi
    WHERE spi.to_pat_id = /*patId*/0
      AND spi.is_from_consent = '1'
      AND spi.is_to_consent = '1'
      AND spi.is_pat_consent = '1'
      AND spi.is_disp = '1'
      AND spi.is_del = '0'
)
/*%end*/
select
--#5738 指示者が選択されない場合の特別処理　start ljx
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
--#5738 指示者が選択されない場合の特別処理 end ljx
from pat_unique a
/*%if patShareMode == 0 */
JOIN pat_ids pid ON pid.pat_id = a.pat_id
/*%end*/
 cross join lateral
  jsonb_to_recordset(a.physical_info)
 as physical_info
 (
  dw text,
  ctr text,
  memo text,
  ctl_no int,
  height text,
  chest_dia text,
  exam_date timestamp,
  breast_dia text,
  ctr_weight text,
  order_class int,
  indicator_cd text,
  target_weight text,
  pre_scale_lower text,
  pre_scale_upper text,
  indicator_start_date text
 )
where
  a.is_del = '0'
/*%if patShareMode != 0 */
and
  a.pat_id = /*patId*/3
/*%end*/
order by
  physical_info.exam_date desc,
  physical_info.ctl_no desc
;
-- upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end
