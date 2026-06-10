INSERT INTO "ntss"."sys_data_set"
("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") 
VALUES 
(-2410, '{"collection" : "ind_history","eq" : { "facility_cd" : "@facilityCd" }}', 4, '[{"preview": "〇", "can_calc": "0", "data_code": "treatment_schedule__before", "data_name": "治療予定（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_schedule__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_schedule__after", "data_name": "治療予定（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_schedule__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_method__before", "data_name": "治療方法（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_method__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_method__after", "data_name": "治療方法（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_method__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_date__before", "data_name": "治療日（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_date__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_date__after", "data_name": "治療日（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_date__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "cool__before", "data_name": "クール（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "cool__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "cool__after", "data_name": "クール（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "cool__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_start_date__before", "data_name": "治療開始時刻（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_start_date__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_start_date__after", "data_name": "治療開始時刻（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_start_date__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "bed__before", "data_name": "ベッド（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "bed__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "bed__after", "data_name": "ベッド（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "bed__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_time__before", "data_name": "治療時間（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_time__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_time__after", "data_name": "治療時間（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "treatment_time__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dw__before", "data_name": "DW（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dw__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dw__after", "data_name": "DW（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dw__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "va__before", "data_name": "VA（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "va__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "va__after", "data_name": "VA（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "va__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "target_weight__before", "data_name": "目標体重（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "target_weight__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "target_weight__after", "data_name": "目標体重（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "target_weight__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "water_limit__before", "data_name": "除水量制限（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "water_limit__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "water_limit__after", "data_name": "除水量制限（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "water_limit__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dializer__before", "data_name": "ダイアライザ（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dializer__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dializer__after", "data_name": "ダイアライザ（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dializer__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "adsorption_column__before", "data_name": "吸着カラム（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "adsorption_column__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "adsorption_column__after", "data_name": "吸着カラム（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "adsorption_column__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "one_film__before", "data_name": "1次膜（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "one_film__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "one_film__after", "data_name": "1次膜（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "one_film__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "two_film__before", "data_name": "2次膜（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "two_film__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "two_film__after", "data_name": "2次膜（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "two_film__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_a__before", "data_name": "穿刺針(A針)（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "puncture_needle_a__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_a__after", "data_name": "穿刺針(A針)（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "puncture_needle_a__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_v__before", "data_name": "穿刺針(V針)（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "puncture_needle_v__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_v__after", "data_name": "穿刺針(V針)（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "puncture_needle_v__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_sn__before", "data_name": "穿刺針(SN)（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "puncture_needle_sn__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_sn__after", "data_name": "穿刺針(SN)（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "puncture_needle_sn__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "use_single_needle__before", "data_name": "シングルニードル使用（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "use_single_needle__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "use_single_needle__after", "data_name": "シングルニードル使用（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "use_single_needle__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "blood_circuit__before", "data_name": "血液回路（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "blood_circuit__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "blood_circuit__after", "data_name": "血液回路（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "blood_circuit__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "blood_flow__before", "data_name": "血流量（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "blood_flow__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "blood_flow__after", "data_name": "血流量（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "blood_flow__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate__before", "data_name": "透析液（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dialysate__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate__after", "data_name": "透析液（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dialysate__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate_flow_rate__before", "data_name": "透析液流量（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dialysate_flow_rate__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate_flow_rate__after", "data_name": "透析液流量（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dialysate_flow_rate__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "amount_of_dialysate__before", "data_name": "透析液量（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "amount_of_dialysate__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "amount_of_dialysate__after", "data_name": "透析液量（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "amount_of_dialysate__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate_temperature__before", "data_name": "透析液温度（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dialysate_temperature__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate_temperature__after", "data_name": "透析液温度（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "dialysate_temperature__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement__before", "data_name": "補液（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement__after", "data_name": "補液（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_volume__before", "data_name": "補液量（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement_volume__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_volume__after", "data_name": "補液量（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement_volume__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_selection__before", "data_name": "補液選択（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement_selection__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_selection__after", "data_name": "補液選択（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement_selection__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "number_replacement_fluids_used__before", "data_name": "補液使用数（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "number_replacement_fluids_used__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "number_replacement_fluids_used__after", "data_name": "補液使用数（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "number_replacement_fluids_used__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_temperature__before", "data_name": "補液温度（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement_temperature__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_temperature__after", "data_name": "補液温度（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement_temperature__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_speed__before", "data_name": "補液速度（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement_speed__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_speed__after", "data_name": "補液速度（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "fluid_replacement_speed__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant__before", "data_name": "抗凝固剤（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "anticoagulant__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant__after", "data_name": "抗凝固剤（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "anticoagulant__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_one-shot_amount__before", "data_name": "抗凝固剤ワンショット量（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "anticoagulant_one-shot_amount__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_one-shot_amount__after", "data_name": "抗凝固剤ワンショット量（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "anticoagulant_one-shot_amount__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_duration__before", "data_name": "抗凝固剤持続速度（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "anticoagulant_duration__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_duration__after", "data_name": "抗凝固剤持続速度（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "anticoagulant_duration__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_sustained_total_amount__before", "data_name": "抗凝固剤持続総量（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "anticoagulant_sustained_total_amount__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_sustained_total_amount__after", "data_name": "抗凝固剤持続総量（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "anticoagulant_sustained_total_amount__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_usage_selection__before", "data_name": "IP使用選択（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_usage_selection__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_usage_selection__after", "data_name": "IP使用選択（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_usage_selection__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_start__before", "data_name": "IPスタート（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_start__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_start__after", "data_name": "IPスタート（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_start__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_one-shot_amount__before", "data_name": "IPワンショット量（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_one-shot_amount__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_one-shot_amount__after", "data_name": "IPワンショット量（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_one-shot_amount__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_speed__before", "data_name": "IP速度（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_speed__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_speed__after", "data_name": "IP速度（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_speed__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_speed_max__before", "data_name": "IP速度最大値（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_speed_max__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_speed_max__after", "data_name": "IP速度最大値（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_speed_max__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "automatic_one_shot__before", "data_name": "自動ワンショット（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "automatic_one_shot__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "automatic_one_shot__after", "data_name": "自動ワンショット（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "automatic_one_shot__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_off_automatically__before", "data_name": "IP電源自動切り（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_power_off_automatically__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_off_automatically__after", "data_name": "IP電源自動切り（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_power_off_automatically__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_off_time__before", "data_name": "IP電源自動切り時間（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_power_off_time__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_off_time__after", "data_name": "IP電源自動切り時間（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_power_off_time__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_monitor_off__before", "data_name": "IP電源OKモニタ切り（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_power_monitor_off__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_monitor_off__after", "data_name": "IP電源OKモニタ切り（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_power_monitor_off__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_monitor_off_time__before", "data_name": "IP電源OKモニタ切り時間（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_power_monitor_off_time__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_monitor_off_time__after", "data_name": "IP電源OKモニタ切り時間（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "ip_power_monitor_off_time__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "administered_drug__before", "data_name": "投与薬剤（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "administered_drug__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "administered_drug__after", "data_name": "投与薬剤（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "administered_drug__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "medical_materials__before", "data_name": "医療材料（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "medical_materials__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "medical_materials__after", "data_name": "医療材料（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "medical_materials__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "instructional_comment__before", "data_name": "指示コメント（修正前）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "instructional_comment__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "instructional_comment__after", "data_name": "指示コメント（修正後）", "data_type": "string", "conv_table": [], "data_class": "指示履歴", "field_name": "instructional_comment__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示履歴：指示', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2420, 'WITH ntss_db5_mm AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_mm.occur_date AS occur_date
		,ntss_db5_mm.monitor_data AS monitor_data
		,ntss_db5_mm.up_date AS up_date
	FROM
		ord_main ntss_db5_om
		LEFT JOIN mni_monitor ntss_db5_mm
		ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
	WHERE ntss_db5_mm.facility_cd = @facilityCd
		AND ntss_db5_mm.data_type = ''1''
		AND ntss_db5_mm.is_del = ''0''
)
SELECT
	ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
	,ntss_db5_mst_m.machine_serial AS deviceno --装置番号
	,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
	,'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,''1'' AS moniname1 --モニタ項目名1
	,ntss_db5_mm.monitor_data #>> ''{1}'' AS moniitem1 --モニタ項目値1
	,''2'' AS moniname2 --モニタ項目名2
	,ntss_db5_mm.monitor_data #>> ''{2}'' AS moniitem2 --モニタ項目値2
	,''3'' AS moniname3 --モニタ項目名3
	,ntss_db5_mm.monitor_data #>> ''{3}'' AS moniitem3 --モニタ項目値3
	,''4'' AS moniname4 --モニタ項目名4
	,ntss_db5_mm.monitor_data #>> ''{4}'' AS moniitem4 --モニタ項目値4
	,''5'' AS moniname5 --モニタ項目名5
	,ntss_db5_mm.monitor_data #>> ''{5}'' AS moniitem5 --モニタ項目値5
	,''6'' AS moniname6 --モニタ項目名6
	,ntss_db5_mm.monitor_data #>> ''{6}'' AS moniitem6 --モニタ項目値6
	,''7'' AS moniname7 --モニタ項目名7
	,ntss_db5_mm.monitor_data #>> ''{7}'' AS moniitem7 --モニタ項目値7
	,''8'' AS moniname8 --モニタ項目名8
	,ntss_db5_mm.monitor_data #>> ''{8}'' AS moniitem8 --モニタ項目値8
	,''9'' AS moniname9 --モニタ項目名9
	,ntss_db5_mm.monitor_data #>> ''{9}'' AS moniitem9 --モニタ項目値9
	,''10'' AS moniname10 --モニタ項目名10
	,ntss_db5_mm.monitor_data #>> ''{10}'' AS moniitem10 --モニタ項目値10
	,''11'' AS moniname11 --モニタ項目名11
	,ntss_db5_mm.monitor_data #>> ''{11}'' AS moniitem11 --モニタ項目値11
	,''12'' AS moniname12 --モニタ項目名12
	,ntss_db5_mm.monitor_data #>> ''{12}'' AS moniitem12 --モニタ項目値12
	,''13'' AS moniname13 --モニタ項目名13
	,ntss_db5_mm.monitor_data #>> ''{13}'' AS moniitem13 --モニタ項目値13
	,''14'' AS moniname14 --モニタ項目名14
	,ntss_db5_mm.monitor_data #>> ''{14}'' AS moniitem14 --モニタ項目値14
	,''15'' AS moniname15 --モニタ項目名15
	,ntss_db5_mm.monitor_data #>> ''{15}'' AS moniitem15 --モニタ項目値15
	,''16'' AS moniname16 --モニタ項目名16
	,ntss_db5_mm.monitor_data #>> ''{16}'' AS moniitem16 --モニタ項目値16
	,''17'' AS moniname17 --モニタ項目名17
	,ntss_db5_mm.monitor_data #>> ''{17}'' AS moniitem17 --モニタ項目値17
	,''18'' AS moniname18 --モニタ項目名18
	,ntss_db5_mm.monitor_data #>> ''{18}'' AS moniitem18 --モニタ項目値18
	,''19'' AS moniname19 --モニタ項目名19
	,ntss_db5_mm.monitor_data #>> ''{19}'' AS moniitem19 --モニタ項目値19
	,''20'' AS moniname20 --モニタ項目名20
	,ntss_db5_mm.monitor_data #>> ''{20}'' AS moniitem20 --モニタ項目値20
	,''21'' AS moniname21 --モニタ項目名21
	,ntss_db5_mm.monitor_data #>> ''{21}'' AS moniitem21 --モニタ項目値21
	,''22'' AS moniname22 --モニタ項目名22
	,ntss_db5_mm.monitor_data #>> ''{22}'' AS moniitem22 --モニタ項目値22
	,''23'' AS moniname23 --モニタ項目名23
	,ntss_db5_mm.monitor_data #>> ''{23}'' AS moniitem23 --モニタ項目値23
	,''24'' AS moniname24 --モニタ項目名24
	,ntss_db5_mm.monitor_data #>> ''{24}'' AS moniitem24 --モニタ項目値24
	,''25'' AS moniname25 --モニタ項目名25
	,ntss_db5_mm.monitor_data #>> ''{25}'' AS moniitem25 --モニタ項目値25
	,''26'' AS moniname26 --モニタ項目名26
	,ntss_db5_mm.monitor_data #>> ''{26}'' AS moniitem26 --モニタ項目値26
	,''27'' AS moniname27 --モニタ項目名27
	,ntss_db5_mm.monitor_data #>> ''{27}'' AS moniitem27 --モニタ項目値27
	,''28'' AS moniname28 --モニタ項目名28
	,ntss_db5_mm.monitor_data #>> ''{28}'' AS moniitem28 --モニタ項目値28
	,''29'' AS moniname29 --モニタ項目名29
	,ntss_db5_mm.monitor_data #>> ''{29}'' AS moniitem29 --モニタ項目値29
	,''30'' AS moniname30 --モニタ項目名30
	,ntss_db5_mm.monitor_data #>> ''{30}'' AS moniitem30 --モニタ項目値30
	,''31'' AS moniname31 --モニタ項目名31
	,ntss_db5_mm.monitor_data #>> ''{31}'' AS moniitem31 --モニタ項目値31
	,''32'' AS moniname32 --モニタ項目名32
	,ntss_db5_mm.monitor_data #>> ''{32}'' AS moniitem32 --モニタ項目値32
	,''33'' AS moniname33 --モニタ項目名33
	,ntss_db5_mm.monitor_data #>> ''{33}'' AS moniitem33 --モニタ項目値33
	,''34'' AS moniname34 --モニタ項目名34
	,ntss_db5_mm.monitor_data #>> ''{34}'' AS moniitem34 --モニタ項目値34
	,''35'' AS moniname35 --モニタ項目名35
	,ntss_db5_mm.monitor_data #>> ''{35}'' AS moniitem35 --モニタ項目値35
	,''36'' AS moniname36 --モニタ項目名36
	,ntss_db5_mm.monitor_data #>> ''{36}'' AS moniitem36 --モニタ項目値36
	,''37'' AS moniname37 --モニタ項目名37
	,ntss_db5_mm.monitor_data #>> ''{37}'' AS moniitem37 --モニタ項目値37
	,''38'' AS moniname38 --モニタ項目名38
	,ntss_db5_mm.monitor_data #>> ''{38}'' AS moniitem38 --モニタ項目値38
	,''39'' AS moniname39 --モニタ項目名39
	,ntss_db5_mm.monitor_data #>> ''{39}'' AS moniitem39 --モニタ項目値39
	,''40'' AS moniname40 --モニタ項目名40
	,ntss_db5_mm.monitor_data #>> ''{40}'' AS moniitem40 --モニタ項目値40
	,''41'' AS moniname41 --モニタ項目名41
	,ntss_db5_mm.monitor_data #>> ''{41}'' AS moniitem41 --モニタ項目値41
	,''42'' AS moniname42 --モニタ項目名42
	,ntss_db5_mm.monitor_data #>> ''{42}'' AS moniitem42 --モニタ項目値42
	,''43'' AS moniname43 --モニタ項目名43
	,ntss_db5_mm.monitor_data #>> ''{43}'' AS moniitem43 --モニタ項目値43
	,''44'' AS moniname44 --モニタ項目名44
	,ntss_db5_mm.monitor_data #>> ''{44}'' AS moniitem44 --モニタ項目値44
	,''45'' AS moniname45 --モニタ項目名45
	,ntss_db5_mm.monitor_data #>> ''{45}'' AS moniitem45 --モニタ項目値45
	,''46'' AS moniname46 --モニタ項目名46
	,ntss_db5_mm.monitor_data #>> ''{46}'' AS moniitem46 --モニタ項目値46
	,''47'' AS moniname47 --モニタ項目名47
	,ntss_db5_mm.monitor_data #>> ''{47}'' AS moniitem47 --モニタ項目値47
	,''48'' AS moniname48 --モニタ項目名48
	,ntss_db5_mm.monitor_data #>> ''{48}'' AS moniitem48 --モニタ項目値48
	,''49'' AS moniname49 --モニタ項目名49
	,ntss_db5_mm.monitor_data #>> ''{49}'' AS moniitem49 --モニタ項目値49
	,''50'' AS moniname50 --モニタ項目名50
	,ntss_db5_mm.monitor_data #>> ''{50}'' AS moniitem50 --モニタ項目値50
	,''51'' AS moniname51 --モニタ項目名51
	,ntss_db5_mm.monitor_data #>> ''{51}'' AS moniitem51 --モニタ項目値51
	,''52'' AS moniname52 --モニタ項目名52
	,ntss_db5_mm.monitor_data #>> ''{52}'' AS moniitem52 --モニタ項目値52
	,''53'' AS moniname53 --モニタ項目名53
	,ntss_db5_mm.monitor_data #>> ''{53}'' AS moniitem53 --モニタ項目値53
	,''54'' AS moniname54 --モニタ項目名54
	,ntss_db5_mm.monitor_data #>> ''{54}'' AS moniitem54 --モニタ項目値54
	,''55'' AS moniname55 --モニタ項目名55
	,ntss_db5_mm.monitor_data #>> ''{55}'' AS moniitem55 --モニタ項目値55
	,''56'' AS moniname56 --モニタ項目名56
	,ntss_db5_mm.monitor_data #>> ''{56}'' AS moniitem56 --モニタ項目値56
	,''57'' AS moniname57 --モニタ項目名57
	,ntss_db5_mm.monitor_data #>> ''{57}'' AS moniitem57 --モニタ項目値57
	,''58'' AS moniname58 --モニタ項目名58
	,ntss_db5_mm.monitor_data #>> ''{58}'' AS moniitem58 --モニタ項目値58
	,''59'' AS moniname59 --モニタ項目名59
	,ntss_db5_mm.monitor_data #>> ''{59}'' AS moniitem59 --モニタ項目値59
	,''60'' AS moniname60 --モニタ項目名60
	,ntss_db5_mm.monitor_data #>> ''{60}'' AS moniitem60 --モニタ項目値60
	,''61'' AS moniname61 --モニタ項目名61
	,ntss_db5_mm.monitor_data #>> ''{61}'' AS moniitem61 --モニタ項目値61
	,''62'' AS moniname62 --モニタ項目名62
	,ntss_db5_mm.monitor_data #>> ''{62}'' AS moniitem62 --モニタ項目値62
	,''63'' AS moniname63 --モニタ項目名63
	,ntss_db5_mm.monitor_data #>> ''{63}'' AS moniitem63 --モニタ項目値63
	,''64'' AS moniname64 --モニタ項目名64
	,ntss_db5_mm.monitor_data #>> ''{64}'' AS moniitem64 --モニタ項目値64
	,''65'' AS moniname65 --モニタ項目名65
	,ntss_db5_mm.monitor_data #>> ''{65}'' AS moniitem65 --モニタ項目値65
	,''66'' AS moniname66 --モニタ項目名66
	,ntss_db5_mm.monitor_data #>> ''{66}'' AS moniitem66 --モニタ項目値66
	,''67'' AS moniname67 --モニタ項目名67
	,ntss_db5_mm.monitor_data #>> ''{67}'' AS moniitem67 --モニタ項目値67
	,''68'' AS moniname68 --モニタ項目名68
	,ntss_db5_mm.monitor_data #>> ''{68}'' AS moniitem68 --モニタ項目値68
	,''69'' AS moniname69 --モニタ項目名69
	,ntss_db5_mm.monitor_data #>> ''{69}'' AS moniitem69 --モニタ項目値69
	,''70'' AS moniname70 --モニタ項目名70
	,ntss_db5_mm.monitor_data #>> ''{70}'' AS moniitem70 --モニタ項目値70
	,''71'' AS moniname71 --モニタ項目名71
	,ntss_db5_mm.monitor_data #>> ''{71}'' AS moniitem71 --モニタ項目値71
	,''72'' AS moniname72 --モニタ項目名72
	,ntss_db5_mm.monitor_data #>> ''{72}'' AS moniitem72 --モニタ項目値72
	,''73'' AS moniname73 --モニタ項目名73
	,ntss_db5_mm.monitor_data #>> ''{73}'' AS moniitem73 --モニタ項目値73
	,''74'' AS moniname74 --モニタ項目名74
	,ntss_db5_mm.monitor_data #>> ''{74}'' AS moniitem74 --モニタ項目値74
	,''75'' AS moniname75 --モニタ項目名75
	,ntss_db5_mm.monitor_data #>> ''{75}'' AS moniitem75 --モニタ項目値75
	,''76'' AS moniname76 --モニタ項目名76
	,ntss_db5_mm.monitor_data #>> ''{76}'' AS moniitem76 --モニタ項目値76
	,''77'' AS moniname77 --モニタ項目名77
	,ntss_db5_mm.monitor_data #>> ''{77}'' AS moniitem77 --モニタ項目値77
	,''78'' AS moniname78 --モニタ項目名78
	,ntss_db5_mm.monitor_data #>> ''{78}'' AS moniitem78 --モニタ項目値78
	,''79'' AS moniname79 --モニタ項目名79
	,ntss_db5_mm.monitor_data #>> ''{79}'' AS moniitem79 --モニタ項目値79
	,''80'' AS moniname80 --モニタ項目名80
	,ntss_db5_mm.monitor_data #>> ''{80}'' AS moniitem80 --モニタ項目値80
	,''81'' AS moniname81 --モニタ項目名81
	,ntss_db5_mm.monitor_data #>> ''{81}'' AS moniitem81 --モニタ項目値81
	,''82'' AS moniname82 --モニタ項目名82
	,ntss_db5_mm.monitor_data #>> ''{82}'' AS moniitem82 --モニタ項目値82
	,''83'' AS moniname83 --モニタ項目名83
	,ntss_db5_mm.monitor_data #>> ''{83}'' AS moniitem83 --モニタ項目値83
	,''84'' AS moniname84 --モニタ項目名84
	,ntss_db5_mm.monitor_data #>> ''{84}'' AS moniitem84 --モニタ項目値84
	,''85'' AS moniname85 --モニタ項目名85
	,ntss_db5_mm.monitor_data #>> ''{85}'' AS moniitem85 --モニタ項目値85
	,''86'' AS moniname86 --モニタ項目名86
	,ntss_db5_mm.monitor_data #>> ''{86}'' AS moniitem86 --モニタ項目値86
	,''87'' AS moniname87 --モニタ項目名87
	,ntss_db5_mm.monitor_data #>> ''{87}'' AS moniitem87 --モニタ項目値87
	,''88'' AS moniname88 --モニタ項目名88
	,ntss_db5_mm.monitor_data #>> ''{88}'' AS moniitem88 --モニタ項目値88
	,''89'' AS moniname89 --モニタ項目名89
	,ntss_db5_mm.monitor_data #>> ''{89}'' AS moniitem89 --モニタ項目値89
	,''90'' AS moniname90 --モニタ項目名90
	,ntss_db5_mm.monitor_data #>> ''{90}'' AS moniitem90 --モニタ項目値90
	,''91'' AS moniname91 --モニタ項目名91
	,ntss_db5_mm.monitor_data #>> ''{91}'' AS moniitem91 --モニタ項目値91
	,''92'' AS moniname92 --モニタ項目名92
	,ntss_db5_mm.monitor_data #>> ''{92}'' AS moniitem92 --モニタ項目値92
	,''93'' AS moniname93 --モニタ項目名93
	,ntss_db5_mm.monitor_data #>> ''{93}'' AS moniitem93 --モニタ項目値93
	,''94'' AS moniname94 --モニタ項目名94
	,ntss_db5_mm.monitor_data #>> ''{94}'' AS moniitem94 --モニタ項目値94
	,''95'' AS moniname95 --モニタ項目名95
	,ntss_db5_mm.monitor_data #>> ''{95}'' AS moniitem95 --モニタ項目値95
	,''96'' AS moniname96 --モニタ項目名96
	,ntss_db5_mm.monitor_data #>> ''{96}'' AS moniitem96 --モニタ項目値96
	,''97'' AS moniname97 --モニタ項目名97
	,ntss_db5_mm.monitor_data #>> ''{97}'' AS moniitem97 --モニタ項目値97
	,''98'' AS moniname98 --モニタ項目名98
	,ntss_db5_mm.monitor_data #>> ''{98}'' AS moniitem98 --モニタ項目値98
	,''99'' AS moniname99 --モニタ項目名99
	,ntss_db5_mm.monitor_data #>> ''{99}'' AS moniitem99 --モニタ項目値99
	,''100'' AS moniname100 --モニタ項目名100
	,ntss_db5_mm.monitor_data #>> ''{100}'' AS moniitem100 --モニタ項目値100
	,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --発生日時
