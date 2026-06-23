DELETE FROM "ntss"."sys_data_set" where sql_cd in (199,259);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (199, 'WITH DATA AS (
with ord_base as(
select *  from ord_main as ord	where  ord.facility_cd = @facilityCd  and ord.ord_no = @ordNo and ord.rst_dialysis_state <> ''0''
)
,treatment_info as(
 select
      ord.ord_no,
      ord.treat_date,
			treatment->>''treat_cd'' as treat_cd,
      treatment->>''occur_date'' as occur_date,
      treatment->>''complaint'' as complaint,
      treatment->>''row_no'' as row_no,
			treatment->>''ctl_no'' as ctl_no,
      treatment->>''checkFlag'' as checkFlag,
			treatment->>''treat_class'' as treat_class,
			treatment->>''oxygen_start'' as oxygen_start,
			treatment->>''electrocardiogram_start'' as electrocardiogram_start,
			treatment->>''oxygen_speed'' as oxygen_speed,
      treatment->>''oxygen_amount'' as oxygen_amount,
			treatment->>''treat_name'' as treat_name,
			treatment->>''treat_medicine_name'' as treat_medicine,
			treatment->>''amount'' as amount,
      treatment->>''unit'' as unit,
      treatment->>''procedure_name'' as procedure_name,
			treatment->>''treat_medicine_cd'' as treat_medicine_cd,
			treatment->>''medicine_type'' as medicine_type
    from
      ord_base as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
)
,complaint_info as(
 select
      ord.ord_no,
      ord.treat_date,
			complaint->>''comp_cd'' as comp_cd,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint,
      complaint->>''row_no'' as row_no,
			complaint->>''ctl_no'' as ctl_no,
      complaint->>''checkFlag'' as checkFlag
    from
      ord_base as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint
)
,treat_staff_info as( 
		select
      ord.ord_no,
      treat_staff->>''occur_date'' as occur_date,
      treat_staff->>''row_no'' as row_no,
			treat_staff->>''ctl_no'' as ctl_no,
      treat_staff->>''treat_staff_name'' as treat_staff_name,
      treat_staff->>''treat_staff_cd'' as treat_staff_cd,
      treat_staff->>''checkFlag'' as checkFlag
    from
      ord_base as ord
    cross join lateral
      json_array_elements (ord.rst_treat_staff_info::json) treat_staff)
,mstcp_tbl as (
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
    from treatment_info as ord 		
    inner join mst_comp_treatment as mstCpt on ord.treat_cd = mstCpt.comp_treatment_cd ::text 
    where
     mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
		 and mstCpt.facility_cd = @facilityCd
)
,mstcmp_tbl as (
  select 
	ord.ord_no,
  ord.treat_date,
  complaint_cd,
	mstCmp.in_hospital_cd_1 as cmp_in_hospital_cd_1,
	mstCmp.in_hospital_cd_2 as cmp_in_hospital_cd_2
  from complaint_info as ord
  inner join mst_complaint as mstCmp on ord.comp_cd = mstCmp.complaint_cd :: TEXT 
  where
    mstCmp.is_del = ''0''
    and mstCmp.is_disp = ''1''
    and mstCmp.facility_cd = @facilityCd
)
select
	@ordNo as ord_no_t,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''YYYY/MM/DD'')as occur_date,
  a.complaint,
  a.cmp_in_hospital_cd_1,
  a.cmp_in_hospital_cd_2,
  a.treat_date,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
	b.treatMdeci_in_hospital_cd_4,
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
      ord.treat_date,
      complaint.occur_date as occur_date,
      complaint.complaint as complaint,
      complaint.row_no as row_no,
			complaint.ctl_no as ctl_no,
      complaint.checkFlag as checkFlag,
      mstcmp_tbl.cmp_in_hospital_cd_1,
      mstcmp_tbl.cmp_in_hospital_cd_2
    from
      ord_base as ord
			INNER JOIN complaint_info as complaint on ord.ord_no = complaint.ord_no
      left join mstcmp_tbl on (mstcmp_tbl.complaint_cd ::text = complaint.comp_cd)
