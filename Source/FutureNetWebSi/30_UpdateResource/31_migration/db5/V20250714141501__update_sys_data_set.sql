DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102006;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102006, '-- SQL:-1102006 begin
WITH ord_main_switch AS(
    (
        SELECT ord.rst_dialysis_state as rst_dialysis_state,
            ord.rst_edition_date as up_date_switch
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
    )
    UNION
    (
        SELECT ord.rst_dialysis_state as rst_dialysis_state,
            ord.del_date as up_date_switch
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
)

SELECT ''01'' as detail_id,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @key0 AS key0,
    @patId AS pat_id,
    @ordNo AS ord_no,
    @fileName AS file_name,
    @folderName AS folder_name
FROM ord_main_switch
WHERE rst_dialysis_state = ''0'';
-- SQL:-1102006 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携_予約受付のdetail特定', '2025-06-25 16:03:16.883', current_timestamp, '[{"sql_cd": -1100009, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);