FROM
	ord_main ntss_db5_om
	LEFT JOIN mst_bed ntss_db5_mst_b
	ON ntss_db5_mst_b.bed_cd = ntss_db5_om.rst_bed_cd
	LEFT JOIN mst_machine ntss_db5_mst_m
	ON cast(ntss_db5_mst_m.machine_type_cd AS integer) = ntss_db5_om.rst_machine_no
	INNER JOIN ntss_db5_mm
	ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
	
	INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2440, 'WITH ntss_db5_mst_mr1 AS (
	SELECT
		ntss_db5_mst_mr.event_reg_date AS event_reg_date
		,ntss_db5_mst_m.machine_serial AS machine_serial
	FROM
		mst_machine ntss_db5_mst_m
		LEFT JOIN mnt_motion_record ntss_db5_mst_mr
		ON ntss_db5_mst_mr.machine_serial = ntss_db5_mst_m.machine_serial
	WHERE ntss_db5_mst_m.facility_cd = @facilityCd
		AND ntss_db5_mst_mr.test_type = ''1''
		AND ntss_db5_mst_mr.contents #>> ''{47}'' IS NOT NULL
),
ntss_db5_mst_mr2 AS (
	SELECT
		ntss_db5_mst_mr.contents #>> ''{47}'' AS contents_47
		,ntss_db5_mst_mr.contents #>> ''{43}'' AS contents_43
		,ntss_db5_mst_mr.contents #>> ''{44}'' AS contents_44
		,ntss_db5_mst_mr.contents #>> ''{48}'' AS contents_48
		,ntss_db5_mst_mr.contents #>> ''{46}'' AS contents_46
		,ntss_db5_mst_mr.contents #>> ''{45}'' AS contents_45
		,ntss_db5_mst_mr.contents #>> ''{49}'' AS contents_49
		,ntss_db5_mst_m.machine_serial AS machine_serial
	FROM
		mst_machine ntss_db5_mst_m
		LEFT JOIN mnt_motion_record ntss_db5_mst_mr
		ON ntss_db5_mst_mr.machine_serial = ntss_db5_mst_m.machine_serial
	WHERE ntss_db5_mst_m.facility_cd = @facilityCd
		AND ntss_db5_mst_mr.test_type = ''1''
)
SELECT
	ntss_db5_mst_m.machine_no AS deviceno --装置番号
	,ntss_db5_mst_m.machine_name AS devicename --装置名称
	,ntss_db5_mst_m.machine_serial AS deviceserial --製造番号
	,to_char(ntss_db5_mst_mr1.event_reg_date, ''YYYYMMDD'') AS meintedate --測定日付
	,to_char(ntss_db5_mst_mr1.event_reg_date, ''hh24mi'') AS meintetime --測定時刻
	,ntss_db5_mst_mr2.contents_47 AS meinteresult --配管自己診断結果
	,ntss_db5_mst_mr2.contents_47 AS meintegen --減圧テスト
	,ntss_db5_mst_mr2.contents_43 AS meintemore --配管系漏れ（陰圧)
	,ntss_db5_mst_mr2.contents_44 AS meinteymore --配管系漏れ（陽圧）
	,ntss_db5_mst_mr2.contents_48 AS meintejyo --除水テスト
	,ntss_db5_mst_mr2.contents_46 AS meintebara --バランステスト
	,ntss_db5_mst_mr2.contents_45 AS meinteetcf --ＣＦフィルタ漏れ
	,ntss_db5_mst_mr2.contents_49 AS meinteetcf2 --ＣＦ２フィルタ漏れ
