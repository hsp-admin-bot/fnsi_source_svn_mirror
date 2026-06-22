const ColumnWidthArrs = {
  10: ['sys_facility','mst_wheel_chair','mst_insurance','mst_pat_event_sub_category','mst_pat_event_data_template','mst_medicine_mix','mst_medicine_group', 'mst_spitz', 'mst_trend_graph_template','mst_water_survey_point'],
  11: ['mst_user','mst_machine','mst_infection','mst_course','mst_treatment_set','mst_medicine_set','mst_monitor_graph','mst_vital_graph','mst_exam_set','mst_destination_group','mst_mainte_detail','mst_water_survey_type'],
  12: ['mst_taboo_allergy', 'mst_transport', 'mst_device_edge', 'mst_medicine_support', 'mst_equipment', 'mst_rad_set', 'mst_bbs_kind'],
  13: ['mst_medicine','mst_disease', 'mst_dialyzer', 'mst_equipment_set'],
  14: ['mst_facility','mst_job','mst_implant','mst_medicate_timing','mst_round_type','mst_add_monitor'],
  15: ['mst_room_bed_group'],
  19: ['sys_medicine']
}

const ColumnWidthMap = new Map();

for (const width in ColumnWidthArrs) {
  ColumnWidthArrs[width].forEach(item => {
     ColumnWidthMap.set(item, parseInt(width));
  });
}

export default ColumnWidthMap;