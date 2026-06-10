DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307076;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307076, 'with dialysis_output_setting as (
-- 透析困難コメント・透析時間の出力設定
select
	coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
	and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
	and info->>''key2'' = ''DIFFCOMMENT_DIALTIME_FLG''
limit 1
),
main_dial_diff_name as (
select
	dialysis_difficulty_name as name
from
	mst_dialysis_difficulty mdd
where
	dialysis_difficulty_cd::text = @dialDiffCd::text
limit 1
) 

select
	case
		when dos.value = ''0'' then null
		when dos.value = ''1'' then 
      coalesce(
        case 
          when (select name from main_dial_diff_name) is not null 
          then ''理由（'' || (select name from main_dial_diff_name) || ''） '' 
          else '''' 
        end, ''''
      )
	end
  || translate( FLOOR(extract(EPOCH from (rst_end_date - rst_start_date)) / 3600)::text, ''0123456789'', ''０１２３４５６７８９'' ) || ''Ｈ''
  || translate( FLOOR(mod(extract(EPOCH from (rst_end_date - rst_start_date)), 3600) / 60)::text, ''0123456789'', ''０１２３４５６７８９'' ) || ''Ｍ ''
  || translate( TO_CHAR(rst_start_date, ''HH24:MI''), ''0123456789:'', ''０１２３４５６７８９：'' )
  || ''~''
  || translate( TO_CHAR(rst_end_date, ''HH24:MI''), ''0123456789:'', ''０１２３４５６７８９：'' ) as order_units_memo
from
	ord_main
cross join dialysis_output_setting dos
where
	ord_no = @ordNo;
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2025-04-09 19:04:37.510', current_timestamp, '[{"sql_cd": -307075, "field_name": "dial_diff_cd", "replace_var": "@dialDiffCd"}]'::jsonb);