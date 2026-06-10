INSERT INTO "ntss"."sys_data_set" ( "sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info" )
VALUES
	( 150, 'select
    count(pat_id) as out_pat_cnt
    , reg_date 
    from
    ( 
        select
            pat_id
            , to_char(reg_date, ''YYYYMMDD'') as reg_date 
        from
            pat_personal_main 
        where
            facility_cd = @facilityCd
            and in_out_class = 0
            and is_del = ''0''
            and to_char(reg_date, ''YYYYMMDD'') >= @fromDate
            and to_char(reg_date, ''YYYYMMDD'') <= @toDate
    ) pt1 
group by
    reg_date 
order by
    reg_date', 3, '[{"preview": "0", "can_calc": "0", "data_code": "out_pat_cnt", "data_name": "外来合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "out_pat_cnt", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '外来合計@facilityCd  @fromdate  @todate', '2021-05-07 10:00:02', '2021-05-07 10:00:02', NULL );