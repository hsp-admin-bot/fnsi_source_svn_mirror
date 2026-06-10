select
  ord_no
  , pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , rst_dialysis_state
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_start_date
  , rst_end_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , up_date
  , reg_date
  , is_confirm
  , rst_treatment_cd
  , rst_treatment_name
  , rst_purification_cnt
  , rst_input_class
  , rst_edition_date
  , rst_cond_info
  -- add by chamaojia 2025-02-28 [11471] Add the return value of 【rst_device_mode】 --start
  , rst_device_mode
  -- add by chamaojia 2025-02-28 [11471] Add the return value of 【rst_device_mode】 --end
from
  ord_main
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
