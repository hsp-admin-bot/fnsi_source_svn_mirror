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
  nextval('ord_main_ord_no_seq')           AS ord_no,                -- 1
  p.pat_id,                                        -- 2
  NULL,                                            -- 3 fn_pat_id
  t.treat_date,                       -- 4
  EXTRACT(ISODOW FROM TO_DATE(t.treat_date,'YYYYMMDD')) AS treat_week,                                    -- 5
  p.facility_cd,                                   -- 6
  f.facility_name AS facility_name,                          -- 7 facility_name
  (p.ind_cond_info -> '2' ->> 'value')::integer AS ind_va_cd,                                            -- 8 ind_va_cd
  p.ind_treatment_cd,                              -- 9
  NULL,                                            --10 ind_treatment_name
  p.ind_kur_cd,                                    --11
  NULL,                                            --12 ind_kur_name
  NULLIF(p.ind_sch_info ->> 'ind_treat_start_time',''),        --13
  t.bed_cd,                                           --14
  NULL,                                            --15 ind_bed_name
  (
    p.ind_sch_info
      - 'ind_bed_cd'
      - 'ind_treat_start_time'
  ),                                               --16 ind_schedule_user_info
  p.ind_cond_info,                                 --17
  p.ind_medi_info,                                 --18
  p.ind_equip_info,                                --19
  p.ind_ind_comment_info,                          --20
  p.ind_tare_info,                                 --21
  p.ind_off_water_info,                            --22
  p.ind_device_set_info,                           --23
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
  NULL,                                            --55 rec_set_date
  NULL,                                            --56 send_ctl_no
  NULL,                                            --57 blood_purifier_name
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
  NULL,                                            --73 rst_dw
  NULL,                                            --74 weight_scale_no
  p.treat_type,                                   --75
  0,                                               --76 is_confirm
  NULL,                                            --77 ind_dw
  NULL,                                            --78 rst_purification_cnt
  NULL,                                            --79 addition_info
  /*indUserId*/0,                                  --80
  /*updUserId*/0,                                  --81
  NULL,                                            --82 rst_edition_date
  NULL,                                            --83 cur_edition_date
  NULL,                                            --84 fn_plural
  NULL,                                            --85 bvms_path
  NULL,                                            --86 ind_device_mode
  NULL,                                            --87 ind_dw_user_info
  NULL                                             --88 rst_device_mode
FROM
(
  SELECT
    v.src_ctl_no,
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
  ) AS v(src_ctl_no, treat_date, bed_cd, seq)
) t
JOIN pat_treatment_pattern p
  ON p.ctl_no = t.src_ctl_no
  AND p.facility_cd = /*facilityCd*/null
  AND p.pat_id = /*patId*/'000001'
JOIN pat_main pm
  ON pm.pat_id = p.pat_id
LEFT JOIN mst_facility f
  ON f.facility_cd = p.facility_cd
WHERE
  t.treat_date <=
    CASE
      WHEN pm.sch_ext_end_date IS NULL THEN
        to_char(
          date_trunc('month', CURRENT_DATE + interval '1 year')
            + interval '1 month - 1 day',
          'YYYYMMDD'
        )
      ELSE
        pm.sch_ext_end_date
    END
RETURNING *;
