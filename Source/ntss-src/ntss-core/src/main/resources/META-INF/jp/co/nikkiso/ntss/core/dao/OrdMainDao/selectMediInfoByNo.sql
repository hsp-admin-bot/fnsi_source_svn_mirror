select
  info.idx,
  medi ->> 'no' as sno,
  medi ->> 'name' as name,
  medi ->> 'unit' as unit,
  medi ->> 'amount' as amount,
  medi ->> 'effect_flg' as effect_flg,
  CASE WHEN medi ->> 'effect_date' is NULL OR medi ->> 'effect_date' = 'null'
    THEN NULL
    ELSE TO_TIMESTAMP(medi ->> 'effect_date', 'YYYY-MM-DD"T"HH24:MI:SS')
  END as effect_date,
  CASE WHEN medi ->> 'medicine_type' = '2'
    THEN (select A.is_medicated from mst_medicine_mix A where (medi ->> 'cd') :: int = A.medicine_mix_cd and A.is_disp = '1' and A.is_del = '0')
    ELSE (select B.is_medicated from mst_medicine B where (medi ->> 'cd') :: int = B.medicine_cd and B.is_disp = '1' and B.is_del = '0')
  END as is_medicated,
  mst_t.dialysis_progress_cd as progress_cd,
  COALESCE(mst_t.alert_time, -1) as alert_time,
  mst_t.is_alert as is_alert
from
  ord_main as ord
cross join lateral
  json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS info(medi, idx)
left join
  mst_medicate_timing mst_t on (medi ->> 'timing_cd') :: int = mst_t.medicate_timing_cd and
  mst_t.is_alert = '1' and
  mst_t.is_del = '0'
where
  ord.ord_no = /*ordNo*/1
order by
  info.idx
;
