WITH mss_bed AS ( 
    select
        mss.facility_cd
        , ms.*
        , row_number() over () as ord_index 
    from
        mst_selector mss 
        cross join lateral jsonb_to_recordset(mss.order_settings -> 'items') as ms(code bigint, name text) 
    where
        master_physical_name = 'mst_bed' 
        AND facility_cd = /*facilityCd*/''
)
select
  A.ord_no,
  A.pat_id,
  A.treat_date,
  A.treat_week,
  A.ind_kur_cd,
  A.ind_bed_cd,
  A.rst_kur_cd,
  A.rst_bed_cd,
  A.rst_dialysis_state,
  A.ind_medi_info,
  A.ind_cond_info,
  A.ind_equip_info,
  A.rst_medi_info,
  A.rst_cond_info,
  A.rst_equip_info,
  B.kur_name as ind_kur_name,
  C.bed_name as ind_bed_name,
  A.rst_kur_name,
  A.rst_bed_name,
  D.device_mode as ind_device_mode,
  E.device_mode as rst_device_mode,
  B.kur_start_time as ind_kur_start_time,
  F.kur_start_time as rst_kur_start_time,
  G.ord_index as ind_bed_order_index,
  H.ord_index as rst_bed_order_index
from
  -- 指定日の治療記録(スケジュール+実績)を取得
  (select
    ord_no,
    pat_id,
    treat_date,
    treat_week,
    ind_kur_cd,
    ind_bed_cd,
    rst_kur_cd,
    rst_bed_cd,
    rst_dialysis_state,
    ind_medi_info,
    ind_cond_info,
    ind_equip_info,
    rst_medi_info,
    rst_cond_info,
    rst_equip_info,
    rst_kur_name,
    rst_bed_name,
    ind_treatment_cd,
    rst_treatment_cd,
    facility_cd
  from ord_main
  where
    facility_cd = /*facilityCd*/'000000'
  and
    treat_date = /*treatDate*/'20190101'
  and
    is_del = '0'
  ) A
  left outer join mst_kur B on (A.ind_kur_cd = B.kur_cd)
  left outer join mst_bed C on (A.ind_bed_cd = C.bed_cd)
  left outer join mst_treatment D on (A.ind_treatment_cd = D.treatment_cd and A.facility_cd = D.facility_cd)
  left outer join mst_treatment E on (A.rst_treatment_cd = E.treatment_cd and A.facility_cd = E.facility_cd)
  left outer join mst_kur F on (A.rst_kur_cd = F.kur_cd)
  left outer join mss_bed G on (A.ind_bed_cd = G.code)
  left outer join mss_bed H on (A.rst_bed_cd = H.code)
;