FROM
	mst_machine ntss_db5_mst_m
	LEFT JOIN mnt_motion_record ntss_db5_mst_mr
	ON ntss_db5_mst_mr.machine_serial = ntss_db5_mst_m.machine_serial
	LEFT JOIN ntss_db5_mst_mr1
	ON ntss_db5_mst_mr1.machine_serial = ntss_db5_mst_m.machine_serial
	LEFT JOIN ntss_db5_mst_mr2
	ON ntss_db5_mst_mr2.machine_serial = ntss_db5_mst_m.machine_serial
WHERE ntss_db5_mst_m.is_del = ''0''
	AND ntss_db5_mst_m.facility_cd = @facilityCd
    AND ntss_db5_mst_m.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
    AND to_date( @toDate , ''YYYYMMDDHH24MISS'' )', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2430, 'WITH ntss_db5_mm AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_mm.occur_date AS occur_date
		,ntss_db5_mm.monitor_data AS monitor_data
		,ntss_db5_mm.up_date AS up_date
	FROM
		ord_main ntss_db5_om
		LEFT JOIN mni_monitor ntss_db5_mm
		ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
	WHERE ntss_db5_mm.facility_cd = @facilityCd
		AND ntss_db5_mm.data_type = ''1''
		AND ntss_db5_mm.is_del = ''0''
		AND cast(ntss_db5_om.rst_dialysis_state AS integer) > 0
)
SELECT
	ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
	,ntss_db5_mst_m.machine_serial AS deviceno --装置番号
	,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
	,'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,''1'' AS moniname1 --モニタ項目名1
	,ntss_db5_mm.monitor_data #>> ''{1}'' AS moniitem1 --モニタ項目値1
	,''2'' AS moniname2 --モニタ項目名2
	,ntss_db5_mm.monitor_data #>> ''{2}'' AS moniitem2 --モニタ項目値2
	,''3'' AS moniname3 --モニタ項目名3
	,ntss_db5_mm.monitor_data #>> ''{3}'' AS moniitem3 --モニタ項目値3
	,''4'' AS moniname4 --モニタ項目名4
	,ntss_db5_mm.monitor_data #>> ''{4}'' AS moniitem4 --モニタ項目値4
	,''5'' AS moniname5 --モニタ項目名5
	,ntss_db5_mm.monitor_data #>> ''{5}'' AS moniitem5 --モニタ項目値5
	,''6'' AS moniname6 --モニタ項目名6
	,ntss_db5_mm.monitor_data #>> ''{6}'' AS moniitem6 --モニタ項目値6
	,''7'' AS moniname7 --モニタ項目名7
	,ntss_db5_mm.monitor_data #>> ''{7}'' AS moniitem7 --モニタ項目値7
	,''8'' AS moniname8 --モニタ項目名8
	,ntss_db5_mm.monitor_data #>> ''{8}'' AS moniitem8 --モニタ項目値8
	,''9'' AS moniname9 --モニタ項目名9
	,ntss_db5_mm.monitor_data #>> ''{9}'' AS moniitem9 --モニタ項目値9
	,''10'' AS moniname10 --モニタ項目名10
	,ntss_db5_mm.monitor_data #>> ''{10}'' AS moniitem10 --モニタ項目値10
	,''11'' AS moniname11 --モニタ項目名11
	,ntss_db5_mm.monitor_data #>> ''{11}'' AS moniitem11 --モニタ項目値11
	,''12'' AS moniname12 --モニタ項目名12
	,ntss_db5_mm.monitor_data #>> ''{12}'' AS moniitem12 --モニタ項目値12
	,''13'' AS moniname13 --モニタ項目名13
	,ntss_db5_mm.monitor_data #>> ''{13}'' AS moniitem13 --モニタ項目値13
	,''14'' AS moniname14 --モニタ項目名14
	,ntss_db5_mm.monitor_data #>> ''{14}'' AS moniitem14 --モニタ項目値14
	,''15'' AS moniname15 --モニタ項目名15
	,ntss_db5_mm.monitor_data #>> ''{15}'' AS moniitem15 --モニタ項目値15
	,''16'' AS moniname16 --モニタ項目名16
	,ntss_db5_mm.monitor_data #>> ''{16}'' AS moniitem16 --モニタ項目値16
	,''17'' AS moniname17 --モニタ項目名17
	,ntss_db5_mm.monitor_data #>> ''{17}'' AS moniitem17 --モニタ項目値17
	,''18'' AS moniname18 --モニタ項目名18
	,ntss_db5_mm.monitor_data #>> ''{18}'' AS moniitem18 --モニタ項目値18
	,''19'' AS moniname19 --モニタ項目名19
	,ntss_db5_mm.monitor_data #>> ''{19}'' AS moniitem19 --モニタ項目値19
	,''20'' AS moniname20 --モニタ項目名20
	,ntss_db5_mm.monitor_data #>> ''{20}'' AS moniitem20 --モニタ項目値20
	,''21'' AS moniname21 --モニタ項目名21
	,ntss_db5_mm.monitor_data #>> ''{21}'' AS moniitem21 --モニタ項目値21
	,''22'' AS moniname22 --モニタ項目名22
	,ntss_db5_mm.monitor_data #>> ''{22}'' AS moniitem22 --モニタ項目値22
	,''23'' AS moniname23 --モニタ項目名23
	,ntss_db5_mm.monitor_data #>> ''{23}'' AS moniitem23 --モニタ項目値23
	,''24'' AS moniname24 --モニタ項目名24
	,ntss_db5_mm.monitor_data #>> ''{24}'' AS moniitem24 --モニタ項目値24
	,''25'' AS moniname25 --モニタ項目名25
	,ntss_db5_mm.monitor_data #>> ''{25}'' AS moniitem25 --モニタ項目値25
	,''26'' AS moniname26 --モニタ項目名26
	,ntss_db5_mm.monitor_data #>> ''{26}'' AS moniitem26 --モニタ項目値26
	,''27'' AS moniname27 --モニタ項目名27
	,ntss_db5_mm.monitor_data #>> ''{27}'' AS moniitem27 --モニタ項目値27
	,''28'' AS moniname28 --モニタ項目名28
	,ntss_db5_mm.monitor_data #>> ''{28}'' AS moniitem28 --モニタ項目値28
	,''29'' AS moniname29 --モニタ項目名29
	,ntss_db5_mm.monitor_data #>> ''{29}'' AS moniitem29 --モニタ項目値29
	,''30'' AS moniname30 --モニタ項目名30
	,ntss_db5_mm.monitor_data #>> ''{30}'' AS moniitem30 --モニタ項目値30
	,''31'' AS moniname31 --モニタ項目名31
	,ntss_db5_mm.monitor_data #>> ''{31}'' AS moniitem31 --モニタ項目値31
	,''32'' AS moniname32 --モニタ項目名32
	,ntss_db5_mm.monitor_data #>> ''{32}'' AS moniitem32 --モニタ項目値32
	,''33'' AS moniname33 --モニタ項目名33
	,ntss_db5_mm.monitor_data #>> ''{33}'' AS moniitem33 --モニタ項目値33
	,''34'' AS moniname34 --モニタ項目名34
	,ntss_db5_mm.monitor_data #>> ''{34}'' AS moniitem34 --モニタ項目値34
	,''35'' AS moniname35 --モニタ項目名35
	,ntss_db5_mm.monitor_data #>> ''{35}'' AS moniitem35 --モニタ項目値35
	,''36'' AS moniname36 --モニタ項目名36
	,ntss_db5_mm.monitor_data #>> ''{36}'' AS moniitem36 --モニタ項目値36
	,''37'' AS moniname37 --モニタ項目名37
	,ntss_db5_mm.monitor_data #>> ''{37}'' AS moniitem37 --モニタ項目値37
	,''38'' AS moniname38 --モニタ項目名38
	,ntss_db5_mm.monitor_data #>> ''{38}'' AS moniitem38 --モニタ項目値38
	,''39'' AS moniname39 --モニタ項目名39
	,ntss_db5_mm.monitor_data #>> ''{39}'' AS moniitem39 --モニタ項目値39
	,''40'' AS moniname40 --モニタ項目名40
	,ntss_db5_mm.monitor_data #>> ''{40}'' AS moniitem40 --モニタ項目値40
	,''41'' AS moniname41 --モニタ項目名41
	,ntss_db5_mm.monitor_data #>> ''{41}'' AS moniitem41 --モニタ項目値41
	,''42'' AS moniname42 --モニタ項目名42
	,ntss_db5_mm.monitor_data #>> ''{42}'' AS moniitem42 --モニタ項目値42
	,''43'' AS moniname43 --モニタ項目名43
	,ntss_db5_mm.monitor_data #>> ''{43}'' AS moniitem43 --モニタ項目値43
	,''44'' AS moniname44 --モニタ項目名44
	,ntss_db5_mm.monitor_data #>> ''{44}'' AS moniitem44 --モニタ項目値44
	,''45'' AS moniname45 --モニタ項目名45
	,ntss_db5_mm.monitor_data #>> ''{45}'' AS moniitem45 --モニタ項目値45
	,''46'' AS moniname46 --モニタ項目名46
	,ntss_db5_mm.monitor_data #>> ''{46}'' AS moniitem46 --モニタ項目値46
	,''47'' AS moniname47 --モニタ項目名47
	,ntss_db5_mm.monitor_data #>> ''{47}'' AS moniitem47 --モニタ項目値47
	,''48'' AS moniname48 --モニタ項目名48
	,ntss_db5_mm.monitor_data #>> ''{48}'' AS moniitem48 --モニタ項目値48
	,''49'' AS moniname49 --モニタ項目名49
	,ntss_db5_mm.monitor_data #>> ''{49}'' AS moniitem49 --モニタ項目値49
	,''50'' AS moniname50 --モニタ項目名50
	,ntss_db5_mm.monitor_data #>> ''{50}'' AS moniitem50 --モニタ項目値50
	,''51'' AS moniname51 --モニタ項目名51
	,ntss_db5_mm.monitor_data #>> ''{51}'' AS moniitem51 --モニタ項目値51
	,''52'' AS moniname52 --モニタ項目名52
	,ntss_db5_mm.monitor_data #>> ''{52}'' AS moniitem52 --モニタ項目値52
	,''53'' AS moniname53 --モニタ項目名53
	,ntss_db5_mm.monitor_data #>> ''{53}'' AS moniitem53 --モニタ項目値53
	,''54'' AS moniname54 --モニタ項目名54
	,ntss_db5_mm.monitor_data #>> ''{54}'' AS moniitem54 --モニタ項目値54
	,''55'' AS moniname55 --モニタ項目名55
	,ntss_db5_mm.monitor_data #>> ''{55}'' AS moniitem55 --モニタ項目値55
	,''56'' AS moniname56 --モニタ項目名56
	,ntss_db5_mm.monitor_data #>> ''{56}'' AS moniitem56 --モニタ項目値56
	,''57'' AS moniname57 --モニタ項目名57
	,ntss_db5_mm.monitor_data #>> ''{57}'' AS moniitem57 --モニタ項目値57
	,''58'' AS moniname58 --モニタ項目名58
	,ntss_db5_mm.monitor_data #>> ''{58}'' AS moniitem58 --モニタ項目値58
	,''59'' AS moniname59 --モニタ項目名59
	,ntss_db5_mm.monitor_data #>> ''{59}'' AS moniitem59 --モニタ項目値59
	,''60'' AS moniname60 --モニタ項目名60
	,ntss_db5_mm.monitor_data #>> ''{60}'' AS moniitem60 --モニタ項目値60
	,''61'' AS moniname61 --モニタ項目名61
	,ntss_db5_mm.monitor_data #>> ''{61}'' AS moniitem61 --モニタ項目値61
	,''62'' AS moniname62 --モニタ項目名62
	,ntss_db5_mm.monitor_data #>> ''{62}'' AS moniitem62 --モニタ項目値62
	,''63'' AS moniname63 --モニタ項目名63
	,ntss_db5_mm.monitor_data #>> ''{63}'' AS moniitem63 --モニタ項目値63
	,''64'' AS moniname64 --モニタ項目名64
	,ntss_db5_mm.monitor_data #>> ''{64}'' AS moniitem64 --モニタ項目値64
	,''65'' AS moniname65 --モニタ項目名65
	,ntss_db5_mm.monitor_data #>> ''{65}'' AS moniitem65 --モニタ項目値65
	,''66'' AS moniname66 --モニタ項目名66
	,ntss_db5_mm.monitor_data #>> ''{66}'' AS moniitem66 --モニタ項目値66
	,''67'' AS moniname67 --モニタ項目名67
	,ntss_db5_mm.monitor_data #>> ''{67}'' AS moniitem67 --モニタ項目値67
	,''68'' AS moniname68 --モニタ項目名68
	,ntss_db5_mm.monitor_data #>> ''{68}'' AS moniitem68 --モニタ項目値68
	,''69'' AS moniname69 --モニタ項目名69
	,ntss_db5_mm.monitor_data #>> ''{69}'' AS moniitem69 --モニタ項目値69
	,''70'' AS moniname70 --モニタ項目名70
	,ntss_db5_mm.monitor_data #>> ''{70}'' AS moniitem70 --モニタ項目値70
	,''71'' AS moniname71 --モニタ項目名71
	,ntss_db5_mm.monitor_data #>> ''{71}'' AS moniitem71 --モニタ項目値71
	,''72'' AS moniname72 --モニタ項目名72
	,ntss_db5_mm.monitor_data #>> ''{72}'' AS moniitem72 --モニタ項目値72
	,''73'' AS moniname73 --モニタ項目名73
	,ntss_db5_mm.monitor_data #>> ''{73}'' AS moniitem73 --モニタ項目値73
	,''74'' AS moniname74 --モニタ項目名74
	,ntss_db5_mm.monitor_data #>> ''{74}'' AS moniitem74 --モニタ項目値74
	,''75'' AS moniname75 --モニタ項目名75
	,ntss_db5_mm.monitor_data #>> ''{75}'' AS moniitem75 --モニタ項目値75
	,''76'' AS moniname76 --モニタ項目名76
	,ntss_db5_mm.monitor_data #>> ''{76}'' AS moniitem76 --モニタ項目値76
	,''77'' AS moniname77 --モニタ項目名77
	,ntss_db5_mm.monitor_data #>> ''{77}'' AS moniitem77 --モニタ項目値77
	,''78'' AS moniname78 --モニタ項目名78
	,ntss_db5_mm.monitor_data #>> ''{78}'' AS moniitem78 --モニタ項目値78
	,''79'' AS moniname79 --モニタ項目名79
	,ntss_db5_mm.monitor_data #>> ''{79}'' AS moniitem79 --モニタ項目値79
	,''80'' AS moniname80 --モニタ項目名80
	,ntss_db5_mm.monitor_data #>> ''{80}'' AS moniitem80 --モニタ項目値80
	,''81'' AS moniname81 --モニタ項目名81
	,ntss_db5_mm.monitor_data #>> ''{81}'' AS moniitem81 --モニタ項目値81
	,''82'' AS moniname82 --モニタ項目名82
	,ntss_db5_mm.monitor_data #>> ''{82}'' AS moniitem82 --モニタ項目値82
	,''83'' AS moniname83 --モニタ項目名83
	,ntss_db5_mm.monitor_data #>> ''{83}'' AS moniitem83 --モニタ項目値83
	,''84'' AS moniname84 --モニタ項目名84
	,ntss_db5_mm.monitor_data #>> ''{84}'' AS moniitem84 --モニタ項目値84
	,''85'' AS moniname85 --モニタ項目名85
	,ntss_db5_mm.monitor_data #>> ''{85}'' AS moniitem85 --モニタ項目値85
	,''86'' AS moniname86 --モニタ項目名86
	,ntss_db5_mm.monitor_data #>> ''{86}'' AS moniitem86 --モニタ項目値86
	,''87'' AS moniname87 --モニタ項目名87
	,ntss_db5_mm.monitor_data #>> ''{87}'' AS moniitem87 --モニタ項目値87
	,''88'' AS moniname88 --モニタ項目名88
	,ntss_db5_mm.monitor_data #>> ''{88}'' AS moniitem88 --モニタ項目値88
	,''89'' AS moniname89 --モニタ項目名89
	,ntss_db5_mm.monitor_data #>> ''{89}'' AS moniitem89 --モニタ項目値89
	,''90'' AS moniname90 --モニタ項目名90
	,ntss_db5_mm.monitor_data #>> ''{90}'' AS moniitem90 --モニタ項目値90
	,''91'' AS moniname91 --モニタ項目名91
	,ntss_db5_mm.monitor_data #>> ''{91}'' AS moniitem91 --モニタ項目値91
	,''92'' AS moniname92 --モニタ項目名92
	,ntss_db5_mm.monitor_data #>> ''{92}'' AS moniitem92 --モニタ項目値92
	,''93'' AS moniname93 --モニタ項目名93
	,ntss_db5_mm.monitor_data #>> ''{93}'' AS moniitem93 --モニタ項目値93
	,''94'' AS moniname94 --モニタ項目名94
	,ntss_db5_mm.monitor_data #>> ''{94}'' AS moniitem94 --モニタ項目値94
	,''95'' AS moniname95 --モニタ項目名95
	,ntss_db5_mm.monitor_data #>> ''{95}'' AS moniitem95 --モニタ項目値95
	,''96'' AS moniname96 --モニタ項目名96
	,ntss_db5_mm.monitor_data #>> ''{96}'' AS moniitem96 --モニタ項目値96
	,''97'' AS moniname97 --モニタ項目名97
	,ntss_db5_mm.monitor_data #>> ''{97}'' AS moniitem97 --モニタ項目値97
	,''98'' AS moniname98 --モニタ項目名98
	,ntss_db5_mm.monitor_data #>> ''{98}'' AS moniitem98 --モニタ項目値98
	,''99'' AS moniname99 --モニタ項目名99
	,ntss_db5_mm.monitor_data #>> ''{99}'' AS moniitem99 --モニタ項目値99
	,''100'' AS moniname100 --モニタ項目名100
	,ntss_db5_mm.monitor_data #>> ''{100}'' AS moniitem100 --モニタ項目値100
	,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --発生日時