union
    select ord_no, treat_date, rst_start_date::text as occur_date, ''治療開始'' as complaint, null, null, ''1'' as checkFlag, null, null from ord_main where ord_no = @ordNo     and rst_start_date is not null
union
    select ord_no, treat_date, rst_end_date::text as occur_date, ''治療終了'' as complaint, null, null, ''1'' as checkFlag, null, null from ord_main where ord_no = @ordNo and rst_end_date is not null
   ) a
  full outer join
  (
    select
      ord.ord_no,
      treatment.occur_date as occur_date,
      treatment.row_no as row_no,
			treatment.ctl_no as ctl_no,
      case
        when treatment.treat_class = ''3'' and treatment.oxygen_start is not null then concat(''酸素吸入開始 '', to_char(cast(treatment.oxygen_speed as numeric), ''FM999999.00''), ''L/min'')
				when treatment.treat_class = ''3'' and treatment.oxygen_start is null then concat(''酸素吸入終了 '' , to_char(cast(treatment.oxygen_amount as numeric), ''FM999999.00''), ''L'') 
				when treatment.treat_class = ''4'' and treatment.electrocardiogram_start is not null then ''心電図測定開始''
        when treatment.treat_class = ''4'' and treatment.electrocardiogram_start is null then ''心電図測定終了''
        else treatment.treat_name end as treat_name,
      treatment.treat_medicine,
      treatment.amount,
      treatment.unit,
      treatment.procedure_name,
      mstMedic.in_hospital_cd_1 as treatMdeci_in_hospital_cd_1,
      mstMedic.in_hospital_cd_2 as treatMdeci_in_hospital_cd_2,
      mstMedic.in_hospital_cd_3 as treatMdeci_in_hospital_cd_3,
			mstMedic.in_hospital_cd_4 as treatMdeci_in_hospital_cd_4,
			mstcp_tbl.comptreat_in_hospital_cd_1,
			mstcp_tbl.comptreat_in_hospital_cd_2,
			mstcp_tbl.comptreat_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_4,
      save.receipt_value,
      case when treatment.checkFlag = ''1'' then mstMedic.unit_second else '''' end unit_second,
      treatment.checkFlag as checkFlag
    from
      ord_base as ord
      INNER JOIN treatment_info as treatment on ord.ord_no = treatment.ord_no and (treatment.medicine_type is null or treatment.medicine_type = ''1'')
			left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment.treat_cd)
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment.treat_medicine_cd  = save.supplies_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      and treatment.ctl_no = save.medicine_no ->>''ctl_no'' and treatment.row_no = save.medicine_no ->> ''row_no''
      left join mst_medicine as  mstMedic  on (treatment.treat_medicine_cd = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
union all
    select
      ord.ord_no,
      treatment.occur_date as occur_date,
      treatment.row_no as row_no,
			treatment.ctl_no as ctl_no,
      case
        when treatment.treat_class = ''3'' and treatment.oxygen_start is not null then concat(''酸素吸入開始 '', to_char(cast(treatment.oxygen_speed as numeric), ''FM999999.00''), ''L/min'')
        when treatment.treat_class = ''3'' and treatment.oxygen_start is null then concat(''酸素吸入終了 '' , to_char(cast(treatment.oxygen_amount as numeric), ''FM999999.00''), ''L'')
        when treatment.treat_class = ''4'' and treatment.electrocardiogram_start is not null then ''心電図測定開始''
        when treatment.treat_class = ''4'' and treatment.electrocardiogram_start is null then ''心電図測定終了''
        else treatment.treat_name end as treat_name,
      mstMedic.medicine_name as treat_medicine,
      save.ind_rst_value as amount,
      mstMedic.unit as unit,
      treatment.procedure_name as procedure_name,
      mstMedic.in_hospital_cd_1 as treatMdeci_in_hospital_cd_1,
      mstMedic.in_hospital_cd_2 as treatMdeci_in_hospital_cd_2,
      mstMedic.in_hospital_cd_3 as treatMdeci_in_hospital_cd_3,
			mstMedic.in_hospital_cd_4 as treatMdeci_in_hospital_cd_4,
			mstcp_tbl.comptreat_in_hospital_cd_1,
			mstcp_tbl.comptreat_in_hospital_cd_2,
			mstcp_tbl.comptreat_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_4,			
      save.receipt_value,
      case when treatment.checkFlag = ''1'' then mstMedic.unit_second else '''' end unit_second,
      treatment.checkFlag as checkFlag
    from
      ord_base as ord
			INNER JOIN treatment_info as treatment on ord.ord_no = treatment.ord_no and  treatment.medicine_type = ''2''
			left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment.treat_cd)
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment.treat_medicine_cd  = save.medicine_mix_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      and treatment.ctl_no = save.medicine_no ->>''ctl_no'' and treatment.row_no = save.medicine_no ->> ''row_no''
			and save.supplies_class not in (''13'',''15'')
      inner join mst_medicine as  mstMedic  on (save.supplies_cd = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
union all
		select
    ord_no
    , to_char(event_reg_date, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') as occur_date
    , ''0'' as row_no
		,''0'' as ctl_no
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
    , mnt.report_disp_flg as checkFlag
		from
    mnt_motion_record as mnt
		where
    mnt.ord_no = @ordNo and mnt.facility_cd= @facilityCd
    and mnt.report_disp_flg = ''1''
  ) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date and a.row_no = b.row_no  and a.ctl_no = b.ctl_no 
  full outer join
  (
    select
      ord.ord_no,
      treat_staff.occur_date as occur_date,
      treat_staff.row_no as row_no,
			treat_staff.ctl_no as ctl_no,
      treat_staff.treat_staff_name as treat_staff_name,
      treat_staff.treat_staff_cd as treat_staff_cd,
      treat_staff.checkFlag as checkFlag
    from
      ord_base as ord
			INNER JOIN treat_staff_info as treat_staff on treat_staff.ord_no = ord.ord_no
   ) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.row_no, b.row_no) = c.row_no and COALESCE(a.ctl_no, b.ctl_no) = c.ctl_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
  and (a.checkFlag = ''1'' or (a.checkFlag is null and b.checkFlag = ''1'') or (a.checkFlag is null and b.checkFlag is null and c.checkFlag = ''1''))
