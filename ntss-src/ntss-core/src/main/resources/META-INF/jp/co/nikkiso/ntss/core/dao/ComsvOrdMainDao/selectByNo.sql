select
  ord_no,
  pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_name,
  rst_bed_name,
  rst_machine_no,
  rst_machine_name,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_name,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  rst_running_time,
  rst_cond_info,
  rst_medi_info,
  rst_equip_info,
--   add 10196 by kangjie 20240130 start del
--   rst_device_set_info,
--   add 10196 by kangjie 20240130 end del
  rst_dialysis_state as dial_state,
  rst_cond_send_date as send_date,
  rst_start_date as start_date,
  rst_end_date as end_date
from
  ord_main
where
  ord_no = /*ordNo*/1
