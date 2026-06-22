UPDATE sys_data_set
set detail = '
[
  {
    "data_code": "pat_id",
    "field_name": "hosp_pat_id",
    "data_category": "患者情報",
    "data_class": "基本情報",
    "data_name": "患者ID",
    "conv_table": "",
    "data_type": "string",
    "preview": "123456789012",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "pat_name",
    "field_name": "pat_name",
    "data_category": "患者情報",
    "data_class": "基本情報",
    "data_name": "氏名",
    "conv_table": "",
    "data_type": "string",
    "preview": "日機装　太郎",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  }
]',
up_date = '2019/07/19 13:00:00.000'
WHERE sql_cd = 1
;

UPDATE sys_data_set
set detail = '
[
  {
    "data_code": "rst_start_date",
    "field_name": "rst_start_date_format",
    "data_category": "実績",
    "data_class": "実績情報",
    "data_name": "透析開始日時",
    "conv_table": "",
    "data_type": "DateTime",
    "preview": "2011/3/12  08:21",
    "disp_format": "hh:mm",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "rst_end_date",
    "field_name": "rst_end_date_format",
    "data_category": "実績",
    "data_class": "実績情報",
    "data_name": "透析終了日時",
    "conv_table": "",
    "data_type": "DateTime",
    "preview": "2011/3/12  12:45",
    "disp_format": "hh:mm",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  }
]',
up_date = '2019/07/19 13:00:00.000'
WHERE sql_cd = 2
;

UPDATE sys_data_set
set detail = '
[
  {
    "data_code": "weight_before",
    "field_name": "weight_before",
    "data_category": "実績",
    "data_class": "体重情報",
    "data_name": "前体重",
    "conv_table": "",
    "data_type": "decimal",
    "preview": "57.90",
    "disp_format": "0.00",
    "can_calc": "1",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "weight_after",
    "field_name": "weight_after",
    "data_category": "実績",
    "data_class": "体重情報",
    "data_name": "後体重",
    "conv_table": "",
    "data_type": "decimal",
    "preview": "55.05",
    "disp_format": "0.00",
    "can_calc": "1",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "puncture_user_name",
    "field_name": "puncture_user_name",
    "data_category": "実績",
    "data_class": "実績情報",
    "data_name": "穿刺者名１",
    "conv_table": "",
    "data_type": "string",
    "preview": "テスト看護師２",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  }
]',
up_date = '2019/07/19 13:00:00.000'
WHERE sql_cd = 3
;

UPDATE sys_data_set
set detail = '
[
  {
    "data_code": "medi_name",
    "field_name": "medi_name",
    "data_category": "指示",
    "data_class": "投薬",
    "data_name": "薬剤名",
    "conv_table": "",
    "data_type": "string",
    "preview": "テスト薬剤１",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "medi_amount",
    "field_name": "medi_amount",
    "data_category": "指示",
    "data_class": "投薬",
    "data_name": "数量",
    "conv_table": "",
    "data_type": "decimal",
    "preview": "1",
    "disp_format": "0",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "medi_timing_name",
    "field_name": "medi_timing_name",
    "data_category": "指示",
    "data_class": "投薬",
    "data_name": "投与時間帯",
    "conv_table": "",
    "data_type": "string",
    "preview": "透析中",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  }
]',
up_date = '2019/07/19 13:00:00.000'
WHERE sql_cd = 4
;