order by
  occur_date, occur_time, to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'') nulls first

	),
time_info AS (
	WITH b as (
		select 
			ord_no,
			rst_start_date,
			rst_end_date,
			rst_dialysis_state  
		from ord_main as ord	where  ord.facility_cd = @facilityCd  and ord.ord_no = @ordNo and ord.rst_dialysis_state <> ''0''
	)
	, e AS (
  SELECT DISTINCT ON (ord_no)
       mni_monitor.*,
       TO_NUMBER(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間,
       TO_NUMBER(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了,
       TO_NUMBER(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
FROM mni_monitor mni_monitor
WHERE mni_monitor.ord_no = @ordNo and  mni_monitor.facility_cd= @facilityCd and mni_monitor.data_type = 1
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
	from  b 
	left JOIN e on b.ord_no=e.ord_no 
	left JOIN f on b.ord_no=f.ord_no
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
	', 2, '[{"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "complaint", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "cmp_in_hospital_cd_1", "data_name": "愁訴連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "cmp_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "cmp_in_hospital_cd_2", "data_name": "愁訴連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "cmp_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_1", "data_name": "処置連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_2", "data_name": "処置連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_3", "data_name": "処置連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_4", "data_name": "処置連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "comptreat_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "処置薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_4", "data_name": "処置薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treatmdeci_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "receipt_value", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "unit_second", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置（分解）", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3]}', '実績：愁訴処置（分解） @ordNo 使用', '2021-11-29 13:29:36.254', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (259, 'WITH DATA AS (
with ord_base as(
select *  from ord_main as ord	where  ord.facility_cd = @facilityCd  and ord.ord_no = @ordNo and ord.rst_dialysis_state <> ''0''
)
,treatment_info as(
 select
      ord.ord_no,
      ord.treat_date,
			treatment->>''treat_cd'' as treat_cd,
      treatment->>''occur_date'' as occur_date,
      treatment->>''complaint'' as complaint,
      treatment->>''row_no'' as row_no,
			treatment->>''ctl_no'' as ctl_no,
      treatment->>''checkFlag'' as checkFlag,
			treatment->>''treat_class'' as treat_class,
			treatment->>''oxygen_start'' as oxygen_start,
			treatment->>''electrocardiogram_start'' as electrocardiogram_start,
			treatment->>''oxygen_speed'' as oxygen_speed,
      treatment->>''oxygen_amount'' as oxygen_amount,
			treatment->>''treat_name'' as treat_name,
			treatment->>''treat_medicine_name'' as treat_medicine,
			treatment->>''amount'' as amount,
      treatment->>''unit'' as unit,
      treatment->>''procedure_name'' as procedure_name,
			treatment->>''treat_medicine_cd'' as treat_medicine_cd,
			treatment->>''medicine_type'' as medicine_type
    from
      ord_base as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
)
,complaint_info as(
 select
      ord.ord_no,
      ord.treat_date,
			complaint->>''comp_cd'' as comp_cd,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint,
      complaint->>''row_no'' as row_no,
			complaint->>''ctl_no'' as ctl_no,
      complaint->>''checkFlag'' as checkFlag
    from
      ord_base as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint
)
,treat_staff_info as( 
		select
      ord.ord_no,
      treat_staff->>''occur_date'' as occur_date,
      treat_staff->>''row_no'' as row_no,
			treat_staff->>''ctl_no'' as ctl_no,
      treat_staff->>''treat_staff_name'' as treat_staff_name,
      treat_staff->>''treat_staff_cd'' as treat_staff_cd,
      treat_staff->>''checkFlag'' as checkFlag
    from
      ord_base as ord
    cross join lateral
      json_array_elements (ord.rst_treat_staff_info::json) treat_staff)
,mstcp_tbl as (
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
    from treatment_info as ord 		
    inner join mst_comp_treatment as mstCpt on ord.treat_cd = mstCpt.comp_treatment_cd ::text 
    where
     mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
		 and mstCpt.facility_cd = @facilityCd
)
,mstcmp_tbl as (
  select 
	ord.ord_no,
  ord.treat_date,
  complaint_cd,
	mstCmp.in_hospital_cd_1 as cmp_in_hospital_cd_1,
	mstCmp.in_hospital_cd_2 as cmp_in_hospital_cd_2
  from complaint_info as ord
  inner join mst_complaint as mstCmp on ord.comp_cd = mstCmp.complaint_cd :: TEXT 
  where
    mstCmp.is_del = ''0''
    and mstCmp.is_disp = ''1''
    and mstCmp.facility_cd = @facilityCd
),
RESULT_ALL AS (
(select
	@ordNo as ord_no_t,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''YYYY/MM/DD'')as occur_date,
  a.complaint,
  a.cmp_in_hospital_cd_1,
  a.cmp_in_hospital_cd_2,
  a.treat_date,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
	b.treatMdeci_in_hospital_cd_4,
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
      ord.treat_date,
      complaint.occur_date as occur_date,
      complaint.complaint as complaint,
      complaint.row_no as row_no,
			complaint.ctl_no as ctl_no,
      complaint.checkFlag as checkFlag,
      mstcmp_tbl.cmp_in_hospital_cd_1,
      mstcmp_tbl.cmp_in_hospital_cd_2
    from
      ord_base as ord
			INNER JOIN complaint_info as complaint on ord.ord_no = complaint.ord_no
      left join mstcmp_tbl on (mstcmp_tbl.complaint_cd ::text = complaint.comp_cd)
union
    select ord_no, treat_date, rst_start_date::text as occur_date, ''治療開始'' as complaint, null, null, ''1'' as checkFlag, null, null from ord_main where ord_no = @ordNo     and rst_start_date is not null
union
    select ord_no, treat_date, rst_end_date::text as occur_date, ''治療終了'' as complaint, null, null, ''1'' as checkFlag, null, null from ord_main where ord_no = @ordNo and rst_end_date is not null
   ) a
  full outer join
  (
    select
      ord.ord_no,
      treatment.occur_date as occur_date,
      treatment.row_no as row_no,
			treatment.ctl_no as ctl_no,
      case
        when treatment.treat_class = ''3'' and treatment.oxygen_start is not null then concat(''酸素吸入開始 '', to_char(cast(treatment.oxygen_speed as numeric), ''FM999999.00''), ''L/min'')
				when treatment.treat_class = ''3'' and treatment.oxygen_start is null then concat(''酸素吸入終了 '' , to_char(cast(treatment.oxygen_amount as numeric), ''FM999999.00''), ''L'') 
				when treatment.treat_class = ''4'' and treatment.electrocardiogram_start is not null then ''心電図測定開始''
        when treatment.treat_class = ''4'' and treatment.electrocardiogram_start is null then ''心電図測定終了''
        else treatment.treat_name end as treat_name,
      treatment.treat_medicine,
      treatment.amount,
      treatment.unit,
      treatment.procedure_name,
      mstMedic.in_hospital_cd_1 as treatMdeci_in_hospital_cd_1,
      mstMedic.in_hospital_cd_2 as treatMdeci_in_hospital_cd_2,
      mstMedic.in_hospital_cd_3 as treatMdeci_in_hospital_cd_3,
			mstMedic.in_hospital_cd_4 as treatMdeci_in_hospital_cd_4,
			mstcp_tbl.comptreat_in_hospital_cd_1,
			mstcp_tbl.comptreat_in_hospital_cd_2,
			mstcp_tbl.comptreat_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_4,
      save.receipt_value,
      case when treatment.checkFlag = ''1'' then mstMedic.unit_second else '''' end unit_second,
      treatment.checkFlag as checkFlag
    from
      ord_base as ord
      INNER JOIN treatment_info as treatment on ord.ord_no = treatment.ord_no and (treatment.medicine_type is null or treatment.medicine_type = ''1'')
			left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment.treat_cd)
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment.treat_medicine_cd  = save.supplies_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      and treatment.ctl_no = save.medicine_no ->>''ctl_no'' and treatment.row_no = save.medicine_no ->> ''row_no''
      left join mst_medicine as  mstMedic  on (treatment.treat_medicine_cd = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
union all
    select
      ord.ord_no,
      treatment.occur_date as occur_date,
      treatment.row_no as row_no,
			treatment.ctl_no as ctl_no,
      case
        when treatment.treat_class = ''3'' and treatment.oxygen_start is not null then concat(''酸素吸入開始 '', to_char(cast(treatment.oxygen_speed as numeric), ''FM999999.00''), ''L/min'')
        when treatment.treat_class = ''3'' and treatment.oxygen_start is null then concat(''酸素吸入終了 '' , to_char(cast(treatment.oxygen_amount as numeric), ''FM999999.00''), ''L'')
        when treatment.treat_class = ''4'' and treatment.electrocardiogram_start is not null then ''心電図測定開始''
        when treatment.treat_class = ''4'' and treatment.electrocardiogram_start is null then ''心電図測定終了''
        else treatment.treat_name end as treat_name,
      mstMedic.medicine_name as treat_medicine,
      save.ind_rst_value as amount,
      mstMedic.unit as unit,
      treatment.procedure_name as procedure_name,
      mstMedic.in_hospital_cd_1 as treatMdeci_in_hospital_cd_1,
      mstMedic.in_hospital_cd_2 as treatMdeci_in_hospital_cd_2,
      mstMedic.in_hospital_cd_3 as treatMdeci_in_hospital_cd_3,
			mstMedic.in_hospital_cd_4 as treatMdeci_in_hospital_cd_4,
			mstcp_tbl.comptreat_in_hospital_cd_1,
			mstcp_tbl.comptreat_in_hospital_cd_2,
			mstcp_tbl.comptreat_in_hospital_cd_3,
			mstcp_tbl.comptreat_in_hospital_cd_4,			
      save.receipt_value,
      case when treatment.checkFlag = ''1'' then mstMedic.unit_second else '''' end unit_second,
      treatment.checkFlag as checkFlag
    from
      ord_base as ord
			INNER JOIN treatment_info as treatment on ord.ord_no = treatment.ord_no and  treatment.medicine_type = ''2''
			left join mstcp_tbl on (mstcp_tbl.comp_treatment_cd ::text = treatment.treat_cd)
      left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and treatment.treat_medicine_cd  = save.medicine_mix_cd and save.supplies_source_class = ''3'' and save.ind_rst_class =''2'')
      and treatment.ctl_no = save.medicine_no ->>''ctl_no'' and treatment.row_no = save.medicine_no ->> ''row_no''
			and save.supplies_class not in (''13'',''15'')
      inner join mst_medicine as  mstMedic  on (save.supplies_cd = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
union all
		select
    ord_no
    , to_char(event_reg_date, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') as occur_date
    , ''0'' as row_no
		,''0'' as ctl_no
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
    , mnt.report_disp_flg as checkFlag
		from
    mnt_motion_record as mnt
		where
    mnt.ord_no = @ordNo and mnt.facility_cd= @facilityCd
    and mnt.report_disp_flg = ''1''
  ) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date and a.row_no = b.row_no  and a.ctl_no = b.ctl_no 
  full outer join
  (
    select
      ord.ord_no,
      treat_staff.occur_date as occur_date,
      treat_staff.row_no as row_no,
			treat_staff.ctl_no as ctl_no,
      treat_staff.treat_staff_name as treat_staff_name,
      treat_staff.treat_staff_cd as treat_staff_cd,
      treat_staff.checkFlag as checkFlag
    from
      ord_base as ord
			INNER JOIN treat_staff_info as treat_staff on treat_staff.ord_no = ord.ord_no
   ) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.row_no, b.row_no) = c.row_no and COALESCE(a.ctl_no, b.ctl_no) = c.ctl_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
  and (a.checkFlag = ''1'' or (a.checkFlag is null and b.checkFlag = ''1'') or (a.checkFlag is null and b.checkFlag is null and c.checkFlag = ''1''))
order by
  occur_date, occur_time, to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'') nulls first)
UNION ALL 
(SELECT 
    ord.ord_no,
    to_char(to_timestamp(coalesce(treatment ->> ''effect_date''), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
	to_char(to_timestamp(coalesce(treatment ->> ''effect_date''), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''YYYY/MM/DD'') AS occur_time, 
	NULL AS complaint,
	NULL AS cmp_in_hospital_cd_1,
	NULL AS cmp_in_hospital_cd_2,
	ord.treat_date,
	mstMedic.medicine_name AS treat_name,
	NULL AS treat_medicine,
	NULL AS treatMdeci_in_hospital_cd_1,
	NULL AS treatMdeci_in_hospital_cd_2,
	NULL AS treatMdeci_in_hospital_cd_3,
	NULL AS treatMdeci_in_hospital_cd_4,
	NULL AS comptreat_in_hospital_cd_1,
	NULL AS comptreat_in_hospital_cd_2,
	NULL AS comptreat_in_hospital_cd_3,
	NULL AS comptreat_in_hospital_cd_4,
	save.ind_rst_value AS amount,
	save.ind_unit AS unit,
	save.receipt_value AS receipt_value,
	save.receipt_unit AS unit_second,
	NULL AS procedure_name,
	( treatment ->> ''effect_user_last_name'' ) || ( treatment ->> ''effect_user_first_name'' ) AS treat_staff_name,
	NULL AS treat_staff_cd
FROM
	ord_material_save AS save
	LEFT JOIN ord_main AS ord
	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: JSON ) treatment ON ( save.supplies_base_no = ord.ord_no AND ord.facility_cd = save.facility_cd AND (treatment ->> ''cd'' = save.supplies_cd AND treatment ->> ''medicine_type'' = ''1'') )
	inner JOIN mst_medicine AS mstMedic ON (
		save.supplies_cd = mstMedic.medicine_cd :: TEXT 
		AND mstMedic.is_del = ''0'' 
		AND mstMedic.is_disp = ''1'' 
		AND mstMedic.facility_cd = ord.facility_cd 
	) 
WHERE
	ord.is_del = ''0'' 
	AND ord.rst_dialysis_state <> ''0'' 
	AND ord.ord_no = @ordNo 
	AND save.supplies_source_class = ''1'' 
	AND save.ind_rst_class = ''2'' 
	AND save.effect_flg = ''1''
	AND save.supplies_class not in (''13'',''17''))
	UNION ALL (
	SELECT 
    ord.ord_no,
    to_char(to_timestamp(coalesce(treatment ->> ''effect_date''), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
	to_char(to_timestamp(coalesce(treatment ->> ''effect_date''), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''YYYY/MM/DD'') AS occur_time, 
	NULL AS complaint,
	NULL AS cmp_in_hospital_cd_1,
	NULL AS cmp_in_hospital_cd_2,
	ord.treat_date,
	mstMedic.medicine_name AS treat_name,
	NULL AS treat_medicine,
	NULL AS treatMdeci_in_hospital_cd_1,
	NULL AS treatMdeci_in_hospital_cd_2,
	NULL AS treatMdeci_in_hospital_cd_3,
	NULL AS treatMdeci_in_hospital_cd_4,
	NULL AS comptreat_in_hospital_cd_1,
	NULL AS comptreat_in_hospital_cd_2,
	NULL AS comptreat_in_hospital_cd_3,
	NULL AS comptreat_in_hospital_cd_4,
	save.ind_rst_value AS amount,
	save.ind_unit AS unit,
	save.receipt_value AS receipt_value,
	save.receipt_unit AS unit_second,
	NULL AS procedure_name,
	( treatment ->> ''effect_user_last_name'' ) || ( treatment ->> ''effect_user_first_name'' ) AS treat_staff_name,
	NULL AS treat_staff_cd
FROM
	ord_material_save AS save
	LEFT JOIN ord_main AS ord
	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: JSON ) treatment ON ( save.supplies_base_no = ord.ord_no AND ord.facility_cd = save.facility_cd AND (treatment ->> ''cd'' = save.medicine_mix_cd AND treatment ->> ''medicine_type'' = ''2'') )
	inner JOIN mst_medicine AS mstMedic ON (
		save.supplies_cd = mstMedic.medicine_cd :: TEXT 
		AND mstMedic.is_del = ''0'' 
		AND mstMedic.is_disp = ''1'' 
		AND mstMedic.facility_cd = ord.facility_cd 
	) 
WHERE
	ord.is_del = ''0'' 
	AND ord.rst_dialysis_state <> ''0'' 
	AND ord.ord_no = @ordNo 
	AND save.supplies_source_class = ''1'' 
	AND save.ind_rst_class = ''2'' 
	AND save.effect_flg = ''1''
	AND save.supplies_class in (''20'',''22'')  
	)
)
SELECT * FROM RESULT_ALL
	)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	;
	', 2, '[{"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint", "data_name": "愁訴", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "complaint", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:46", "can_calc": "0", "data_code": "occur_time", "data_name": "愁訴処置時刻", "data_type": "DateTime", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "occur_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treat_name", "data_name": "処置", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "treat_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treat_staff_cd", "data_name": "処置ID", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "treat_staff_cd", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "treat_staff_name", "data_name": "処置者", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "treat_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置薬剤", "can_calc": "0", "data_code": "treat_medicine", "data_name": "処置薬剤", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "treat_medicine", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_1", "data_name": "処置薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "treatmdeci_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_2", "data_name": "処置薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "treatmdeci_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_3", "data_name": "処置薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "treatmdeci_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "treatmdeci_in_hospital_cd_4", "data_name": "処置薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "treatmdeci_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_1", "data_name": "処置連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "comptreat_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_2", "data_name": "処置連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "comptreat_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_3", "data_name": "処置連携コード３", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "comptreat_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "comptreat_in_hospital_cd_4", "data_name": "処置連携コード４", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "comptreat_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "receipt_value", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "unit_second", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "cmp_in_hospital_cd_1", "data_name": "愁訴連携コード１", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "cmp_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "cmp_in_hospital_cd_2", "data_name": "愁訴連携コード２", "data_type": "string", "conv_table": [], "data_class": "愁訴処置・実施薬剤（分解）", "field_name": "cmp_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 11]}', '実績：愁訴処置・実施薬剤（分解） @ordNo 使用', '2025-08-25 15:14:03.631', CURRENT_TIMESTAMP, NULL);
