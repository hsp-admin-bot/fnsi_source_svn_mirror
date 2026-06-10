DELETE from sys_data_set where sql_cd = 33;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (33, 'with off_water_tbl as (
  select
    case when extract(dow from date) = 0 then off_water_info->''7''
      when extract(dow from date) = 1 then off_water_info->''1''
      when extract(dow from date) = 2 then off_water_info->''2''
      when extract(dow from date) = 3 then off_water_info->''3''
      when extract(dow from date) = 4 then off_water_info->''4''
      when extract(dow from date) = 5 then off_water_info->''5''
      when extract(dow from date) = 6 then off_water_info->''6''
      else null
    end as off_water_info
  from (
    select
      date_trunc(''day'', @date::timestamp) as date,
      off_water_info
    from
      pat_main
    where
      pat_id = @patId and is_del = ''0''
  ) as pat_main
)

select
  off_water_info->>''name_1'' as name_1,
  off_water_info->>''weight_1'' as weight_1,
  off_water_info->>''name_2'' as name_2,
  off_water_info->>''weight_2'' as weight_2,
  off_water_info->>''name_3'' as name_3,
  off_water_info->>''weight_3'' as weight_3,
  off_water_info->>''name_4'' as name_4,
  off_water_info->>''weight_4'' as weight_4,
  off_water_info->>''name_5'' as name_5,
  off_water_info->>''weight_5'' as weight_5,
  to_number(off_water_info->>''weight_1'', ''999999'')
    + to_number(off_water_info->>''weight_2'', ''999999'')
    + to_number(off_water_info->>''weight_3'', ''999999'')
    + to_number(off_water_info->>''weight_4'', ''999999'')
    + to_number(off_water_info->>''weight_5'', ''999999'')
 as weight_sum
from
  off_water_tbl
;', 2, '[{"preview": "食事量", "can_calc": "0", "data_code": "name_1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_1", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "name_2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "weight_2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_2", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "name_3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_3", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_3", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "name_4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_4", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_4", "data_name": "除水補正重量４", "data_type": "decima", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_4", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "name_5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_5", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_5", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "0", "data_code": "weight_sum", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_sum", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：除水補正　@patId @date使用', '2020-03-25 20:23:00', current_timestamp, NULL);
