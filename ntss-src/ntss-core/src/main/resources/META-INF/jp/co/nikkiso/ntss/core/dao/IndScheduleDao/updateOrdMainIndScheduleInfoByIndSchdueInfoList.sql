WITH updates AS (
  SELECT facility_cd, ord_no, treat_date, ind_kur_cd, ind_bed_cd
  FROM (
     VALUES
       (null, 0, null, 0, 0),
       /*%for isl : indScheduleInfoList */
       (
         /*isl.facilityCd*/null,
         /*isl.ordNo*/0,
         /*isl.treatDate*/null,
         /*isl.indKurCd*/0,
         /*isl.indBedCd*/0
       )
       /*%if isl_has_next */
       /*# "," */
       /*%end*/
      /*%end*/
   ) AS t(facility_cd, ord_no, treat_date, ind_kur_cd, ind_bed_cd)
)
UPDATE ord_main AS om
SET treat_date = u.treat_date
  ,treat_week = EXTRACT(ISODOW FROM to_date(u.treat_date, 'yyyyMMdd'))
  ,ind_kur_cd = u.ind_kur_cd
  ,ind_treat_start_time = CASE
                              WHEN mk.kur_standard_start_time IS NOT NULL THEN substring(mk.kur_standard_start_time, 1, 4)
                              ELSE om.ind_treat_start_time
                          END
  ,ind_bed_cd = u.ind_bed_cd
  ,ind_schedule_user_info = om.ind_schedule_user_info ||
                                  jsonb_build_object(
--                                   mod 10860 ind_schedule_user_infoのデータ不正 zhao start
--                                                      'ind_kur_cd', om.ind_kur_cd,
--                                                      'ind_treat_start_time', om.ind_treat_start_time
                                                     'ind_kur_cd_before', om.ind_kur_cd,
                                                     'ind_treat_start_time_before', om.ind_treat_start_time
--                                   mod 10860 ind_schedule_user_infoのデータ不正 zhao end
                                    , 'ind_user_id', /*indUser.userId*/null
                                    , 'ind_user_first_name', /*indUser.userFirstName*/'null'::text
                                    , 'ind_user_last_name', /*indUser.userLastName*/' '::text
                                    , 'upd_user_id', /*updUser.userId*/null
                                    , 'upd_user_first_name', /*updUser.userFirstName*/'null'::text
                                    , 'upd_user_last_name', /*updUser.userLastName*/' '::text
                                  )
  ,up_date = transaction_timestamp()
  ,up_ind_user_id = /*indUser.userId*/null
  ,up_user_id = /*updUser.userId*/null
   --治療状況別分岐処理
  ,rst_dialysis_state = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN '0' ELSE om.rst_dialysis_state END
  ,ind_treatment_name = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.ind_treatment_name END
  ,ind_device_mode = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.ind_device_mode END
  ,ind_kur_name = CASE
                    WHEN om.rst_dialysis_state IN ('1', '2') THEN null
                    WHEN om.rst_dialysis_state IN ('4', '5', '6') THEN mk.kur_name
                    ELSE om.ind_kur_name
                  END
  ,ind_bed_name = CASE
                    WHEN om.rst_dialysis_state IN ('1', '2') THEN null
                    WHEN om.rst_dialysis_state IN ('4', '5', '6') THEN mb.bed_name
                    ELSE om.ind_bed_name
                  END
  --mod #11841 【たくしん会】ord_mainの登録不正 zrx start
  ,ind_medi_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN (
    SELECT jsonb_agg(elem - 'name' - 'unit' - 'class_cd' - 'class_name' - 'class_type' - 'short_name' - 'timing_name' - 'procedure_name')
    FROM jsonb_array_elements(om.ind_medi_info) AS elem
    )
      ELSE om.ind_medi_info END
  ,ind_equip_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN (
    SELECT jsonb_agg(elem - 'name' - 'unit' - 'class_cd' - 'class_name' - 'class_type' - 'short_name')
    FROM jsonb_array_elements(om.ind_equip_info) AS elem
    )
      ELSE om.ind_equip_info END
  ,ind_cond_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN (
    SELECT jsonb_object_agg(key, value - 'unit' - 'value_name_1' - 'value_name_2')
    FROM jsonb_each(om.ind_cond_info)
      )
      ELSE om.ind_cond_info END
  --mod #11841 【たくしん会】ord_mainの登録不正 zrx end
  ,ind_dw = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.ind_dw END
