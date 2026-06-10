select
  om.treat_date ,
  om.rst_treatment_cd ,
  mt.device_mode ,
  om.rst_start_date ,
  om.rst_end_date ,
  extract(epoch from (om.rst_start_date - /*treatTime*/'20240126 22:11'::timestamp) ) as time_diff_before,
  extract(epoch from (om.rst_end_date - /*treatTime*/'20240126 22:11'::timestamp) ) as time_diff_after,
  extract(epoch from ((om.rst_weight_info ->> 'weight_before_date')::timestamp - /*treatTime*/'20240705 16:00'::timestamp) ) as w_time_diff_before,
  extract(epoch from ((om.rst_weight_info ->> 'weight_after_date')::timestamp - /*treatTime*/'20240705 16:00'::timestamp) ) as w_time_diff_after,
  om.rst_weight_info ->> 'weight_before' as weight_before,
  om.rst_weight_info ->> 'weight_after' as weight_after
from
  ord_main om
  inner join mst_treatment mt
on om.rst_treatment_cd = mt.treatment_cd
  and om.facility_cd = mt.facility_cd
where
  om.facility_cd = /*facilityCd*/'NKKSBR'
  and om.pat_id = /*patId*/11782
  and om.treat_date = /*treatDate*/'20240126'
  and om.rst_dialysis_state > '0'
  and om.is_del = '0'
order by
  om.rst_start_date desc nulls last,
  om.rst_end_date desc nulls last,
  om.up_date desc
