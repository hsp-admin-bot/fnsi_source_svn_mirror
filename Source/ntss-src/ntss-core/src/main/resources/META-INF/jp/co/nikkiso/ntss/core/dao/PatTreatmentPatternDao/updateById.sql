update pat_treatment_pattern 
set
/*%if null != pat.facilityCd*/
  facility_cd = /*pat.facilityCd*/null,
/*%end*/
/*%if null != pat.treatType*/
  treat_type = /*pat.treatType*/null,
/*%end*/
/*%if null != pat.indTreatStartDate*/
  ind_treat_start_date = /*pat.indTreatStartDate*/null,
/*%end*/
/*%if null != pat.indTreatmentCd*/
  ind_treatment_cd = /*pat.indTreatmentCd*/null,
/*%end*/
/*%if null != pat.indKurCd*/
  ind_kur_cd = /*pat.indKurCd*/null,
/*%end*/
/*%if null != pat.treatWeek*/
  treat_week = /*pat.treatWeek*/null,
/*%end*/
/*%if null != pat.indSchInfo*/
  ind_sch_info = jsonb_merge_recursive(ind_sch_info, /*pat.indSchInfo*/null),
/*%end*/
-- /*%if null != pat.indCondInfo*/
--   ind_cond_info = jsonb_merge_recursive(ind_cond_info, /*pat.indCondInfo*/null),
-- /*%end*/
-- /*%if null != pat.indMediInfo*/
--   ind_medi_info = /*pat.indMediInfo*/null,
-- /*%end*/
-- /*%if null != pat.indEquipInfo*/
--   ind_equip_info = /*pat.indEquipInfo*/null,
-- /*%end*/
/*%if null != pat.indCondInfo*/
  ind_cond_info = (
      SELECT jsonb_object_agg(key, value - 'unit' - 'value_name_1' - 'value_name_2')
      FROM jsonb_each(/*pat.indCondInfo*/null) AS t(key, value)
  ),
/*%end*/
/*%if null != pat.indMediInfo*/
  ind_medi_info = (
      SELECT jsonb_agg(elem - 'name' - 'unit' - 'class_cd' - 'class_name' - 'class_type' - 'short_name' - 'timing_name' - 'procedure_name')
      FROM jsonb_array_elements(/*pat.indMediInfo*/null) AS elem
  ),
/*%end*/
/*%if null != pat.indEquipInfo*/
  ind_equip_info = (
      SELECT jsonb_agg(elem - 'name' - 'unit' - 'class_cd' - 'class_name' - 'class_type' - 'short_name')
      FROM jsonb_array_elements(/*pat.indEquipInfo*/null) AS elem
  ),
/*%end*/
/*%if null != pat.indIndCommentInfo*/
  ind_ind_comment_info = /*pat.indIndCommentInfo*/null,
/*%end*/
/*%if null != pat.indTareInfo*/
  ind_tare_info = jsonb_merge_recursive(ind_tare_info, /*pat.indTareInfo*/null),
/*%end*/
/*%if null != pat.indOffWaterInfo*/
  ind_off_water_info = jsonb_merge_recursive(ind_off_water_info, /*pat.indOffWaterInfo*/null),
/*%end*/
/*%if null != pat.indDeviceSetInfo*/
  ind_device_set_info = jsonb_merge_recursive(ind_device_set_info, /*pat.indDeviceSetInfo*/null),
/*%end*/
  up_date = /*pat.upDate*/null
where
  pat_id = /*pat_id*/null
and
  ctl_no = /*ctl_no*/null
;