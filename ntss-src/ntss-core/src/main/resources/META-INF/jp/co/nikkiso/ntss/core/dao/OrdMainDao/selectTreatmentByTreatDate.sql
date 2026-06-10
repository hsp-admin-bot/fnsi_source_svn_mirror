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
  A.treat_date || COALESCE(B.kur_start_time, '') as date_kur
from
  -- 指定日の治療記録(スケジュール+実績)を取得
  (  select
    *
  from ord_main A
  where
    ord_no in
  (select
     ord_no
   from
     ord_main as B
     where
       A.ind_bed_cd = B.ind_bed_cd
     order by
       treat_date, ind_kur_cd
   limit 5)
  and
    facility_cd = /*facilityCd*/'000000'
  and
    treat_date >= /*treatDate*/'20190101'
  and
    is_del = '0'
  union
  -- 装置状態と一致する治療中の治療記録を取得
  select
    ord_main.*
  from ord_main
    inner join
      -- 装置情報から治療中のord_no取得
      (select
        ord_no
      from
        mnt_machine_state
      where
        facility_cd = /*facilityCd*/'000000'
      and
        -- ord_noの値があるもの
        (ord_no is not null)
      ) mnt_machine_state
    on (ord_main.ord_no = mnt_machine_state.ord_no)
  where
    is_del = '0'
  ) A
  left outer join mst_kur B on (A.ind_kur_cd = B.kur_cd)
  left outer join mst_bed C on (A.ind_bed_cd = C.bed_cd)
  left outer join mst_treatment D on (A.ind_treatment_cd = D.treatment_cd and A.facility_cd = D.facility_cd)
  left outer join mst_treatment E on (A.rst_treatment_cd = E.treatment_cd and A.facility_cd = E.facility_cd)
  order by ind_bed_cd, date_kur
;
