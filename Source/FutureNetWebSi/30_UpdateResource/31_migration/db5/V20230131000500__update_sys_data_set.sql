delete from ntss.sys_data_set where sql_cd = '141';
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (141, 'select a.f_medi_cd,a.medicine_name as f_medi_name,a.f_medi_amount,a.medicine_unit as f_medicine_unit,array_agg(a.f_week) as f_week from (
select
		weekmedi_info.cd as f_medi_cd,
    mmd.medicine_name as medicine_name,
	  weekmedi_info.amount as f_medi_amount,
    mmd.unit as medicine_unit,
    weekmedi_info.week as f_week
from
(select
    distinct
    medi ->> ''cd''  as cd,
    to_number(medi ->>''amount'',''9999999.9999'') as amount,
		medi ->> ''medicine_type'' as medicine_type,
    medi ->> ''unit'' as unit,
    medi ->> ''no''  as medi_no,
    case ord.treat_week
        when 1 then ''月''
        when 2 then ''火''
        when 3 then ''水''
        when 4 then ''木''
        when 5 then ''金''
        when 6 then ''土''
        when 7 then ''日''
        else  ''未''
    end as week
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_medi_info :: json) medi
    where
      ord.facility_cd = @facilityCd
 and 
      ord.treat_date between to_char(date_trunc(''day'', ( @fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'') and 
      ord.pat_id = @patId

 and 
      ord.is_del = ''0''
    order by medi_no,cd,amount,unit,week) as weekmedi_info
    inner join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (weekmedi_info.cd,''999999999999'') AND mmd.class_cd IN ( @medIds
 )  where  weekmedi_info.medicine_type = ''1''
 UNION ALL
 select
		weekmedi_info.cd as f_medi_cd,
    mix.medicine_mix_name as medicine_name,
	  weekmedi_info.amount as f_medi_amount,
		mix.unit as medicine_unit,
   weekmedi_info.week as f_week
from
(select
    distinct
    medi ->> ''cd''  as cd,
    to_number(medi ->>''amount'',''9999999.9999'') as amount,
		medi ->> ''medicine_type'' as medicine_type,
    medi ->> ''unit'' as unit,
    medi ->> ''no''  as medi_no,
    case ord.treat_week
        when 1 then ''月''
        when 2 then ''火''
        when 3 then ''水''
        when 4 then ''木''
        when 5 then ''金''
        when 6 then ''土''
        when 7 then ''日''
        else  ''未''
    end as week
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_medi_info :: json) medi
    where
      ord.facility_cd = @facilityCd
 and 
      ord.treat_date between to_char(date_trunc(''day'', ( @fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'') and 
      ord.pat_id = @patId

 and 
      ord.is_del = ''0''
    order by medi_no,cd,amount,unit,week) as weekmedi_info
    inner join
      mst_medicine_mix as mix
    on
      mix.medicine_mix_cd = TO_NUMBER (weekmedi_info.cd,''999999999999'') AND mix.class_cd IN ( @medIds
 )  where  weekmedi_info.medicine_type = ''2''
 )  a
      group by a.f_medi_cd,a.medicine_name,a.f_medi_amount,a.medicine_unit', 2, '[{"preview": "1", "can_calc": "0", "data_code": "f_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_cd", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "f_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_name", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "f_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_amount", "disp_format": "0", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "f_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medicine_unit", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "火,水,木", "can_calc": "0", "data_code": "f_week", "data_name": "指示曜日", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_week", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 9, 10]}', '紹介状　指示：投薬(未来有効）　@facilityCd@patId@fromdate@todate使用', '2021-03-31 14:09:45', CURRENT_TIMESTAMP, '[]');
