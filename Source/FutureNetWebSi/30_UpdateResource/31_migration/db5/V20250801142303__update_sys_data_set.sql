DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103013;

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103013, '-- SQL: -1103013 begin
WITH ord_main_switch AS(
    -- ord_mainまたはord_main_restoreから、当連携処理のord_noに該当するの最新のレコードを取得する
    (
        SELECT TRUE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.rst_edition_date AS up_date_switch
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
            and is_del = ''0''
    )
    UNION
    (
        select FALSE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.del_date AS up_date_switch
        FROM ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY del_date DESC
        LIMIT 1
    )
    ORDER BY up_date_switch DESC NULLS LAST
    LIMIT 1
), inject_cancel_file_output_flg AS (
    -- 注射中止ファイル出力有無を判断するフラグを取得する
    SELECT CASE
            -- 処理対象ord_noのord_mainが存在しない場合
            -- 予定そのものが削除されたと判断し、注射中止ファイルを出力する
            WHEN oms.is_from_ord_main = FALSE THEN TRUE 
            -- 処理対象ord_noのord_mainが存在する場合
            -- rst_dialysis_stateが0(条件送信前)の時は実績が削除されたと判断し、注射中止ファイルを出力する
            WHEN oms.rst_dialysis_state = ''0'' THEN TRUE 
            -- それ以外の場合
            -- 処理対象ord_noのord_mainが存在する & rst_dialysis_stateが0(条件送信前)以外の場合
            -- 実績の更新処理だと判断し、注射中止ファイルを出力しない
            ELSE FALSE
        END AS value
    FROM ord_main_switch AS oms
)


select  
    ''01'' as detail_id,
    -- このカラムはdummyの実装です。
    -- -1103004のrp_noの実装が入ります。
    -- (SQL作成完了後、このコメントは削除してください)
    generate_series(1, 10) as rp_no 
where (select value from inject_cancel_file_output_flg)
-- SQL: -1103013 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射中止ファイル', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);