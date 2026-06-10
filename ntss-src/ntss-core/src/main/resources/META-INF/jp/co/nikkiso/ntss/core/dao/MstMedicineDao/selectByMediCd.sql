SELECT
  A.medicine_cd
  , A.facility_cd
  , A.fn_medicine_cd
  , A.standard_medicine_cd
  , A.is_trial
  , A.medicine_name
  , A.medicine_short_name
  , A.unit
  , A.unit_second
  , A.class_cd
  , A.is_shot
  , A.use_start_date
  , A.use_end_date
  , A.is_medicated
  , A.unit_converted_amount
  , A.unit_converted_amount_second
  , A.anticoagulant_original_quantity
  , A.after_anticoagulant_quantity
  , A.in_hospital_cd_1
  , A.in_hospital_cd_2
  , A.in_hospital_cd_3
  , A.is_disp
  , A.is_del
  , A.reg_date
  , A.up_date
  , A.is_exchange
  , A.medicate_timing_cd
  , A.procedure_cd
  , A.unit_decimal_point
  , A.unit_decimal_point_second
FROM
  mst_medicine A
WHERE
  medicine_cd = /* medicineCd*/'0'
AND
  is_del = '0'
;