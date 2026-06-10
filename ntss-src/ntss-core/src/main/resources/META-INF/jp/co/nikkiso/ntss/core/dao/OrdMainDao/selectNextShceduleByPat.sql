select
  O.ord_no, O.pat_id, O.facility_cd,
  O.treat_date, O.ind_treat_start_time,
  O.treat_date || COALESCE(O.ind_treat_start_time, '0000') as schedule_date,
  O.ind_kur_cd, K.kur_name as ind_kur_name,
  O.ind_bed_cd, B.bed_name as ind_bed_name
from
  ord_main O
  left outer join mst_bed B on O.ind_bed_cd = B.bed_cd
  left outer join mst_kur K on O.ind_kur_cd = K.kur_cd
where
 O.pat_id = /*patId*/3
 and
 O.treat_date || COALESCE(O.ind_treat_start_time, '0000') > /*basetreatDateTime*/'201904010000'
 and
 O.rst_dialysis_state = '0' -- 条件送信前のみ
 and
 O.is_del = '0'
order by
 schedule_date asc
limit 1
;