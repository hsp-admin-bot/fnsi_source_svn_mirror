truncate sys_data_set;

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date)
VALUES
(1, 'select
	pat_id,
	personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name
from
  pat_personal_main
where
  is_del = ''0''
and
  pat_id = @patId
', 3, '[{"data_code": "pat_id", "field_name": "pat_id"}, {"data_code": "pat_name", "field_name": "pat_name"}]', '0', NULL, NULL, NULL, '2019-05-29 17:24:00.000', '2019-05-29 17:24:00.000'),
(2, 'select 
  *
from
  ord_main
where
  ord_no = @ordNo', 2, '[
    {
        "data_code": "pat_id",
        "field_name": "pat_id"
    },
    {
        "data_code": "pat_name",
        "field_name": "pat_name"
    }
]', '0', NULL, NULL, NULL, '2019-05-29 17:24:00.000', '2019-05-29 17:24:00.000'),
(3, 'select 
  weight_before,
  weight_after,
  puncture_user_last_name||puncture_user_first_name as puncture_user_name
from  ( 
  select
    ord.rst_weight_info ->> ''weight_before'' as weight_before,
    ord.rst_weight_info ->> ''weight_after'' as weight_after,
    ord.rst_puncture_user_info ->> ''user_last_name_1'' as puncture_user_last_name,
    ord.rst_puncture_user_info ->> ''user_first_name_1'' as puncture_user_first_name
  from
    ord_main as ord
  where
    ord.ord_no = @ordNo
) as ordsub', 2, '[{"data_code": "weight_before", "field_name": "weight_before"}, {"data_code": "weight_after", "field_name": "weight_after"}, {"data_code": "puncture_user_name", "field_name": "puncture_user_name"}]', '0', NULL, NULL, NULL, '2019-05-29 17:24:00.000', '2019-05-29 17:24:00.000'),
(4, 'select
  medi ->> ''name'' as medi_name,
  medi ->> ''amount'' as medi_amount,
  medi ->> ''timing_name'' as medi_timing_name
from
  ord_main as ord
cross join lateral
  json_array_elements (ord.rst_medi_info :: json) medi
where
    ord.ord_no = @ordNo
', 2, '[{"data_code": "medi_name", "field_name": "medi_name"}, {"data_code": "medi_amount", "field_name": "medi_amount"}, {"data_code": "medi_timing_name", "field_name": "medi_timing_name"}]', '1', NULL, NULL, NULL, '2019-05-29 17:24:00.000', '2019-05-29 17:24:00.000')
;

UPDATE
  sys_data_set
SET
 "sql"=
'
 select
   hosp_pat_id,
 	 personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name
 from
   pat_personal_main
 where
   is_del = ''0''
 and
   pat_id = @patId
'
  , detail='[{"data_code": "pat_id", "field_name": "hosp_pat_id"}, {"data_code": "pat_name", "field_name": "pat_name"}]'
WHERE
  sql_cd = 1
;

UPDATE
  sys_data_set
SET
  "sql"=
'
 select
   *
   , to_char(rst_start_date, ''hh24:mm'') as rst_start_date_format
   , to_char(rst_end_date, ''hh24:mm'') as rst_end_date_format
 from
   ord_main
 where
   ord_no = @ordNo
'
  , detail='[{"data_code": "rst_start_date", "field_name": "rst_start_date_format"}, {"data_code": "rst_end_date", "field_name": "rst_end_date_format"}]'
WHERE
  sql_cd = 2
;
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date)
VALUES
(5, 'select
  ord.rst_treatment_name as treatment_name,
  ord.rst_dw as dw,
  ord.rst_cond_info->''1''->>''value'' as treatment_time,
  ord.rst_cond_info->''2''->>''value_name_1'' as va,
  ord.rst_cond_info->''3''->>''value'' as target_weight,
  ord.rst_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.rst_cond_info->''5''->>''value_name_1'' as dialyzer,
  ord.rst_cond_info->''6''->>''value_name_1'' as adsorption_column,
  ord.rst_cond_info->''7''->>''value_name_1'' as primary_film,
  ord.rst_cond_info->''8''->>''value_name_1'' as secondary_film,
  ord.rst_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  ord.rst_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  ord.rst_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  (case ord.rst_cond_info->''12''->>''value'' when ''1'' then ''有り'' when ''0'' then ''無し'' else null end) as single_needle,
  ord.rst_cond_info->''13''->>''value'' as blood_circuit,
  ord.rst_cond_info->''14''->>''value'' as blood_flow,
  ord.rst_cond_info->''15''->>''value_name_1'' as dialysate,
  ord.rst_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.rst_cond_info->''17''->>''value'' as dialysate_amount,
  ord.rst_cond_info->''17''->>''unit'' as dialysate_amount_unit,
  ord.rst_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.rst_cond_info->''19''->>''value_name_1'' as fluid_replacement,
  ord.rst_cond_info->''20''->>''value'' as fluid_replacement_amount,
  (case ord.rst_cond_info->''21''->>''value'' when ''1'' then ''前補液'' when ''0'' then ''後補液'' else null end) as fluid_replacement_timing,
  ord.rst_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.rst_cond_info->''22''->>''unit'' as fluid_replacement_use_count_unit,
  ord.rst_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.rst_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.rst_cond_info->''25''->>''value_name_1'' as anti_coagulant,
  ord.rst_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.rst_cond_info->''26''->>''unit'' as anti_coagulant_one_shot_amount_unit,
  ord.rst_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.rst_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.rst_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.rst_cond_info->''28''->>''unit'' as anti_coagulant_sustained_amount_unit,
  (case ord.rst_cond_info->''29''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end) as ip,
  (case ord.rst_cond_info->''30''->>''value'' when ''0'' then ''手動'' when ''1'' then ''自動'' else null end) as ip_start,
  ord.rst_cond_info->''31''->>''value'' as ip_one_short_amount,
  ord.rst_cond_info->''32''->>''value'' as ip_speed,
  ord.rst_cond_info->''33''->>''value'' as ip_speed_max,
  (case ord.rst_cond_info->''34''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end) as auto_one_shot,
  (case ord.rst_cond_info->''35''->>''value'' when ''1'' then ''入'' when ''0'' then ''切'' else null end) as ip_auto_off,
  ord.rst_cond_info->''36''->>''value'' as ip_auto_off_time,
  (case ord.rst_cond_info->''37''->>''value'' when ''1'' then ''入'' when ''0'' then ''切'' else null end) as ip_monitor_auto_off,
  ord.rst_cond_info->''38''->>''value'' as ip_monitor_auto_off_time
from
  ord_main as ord
where
  ord.ord_no = @ordNo
', 2, '[
  {"data_code": "treatment_name", "field_name": "treatment_name"},
  {"data_code": "dw", "field_name": "dw"},
  {"data_code": "treatment_time", "field_name": "treatment_time"},
  {"data_code": "va", "field_name": "va"},
  {"data_code": "target_weight", "field_name": "target_weight"},
  {"data_code": "water_removal_amount_limit", "field_name": "water_removal_amount_limit"},
  {"data_code": "dialyzer", "field_name": "dialyzer"},
  {"data_code": "adsorption_column", "field_name": "adsorption_column"},
  {"data_code": "primary_film", "field_name": "primary_film"},
  {"data_code": "secondary_film", "field_name": "secondary_film"},
  {"data_code": "puncture_needle_a", "field_name": "puncture_needle_a"},
  {"data_code": "puncture_needle_v", "field_name": "puncture_needle_v"},
  {"data_code": "puncture_needle_sn", "field_name": "puncture_needle_sn"},
  {"data_code": "single_needle", "field_name": "single_needle"},
  {"data_code": "blood_circuit", "field_name": "blood_circuit"},
  {"data_code": "blood_flow", "field_name": "blood_flow"},
  {"data_code": "dialysate", "field_name": "dialysate"},
  {"data_code": "dialysate_flow_rate", "field_name": "dialysate_flow_rate"},
  {"data_code": "dialysate_amount", "field_name": "dialysate_amount"},
  {"data_code": "dialysate_amount_unit", "field_name": "dialysate_amount_unit"},
  {"data_code": "dialysate_temperature", "field_name": "dialysate_temperature"},
  {"data_code": "fluid_replacement", "field_name": "fluid_replacement"},
  {"data_code": "fluid_replacement_amount", "field_name": "fluid_replacement_amount"},
  {"data_code": "fluid_replacement_timing", "field_name": "fluid_replacement_timing"},
  {"data_code": "fluid_replacement_use_count", "field_name": "fluid_replacement_use_count"},
  {"data_code": "fluid_replacement_use_count_unit", "field_name": "fluid_replacement_use_count_unit"},
  {"data_code": "fluid_replacement_temperature", "field_name": "fluid_replacement_temperature"},
  {"data_code": "fluid_replacement_speed", "field_name": "fluid_replacement_speed"},
  {"data_code": "anti_coagulant", "field_name": "anti_coagulant"},
  {"data_code": "anti_coagulant_one_shot_amount", "field_name": "anti_coagulant_one_shot_amount"},
  {"data_code": "anti_coagulant_one_shot_amount_unit", "field_name": "anti_coagulant_one_shot_amount_unit"},
  {"data_code": "anti_coagulant_sustained_speed", "field_name": "anti_coagulant_sustained_speed"},
  {"data_code": "anti_coagulant_sustained_speed_unit", "field_name": "anti_coagulant_sustained_speed_unit"},
  {"data_code": "anti_coagulant_sustained_amount", "field_name": "anti_coagulant_sustained_amount"},
  {"data_code": "anti_coagulant_sustained_amount_unit", "field_name": "anti_coagulant_sustained_amount_unit"},
  {"data_code": "ip", "field_name": "ip"},
  {"data_code": "ip_start", "field_name": "ip_start"},
  {"data_code": "ip_one_short_amount", "field_name": "ip_one_short_amount"},
  {"data_code": "ip_speed", "field_name": "ip_speed"},
  {"data_code": "ip_speed_max", "field_name": "ip_speed_max"},
  {"data_code": "auto_one_shot", "field_name": "auto_one_shot"},
  {"data_code": "ip_auto_off", "field_name": "ip_auto_off"},
  {"data_code": "ip_auto_off_time", "field_name": "ip_auto_off_time"},
  {"data_code": "ip_monitor_auto_off", "field_name": "ip_monitor_auto_off"},
  {"data_code": "ip_monitor_auto_off_time", "field_name": "ip_monitor_auto_off_time"}
]', '0', NULL, NULL, NULL, '2019-06-17 14:45:00.000', '2019-06-17 14:45:00.000')
;

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date)
VALUES
(6, 'select
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  a.complaint,
  b.row_no,
  b.treat_name,
  b.treat_medicine,
  b.amount,
  b.unit,
  b.procedure,
  c.treat_staff_name
from
  (
    select
      ord.ord_no,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint
    order by
      ord_no,
      occur_date) a
  full outer join
  (
    select
      ord.ord_no,
      treatment->>''occur_date'' as occur_date,
      treatment->>''row_no'' as row_no,
      case
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is not null then concat(''酸素吸入開始 '', to_char(cast(treatment->>''oxygen_speed'' as numeric), ''FM999999.00''), ''L/min'')
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is null then concat(''酸素吸入終了 '' , to_char(cast(treatment->>''oxygen_amount'' as numeric), ''FM999999.00''), ''L'')
        else treatment->>''treat_name'' end
      as treat_name,
      treatment->>''treat_medicine_name'' as treat_medicine,
      treatment->>''amount'' as amount,
      treatment->>''unit'' as unit,
      treatment->>''procedure_name'' as procedure
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
    order by
      ord_no,
      occur_date,
      row_no) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date
  left outer join
  (
    select
      ord.ord_no,
      treat_staff->>''occur_date'' as occur_date,
      treat_staff->>''row_no'' as row_no,
      treat_staff->>''treat_staff_name'' as treat_staff_name
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treat_staff_info::json) treat_staff
    order by
      ord_no,
      occur_date,
      row_no) c
  on b.ord_no = c.ord_no and b.occur_date = c.occur_date and b.row_no = c.row_no
where
  coalesce(a.ord_no, b.ord_no) = @ordNo
order by
  occur_time
', 2, '[
  {"data_code": "occur_time", "field_name": "occur_time"},
  {"data_code": "complaint", "field_name": "complaint"},
  {"data_code": "row_no", "field_name": "row_no"},
  {"data_code": "treat_name", "field_name": "treat_name"},
  {"data_code": "treat_medicine", "field_name": "treat_medicine"},
  {"data_code": "amount", "field_name": "amount"},
  {"data_code": "unit", "field_name": "unit"},
  {"data_code": "procedure", "field_name": "procedure"},
  {"data_code": "treat_staff_name", "field_name": "treat_staff_name"}
]', '1', NULL, NULL, NULL, '2019-06-17 14:45:00.000', '2019-06-17 14:45:00.000')
;

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

UPDATE sys_data_set
SET 
  "sql"=
'select
  *
from
  ord_main
where
  ord_no = @ordNo'
  , detail='
    [
      {
        "preview": "2011/3/12  08:21"
        , "can_calc": "0"
        , "data_code": "rst_start_date"
        , "data_name": "透析開始日時"
        , "data_type": "DateTime"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_start_date"
        , "disp_format": "hh:mm"
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "2011/3/12  12:45"
        , "can_calc": "0"
        , "data_code": "rst_end_date"
        , "data_name": "透析終了日時"
        , "data_type": "DateTime"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_end_date"
        , "disp_format": "hh:mm"
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
    ]'
WHERE 
  sql_cd=2
;

UPDATE 
  sys_data_set 
SET 
  "sql"=
'select
  hosp_pat_id,
  personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name,
  in_out_class
from
  pat_personal_main
where
  is_del = ''0''
and
  pat_id = @patId'
  , detail='
    [
      {
        "preview": "123456789012"
        , "can_calc": "0"
        , "data_code": "pat_id"
        , "data_name": "患者ID"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "基本情報"
        , "field_name": "hosp_pat_id"
        , "disp_format": ""
        , "data_category": "患者情報"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "日機装　太郎"
        , "can_calc": "0"
        , "data_code": "pat_name"
        , "data_name": "氏名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "基本情報"
        , "field_name": "pat_name"
        , "disp_format": ""
        , "data_category": "患者情報"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      ,{
        "preview": "0"
        , "can_calc": "0"
        , "data_code": "in_out_class"
        , "data_name": "入外区分"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "基本情報"
        , "field_name": "in_out_class"
        , "disp_format": ""
        , "data_category": "患者情報"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
    ]'
WHERE
  sql_cd=1
;

UPDATE
  sys_data_set
SET
  "sql" = '
    select
      medi ->> ''class_cd'' as medi_class_cd,
      medi ->> ''class_type'' as medi_class_type,
      medi ->> ''cd'' as medi_cd,
      medi ->> ''name'' as medi_name,
      medi ->> ''amount'' as medi_amount,
      medi ->> ''timing_name'' as medi_timing_name
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
    where
      ord.ord_no = @ordNo
  '
  , detail = '
    [
      {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "medi_class_cd"
        , "data_name": "薬剤分類コード"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_class_cd"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "medi_class_type"
        , "data_name": "分類区分"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_class_type"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "medi_cd"
        , "data_name": "薬剤(調整薬剤)コード"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_cd"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "テスト薬剤１"
        , "can_calc": "0"
        , "data_code": "medi_name"
        , "data_name": "薬剤名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_name"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "medi_amount"
        , "data_name": "数量"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_amount"
        , "disp_format": "0"
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
      , {
        "preview": "透析中"
        , "can_calc": "0"
        , "data_code": "medi_timing_name"
        , "data_name": "投与時間帯"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "投薬"
        , "field_name": "medi_timing_name"
        , "disp_format": ""
        , "data_category": "指示"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
    ]
  '
WHERE
  sql_cd = 4
;

UPDATE
  sys_data_set
SET
  "sql" = '
    select
      hosp_pat_id
      , personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name
      , in_out_class
      , pat_sex
    from
      pat_personal_main
    where
      is_del = ''0''
    and
      pat_id = @patId
  '
  , detail = '[
    {
      "preview": "123456789012"
      , "can_calc": "0"
      , "data_code": "pat_id"
      , "data_name": "患者ID"
      , "data_type": "string"
      , "conv_table": ""
      , "data_class": "基本情報"
      , "field_name": "hosp_pat_id"
      , "disp_format": ""
      , "data_category": "患者情報"
      , "facility_table": ""
      , "facility_filter_type": "0"
    }
    , {
      "preview": "日機装　太郎"
      , "can_calc": "0"
      , "data_code": "pat_name"
      , "data_name": "氏名"
      , "data_type": "string"
      , "conv_table": ""
      , "data_class": "基本情報"
      , "field_name": "pat_name"
      , "disp_format": ""
      , "data_category": "患者情報"
      , "facility_table": ""
      , "facility_filter_type": "0"
    }, {
      "preview": "0"
      , "can_calc": "0"
      , "data_code": "in_out_class"
      , "data_name": "入外区分"
      , "data_type": "string"
      , "conv_table": ""
      , "data_class": "基本情報"
      , "field_name": "in_out_class"
      , "disp_format": ""
      , "data_category": "患者情報"
      , "facility_table": ""
      , "facility_filter_type": "0"
    }, {
      "preview": "男性"
      , "can_calc": "0"
      , "data_code": "pat_sex"
      , "data_name": "性別"
      , "data_type": "string"
      , "conv_table": ""
      , "data_class": "基本情報"
      , "field_name": "pat_sex"
      , "disp_format": ""
      , "data_category": "患者情報"
      , "facility_table": ""
      , "facility_filter_type": "0"
    }
  ]'
WHERE
  sql_cd = 1
;

INSERT INTO
  sys_data_set
  (
    sql_cd
    , "sql"
    , db_class
    , detail
    , can_repeat
    , use_application
    , report_class
    , memo
    , reg_date
    , up_date
  )
VALUES
  (
    7
    , '
      select
        *
      from
        ord_main
      where
        pat_id = @patId
      order by rst_start_date desc
    '
    , 2
    , '[
      {
        "preview": "2011/3/12 08:21"
        , "can_calc": "0"
        , "data_code": "rst_start_date"
        , "data_name": "透析開始日時"
        , "data_type": "DateTime"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_start_date"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "rst_treatment_cd"
        , "data_name": "治療方法コード"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_treatment_cd"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "テスト治療方法"
        , "can_calc": "0"
        , "data_code": "rst_treatment_name"
        , "data_name": "治療方法名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_treatment_name"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "rst_kur_cd"
        , "data_name": "クールコード"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_kur_cd"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "テストクール"
        , "can_calc": "0"
        , "data_code": "rst_kur_name"
        , "data_name": "クール名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_kur_name"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "1"
        , "can_calc": "0"
        , "data_code": "rst_bed_cd"
        , "data_name": "ベッドコード"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_bed_cd"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "テストベッド"
        , "can_calc": "0"
        , "data_code": "rst_bed_name"
        , "data_name": "ベッド名"
        , "data_type": "string"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_bed_name"
        , "disp_format": ""
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }, {
        "preview": "55.00"
        , "can_calc": "1"
        , "data_code": "rst_dw"
        , "data_name": "DW"
        , "data_type": "decimal"
        , "conv_table": ""
        , "data_class": "実績情報"
        , "field_name": "rst_dw"
        , "disp_format": "0.00"
        , "data_category": "実績"
        , "facility_table": ""
        , "facility_filter_type": "0"
      }
    ]'
    , '1'
    , NULL
    , NULL
    , NULL
    , '2019-09-17 11:32:00.000'
    , '2019-09-17 11:32:00.000'
  )
;