UPDATE sys_data_set
set detail = '
[
  {
    "data_code": "treatment_name",
    "field_name": "treatment_name",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "治療方法",
    "conv_table": "",
    "data_type": "string",
    "preview": "HDF",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "dw",
    "field_name": "dw",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "DW",
    "conv_table": "",
    "data_type": "decimal",
    "preview": "55.00",
    "disp_format": "0.00",
    "can_calc": "1",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "treatment_time",
    "field_name": "treatment_time"
  },
  {
    "data_code": "va",
    "field_name": "va"
  },
  {
    "data_code": "target_weight",
    "field_name": "target_weight"
  },
  {
    "data_code": "water_removal_amount_limit",
    "field_name": "water_removal_amount_limit"
  },
  {
    "data_code": "dialyzer",
    "field_name": "dialyzer",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "ダイアライザ",
    "conv_table": "",
    "data_type": "string",
    "preview": "FDX-120GW",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "adsorption_column",
    "field_name": "adsorption_column"
  },
  {
    "data_code": "primary_film",
    "field_name": "primary_film"
  },
  {
    "data_code": "secondary_film",
    "field_name": "secondary_film"
  },
  {
    "data_code": "puncture_needle_a",
    "field_name": "puncture_needle_a"
  },
  {
    "data_code": "puncture_needle_v",
    "field_name": "puncture_needle_v"
  },
  {
    "data_code": "puncture_needle_sn",
    "field_name": "puncture_needle_sn"
  },
  {
    "data_code": "single_needle",
    "field_name": "single_needle"
  },
  {
    "data_code": "blood_circuit",
    "field_name": "blood_circuit"
  },
  {
    "data_code": "blood_flow",
    "field_name": "blood_flow",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "血流量",
    "conv_table": "",
    "data_type": "decimal",
    "preview": "180",
    "disp_format": "0",
    "can_calc": "1",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "dialysate",
    "field_name": "dialysate"
  },
  {
    "data_code": "dialysate_flow_rate",
    "field_name": "dialysate_flow_rate"
  },
  {
    "data_code": "dialysate_amount",
    "field_name": "dialysate_amount"
  },
  {
    "data_code": "dialysate_amount_unit",
    "field_name": "dialysate_amount_unit"
  },
  {
    "data_code": "dialysate_temperature",
    "field_name": "dialysate_temperature"
  },
  {
    "data_code": "fluid_replacement",
    "field_name": "fluid_replacement"
  },
  {
    "data_code": "fluid_replacement_amount",
    "field_name": "fluid_replacement_amount"
  },
  {
    "data_code": "fluid_replacement_timing",
    "field_name": "fluid_replacement_timing"
  },
  {
    "data_code": "fluid_replacement_use_count",
    "field_name": "fluid_replacement_use_count"
  },
  {
    "data_code": "fluid_replacement_use_count_unit",
    "field_name": "fluid_replacement_use_count_unit"
  },
  {
    "data_code": "fluid_replacement_temperature",
    "field_name": "fluid_replacement_temperature"
  },
  {
    "data_code": "fluid_replacement_speed",
    "field_name": "fluid_replacement_speed"
  },
  {
    "data_code": "anti_coagulant",
    "field_name": "anti_coagulant",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "抗凝固剤",
    "conv_table": "",
    "data_type": "string",
    "preview": "テスト抗凝固剤",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "anti_coagulant_one_shot_amount",
    "field_name": "anti_coagulant_one_shot_amount",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "抗凝固剤ワンショット量",
    "conv_table": "",
    "data_type": "decimal",
    "preview": "1000",
    "disp_format": "0",
    "can_calc": "1",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "anti_coagulant_one_shot_amount_unit",
    "field_name": "anti_coagulant_one_shot_amount_unit"
  },
  {
    "data_code": "anti_coagulant_sustained_speed",
    "field_name": "anti_coagulant_sustained_speed",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "抗凝固剤持続速度",
    "conv_table": "",
    "data_type": "decimal",
    "preview": "500",
    "disp_format": "0",
    "can_calc": "1",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "anti_coagulant_sustained_speed_unit",
    "field_name": "anti_coagulant_sustained_speed_unit",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "抗凝固剤持続速度単位",
    "conv_table": "",
    "data_type": "string",
    "preview": "U/h",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "anti_coagulant_sustained_amount",
    "field_name": "anti_coagulant_sustained_amount",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "抗凝固剤持続総量",
    "conv_table": "",
    "data_type": "decimal",
    "preview": "2000",
    "disp_format": "0",
    "can_calc": "1",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "anti_coagulant_sustained_amount_unit",
    "field_name": "anti_coagulant_sustained_amount_unit",
    "data_category": "指示",
    "data_class": "透析条件",
    "data_name": "抗凝固剤単位",
    "conv_table": "",
    "data_type": "string",
    "preview": "U",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "ip",
    "field_name": "ip"
  },
  {
    "data_code": "ip_start",
    "field_name": "ip_start"
  },
  {
    "data_code": "ip_one_short_amount",
    "field_name": "ip_one_short_amount"
  },
  {
    "data_code": "ip_speed",
    "field_name": "ip_speed"
  },
  {
    "data_code": "ip_speed_max",
    "field_name": "ip_speed_max"
  },
  {
    "data_code": "auto_one_shot",
    "field_name": "auto_one_shot"
  },
  {
    "data_code": "ip_auto_off",
    "field_name": "ip_auto_off"
  },
  {
    "data_code": "ip_auto_off_time",
    "field_name": "ip_auto_off_time"
  },
  {
    "data_code": "ip_monitor_auto_off",
    "field_name": "ip_monitor_auto_off"
  },
  {
    "data_code": "ip_monitor_auto_off_time",
    "field_name": "ip_monitor_auto_off_time"
  }
]',
up_date = '2019/07/19 13:00:00.000'
WHERE sql_cd = 5
;

UPDATE sys_data_set
set detail = '
[
  {
    "data_code": "occur_time",
    "field_name": "occur_time",
    "data_category": "実績",
    "data_class": "愁訴処置",
    "data_name": "愁訴処置時刻",
    "conv_table": "",
    "data_type": "DateTime",
    "preview": "09:46",
    "disp_format": "hh:mm",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "complaint",
    "field_name": "complaint",
    "data_category": "実績",
    "data_class": "愁訴処置",
    "data_name": "愁訴",
    "conv_table": "",
    "data_type": "string",
    "preview": "テスト愁訴",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "row_no",
    "field_name": "row_no"
  },
  {
    "data_code": "treat_name",
    "field_name": "treat_name",
    "data_category": "実績",
    "data_class": "愁訴処置",
    "data_name": "処置",
    "conv_table": "",
    "data_type": "string",
    "preview": "テスト処置",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "treat_medicine",
    "field_name": "treat_medicine",
    "data_category": "実績",
    "data_class": "愁訴処置",
    "data_name": "処置薬剤",
    "conv_table": "",
    "data_type": "string",
    "preview": "テスト処置薬剤",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  },
  {
    "data_code": "amount",
    "field_name": "amount"
  },
  {
    "data_code": "unit",
    "field_name": "unit"
  },
  {
    "data_code": "procedure",
    "field_name": "procedure"
  },
  {
    "data_code": "treat_staff_name",
    "field_name": "treat_staff_name",
    "data_category": "実績",
    "data_class": "愁訴処置",
    "data_name": "処置者",
    "conv_table": "",
    "data_type": "string",
    "preview": "テスト看護師１",
    "disp_format": "",
    "can_calc": "0",
    "facility_filter_type": "0",
    "facility_table": ""
  }
]',
up_date = '2019/07/19 13:00:00.000'
WHERE sql_cd = 6
;
