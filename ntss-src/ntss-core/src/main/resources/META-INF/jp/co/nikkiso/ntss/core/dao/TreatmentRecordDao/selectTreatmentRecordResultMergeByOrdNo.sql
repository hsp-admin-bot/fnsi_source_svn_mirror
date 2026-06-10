select
  ord_no
  , pat_id
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_dw
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
--   add 10196 by kangjie 20240130 start del
--   , rst_device_set_info
--   add 10196 by kangjie 20240130 end del
  , weight_scale_no
  , rst_weight_info
--   add 10196 by kangjie 20240130 start del
--   , rst_vital_info
--   add 10196 by kangjie 20240130 end del
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , up_date
  , reg_date
  , rst_purification_cnt
  , treat_date
  , ind_ind_comment_info
  , ind_medi_info
from
(
  select
    -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
    -- *
    ord_no
    , pat_id
    , rst_input_class
    , rst_dialysis_state
    , rst_treatment_cd
    , rst_treatment_name
    , rst_kur_cd
    , rst_kur_name
    , rst_bed_cd
    , rst_bed_name
    , rst_machine_name
    , rst_cond_send_date
    , rst_accept_date
    , rst_start_date
    , rst_end_date
    , rst_return_home_date
    , rst_in_out_class
    , rst_dialysis_cnt
    , rst_ward_cd
    , rst_ward_name
    , rst_course_cd
    , rst_course_name
    , rst_dw
    , rst_puncture_user_info
    , rst_return_user_info
    , rst_charge_user_info
    , rst_blood_circulate_total
    , rst_running_time
    , rst_kt_v
    , rec_set_date
    , send_ctl_no
    , blood_purifier_name
    , pull_leave_amount
    , rst_cond_info
    , rst_medi_info
    , rst_equip_info
    , rst_ind_comment_info
    , rst_tare_info
    , rst_off_water_info
--   add 10196 by kangjie 20240130 start del
--     , rst_device_set_info
--   add 10196 by kangjie 20240130 end del
    , weight_scale_no
    , rst_weight_info
--   add 10196 by kangjie 20240130 start del
--     , rst_vital_info
--   add 10196 by kangjie 20240130 end del
    , rst_complaint_info
    , rst_treatment_info
    , rst_treat_staff_info
    , rst_rounds_info
    , up_date
    , reg_date
    , rst_purification_cnt
    , treat_date
    , ind_ind_comment_info
    , ind_medi_info
    -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
    -- # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B Start
    , rst_device_mode
    -- # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B End
  from
    ord_main
  where
    ord_no = /*ordNo*/1
  and
    is_del = '0'
  union all
  select
    -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
    -- m.*
    m.ord_no
    , m.pat_id
    , m.rst_input_class
    , m.rst_dialysis_state
    , m.rst_treatment_cd
    , m.rst_treatment_name
    , m.rst_kur_cd
    , m.rst_kur_name
    , m.rst_bed_cd
    , m.rst_bed_name
    , m.rst_machine_name
    , m.rst_cond_send_date
    , m.rst_accept_date
    , m.rst_start_date
    , m.rst_end_date
    , m.rst_return_home_date
    , m.rst_in_out_class
    , m.rst_dialysis_cnt
    , m.rst_ward_cd
    , m.rst_ward_name
    , m.rst_course_cd
    , m.rst_course_name
    , m.rst_dw
    , m.rst_puncture_user_info
    , m.rst_return_user_info
    , m.rst_charge_user_info
    , m.rst_blood_circulate_total
    , m.rst_running_time
    , m.rst_kt_v
    , m.rec_set_date
    , m.send_ctl_no
    , m.blood_purifier_name
    , m.pull_leave_amount
    , m.rst_cond_info
    , m.rst_medi_info
    , m.rst_equip_info
    , m.rst_ind_comment_info
    , m.rst_tare_info
    , m.rst_off_water_info
--   add 10196 by kangjie 20240130 start del
--     , m.rst_device_set_info
--   add 10196 by kangjie 20240130 end del
    , m.weight_scale_no
    , m.rst_weight_info
--   add 10196 by kangjie 20240130 start del
--     , m.rst_vital_info
--   add 10196 by kangjie 20240130 end del
    , m.rst_complaint_info
    , m.rst_treatment_info
    , m.rst_treat_staff_info
    , m.rst_rounds_info
    , m.up_date
    , m.reg_date
    , m.rst_purification_cnt
    , m.treat_date
    , m.ind_ind_comment_info
    , m.ind_medi_info
    -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
    -- # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B Start
    , m.rst_device_mode
    -- # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B End
  from
    ord_main m
      inner join
        -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
        --(select * from ord_main where ord_no = /*ordNo*/1 and is_del = '0') s
        (select ord_no, treat_date, pat_id from ord_main where ord_no = /*ordNo*/1 and is_del = '0') s
        -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
      on
        m.ord_no <> s.ord_no
      and
        m.treat_date = s.treat_date
      and
        (m.pat_id = s.pat_id or m.pat_id is null)
      and
        m.rst_dialysis_state in ('3', '4', '5', '6')
      and
        m.is_del = '0'
) result_merge
order by
  rst_bed_name
  , rst_start_date
  , pat_id
;
