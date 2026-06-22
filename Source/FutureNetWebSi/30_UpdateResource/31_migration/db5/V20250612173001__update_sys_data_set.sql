DELETE FROM sys_data_set WHERE sql_cd IN 
(-1202020);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202020, 'with hosp_code as (
    -- 病院コード デフォルト(000000)
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_EXAM_SCHE_INFO''
        and info->>''key2'' = ''HOSP_CODE''
)

SELECT
  ''O'' || 
  coalesce( (SELECT value FROM hosp_code) , ''000000'')  ||
  ''-'' ||
  coalesce(journal.coop_ord_no, '''')  ||
  ''-'' ||
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') ||
  ''.dat'' AS filename
FROM
  sys_coop_journal AS journal
WHERE
  journal.ctl_no = @ctlNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_透析実績[送信]ファイル名取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
