select
  A.ord_no,
  A.facility_cd,
  A.pat_id,
  A.treat_date,
  A.treat_week,
  A.ind_kur_cd,
  A.ind_bed_cd,
  A.rst_kur_cd,
  A.rst_bed_cd,
  A.rst_dialysis_state,
  B.kur_name as ind_kur_name,
  C.bed_name as ind_bed_name,
  A.rst_kur_name,
  A.rst_bed_name,
  D.device_mode as ind_device_mode,
  E.device_mode as rst_device_mode,
  A.rst_start_date,
  A.rst_end_date
from
  -- 指定日の治療記録(スケジュール+実績)を取得
  (select
    *
  from ord_main
  where
    facility_cd = /*facilityCd*/'000000'
  and
    treat_date between /*startDate*/'20190101' and /*endDate*/'20190101'
  and
    (ind_bed_cd  = /*bedCd*/0 or ind_bed_cd = 0)
  and
    pat_id IS NOT NULL
  and
    rst_dialysis_state = '0'
  and
    is_del = '0'
  ) A
  left outer join mst_kur B on (A.ind_kur_cd = B.kur_cd)
  left outer join mst_bed C on (A.ind_bed_cd = C.bed_cd)
  left outer join mst_treatment D on (A.ind_treatment_cd = D.treatment_cd)
  left outer join mst_treatment E on (A.rst_treatment_cd = E.treatment_cd)
;