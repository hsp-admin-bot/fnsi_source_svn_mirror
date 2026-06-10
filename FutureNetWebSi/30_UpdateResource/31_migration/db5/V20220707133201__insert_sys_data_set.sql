delete from ntss.sys_data_set where sql_cd in (-500, -502);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-500, 'WITH dialysateSql AS (
    SELECT
        1 AS order_no,
        COALESCE ( info ->> ''value'', info ->> ''default_v'' ) :: INT AS dialysateTransCd 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
        
        AND is_del = ''0'' 
        AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
        AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' UNION
    SELECT
        2 AS order_no,
        0 AS dialysateTransCd 
    ORDER BY
        order_no ASC 
        LIMIT 1 
    ) SELECT
CASE
        
    WHEN
        ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ISNULL THEN
            ( CASE dialysateSql.dialysateTransCd WHEN 0 THEN ''0'' WHEN 1 THEN ''000'' END ) 
                WHEN ( ord.ind_cond_info -> ''17'' ->> ''value'' ) :: NUMERIC >= 1 THEN
                (
                CASE
                        
                        WHEN strpos( ( ord.ind_cond_info -> ''17'' ->> ''value'' ), ''.'' ) <= 0 THEN
                        TRIM ( to_char( ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) :: NUMERIC ) * 100, ''999999'' ) ) ELSE TRIM (
                            to_char(
                                (
                                    SUBSTR(
                                        TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ),
                                        0,
                                        strpos( ( ord.ind_cond_info -> ''17'' ->> ''value'' ), ''.'' ) + 3 
                                    ) :: NUMERIC 
                                ) * 100,
                                ''999999'' 
                            ) 
                        ) 
                    END 
                        ) ELSE (
                    CASE
                            dialysateSql.dialysateTransCd 
                            WHEN 0 THEN
                            TRIM (
                                to_char(
                                    ( SUBSTR( TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ), 0, 5 ) :: NUMERIC ) * 100,
                                    ''99'' 
                                ) 
                            ) 
                            WHEN 1 THEN
                            TRIM (
                                to_char(
                                    ( SUBSTR( TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ), 0, 5 ) :: NUMERIC ) * 100,
                                    ''000'' 
                                ) 
                            ) 
                        END 
                        ) 
                    END AS dialysate_amount 
                FROM
                    ord_main ord,
                    dialysateSql 
            WHERE
    ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)ind_dial連携:透析液使用量（単体薬剤）', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-502, 'WITH dialysateSql AS (
    SELECT
        1 AS order_no,
        COALESCE ( info ->> ''value'', info ->> ''default_v'' ) :: INT AS dialysateTransCd 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
        
        AND is_del = ''0'' 
        AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
        AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' UNION
    SELECT
        2 AS order_no,
        0 AS dialysateTransCd 
    ORDER BY
        order_no ASC 
        LIMIT 1 
    ) SELECT
CASE
        
    WHEN
        ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ISNULL THEN
            ( CASE dialysateSql.dialysateTransCd WHEN 0 THEN ''0'' WHEN 1 THEN ''000'' END ) 
                WHEN ( ord.ind_cond_info -> ''17'' ->> ''value'' ) :: NUMERIC >= 1 THEN
                (
                CASE
                        
                        WHEN strpos( ( ord.ind_cond_info -> ''17'' ->> ''value'' ), ''.'' ) <= 0 THEN
                        TRIM ( to_char( ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) :: NUMERIC ) * 100, ''999999'' ) ) ELSE TRIM (
                            to_char(
                                (
                                    SUBSTR(
                                        TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ),
                                        0,
                                        strpos( ( ord.ind_cond_info -> ''17'' ->> ''value'' ), ''.'' ) + 3 
                                    ) :: NUMERIC 
                                ) * 100,
                                ''999999'' 
                            ) 
                        ) 
                    END 
                        ) ELSE (
                    CASE
                            dialysateSql.dialysateTransCd 
                            WHEN 0 THEN
                            TRIM (
                                to_char(
                                    ( SUBSTR( TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ), 0, 5 ) :: NUMERIC ) * 100,
                                    ''99'' 
                                ) 
                            ) 
                            WHEN 1 THEN
                            TRIM (
                                to_char(
                                    ( SUBSTR( TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ), 0, 5 ) :: NUMERIC ) * 100,
                                    ''000'' 
                                ) 
                            ) 
                        END 
                        ) 
                    END AS dialysate_amount 
                FROM
                    ord_main_restore ord,
                    dialysateSql 
            WHERE
    ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)ind_dial連携:透析液使用量（単体薬剤）DEL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
