DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-400006,-400008,-400019);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-400006, 'select
		to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
		to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
		to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
		to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
		to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
		to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
		to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
		to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
		to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
		to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
		to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
		to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
		to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
		to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
		ord.rst_running_time as running_time,
		RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
		to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
		rst_bed_name as bed_name,
		(CASE WHEN rst_fn_dialysis_no IS NOT NULL AND ord.rst_fn_dialysis_no > 0 THEN ord.rst_fn_dialysis_no ELSE ord.ord_no END) as dialysis_no,
		rst_edition as edition,
		up_date as up_date
		from
		ord_main as ord
		where
  ord.ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '日機装 透析レポート', '2020-07-31 18:29:49.000', now(), NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-400008, 'select
    ltrim(journal.hosp_pat_id, ''0'') || lpad(
        trim(to_char((CASE WHEN rst_fn_dialysis_no IS NOT NULL AND ord.rst_fn_dialysis_no > 0 THEN ord.rst_fn_dialysis_no ELSE ord.ord_no END), ''999999999999'')),
        12,
        ''0''
    ) || lpad(trim(to_char(ord.rst_edition, ''9999'')), 4, ''0'') || ''.pdf'' as filename
from
    sys_coop_journal journal
    inner join ord_main ord on journal.ord_no = ord.ord_no
where
    journal.ord_no = @ordNo
    and journal.direction = ''S''
    and journal.ana_result = ''1''
    and journal.is_del = ''0''
limit
    1;  ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '日機装 透析レポート', '2020-07-31 18:29:49.000', now(), NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-400019, 'select
        to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
        to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
        to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
        to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
        to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
        to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
        to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
        to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
        to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
        to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
        to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
        to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
        to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
        to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
        ord.rst_running_time as running_time,
        RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
        to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
        rst_bed_name as bed_name,
		(CASE WHEN rst_fn_dialysis_no IS NOT NULL AND ord.rst_fn_dialysis_no > 0 THEN ord.rst_fn_dialysis_no ELSE ord.ord_no END) as dialysis_no,
        rst_edition as edition,
        up_date as up_date
        from
        ord_main_restore as ord
        where
  ord.ord_no = @ordNo
  order by del_date desc
  limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '日機装 透析レポート',  now(), now(), NULL);
