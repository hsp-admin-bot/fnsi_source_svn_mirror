UPDATE "ntss"."sys_data_set" SET "sql" = 'with mstcp_tbl as (
    select 
    comp_treatment_cd
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_1 else mstMedic.in_hospital_cd_1 end as treatMdeci_in_hospital_cd_1
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_2 else mstMedic.in_hospital_cd_2 end as treatMdeci_in_hospital_cd_2
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_3 else mstMedic.in_hospital_cd_3 end as treatMdeci_in_hospital_cd_3
    ,case treat_class when ''0'' then '''' else mstMedic.in_hospital_cd_4 end as treatMdeci_in_hospital_cd_4
    from mst_comp_treatment mstCpt
    left join mst_medicine_mix  as mstMedicMix  on (mstCpt.treat_medicine_cd = mstMedicMix.medicine_mix_cd      and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'')
    left join mst_medicine as  mstMedic  on (mstCpt.treat_medicine_cd = mstMedic.medicine_cd      and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'')
    where mstCpt.treat_class != ''2''
     and mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
)
  select
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''YYYY/MM/DD'')as occur_date,
  a.complaint,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
  treatMdeci_in_hospital_cd_4,
  b.amount,
  b.unit,
  b.receipt_value,
  b.unit_second,
  b.procedure_name,
  c.treat_staff_name,
  c.treat_staff_cd
from
  (
    select
      ord.ord_no,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint,
      complaint->>''row_no'' as row_no
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint
    where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord.ord_no = @ordNo
    and complaint->>''checkFlag'' = ''1''   
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
        when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is not null then ''心電図測定開始''
        when treatment->>''treat_class'' = ''4'' and treatment->>''electrocardiogram_start'' is null then ''心電図測定終了''
        else treatment->>''treat_name'' end
      as treat_name,
      treatment->>''treat_medicine_name'' as treat_medicine,
      treatment->>''amount'' as amount,
      treatment->>''unit'' as unit,
      treatment->>''procedure_name'' as procedure_name,
      mstcp_tbl.treatMdeci_in_hospital_cd_1,
      mstcp_tbl.treatMdeci_in_hospital_cd_2,
      mstcp_tbl.treatMdeci_in_hospital_cd_3,
      mstcp_tbl.treatMdeci_in_hospital_cd_4,
      save.receipt_value,
      mstMedic.unit_second
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
      left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment ->> ''treat_cd'')
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment->>''treat_medicine_cd''  = save.supplies_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      left join mst_medicine as  mstMedic  on (treatment->>''treat_medicine_cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
   where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
    and treatment->>''checkFlag'' = ''1''

union all 
select
    ord_no
    , to_char(event_reg_date, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') as occur_date
    , ''0'' as row_no 
    , machine_record_message as treat_name
    ,'''' as treat_medicine
    ,'''' as amount
    ,'''' as unit
    ,'''' as procedure_name
    ,'''' as treatMdeci_in_hospital_cd_1
    ,'''' as treatMdeci_in_hospital_cd_2
    ,'''' as treatMdeci_in_hospital_cd_3
    ,'''' as treatMdeci_in_hospital_cd_4
    ,'''' as receipt_value
    ,'''' as unit_second
from
    mnt_motion_record as mnt 
where
    mnt.ord_no = @ordNo 
    and mnt.report_disp_flg = ''1''     
     
order by
ord_no,
occur_date,
row_no   
    
     ) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date and a.row_no = b.row_no
  full outer join
  (
    select
      ord.ord_no,
      treat_staff->>''occur_date'' as occur_date,
      treat_staff->>''row_no'' as row_no,
      treat_staff->>''treat_staff_name'' as treat_staff_name,
      treat_staff->>''treat_staff_cd'' as treat_staff_cd
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treat_staff_info::json) treat_staff
    where ord.is_del = ''0''  and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
    and treat_staff->>''checkFlag'' = ''1''
    order by
      ord_no,
      occur_date,
      row_no) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.occur_date,b.occur_date) = c.occur_date and COALESCE(a.row_no, b.row_no) = c.row_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
order by
  coalesce(a.occur_date, b.occur_date, c.occur_date), to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'')', "db_class" = 2, "detail" = '[{"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "complaint", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置", "field_name": "amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置", "field_name": "receipt_value", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "unit_second", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [1, 2, 3, 11]}', "memo" = '実績：愁訴処置 @ordNo 使用', "reg_date" = '2020-03-31 23:59:59', "up_date" = '2020-05-19 00:00:00', "pre_sql_info" = NULL WHERE "sql_cd" = 6;


UPDATE "ntss"."sys_data_set" SET "sql" = 'select
  facility_cd,
  to_date(treat_date, ''yyyymmdd'') as treat_date,

  info->>''no'' as no,
  info->>''content'' as content,

  info->>''ind_user_id'' as ind_user_id,
  info->>''ind_user_last_name'' as ind_user_last_name,
  info->>''ind_user_first_name'' as ind_user_first_name,
  info->>''upd_user_id'' as upd_user_id,
  info->>''upd_user_last_name'' as upd_user_last_name,
  info->>''upd_user_first_name'' as upd_user_first_name,
  info->>''input_class'' as input_class,
  info->>''is_editable'' as is_editable,
  info->>''cop_order_no'' as cop_order_no,
  ind_treat_start_time as treat_date_start,
  null as treat_date_end
  -- equipinfo->>''needle_type'' as needle_type
from
  ord_main
    cross join lateral
      json_array_elements (ord_main.ind_ind_comment_info :: json) info
	cross join lateral	
	  json_array_elements (ord_main.ind_equip_info :: json) equipinfo
where
  ord_no = @ordNo
  and is_del = ''0'' order  by   treat_date_start,treat_date_end', "db_class" = 2, "detail" = '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "指示コメント", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "指示簿です。", "can_calc": "0", "data_code": "content", "data_name": "指示内容", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "content", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "ind_user_id", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "upd_user_id", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [1, 2, 3, 9, 10, 11]}', "memo" = '指示：指示簿(指示コメント)　@ordNo使用', "reg_date" = '2020-03-27 13:28:00', "up_date" = '2020-03-27 13:28:00', "pre_sql_info" = NULL WHERE "sql_cd" = 75;


UPDATE "ntss"."sys_data_set" SET "sql" = 'select
  facility_cd,
  to_date(treat_date, ''yyyymmdd'') as treat_date,

  info->>''no'' as no,
  info->>''content'' as content,

  info->>''ind_user_id'' as ind_user_id,
  info->>''ind_user_last_name'' as ind_user_last_name,
  info->>''ind_user_first_name'' as ind_user_first_name,
  info->>''upd_user_id'' as upd_user_id,
  info->>''upd_user_last_name'' as upd_user_last_name,
  info->>''upd_user_first_name'' as upd_user_first_name,
  info->>''input_class'' as input_class,
  info->>''is_editable'' as is_editable,
  info->>''cop_order_no'' as cop_order_no
from
  ord_main
    cross join lateral
      json_array_elements (ord_main.rst_ind_comment_info :: json) info
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <> ''0''
order by no
;', "db_class" = 2, "detail" = '[{"preview": "指示簿テストです。", "can_calc": "0", "data_code": "content", "data_name": "指示内容", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "content", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [1, 2, 3, 9, 10, 11]}', "memo" = '実績：指示簿(指示コメント) @ordNo 使用', "reg_date" = '2020-03-31 23:59:59', "up_date" = '2020-04-09 10:59:00', "pre_sql_info" = NULL WHERE "sql_cd" = 98;


UPDATE "ntss"."sys_data_set" SET "sql" = 'select
  facility_cd,
  to_date(treat_date, ''yyyymmdd'') as treat_date,

  info->>''no'' as no,
  info->>''content'' as content,

  info->>''ind_user_id'' as ind_user_id,
  info->>''ind_user_last_name'' as ind_user_last_name,
  info->>''ind_user_first_name'' as ind_user_first_name,
  info->>''upd_user_id'' as upd_user_id,
  info->>''upd_user_last_name'' as upd_user_last_name,
  info->>''upd_user_first_name'' as upd_user_first_name,
  info->>''input_class'' as input_class,
  info->>''is_editable'' as is_editable,
  info->>''cop_order_no'' as cop_order_no
from
  ord_main
    cross join lateral
      json_array_elements (ord_main.rst_ind_comment_info :: json) info
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''
order by no
;', "db_class" = 2, "detail" = '[{"preview": "指示簿テストです。", "can_calc": "0", "data_code": "content", "data_name": "指示内容", "data_type": "string", "conv_table": [], "data_class": "指示コメント", "field_name": "content", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [1, 2, 3, 9, 10, 11]}', "memo" = '実績（治療中）：指示簿(指示コメント) @ordNo 使用', "reg_date" = '2021-08-05 13:30:00', "up_date" = '2021-08-05 13:30:00', "pre_sql_info" = NULL WHERE "sql_cd" = 168;


UPDATE "ntss"."sys_data_set" SET "sql" = 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''2''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_start_date, ''YYYYMMDD'') AS event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') AS event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  
  ,(picked_result_params[1]->''result_value''->0)->>''name'' as data1_pic1_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_name'' as data1_pic1_file_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_path'' as data1_pic1_file_path
  ,(picked_result_params[1]->''result_value''->1)->>''name'' as data1_pic2_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_name'' as data1_pic2_file_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_path'' as data1_pic2_file_path
  ,(picked_result_params[1]->''result_value''->2)->>''name'' as data1_pic3_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_name'' as data1_pic3_file_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_path'' as data1_pic3_file_path
  ,(picked_result_params[1]->''result_value''->3)->>''name'' as data1_pic4_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_name'' as data1_pic4_file_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_path'' as data1_pic4_file_path
  ,(picked_result_params[1]->''result_value''->4)->>''name'' as data1_pic5_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_name'' as data1_pic5_file_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_path'' as data1_pic5_file_path
  ,(picked_result_params[1]->''result_value''->5)->>''name'' as data1_pic6_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_name'' as data1_pic6_file_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_path'' as data1_pic6_file_path
  ,(picked_result_params[1]->''result_value''->6)->>''name'' as data1_pic7_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_name'' as data1_pic7_file_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_path'' as data1_pic7_file_path
  ,(picked_result_params[1]->''result_value''->7)->>''name'' as data1_pic8_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_name'' as data1_pic8_file_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_path'' as data1_pic8_file_path
  ,(picked_result_params[1]->''result_value''->8)->>''name'' as data1_pic9_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_name'' as data1_pic9_file_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_path'' as data1_pic9_file_path
  
  ,(picked_result_params[2]->''result_value''->0)->>''name'' as data2_pic1_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_name'' as data2_pic1_file_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_path'' as data2_pic1_file_path
  ,(picked_result_params[2]->''result_value''->1)->>''name'' as data2_pic2_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_name'' as data2_pic2_file_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_path'' as data2_pic2_file_path
  ,(picked_result_params[2]->''result_value''->2)->>''name'' as data2_pic3_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_name'' as data2_pic3_file_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_path'' as data2_pic3_file_path
  ,(picked_result_params[2]->''result_value''->3)->>''name'' as data2_pic4_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_name'' as data2_pic4_file_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_path'' as data2_pic4_file_path
  ,(picked_result_params[2]->''result_value''->4)->>''name'' as data2_pic5_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_name'' as data2_pic5_file_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_path'' as data2_pic5_file_path
  ,(picked_result_params[2]->''result_value''->5)->>''name'' as data2_pic6_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_name'' as data2_pic6_file_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_path'' as data2_pic6_file_path
  ,(picked_result_params[2]->''result_value''->6)->>''name'' as data2_pic7_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_name'' as data2_pic7_file_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_path'' as data2_pic7_file_path
  ,(picked_result_params[2]->''result_value''->7)->>''name'' as data2_pic8_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_name'' as data2_pic8_file_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_path'' as data2_pic8_file_path
  ,(picked_result_params[2]->''result_value''->8)->>''name'' as data2_pic9_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_name'' as data2_pic9_file_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_path'' as data2_pic9_file_path
  
  ,(picked_result_params[3]->''result_value''->0)->>''name'' as data3_pic1_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_name'' as data3_pic1_file_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_path'' as data3_pic1_file_path
  ,(picked_result_params[3]->''result_value''->1)->>''name'' as data3_pic2_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_name'' as data3_pic2_file_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_path'' as data3_pic2_file_path
  ,(picked_result_params[3]->''result_value''->2)->>''name'' as data3_pic3_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_name'' as data3_pic3_file_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_path'' as data3_pic3_file_path
  ,(picked_result_params[3]->''result_value''->3)->>''name'' as data3_pic4_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_name'' as data3_pic4_file_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_path'' as data3_pic4_file_path
  ,(picked_result_params[3]->''result_value''->4)->>''name'' as data3_pic5_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_name'' as data3_pic5_file_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_path'' as data3_pic5_file_path
  ,(picked_result_params[3]->''result_value''->5)->>''name'' as data3_pic6_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_name'' as data3_pic6_file_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_path'' as data3_pic6_file_path
  ,(picked_result_params[3]->''result_value''->6)->>''name'' as data3_pic7_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_name'' as data3_pic7_file_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_path'' as data3_pic7_file_path
  ,(picked_result_params[3]->''result_value''->7)->>''name'' as data3_pic8_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_name'' as data3_pic8_file_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_path'' as data3_pic8_file_path
  ,(picked_result_params[3]->''result_value''->8)->>''name'' as data3_pic9_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_name'' as data3_pic9_file_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_path'' as data3_pic9_file_path
  
  ,(picked_result_params[4]->''result_value''->0)->>''name'' as data4_pic1_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_name'' as data4_pic1_file_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_path'' as data4_pic1_file_path
  ,(picked_result_params[4]->''result_value''->1)->>''name'' as data4_pic2_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_name'' as data4_pic2_file_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_path'' as data4_pic2_file_path
  ,(picked_result_params[4]->''result_value''->2)->>''name'' as data4_pic3_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_name'' as data4_pic3_file_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_path'' as data4_pic3_file_path
  ,(picked_result_params[4]->''result_value''->3)->>''name'' as data4_pic4_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_name'' as data4_pic4_file_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_path'' as data4_pic4_file_path
  ,(picked_result_params[4]->''result_value''->4)->>''name'' as data4_pic5_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_name'' as data4_pic5_file_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_path'' as data4_pic5_file_path
  ,(picked_result_params[4]->''result_value''->5)->>''name'' as data4_pic6_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_name'' as data4_pic6_file_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_path'' as data4_pic6_file_path
  ,(picked_result_params[4]->''result_value''->6)->>''name'' as data4_pic7_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_name'' as data4_pic7_file_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_path'' as data4_pic7_file_path
  ,(picked_result_params[4]->''result_value''->7)->>''name'' as data4_pic8_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_name'' as data4_pic8_file_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_path'' as data4_pic8_file_path
  ,(picked_result_params[4]->''result_value''->8)->>''name'' as data4_pic9_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_name'' as data4_pic9_file_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_path'' as data4_pic9_file_path
  
  ,(picked_result_params[5]->''result_value''->0)->>''name'' as data5_pic1_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_name'' as data5_pic1_file_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_path'' as data5_pic1_file_path
  ,(picked_result_params[5]->''result_value''->1)->>''name'' as data5_pic2_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_name'' as data5_pic2_file_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_path'' as data5_pic2_file_path
  ,(picked_result_params[5]->''result_value''->2)->>''name'' as data5_pic3_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_name'' as data5_pic3_file_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_path'' as data5_pic3_file_path
  ,(picked_result_params[5]->''result_value''->3)->>''name'' as data5_pic4_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_name'' as data5_pic4_file_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_path'' as data5_pic4_file_path
  ,(picked_result_params[5]->''result_value''->4)->>''name'' as data5_pic5_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_name'' as data5_pic5_file_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_path'' as data5_pic5_file_path
  ,(picked_result_params[5]->''result_value''->5)->>''name'' as data5_pic6_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_name'' as data5_pic6_file_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_path'' as data5_pic6_file_path
  ,(picked_result_params[5]->''result_value''->6)->>''name'' as data5_pic7_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_name'' as data5_pic7_file_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_path'' as data5_pic7_file_path
  ,(picked_result_params[5]->''result_value''->7)->>''name'' as data5_pic8_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_name'' as data5_pic8_file_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_path'' as data5_pic8_file_path
  ,(picked_result_params[5]->''result_value''->8)->>''name'' as data5_pic9_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_name'' as data5_pic9_file_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_path'' as data5_pic9_file_path
  
  ,(picked_result_params[6]->''result_value''->0)->>''name'' as data6_pic1_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_name'' as data6_pic1_file_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_path'' as data6_pic1_file_path
  ,(picked_result_params[6]->''result_value''->1)->>''name'' as data6_pic2_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_name'' as data6_pic2_file_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_path'' as data6_pic2_file_path
  ,(picked_result_params[6]->''result_value''->2)->>''name'' as data6_pic3_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_name'' as data6_pic3_file_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_path'' as data6_pic3_file_path
  ,(picked_result_params[6]->''result_value''->3)->>''name'' as data6_pic4_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_name'' as data6_pic4_file_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_path'' as data6_pic4_file_path
  ,(picked_result_params[6]->''result_value''->4)->>''name'' as data6_pic5_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_name'' as data6_pic5_file_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_path'' as data6_pic5_file_path
  ,(picked_result_params[6]->''result_value''->5)->>''name'' as data6_pic6_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_name'' as data6_pic6_file_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_path'' as data6_pic6_file_path
  ,(picked_result_params[6]->''result_value''->6)->>''name'' as data6_pic7_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_name'' as data6_pic7_file_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_path'' as data6_pic7_file_path
  ,(picked_result_params[6]->''result_value''->7)->>''name'' as data6_pic8_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_name'' as data6_pic8_file_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_path'' as data6_pic8_file_path
  ,(picked_result_params[6]->''result_value''->8)->>''name'' as data6_pic9_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_name'' as data6_pic9_file_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_path'' as data6_pic9_file_path
  
  ,(picked_result_params[7]->''result_value''->0)->>''name'' as data7_pic1_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_name'' as data7_pic1_file_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_path'' as data7_pic1_file_path
  ,(picked_result_params[7]->''result_value''->1)->>''name'' as data7_pic2_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_name'' as data7_pic2_file_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_path'' as data7_pic2_file_path
  ,(picked_result_params[7]->''result_value''->2)->>''name'' as data7_pic3_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_name'' as data7_pic3_file_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_path'' as data7_pic3_file_path
  ,(picked_result_params[7]->''result_value''->3)->>''name'' as data7_pic4_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_name'' as data7_pic4_file_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_path'' as data7_pic4_file_path
  ,(picked_result_params[7]->''result_value''->4)->>''name'' as data7_pic5_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_name'' as data7_pic5_file_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_path'' as data7_pic5_file_path
  ,(picked_result_params[7]->''result_value''->5)->>''name'' as data7_pic6_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_name'' as data7_pic6_file_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_path'' as data7_pic6_file_path
  ,(picked_result_params[7]->''result_value''->6)->>''name'' as data7_pic7_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_name'' as data7_pic7_file_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_path'' as data7_pic7_file_path
  ,(picked_result_params[7]->''result_value''->7)->>''name'' as data7_pic8_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_name'' as data7_pic8_file_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_path'' as data7_pic8_file_path
  ,(picked_result_params[7]->''result_value''->8)->>''name'' as data7_pic9_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_name'' as data7_pic9_file_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_path'' as data7_pic9_file_path
  
  ,(picked_result_params[8]->''result_value''->0)->>''name'' as data8_pic1_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_name'' as data8_pic1_file_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_path'' as data8_pic1_file_path
  ,(picked_result_params[8]->''result_value''->1)->>''name'' as data8_pic2_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_name'' as data8_pic2_file_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_path'' as data8_pic2_file_path
  ,(picked_result_params[8]->''result_value''->2)->>''name'' as data8_pic3_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_name'' as data8_pic3_file_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_path'' as data8_pic3_file_path
  ,(picked_result_params[8]->''result_value''->3)->>''name'' as data8_pic4_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_name'' as data8_pic4_file_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_path'' as data8_pic4_file_path
  ,(picked_result_params[8]->''result_value''->4)->>''name'' as data8_pic5_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_name'' as data8_pic5_file_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_path'' as data8_pic5_file_path
  ,(picked_result_params[8]->''result_value''->5)->>''name'' as data8_pic6_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_name'' as data8_pic6_file_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_path'' as data8_pic6_file_path
  ,(picked_result_params[8]->''result_value''->6)->>''name'' as data8_pic7_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_name'' as data8_pic7_file_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_path'' as data8_pic7_file_path
  ,(picked_result_params[8]->''result_value''->7)->>''name'' as data8_pic8_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_name'' as data8_pic8_file_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_path'' as data8_pic8_file_path
  ,(picked_result_params[8]->''result_value''->8)->>''name'' as data8_pic9_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_name'' as data8_pic9_file_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_path'' as data8_pic9_file_path
  
  ,(picked_result_params[9]->''result_value''->0)->>''name'' as data9_pic1_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_name'' as data9_pic1_file_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_path'' as data9_pic1_file_path
  ,(picked_result_params[9]->''result_value''->1)->>''name'' as data9_pic2_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_name'' as data9_pic2_file_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_path'' as data9_pic2_file_path
  ,(picked_result_params[9]->''result_value''->2)->>''name'' as data9_pic3_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_name'' as data9_pic3_file_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_path'' as data9_pic3_file_path
  ,(picked_result_params[9]->''result_value''->3)->>''name'' as data9_pic4_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_name'' as data9_pic4_file_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_path'' as data9_pic4_file_path
  ,(picked_result_params[9]->''result_value''->4)->>''name'' as data9_pic5_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_name'' as data9_pic5_file_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_path'' as data9_pic5_file_path
  ,(picked_result_params[9]->''result_value''->5)->>''name'' as data9_pic6_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_name'' as data9_pic6_file_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_path'' as data9_pic6_file_path
  ,(picked_result_params[9]->''result_value''->6)->>''name'' as data9_pic7_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_name'' as data9_pic7_file_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_path'' as data9_pic7_file_path
  ,(picked_result_params[9]->''result_value''->7)->>''name'' as data9_pic8_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_name'' as data9_pic8_file_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_path'' as data9_pic8_file_path
  ,(picked_result_params[9]->''result_value''->8)->>''name'' as data9_pic9_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_name'' as data9_pic9_file_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_path'' as data9_pic9_file_path
  
  ,(picked_result_params[10]->''result_value''->0)->>''name'' as data10_pic1_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_name'' as data10_pic1_file_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_path'' as data10_pic1_file_path
  ,(picked_result_params[10]->''result_value''->1)->>''name'' as data10_pic2_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_name'' as data10_pic2_file_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_path'' as data10_pic2_file_path
  ,(picked_result_params[10]->''result_value''->2)->>''name'' as data10_pic3_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_name'' as data10_pic3_file_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_path'' as data10_pic3_file_path
  ,(picked_result_params[10]->''result_value''->3)->>''name'' as data10_pic4_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_name'' as data10_pic4_file_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_path'' as data10_pic4_file_path
  ,(picked_result_params[10]->''result_value''->4)->>''name'' as data10_pic5_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_name'' as data10_pic5_file_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_path'' as data10_pic5_file_path
  ,(picked_result_params[10]->''result_value''->5)->>''name'' as data10_pic6_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_name'' as data10_pic6_file_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_path'' as data10_pic6_file_path
  ,(picked_result_params[10]->''result_value''->6)->>''name'' as data10_pic7_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_name'' as data10_pic7_file_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_path'' as data10_pic7_file_path
  ,(picked_result_params[10]->''result_value''->7)->>''name'' as data10_pic8_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_name'' as data10_pic8_file_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_path'' as data10_pic8_file_path
  ,(picked_result_params[10]->''result_value''->8)->>''name'' as data10_pic9_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_name'' as data10_pic9_file_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_path'' as data10_pic9_file_path

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', "db_class" = 2, "detail" = '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者情報", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "category_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "sub_category_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic1_name", "data_name": "データ1 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "データ1 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic2_name", "data_name": "データ1 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic2_file_name", "data_name": "データ1 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic3_name", "data_name": "データ1 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic3_file_name", "data_name": "データ1 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic4_name", "data_name": "データ1 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic4_file_name", "data_name": "データ1 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic5_name", "data_name": "データ1 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic5_file_name", "data_name": "データ1 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic6_name", "data_name": "データ1 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic6_file_name", "data_name": "データ1 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic7_name", "data_name": "データ1 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic7_file_name", "data_name": "データ1 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic8_name", "data_name": "データ1 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic8_file_name", "data_name": "データ1 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic9_name", "data_name": "データ1 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic9_file_name", "data_name": "データ1 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic1_name", "data_name": "データ2 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic1_file_name", "data_name": "データ2 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic2_name", "data_name": "データ2 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic2_file_name", "data_name": "データ2 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic3_name", "data_name": "データ2 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic3_file_name", "data_name": "データ2 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic4_name", "data_name": "データ2 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic4_file_name", "data_name": "データ2 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic5_name", "data_name": "データ2 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic5_file_name", "data_name": "データ2 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic6_name", "data_name": "データ2 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic6_file_name", "data_name": "データ2 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic7_name", "data_name": "データ2 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic7_file_name", "data_name": "データ2 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic8_name", "data_name": "データ2 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic8_file_name", "data_name": "データ2 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic9_name", "data_name": "データ2 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic9_file_name", "data_name": "データ2 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic1_name", "data_name": "データ3 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic1_file_name", "data_name": "データ3 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic2_name", "data_name": "データ3 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic2_file_name", "data_name": "データ3 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic3_name", "data_name": "データ3 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic3_file_name", "data_name": "データ3 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic4_name", "data_name": "データ3 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic4_file_name", "data_name": "データ3 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic5_name", "data_name": "データ3 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic5_file_name", "data_name": "データ3 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic6_name", "data_name": "データ3 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic6_file_name", "data_name": "データ3 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic7_name", "data_name": "データ3 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic7_file_name", "data_name": "データ3 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic8_name", "data_name": "データ3 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic8_file_name", "data_name": "データ3 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic9_name", "data_name": "データ3 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic9_file_name", "data_name": "データ3 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic1_name", "data_name": "データ4 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic1_file_name", "data_name": "データ4 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic2_name", "data_name": "データ4 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic2_file_name", "data_name": "データ4 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic3_name", "data_name": "データ4 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic3_file_name", "data_name": "データ4 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic4_name", "data_name": "データ4 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic4_file_name", "data_name": "データ4 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic5_name", "data_name": "データ4 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic5_file_name", "data_name": "データ4 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic6_name", "data_name": "データ4 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic6_file_name", "data_name": "データ4 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic7_name", "data_name": "データ4 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic7_file_name", "data_name": "データ4 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic8_name", "data_name": "データ4 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic8_file_name", "data_name": "データ4 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic9_name", "data_name": "データ4 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic9_file_name", "data_name": "データ4 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic1_name", "data_name": "データ5 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "graph.jpg", "can_calc": "0", "data_code": "data5_pic1_file_name", "data_name": "データ5 患者イベント(画像)1Image", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic2_name", "data_name": "データ5 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic2_file_name", "data_name": "データ5 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic3_name", "data_name": "データ5 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic3_file_name", "data_name": "データ5 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic4_name", "data_name": "データ5 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic4_file_name", "data_name": "データ5 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic5_name", "data_name": "データ5 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic5_file_name", "data_name": "データ5 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic6_name", "data_name": "データ5 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic6_file_name", "data_name": "データ5 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic7_name", "data_name": "データ5 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic7_file_name", "data_name": "データ5 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic8_name", "data_name": "データ5 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic8_file_name", "data_name": "データ5 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic9_name", "data_name": "データ5 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic9_file_name", "data_name": "データ5 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic1_name", "data_name": "データ6 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic1_file_name", "data_name": "データ6 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic2_name", "data_name": "データ6 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic2_file_name", "data_name": "データ6 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic3_name", "data_name": "データ6 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic3_file_name", "data_name": "データ6 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic4_name", "data_name": "データ6 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic4_file_name", "data_name": "データ6 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic5_name", "data_name": "データ6 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic5_file_name", "data_name": "データ6 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic6_name", "data_name": "データ6 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic6_file_name", "data_name": "データ6 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic7_name", "data_name": "データ6 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic7_file_name", "data_name": "データ6 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic8_name", "data_name": "データ6 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic8_file_name", "data_name": "データ6 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic9_name", "data_name": "データ6 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic9_file_name", "data_name": "データ6 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic1_name", "data_name": "データ7 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic1_file_name", "data_name": "データ7 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic2_name", "data_name": "データ7 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic2_file_name", "data_name": "データ7 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic3_name", "data_name": "データ7 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic3_file_name", "data_name": "データ7 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic4_name", "data_name": "データ7 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic4_file_name", "data_name": "データ7 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic5_name", "data_name": "データ7 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic5_file_name", "data_name": "データ7 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic6_name", "data_name": "データ7 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic6_file_name", "data_name": "データ7 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic7_name", "data_name": "データ7 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic7_file_name", "data_name": "データ7 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic8_name", "data_name": "データ7 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic8_file_name", "data_name": "データ7 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic9_name", "data_name": "データ7 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic9_file_name", "data_name": "データ7 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic1_name", "data_name": "データ8 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic1_file_name", "data_name": "データ8 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic2_name", "data_name": "データ8 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic2_file_name", "data_name": "データ8 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic3_name", "data_name": "データ8 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic3_file_name", "data_name": "データ8 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic4_name", "data_name": "データ8 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic4_file_name", "data_name": "データ8 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic5_name", "data_name": "データ8 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic5_file_name", "data_name": "データ8 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic6_name", "data_name": "データ8 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic6_file_name", "data_name": "データ8 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic7_name", "data_name": "データ8 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic7_file_name", "data_name": "データ8 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic8_name", "data_name": "データ8 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic8_file_name", "data_name": "データ8 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic9_name", "data_name": "データ8 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic9_file_name", "data_name": "データ8 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic1_name", "data_name": "データ9 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic1_file_name", "data_name": "データ9 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic2_name", "data_name": "データ9 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic2_file_name", "data_name": "データ9 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic3_name", "data_name": "データ9 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic3_file_name", "data_name": "データ9 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic4_name", "data_name": "データ9 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic4_file_name", "data_name": "データ9 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic5_name", "data_name": "データ9 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic5_file_name", "data_name": "データ9 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic6_name", "data_name": "データ9 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic6_file_name", "data_name": "データ9 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic7_name", "data_name": "データ9 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic7_file_name", "data_name": "データ9 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic8_name", "data_name": "データ9 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic8_file_name", "data_name": "データ9 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic9_name", "data_name": "データ9 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic9_file_name", "data_name": "データ9 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic1_name", "data_name": "データ10 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic1_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic1_file_name", "data_name": "データ10 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic1_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic2_name", "data_name": "データ10 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic2_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic2_file_name", "data_name": "データ10 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic2_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic3_name", "data_name": "データ10 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic3_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic3_file_name", "data_name": "データ10 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic3_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic4_name", "data_name": "データ10 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic4_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic4_file_name", "data_name": "データ10 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic4_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic5_name", "data_name": "データ10 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic5_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic5_file_name", "data_name": "データ10 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic5_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic6_name", "data_name": "データ10 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic6_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic6_file_name", "data_name": "データ10 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic6_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic7_name", "data_name": "データ10 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic7_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic7_file_name", "data_name": "データ10 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic7_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic8_name", "data_name": "データ10 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic8_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic8_file_name", "data_name": "データ10 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic8_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic9_name", "data_name": "データ10 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic9_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic9_file_name", "data_name": "データ10 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic9_file_name", "disp_format": "", "filter_type": "Event", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [1, 2, 3, 9, 11]}', "memo" = '患者情報：患者イベント 画像　@patId @fromDate @toDate使用', "reg_date" = '2021-08-26 00:00:22', "up_date" = '2021-08-26 00:00:22', "pre_sql_info" = NULL WHERE "sql_cd" = 86;
