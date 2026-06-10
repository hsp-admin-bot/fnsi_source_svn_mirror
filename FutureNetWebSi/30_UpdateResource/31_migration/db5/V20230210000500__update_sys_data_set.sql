DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (149);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (
149
,'with
eq as
(    select
         equipment_name,equipment_cd
     from
         mst_equipment
     where         is_del = ''0''         and is_disp = ''1''                 and facility_cd =@facilityCd  )    ,
md as
(    select
        medicine_name,medicine_cd
     from
         mst_medicine
     where         is_del = ''0''         and is_disp = ''1''                 and facility_cd =@facilityCd  )      ,
dz as
(
      select  
        model_number, dialyzer_cd  
      from  
        mst_dialyzer   
      where        is_del = ''0''         and is_disp = ''1''                 and facility_cd =@facilityCd  )

select
       supplies_base_date
     , supplies_source_class
     , supplies_class
     , supplies_cd
     , medicine_mix_cd
     , class_cd
     , ind_rst_value
     , receipt_value
     , case sv.supplies_class
         when ''01'' then (dz.model_number)
         when ''00'' then (eq.equipment_name)
         when ''02'' then (eq.equipment_name)
         when ''03'' then (eq.equipment_name)
         when ''04'' then (eq.equipment_name)
         when ''05'' then (eq.equipment_name)
         when ''06'' then (eq.equipment_name)
         when ''07'' then (eq.equipment_name)
         when ''11'' then (eq.equipment_name)
         when ''08'' then (md2.medicine_name)
         when ''09'' then (md2.medicine_name)
         when ''10'' then (md2.medicine_name)
         when ''12'' then (md2.medicine_name)
         when ''13'' then (md1.medicine_name)
         when ''14'' then (md2.medicine_name)
         when ''15'' then (md1.medicine_name)
         when ''16'' then (md2.medicine_name)
         when ''17'' then (md2.medicine_name)
         else ''''
         end as supplies_name
from     ord_material_save as sv
LEFT OUTER JOIN eq ON eq.equipment_cd = TO_NUMBER(sv.supplies_cd, ''99999999'') 
LEFT OUTER JOIN md AS md1 ON md1.medicine_cd = TO_NUMBER(CASE WHEN sv.medicine_mix_cd ='''' THEN NULL ELSE sv.medicine_mix_cd END, ''99999999'')
LEFT OUTER JOIN md AS md2 ON md2.medicine_cd = TO_NUMBER(CASE WHEN sv.medicine_mix_cd ='''' THEN NULL ELSE sv.supplies_cd END, ''99999999'')
LEFT OUTER JOIN dz ON dz.dialyzer_cd = TO_NUMBER(sv.supplies_cd, ''99999999'')
where     sv.facility_cd = @facilityCd
      and sv.supplies_base_date >= to_char(date_trunc(''day'', ( @fromDate  )::timestamp), ''yyyymmdd'')
      and sv.supplies_base_date <= @toDate
      and sv.pat_id in (@patIds)'
,2
,'[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "supplies_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_name", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "supplies_base_date", "data_name": "データ基準日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "supplies_base_date", "disp_format": "yyyy/mm/dd", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ind_rst_value", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "ind_rst_value", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_unitH", "data_name": "各日医材合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "total_unitH", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_unitV", "data_name": "医材計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "total_unitV", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]',
'1'
,'{"applications": [1]}'
,'{"classes": [11]}'
,'薬剤週間薬剤集計表　@patId @facilityCd  @fromdate  @todate'
,'2021-04-25 16:40:02'
, CURRENT_TIMESTAMP
,'[]'
);
