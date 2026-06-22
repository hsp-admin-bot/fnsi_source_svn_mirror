DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-427, -317104, -317116);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-427, 'select 
	''除水'' as detail_id,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_target'',''0''),''9999.99''),''9990.99'')) as e01,
	trim(to_char(ROUND(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_target'',''0''),''9990.99'') / TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0), 2),''9990.99'')) as e02,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''add_total'',''0''),''9999.99''),''9990.99'')) as e03
from 
	ord_main ord
where
	ord.ord_no = @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom)経過情報（除水）', '2020-05-27 10:00:13.000', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317104, '
with medical_name_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join lateral jsON_array_elements(ini.coop_ini_info ::jsON) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
  ord.rst_treatment_name as e01  --血液浄化法
  ,to_char(ord.rst_start_date,''YYYY/MM/DD'') as e02--透析日
  ,RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999'')/60,0),2)||''時間''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999''),60),2)||''分''as e03--予定時間
  ,to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as e04--開始時刻
  ,to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as e05--終了時刻
  ,FLOOR(EXTRACT(EPOCH FROM DATE_TRUNC(''minute'', rst_end_date) - DATE_TRUNC(''minute'', rst_start_date)) / 3600) || ''時間'' ||
   FLOOR(MOD(EXTRACT(EPOCH FROM DATE_TRUNC(''minute'', rst_end_date) - DATE_TRUNC(''minute'', rst_start_date)), 3600) / 60) || ''分'' as e06--透析時間・実績時間
  ,to_number(cast(ord.rst_dialysis_cnt as text), ''FM999999'') as e07--透析回数
  ,to_number(ord.rst_cond_info->''14''->>''value'', ''FM999'') as e08--血流量
  ,to_char(cast(ord.rst_weight_info->>''ctr'' as numeric),''FM9990.00'') as e09--CTR
  ,ord.rst_cond_info->''5''->>''value_name_1'' as e10--ダイアライザ
  ,ord.rst_cond_info->''2''->>''value_name_1'' as e11--ブラッドアクセス・バスキュラーアクセス
  , case (
  	select
  		value
  	from
  		medical_name_info
  	where 
  		key2 = ''MEDICAL_NAME''
	) when ''0'' then coalesce(ord.rst_course_name,(
		select 
			value
		from
			medical_name_info
		where
			key2 = ''FIXED_MEDICAL_NAME''
	))when ''1'' then (
		select 
			value
		from
			medical_name_info
		where
			key2 = ''FIXED_MEDICAL_NAME''		
	)
    end as e12--診療科名
	,ord.rst_cond_info->''25''->>''value_name_1''  as e13--抗凝固剤
	,trim(to_char(to_number(ord.rst_cond_info->''26''->>''value'',''9999.99''),''99990.99''))  as e14--初回注入量
	,trim(to_char(to_number(ord.rst_cond_info->''27''->>''value'',''9999.99''),''99990.99'')) as e15--持続注入量
	,trim(to_char(to_number(ord.rst_cond_info->''28''->>''value'',''9999.99''),''99990.99'')) as e16--持続総量
from 
	ord_main ord
where
	ord.ord_no = @ordNo

', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携治療情報テーブルデータ取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317116, '
with blood_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	''血液'' as detail_id,
	case abo
	when ''1'' then (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_A''
	)
	when ''2'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_B''
	)
	when ''4'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_AB''
	)
	when ''3'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_O''
	)
	else (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_UNKNOWN''
	)
	end as abo,
	case rh
	when ''1'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_RH+''
	)
	when ''2'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_RH-''
	)
	else (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_UNKNOWN''
	)
	end as rh
from
	(
		select
			@blood_type_abo as abo,
			@blood_type_rh as rh
	) as blood_type', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携血液取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317115, "field_name": "abo", "replace_var": "@blood_type_abo"}, {"sql_cd": -317115, "field_name": "rh", "replace_var": "@blood_type_rh"}]'::jsonb);