--   add 10443 身体情報・DW・目標体重バグ 関  start
  ,ind_dw_user_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.ind_dw_user_info END
--   add 10443 身体情報・DW・目標体重バグ 関  end
  ,rst_dw = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_dw END
  ,addition_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.addition_info END
  ,send_ctl_no = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.send_ctl_no END
  ,blood_purifier_name = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.blood_purifier_name END
  ,pull_leave_amount = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.pull_leave_amount END
  ,weight_scale_no = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.weight_scale_no END
  ,rst_input_class = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_input_class END
  ,rst_cond_send_date = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_cond_send_date END
  ,rst_treatment_cd = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_treatment_cd END
  ,rst_treatment_name = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_treatment_name END
  /*%if updateRst != null && updateRst.equals("1") */
  ,rst_kur_cd = CASE WHEN om.rst_dialysis_state IN ('4', '5', '6') THEN u.ind_kur_cd ELSE om.rst_kur_cd END
  ,rst_kur_name = CASE
                    WHEN om.rst_dialysis_state IN ('4', '5', '6') AND u.ind_kur_cd > 0 THEN mk.kur_name
                    WHEN om.rst_dialysis_state IN ('4', '5', '6') THEN NULL
                    ELSE om.rst_kur_name
                  END
  ,rst_bed_cd = CASE WHEN om.rst_dialysis_state IN ('4', '5', '6') THEN u.ind_bed_cd ELSE om.rst_bed_cd END
  ,rst_bed_name = CASE
                    WHEN om.rst_dialysis_state IN ('4', '5', '6') AND u.ind_bed_cd > 0 THEN mb.bed_name
                    WHEN om.rst_dialysis_state IN ('4', '5', '6') THEN NULL
                    ELSE om.rst_bed_name
                  END
  /*%else*/
  ,rst_kur_cd = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_kur_cd END
  ,rst_kur_name = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_kur_name END
  ,rst_bed_cd = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_bed_cd END
  ,rst_bed_name = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_bed_name END
  /*%end*/
  ,rst_machine_no = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_machine_no END
  ,rst_machine_name = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_machine_name END
  ,rst_accept_date = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_accept_date END
  ,rst_start_date = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_start_date END
  ,rst_end_date = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_end_date END
  ,rst_return_home_date = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_return_home_date END
  ,rst_in_out_class = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_in_out_class END
  ,rst_dialysis_cnt = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_dialysis_cnt END
  ,rst_ward_cd = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_ward_cd END
  ,rst_ward_name = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_ward_name END
  ,rst_course_cd = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_course_cd END
  ,rst_course_name = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_course_name END
  ,rst_puncture_user_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_puncture_user_info END
  ,rst_return_user_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_return_user_info END
  ,rst_charge_user_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_charge_user_info END
  ,rst_blood_circulate_total = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_blood_circulate_total END
  ,rst_running_time = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_running_time END
  ,rst_kt_v = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_kt_v END
  ,rec_set_date = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rec_set_date END
  ,rst_cond_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_cond_info END
  ,rst_medi_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_medi_info END
  ,rst_equip_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_equip_info END
  ,rst_ind_comment_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_ind_comment_info END
  ,rst_tare_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_tare_info END
  ,rst_off_water_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_off_water_info END
  ,rst_weight_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_weight_info END
  ,rst_complaint_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_complaint_info END
  ,rst_treatment_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_treatment_info END
  ,rst_treat_staff_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_treat_staff_info END
  ,rst_rounds_info = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_rounds_info END
  ,rst_purification_cnt = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_purification_cnt END
  ,bvms_path = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.bvms_path END
  ,rst_device_mode = CASE WHEN om.rst_dialysis_state IN ('1', '2') THEN null ELSE om.rst_device_mode END
FROM updates AS u
LEFT JOIN mst_kur AS mk ON mk.facility_cd = u.facility_cd AND u.ind_kur_cd = mk.kur_cd
LEFT JOIN mst_bed AS mb ON mb.facility_cd = u.facility_cd AND u.ind_bed_cd = mb.bed_cd
WHERE om.facility_cd = /*facilityCd*/null
  AND om.facility_cd = u.facility_cd
  AND om.ord_no = u.ord_no
  AND om.rst_dialysis_state <> '3'
RETURNING om.*
