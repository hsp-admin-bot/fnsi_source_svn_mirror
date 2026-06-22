DELETE FROM sys_data_set WHERE sql_cd IN (-500064);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500064, 'WITH ssi_order_recv_info AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_ORDER_RECV''
    AND info->>''key2'' = ''BEDNO''
) 
select
    1
where
    @indBedCd in (SELECT  regexp_split_to_table(VALUE,'','') FROM ssi_order_recv_info)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのベッド(SELECT)', '2025-05-28 01:58:27.087', CURRENT_TIMESTAMP, NULL);