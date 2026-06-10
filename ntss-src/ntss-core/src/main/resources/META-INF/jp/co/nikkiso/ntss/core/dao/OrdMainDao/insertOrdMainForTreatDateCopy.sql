INSERT INTO ord_main
(
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  ind_va_cd,
  ind_treatment_cd,
  ind_treatment_name,
  ind_kur_cd,
  ind_kur_name,
  ind_treat_start_time,
  ind_bed_cd,
  ind_bed_name,
  ind_schedule_user_info,
  ind_cond_info,
  ind_medi_info,
  ind_equip_info,
  ind_ind_comment_info,
  ind_tare_info,
  ind_off_water_info,
  ind_device_set_info,
  rst_fn_dialysis_no,
  rst_relation_dialysis_no,
  rst_edition,
  rst_is_update_edition,
  rst_input_class,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_machine_no,
  rst_machine_name,
  rst_cond_send_date,
  rst_accept_date,
  rst_start_date,
  rst_end_date,
  rst_return_home_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  rst_blood_circulate_total,
  rst_running_time,
  rst_kt_v,
  rec_set_date,
  send_ctl_no,
  blood_purifier_name,
  pull_leave_amount,
  rst_cond_info,
  rst_medi_info,
  rst_equip_info,
  rst_ind_comment_info,
  rst_tare_info,
  rst_off_water_info,
  rst_weight_info,
  rst_complaint_info,
  rst_treatment_info,
  rst_treat_staff_info,
  rst_rounds_info,
  is_del,
  up_date,
  reg_date,
  rst_dw,
  weight_scale_no,
  treat_type,
  is_confirm,
  ind_dw,
  rst_purification_cnt,
  addition_info,
  up_ind_user_id,
  up_user_id,
  rst_edition_date,
  cur_edition_date,
  fn_plural,
  bvms_path,
  ind_device_mode,
  ind_dw_user_info,
  rst_device_mode
)
SELECT
  nextval('ord_main_ord_no_seq')                   AS ord_no,
  o.pat_id,                                        -- 2
  o.fn_pat_id,                                     -- 3
  t.treat_date,                                    -- 4
  EXTRACT(ISODOW FROM TO_DATE(t.treat_date,'YYYYMMDD')) AS treat_week,
  o.facility_cd,                                   -- 6
  o.facility_name,                                 -- 7
  o.ind_va_cd,                                     -- 8
  o.ind_treatment_cd,                              -- 9
  o.ind_treatment_name,                            --10
  o.ind_kur_cd,                                    --11
  o.ind_kur_name,                                  --12
  o.ind_treat_start_time,                          --13
  t.bed_cd,                                        --14
  o.ind_bed_name,                                  --15
  o.ind_schedule_user_info,                        --16
  o.ind_cond_info,                                 --17
  o.ind_medi_info,                                 --18
  o.ind_equip_info,                                --19
  o.ind_ind_comment_info,                          --20
  o.ind_tare_info,                                 --21
  o.ind_off_water_info,                            --22
  o.ind_device_set_info,                           --23
  NULL,                                            --24 rst_fn_dialysis_no
  NULL,                                            --25 rst_relation_dialysis_no
  '0',                                             --26 rst_edition
  NULL,                                            --27 rst_is_update_edition
  NULL,                                            --28 rst_input_class
  '0',                                             --29 rst_dialysis_state
  NULL,                                            --30 rst_treatment_cd
  NULL,                                            --31 rst_treatment_name
  NULL,                                            --32 rst_kur_cd
  NULL,                                            --33 rst_kur_name
  NULL,                                            --34 rst_bed_cd
  NULL,                                            --35 rst_bed_name
  NULL,                                            --36 rst_machine_no
  NULL,                                            --37 rst_machine_name
  NULL,                                            --38 rst_cond_send_date
  NULL,                                            --39 rst_accept_date
  NULL,                                            --40 rst_start_date
  NULL,                                            --41 rst_end_date
  NULL,                                            --42 rst_return_home_date
  NULL,                                            --43 rst_in_out_class
  NULL,                                            --44 rst_dialysis_cnt
  NULL,                                            --45 rst_ward_cd
  NULL,                                            --46 rst_ward_name
  NULL,                                            --47 rst_course_cd
  NULL,                                            --48 rst_course_name
  NULL,                                            --49 rst_puncture_user_info
  NULL,                                            --50 rst_return_user_info
  NULL,                                            --51 rst_charge_user_info
  NULL,                                            --52 rst_blood_circulate_total
  NULL,                                            --53 rst_running_time
  NULL,                                            --54 rst_kt_v
  CURRENT_TIMESTAMP,                               --55 rec_set_date
  NULL,                                            --56 send_ctl_no
  o.blood_purifier_name,                            --57
  NULL,                                            --58 pull_leave_amount
  NULL,                                            --59 rst_cond_info
  NULL,                                            --60 rst_medi_info
  NULL,                                            --61 rst_equip_info
  NULL,                                            --62 rst_ind_comment_info
  NULL,                                            --63 rst_tare_info
  NULL,                                            --64 rst_off_water_info
  NULL,                                            --65 rst_weight_info
  NULL,                                            --66 rst_complaint_info
  NULL,                                            --67 rst_treatment_info
  NULL,                                            --68 rst_treat_staff_info
  NULL,                                            --69 rst_rounds_info
  '0',                                             --70 is_del
  CURRENT_TIMESTAMP,                               --71 up_date
  CURRENT_TIMESTAMP,                               --72 reg_date
  o.rst_dw,                                        --73
  o.weight_scale_no,                               --74
  o.treat_type,                                   --75
  0,                                               --76 is_confirm
  o.ind_dw,                                        --77
  o.rst_purification_cnt,                          --78
  o.addition_info,                                 --79
  /*indUserId*/0,                                  --80
  /*updUserId*/0,                                  --81
  NULL,                                            --82 rst_edition_date
  NULL,                                            --83 cur_edition_date
  o.fn_plural,                                     --84
  o.bvms_path,                                     --85
  o.ind_device_mode,                               --86
  o.ind_dw_user_info,                              --87
  o.rst_device_mode                                --88
FROM
(
  SELECT
    v.src_ord_no,
    v.treat_date,
    v.bed_cd,
    v.seq
  FROM
  (
    VALUES
    /*%for dto : copyList */
      (
        /*dto.ordNo*/0,
        /*dto.treatDate*/null,
        /*dto.bedCd*/0,
        /*dto_index*/0
      )
      /*%if dto_has_next*/
      ,
      /*%end*/
    /*%end*/
  ) AS v(src_ord_no, treat_date, bed_cd, seq)
) t
JOIN ord_main o
  ON o.ord_no = t.src_ord_no
JOIN pat_main p
  ON o.pat_id = p.pat_id
WHERE
  t.treat_date <=
  CASE
    WHEN p.sch_ext_end_date IS NULL THEN
      to_char(
        date_trunc('month', CURRENT_DATE + interval '1 year')
        + interval '1 month - 1 day',
        'YYYYMMDD'
      )
    ELSE
      p.sch_ext_end_date
  END
RETURNING *;
