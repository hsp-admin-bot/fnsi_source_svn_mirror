DELETE FROM "ntss"."sys_data_set" where sql_cd in (199,200);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (199, 'WITH DATA AS (

with mstcp_tbl as (
select
   distinct comp_treatment_cd
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
    inner join mst_comp_treatment as mstCpt on (info ->> ''treat_cd'' = mstCpt.comp_treatment_cd ::text and ord.is_del = ''0'')
    where
     mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
		 and mstCpt.facility_cd = @facilityCd
		 and ord.ord_no = @ordNo
)

select
	@ordNo as ord_no_t,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''YYYY/MM/DD'')as occur_date,
  a.complaint,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
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
  c.treat_staff_cd
from
  (
    select
      ord.ord_no,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint,
      complaint->>''row_no'' as row_no,
      complaint->>''checkFlag'' as checkFlag
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint
    where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord.ord_no = @ordNo
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
      mstMedic.in_hospital_cd_1 as treatMdeci_in_hospital_cd_1,
      mstMedic.in_hospital_cd_2 as treatMdeci_in_hospital_cd_2,
      mstMedic.in_hospital_cd_3 as treatMdeci_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_1,
			mstcp_tbl.comptreat_in_hospital_cd_2,
			mstcp_tbl.comptreat_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_4,
      save.receipt_value,
      case when treatment->>''checkFlag'' = ''1'' then mstMedic.unit_second else '''' end unit_second,
      treatment->>''checkFlag'' as checkFlag
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
			left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment ->> ''treat_cd'')
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment->>''treat_medicine_cd''  = save.supplies_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      and treatment ->>''ctl_no'' = save.medicine_no ->>''ctl_no'' and treatment ->> ''row_no'' = save.medicine_no ->> ''row_no''
      left join mst_medicine as  mstMedic  on (treatment->>''treat_medicine_cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
   where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
    and treatment->>''medicine_type'' = ''1''
union all
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
      mstMedic.medicine_name as treat_medicine,
      save.ind_rst_value as amount,
      mstMedic.unit as unit,
      treatment->>''procedure_name'' as procedure_name,
      mstMedic.in_hospital_cd_1 as treatMdeci_in_hospital_cd_1,
      mstMedic.in_hospital_cd_2 as treatMdeci_in_hospital_cd_2,
      mstMedic.in_hospital_cd_3 as treatMdeci_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_1,
			mstcp_tbl.comptreat_in_hospital_cd_2,
			mstcp_tbl.comptreat_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_4,			
      save.receipt_value,
      case when treatment->>''checkFlag'' = ''1'' then mstMedic.unit_second else '''' end unit_second,
      treatment->>''checkFlag'' as checkFlag
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
			left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment ->> ''treat_cd'')
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment->>''treat_medicine_cd''  = save.medicine_mix_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      and treatment ->>''ctl_no'' = save.medicine_no ->>''ctl_no'' and treatment ->> ''row_no'' = save.medicine_no ->> ''row_no''
      inner join mst_medicine as  mstMedic  on (save.supplies_cd = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
   where ord.is_del = ''0'' and ord.rst_dialysis_state <> ''0''
    and ord_no = @ordNo
    and treatment->>''medicine_type'' = ''2''
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
		,'''' as comptreat_in_hospital_cd_1
    ,'''' as comptreat_in_hospital_cd_2
    ,'''' as comptreat_in_hospital_cd_3
    ,'''' as comptreat_in_hospital_cd_4
    ,'''' as receipt_value
    ,'''' as unit_second
    , mnt.report_disp_flg as checkFlag
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
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.row_no, b.row_no) = c.row_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
  and (a.checkFlag = ''1'' or (a.checkFlag is null and b.checkFlag = ''1'') or (a.checkFlag is null and b.checkFlag is null and c.checkFlag = ''1''))
order by
  coalesce(a.occur_date, b.occur_date, c.occur_date), to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'')

	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no as ordnob,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ordnob
	;
	', 2, '[{"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "complaint", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_1", "data_name": "処置連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_2", "data_name": "処置連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_3", "data_name": "処置連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_4", "data_name": "処置連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "処置薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "receipt_value", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "unit_second", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3]}', '実績：愁訴処置（分解） @ordNo 使用', '2021-11-29 13:29:36.254', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (200, 'WITH DATA AS (

	with ord_tbl AS (
--     SELECT
--         ord_no
--         , facility_cd
--     FROM
--         ord_main
        SELECT
        ord_no
                , medi
                , json_idx
        , facility_cd
    FROM
        ord_main
                CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
        AND ord_no = @ordNo
)
, medicine_order AS (
    select
        one_json ->> ''code'' as medicine_cd
        , json_idx as medicine_cd_order
    from
        mst_selector
        cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
    where
        facility_cd = (select facility_cd from ord_tbl limit 1)
        and master_physical_name = ''mst_medicine''
)
select
    @ordNo as ord_no_t
		,sv.supplies_cd
    , med.medicine_name as medicine_name
    , md.medicine_cd_order
    , med_clss.class_name as medi_class_name
    , sum(sv.ind_rst_value :: NUMERIC) as amount
    , med.unit
    ,sum(sv.receipt_value :: NUMERIC) as receipt_value
    ,med.unit_second as unit_second
--     , med.in_hospital_cd_1 as med_in_hospital_cd_1
--     , med.in_hospital_cd_2 as med_in_hospital_cd_2
--     , med.in_hospital_cd_3 as med_in_hospital_cd_3
--
-- from
--     ord_material_save sv
        , med_clss.class_cd as medi_class_cd
        , case when ord_tbl.medi ->> ''medicine_type'' is null then ''0'' else ord_tbl.medi ->> ''medicine_type'' end as medicine_type
    , med.in_hospital_cd_1 as med_in_hospital_cd_1
    , med.in_hospital_cd_2 as med_in_hospital_cd_2
    , med.in_hospital_cd_3 as med_in_hospital_cd_3

from
    ord_material_save sv
        left join ord_tbl as ord_tbl
        on (sv.supplies_cd = ord_tbl.medi ->> ''cd'' ::text)
        and sv.medicine_no ->>''no'' = ord_tbl.medi ->>''no'' 
    left join medicine_order md
        on (
            sv.supplies_base_no = sv.supplies_base_no
            and sv.supplies_cd = md.medicine_cd
        )
    inner join mst_medicine as med
        on (sv.supplies_cd = med.medicine_cd ::text)
    left join mst_medicine_class as med_clss
        on (med_clss.class_cd = med.class_cd)
where
    sv.supplies_base_no = @ordNo
    and sv.supplies_source_class in (''1'', ''3'')
    and sv.ind_rst_class = ''2''
group by
    sv.supplies_cd
    , medicine_name
    , medicine_cd_order
    , class_name
    , unit
    ,unit_second
        , medi_class_cd--
        , medicine_type--
    , med_in_hospital_cd_1
    , med_in_hospital_cd_2
    , med_in_hospital_cd_3

order by
    medicine_cd_order asc


	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no as ordnob,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ordnob
	;
	', 2, '[{"preview": "実施薬剤１", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "錠", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_1", "data_name": "実施薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_2", "data_name": "実施薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_3", "data_name": "実施薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "med_in_hospital_cd_4", "data_name": "実施薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "実施薬剤（分解）", "field_name": "med_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3]}', '実績：実施薬剤（分解） @ordNo 使用', '2021-11-05 11:30:03', CURRENT_TIMESTAMP, NULL);
