DELETE from sys_data_set where sql_cd = -18;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-18, 'select 	
''指示薬剤''::TEXT as detail_id,
		a.medi_cd1
		,sum(medi_amount::integer) as  medi_amount
		,COUNT(medi_cd1) as medi_back
		,a.medi_unit		
		from 
		(select
	  ''指示薬剤'' as detail_id,
		medc.in_hospital_cd_1 as medi_class_cd,
		medc.class_name as medi_class_type,
		mmd.medicine_name  as medi_name,
		medi ->> ''amount'' as medi_amount,
		mmd.unit as medi_unit,
	  (case when mmd.unit_second is null then to_number(medi ->> ''amount'',''FM99999.99'') else (case  when mmd.is_exchange = ''0'' then to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second   when mmd.is_exchange = ''1'' then trunc( to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second + 0.9 ,0) when mmd.is_exchange = ''2'' then 1 else  to_number(medi ->> ''amount'',''FM99999.99'') end) end) as res_amount,
		mmd.unit_second as res_unit,
		medi ->> ''timing_name'' as medi_timing_name,
		mp.pricedure_name as procedure_name,
		mp.in_hospital_cd_a1 as procedure_cd1,
		mmd.in_hospital_cd_1 as medi_cd1,
		mmd.in_hospital_cd_2 as medi_cd2,
		mmd.in_hospital_cd_3 as medi_cd3,
		mmd.in_hospital_cd_4 as medi_cd4
    from
		mst_medicine_class as medc,
		ord_main as ord
    cross join lateral
		json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
		mst_medicine as mmd
    on
		mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
		mst_procedure as mp
    on
		mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    where
		mmd.class_cd = medc.class_cd and 
		mmd.in_hospital_cd_1 is not null and
	ord.ord_no =  @ordNo)  as a 
	GROUP BY a.medi_cd1,a.medi_unit		', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）投与薬剤コード', '2020-04-10 15:28:38.712', current_timestamp, NULL);
