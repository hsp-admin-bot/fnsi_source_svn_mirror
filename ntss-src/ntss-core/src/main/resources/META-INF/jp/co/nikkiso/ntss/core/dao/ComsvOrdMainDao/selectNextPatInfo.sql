select
  ord.ord_no,
  ord.pat_id,
  ord.treat_date,
  ord.facility_cd,
  ord.facility_name,
  ord.ind_treatment_cd,
  -- #9290 2023.10.19 add 実績展開後の名称を取得する TDC片口 start
  ord.ind_treatment_name,
  -- #9290 2023.10.19 add 実績展開後の名称を取得する TDC片口 end
  ord.ind_treat_start_time,
  ord.ind_cond_info,
  ord.ind_medi_info,
  ord.ind_equip_info,
  ord.ind_device_set_info,
  ord.ind_dw, -- #9147 2024.02.15 add 次患者整形 指示DW→無ければpat_uniqueの最新DW TDC山崎
  pat.is_infect,
  kur.kur_name
from
  ord_main as ord
join
  pat_main as pat
on
  ord.pat_id = pat.pat_id
join
  mst_kur as kur
on
  ord.ind_kur_cd = kur.kur_cd
where
  ord_no = /*ordNo*/1
;