FROM
	ord_main ntss_db5_om
	LEFT JOIN mst_bed ntss_db5_mst_b
	ON ntss_db5_mst_b.bed_cd = ntss_db5_om.rst_bed_cd
	LEFT JOIN mst_machine ntss_db5_mst_m
	ON cast(ntss_db5_mst_m.machine_type_cd AS integer) = ntss_db5_om.rst_machine_no
	INNER JOIN ntss_db5_mm
	ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
	
	INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2450, 'WITH ntss_db5_pm_dsi AS (
	SELECT
		ntss_db5_pm.pat_id AS pat_id
		,value_3.key AS value_2
		,value_3.value AS value_4
	FROM
		pat_main ntss_db5_pm
		JOIN json_each_text(ntss_db5_pm.device_set_info ::json) AS keysandvalue ON TRUE
		JOIN json_each_text((keysandvalue.value::json #>> ''{dev,A}'')::json) AS value_3 ON TRUE
	WHERE ntss_db5_pm.is_del = ''0''
		AND ntss_db5_pm.facility_cd = @facilityCd
		AND ntss_db5_pm.device_set_info IS NOT NULL
		AND ntss_db5_pm.device_set_info <> ''[]''
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pm.pat_id AS patid
	,'''' AS name
	,ntss_db5_pm_dsi.value_2
	,CASE
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0100'' THEN ''1''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0101'' THEN ''2''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0102'' THEN ''3''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0103'' THEN ''4''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0104'' THEN ''5''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0105'' THEN ''6''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0106'' THEN ''7''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0107'' THEN ''8''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0108'' THEN ''9''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0109'' THEN ''10''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0110'' THEN ''11''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0111'' THEN ''12''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0112'' THEN ''13''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0113'' THEN ''14''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0114'' THEN ''15''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0115'' THEN ''16''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0116'' THEN ''17''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0117'' THEN ''18''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0118'' THEN ''19''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0119'' THEN ''20''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0120'' THEN ''21''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0121'' THEN ''22''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0122'' THEN ''23''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0123'' THEN ''24''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0124'' THEN ''25''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0125'' THEN ''26''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0126'' THEN ''27''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0127'' THEN ''28''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0128'' THEN ''29''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0129'' THEN ''30''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0130'' THEN ''31''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0131'' THEN ''32''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0132'' THEN ''33''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0133'' THEN ''34''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0134'' THEN ''35''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0135'' THEN ''36''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0136'' THEN ''37''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0137'' THEN ''38''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0138'' THEN ''39''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0139'' THEN ''40''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0140'' THEN ''41''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0141'' THEN ''42''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0142'' THEN ''43''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0143'' THEN ''44''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0144'' THEN ''45''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0145'' THEN ''46''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0146'' THEN ''47''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0147'' THEN ''48''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0148'' THEN ''49''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0149'' THEN ''50''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0150'' THEN ''51''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0151'' THEN ''52''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0152'' THEN ''53''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0153'' THEN ''54''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0154'' THEN ''55''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0155'' THEN ''56''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0156'' THEN ''57''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0157'' THEN ''58''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0158'' THEN ''59''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0159'' THEN ''60''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0160'' THEN ''61''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0161'' THEN ''62''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0162'' THEN ''63''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0163'' THEN ''64''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0164'' THEN ''65''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0165'' THEN ''66''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0166'' THEN ''67''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0167'' THEN ''68''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0168'' THEN ''69''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0169'' THEN ''70''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0170'' THEN ''71''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0171'' THEN ''72''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0172'' THEN ''73''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0173'' THEN ''74''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0174'' THEN ''75''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0175'' THEN ''76''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0176'' THEN ''77''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0177'' THEN ''78''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0178'' THEN ''79''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0179'' THEN ''80''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0180'' THEN ''81''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0181'' THEN ''82''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0182'' THEN ''83''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0183'' THEN ''84''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0184'' THEN ''85''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0185'' THEN ''86''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0186'' THEN ''87''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0190'' THEN ''88''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0191'' THEN ''89''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0192'' THEN ''90''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0193'' THEN ''91''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0194'' THEN ''92''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0211'' THEN ''93''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0212'' THEN ''94''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0213'' THEN ''95''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0214'' THEN ''96''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0215'' THEN ''97''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0216'' THEN ''98''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0217'' THEN ''99''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0218'' THEN ''100''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0219'' THEN ''101''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0220'' THEN ''102''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0221'' THEN ''103''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0222'' THEN ''104''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0223'' THEN ''105''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0224'' THEN ''106''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0225'' THEN ''107''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0226'' THEN ''108''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0227'' THEN ''109''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0228'' THEN ''110''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0229'' THEN ''111''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0230'' THEN ''112''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0231'' THEN ''113''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0232'' THEN ''114''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0233'' THEN ''115''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0234'' THEN ''116''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0235'' THEN ''117''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0236'' THEN ''118''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0237'' THEN ''119''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0238'' THEN ''120''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0239'' THEN ''121''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0240'' THEN ''122''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0241'' THEN ''123''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0242'' THEN ''124''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0243'' THEN ''125''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0244'' THEN ''126''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0245'' THEN ''127''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0246'' THEN ''128''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0247'' THEN ''129''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0250'' THEN ''130''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0251'' THEN ''131''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0252'' THEN ''132''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0253'' THEN ''133''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0254'' THEN ''134''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0255'' THEN ''135''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0256'' THEN ''136''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0257'' THEN ''137''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0258'' THEN ''138''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0259'' THEN ''139''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0260'' THEN ''140''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0261'' THEN ''141''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0262'' THEN ''142''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0267'' THEN ''143''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0277'' THEN ''144''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0278'' THEN ''145''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0281'' THEN ''146''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0282'' THEN ''147''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0283'' THEN ''148''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0284'' THEN ''149''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0285'' THEN ''150''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0286'' THEN ''151''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0287'' THEN ''152''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0288'' THEN ''153''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0290'' THEN ''154''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0301'' THEN ''155''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0302'' THEN ''156''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0303'' THEN ''157''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0304'' THEN ''158''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0305'' THEN ''159''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0306'' THEN ''160''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0307'' THEN ''161''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0308'' THEN ''162''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0309'' THEN ''163''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0310'' THEN ''164''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0311'' THEN ''165''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0312'' THEN ''166''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0313'' THEN ''167''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0314'' THEN ''168''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0315'' THEN ''169''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0316'' THEN ''170''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0317'' THEN ''171''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0318'' THEN ''172''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0319'' THEN ''173''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0320'' THEN ''174''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0321'' THEN ''175''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0322'' THEN ''176''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0323'' THEN ''177''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0324'' THEN ''178''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0325'' THEN ''179''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0326'' THEN ''180''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0327'' THEN ''181''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0328'' THEN ''182''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0329'' THEN ''183''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0330'' THEN ''184''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0331'' THEN ''185''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0332'' THEN ''186''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0333'' THEN ''187''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0334'' THEN ''188''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0335'' THEN ''189''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0336'' THEN ''190''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0337'' THEN ''191''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0338'' THEN ''192''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0339'' THEN ''193''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0340'' THEN ''194''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0341'' THEN ''195''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0342'' THEN ''196''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0343'' THEN ''197''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0344'' THEN ''198''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0345'' THEN ''199''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0346'' THEN ''200''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0347'' THEN ''201''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0348'' THEN ''202''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0349'' THEN ''203''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0350'' THEN ''204''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0351'' THEN ''205''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0352'' THEN ''206''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0353'' THEN ''207''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0354'' THEN ''208''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0355'' THEN ''209''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0356'' THEN ''210''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0357'' THEN ''211''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0358'' THEN ''212''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0359'' THEN ''213''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0360'' THEN ''214''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0361'' THEN ''215''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0362'' THEN ''216''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0363'' THEN ''217''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0364'' THEN ''218''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0365'' THEN ''219''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0366'' THEN ''220''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0367'' THEN ''221''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0368'' THEN ''222''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0370'' THEN ''223''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0371'' THEN ''224''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0372'' THEN ''225''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0373'' THEN ''226''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0374'' THEN ''227''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0376'' THEN ''228''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0377'' THEN ''229''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0378'' THEN ''230''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0380'' THEN ''231''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0381'' THEN ''232''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0382'' THEN ''233''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0383'' THEN ''234''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0384'' THEN ''235''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0385'' THEN ''236''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0386'' THEN ''237''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0387'' THEN ''238''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0388'' THEN ''239''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0389'' THEN ''240''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0390'' THEN ''241''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0391'' THEN ''242''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0392'' THEN ''243''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0393'' THEN ''244''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0394'' THEN ''245''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0395'' THEN ''246''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0396'' THEN ''247''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0397'' THEN ''248''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0398'' THEN ''249''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0000'' THEN ''250''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0001'' THEN ''251''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0002'' THEN ''252''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0003'' THEN ''253''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0004'' THEN ''254''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0005'' THEN ''255''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0006'' THEN ''256''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0007'' THEN ''257''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0008'' THEN ''258''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0009'' THEN ''259''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0010'' THEN ''260''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0011'' THEN ''261''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0012'' THEN ''262''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0013'' THEN ''263''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0014'' THEN ''264''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0015'' THEN ''265''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0016'' THEN ''266''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0017'' THEN ''267''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0018'' THEN ''268''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0019'' THEN ''269''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0020'' THEN ''270''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0021'' THEN ''271''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0022'' THEN ''272''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0023'' THEN ''273''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0024'' THEN ''274''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0025'' THEN ''275''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0026'' THEN ''276''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0027'' THEN ''277''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0028'' THEN ''278''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0029'' THEN ''279''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0030'' THEN ''280''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0031'' THEN ''281''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0032'' THEN ''282''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0033'' THEN ''283''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0034'' THEN ''284''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0035'' THEN ''285''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0036'' THEN ''286''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0037'' THEN ''287''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0038'' THEN ''288''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0000'' THEN ''289''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0001'' THEN ''290''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0002'' THEN ''291''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0003'' THEN ''292''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0004'' THEN ''293''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0005'' THEN ''294''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0006'' THEN ''295''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0007'' THEN ''296''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0008'' THEN ''297''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0009'' THEN ''298''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0010'' THEN ''299''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0011'' THEN ''300''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0012'' THEN ''301''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0013'' THEN ''302''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0014'' THEN ''303''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0015'' THEN ''304''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0016'' THEN ''305''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0017'' THEN ''306''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0018'' THEN ''307''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0019'' THEN ''308''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0000'' THEN ''309''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0001'' THEN ''310''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0005'' THEN ''311''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0007'' THEN ''312''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0008'' THEN ''313''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0009'' THEN ''314''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0010'' THEN ''315''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0011'' THEN ''316''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0030'' THEN ''317''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0031'' THEN ''318''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0032'' THEN ''319''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0033'' THEN ''320''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0034'' THEN ''321''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0051'' THEN ''322''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0052'' THEN ''323''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0053'' THEN ''324''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0054'' THEN ''325''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0055'' THEN ''326''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0056'' THEN ''327''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0057'' THEN ''328''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0058'' THEN ''329''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0059'' THEN ''330''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0369'' THEN ''331''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0379'' THEN ''332''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0039'' THEN ''333''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0263'' THEN ''334''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0264'' THEN ''335''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0265'' THEN ''336''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0266'' THEN ''337''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0039'' THEN ''338''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0270'' THEN ''339''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0200'' THEN ''340''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0201'' THEN ''341''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0202'' THEN ''342''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0203'' THEN ''343''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0204'' THEN ''344''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0205'' THEN ''345''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0090'' THEN ''346''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0091'' THEN ''347''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0092'' THEN ''348''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0195'' THEN ''349''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0040'' THEN ''350''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0196'' THEN ''351''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0197'' THEN ''352''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0198'' THEN ''353''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0199'' THEN ''354''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0206'' THEN ''355''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0207'' THEN ''356''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0208'' THEN ''357''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0209'' THEN ''358''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0210'' THEN ''359''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0248'' THEN ''360''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0249'' THEN ''361''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0268'' THEN ''362''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0269'' THEN ''363''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0271'' THEN ''364''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0272'' THEN ''365''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0273'' THEN ''366''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0274'' THEN ''367''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0275'' THEN ''368''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0400'' THEN ''369''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0401'' THEN ''370''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0402'' THEN ''371''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0403'' THEN ''372''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0404'' THEN ''373''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0405'' THEN ''374''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0406'' THEN ''375''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0407'' THEN ''376''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0408'' THEN ''377''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0409'' THEN ''378''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0410'' THEN ''379''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0411'' THEN ''380''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0412'' THEN ''381''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0413'' THEN ''382''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0414'' THEN ''383''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0415'' THEN ''384''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0416'' THEN ''385''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0417'' THEN ''386''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0418'' THEN ''387''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0419'' THEN ''388''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0420'' THEN ''389''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0421'' THEN ''390''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0422'' THEN ''391''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0423'' THEN ''392''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0424'' THEN ''393''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0425'' THEN ''394''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0426'' THEN ''395''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0427'' THEN ''396''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0428'' THEN ''397''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0429'' THEN ''398''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0430'' THEN ''399''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0431'' THEN ''400''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0432'' THEN ''401''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0433'' THEN ''402''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0434'' THEN ''403''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0435'' THEN ''404''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0436'' THEN ''405''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0437'' THEN ''406''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0438'' THEN ''407''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0439'' THEN ''408''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0440'' THEN ''409''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0441'' THEN ''410''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0442'' THEN ''411''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0443'' THEN ''412''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0444'' THEN ''413''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0445'' THEN ''414''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0446'' THEN ''415''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0447'' THEN ''416''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0448'' THEN ''417''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0449'' THEN ''418''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0450'' THEN ''419''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0451'' THEN ''420''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0452'' THEN ''421''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0453'' THEN ''422''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0454'' THEN ''423''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0455'' THEN ''424''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0456'' THEN ''425''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0457'' THEN ''426''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0458'' THEN ''427''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0459'' THEN ''428''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0460'' THEN ''429''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0461'' THEN ''430''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0462'' THEN ''431''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0463'' THEN ''432''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0464'' THEN ''433''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0465'' THEN ''434''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0466'' THEN ''435''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0468'' THEN ''436''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0469'' THEN ''437''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0470'' THEN ''438''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0471'' THEN ''439''
	 END AS ctlno --管理番号
	,CASE
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0100'' THEN ''静脈圧自動設定警報幅上限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0101'' THEN ''静脈圧自動設定警報幅下限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0102'' THEN ''静脈圧自動設定警報限界上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0103'' THEN ''静脈圧自動設定警報限界下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0104'' THEN ''静脈圧固定警報上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0105'' THEN ''静脈圧固定警報下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0106'' THEN ''静脈圧自動設定警報幅上限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0107'' THEN ''静脈圧自動設定警報幅下限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0108'' THEN ''静脈圧固定警報上限準備回収''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0109'' THEN ''静脈圧固定警報下限準備回収''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0110'' THEN ''静脈圧固定警報上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0111'' THEN ''静脈圧固定警報下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0112'' THEN ''液圧自動設定警報幅上限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0113'' THEN ''液圧自動設定警報幅下限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0114'' THEN ''液圧自動設定警報限界上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0115'' THEN ''液圧自動設定警報限界下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0116'' THEN ''液圧固定警報上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0117'' THEN ''液圧固定警報下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0118'' THEN ''液圧自動設定警報幅上限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0119'' THEN ''液圧自動設定警報幅下限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0120'' THEN ''液圧自動設定警報幅上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0121'' THEN ''液圧自動設定警報幅下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0122'' THEN ''液圧自動設定警報限界上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0123'' THEN ''液圧自動設定警報限界下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0124'' THEN ''液圧固定警報上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0125'' THEN ''液圧固定警報下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0126'' THEN ''ＴＭＰ自動追従警報幅上限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0127'' THEN ''ＴＭＰ自動追従警報幅下限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0128'' THEN ''ＴＭＰ自動設定警報幅上限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0129'' THEN ''ＴＭＰ自動設定警報幅下限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0130'' THEN ''ＴＭＰ自動設定警報限界上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0131'' THEN ''ＴＭＰ自動設定警報限界下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0132'' THEN ''ＴＭＰ固定警報上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0133'' THEN ''ＴＭＰ固定警報下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0134'' THEN ''ＴＭＰ自動追従警報幅上限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0135'' THEN ''ＴＭＰ自動追従警報幅下限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0136'' THEN ''ＴＭＰ自動設定警報幅上限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0137'' THEN ''ＴＭＰ自動設定警報幅下限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0138'' THEN ''ＴＭＰ自動追従警報幅上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0139'' THEN ''ＴＭＰ自動追従警報幅下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0140'' THEN ''ＴＭＰ自動設定警報幅上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0141'' THEN ''ＴＭＰ自動設定警報幅下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0142'' THEN ''ＴＭＰ自動設定警報限界上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0143'' THEN ''ＴＭＰ自動設定警報限界下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0144'' THEN ''ＴＭＰ固定警報上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0145'' THEN ''ＴＭＰ固定警報下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0146'' THEN ''ダイアライザー差圧自動設定警報幅上限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0147'' THEN ''ダイアライザー差圧自動設定警報幅下限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0148'' THEN ''ダイアライザー差圧固定警報上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0149'' THEN ''ダイアライザー差圧固定警報下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0150'' THEN ''ダイアライザー差圧自動設定警報幅上限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0151'' THEN ''ダイアライザー差圧自動設定警報幅下限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0152'' THEN ''ダイアライザー入口圧自動設定警報幅上限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0153'' THEN ''ダイアライザー入口圧自動設定警報幅下限HD/ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0154'' THEN ''ダイアライザー入口圧自動設定警報限界上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0155'' THEN ''ダイアライザー入口圧自動設定警報限界下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0156'' THEN ''ダイアライザー入口圧固定警報上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0157'' THEN ''ダイアライザー入口圧固定警報下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0158'' THEN ''ダイアライザー入口圧自動設定警報幅上限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0159'' THEN ''ダイアライザー入口圧自動設定警報幅下限HDF/HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0160'' THEN ''ダイアライザー入口圧固定警報上限準備回収''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0161'' THEN ''ダイアライザー入口圧固定警報下限準備回収''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0162'' THEN ''ダイアライザー入口圧固定警報上限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0163'' THEN ''ダイアライザー入口圧固定警報下限ＳＮ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0164'' THEN ''初期ＵＦＲ警報上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0165'' THEN ''初期ＵＦＲ警報下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0166'' THEN ''ＵＦＲ低下警報点''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0167'' THEN ''ＴＭＰゼロ補正警報中点HD''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0168'' THEN ''ＴＭＰゼロ補正警報上限HD''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0169'' THEN ''ＴＭＰゼロ補正警報下限HD''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0170'' THEN ''ＴＭＰゼロ補正警報中点ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0171'' THEN ''ＴＭＰゼロ補正警報上限ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0172'' THEN ''ＴＭＰゼロ補正警報下限ECUM''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0173'' THEN ''ＴＭＰゼロ補正警報中点HDF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0174'' THEN ''ＴＭＰゼロ補正警報上限HDF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0175'' THEN ''ＴＭＰゼロ補正警報下限HDF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0176'' THEN ''ＴＭＰゼロ補正警報中点HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0177'' THEN ''ＴＭＰゼロ補正警報上限HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0178'' THEN ''ＴＭＰゼロ補正警報下限HF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0179'' THEN ''血流量操作範囲上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0180'' THEN ''ＩＰ速度操作範囲上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0181'' THEN ''除水速度操作範囲上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0182'' THEN ''透析液温度操作範囲上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0183'' THEN ''透析液温度操作範囲下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0184'' THEN ''Ｎａ注入濃度操作範囲上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0185'' THEN ''前補液 補液速度操作範囲上限(HDF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0186'' THEN ''前補液 補液速度操作範囲上限(HF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0190'' THEN ''血圧自動測定間隔''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0191'' THEN ''血圧ｶﾌ選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0192'' THEN ''昇圧値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0193'' THEN ''昇圧方法選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0194'' THEN ''血圧連続測定動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0211'' THEN ''最高血圧上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0212'' THEN ''最高血圧下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0213'' THEN ''最低血圧上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0214'' THEN ''最低血圧下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0215'' THEN ''平均血圧上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0216'' THEN ''平均血圧下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0217'' THEN ''脈拍数上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0218'' THEN ''脈拍数下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0219'' THEN ''最高血圧上限警報 BP 動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0220'' THEN ''最高血圧下限警報 BP 動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0221'' THEN ''最高血圧上限警報 除水 動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0222'' THEN ''最高血圧下限警報 除水 動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0223'' THEN ''最高血圧上限警報 Na注入 動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0224'' THEN ''最高血圧下限警報 Na注入 動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0225'' THEN ''最高血圧上限警報 補液 動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0226'' THEN ''最高血圧下限警報 補液 動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0227'' THEN ''最高血圧上限警報 BP 速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0228'' THEN ''最高血圧下限警報 BP 速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0229'' THEN ''最高血圧上限警報 除水 速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0230'' THEN ''最高血圧下限警報 除水 速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0231'' THEN ''最高血圧上限警報 Na注入 速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0232'' THEN ''最高血圧下限警報 Na注入 速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0233'' THEN ''最高血圧上限警報 補液 速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0234'' THEN ''最高血圧下限警報 補液 速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0235'' THEN ''警報連動測定開始時刻''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0236'' THEN ''治療条件連動測定時刻''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0237'' THEN ''血圧測定自動停止(警報発生)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0238'' THEN ''血圧測定自動停止(条件変更)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0239'' THEN ''高速測定選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0240'' THEN ''ＴＭＰ監視モード''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0241'' THEN ''ＴＭＰゼロ補正の選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0242'' THEN ''静脈圧自動設定警報監視有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0243'' THEN ''ダイアライザー血液入口圧自動設定警報監視有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0244'' THEN ''透析液圧自動設定警報監視有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0245'' THEN ''ＴＭＰ自動設定警報監視有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0246'' THEN ''差圧自動設定警報監視有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0247'' THEN ''Ｎａ濃度自動設定警報監視有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0250'' THEN ''透析液濃度プログラム自動設定警報幅上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0251'' THEN ''透析液濃度プログラム自動設定警報幅下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0252'' THEN ''Ｂ液濃度プログラム自動設定警報幅上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0253'' THEN ''Ｂ液濃度プログラム自動設定警報幅下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0254'' THEN ''Ｎａ濃度自動設定警報幅上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0255'' THEN ''Ｎａ濃度自動設定警報幅下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0256'' THEN ''Ｎａ濃度固定警報上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0257'' THEN ''Ｎａ濃度固定警報下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0258'' THEN ''アクセス再循環測定使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0259'' THEN ''自動測定1''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0260'' THEN ''⊿ＢＶ低下警報点１''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0261'' THEN ''⊿ＢＶ低下警報点２''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0262'' THEN ''⊿BV変化率警報点''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0267'' THEN ''ブラッドボリューム計使用の選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0277'' THEN ''⊿ＢＶ除水低下速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0278'' THEN ''⊿ＢＶ除水低下遅延時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0281'' THEN ''再循環率報知''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0282'' THEN ''透析量プログラム使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0283'' THEN ''体液量計算時後体重''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0284'' THEN ''体液量+補正値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0285'' THEN ''目標後体重''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0286'' THEN ''標準血流量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0287'' THEN ''KoA''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0288'' THEN ''目標Kt/V''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0290'' THEN ''ＵＦＲプログラム電源ＳＷ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0301'' THEN ''ＵＦＲプログラム指数１''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0302'' THEN ''ＵＦＲプログラム指数２''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0303'' THEN ''ＵＦＲプログラム指数３''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0304'' THEN ''ＵＦＲプログラム指数４''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0305'' THEN ''ＵＦＲプログラム指数５''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0306'' THEN ''ＵＦＲプログラム指数６''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0307'' THEN ''ＵＦＲプログラム指数７''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0308'' THEN ''ＵＦＲプログラム指数８''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0309'' THEN ''ＵＦＲプログラム指数９''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0310'' THEN ''ＵＦＲプログラム指数１０''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0311'' THEN ''ＵＦＲプログラム最終位置''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0312'' THEN ''ＵＦＲプログラムコース''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0313'' THEN ''ＵＦＲプログラム開始数値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0314'' THEN ''ＵＦＲプログラム終了数値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0315'' THEN ''Ｎａ注入プログラム電源ＳＷ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0316'' THEN ''Ｎａ注入プログラム設定１''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0317'' THEN ''Ｎａ注入プログラム設定２''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0318'' THEN ''Ｎａ注入プログラム設定３''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0319'' THEN ''Ｎａ注入プログラム設定４''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0320'' THEN ''Ｎａ注入プログラム設定５''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0321'' THEN ''Ｎａ注入プログラム設定６''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0322'' THEN ''Ｎａ注入プログラム設定７''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0323'' THEN ''Ｎａ注入プログラム設定８''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0324'' THEN ''Ｎａ注入プログラム設定９''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0325'' THEN ''Ｎａ注入プログラム設定１０''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0326'' THEN ''Ｎａ注入プログラム切替時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0327'' THEN ''Ｎａ注入プログラム ＵＦＲプロとの連動選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0328'' THEN ''Ｎａ注入プログラムコース''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0329'' THEN ''Ｎａ注入プログラム開始数値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0330'' THEN ''Ｎａ注入プログラム終了数値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0331'' THEN ''同時脱血 脱血量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0332'' THEN ''片側脱血への切替え透析液圧''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0333'' THEN ''脱血速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0334'' THEN ''片側脱血(除水なし) 脱血量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0335'' THEN ''治療開始時 血液ポンプ速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0336'' THEN ''補液速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0337'' THEN ''補液量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0338'' THEN ''片側脱血(除水あり) 脱血量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0339'' THEN ''脱血方法選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0340'' THEN ''濃度プログラム電源ＳＷ''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0341'' THEN ''透析液濃度プログラム設定１''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0342'' THEN ''透析液濃度プログラム設定２''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0343'' THEN ''透析液濃度プログラム設定３''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0344'' THEN ''透析液濃度プログラム設定４''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0345'' THEN ''透析液濃度プログラム設定５''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0346'' THEN ''透析液濃度プログラム設定６''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0347'' THEN ''透析液濃度プログラム設定７''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0348'' THEN ''透析液濃度プログラム設定８''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0349'' THEN ''透析液濃度プログラム設定９''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0350'' THEN ''透析液濃度プログラム設定１０''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0351'' THEN ''Ｂ液濃度プログラム設定１''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0352'' THEN ''Ｂ液濃度プログラム設定２''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0353'' THEN ''Ｂ液濃度プログラム設定３''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0354'' THEN ''Ｂ液濃度プログラム設定４''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0355'' THEN ''Ｂ液濃度プログラム設定５''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0356'' THEN ''Ｂ液濃度プログラム設定６''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0357'' THEN ''Ｂ液濃度プログラム設定７''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0358'' THEN ''Ｂ液濃度プログラム設定８''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0359'' THEN ''Ｂ液濃度プログラム設定９''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0360'' THEN ''Ｂ液濃度プログラム設定１０''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0361'' THEN ''透析液濃度プログラムステップ切替無し コース''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0362'' THEN ''透析液濃度プログラム開始数値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0363'' THEN ''透析液濃度プログラム終了数値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0364'' THEN ''Ｂ液濃度プログラムステップ切替無し コース''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0365'' THEN ''Ｂ液濃度プログラム開始数値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0366'' THEN ''Ｂ液濃度プログラム終了数値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0367'' THEN ''濃度プログラム切替時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0368'' THEN ''濃度プログラム ＵＦＲプロとの連動選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0370'' THEN ''自動回収 使用液量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0371'' THEN ''自動回収 流速''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0372'' THEN ''自動回収 血液判別器による終了選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0373'' THEN ''静脈側返血速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0374'' THEN ''静脈側最大返血量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0376'' THEN ''動脈側最大返血量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0377'' THEN ''静脈側返血 血液判別器使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0378'' THEN ''動脈側返血 血液判別器使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0380'' THEN ''補液速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0381'' THEN ''補液温度設定値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0382'' THEN ''補液量設定値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0383'' THEN ''補液量設定値制限(OHDF・OHF用)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0384'' THEN ''AFBF 補液比率使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0385'' THEN ''AFBF 補液比率''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0386'' THEN ''補液速度設定範囲上限(AFBF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0387'' THEN ''補液速度設定範囲下限(AFBF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0388'' THEN ''補液選択(前・後)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0389'' THEN ''OHDF/OHF補液計算優先項目選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0390'' THEN ''ＴＭＰゼロ補正警報中点OHDF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0391'' THEN ''ＴＭＰゼロ補正警報上限OHDF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0392'' THEN ''ＴＭＰゼロ補正警報下限OHDF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0393'' THEN ''ＴＭＰゼロ補正警報中点OHF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0394'' THEN ''ＴＭＰゼロ補正警報上限OHF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0395'' THEN ''ＴＭＰゼロ補正警報下限OHF''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0396'' THEN ''前補液 補液速度操作範囲上限(OHDF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0397'' THEN ''前補液 補液速度操作範囲上限(OHF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0398'' THEN ''補液開始遅延時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0000'' THEN ''UFRプログラム工程1の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0001'' THEN ''UFRプログラム工程2の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0002'' THEN ''UFRプログラム工程3の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0003'' THEN ''UFRプログラム工程4の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0004'' THEN ''UFRプログラム工程5の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0005'' THEN ''UFRプログラム工程6の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0006'' THEN ''UFRプログラム工程7の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0007'' THEN ''UFRプログラム工程8の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0008'' THEN ''UFRプログラム工程9の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0009'' THEN ''UFRプログラム工程10の指数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0010'' THEN ''B液濃度プログラム工程1のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0011'' THEN ''B液濃度プログラム工程2のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0012'' THEN ''B液濃度プログラム工程3のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0013'' THEN ''B液濃度プログラム工程4のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0014'' THEN ''B液濃度プログラム工程5のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0015'' THEN ''B液濃度プログラム工程6のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0016'' THEN ''B液濃度プログラム工程7のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0017'' THEN ''B液濃度プログラム工程8のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0018'' THEN ''B液濃度プログラム工程9のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0019'' THEN ''B液濃度プログラム工程10のB液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0020'' THEN ''A液濃度プログラム工程1のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0021'' THEN ''A液濃度プログラム工程2のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0022'' THEN ''A液濃度プログラム工程3のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0023'' THEN ''A液濃度プログラム工程4のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0024'' THEN ''A液濃度プログラム工程5のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0025'' THEN ''A液濃度プログラム工程6のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0026'' THEN ''A液濃度プログラム工程7のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0027'' THEN ''A液濃度プログラム工程8のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0028'' THEN ''A液濃度プログラム工程9のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0029'' THEN ''A液濃度プログラム工程10のA液濃度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0030'' THEN ''前補液 補液速度操作範囲上限(HD+補液)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0031'' THEN ''後補液 補液速度操作範囲上限(HDF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0032'' THEN ''後補液 補液速度操作範囲上限(HF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0033'' THEN ''後補液 補液速度操作範囲上限(HD+補液)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0034'' THEN ''後補液 補液速度操作範囲上限(OHDF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0035'' THEN ''後補液 補液速度操作範囲上限(OHF)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0036'' THEN ''治療開始時血流量使用有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0037'' THEN ''ＴＭＰゼロ補正警報上限(HD+補液)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0038'' THEN ''ＴＭＰゼロ補正警報下限(HD+補液)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0000'' THEN ''プライミング補助動脈充填液量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0001'' THEN ''プライミング補助動脈充填流速''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0002'' THEN ''プライミング補助静脈充填液量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0003'' THEN ''プライミング補助静脈充填流速''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0004'' THEN ''プライミング補助気泡抜き液量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0005'' THEN ''プライミング補助気泡抜き流速''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0006'' THEN ''プライミング補助動脈充填後継続の有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0007'' THEN ''プライミング補助静脈充填後継続の有無''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0008'' THEN ''プライミング補助気泡抜き間欠動作選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0009'' THEN ''プライミング補助液交換量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0010'' THEN ''プライミング補助間欠動作動作時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0011'' THEN ''プライミング補助間欠動作停止時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0012'' THEN ''自動プライミング開始時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0013'' THEN ''自動プライミング落差時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0014'' THEN ''自動プライミング送液液量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0015'' THEN ''自動プライミング送液流速1回目''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0016'' THEN ''自動プライミング送液流速2回目以降''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0017'' THEN ''自動プライミング循環流速''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0018'' THEN ''自動プライミング循環時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0019'' THEN ''自動プライミング総量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0000'' THEN ''ダイアライザ選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0001'' THEN ''IPラインプライミング使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0005'' THEN ''中空糸 プライミング時のBP速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0007'' THEN ''中空糸 送液最大時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0008'' THEN ''中空糸 回路内洗浄送液量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0009'' THEN ''中空糸 気泡抜き動作実行回数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0010'' THEN ''中空糸 気泡抜き圧力上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0011'' THEN ''中空糸 除水ポンプ速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0030'' THEN ''補液選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0031'' THEN ''前補液 ダイアライザー気泡抜き時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0032'' THEN ''前補液 動脈チャンバ液面作成時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0033'' THEN ''前補液 循環洗浄時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0034'' THEN ''治療モード''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0051'' THEN ''後補液 ダイアライザー気泡抜き時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0052'' THEN ''後補液 動脈チャンバ液面作成時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0053'' THEN ''後補液 循環洗浄時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0054'' THEN ''積層 送液最大時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0055'' THEN ''積層 回路内洗浄送液量''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0056'' THEN ''積層 気泡抜き動作実行回数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0057'' THEN ''積層 気泡抜き圧力上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0058'' THEN ''積層 除水ポンプ速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0059'' THEN ''積層 プライミング時のBP速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0369'' THEN ''DP=Qd+Qs(補液速度加算)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0379'' THEN ''前補液　OHDF/OHF　補液速度比率''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0039'' THEN ''後補液　OHDF/OHF　補液速度比率''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0263'' THEN ''自動測定2''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0264'' THEN ''自動測定3''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0265'' THEN ''自動測定4''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0266'' THEN ''自動測定5''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0039'' THEN ''除水開始遅延時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0270'' THEN ''動脈側返血使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0200'' THEN ''I-HDF　補液量設定''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0201'' THEN ''I-HDF　補液速度''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0202'' THEN ''I-HDF　補液周期''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0203'' THEN ''I-HDF　補液開始時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0204'' THEN ''I-HDF　除水再開時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0205'' THEN ''I-HDF　総補液量上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0090'' THEN ''濾過率（前補液）''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0091'' THEN ''ヘマトクリット（Ht）''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0092'' THEN ''総タンパク（TP）''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0195'' THEN ''血圧測定方法選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0040'' THEN ''濾過率（後補液）''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0196'' THEN ''BV-UFC使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0197'' THEN ''UFC期間除水速度上限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0198'' THEN ''UFC期間除水速度下限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0199'' THEN ''開始期間 時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0206'' THEN ''開始期間 除水速度倍率''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0207'' THEN ''固定倍率除水期間 時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0208'' THEN ''固定倍率除水期間 除水速度倍率''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0209'' THEN ''固定倍率除水終了条件　最高血圧''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0210'' THEN ''固定倍率除水終了条件　脈拍''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0248'' THEN ''固定倍率除水終了条件　ΔBV''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0249'' THEN ''終了前期間 時間''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0268'' THEN ''透析液流量　設定方法''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0269'' THEN ''透析液流量　比率設定''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0271'' THEN ''開始時ΔBV基準値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0272'' THEN ''ΔBV基準線　指数1''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0273'' THEN ''ΔBV基準線　指数2''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0274'' THEN ''ΔBV基準線　指数3''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0275'' THEN ''終了時ΔBV基準値''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0400'' THEN ''QBプログラム血流量1''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0401'' THEN ''QBプログラム血流量2''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0402'' THEN ''QBプログラム血流量3''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0403'' THEN ''QBプログラム血流量4''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0404'' THEN ''QBプログラム血流量5''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0405'' THEN ''QBプログラム血流量6''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0406'' THEN ''QBプログラム血流量7''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0407'' THEN ''QBプログラム血流量8''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0408'' THEN ''QBプログラム血流量9''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0409'' THEN ''QBプログラム血流量10''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0410'' THEN ''QDプログラム透析液流量1''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0411'' THEN ''QDプログラム透析液流量2''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0412'' THEN ''QDプログラム透析液流量3''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0413'' THEN ''QDプログラム透析液流量4''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0414'' THEN ''QDプログラム透析液流量5''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0415'' THEN ''QDプログラム透析液流量6''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0416'' THEN ''QDプログラム透析液流量7''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0417'' THEN ''QDプログラム透析液流量8''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0418'' THEN ''QDプログラム透析液流量9''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0419'' THEN ''QDプログラム透析液流量10''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0420'' THEN ''QB、QDプログラム切替時間1''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0421'' THEN ''QB、QDプログラム切替時間2''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0422'' THEN ''QB、QDプログラム切替時間3''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0423'' THEN ''QB、QDプログラム切替時間4''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0424'' THEN ''QB、QDプログラム切替時間5''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0425'' THEN ''QB、QDプログラム切替時間6''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0426'' THEN ''QB、QDプログラム切替時間7''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0427'' THEN ''QB、QDプログラム切替時間8''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0428'' THEN ''QB、QDプログラム切替時間9''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0429'' THEN ''QB、QDプログラム最大ステップ数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0430'' THEN ''QBプログラム電源''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0431'' THEN ''QDプログラム電源''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0432'' THEN ''I-HDFプログラム使用選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0433'' THEN ''予定補液回数''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0434'' THEN ''補液バランス制限''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0435'' THEN ''補液量01''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0436'' THEN ''補液量02''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0437'' THEN ''補液量03''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0438'' THEN ''補液量04''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0439'' THEN ''補液量05''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0440'' THEN ''補液量06''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0441'' THEN ''補液量07''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0442'' THEN ''補液量08''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0443'' THEN ''補液量09''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0444'' THEN ''補液量10''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0445'' THEN ''補液量11''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0446'' THEN ''補液量12''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0447'' THEN ''補液量13''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0448'' THEN ''補液量14''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0449'' THEN ''補液量15''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0450'' THEN ''補液量16''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0451'' THEN ''回収量01''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0452'' THEN ''回収量02''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0453'' THEN ''回収量03''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0454'' THEN ''回収量04''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0455'' THEN ''回収量05''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0456'' THEN ''回収量06''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0457'' THEN ''回収量07''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0458'' THEN ''回収量08''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0459'' THEN ''回収量09''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0460'' THEN ''回収量10''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0461'' THEN ''回収量11''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0462'' THEN ''回収量12''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0463'' THEN ''回収量13''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0464'' THEN ''回収量14''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0465'' THEN ''回収量15''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0466'' THEN ''回収量16''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0468'' THEN ''VA確認報知基準値(静的静脈圧)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0469'' THEN ''VA確認報知基準値(IAP ratio)''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0470'' THEN ''静的静脈圧記録 自動実施選択''
		WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0471'' THEN ''血圧測定 自動実施選択''
	 END AS setname --項目名
	 ,ntss_db5_pm_dsi.value_4 AS value --設定値(当日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
	 ,ntss_db5_pm_dsi.value_4 AS monvalue --設定値(月曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
	 ,ntss_db5_pm_dsi.value_4 AS tuevalue --設定値(火曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
	 ,ntss_db5_pm_dsi.value_4 AS wedvalue --設定値(水曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
	 ,ntss_db5_pm_dsi.value_4 AS thuvalue --設定値(木曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
	 ,ntss_db5_pm_dsi.value_4 AS frivalue --設定値(金曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
	 ,ntss_db5_pm_dsi.value_4 AS satvalue --設定値(土曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
	 ,ntss_db5_pm_dsi.value_4 AS sunvalue --設定値(日曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
FROM
	pat_main ntss_db5_pm
	INNER JOIN ntss_db5_pm_dsi
	ON ntss_db5_pm_dsi.pat_id = ntss_db5_pm.pat_id
	AND cast(ntss_db5_pm_dsi.value_2 AS integer) > 100
WHERE ntss_db5_pm.is_del = ''0''
	AND ntss_db5_pm.facility_cd = @facilityCd
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_pm.device_set_info IS NOT NULL
	AND ntss_db5_pm.device_set_info <> ''[]'';', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
