select
  O.ord_no, O.pat_id, O.facility_cd, P.is_same, O.treat_date, O.ind_treatment_cd,
  T_IND.treatment_name as ind_treatment_name,
  T_IND.device_mode as ind_device_mode,
  O.ind_kur_cd,
  K.kur_name as ind_kur_name,
  O.ind_treat_start_time,
  CASE WHEN B.is_disp = '0' or B.is_del = '1' THEN null ELSE O.ind_bed_cd END as ind_bed_cd,
  CASE WHEN B.is_disp = '0' or B.is_del = '1' THEN 'ベッド未設定' ELSE B.bed_name END as ind_bed_name,
  O.rst_edition, O.rst_dialysis_state,
  O.ind_schedule_user_info,
  O.ind_cond_info,
  O.ind_tare_info,
  O.ind_off_water_info,
  O.rst_treatment_cd,
  T_RST.device_mode as rst_device_mode,
  O.rst_treatment_name,
  O.rst_kur_cd,
  O.rst_kur_name,
  CASE WHEN M.is_disp = '0' or M.is_del = '1' THEN null ELSE O.rst_bed_cd END as rst_bed_cd,
  CASE WHEN M.is_disp = '0' or M.is_del = '1' THEN 'ベッド未設定' ELSE M.bed_name END as rst_bed_name,
  O.blood_purifier_name,
  O.pull_leave_amount,
  O.rst_cond_info,
  O.rst_tare_info,
  O.rst_off_water_info,
  O.rst_weight_info,
  O.rst_start_date,
  O.rst_end_date,
  O.weight_scale_no,
  O.rst_input_class,
  P.is_wheel_chair
from
  ord_main O
  left outer join pat_main P on O.pat_id = P.pat_id and P.facility_cd = /*facilityCd*/0
  left outer join mst_treatment T_IND on O.ind_treatment_cd = T_IND.treatment_cd AND T_IND.facility_cd = /*facilityCd*/0
  left outer join mst_treatment T_RST on O.rst_treatment_cd = T_RST.treatment_cd AND T_RST.facility_cd = /*facilityCd*/0
  left outer join mst_bed B on O.ind_bed_cd = B.bed_cd AND B.facility_cd = /*facilityCd*/0
  left outer join mst_kur K on O.ind_kur_cd = K.kur_cd AND K.facility_cd = /*facilityCd*/0
  left outer join mst_bed M on O.rst_bed_cd = M.bed_cd AND M.facility_cd = /*facilityCd*/0
where
  O.ord_no = /*ordNo*/0
  and
  O.is_del = '0'
order by
  O.ind_bed_cd, O.ind_treat_start_time
;
