DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2420,-2051)
;


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2420, 'WITH sys_moni AS (
    SELECT
        moni_data_no,
        moni_data_name
    FROM
        sys_monitor_item
    WHERE
        moni_data_no BETWEEN ''-2'' AND ''148''
        AND sys_monitor_item.is_disp = ''1''
        AND sys_monitor_item.moni_data_type IS NULL
        AND sys_monitor_item.data_type between 1 and 3
)
        SELECT 
    m_b.in_hospital_cd_1 AS bedno --ベッド番号
    , m_m.in_hospital_cd_1 AS deviceno --装置番号
    , to_char(mm.occur_date,''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
    , om.pat_id AS patid
    , '''' AS hosppatid --患者ID
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''1'') AS moniname1
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''1'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''1'' ::TEXT <> ''-1'' THEN mm.monitor_data ->> ''1'' 
        END
    END AS moniitem1
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''2'') AS moniname2
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''2'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''2'' ::TEXT <> ''-1'' THEN mm.monitor_data ->> ''2'' 
        END
    END AS moniitem2
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''3'') AS moniname3
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''3'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''3'' ::TEXT <> ''-1'' THEN mm.monitor_data ->> ''3'' 
        END
    END AS moniitem3
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''4'') AS moniname4
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''4'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''4''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''4''
        END
    END AS moniitem4
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''5'') AS moniname5
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''5'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''5''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''5''
        END
    END AS moniitem5
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''6'') AS moniname6
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''6'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''6''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''6''
        END
    END AS moniitem6
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''7'') AS moniname7
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''7'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''7''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''7''
        END
    END AS moniitem7
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''8'') AS moniname8
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''8'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''8''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''8''
        END
    END AS moniitem8
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''9'') AS moniname9
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''9'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''9''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''9''
        END
    END AS moniitem9
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''10'') AS moniname10
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''10'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''10''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''10''
        END
    END AS moniitem10
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''11'') AS moniname11
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''11'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''11''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''11''
        END
    END AS moniitem11
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''12'') AS moniname12
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''12'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''12''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''12''
        END
    END AS moniitem12
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''13'') AS moniname13
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''13'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''13''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''13''
        END
    END AS moniitem13
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''14'') AS moniname14
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''14'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''14''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''14''
        END
    END AS moniitem14
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''15'') AS moniname15
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''15'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''15''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''15''
        END
    END AS moniitem15
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''16'') AS moniname16
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''16'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''16''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''16''
        END
    END AS moniitem16
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''17'') AS moniname17
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''17'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''17''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''17''
        END
    END AS moniitem17
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''18'') AS moniname18
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''18'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''18''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''18''
        END
    END AS moniitem18
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''19'') AS moniname19
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''19'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''19''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''19''
        END
    END AS moniitem19
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''20'') AS moniname20
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''20'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''20''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''20''
        END
    END AS moniitem20
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''21'') AS moniname21
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''21'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''21''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''21''
        END
    END AS moniitem21
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''22'') AS moniname22
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''22'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''22''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''22''
        END
    END AS moniitem22
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''23'') AS moniname23
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''23'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''23''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''23''
        END
    END AS moniitem23
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''24'') AS moniname24
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''24'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''24''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''24''
        END
    END AS moniitem24
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''25'') AS moniname25
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''25'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''25''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''25''
        END
    END AS moniitem25
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''26'') AS moniname26
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''26'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''26''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''26''
        END
    END AS moniitem26
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''27'') AS moniname27
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''27'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''27''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''27''
        END
    END AS moniitem27
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''28'') AS moniname28
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''28'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''28''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''28''
        END
    END AS moniitem28
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''29'') AS moniname29
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''29'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''29''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''29''
        END
    END AS moniitem29
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''30'') AS moniname30
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''30'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''30''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''30''
        END
    END AS moniitem30
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''31'') AS moniname31
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''31'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''31''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''31''
        END
    END AS moniitem31
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''32'') AS moniname32
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''32'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''32''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''32''
        END
    END AS moniitem32
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''33'') AS moniname33
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''33'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''33''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''33''
        END
    END AS moniitem33
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''34'') AS moniname34
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''34'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''34''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''34''
        END
    END AS moniitem34
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''35'') AS moniname35
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''35'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''35''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''35''
        END
    END AS moniitem35
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''36'') AS moniname36
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''36'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''36''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''36''
        END
    END AS moniitem36
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''37'') AS moniname37
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''37'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''37''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''37''
        END
    END AS moniitem37
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''38'') AS moniname38
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''38'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''38''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''38''
        END
    END AS moniitem38
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''39'') AS moniname39
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''39'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''39''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''39''
        END
    END AS moniitem39
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''40'') AS moniname40
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''40'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''40''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''40''
        END
    END AS moniitem40
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''41'') AS moniname41
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''41'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''41''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''41''
        END
    END AS moniitem41
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''42'') AS moniname42
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''42'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''42''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''42''
        END
    END AS moniitem42
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''43'') AS moniname43
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''43'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''43''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''43''
        END
    END AS moniitem43
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''44'') AS moniname44
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''44'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''44''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''44''
        END
    END AS moniitem44
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''45'') AS moniname45
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''45'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''45''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''45''
        END
    END AS moniitem45
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''46'') AS moniname46
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''46'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''46''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''46''
        END
    END AS moniitem46
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''47'') AS moniname47
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''47'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''47''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''47''
        END
    END AS moniitem47
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''48'') AS moniname48
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''48'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''48''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''48''
        END
    END AS moniitem48
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''49'') AS moniname49
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''49'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''49''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''49''
        END
    END AS moniitem49
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''50'') AS moniname50
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''50'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''50''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''50''
        END
    END AS moniitem50
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''51'') AS moniname51
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''51'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''51''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''51''
        END
    END AS moniitem51
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''52'') AS moniname52
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''52'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''52''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''52''
        END
    END AS moniitem52
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''53'') AS moniname53
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''53'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''53''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''53''
        END
    END AS moniitem53
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''54'') AS moniname54
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''54'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''54''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''54''
        END
    END AS moniitem54
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''55'') AS moniname55
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''55'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''55''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''55''
        END
    END AS moniitem55
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''56'') AS moniname56
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''56'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''56''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''56''
        END
    END AS moniitem56
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''57'') AS moniname57
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''57'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''57''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''57''
        END
    END AS moniitem57
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''58'') AS moniname58
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''58'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''58''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''58''
        END
    END AS moniitem58
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''59'') AS moniname59
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''59'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''59''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''59''
        END
    END AS moniitem59
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''60'') AS moniname60
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''60'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''60''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''60''
        END
    END AS moniitem60
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''61'') AS moniname61
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''61'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''61''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''61''
        END
    END AS moniitem61
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''62'') AS moniname62
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''62'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''62''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''62''
        END
    END AS moniitem62
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''63'') AS moniname63
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''63'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''63''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''63''
        END
    END AS moniitem63
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''64'') AS moniname64
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''64'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''64''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''64''
        END
    END AS moniitem64
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''65'') AS moniname65
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''65'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''65''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''65''
        END
    END AS moniitem65
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''66'') AS moniname66
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''66'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''66''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''66''
        END
    END AS moniitem66
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''67'') AS moniname67
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''67'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''67''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''67''
        END
    END AS moniitem67
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''68'') AS moniname68
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''68'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''68''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''68''
        END
    END AS moniitem68
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''69'') AS moniname69
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''69'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''69''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''69''
        END
    END AS moniitem69
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''70'') AS moniname70
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''70'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''70''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''70''
        END
    END AS moniitem70
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''71'') AS moniname71
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''71'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''71''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''71''
        END
    END AS moniitem71
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''72'') AS moniname72
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''72'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''72''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''72''
        END
    END AS moniitem72
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''73'') AS moniname73
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''73'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''73''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''73''
        END
    END AS moniitem73
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''74'') AS moniname74
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''74'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''74''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''74''
        END
    END AS moniitem74
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''75'') AS moniname75
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''75'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''75''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''75''
        END
    END AS moniitem75
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''76'') AS moniname76
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''76'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''76''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''76''
        END
    END AS moniitem76
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''77'') AS moniname77
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''77'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''77''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''77''
        END
    END AS moniitem77
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''78'') AS moniname78
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''78'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''78''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''78''
        END
    END AS moniitem78
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''79'') AS moniname79
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''79'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''79''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''79''
        END
    END AS moniitem79
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''80'') AS moniname80
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''80'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''80''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''80''
        END
    END AS moniitem80
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''81'') AS moniname81
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''81'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''81''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''81''
        END
    END AS moniitem81
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''82'') AS moniname82
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''82'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''82''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''82''
        END
    END AS moniitem82
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''83'') AS moniname83
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''83'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''83''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''83''
        END
    END AS moniitem83
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''84'') AS moniname84
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''84'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''84''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''84''
        END
    END AS moniitem84
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''85'') AS moniname85
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''85'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''85''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''85''
        END
    END AS moniitem85
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''86'') AS moniname86
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''86'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''86''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''86''
        END
    END AS moniitem86
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''87'') AS moniname87
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''87'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''87''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''87''
        END
    END AS moniitem87
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''88'') AS moniname88
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''88'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''88''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''88''
        END
    END AS moniitem88
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''89'') AS moniname89
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''89'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''89''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''89''
        END
    END AS moniitem89
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''90'') AS moniname90
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''90'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''90''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''90''
        END
    END AS moniitem90
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''91'') AS moniname91
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''91'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''91''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''91''
        END
    END AS moniitem91
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''92'') AS moniname92
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''92'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''92''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''92''
        END
    END AS moniitem92
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''93'') AS moniname93
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''93'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''93''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''93''
        END
    END AS moniitem93
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''94'') AS moniname94
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''94'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''94''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''94''
        END
    END AS moniitem94
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''95'') AS moniname95
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''95'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''95''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''95''
        END
    END AS moniitem95
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''96'') AS moniname96
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''96'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''96''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''96''
        END
    END AS moniitem96
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''97'') AS moniname97
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''97'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''97''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''97''
        END
    END AS moniitem97
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''98'') AS moniname98
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''98'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''98''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''98''
        END
    END AS moniitem98
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''99'') AS moniname99
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''99'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''99''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''99''
        END
    END AS moniitem99
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''100'') AS moniname100
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''100'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''100''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''100''
        END
    END AS moniitem100
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''101'') AS moniname101
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''101'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''101''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''101''
        END
    END AS moniitem101
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''102'') AS moniname102
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''102'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''102''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''102''
        END
    END AS moniitem102
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''103'') AS moniname103
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''103'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''103''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''103''
        END
    END AS moniitem103
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''104'') AS moniname104
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''104'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''104''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''104''
        END
    END AS moniitem104
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''105'') AS moniname105
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''105'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''105''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''105''
        END
    END AS moniitem105
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''106'') AS moniname106
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''106'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''106''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''106''
        END
    END AS moniitem106
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''107'') AS moniname107
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''107'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''107''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''107''
        END
    END AS moniitem107
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''108'') AS moniname108
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''108'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''108''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''108''
        END
    END AS moniitem108
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''109'') AS moniname109
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''109'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''109''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''109''
        END
    END AS moniitem109
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''110'') AS moniname110
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''110'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''110''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''110''
        END
    END AS moniitem110
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''111'') AS moniname111
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''111'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''111''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''111''
        END
    END AS moniitem111
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''112'') AS moniname112
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''112'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''112''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''112''
        END
    END AS moniitem112
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''113'') AS moniname113
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''113'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''113''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''113''
        END
    END AS moniitem113
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''114'') AS moniname114
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''114'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''114''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''114''
        END
    END AS moniitem114
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''115'') AS moniname115
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''115'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''115''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''115''
        END
    END AS moniitem115
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''116'') AS moniname116
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''116'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''116''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''116''
        END
    END AS moniitem116
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''117'') AS moniname117
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''117'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''117''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''117''
        END
    END AS moniitem117
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''118'') AS moniname118
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''118'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''118''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''118''
        END
    END AS moniitem118
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''119'') AS moniname119
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''119'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''119''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''119''
        END
    END AS moniitem119
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''120'') AS moniname120
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''120'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''120''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''120''
        END
    END AS moniitem120
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''121'') AS moniname121
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''121'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''121''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''121''
        END
    END AS moniitem121
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''122'') AS moniname122
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''122'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''122''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''122''
        END
    END AS moniitem122
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''123'') AS moniname123
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''123'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''123''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''123''
        END
    END AS moniitem123
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''124'') AS moniname124
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''124'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''124''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''124''
        END
    END AS moniitem124
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''125'') AS moniname125
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''125'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''125''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''125''
        END
    END AS moniitem125
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''126'') AS moniname126
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''126'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''126''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''126''
        END
    END AS moniitem126
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''127'') AS moniname127
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''127'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''127''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''127''
        END
    END AS moniitem127
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''128'') AS moniname128
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''128'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''128''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''128''
        END
    END AS moniitem128
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''129'') AS moniname129
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''129'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''129''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''129''
        END
    END AS moniitem129
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''130'') AS moniname130
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''130'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''130''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''130''
        END
    END AS moniitem130
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''131'') AS moniname131
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''131'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''131''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''131''
        END
    END AS moniitem131
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''132'') AS moniname132
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''132'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''132''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''132''
        END
    END AS moniitem132
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''133'') AS moniname133
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''133'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''133''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''133''
        END
    END AS moniitem133
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''134'') AS moniname134
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''134'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''134''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''134''
        END
    END AS moniitem134
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''135'') AS moniname135
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''135'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''135''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''135''
        END
    END AS moniitem135
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''136'') AS moniname136
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''136'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''136''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''136''
        END
    END AS moniitem136
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''137'') AS moniname137
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''137'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''137''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''137''
        END
    END AS moniitem137
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''138'') AS moniname138
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''138'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''138''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''138''
        END
    END AS moniitem138
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''139'') AS moniname139
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''139'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''139''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''139''
        END
    END AS moniitem139
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''140'') AS moniname140
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''140'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''140''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''140''
        END
    END AS moniitem140
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''141'') AS moniname141
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''141'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''141''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''141''
        END
    END AS moniitem141
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''142'') AS moniname142
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''142'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''142''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''142''
        END
    END AS moniitem142
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''143'') AS moniname143
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''143'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''143''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''143''
        END
    END AS moniitem143
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''144'') AS moniname144
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''144'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''144''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''144''
        END
    END AS moniitem144
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''145'') AS moniname145
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''145'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''145''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''145''
        END
    END AS moniitem145
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''146'') AS moniname146
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''146'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''146''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''146''
        END
    END AS moniitem146
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''147'') AS moniname147
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''147'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''147''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''147''
        END
    END AS moniitem147
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''148'') AS moniname148
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''148'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''148''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''148''
        END
    END AS moniitem148
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-2'') AS moniname149
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-2'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''-2''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''-2''
        END
    END AS moniitem149
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-1'') AS moniname150
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-1'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''-1''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''-1''
        END
    END AS moniitem150
    , to_char(mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , om.ord_no AS ordno --透析番号
    , om.treat_date AS dialysisdate --透析日
        FROM
            ord_main om
            JOIN mni_monitor mm
                ON mm.ord_no = om.ord_no
                AND mm.facility_cd = @facilityCd
                AND mm.is_del = ''0''
            LEFT JOIN mst_machine m_m
                ON m_m.machine_no = om.rst_machine_no
                AND m_m.facility_cd = @facilityCd
            LEFT JOIN mst_bed m_b
                ON om.rst_bed_cd = m_b.bed_cd
        WHERE
            om.facility_cd = @facilityCd
            AND @fromDate <= om.treat_date AND om.treat_date < @toDate
            AND mm.data_type IN (1,2,5,6);
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
