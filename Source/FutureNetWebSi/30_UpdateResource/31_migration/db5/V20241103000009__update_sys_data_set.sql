DELETE FROM "ntss"."sys_data_set" where sql_cd in (6);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (6, 'with mstcp_tbl as (
    select
    distinct comp_treatment_cd
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_1 else mstMedic.in_hospital_cd_1 end as treatMdeci_in_hospital_cd_1
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_2 else mstMedic.in_hospital_cd_2 end as treatMdeci_in_hospital_cd_2
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_3 else mstMedic.in_hospital_cd_3 end as treatMdeci_in_hospital_cd_3
		,case treat_class when ''0'' then '''' else mstMedic.in_hospital_cd_4 end as treatMdeci_in_hospital_cd_4
		,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b1
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b1
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a1
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b1
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a1
			 else ''''
		 end as comptreat_in_hospital_cd_1
 		,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b2
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b2
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a2
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b2
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a2
			 else ''''
		 end as comptreat_in_hospital_cd_2
  	,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b3
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b3
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a3
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b3
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a3
			 else ''''
		 end as comptreat_in_hospital_cd_3
   	,case 
			 when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_b4
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP is null then mstCpt.in_hospital_cd_b4
		   when mstCpt.in_hosp_b_startdate :: TIMESTAMP < mstCpt.in_hosp_a_startdate :: TIMESTAMP and mstCpt.in_hosp_a_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_a4
		   when mstCpt.in_hosp_a_startdate :: TIMESTAMP < mstCpt.in_hosp_b_startdate :: TIMESTAMP and mstCpt.in_hosp_b_startdate :: TIMESTAMP <= ord.treat_date :: TIMESTAMP then mstCpt.in_hospital_cd_b4
		   when ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_a_startdate :: TIMESTAMP and ord.treat_date :: TIMESTAMP = mstCpt.in_hosp_b_startdate :: TIMESTAMP then mstCpt.in_hospital_cd_a4
			 else ''''
		 end as comptreat_in_hospital_cd_4
    from ord_main as ord		
		cross join lateral
      json_array_elements (ord.rst_treatment_info::json) info		
    inner join mst_comp_treatment as mstCpt on (info ->> ''treat_cd'' = mstCpt.comp_treatment_cd :: TEXT and ord.is_del = ''0'')
    left join mst_medicine_mix  as mstMedicMix  on (mstCpt.treat_medicine_cd = mstMedicMix.medicine_mix_cd      and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'')
    left join mst_medicine as  mstMedic  on (mstCpt.treat_medicine_cd = mstMedic.medicine_cd      and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'')
    where
     mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
		 and mstCpt.facility_cd = @facilityCd
		 and ord.ord_no = @ordNo
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
	b.comptreat_in_hospital_cd_1,
	b.comptreat_in_hospital_cd_2,
	b.comptreat_in_hospital_cd_3,
	b.comptreat_in_hospital_cd_4,
  b.amount,
  b.unit,
  b.receipt_value,
  b.unit_second,
  b.procedure_name,
  c.treat_staff_name,
  c.treat_staff_cd,
	@ordNo as ord_no
from
  (
    select
      ord.ord_no,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint,
      complaint->>''row_no'' as row_no,
      complaint->>''ctl_no'' as ctl_no,
      complaint->>''checkFlag'' as checkFlag
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint 
    where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord.ord_no = @ordNo
    --↓画面上で追加している項目の追加処理
    union
    select ord_no, rst_start_date::text as occur_date, ''治療開始'' as complaint, null, null, ''1'' as checkFlag from ord_main where ord_no = @ordNo and rst_start_date is not null
    union
    select ord_no, rst_end_date::text as occur_date, ''治療終了'' as complaint, ''999'', ''999'', ''1'' as checkFlag from ord_main where ord_no = @ordNo and rst_end_date is not null
    --↑画面上で追加している項目の追加処理
order by
      ord_no,
      occur_date) a
  full outer join
  (
    select
      ord.ord_no,
      treatment->>''occur_date'' as occur_date,
      treatment->>''row_no'' as row_no,
      treatment->>''ctl_no'' as ctl_no,
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
      mstcp_tbl.comptreat_in_hospital_cd_1,
      mstcp_tbl.comptreat_in_hospital_cd_2,
      mstcp_tbl.comptreat_in_hospital_cd_3,
      mstcp_tbl.comptreat_in_hospital_cd_4,
      save.receipt_value,
      case when treatment->>''medicine_type'' = ''1''  then  mstMedic.unit_second else '''' end unit_second,
      treatment->>''checkFlag'' as checkFlag
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
      left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment ->> ''treat_cd'')
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment->>''treat_medicine_cd''  = save.supplies_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2''
			and treatment->>''ctl_no'' = save.medicine_no ->>''ctl_no'' and treatment->>''row_no'' = save.medicine_no ->>''row_no'')
      left join mst_medicine as  mstMedic  on (treatment->>''treat_medicine_cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
   where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
union all
select
    ord_no
    , to_char(event_reg_date, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') as occur_date
    , ''0'' as row_no
    , ''0'' as ctl_no
    , machine_record_message as treat_name
    ,'''' as treat_medicine
    ,'''' as amount
    ,'''' as unit
    ,'''' as procedure_name
    ,'''' as treatMdeci_in_hospital_cd_1
    ,'''' as treatMdeci_in_hospital_cd_2
    ,'''' as treatMdeci_in_hospital_cd_3
    ,'''' as treatMdeci_in_hospital_cd_4
    ,'''' as comptreat_in_hospital_cd_1
    ,'''' as comptreat_in_hospital_cd_2
    ,'''' as comptreat_in_hospital_cd_3
    ,'''' as comptreat_in_hospital_cd_4
    ,'''' as receipt_value
    ,'''' as unit_second
    ,mnt.report_disp_flg as checkFlag
from
    mnt_motion_record as mnt
		LEFT JOIN (
	SELECT
		a.machine_record_cd,
		COALESCE ( b.disp_flg, a.disp_flg ) AS disp_flg
	FROM
		mst_machine_record a
		LEFT JOIN mst_machine_record_control b ON a.machine_record_cd = b.machine_record_cd
		WHERE facility_cd = @facilityCd
) t2 ON mnt.machine_record_cd = t2.machine_record_cd
where
    mnt.facility_cd = @facilityCd
    and mnt.ord_no = @ordNo
    and mnt.report_disp_flg = ''1''
    and t2.disp_flg <> ''0''
order by
ord_no,
occur_date,
row_no

     ) b
  on a.ord_no = b.ord_no and a.row_no = b.row_no and a.ctl_no = b.ctl_no
  full outer join
  (
    select
      ord.ord_no,
      treat_staff->>''occur_date'' as occur_date,
      treat_staff->>''row_no'' as row_no,
      treat_staff->>''ctl_no'' as ctl_no,
      treat_staff->>''treat_staff_name'' as treat_staff_name,
      treat_staff->>''treat_staff_cd'' as treat_staff_cd,
      treat_staff->>''checkFlag'' as checkFlag
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treat_staff_info::json) treat_staff
    where ord.is_del = ''0''  and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
    order by
      ord_no,
      occur_date,
      row_no) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.row_no, b.row_no) = c.row_no and COALESCE(a.ctl_no, b.ctl_no) = c.ctl_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
  and (a.checkFlag = ''1'' or (a.checkFlag is null and b.checkFlag = ''1'') or (a.checkFlag is null and b.checkFlag is null and c.checkFlag = ''1''))
order by
  occur_date, occur_time, to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'') nulls first', 2, '[{"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "complaint", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_1", "data_name": "処置連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_2", "data_name": "処置連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_3", "data_name": "処置連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_4", "data_name": "処置連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "comptreat_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "処置薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_4", "data_name": "処置薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treatmdeci_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置", "field_name": "amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置", "field_name": "receipt_value", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "unit_second", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 11]}', '実績：愁訴処置 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
