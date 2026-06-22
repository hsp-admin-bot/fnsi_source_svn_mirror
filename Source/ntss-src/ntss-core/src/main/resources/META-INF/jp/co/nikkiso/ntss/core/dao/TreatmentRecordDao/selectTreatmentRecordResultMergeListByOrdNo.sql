WITH mss_bed AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_bed'
    AND facility_cd = /*facilityCd*/'nkknkk'
),
mss_treatment AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_treatment'
    AND facility_cd = /*facilityCd*/'nkknkk'
)

select
  ord_no
  , treat_date
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
-- delete by chamaojia 2024-02-04 [10196] Attribute deleted  --start
--   , rst_device_set_info
-- delete by chamaojia 2024-02-04 [10196] Attribute deleted  --end
  , weight_scale_no
  , rst_weight_info
-- delete by chamaojia 2024-02-04 [10196] Attribute deleted  --start
--   , rst_vital_info
-- delete by chamaojia 2024-02-04 [10196] Attribute deleted  --start
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , T1.up_date
  , T1.reg_date
  , rst_purification_cnt
  , ind_ind_comment_info
  , ind_medi_info
  -- # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B Start
  , rst_device_mode
  -- # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B End
  , K.kur_start_time as rst_kur_start_time
  , MSB.ord_index as rst_bed_order_index
  , MST.ord_index as rst_treatment_order_index
from
    (select
  ord_no
  , treat_date
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
-- delete by chamaojia 2024-02-04 [10196] Attribute deleted  --start
--   , rst_device_set_info
-- delete by chamaojia 2024-02-04 [10196] Attribute deleted  --end
  , weight_scale_no
  , rst_weight_info
-- delete by chamaojia 2024-02-04 [10196] Attribute deleted  --start
--   , rst_vital_info
-- delete by chamaojia 2024-02-04 [10196] Attribute deleted  --end
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , up_date
  , reg_date
  , rst_purification_cnt
  , ind_ind_comment_info
  , ind_medi_info
  , is_del
  -- # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B Start
  , rst_device_mode
  -- # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B End
--   , CASE WHEN treat_date IS NOT NULL AND rst_start_date IS NULL THEN treat_date
--     WHEN treat_date IS NULL AND rst_start_date IS NOT NULL THEN to_char(rst_start_date, 'yyyyMMdd')
--     WHEN treat_date < to_char(rst_start_date, 'yyyyMMdd') THEN treat_date
--     ELSE to_char(rst_start_date, 'yyyyMMdd') END AS treat_start_date
  , case
      when rst_start_date is not null then rst_start_date
      else to_timestamp(treat_date, 'YYYYMMDD') end as treat_start_date
--   , CASE WHEN rst_end_date IS NOT NULL THEN to_char(rst_end_date, 'yyyyMMdd')
--     WHEN rst_end_date IS NULL AND treat_date IS NOT NULL THEN treat_date
--     WHEN rst_end_date IS NULL AND treat_date IS NULL THEN to_char(NOW(), 'yyyyMMdd') END AS treat_end_date
  , case
      when rst_end_date is not null then rst_end_date
      when rst_start_date is not null and current_timestamp < rst_start_date then rst_start_date
      when rst_start_date is null and current_timestamp < to_timestamp(treat_date, 'YYYYMMDD') then to_timestamp(treat_date, 'YYYYMMDD')
      else current_timestamp end as treat_end_date
from
ord_main
where
  facility_cd = /*facilityCd*/'NKKSBR'
) T1
  left join mst_kur K on T1.rst_kur_cd = K.kur_cd
  left join mss_bed MSB on T1.rst_bed_cd = MSB.code
  left join mss_treatment MST on T1.rst_treatment_cd = MST.code
where
T1.ord_no <> /*ordNo*/1
and (
    (T1.treat_start_date, T1.treat_end_date) OVERLAPS (/*startDate*/'00000000', /*endDate*/'99999999')
)
/*%if "false" == isUnknown*/
and (T1.pat_id = /*patId*/1 or T1.pat_id is null)
/*%end*/
/*%if "true" == isUnknown*/
and T1.pat_id is not null
/*%end*/
and T1.rst_dialysis_state in ('3','4','5','6')
and T1.is_del = '0'
order by
    treat_date desc
  , rst_kur_start_time
  , rst_bed_order_index
;
