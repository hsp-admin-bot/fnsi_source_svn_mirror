select
  A.weight_scale_no,
  A.ord_no,
  A.facility_cd,
  A.weight_cd,
  A.weight_name,
  A.machine_no,
  A.machine_name,
  A.weight_scale_status,
  A.message,
  A.measure_date,
  A.kur_cd,
  A.kur_name,
  A.bed_cd,
  A.bed_name,
  A.pat_id,
  A.scale_class,
  A.scale_mode,
  A.scale_value,
  A.rst_tare_info,
  A.rst_off_water_info,
  A.weight_value,
  A.target_weight_value,
  A.off_water_limit,
  A.wheel_chair_cd,
  A.wheel_chair_name,
  A.wheel_chair_weight,
  A.treatment_name,
  A.device_mode,
  A.user_id,
  A.reg_date,
  A.up_date
from
  ord_weight_scale A
where
  A.facility_cd = /*facilityCd*/''
and
  A.measure_date >= /*measure_date_from*/null
and
  A.measure_date < /*measure_date_to*/null
order by
  A.measure_date desc
;
