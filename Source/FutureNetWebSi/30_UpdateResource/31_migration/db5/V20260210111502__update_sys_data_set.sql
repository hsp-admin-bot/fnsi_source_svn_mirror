DELETE FROM ntss.sys_data_set
WHERE sql_cd=-2300;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2300, '--性能検証のため一時的なアップ。ロールバックには下部のコメントアウトブロックを使用する

--with ord_main_tmp as(
--    select
--        ord_no
--        ,pat_id
--        ,treat_date
--        ,ind_treat_start_time
--        ,rst_dialysis_state
--        ,rst_cond_send_date
--        ,rst_start_date
--        ,rst_end_date
--        ,to_char((rst_weight_info ->> ''weight_after_date'')::TIMESTAMPTZ AT TIME ZONE ''Asia/Tokyo'', ''YYYY-MM-DD hh24:mi:ss'') as weightafterdate
--        ,rst_edition_date
--        ,cur_edition_date
--        ,facility_cd
--        from
--            ord_main
--        where
--            facility_cd = @facilityCd
--            and @fromDate <= treat_date AND treat_date < @toDate
--            AND is_del = ''0''
--    )
--,mnt_motion_record_tmp as
--    (select
--        ord_no
--        ,machine_record_cd 
--        ,event_reg_date
--    from
--        mnt_motion_record
--    where
--        facility_cd = @facilityCd
--        and machine_record_cd in(''4000'',''5F00'',''F407'',''F409'',''F406'',''F408'')
--)
--,off_water_tmp as
--    (select
--        ord_no
--        ,machine_record_cd 
--        ,event_reg_date
--    from(
--        select
--            mnt.ord_no
--            ,mnt.machine_record_cd
--            ,mnt.event_reg_date
--            ,row_number() OVER (PARTITION BY mnt.ord_no ORDER BY mnt.event_reg_date DESC) as rn
--        from
--            mnt_motion_record_tmp as mnt
--            left join ord_main_tmp as ord on ord.ord_no = mnt.ord_no
--        where
--            mnt.machine_record_cd in(''4000'',''5F00'')
--        )waterranked
--    where
--        rn = 1
--)
--,machine_check_tmp as(
--select
--    ord_no
--    ,case when machine_record_cd in (''F407'',''F409'') then ''1''
--        else null
--    end as machinecheckflg
--    ,case when machine_record_cd in (''F406'',''F408'') then null --最新レコードがF406、F408だった時は除水完了日時をnullにする
--        else event_reg_date
--    end as machinecheckdate
--    from(
--        select
--            mnt.ord_no
--            ,mnt.machine_record_cd
--            ,mnt.event_reg_date
--            ,row_number() OVER (PARTITION BY mnt.ord_no ORDER BY mnt.event_reg_date DESC) as rn
--        from
--            mnt_motion_record_tmp as mnt
--            left join ord_main_tmp as ord on ord.ord_no = mnt.ord_no
--        where 
--            mnt.machine_record_cd in(''F407'',''F409'',''F406'',''F408'')
--    )machineranked
--    where
--        rn = 1
--)
--SELECT
--    ord.pat_id as patid --患者ID(外部キー用)
--    ,'''' as hosppatid --表示患者ID(外部キーから取得)
--    ,ord.treat_date as dialysisdate --透析日
--    ,ord.ind_treat_start_time as dialysistime --透析開始時刻
--    ,to_char(to_timestamp(treat_date||ind_treat_start_time||''0000'',''YYYYMMDDHH24MISSMS'')AT TIME ZONE ''Asia/Tokyo'', ''YYYY-MM-DD hh24:mi:ss'') as startplandate --予定開始日時
--    ,CASE
--        WHEN ord.rst_cond_send_date is null then ''0'' else ''1''
--    END as enterflg --入室フラグ（前体重測定）
--    ,to_char(ord.rst_cond_send_date, ''YYYY-MM-DD hh24:mi:ss'') as enterdate --初回入室日時(前体重測定日時)
--    ,CASE
--        WHEN machine.machinecheckflg is null then ''0'' else ''1''
--    END as machinecheckflg --透析装置確認フラグ
--    ,to_char(machine.machinecheckdate, ''YYYY-MM-DD hh24:mi:ss'') as machinecheckdate --透析装置確認日時
--    ,CASE
--        WHEN ord.rst_dialysis_state IN (''0'', ''1'', ''2'') then ''0''
--        WHEN ord.rst_dialysis_state IN (''3'',''4'', ''5'', ''6'') then ''1''
--    END as dialsisstartflg --透析運転開始フラグ
--    ,to_char(ord.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') as dialsisstartdate--透析運転開始日時
--    ,CASE
--        WHEN water.machine_record_cd is null then ''0'' ELSE ''1''
--    END as offwaterflg --除水完了フラグ
--    ,to_char(water.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'') as offwaterdate --除水完了日時
--    ,CASE
--        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'') then ''0''
--        WHEN ord.rst_dialysis_state IN (''4'',''5'',''6'') then ''1''
--    END as wastefluidflg --排液フラグ
--    ,to_char(ord.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'')  as wastefluiddate --排液日時
--    ,CASE
--        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'',''4'') then ''0''
--        WHEN ord.rst_dialysis_state IN (''5'',''6'') then ''1''
--    END as weightafterflg --後体重測定フラグ
--    ,ord.weightafterdate --後体重測定日時
--    ,CASE
--        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'',''4'',''5'') then ''0''
--        WHEN ord.rst_dialysis_state IN (''6'') then ''1''
--    END as recoverybtnflg --準備回収確認ボタンフラグ
--    ,to_char(ord.rst_edition_date, ''YYYY-MM-DD hh24:mi:ss'') as recoverybtndate--準備回収確認ボタン日時
--    ,to_char(ord.cur_edition_date, ''YYYY-MM-DD hh24:mi:ss'') as update --更新日時
--    ,ord.ord_no AS dialysisno --透析番号
--from
--    ord_main_tmp as ord
--    left join off_water_tmp as water on ord.ord_no = water.ord_no
--    left join machine_check_tmp as machine on ord.ord_no = machine.ord_no;

with ord_main_tmp as(
    select
        ord_no
        ,pat_id
        ,treat_date
        ,ind_treat_start_time
        ,rst_dialysis_state
        ,rst_cond_send_date
        ,rst_start_date
        ,rst_end_date
        ,to_char((rst_weight_info ->> ''weight_after_date'')::TIMESTAMPTZ AT TIME ZONE ''Asia/Tokyo'', ''YYYY-MM-DD hh24:mi:ss'') as weightafterdate
        ,rst_edition_date
        ,cur_edition_date
        ,facility_cd
        from
            ord_main
        where
            facility_cd = @facilityCd
            and @fromDate <= treat_date AND treat_date < @toDate
            AND is_del = ''0''
    )
,mnt_motion_record_tmp as
    (select
        mnt.ord_no
        ,mnt.machine_record_cd 
        ,mnt.event_reg_date
    from
        mnt_motion_record mnt
    where
        mnt.facility_cd = @facilityCd
        and mnt.machine_record_cd in(''4000'',''5F00'',''F407'',''F409'',''F406'',''F408'')
        and exists (
            select 1
            from ord_main_tmp ord
            where ord.ord_no = mnt.ord_no
        )
)
,off_water_tmp as
    (select
        ord_no
        ,machine_record_cd 
        ,event_reg_date
    from(
        select
            mnt.ord_no
            ,mnt.machine_record_cd
            ,mnt.event_reg_date
            ,row_number() OVER (PARTITION BY mnt.ord_no ORDER BY mnt.event_reg_date DESC) as rn
        from
            mnt_motion_record_tmp as mnt
            left join ord_main_tmp as ord on ord.ord_no = mnt.ord_no
        where
            mnt.machine_record_cd in(''4000'',''5F00'')
        )waterranked
    where
        rn = 1
)
,machine_check_tmp as(
select
    ord_no
    ,case when machine_record_cd in (''F407'',''F409'') then ''1''
        else null
    end as machinecheckflg
    ,case when machine_record_cd in (''F406'',''F408'') then null --最新レコードがF406、F408だった時は除水完了日時をnullにする
        else event_reg_date
    end as machinecheckdate
    from(
        select
            mnt.ord_no
            ,mnt.machine_record_cd
            ,mnt.event_reg_date
            ,row_number() OVER (PARTITION BY mnt.ord_no ORDER BY mnt.event_reg_date DESC) as rn
        from
            mnt_motion_record_tmp as mnt
            left join ord_main_tmp as ord on ord.ord_no = mnt.ord_no
        where 
            mnt.machine_record_cd in(''F407'',''F409'',''F406'',''F408'')
    )machineranked
    where
        rn = 1
)
SELECT
    ord.pat_id as patid --患者ID(外部キー用)
    ,'''' as hosppatid --表示患者ID(外部キーから取得)
    ,ord.treat_date as dialysisdate --透析日
    ,ord.ind_treat_start_time as dialysistime --透析開始時刻
    ,to_char(to_timestamp(treat_date||ind_treat_start_time||''0000'',''YYYYMMDDHH24MISSMS'')AT TIME ZONE ''Asia/Tokyo'', ''YYYY-MM-DD hh24:mi:ss'') as startplandate --予定開始日時
    ,CASE
        WHEN ord.rst_cond_send_date is null then ''0'' else ''1''
    END as enterflg --入室フラグ（前体重測定）
    ,to_char(ord.rst_cond_send_date, ''YYYY-MM-DD hh24:mi:ss'') as enterdate --初回入室日時(前体重測定日時)
    ,CASE
        WHEN machine.machinecheckflg is null then ''0'' else ''1''
    END as machinecheckflg --透析装置確認フラグ
    ,to_char(machine.machinecheckdate, ''YYYY-MM-DD hh24:mi:ss'') as machinecheckdate --透析装置確認日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'', ''1'', ''2'') then ''0''
        WHEN ord.rst_dialysis_state IN (''3'',''4'', ''5'', ''6'') then ''1''
    END as dialsisstartflg --透析運転開始フラグ
    ,to_char(ord.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') as dialsisstartdate--透析運転開始日時
    ,CASE
        WHEN water.machine_record_cd is null then ''0'' ELSE ''1''
    END as offwaterflg --除水完了フラグ
    ,to_char(water.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'') as offwaterdate --除水完了日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'') then ''0''
        WHEN ord.rst_dialysis_state IN (''4'',''5'',''6'') then ''1''
    END as wastefluidflg --排液フラグ
    ,to_char(ord.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'')  as wastefluiddate --排液日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'',''4'') then ''0''
        WHEN ord.rst_dialysis_state IN (''5'',''6'') then ''1''
    END as weightafterflg --後体重測定フラグ
    ,ord.weightafterdate --後体重測定日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'',''4'',''5'') then ''0''
        WHEN ord.rst_dialysis_state IN (''6'') then ''1''
    END as recoverybtnflg --準備回収確認ボタンフラグ
    ,to_char(ord.rst_edition_date, ''YYYY-MM-DD hh24:mi:ss'') as recoverybtndate--準備回収確認ボタン日時
    ,to_char(ord.cur_edition_date, ''YYYY-MM-DD hh24:mi:ss'') as update --更新日時
    ,ord.ord_no AS dialysisno --透析番号
from
    ord_main_tmp as ord
    left join off_water_tmp as water on ord.ord_no = water.ord_no
    left join machine_check_tmp as machine on ord.ord_no = machine.ord_no;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
