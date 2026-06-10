update ntss.sys_data_set set "sql"='with mstcp_tbl as (
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
  a.complaint,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
  treatMdeci_in_hospital_cd_4,
  b.amount,
  b.unit,
  b.procedure,
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
	where ord.is_del = ''0'' and ord.rst_dialysis_state >''0'' and ord.rst_dialysis_state <''6''
	and ord.ord_no = @ordNo
	and complaint->>''checkFlag'' = ''true''
union all 
select
	ord_no
	, to_char(event_reg_date, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') as occur_date
	, machine_record_message as complaint
	, ''0'' as row_no 
from
	mnt_motion_record as mnt 
where
	mnt.ord_no = @ordNo 
	and mnt.report_disp_flg = ''1''    
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
	treatment->>''procedure_name'' as procedure,
	mstcp_tbl.treatMdeci_in_hospital_cd_1,
	mstcp_tbl.treatMdeci_in_hospital_cd_2,
	mstcp_tbl.treatMdeci_in_hospital_cd_3,
	mstcp_tbl.treatMdeci_in_hospital_cd_4
from
	ord_main as ord LEFT JOIN mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text) in (select
	treatmentA ->> ''treat_cd'' as treat_cd
from
	ntss.ord_main ordmain cross
	join lateral json_array_elements (ordmain.rst_treatment_info::json ) treatmentA
where
	ordmain.ord_no = @ordNo
	and ordmain.rst_dialysis_state > ''0'' and ordmain.rst_dialysis_state < ''6'')
	cross join lateral
	json_array_elements (ord.rst_treatment_info::json) treatment
	where ord.is_del = ''0'' and ord.rst_dialysis_state > ''0'' and ord.rst_dialysis_state < ''6''
	and ord_no = @ordNo
	and treatment->>''checkFlag'' = ''true''
order by
	ord_no,
	occur_date,
	row_no) b
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
	where ord.is_del = ''0''  and ord.rst_dialysis_state>''0'' and ord.rst_dialysis_state<''6''
	and ord_no = @ordNo
	and treat_staff->>''checkFlag'' = ''true''
order by
	ord_no,
	occur_date,
	row_no) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.occur_date,b.occur_date) = c.occur_date and COALESCE(a.row_no, b.row_no) = c.row_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
order by
  coalesce(a.occur_date, b.occur_date, c.occur_date), to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'')',db_class=2,detail='[{"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "complaint", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置", "field_name": "amount", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "unit", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]',can_repeat='1',use_application='{"applications": [1]}',report_class='{"classes": [1, 2, 3]}',memo='実績（治療中）：愁訴処置 @ordNo 使用',reg_date='2021-08-05T13:30:00',up_date='2021-08-05T13:30:00',pre_sql_info=null where sql_cd=163;
