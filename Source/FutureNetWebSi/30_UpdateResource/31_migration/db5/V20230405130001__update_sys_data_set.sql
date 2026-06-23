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
    --↓画面上で追加している項目の追加処理
    union
    select ord_no, rst_start_date::text as occur_date, ''治療開始'' as complaint, null from ord_main where ord_no = @ordNo and rst_start_date is not null
    union
    select ord_no, rst_end_date::text as occur_date, ''治療終了'' as complaint, ''999'' from ord_main where ord_no = @ordNo and rst_end_date is not null
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
		LEFT JOIN (
	SELECT
		a.machine_record_cd,
		COALESCE ( b.disp_flg, a.disp_flg ) AS disp_flg 
	FROM
		mst_machine_record a
		LEFT JOIN mst_machine_record_control b ON a.machine_record_cd = b.machine_record_cd 
) t2 ON mnt.machine_record_cd = t2.machine_record_cd 
where
    mnt.facility_cd = ( select facility_cd from ord_main where ord_no = @ordNo ) 
    and mnt.ord_no = @ordNo 
    and mnt.report_disp_flg = ''1''     
    and t2.disp_flg = ''2''
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
  occur_date, occur_time, to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'') nulls first', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 6;
