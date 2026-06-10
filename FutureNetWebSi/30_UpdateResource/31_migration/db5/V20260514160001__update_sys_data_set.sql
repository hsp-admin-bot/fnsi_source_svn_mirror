DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-2430, -2450);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2430, 'WITH sys_moni AS (
    SELECT
        moni_data_no,
        moni_data_name
    FROM
        sys_monitor_item
    WHERE
        moni_data_no IN (''-1'',''-2'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'',''11'',''12'',''13'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'',''39'',''40'',''41'',''42'',''43'',''44'',''45'',''46'',''47'',''48'',''49'',''50'',''51'',''52'',''53'',''54'',''55'',''56'',''57'',''58'',''59'',''60'',''61'',''62'',''63'',''64'',''65'',''66'',''67'',''68'',''69'',''70'',''71'',''72'',''73'',''74'',''75'',''76'',''77'',''78'',''79'',''80'',''81'',''82'',''83'',''84'',''85'',''86'',''87'',''88'',''89'',''90'',''91'',''92'',''93'',''94'',''95'',''96'',''97'',''98'',''99'',''100'',''101'',''102'',''103'',''104'',''105'',''106'',''107'',''108'',''109'',''110'',''111'',''112'',''113'',''114'',''115'',''116'',''117'',''118'',''119'',''120'',''121'',''122'',''123'',''124'',''125'',''126'',''127'',''128'',''129'',''130'',''131'',''132'',''133'',''134'',''135'',''136'',''137'',''138'',''139'',''140'',''141'',''142'',''143'',''144'',''145'',''146'',''147'',''148'',''149'',''150'')
        AND sys_monitor_item.is_disp = ''1''
        AND sys_monitor_item.moni_data_type IS NULL
        AND sys_monitor_item.data_type BETWEEN 1 AND 3
)
        SELECT 
    ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
    , ntss_db5_mst_m.in_hospital_cd_1 AS deviceno --装置番号
    , to_char(ntss_db5_mm.occur_date,''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
    , ntss_db5_om.pat_id AS patid
    , '''' AS hosppatid --患者ID
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''1'') AS moniname1
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''1'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''1'' ::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''1'' 
        END
    END AS moniitem1
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''2'') AS moniname2
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''2'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''2'' ::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''2'' 
        END
    END AS moniitem2
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''3'') AS moniname3
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''3'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''3'' ::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''3'' 
        END
    END AS moniitem3
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''4'') AS moniname4
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''4'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''4''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''4''
        END
    END AS moniitem4
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''5'') AS moniname5
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''5'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''5''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''5''
        END
    END AS moniitem5
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''6'') AS moniname6
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''6'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''6''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''6''
        END
    END AS moniitem6
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''7'') AS moniname7
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''7'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''7''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''7''
        END
    END AS moniitem7
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''8'') AS moniname8
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''8'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''8''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''8''
        END
    END AS moniitem8
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''9'') AS moniname9
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''9'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''9''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''9''
        END
    END AS moniitem9
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''10'') AS moniname10
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''10'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''10''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''10''
        END
    END AS moniitem10
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''11'') AS moniname11
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''11'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''11''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''11''
        END
    END AS moniitem11
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''12'') AS moniname12
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''12'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''12''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''12''
        END
    END AS moniitem12
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''13'') AS moniname13
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''13'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''13''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''13''
        END
    END AS moniitem13
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''14'') AS moniname14
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''14'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''14''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''14''
        END
    END AS moniitem14
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''15'') AS moniname15
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''15'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''15''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''15''
        END
    END AS moniitem15
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''16'') AS moniname16
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''16'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''16''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''16''
        END
    END AS moniitem16
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''17'') AS moniname17
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''17'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''17''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''17''
        END
    END AS moniitem17
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''18'') AS moniname18
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''18'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''18''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''18''
        END
    END AS moniitem18
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''19'') AS moniname19
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''19'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''19''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''19''
        END
    END AS moniitem19
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''20'') AS moniname20
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''20'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''20''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''20''
        END
    END AS moniitem20
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''21'') AS moniname21
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''21'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''21''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''21''
        END
    END AS moniitem21
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''22'') AS moniname22
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''22'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''22''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''22''
        END
    END AS moniitem22
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''23'') AS moniname23
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''23'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''23''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''23''
        END
    END AS moniitem23
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''24'') AS moniname24
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''24'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''24''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''24''
        END
    END AS moniitem24
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''25'') AS moniname25
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''25'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''25''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''25''
        END
    END AS moniitem25
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''26'') AS moniname26
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''26'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''26''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''26''
        END
    END AS moniitem26
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''27'') AS moniname27
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''27'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''27''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''27''
        END
    END AS moniitem27
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''28'') AS moniname28
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''28'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''28''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''28''
        END
    END AS moniitem28
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''29'') AS moniname29
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''29'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''29''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''29''
        END
    END AS moniitem29
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''30'') AS moniname30
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''30'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''30''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''30''
        END
    END AS moniitem30
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''31'') AS moniname31
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''31'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''31''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''31''
        END
    END AS moniitem31
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''32'') AS moniname32
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''32'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''32''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''32''
        END
    END AS moniitem32
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''33'') AS moniname33
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''33'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''33''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''33''
        END
    END AS moniitem33
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''34'') AS moniname34
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''34'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''34''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''34''
        END
    END AS moniitem34
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''35'') AS moniname35
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''35'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''35''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''35''
        END
    END AS moniitem35
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''36'') AS moniname36
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''36'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''36''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''36''
        END
    END AS moniitem36
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''37'') AS moniname37
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''37'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''37''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''37''
        END
    END AS moniitem37
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''38'') AS moniname38
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''38'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''38''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''38''
        END
    END AS moniitem38
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''39'') AS moniname39
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''39'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''39''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''39''
        END
    END AS moniitem39
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''40'') AS moniname40
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''40'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''40''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''40''
        END
    END AS moniitem40
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''41'') AS moniname41
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''41'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''41''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''41''
        END
    END AS moniitem41
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''42'') AS moniname42
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''42'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''42''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''42''
        END
    END AS moniitem42
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''43'') AS moniname43
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''43'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''43''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''43''
        END
    END AS moniitem43
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''44'') AS moniname44
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''44'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''44''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''44''
        END
    END AS moniitem44
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''45'') AS moniname45
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''45'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''45''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''45''
        END
    END AS moniitem45
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''46'') AS moniname46
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''46'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''46''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''46''
        END
    END AS moniitem46
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''47'') AS moniname47
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''47'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''47''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''47''
        END
    END AS moniitem47
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''48'') AS moniname48
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''48'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''48''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''48''
        END
    END AS moniitem48
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''49'') AS moniname49
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''49'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''49''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''49''
        END
    END AS moniitem49
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''50'') AS moniname50
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''50'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''50''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''50''
        END
    END AS moniitem50
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''51'') AS moniname51
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''51'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''51''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''51''
        END
    END AS moniitem51
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''52'') AS moniname52
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''52'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''52''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''52''
        END
    END AS moniitem52
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''53'') AS moniname53
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''53'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''53''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''53''
        END
    END AS moniitem53
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''54'') AS moniname54
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''54'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''54''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''54''
        END
    END AS moniitem54
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''55'') AS moniname55
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''55'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''55''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''55''
        END
    END AS moniitem55
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''56'') AS moniname56
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''56'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''56''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''56''
        END
    END AS moniitem56
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''57'') AS moniname57
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''57'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''57''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''57''
        END
    END AS moniitem57
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''58'') AS moniname58
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''58'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''58''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''58''
        END
    END AS moniitem58
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''59'') AS moniname59
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''59'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''59''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''59''
        END
    END AS moniitem59
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''60'') AS moniname60
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''60'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''60''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''60''
        END
    END AS moniitem60
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''61'') AS moniname61
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''61'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''61''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''61''
        END
    END AS moniitem61
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''62'') AS moniname62
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''62'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''62''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''62''
        END
    END AS moniitem62
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''63'') AS moniname63
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''63'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''63''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''63''
        END
    END AS moniitem63
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''64'') AS moniname64
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''64'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''64''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''64''
        END
    END AS moniitem64
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''65'') AS moniname65
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''65'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''65''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''65''
        END
    END AS moniitem65
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''66'') AS moniname66
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''66'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''66''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''66''
        END
    END AS moniitem66
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''67'') AS moniname67
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''67'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''67''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''67''
        END
    END AS moniitem67
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''68'') AS moniname68
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''68'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''68''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''68''
        END
    END AS moniitem68
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''69'') AS moniname69
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''69'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''69''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''69''
        END
    END AS moniitem69
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''70'') AS moniname70
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''70'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''70''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''70''
        END
    END AS moniitem70
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''71'') AS moniname71
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''71'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''71''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''71''
        END
    END AS moniitem71
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''72'') AS moniname72
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''72'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''72''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''72''
        END
    END AS moniitem72
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''73'') AS moniname73
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''73'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''73''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''73''
        END
    END AS moniitem73
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''74'') AS moniname74
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''74'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''74''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''74''
        END
    END AS moniitem74
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''75'') AS moniname75
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''75'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''75''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''75''
        END
    END AS moniitem75
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''76'') AS moniname76
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''76'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''76''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''76''
        END
    END AS moniitem76
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''77'') AS moniname77
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''77'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''77''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''77''
        END
    END AS moniitem77
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''78'') AS moniname78
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''78'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''78''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''78''
        END
    END AS moniitem78
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''79'') AS moniname79
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''79'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''79''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''79''
        END
    END AS moniitem79
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''80'') AS moniname80
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''80'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''80''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''80''
        END
    END AS moniitem80
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''81'') AS moniname81
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''81'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''81''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''81''
        END
    END AS moniitem81
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''82'') AS moniname82
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''82'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''82''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''82''
        END
    END AS moniitem82
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''83'') AS moniname83
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''83'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''83''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''83''
        END
    END AS moniitem83
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''84'') AS moniname84
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''84'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''84''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''84''
        END
    END AS moniitem84
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''85'') AS moniname85
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''85'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''85''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''85''
        END
    END AS moniitem85
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''86'') AS moniname86
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''86'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''86''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''86''
        END
    END AS moniitem86
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''87'') AS moniname87
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''87'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''87''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''87''
        END
    END AS moniitem87
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''88'') AS moniname88
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''88'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''88''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''88''
        END
    END AS moniitem88
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''89'') AS moniname89
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''89'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''89''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''89''
        END
    END AS moniitem89
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''90'') AS moniname90
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''90'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''90''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''90''
        END
    END AS moniitem90
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''91'') AS moniname91
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''91'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''91''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''91''
        END
    END AS moniitem91
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''92'') AS moniname92
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''92'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''92''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''92''
        END
    END AS moniitem92
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''93'') AS moniname93
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''93'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''93''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''93''
        END
    END AS moniitem93
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''94'') AS moniname94
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''94'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''94''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''94''
        END
    END AS moniitem94
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''95'') AS moniname95
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''95'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''95''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''95''
        END
    END AS moniitem95
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''96'') AS moniname96
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''96'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''96''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''96''
        END
    END AS moniitem96
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''97'') AS moniname97
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''97'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''97''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''97''
        END
    END AS moniitem97
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''98'') AS moniname98
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''98'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''98''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''98''
        END
    END AS moniitem98
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''99'') AS moniname99
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''99'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''99''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''99''
        END
    END AS moniitem99
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''100'') AS moniname100
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''100'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''100''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''100''
        END
    END AS moniitem100
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''101'') AS moniname101
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''101'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''101''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''101''
        END
    END AS moniitem101
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''102'') AS moniname102
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''102'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''102''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''102''
        END
    END AS moniitem102
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''103'') AS moniname103
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''103'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''103''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''103''
        END
    END AS moniitem103
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''104'') AS moniname104
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''104'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''104''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''104''
        END
    END AS moniitem104
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''105'') AS moniname105
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''105'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''105''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''105''
        END
    END AS moniitem105
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''106'') AS moniname106
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''106'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''106''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''106''
        END
    END AS moniitem106
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''107'') AS moniname107
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''107'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''107''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''107''
        END
    END AS moniitem107
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''108'') AS moniname108
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''108'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''108''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''108''
        END
    END AS moniitem108
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''109'') AS moniname109
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''109'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''109''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''109''
        END
    END AS moniitem109
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''110'') AS moniname110
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''110'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''110''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''110''
        END
    END AS moniitem110
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''111'') AS moniname111
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''111'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''111''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''111''
        END
    END AS moniitem111
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''112'') AS moniname112
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''112'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''112''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''112''
        END
    END AS moniitem112
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''113'') AS moniname113
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''113'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''113''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''113''
        END
    END AS moniitem113
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''114'') AS moniname114
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''114'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''114''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''114''
        END
    END AS moniitem114
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''115'') AS moniname115
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''115'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''115''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''115''
        END
    END AS moniitem115
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''116'') AS moniname116
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''116'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''116''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''116''
        END
    END AS moniitem116
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''117'') AS moniname117
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''117'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''117''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''117''
        END
    END AS moniitem117
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''118'') AS moniname118
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''118'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''118''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''118''
        END
    END AS moniitem118
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''119'') AS moniname119
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''119'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''119''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''119''
        END
    END AS moniitem119
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''120'') AS moniname120
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''120'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''120''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''120''
        END
    END AS moniitem120
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''121'') AS moniname121
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''121'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''121''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''121''
        END
    END AS moniitem121
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''122'') AS moniname122
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''122'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''122''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''122''
        END
    END AS moniitem122
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''123'') AS moniname123
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''123'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''123''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''123''
        END
    END AS moniitem123
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''124'') AS moniname124
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''124'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''124''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''124''
        END
    END AS moniitem124
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''125'') AS moniname125
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''125'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''125''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''125''
        END
    END AS moniitem125
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''126'') AS moniname126
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''126'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''126''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''126''
        END
    END AS moniitem126
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''127'') AS moniname127
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''127'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''127''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''127''
        END
    END AS moniitem127
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''128'') AS moniname128
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''128'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''128''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''128''
        END
    END AS moniitem128
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''129'') AS moniname129
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''129'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''129''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''129''
        END
    END AS moniitem129
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''130'') AS moniname130
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''130'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''130''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''130''
        END
    END AS moniitem130
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''131'') AS moniname131
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''131'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''131''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''131''
        END
    END AS moniitem131
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''132'') AS moniname132
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''132'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''132''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''132''
        END
    END AS moniitem132
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''133'') AS moniname133
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''133'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''133''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''133''
        END
    END AS moniitem133
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''134'') AS moniname134
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''134'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''134''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''134''
        END
    END AS moniitem134
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''135'') AS moniname135
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''135'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''135''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''135''
        END
    END AS moniitem135
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''136'') AS moniname136
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''136'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''136''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''136''
        END
    END AS moniitem136
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''137'') AS moniname137
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''137'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''137''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''137''
        END
    END AS moniitem137
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''138'') AS moniname138
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''138'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''138''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''138''
        END
    END AS moniitem138
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''139'') AS moniname139
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''139'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''139''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''139''
        END
    END AS moniitem139
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''140'') AS moniname140
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''140'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''140''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''140''
        END
    END AS moniitem140
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''141'') AS moniname141
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''141'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''141''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''141''
        END
    END AS moniitem141
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''142'') AS moniname142
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''142'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''142''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''142''
        END
    END AS moniitem142
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''143'') AS moniname143
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''143'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''143''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''143''
        END
    END AS moniitem143
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''144'') AS moniname144
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''144'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''144''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''144''
        END
    END AS moniitem144
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''145'') AS moniname145
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''145'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''145''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''145''
        END
    END AS moniitem145
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''146'') AS moniname146
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''146'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''146''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''146''
        END
    END AS moniitem146
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''147'') AS moniname147
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''147'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''147''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''147''
        END
    END AS moniitem147
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''148'') AS moniname148
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''148'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''148''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''148''
        END
    END AS moniitem148
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''149'') AS moniname149
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''149'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''149''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''149''
        END
    END AS moniitem149
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''150'') AS moniname150
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''150'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''150''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''150''
        END
    END AS moniitem150
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-1'') AS moniname151
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-1'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''-1''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''-1''
        END
    END AS moniitem151
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-2'') AS moniname152
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-2'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''-2''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''-2''
        END
    END AS moniitem152
    , to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ntss_db5_om.ord_no AS ordno --透析番号
    , ntss_db5_om.treat_date AS dialysisdate --透析日
        FROM
            ord_main ntss_db5_om
            JOIN mni_monitor ntss_db5_mm
                ON ntss_db5_mm.facility_cd = ntss_db5_om.facility_cd
                AND ntss_db5_mm.ord_no = ntss_db5_om.ord_no
                AND ntss_db5_mm.is_del = ''0''
            LEFT JOIN mst_machine ntss_db5_mst_m
                ON ntss_db5_mst_m.machine_no = ntss_db5_om.rst_machine_no
                AND ntss_db5_mst_m.facility_cd = ntss_db5_om.facility_cd
                AND ntss_db5_mst_m.is_del = ''0''
                AND ntss_db5_mst_m.is_disp = ''1''
            LEFT JOIN mst_bed ntss_db5_mst_b
                ON ntss_db5_om.rst_bed_cd = ntss_db5_mst_b.bed_cd
                AND ntss_db5_mst_b.is_del = ''0''
                AND ntss_db5_mst_b.is_disp = ''1''
        WHERE
            ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.ord_no = ANY (string_to_array(@paramList1, '','')::bigint[])
            AND ntss_db5_om.rst_dialysis_state BETWEEN ''1'' AND ''5''
            AND ntss_db5_mm.data_type IN (1,2,5,6);', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2450, '-- 【SQL_CD=-2450】
WITH
  elements AS (
    SELECT
      ctlno,
      setname,
      elemkey,
      datapattern,
      defaultvalue
    FROM
      jsonb_to_recordset(
        ''[
    {"ctlno":"1","setname":"静脈圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0100","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"100"},
    {"ctlno":"2","setname":"静脈圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0101","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"101"},
    {"ctlno":"3","setname":"静脈圧自動設定警報限界上限","elemkey":"dev-A-0102","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"102"},
    {"ctlno":"4","setname":"静脈圧自動設定警報限界下限","elemkey":"dev-A-0103","datapattern":"1","defaultvalue":"10","level1":"war","level2":"dev","level3":"A","level4":"103"},
    {"ctlno":"5","setname":"静脈圧固定警報上限","elemkey":"dev-A-0104","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"104"},
    {"ctlno":"6","setname":"静脈圧固定警報下限","elemkey":"dev-A-0105","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"105"},
    {"ctlno":"7","setname":"静脈圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0106","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"106"},
    {"ctlno":"8","setname":"静脈圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0107","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"107"},
    {"ctlno":"9","setname":"静脈圧固定警報上限準備回収","elemkey":"dev-A-0108","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"108"},
    {"ctlno":"10","setname":"静脈圧固定警報下限準備回収","elemkey":"dev-A-0109","datapattern":"1","defaultvalue":"-200","level1":"war","level2":"dev","level3":"A","level4":"109"},
    {"ctlno":"11","setname":"静脈圧固定警報上限ＳＮ","elemkey":"dev-A-0110","datapattern":"1","defaultvalue":"400","level1":"war","level2":"dev","level3":"A","level4":"110"},
    {"ctlno":"12","setname":"静脈圧固定警報下限ＳＮ","elemkey":"dev-A-0111","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"111"},
    {"ctlno":"13","setname":"液圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0112","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"112"},
    {"ctlno":"14","setname":"液圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0113","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"113"},
    {"ctlno":"15","setname":"液圧自動設定警報限界上限","elemkey":"dev-A-0114","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"114"},
    {"ctlno":"16","setname":"液圧自動設定警報限界下限","elemkey":"dev-A-0115","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"115"},
    {"ctlno":"17","setname":"液圧固定警報上限","elemkey":"dev-A-0116","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"116"},
    {"ctlno":"18","setname":"液圧固定警報下限","elemkey":"dev-A-0117","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"117"},
    {"ctlno":"19","setname":"液圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0118","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"118"},
    {"ctlno":"20","setname":"液圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0119","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"119"},
    {"ctlno":"21","setname":"液圧自動設定警報幅上限ＳＮ","elemkey":"dev-A-0120","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"120"},
    {"ctlno":"22","setname":"液圧自動設定警報幅下限ＳＮ","elemkey":"dev-A-0121","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"121"},
    {"ctlno":"23","setname":"液圧自動設定警報限界上限ＳＮ","elemkey":"dev-A-0122","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"122"},
    {"ctlno":"24","setname":"液圧自動設定警報限界下限ＳＮ","elemkey":"dev-A-0123","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"123"},
    {"ctlno":"25","setname":"液圧固定警報上限ＳＮ","elemkey":"dev-A-0124","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"124"},
    {"ctlno":"26","setname":"液圧固定警報下限ＳＮ","elemkey":"dev-A-0125","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"125"},
    {"ctlno":"27","setname":"ＴＭＰ自動追従警報幅上限HD/ECUM","elemkey":"dev-A-0126","datapattern":"1","defaultvalue":"20","level1":"war","level2":"dev","level3":"A","level4":"126"},
    {"ctlno":"28","setname":"ＴＭＰ自動追従警報幅下限HD/ECUM","elemkey":"dev-A-0127","datapattern":"1","defaultvalue":"-20","level1":"war","level2":"dev","level3":"A","level4":"127"},
    {"ctlno":"29","setname":"ＴＭＰ自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0128","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"128"},
    {"ctlno":"30","setname":"ＴＭＰ自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0129","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"129"},
    {"ctlno":"31","setname":"ＴＭＰ自動設定警報限界上限","elemkey":"dev-A-0130","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"130"},
    {"ctlno":"32","setname":"ＴＭＰ自動設定警報限界下限","elemkey":"dev-A-0131","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"131"},
    {"ctlno":"33","setname":"ＴＭＰ固定警報上限","elemkey":"dev-A-0132","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"132"},
    {"ctlno":"34","setname":"ＴＭＰ固定警報下限","elemkey":"dev-A-0133","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"133"},
    {"ctlno":"35","setname":"ＴＭＰ自動追従警報幅上限HDF/HF","elemkey":"dev-A-0134","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"134"},
    {"ctlno":"36","setname":"ＴＭＰ自動追従警報幅下限HDF/HF","elemkey":"dev-A-0135","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"135"},
    {"ctlno":"37","setname":"ＴＭＰ自動設定警報幅上限HDF/HF","elemkey":"dev-A-0136","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"136"},
    {"ctlno":"38","setname":"ＴＭＰ自動設定警報幅下限HDF/HF","elemkey":"dev-A-0137","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"137"},
    {"ctlno":"39","setname":"ＴＭＰ自動追従警報幅上限ＳＮ","elemkey":"dev-A-0138","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"138"},
    {"ctlno":"40","setname":"ＴＭＰ自動追従警報幅下限ＳＮ","elemkey":"dev-A-0139","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"139"},
    {"ctlno":"41","setname":"ＴＭＰ自動設定警報幅上限ＳＮ","elemkey":"dev-A-0140","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"140"},
    {"ctlno":"42","setname":"ＴＭＰ自動設定警報幅下限ＳＮ","elemkey":"dev-A-0141","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"141"},
    {"ctlno":"43","setname":"ＴＭＰ自動設定警報限界上限ＳＮ","elemkey":"dev-A-0142","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"142"},
    {"ctlno":"44","setname":"ＴＭＰ自動設定警報限界下限ＳＮ","elemkey":"dev-A-0143","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"143"},
    {"ctlno":"45","setname":"ＴＭＰ固定警報上限ＳＮ","elemkey":"dev-A-0144","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"144"},
    {"ctlno":"46","setname":"ＴＭＰ固定警報下限ＳＮ","elemkey":"dev-A-0145","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"145"},
    {"ctlno":"47","setname":"ダイアライザー差圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0146","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"146"},
    {"ctlno":"48","setname":"ダイアライザー差圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0147","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"147"},
    {"ctlno":"49","setname":"ダイアライザー差圧固定警報上限","elemkey":"dev-A-0148","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"148"},
    {"ctlno":"50","setname":"ダイアライザー差圧固定警報下限","elemkey":"dev-A-0149","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"149"},
    {"ctlno":"51","setname":"ダイアライザー差圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0150","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"150"},
    {"ctlno":"52","setname":"ダイアライザー差圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0151","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"151"},
    {"ctlno":"53","setname":"ダイアライザー入口圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0152","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"152"},
    {"ctlno":"54","setname":"ダイアライザー入口圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0153","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"153"},
    {"ctlno":"55","setname":"ダイアライザー入口圧自動設定警報限界上限","elemkey":"dev-A-0154","datapattern":"1","defaultvalue":"350","level1":"war","level2":"dev","level3":"A","level4":"154"},
    {"ctlno":"56","setname":"ダイアライザー入口圧自動設定警報限界下限","elemkey":"dev-A-0155","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"155"},
    {"ctlno":"57","setname":"ダイアライザー入口圧固定警報上限","elemkey":"dev-A-0156","datapattern":"1","defaultvalue":"350","level1":"war","level2":"dev","level3":"A","level4":"156"},
    {"ctlno":"58","setname":"ダイアライザー入口圧固定警報下限","elemkey":"dev-A-0157","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"157"},
    {"ctlno":"59","setname":"ダイアライザー入口圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0158","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"158"},
    {"ctlno":"60","setname":"ダイアライザー入口圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0159","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"159"},
    {"ctlno":"61","setname":"ダイアライザー入口圧固定警報上限準備回収","elemkey":"dev-A-0160","datapattern":"1","defaultvalue":"400","level1":"war","level2":"dev","level3":"A","level4":"160"},
    {"ctlno":"62","setname":"ダイアライザー入口圧固定警報下限準備回収","elemkey":"dev-A-0161","datapattern":"1","defaultvalue":"-200","level1":"war","level2":"dev","level3":"A","level4":"161"},
    {"ctlno":"63","setname":"ダイアライザー入口圧固定警報上限ＳＮ","elemkey":"dev-A-0162","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"162"},
    {"ctlno":"64","setname":"ダイアライザー入口圧固定警報下限ＳＮ","elemkey":"dev-A-0163","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"163"},
    {"ctlno":"69","setname":"ＴＭＰゼロ補正警報上限HD","elemkey":"dev-A-0168","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"168"},
    {"ctlno":"70","setname":"ＴＭＰゼロ補正警報下限HD","elemkey":"dev-A-0169","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"169"},
    {"ctlno":"72","setname":"ＴＭＰゼロ補正警報上限ECUM","elemkey":"dev-A-0171","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"171"},
    {"ctlno":"73","setname":"ＴＭＰゼロ補正警報下限ECUM","elemkey":"dev-A-0172","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"172"},
    {"ctlno":"75","setname":"ＴＭＰゼロ補正警報上限HDF","elemkey":"dev-A-0174","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"174"},
    {"ctlno":"76","setname":"ＴＭＰゼロ補正警報下限HDF","elemkey":"dev-A-0175","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"175"},
    {"ctlno":"78","setname":"ＴＭＰゼロ補正警報上限HF","elemkey":"dev-A-0177","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"177"},
    {"ctlno":"79","setname":"ＴＭＰゼロ補正警報下限HF","elemkey":"dev-A-0178","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"178"},
    {"ctlno":"80","setname":"血流量操作範囲上限","elemkey":"dev-A-0179","datapattern":"1","defaultvalue":"300","level1":"ope","level2":"dev","level3":"A","level4":"179"},
    {"ctlno":"82","setname":"除水速度操作範囲上限","elemkey":"dev-A-0181","datapattern":"1","defaultvalue":"2","level1":"ope","level2":"dev","level3":"A","level4":"181"},
    {"ctlno":"83","setname":"透析液温度操作範囲上限","elemkey":"dev-A-0182","datapattern":"1","defaultvalue":"40","level1":"ope","level2":"dev","level3":"A","level4":"182"},
    {"ctlno":"84","setname":"透析液温度操作範囲下限","elemkey":"dev-A-0183","datapattern":"1","defaultvalue":"33","level1":"ope","level2":"dev","level3":"A","level4":"183"},
    {"ctlno":"86","setname":"前補液 補液速度操作範囲上限(HDF)","elemkey":"dev-A-0185","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"A","level4":"185"},
    {"ctlno":"87","setname":"前補液 補液速度操作範囲上限(HF)","elemkey":"dev-A-0186","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"A","level4":"186"},
    {"ctlno":"88","setname":"血圧自動測定間隔","elemkey":"dev-A-0190","datapattern":"1","defaultvalue":"30","level1":"bp","level2":"dev","level3":"A","level4":"190"},
    {"ctlno":"89","setname":"血圧ｶﾌ選択","elemkey":"dev-A-0191","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"191"},
    {"ctlno":"90","setname":"昇圧値","elemkey":"dev-A-0192","datapattern":"1","defaultvalue":"200","level1":"bp","level2":"dev","level3":"A","level4":"192"},
    {"ctlno":"91","setname":"昇圧方法選択","elemkey":"dev-A-0193","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"193"},
    {"ctlno":"92","setname":"血圧連続測定動作選択","elemkey":"dev-A-0194","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"194"},
    {"ctlno":"93","setname":"最高血圧上限","elemkey":"dev-A-0211","datapattern":"1","defaultvalue":"200","level1":"bp","level2":"dev","level3":"A","level4":"211"},
    {"ctlno":"94","setname":"最高血圧下限","elemkey":"dev-A-0212","datapattern":"1","defaultvalue":"80","level1":"bp","level2":"dev","level3":"A","level4":"212"},
    {"ctlno":"95","setname":"最低血圧上限","elemkey":"dev-A-0213","datapattern":"1","defaultvalue":"160","level1":"bp","level2":"dev","level3":"A","level4":"213"},
    {"ctlno":"96","setname":"最低血圧下限","elemkey":"dev-A-0214","datapattern":"1","defaultvalue":"50","level1":"bp","level2":"dev","level3":"A","level4":"214"},
    {"ctlno":"97","setname":"平均血圧上限","elemkey":"dev-A-0215","datapattern":"1","defaultvalue":"180","level1":"bp","level2":"dev","level3":"A","level4":"215"},
    {"ctlno":"98","setname":"平均血圧下限","elemkey":"dev-A-0216","datapattern":"1","defaultvalue":"60","level1":"bp","level2":"dev","level3":"A","level4":"216"},
    {"ctlno":"99","setname":"脈拍数上限","elemkey":"dev-A-0217","datapattern":"1","defaultvalue":"170","level1":"bp","level2":"dev","level3":"A","level4":"217"},
    {"ctlno":"100","setname":"脈拍数下限","elemkey":"dev-A-0218","datapattern":"1","defaultvalue":"50","level1":"bp","level2":"dev","level3":"A","level4":"218"},
    {"ctlno":"101","setname":"最高血圧上限警報 BP 動作選択","elemkey":"dev-A-0219","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"219"},
    {"ctlno":"102","setname":"最高血圧下限警報 BP 動作選択","elemkey":"dev-A-0220","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"220"},
    {"ctlno":"103","setname":"最高血圧上限警報 除水 動作選択","elemkey":"dev-A-0221","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"221"},
    {"ctlno":"104","setname":"最高血圧下限警報 除水 動作選択","elemkey":"dev-A-0222","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"222"},
    {"ctlno":"105","setname":"最高血圧上限警報 Na注入 動作選択","elemkey":"dev-A-0223","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"223"},
    {"ctlno":"106","setname":"最高血圧下限警報 Na注入 動作選択","elemkey":"dev-A-0224","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"224"},
    {"ctlno":"107","setname":"最高血圧上限警報 補液 動作選択","elemkey":"dev-A-0225","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"225"},
    {"ctlno":"108","setname":"最高血圧下限警報 補液 動作選択","elemkey":"dev-A-0226","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"226"},
    {"ctlno":"109","setname":"最高血圧上限警報 BP 速度","elemkey":"dev-A-0227","datapattern":"1","defaultvalue":"100","level1":"bp","level2":"dev","level3":"A","level4":"227"},
    {"ctlno":"110","setname":"最高血圧下限警報 BP 速度","elemkey":"dev-A-0228","datapattern":"1","defaultvalue":"100","level1":"bp","level2":"dev","level3":"A","level4":"228"},
    {"ctlno":"111","setname":"最高血圧上限警報 除水 速度","elemkey":"dev-A-0229","datapattern":"1","defaultvalue":"0.1","level1":"bp","level2":"dev","level3":"A","level4":"229"},
    {"ctlno":"112","setname":"最高血圧下限警報 除水 速度","elemkey":"dev-A-0230","datapattern":"1","defaultvalue":"0.1","level1":"bp","level2":"dev","level3":"A","level4":"230"},
    {"ctlno":"113","setname":"最高血圧上限警報 Na注入 速度","elemkey":"dev-A-0231","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"231"},
    {"ctlno":"114","setname":"最高血圧下限警報 Na注入 速度","elemkey":"dev-A-0232","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"232"},
    {"ctlno":"115","setname":"最高血圧上限警報 補液 速度","elemkey":"dev-A-0233","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"233"},
    {"ctlno":"116","setname":"最高血圧下限警報 補液 速度","elemkey":"dev-A-0234","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"234"},
    {"ctlno":"117","setname":"警報連動測定開始時刻","elemkey":"dev-A-0235","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"235"},
    {"ctlno":"118","setname":"治療条件連動測定時刻","elemkey":"dev-A-0236","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"236"},
    {"ctlno":"119","setname":"血圧測定自動停止(警報発生)","elemkey":"dev-A-0237","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"237"},
    {"ctlno":"120","setname":"血圧測定自動停止(条件変更)","elemkey":"dev-A-0238","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"238"},
    {"ctlno":"121","setname":"高速測定選択","elemkey":"dev-A-0239","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"239"},
    {"ctlno":"122","setname":"ＴＭＰ監視モード","elemkey":"dev-A-0240","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"240"},
    {"ctlno":"123","setname":"ＴＭＰゼロ補正の選択","elemkey":"dev-A-0241","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"241"},
    {"ctlno":"124","setname":"静脈圧自動設定警報監視有無","elemkey":"dev-A-0242","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"242"},
    {"ctlno":"125","setname":"ダイアライザー血液入口圧自動設定警報監視有無","elemkey":"dev-A-0243","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"243"},
    {"ctlno":"126","setname":"透析液圧自動設定警報監視有無","elemkey":"dev-A-0244","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"244"},
    {"ctlno":"127","setname":"ＴＭＰ自動設定警報監視有無","elemkey":"dev-A-0245","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"245"},
    {"ctlno":"128","setname":"差圧自動設定警報監視有無","elemkey":"dev-A-0246","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"246"},
    {"ctlno":"129","setname":"Ｎａ濃度自動設定警報監視有無","elemkey":"dev-A-0247","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"247"},
    {"ctlno":"130","setname":"透析液濃度プログラム自動設定警報幅上限","elemkey":"dev-A-0250","datapattern":"1","defaultvalue":"5","level1":"cpro","level2":"dev","level3":"A","level4":"250"},
    {"ctlno":"131","setname":"透析液濃度プログラム自動設定警報幅下限","elemkey":"dev-A-0251","datapattern":"1","defaultvalue":"-5","level1":"cpro","level2":"dev","level3":"A","level4":"251"},
    {"ctlno":"132","setname":"Ｂ液濃度プログラム自動設定警報幅上限","elemkey":"dev-A-0252","datapattern":"1","defaultvalue":"5","level1":"cpro","level2":"dev","level3":"A","level4":"252"},
    {"ctlno":"133","setname":"Ｂ液濃度プログラム自動設定警報幅下限","elemkey":"dev-A-0253","datapattern":"1","defaultvalue":"-5","level1":"cpro","level2":"dev","level3":"A","level4":"253"},
    {"ctlno":"134","setname":"Ｎａ濃度自動設定警報幅上限","elemkey":"dev-A-0254","datapattern":"1","defaultvalue":"5","level1":"war","level2":"dev","level3":"A","level4":"254"},
    {"ctlno":"135","setname":"Ｎａ濃度自動設定警報幅下限","elemkey":"dev-A-0255","datapattern":"1","defaultvalue":"-5","level1":"war","level2":"dev","level3":"A","level4":"255"},
    {"ctlno":"136","setname":"Ｎａ濃度固定警報上限","elemkey":"dev-A-0256","datapattern":"1","defaultvalue":"190","level1":"war","level2":"dev","level3":"A","level4":"256"},
    {"ctlno":"137","setname":"Ｎａ濃度固定警報下限","elemkey":"dev-A-0257","datapattern":"1","defaultvalue":"120","level1":"war","level2":"dev","level3":"A","level4":"257"},
    {"ctlno":"138","setname":"アクセス再循環測定使用選択","elemkey":"dev-A-0258","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"258"},
    {"ctlno":"139","setname":"自動測定1","elemkey":"dev-A-0259","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"259"},
    {"ctlno":"140","setname":"ΔＢＶ低下警報点１","elemkey":"dev-A-0260","datapattern":"1","defaultvalue":"-10","level1":"bv","level2":"dev","level3":"A","level4":"260"},
    {"ctlno":"141","setname":"ΔＢＶ低下警報点２","elemkey":"dev-A-0261","datapattern":"1","defaultvalue":"-25","level1":"bv","level2":"dev","level3":"A","level4":"261"},
    {"ctlno":"142","setname":"ΔBV変化率警報点","elemkey":"dev-A-0262","datapattern":"1","defaultvalue":"-3","level1":"bv","level2":"dev","level3":"A","level4":"262"},
    {"ctlno":"143","setname":"ブラッドボリューム計使用の選択","elemkey":"dev-A-0267","datapattern":"1","defaultvalue":"1","level1":"bv","level2":"dev","level3":"A","level4":"267"},
    {"ctlno":"144","setname":"ΔＢＶ除水低下速度","elemkey":"dev-A-0277","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"277"},
    {"ctlno":"145","setname":"ΔＢＶ除水低下遅延時間","elemkey":"dev-A-0278","datapattern":"1","defaultvalue":"5","level1":"bv","level2":"dev","level3":"A","level4":"278"},
    {"ctlno":"146","setname":"再循環率報知","elemkey":"dev-A-0281","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"281"},
    {"ctlno":"185","setname":"同時脱血 脱血量","elemkey":"dev-A-0331","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"dev","level3":"A","level4":"331"},
    {"ctlno":"186","setname":"片側脱血への切替え透析液圧","elemkey":"dev-A-0332","datapattern":"1","defaultvalue":"-200","level1":"dfas","level2":"dev","level3":"A","level4":"332"},
    {"ctlno":"187","setname":"脱血速度","elemkey":"dev-A-0333","datapattern":"1","defaultvalue":"100","level1":"dfas","level2":"dev","level3":"A","level4":"333"},
    {"ctlno":"188","setname":"片側脱血(除水なし) 脱血量","elemkey":"dev-A-0334","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"dev","level3":"A","level4":"334"},
    {"ctlno":"190","setname":"補液速度","elemkey":"dev-A-0336","datapattern":"1","defaultvalue":"100","level1":"ope","level2":"dev","level3":"A","level4":"336"},
    {"ctlno":"191","setname":"補液量","elemkey":"dev-A-0337","datapattern":"1","defaultvalue":"100","level1":"ope","level2":"dev","level3":"A","level4":"337"},
    {"ctlno":"192","setname":"片側脱血(除水あり) 脱血量","elemkey":"dev-A-0338","datapattern":"1","defaultvalue":"50","level1":"dfas","level2":"dev","level3":"A","level4":"338"},
    {"ctlno":"193","setname":"脱血方法選択","elemkey":"dev-A-0339","datapattern":"1","defaultvalue":"2","level1":"dfas","level2":"dev","level3":"A","level4":"339"},
    {"ctlno":"223","setname":"自動回収 使用液量","elemkey":"dev-A-0370","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"dev","level3":"A","level4":"370"},
    {"ctlno":"224","setname":"自動回収 流速","elemkey":"dev-A-0371","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"dev","level3":"A","level4":"371"},
    {"ctlno":"225","setname":"自動回収 血液判別器による終了選択","elemkey":"dev-A-0372","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"dev","level3":"A","level4":"372"},
    {"ctlno":"226","setname":"静脈側返血速度","elemkey":"dev-A-0373","datapattern":"1","defaultvalue":"100","level1":"dfas","level2":"dev","level3":"A","level4":"373"},
    {"ctlno":"227","setname":"静脈側最大返血量","elemkey":"dev-A-0374","datapattern":"1","defaultvalue":"250","level1":"dfas","level2":"dev","level3":"A","level4":"374"},
    {"ctlno":"228","setname":"動脈側最大返血量","elemkey":"dev-A-0376","datapattern":"1","defaultvalue":"30","level1":"dfas","level2":"dev","level3":"A","level4":"376"},
    {"ctlno":"229","setname":"静脈側返血 血液判別器使用選択","elemkey":"dev-A-0377","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"dev","level3":"A","level4":"377"},
    {"ctlno":"230","setname":"動脈側返血 血液判別器使用選択","elemkey":"dev-A-0378","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"dev","level3":"A","level4":"378"},
    {"ctlno":"234","setname":"補液量設定値制限(OHDF・OHF用)","elemkey":"dev-A-0383","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"383"},
    {"ctlno":"235","setname":"AFBF 補液比率使用選択","elemkey":"dev-A-0384","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"384"},
    {"ctlno":"236","setname":"AFBF 補液比率","elemkey":"dev-A-0385","datapattern":"1","defaultvalue":"13","level1":"ope","level2":"dev","level3":"A","level4":"385"},
    {"ctlno":"237","setname":"補液速度設定範囲上限(AFBF)","elemkey":"dev-A-0386","datapattern":"1","defaultvalue":"2.5","level1":"ope","level2":"dev","level3":"A","level4":"386"},
    {"ctlno":"238","setname":"補液速度設定範囲下限(AFBF)","elemkey":"dev-A-0387","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"387"},
    {"ctlno":"240","setname":"OHDF/OHF補液計算優先項目選択","elemkey":"dev-A-0389","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"389"},
    {"ctlno":"242","setname":"ＴＭＰゼロ補正警報上限OHDF","elemkey":"dev-A-0391","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"391"},
    {"ctlno":"243","setname":"ＴＭＰゼロ補正警報下限OHDF","elemkey":"dev-A-0392","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"392"},
    {"ctlno":"245","setname":"ＴＭＰゼロ補正警報上限OHF","elemkey":"dev-A-0394","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"394"},
    {"ctlno":"246","setname":"ＴＭＰゼロ補正警報下限OHF","elemkey":"dev-A-0395","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"395"},
    {"ctlno":"247","setname":"前補液 補液速度操作範囲上限(OHDF)","elemkey":"dev-A-0396","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"A","level4":"396"},
    {"ctlno":"248","setname":"前補液 補液速度操作範囲上限(OHF)","elemkey":"dev-A-0397","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"A","level4":"397"},
    {"ctlno":"249","setname":"補液開始遅延時間","elemkey":"dev-A-0398","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"398"},
    {"ctlno":"280","setname":"前補液 補液速度操作範囲上限(HD+補液)","elemkey":"dev-B-0030","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"B","level4":"030"},
    {"ctlno":"281","setname":"後補液 補液速度操作範囲上限(HDF)","elemkey":"dev-B-0031","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"031"},
    {"ctlno":"282","setname":"後補液 補液速度操作範囲上限(HF)","elemkey":"dev-B-0032","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"032"},
    {"ctlno":"283","setname":"後補液 補液速度操作範囲上限(HD+補液)","elemkey":"dev-B-0033","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"033"},
    {"ctlno":"284","setname":"後補液 補液速度操作範囲上限(OHDF)","elemkey":"dev-B-0034","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"034"},
    {"ctlno":"285","setname":"後補液 補液速度操作範囲上限(OHF)","elemkey":"dev-B-0035","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"035"},
    {"ctlno":"286","setname":"治療開始時血流量使用有無","elemkey":"dev-B-0036","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"dev","level3":"B","level4":"036"},
    {"ctlno":"287","setname":"ＴＭＰゼロ補正警報上限(HD+補液)","elemkey":"dev-B-0037","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"B","level4":"037"},
    {"ctlno":"288","setname":"ＴＭＰゼロ補正警報下限(HD+補液)","elemkey":"dev-B-0038","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"B","level4":"038"},
    {"ctlno":"289","setname":"プライミング補助動脈充填液量","elemkey":"pat-A-0219","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"pat","level3":"A","level4":"219"},
    {"ctlno":"290","setname":"プライミング補助動脈充填流速","elemkey":"pat-A-0220","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"pat","level3":"A","level4":"220"},
    {"ctlno":"291","setname":"プライミング補助静脈充填液量","elemkey":"pat-A-0221","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"pat","level3":"A","level4":"221"},
    {"ctlno":"292","setname":"プライミング補助静脈充填流速","elemkey":"pat-A-0222","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"pat","level3":"A","level4":"222"},
    {"ctlno":"293","setname":"プライミング補助気泡抜き液量","elemkey":"pat-A-0223","datapattern":"1","defaultvalue":"400","level1":"pri","level2":"pat","level3":"A","level4":"223"},
    {"ctlno":"294","setname":"プライミング補助気泡抜き流速","elemkey":"pat-A-0224","datapattern":"1","defaultvalue":"300","level1":"pri","level2":"pat","level3":"A","level4":"224"},
    {"ctlno":"295","setname":"プライミング補助動脈充填後継続の有無","elemkey":"pat-A-0225","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"225"},
    {"ctlno":"296","setname":"プライミング補助静脈充填後継続の有無","elemkey":"pat-A-0226","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"226"},
    {"ctlno":"297","setname":"プライミング補助気泡抜き間欠動作選択","elemkey":"pat-A-0227","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"227"},
    {"ctlno":"298","setname":"プライミング補助液交換量","elemkey":"pat-A-0228","datapattern":"1","defaultvalue":"800","level1":"pri","level2":"pat","level3":"A","level4":"228"},
    {"ctlno":"299","setname":"プライミング補助間欠動作動作時間","elemkey":"pat-A-0229","datapattern":"1","defaultvalue":"2","level1":"pri","level2":"pat","level3":"A","level4":"229"},
    {"ctlno":"300","setname":"プライミング補助間欠動作停止時間","elemkey":"pat-A-0230","datapattern":"1","defaultvalue":"1","level1":"pri","level2":"pat","level3":"A","level4":"230"},
    {"ctlno":"301","setname":"自動プライミング開始時間","elemkey":"pat-A-0231","datapattern":"1","defaultvalue":"420","level1":"pri","level2":"pat","level3":"A","level4":"231"},
    {"ctlno":"302","setname":"自動プライミング落差時間","elemkey":"pat-A-0232","datapattern":"1","defaultvalue":"40","level1":"pri","level2":"pat","level3":"A","level4":"232"},
    {"ctlno":"303","setname":"自動プライミング送液液量","elemkey":"pat-A-0233","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"233"},
    {"ctlno":"304","setname":"自動プライミング送液流速1回目","elemkey":"pat-A-0234","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"234"},
    {"ctlno":"305","setname":"自動プライミング送液流速2回目以降","elemkey":"pat-A-0235","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"235"},
    {"ctlno":"306","setname":"自動プライミング循環流速","elemkey":"pat-A-0236","datapattern":"1","defaultvalue":"400","level1":"pri","level2":"pat","level3":"A","level4":"236"},
    {"ctlno":"307","setname":"自動プライミング循環時間","elemkey":"pat-A-0237","datapattern":"1","defaultvalue":"300","level1":"pri","level2":"pat","level3":"A","level4":"237"},
    {"ctlno":"308","setname":"自動プライミング総量","elemkey":"pat-A-0238","datapattern":"1","defaultvalue":"600","level1":"pri","level2":"pat","level3":"A","level4":"238"},
    {"ctlno":"310","setname":"IPラインプライミング使用選択","elemkey":"pat-B-0001","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"pat","level3":"B","level4":"001"},
    {"ctlno":"311","setname":"中空糸 プライミング時のBP速度","elemkey":"pat-B-0005","datapattern":"1","defaultvalue":"300","level1":"dfas","level2":"pat","level3":"B","level4":"005"},
    {"ctlno":"312","setname":"中空糸 送液最大時間","elemkey":"pat-B-0007","datapattern":"1","defaultvalue":"60","level1":"dfas","level2":"pat","level3":"B","level4":"007"},
    {"ctlno":"313","setname":"中空糸 回路内洗浄送液量","elemkey":"pat-B-0008","datapattern":"1","defaultvalue":"200","level1":"dfas","level2":"pat","level3":"B","level4":"008"},
    {"ctlno":"314","setname":"中空糸 気泡抜き動作実行回数","elemkey":"pat-B-0009","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"pat","level3":"B","level4":"009"},
    {"ctlno":"315","setname":"中空糸 気泡抜き圧力上限","elemkey":"pat-B-0010","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"010"},
    {"ctlno":"317","setname":"補液選択","elemkey":"dev-B-0030","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"B","level4":"030"},
    {"ctlno":"318","setname":"前補液 ダイアライザー気泡抜き時間","elemkey":"dev-B-0031","datapattern":"1","defaultvalue":"2","level1":"ope","level2":"dev","level3":"B","level4":"031"},
    {"ctlno":"319","setname":"前補液 動脈チャンバ液面作成時間","elemkey":"pat-B-0032","datapattern":"1","defaultvalue":"90","level1":"pri","level2":"pat","level3":"B","level4":"032"},
    {"ctlno":"320","setname":"前補液 循環洗浄時間","elemkey":"pat-B-0033","datapattern":"1","defaultvalue":"3","level1":"pri","level2":"pat","level3":"B","level4":"033"},
    {"ctlno":"321","setname":"治療モード","elemkey":"dev-B-0034","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"B","level4":"034"},
    {"ctlno":"322","setname":"後補液 ダイアライザー気泡抜き時間","elemkey":"pat-B-0051","datapattern":"1","defaultvalue":"2","level1":"pri","level2":"pat","level3":"B","level4":"051"},
    {"ctlno":"323","setname":"後補液 動脈チャンバ液面作成時間","elemkey":"pat-B-0052","datapattern":"1","defaultvalue":"60","level1":"pri","level2":"pat","level3":"B","level4":"052"},
    {"ctlno":"324","setname":"後補液 循環洗浄時間","elemkey":"pat-B-0053","datapattern":"1","defaultvalue":"3","level1":"pri","level2":"pat","level3":"B","level4":"053"},
    {"ctlno":"325","setname":"積層 送液最大時間","elemkey":"pat-B-0054","datapattern":"1","defaultvalue":"60","level1":"dfas","level2":"pat","level3":"B","level4":"054"},
    {"ctlno":"326","setname":"積層 回路内洗浄送液量","elemkey":"pat-B-0055","datapattern":"1","defaultvalue":"200","level1":"dfas","level2":"pat","level3":"B","level4":"055"},
    {"ctlno":"327","setname":"積層 気泡抜き動作実行回数","elemkey":"pat-B-0056","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"pat","level3":"B","level4":"056"},
    {"ctlno":"328","setname":"積層 気泡抜き圧力上限","elemkey":"pat-B-0057","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"057"},
    {"ctlno":"329","setname":"積層 除水ポンプ速度","elemkey":"pat-B-0058","datapattern":"1","defaultvalue":"0.2","level1":"dfas","level2":"pat","level3":"B","level4":"058"},
    {"ctlno":"330","setname":"積層 プライミング時のBP速度","elemkey":"pat-B-0059","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"059"},
    {"ctlno":"331","setname":"DP=Qd+Qs(補液速度加算)","elemkey":"dev-A-0369","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"369"},
    {"ctlno":"332","setname":"前補液　OHDF/OHF　補液速度比率","elemkey":"dev-A-0379","datapattern":"1","defaultvalue":"20","level1":"ope","level2":"dev","level3":"A","level4":"379"},
    {"ctlno":"333","setname":"後補液　OHDF/OHF　補液速度比率","elemkey":"dev-B-0039","datapattern":"1","defaultvalue":"20","level1":"ope","level2":"dev","level3":"B","level4":"039"},
    {"ctlno":"334","setname":"自動測定2","elemkey":"dev-A-0263","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"263"},
    {"ctlno":"335","setname":"自動測定3","elemkey":"dev-A-0264","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"264"},
    {"ctlno":"336","setname":"自動測定4","elemkey":"dev-A-0265","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"265"},
    {"ctlno":"337","setname":"自動測定5","elemkey":"dev-A-0266","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"266"},
    {"ctlno":"338","setname":"除水開始遅延時間","elemkey":"dev-A-0039","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"039"},
    {"ctlno":"339","setname":"動脈側返血使用選択","elemkey":"dev-A-0270","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"dev","level3":"A","level4":"270"},
    {"ctlno":"346","setname":"濾過率（前補液）","elemkey":"dev-A-0090","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"090"},
    {"ctlno":"347","setname":"ヘマトクリット（Ht）","elemkey":"dev-A-0091","datapattern":"1","defaultvalue":"33","level1":"ope","level2":"dev","level3":"A","level4":"091"},
    {"ctlno":"348","setname":"総タンパク（TP）","elemkey":"dev-A-0092","datapattern":"1","defaultvalue":"6.5","level1":"ope","level2":"dev","level3":"A","level4":"092"},
    {"ctlno":"349","setname":"血圧測定方法選択","elemkey":"dev-A-0195","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"195"},
    {"ctlno":"350","setname":"濾過率（後補液）","elemkey":"dev-B-0040","datapattern":"1","defaultvalue":"40","level1":"ope","level2":"dev","level3":"B","level4":"040"},
    {"ctlno":"362","setname":"透析液流量　設定方法","elemkey":"dev-A-0268","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"268"},
    {"ctlno":"363","setname":"透析液流量　比率設定","elemkey":"dev-A-0269","datapattern":"1","defaultvalue":"2.0","level1":"ope","level2":"dev","level3":"A","level4":"269"},
    {"ctlno":"436","setname":"VA確認報知基準値(静的静脈圧)","elemkey":"dev-A-0468","datapattern":"1","defaultvalue":"80","level1":"iap","level2":"dev","level3":"A","level4":"468"},
    {"ctlno":"437","setname":"VA確認報知基準値(IAP ratio)","elemkey":"dev-A-0469","datapattern":"1","defaultvalue":"0.5","level1":"iap","level2":"dev","level3":"A","level4":"469"},
    {"ctlno":"438","setname":"静的静脈圧記録 自動実施選択","elemkey":"dev-A-0470","datapattern":"1","defaultvalue":"1","level1":"iap","level2":"dev","level3":"A","level4":"470"},
    {"ctlno":"439","setname":"血圧測定 自動実施選択","elemkey":"dev-A-0471","datapattern":"1","defaultvalue":"0","level1":"iap","level2":"dev","level3":"A","level4":"471"},
    {"ctlno":"440","setname":"TMP閾値 速度低下","elemkey":"dev-A-0472","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"472"},
    {"ctlno":"441","setname":"TMP閾値 速度復帰","elemkey":"dev-A-0473","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"473"},
    {"ctlno":"442","setname":"速度変化率 速度低下","elemkey":"dev-A-0474","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"474"},
    {"ctlno":"443","setname":"速度変化率 速度復帰","elemkey":"dev-A-0475","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"475"},
    {"ctlno":"444","setname":"ΔSO2低下報知点","elemkey":"dev-A-0476","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"476"},
    {"ctlno":"445","setname":"条件送信時血流量","elemkey":"dev-A-0477","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"A","level4":"477"},
    {"ctlno":"65","setname":"初期ＵＦＲ警報上限","elemkey":"ufr_warning_max","datapattern":"4","defaultvalue":"200","level1":"ufr_warning_max","level2":"","level3":"","level4":"ufr_warning_max"},
    {"ctlno":"66","setname":"初期ＵＦＲ警報下限","elemkey":"ufr_warning_min","datapattern":"4","defaultvalue":"1","level1":"ufr_warning_min","level2":"","level3":"","level4":"ufr_warning_min"},
    {"ctlno":"67","setname":"ＵＦＲ低下警報点","elemkey":"ufr_warning_reduction","datapattern":"4","defaultvalue":"50","level1":"ufr_warning_reduction","level2":"","level3":"","level4":"ufr_warning_reduction"},
    {"ctlno":"68","setname":"ＴＭＰゼロ補正警報中点HD","elemkey":"tmp_center_hd","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_hd","level2":"","level3":"","level4":"tmp_center_hd"},
    {"ctlno":"71","setname":"ＴＭＰゼロ補正警報中点ECUM","elemkey":"tmp_center_ecum","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_ecum","level2":"","level3":"","level4":"tmp_center_ecum"},
    {"ctlno":"74","setname":"ＴＭＰゼロ補正警報中点HDF","elemkey":"tmp_center_hdf","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_hdf","level2":"","level3":"","level4":"tmp_center_hdf"},
    {"ctlno":"77","setname":"ＴＭＰゼロ補正警報中点HF","elemkey":"tmp_center_hf","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_hf","level2":"","level3":"","level4":"tmp_center_hf"},
    {"ctlno":"81","setname":"ＩＰ速度操作範囲上限","elemkey":"ind_cond_info-33-value","datapattern":"3","defaultvalue":"10","level1":"33","level2":"ind_cond_info","level3":"33","level4":"value"},
    {"ctlno":"85","setname":"Ｎａ注入濃度操作範囲上限","elemkey":"dev-A-0184","datapattern":"2","defaultvalue":"50","level1":"na","level2":"dev","level3":"A","level4":"184"},
    {"ctlno":"147","setname":"透析量プログラム使用選択","elemkey":"dev-A-0282","datapattern":"2","defaultvalue":"0","level1":"dia","level2":"dev","level3":"A","level4":"282"},
    {"ctlno":"148","setname":"体液量計算時後体重","elemkey":"calc_body_fluids_date","datapattern":"6","defaultvalue":null,"level1":"","level2":"","level3":"","level4":"calc_body_fluids_date"},
    {"ctlno":"149","setname":"体液量+補正値","elemkey":"calc_body_fluids","datapattern":"6","defaultvalue":null,"level1":"","level2":"","level3":"","level4":"calc_body_fluids"},
    {"ctlno":"150","setname":"目標後体重","elemkey":"ind_cond_info-3-value","datapattern":"3","defaultvalue":null,"level1":"3","level2":"ind_cond_info","level3":"3","level4":"value"},
    {"ctlno":"151","setname":"標準血流量","elemkey":"ind_cond_info-14-value","datapattern":"3","defaultvalue":null,"level1":"14","level2":"ind_cond_info","level3":"14","level4":"value"},
    {"ctlno":"152","setname":"KoA","elemkey":"koa","datapattern":"4","defaultvalue":null,"level1":"koa","level2":"","level3":"","level4":"koa"},
    {"ctlno":"153","setname":"目標Kt/V","elemkey":"dev-A-0288","datapattern":"2","defaultvalue":null,"level1":"dia","level2":"dev","level3":"A","level4":"288"},
    {"ctlno":"154","setname":"ＵＦＲプログラム電源ＳＷ","elemkey":"dev-A-0290","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"290"},
    {"ctlno":"155","setname":"ＵＦＲプログラム指数１","elemkey":"dev-A-0301","datapattern":"2","defaultvalue":"200","level1":"ufr","level2":"dev","level3":"A","level4":"301"},
    {"ctlno":"156","setname":"ＵＦＲプログラム指数２","elemkey":"dev-A-0302","datapattern":"2","defaultvalue":"150","level1":"ufr","level2":"dev","level3":"A","level4":"302"},
    {"ctlno":"157","setname":"ＵＦＲプログラム指数３","elemkey":"dev-A-0303","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"303"},
    {"ctlno":"158","setname":"ＵＦＲプログラム指数４","elemkey":"dev-A-0304","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"A","level4":"304"},
    {"ctlno":"159","setname":"ＵＦＲプログラム指数５","elemkey":"dev-A-0305","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"305"},
    {"ctlno":"160","setname":"ＵＦＲプログラム指数６","elemkey":"dev-A-0306","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"306"},
    {"ctlno":"161","setname":"ＵＦＲプログラム指数７","elemkey":"dev-A-0307","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"A","level4":"307"},
    {"ctlno":"162","setname":"ＵＦＲプログラム指数８","elemkey":"dev-A-0308","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"308"},
    {"ctlno":"163","setname":"ＵＦＲプログラム指数９","elemkey":"dev-A-0309","datapattern":"2","defaultvalue":"150","level1":"ufr","level2":"dev","level3":"A","level4":"309"},
    {"ctlno":"164","setname":"ＵＦＲプログラム指数１０","elemkey":"dev-A-0310","datapattern":"2","defaultvalue":"200","level1":"ufr","level2":"dev","level3":"A","level4":"310"},
    {"ctlno":"165","setname":"ＵＦＲプログラム最終位置","elemkey":"dev-A-0311","datapattern":"2","defaultvalue":"10","level1":"ufr","level2":"dev","level3":"A","level4":"311"},
    {"ctlno":"166","setname":"ＵＦＲプログラムコース","elemkey":"dev-A-0312","datapattern":"2","defaultvalue":"1","level1":"ufr","level2":"dev","level3":"A","level4":"312"},
    {"ctlno":"167","setname":"ＵＦＲプログラム開始数値","elemkey":"dev-A-0313","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"313"},
    {"ctlno":"168","setname":"ＵＦＲプログラム終了数値","elemkey":"dev-A-0314","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"314"},
    {"ctlno":"169","setname":"Ｎａ注入プログラム電源ＳＷ","elemkey":"dev-A-0315","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"315"},
    {"ctlno":"170","setname":"Ｎａ注入プログラム設定１","elemkey":"dev-A-0316","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"316"},
    {"ctlno":"171","setname":"Ｎａ注入プログラム設定２","elemkey":"dev-A-0317","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"317"},
    {"ctlno":"172","setname":"Ｎａ注入プログラム設定３","elemkey":"dev-A-0318","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"318"},
    {"ctlno":"173","setname":"Ｎａ注入プログラム設定４","elemkey":"dev-A-0319","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"319"},
    {"ctlno":"174","setname":"Ｎａ注入プログラム設定５","elemkey":"dev-A-0320","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"320"},
    {"ctlno":"175","setname":"Ｎａ注入プログラム設定６","elemkey":"dev-A-0321","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"321"},
    {"ctlno":"176","setname":"Ｎａ注入プログラム設定７","elemkey":"dev-A-0322","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"322"},
    {"ctlno":"177","setname":"Ｎａ注入プログラム設定８","elemkey":"dev-A-0323","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"323"},
    {"ctlno":"178","setname":"Ｎａ注入プログラム設定９","elemkey":"dev-A-0324","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"324"},
    {"ctlno":"179","setname":"Ｎａ注入プログラム設定１０","elemkey":"dev-A-0325","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"325"},
    {"ctlno":"180","setname":"Ｎａ注入プログラム切替時間","elemkey":"dev-A-0326","datapattern":"2","defaultvalue":"30","level1":"na","level2":"dev","level3":"A","level4":"326"},
    {"ctlno":"181","setname":"Ｎａ注入プログラム ＵＦＲプロとの連動選択","elemkey":"dev-A-0327","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"327"},
    {"ctlno":"182","setname":"Ｎａ注入プログラムコース","elemkey":"dev-A-0328","datapattern":"2","defaultvalue":"1","level1":"na","level2":"dev","level3":"A","level4":"328"},
    {"ctlno":"183","setname":"Ｎａ注入プログラム開始数値","elemkey":"dev-A-0329","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"329"},
    {"ctlno":"184","setname":"Ｎａ注入プログラム終了数値","elemkey":"dev-A-0330","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"330"},
    {"ctlno":"189","setname":"治療開始時 血液ポンプ速度","elemkey":"ind_cond_info-14-value","datapattern":"3","defaultvalue":null,"level1":"14","level2":"ind_cond_info","level3":"14","level4":"value"},
    {"ctlno":"194","setname":"濃度プログラム電源ＳＷ","elemkey":"dev-A-0340","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"A","level4":"340"},
    {"ctlno":"195","setname":"透析液濃度プログラム設定１","elemkey":"dev-A-0341","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"341"},
    {"ctlno":"196","setname":"透析液濃度プログラム設定２","elemkey":"dev-A-0342","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"342"},
    {"ctlno":"197","setname":"透析液濃度プログラム設定３","elemkey":"dev-A-0343","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"343"},
    {"ctlno":"198","setname":"透析液濃度プログラム設定４","elemkey":"dev-A-0344","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"344"},
    {"ctlno":"199","setname":"透析液濃度プログラム設定５","elemkey":"dev-A-0345","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"345"},
    {"ctlno":"200","setname":"透析液濃度プログラム設定６","elemkey":"dev-A-0346","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"346"},
    {"ctlno":"201","setname":"透析液濃度プログラム設定７","elemkey":"dev-A-0347","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"347"},
    {"ctlno":"202","setname":"透析液濃度プログラム設定８","elemkey":"dev-A-0348","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"348"},
    {"ctlno":"203","setname":"透析液濃度プログラム設定９","elemkey":"dev-A-0349","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"349"},
    {"ctlno":"204","setname":"透析液濃度プログラム設定１０","elemkey":"dev-A-0350","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"350"},
    {"ctlno":"205","setname":"Ｂ液濃度プログラム設定１","elemkey":"dev-A-0351","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"351"},
    {"ctlno":"206","setname":"Ｂ液濃度プログラム設定２","elemkey":"dev-A-0352","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"352"},
    {"ctlno":"207","setname":"Ｂ液濃度プログラム設定３","elemkey":"dev-A-0353","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"353"},
    {"ctlno":"208","setname":"Ｂ液濃度プログラム設定４","elemkey":"dev-A-0354","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"354"},
    {"ctlno":"209","setname":"Ｂ液濃度プログラム設定５","elemkey":"dev-A-0355","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"355"},
    {"ctlno":"210","setname":"Ｂ液濃度プログラム設定６","elemkey":"dev-A-0356","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"356"},
    {"ctlno":"211","setname":"Ｂ液濃度プログラム設定７","elemkey":"dev-A-0357","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"357"},
    {"ctlno":"212","setname":"Ｂ液濃度プログラム設定８","elemkey":"dev-A-0358","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"358"},
    {"ctlno":"213","setname":"Ｂ液濃度プログラム設定９","elemkey":"dev-A-0359","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"359"},
    {"ctlno":"214","setname":"Ｂ液濃度プログラム設定１０","elemkey":"dev-A-0360","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"360"},
    {"ctlno":"215","setname":"透析液濃度プログラムステップ切替無し コース","elemkey":"dev-A-0361","datapattern":"2","defaultvalue":"2","level1":"dc","level2":"dev","level3":"A","level4":"361"},
    {"ctlno":"216","setname":"透析液濃度プログラム開始数値","elemkey":"dev-A-0362","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"362"},
    {"ctlno":"217","setname":"透析液濃度プログラム終了数値","elemkey":"dev-A-0363","datapattern":"2","defaultvalue":"15","level1":"dc","level2":"dev","level3":"A","level4":"363"},
    {"ctlno":"218","setname":"Ｂ液濃度プログラムステップ切替無し コース","elemkey":"dev-A-0364","datapattern":"2","defaultvalue":"2","level1":"dc","level2":"dev","level3":"A","level4":"364"},
    {"ctlno":"219","setname":"Ｂ液濃度プログラム開始数値","elemkey":"dev-A-0365","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"365"},
    {"ctlno":"220","setname":"Ｂ液濃度プログラム終了数値","elemkey":"dev-A-0366","datapattern":"2","defaultvalue":"3","level1":"dc","level2":"dev","level3":"A","level4":"366"},
    {"ctlno":"221","setname":"濃度プログラム切替時間","elemkey":"dev-A-0367","datapattern":"2","defaultvalue":"30","level1":"dc","level2":"dev","level3":"A","level4":"367"},
    {"ctlno":"222","setname":"濃度プログラム ＵＦＲプロとの連動選択","elemkey":"dev-A-0368","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"A","level4":"368"},
    {"ctlno":"231","setname":"補液速度","elemkey":"ind_cond_info-24-value","datapattern":"3","defaultvalue":null,"level1":"24","level2":"ind_cond_info","level3":"24","level4":"value"},
    {"ctlno":"232","setname":"補液温度設定値","elemkey":"ind_cond_info-23-value","datapattern":"3","defaultvalue":null,"level1":"23","level2":"ind_cond_info","level3":"23","level4":"value"},
    {"ctlno":"233","setname":"補液量設定値","elemkey":"ind_cond_info-20-value","datapattern":"3","defaultvalue":null,"level1":"20","level2":"ind_cond_info","level3":"20","level4":"value"},
    {"ctlno":"239","setname":"補液選択(前・後)","elemkey":"ind_cond_info-21-value","datapattern":"3","defaultvalue":"0","level1":"21","level2":"ind_cond_info","level3":"21","level4":"value"},
    {"ctlno":"241","setname":"ＴＭＰゼロ補正警報中点OHDF","elemkey":"tmp_center_ohdf","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_ohdf","level2":"","level3":"","level4":"tmp_center_ohdf"},
    {"ctlno":"244","setname":"ＴＭＰゼロ補正警報中点OHF","elemkey":"tmp_center_ohf","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_ohf","level2":"","level3":"","level4":"tmp_center_ohf"},
    {"ctlno":"250","setname":"UFRプログラム工程1の指数","elemkey":"dev-B-0000","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"B","level4":"000"},
    {"ctlno":"251","setname":"UFRプログラム工程2の指数","elemkey":"dev-B-0001","datapattern":"2","defaultvalue":"38","level1":"ufr","level2":"dev","level3":"B","level4":"001"},
    {"ctlno":"252","setname":"UFRプログラム工程3の指数","elemkey":"dev-B-0002","datapattern":"2","defaultvalue":"25","level1":"ufr","level2":"dev","level3":"B","level4":"002"},
    {"ctlno":"253","setname":"UFRプログラム工程4の指数","elemkey":"dev-B-0003","datapattern":"2","defaultvalue":"13","level1":"ufr","level2":"dev","level3":"B","level4":"003"},
    {"ctlno":"254","setname":"UFRプログラム工程5の指数","elemkey":"dev-B-0004","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"B","level4":"004"},
    {"ctlno":"255","setname":"UFRプログラム工程6の指数","elemkey":"dev-B-0005","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"B","level4":"005"},
    {"ctlno":"256","setname":"UFRプログラム工程7の指数","elemkey":"dev-B-0006","datapattern":"2","defaultvalue":"13","level1":"ufr","level2":"dev","level3":"B","level4":"006"},
    {"ctlno":"257","setname":"UFRプログラム工程8の指数","elemkey":"dev-B-0007","datapattern":"2","defaultvalue":"25","level1":"ufr","level2":"dev","level3":"B","level4":"007"},
    {"ctlno":"258","setname":"UFRプログラム工程9の指数","elemkey":"dev-B-0008","datapattern":"2","defaultvalue":"38","level1":"ufr","level2":"dev","level3":"B","level4":"008"},
    {"ctlno":"259","setname":"UFRプログラム工程10の指数","elemkey":"dev-B-0009","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"B","level4":"009"},
    {"ctlno":"260","setname":"B液濃度プログラム工程1のB液濃度","elemkey":"dev-B-0010","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"010"},
    {"ctlno":"261","setname":"B液濃度プログラム工程2のB液濃度","elemkey":"dev-B-0011","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"011"},
    {"ctlno":"262","setname":"B液濃度プログラム工程3のB液濃度","elemkey":"dev-B-0012","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"012"},
    {"ctlno":"263","setname":"B液濃度プログラム工程4のB液濃度","elemkey":"dev-B-0013","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"013"},
    {"ctlno":"264","setname":"B液濃度プログラム工程5のB液濃度","elemkey":"dev-B-0014","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"014"},
    {"ctlno":"265","setname":"B液濃度プログラム工程6のB液濃度","elemkey":"dev-B-0015","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"015"},
    {"ctlno":"266","setname":"B液濃度プログラム工程7のB液濃度","elemkey":"dev-B-0016","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"016"},
    {"ctlno":"267","setname":"B液濃度プログラム工程8のB液濃度","elemkey":"dev-B-0017","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"017"},
    {"ctlno":"268","setname":"B液濃度プログラム工程9のB液濃度","elemkey":"dev-B-0018","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"018"},
    {"ctlno":"269","setname":"B液濃度プログラム工程10のB液濃度","elemkey":"dev-B-0019","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"019"},
    {"ctlno":"270","setname":"A液濃度プログラム工程1のA液濃度","elemkey":"dev-B-0020","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"020"},
    {"ctlno":"271","setname":"A液濃度プログラム工程2のA液濃度","elemkey":"dev-B-0021","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"021"},
    {"ctlno":"272","setname":"A液濃度プログラム工程3のA液濃度","elemkey":"dev-B-0022","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"022"},
    {"ctlno":"273","setname":"A液濃度プログラム工程4のA液濃度","elemkey":"dev-B-0023","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"023"},
    {"ctlno":"274","setname":"A液濃度プログラム工程5のA液濃度","elemkey":"dev-B-0024","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"024"},
    {"ctlno":"275","setname":"A液濃度プログラム工程6のA液濃度","elemkey":"dev-B-0025","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"025"},
    {"ctlno":"276","setname":"A液濃度プログラム工程7のA液濃度","elemkey":"dev-B-0026","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"026"},
    {"ctlno":"277","setname":"A液濃度プログラム工程8のA液濃度","elemkey":"dev-B-0027","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"027"},
    {"ctlno":"278","setname":"A液濃度プログラム工程9のA液濃度","elemkey":"dev-B-0028","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"028"},
    {"ctlno":"279","setname":"A液濃度プログラム工程10のA液濃度","elemkey":"dev-B-0029","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"029"},
    {"ctlno":"309","setname":"ダイアライザ選択","elemkey":"dialyzer_type","datapattern":"4","defaultvalue":"1","level1":"dialyzer_type","level2":"","level3":"","level4":"dialyzer_type"},
    {"ctlno":"316","setname":"中空糸 除水ポンプ速度","elemkey":"0000","datapattern":"7","defaultvalue":"0.2","level1":"","level2":"","level3":"","level4":""},
    {"ctlno":"340","setname":"I-HDF　補液量設定","elemkey":"dev-A-0200","datapattern":"2","defaultvalue":"200","level1":"ihdf","level2":"dev","level3":"A","level4":"200"},
    {"ctlno":"341","setname":"I-HDF　補液速度","elemkey":"dev-A-0201","datapattern":"2","defaultvalue":"100","level1":"ihdf","level2":"dev","level3":"A","level4":"201"},
    {"ctlno":"342","setname":"I-HDF　補液周期","elemkey":"dev-A-0202","datapattern":"2","defaultvalue":"30","level1":"ihdf","level2":"dev","level3":"A","level4":"202"},
    {"ctlno":"343","setname":"I-HDF　補液開始時間","elemkey":"dev-A-0203","datapattern":"2","defaultvalue":"30","level1":"ihdf","level2":"dev","level3":"A","level4":"203"},
    {"ctlno":"344","setname":"I-HDF　除水再開時間","elemkey":"dev-A-0204","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"204"},
    {"ctlno":"345","setname":"I-HDF　総補液量上限","elemkey":"dev-A-0205","datapattern":"2","defaultvalue":"1.5","level1":"ihdf","level2":"dev","level3":"A","level4":"205"},
    {"ctlno":"351","setname":"BV-UFC使用選択","elemkey":"dev-A-0196","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"196"},
    {"ctlno":"352","setname":"UFC期間除水速度上限","elemkey":"dev-A-0197","datapattern":"2","defaultvalue":"2.00","level1":"bvufc","level2":"dev","level3":"A","level4":"197"},
    {"ctlno":"353","setname":"UFC期間除水速度下限","elemkey":"dev-A-0198","datapattern":"2","defaultvalue":"0.00","level1":"bvufc","level2":"dev","level3":"A","level4":"198"},
    {"ctlno":"354","setname":"開始期間 時間","elemkey":"dev-A-0199","datapattern":"2","defaultvalue":"10","level1":"bvufc","level2":"dev","level3":"A","level4":"199"},
    {"ctlno":"355","setname":"開始期間 除水速度倍率","elemkey":"dev-A-0206","datapattern":"2","defaultvalue":"1.00","level1":"bvufc","level2":"dev","level3":"A","level4":"206"},
    {"ctlno":"356","setname":"固定倍率除水期間 時間","elemkey":"dev-A-0207","datapattern":"2","defaultvalue":"60","level1":"bvufc","level2":"dev","level3":"A","level4":"207"},
    {"ctlno":"357","setname":"固定倍率除水期間 除水速度倍率","elemkey":"dev-A-0208","datapattern":"2","defaultvalue":"1.30","level1":"bvufc","level2":"dev","level3":"A","level4":"208"},
    {"ctlno":"358","setname":"固定倍率除水終了条件　最高血圧","elemkey":"dev-A-0209","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"209"},
    {"ctlno":"359","setname":"固定倍率除水終了条件　脈拍","elemkey":"dev-A-0210","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"210"},
    {"ctlno":"360","setname":"固定倍率除水終了条件　ΔBV","elemkey":"dev-A-0248","datapattern":"2","defaultvalue":"0.0","level1":"bvufc","level2":"dev","level3":"A","level4":"248"},
    {"ctlno":"361","setname":"終了前期間 時間","elemkey":"dev-A-0249","datapattern":"2","defaultvalue":"20","level1":"bvufc","level2":"dev","level3":"A","level4":"249"},
    {"ctlno":"364","setname":"開始時ΔBV基準値 ","elemkey":"dev-A-0271","datapattern":"2","defaultvalue":"0.0","level1":"bvufc","level2":"dev","level3":"A","level4":"271"},
    {"ctlno":"365","setname":"ΔBV基準線　指数1","elemkey":"dev-A-0272","datapattern":"2","defaultvalue":"50","level1":"bvufc","level2":"dev","level3":"A","level4":"272"},
    {"ctlno":"366","setname":"ΔBV基準線　指数2","elemkey":"dev-A-0273","datapattern":"2","defaultvalue":"80","level1":"bvufc","level2":"dev","level3":"A","level4":"273"},
    {"ctlno":"367","setname":"ΔBV基準線　指数3","elemkey":"dev-A-0274","datapattern":"2","defaultvalue":"95","level1":"bvufc","level2":"dev","level3":"A","level4":"274"},
    {"ctlno":"368","setname":"終了時ΔBV基準値 ","elemkey":"dev-A-0275","datapattern":"2","defaultvalue":"-4.0","level1":"bvufc","level2":"dev","level3":"A","level4":"275"},
    {"ctlno":"369","setname":"QBプログラム血流量1","elemkey":"dev-A-0400","datapattern":"2","defaultvalue":"100","level1":"qbqd","level2":"dev","level3":"A","level4":"400"},
    {"ctlno":"370","setname":"QBプログラム血流量2","elemkey":"dev-A-0401","datapattern":"2","defaultvalue":"160","level1":"qbqd","level2":"dev","level3":"A","level4":"401"},
    {"ctlno":"371","setname":"QBプログラム血流量3","elemkey":"dev-A-0402","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"402"},
    {"ctlno":"372","setname":"QBプログラム血流量4","elemkey":"dev-A-0403","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"403"},
    {"ctlno":"373","setname":"QBプログラム血流量5","elemkey":"dev-A-0404","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"404"},
    {"ctlno":"374","setname":"QBプログラム血流量6","elemkey":"dev-A-0405","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"405"},
    {"ctlno":"375","setname":"QBプログラム血流量7","elemkey":"dev-A-0406","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"406"},
    {"ctlno":"376","setname":"QBプログラム血流量8","elemkey":"dev-A-0407","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"407"},
    {"ctlno":"377","setname":"QBプログラム血流量9","elemkey":"dev-A-0408","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"408"},
    {"ctlno":"378","setname":"QBプログラム血流量10","elemkey":"dev-A-0409","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"409"},
    {"ctlno":"379","setname":"QDプログラム透析液流量1","elemkey":"dev-A-0410","datapattern":"2","defaultvalue":"200","level1":"qbqd","level2":"dev","level3":"A","level4":"410"},
    {"ctlno":"380","setname":"QDプログラム透析液流量2","elemkey":"dev-A-0411","datapattern":"2","defaultvalue":"400","level1":"qbqd","level2":"dev","level3":"A","level4":"411"},
    {"ctlno":"381","setname":"QDプログラム透析液流量3","elemkey":"dev-A-0412","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"412"},
    {"ctlno":"382","setname":"QDプログラム透析液流量4","elemkey":"dev-A-0413","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"413"},
    {"ctlno":"383","setname":"QDプログラム透析液流量5","elemkey":"dev-A-0414","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"414"},
    {"ctlno":"384","setname":"QDプログラム透析液流量6","elemkey":"dev-A-0415","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"415"},
    {"ctlno":"385","setname":"QDプログラム透析液流量7","elemkey":"dev-A-0416","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"416"},
    {"ctlno":"386","setname":"QDプログラム透析液流量8","elemkey":"dev-A-0417","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"417"},
    {"ctlno":"387","setname":"QDプログラム透析液流量9","elemkey":"dev-A-0418","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"418"},
    {"ctlno":"388","setname":"QDプログラム透析液流量10","elemkey":"dev-A-0419","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"419"},
    {"ctlno":"389","setname":"QB、QDプログラム切替時間1","elemkey":"dev-A-0420","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"420"},
    {"ctlno":"390","setname":"QB、QDプログラム切替時間2","elemkey":"dev-A-0421","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"421"},
    {"ctlno":"391","setname":"QB、QDプログラム切替時間3","elemkey":"dev-A-0422","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"422"},
    {"ctlno":"392","setname":"QB、QDプログラム切替時間4","elemkey":"dev-A-0423","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"423"},
    {"ctlno":"393","setname":"QB、QDプログラム切替時間5","elemkey":"dev-A-0424","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"424"},
    {"ctlno":"394","setname":"QB、QDプログラム切替時間6","elemkey":"dev-A-0425","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"425"},
    {"ctlno":"395","setname":"QB、QDプログラム切替時間7","elemkey":"dev-A-0426","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"426"},
    {"ctlno":"396","setname":"QB、QDプログラム切替時間8","elemkey":"dev-A-0427","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"427"},
    {"ctlno":"397","setname":"QB、QDプログラム切替時間9","elemkey":"dev-A-0428","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"428"},
    {"ctlno":"398","setname":"QB、QDプログラム最大ステップ数","elemkey":"dev-A-0429","datapattern":"2","defaultvalue":"3","level1":"qbqd","level2":"dev","level3":"A","level4":"429"},
    {"ctlno":"399","setname":"QBプログラム電源","elemkey":"dev-A-0430","datapattern":"2","defaultvalue":"0","level1":"qbqd","level2":"dev","level3":"A","level4":"430"},
    {"ctlno":"400","setname":"QDプログラム電源","elemkey":"dev-A-0431","datapattern":"2","defaultvalue":"0","level1":"qbqd","level2":"dev","level3":"A","level4":"431"},
    {"ctlno":"401","setname":"I-HDFプログラム使用選択","elemkey":"dev-A-0432","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"432"},
    {"ctlno":"402","setname":"予定補液回数","elemkey":"dev-A-0433","datapattern":"2","defaultvalue":"7","level1":"ihdf","level2":"dev","level3":"A","level4":"433"},
    {"ctlno":"403","setname":"補液バランス制限","elemkey":"dev-A-0434","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"434"},
    {"ctlno":"404","setname":"補液量01","elemkey":"dev-A-0435","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"435"},
    {"ctlno":"405","setname":"補液量02","elemkey":"dev-A-0436","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"436"},
    {"ctlno":"406","setname":"補液量03","elemkey":"dev-A-0437","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"437"},
    {"ctlno":"407","setname":"補液量04","elemkey":"dev-A-0438","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"438"},
    {"ctlno":"408","setname":"補液量05","elemkey":"dev-A-0439","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"439"},
    {"ctlno":"409","setname":"補液量06","elemkey":"dev-A-0440","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"440"},
    {"ctlno":"410","setname":"補液量07","elemkey":"dev-A-0441","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"441"},
    {"ctlno":"411","setname":"補液量08","elemkey":"dev-A-0442","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"442"},
    {"ctlno":"412","setname":"補液量09","elemkey":"dev-A-0443","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"443"},
    {"ctlno":"413","setname":"補液量10","elemkey":"dev-A-0444","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"444"},
    {"ctlno":"414","setname":"補液量11","elemkey":"dev-A-0445","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"445"},
    {"ctlno":"415","setname":"補液量12","elemkey":"dev-A-0446","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"446"},
    {"ctlno":"416","setname":"補液量13","elemkey":"dev-A-0447","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"447"},
    {"ctlno":"417","setname":"補液量14","elemkey":"dev-A-0448","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"448"},
    {"ctlno":"418","setname":"補液量15","elemkey":"dev-A-0449","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"449"},
    {"ctlno":"419","setname":"補液量16","elemkey":"dev-A-0450","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"450"},
    {"ctlno":"420","setname":"回収量01","elemkey":"dev-A-0451","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"451"},
    {"ctlno":"421","setname":"回収量02","elemkey":"dev-A-0452","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"452"},
    {"ctlno":"422","setname":"回収量03","elemkey":"dev-A-0453","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"453"},
    {"ctlno":"423","setname":"回収量04","elemkey":"dev-A-0454","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"454"},
    {"ctlno":"424","setname":"回収量05","elemkey":"dev-A-0455","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"455"},
    {"ctlno":"425","setname":"回収量06","elemkey":"dev-A-0456","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"456"},
    {"ctlno":"426","setname":"回収量07","elemkey":"dev-A-0457","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"457"},
    {"ctlno":"427","setname":"回収量08","elemkey":"dev-A-0458","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"458"},
    {"ctlno":"428","setname":"回収量09","elemkey":"dev-A-0459","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"459"},
    {"ctlno":"429","setname":"回収量10","elemkey":"dev-A-0460","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"460"},
    {"ctlno":"430","setname":"回収量11","elemkey":"dev-A-0461","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"461"},
    {"ctlno":"431","setname":"回収量12","elemkey":"dev-A-0462","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"462"},
    {"ctlno":"432","setname":"回収量13","elemkey":"dev-A-0463","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"463"},
    {"ctlno":"433","setname":"回収量14","elemkey":"dev-A-0464","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"464"},
    {"ctlno":"434","setname":"回収量15","elemkey":"dev-A-0465","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"465"},
    {"ctlno":"435","setname":"回収量16","elemkey":"dev-A-0466","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"466"}
  ]'' :: jsonb
      ) AS elements(
        ctlno TEXT,
        setname TEXT,
        elemkey TEXT,
        datapattern TEXT,
        defaultvalue TEXT
      )
  ),
  ntss_db5_pm AS (
    SELECT
      pat_id,
      facility_cd,
      device_set_info,
      up_date
    FROM
      ntss.pat_main
    WHERE
      facility_cd = @facilityCd
      AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
      AND is_del <> ''1''
  ),
  -- 治療情報マスタ：指示
  ind_ord_main_before_rank AS (
    SELECT
      subquery.pat_id,
      subquery.facility_cd,
      subquery.ord_no,
      subquery.treat_week,
      subquery.treat_date,
      subquery.up_date,
      subquery.ind_device_set_info,
      subquery.ind_cond_info,
      subquery.rst_cond_info,
      subquery.ind_bed_cd,
      subquery.rst_weight_info,
      subquery.rst_running_time,
      subquery.min_treatment_date,
      RANK() OVER (
        PARTITION BY subquery.pat_id,
        subquery.treat_week
        ORDER BY
          CASE
            WHEN subquery.ind_kur_cd = ''0'' THEN 2
            ELSE 1
          END,
          CASE
            WHEN subquery.ind_kur_cd = ''0'' THEN ntss_db5_mst_sel.sortkey :: integer
            ELSE (subquery.ind_treat_start_time) :: integer
          END,
          ntss_db5_mst_sel.sortkey
      ) AS priority
    FROM
      (
        SELECT
          ord_main.*,
          MIN(TO_DATE(ord_main.treat_date, ''YYYYMMDD'')) OVER(PARTITION BY ord_main.treat_week, ord_main.pat_id) AS min_treatment_date
        FROM
          ord_main
        WHERE
          ord_main.facility_cd = @facilityCd
          AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
          AND ord_main.is_del = ''0''
          AND TO_DATE(ord_main.treat_date, ''YYYYMMDD'') >= CURRENT_DATE
      ) AS subquery
      LEFT JOIN (
        SELECT
          ntss_db5_ms.facility_cd,
          setting ->> ''code'' AS code,
          ROW_NUMBER() OVER() AS sortkey
        FROM
          ntss.mst_selector ntss_db5_ms
          CROSS JOIN LATERAL jsonb_array_elements((ntss_db5_ms.order_settings #> ''{"items"}'') ) setting
        WHERE
          ntss_db5_ms.facility_cd = @facilityCd
          AND ntss_db5_ms.master_physical_name = ''mst_treatment''
          AND setting ->> ''isDel'' = ''0''
          AND setting ->> ''isDisp'' = ''1''
      ) AS ntss_db5_mst_sel ON subquery.facility_cd = ntss_db5_mst_sel.facility_cd
      AND subquery.ind_treatment_cd :: TEXT = ntss_db5_mst_sel.code
    WHERE
      TO_DATE(treat_date, ''YYYYMMDD'') = min_treatment_date
  ),
  ind_ord_main AS (
    SELECT
      *
    FROM
      ind_ord_main_before_rank
    WHERE
      priority = 1
  ),
  -- pat_mainのデータ取得START
ntss_db5_pm_dsi AS (
  SELECT
    pm.pat_id,
    base.prefix || ''-'' || base.ab || ''-'' || lpad(v.key, 4, ''0'') AS elemkey,
    pm.up_date::text,
    v.value AS value_4
  FROM
    ntss_db5_pm pm
  CROSS JOIN LATERAL jsonb_each(pm.device_set_info::jsonb) kv
  CROSS JOIN LATERAL (
      VALUES
        (''dev'', ''A''),
        (''dev'', ''B''),
        (''pat'', ''A''),
        (''pat'', ''B'')
  ) AS base(prefix, ab)
  CROSS JOIN LATERAL jsonb_each_text(
      (kv.value::jsonb #> ARRAY[base.prefix, base.ab])
  ) v
  WHERE
    pm.device_set_info IS NOT NULL
    AND pm.device_set_info <> ''[]''
    AND v.key IS NOT NULL
), -- pat_mainのデータ取得END
  -- ord_main,pat_treatment_patternのind_device_set_infoデータ取得START
  ntss_db5_ptp_week_date AS (
  SELECT
    p.pat_id,
    p.treat_week,
    max(p.ind_treat_start_date) AS max_ind_treat_start_date
  FROM ntss.pat_treatment_pattern p
  WHERE
    p.facility_cd = @facilityCd
    AND p.pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
    AND p.ind_treat_start_date::date <= CURRENT_DATE
  GROUP BY
    p.pat_id,
    p.treat_week
),

mst_sel AS (
  SELECT
    ms.facility_cd,
    setting ->> ''code'' AS code,
    ROW_NUMBER() OVER (ORDER BY setting ->> ''code'') AS sortkey
  FROM ntss.mst_selector ms
  CROSS JOIN LATERAL jsonb_array_elements(ms.order_settings -> ''items'') setting
  WHERE
    ms.facility_cd = @facilityCd
    AND ms.master_physical_name = ''mst_treatment''
    AND setting ->> ''isDel'' = ''0''
    AND setting ->> ''isDisp'' = ''1''
),

ntss_db5_ptp_week AS (
  SELECT *
  FROM (
    SELECT
      p.pat_id,
      p.treat_week,
      p.ctl_no,
      d.max_ind_treat_start_date,
      p.up_date,
      ROW_NUMBER() OVER (
        PARTITION BY p.pat_id, p.treat_week
        ORDER BY
          CASE WHEN p.ind_kur_cd = ''0'' THEN 2 ELSE 1 END,
          CASE
            WHEN p.ind_kur_cd = ''0''
              THEN mst.sortkey
            ELSE (p.ind_sch_info ->> ''ind_treat_start_time'')::integer
          END,
          mst.sortkey
      ) AS priority,
      p.facility_cd,
      p.ind_sch_info,
      p.ind_cond_info,
      p.ind_device_set_info
    FROM ntss.pat_treatment_pattern p
    JOIN ntss_db5_ptp_week_date d
      ON p.pat_id = d.pat_id
     AND p.treat_week = d.treat_week
     AND p.ind_treat_start_date = d.max_ind_treat_start_date
    LEFT JOIN mst_sel mst
      ON p.facility_cd = mst.facility_cd
     AND p.ind_treatment_cd::text = mst.code
    WHERE
      p.facility_cd = @facilityCd
      AND p.ind_device_set_info IS NOT NULL
      AND p.ind_device_set_info <> ''[]''
  ) ranked
  WHERE priority = 1
),

yellow_idsi AS (

  SELECT DISTINCT ON (pat_id, treat_week, elemkey)
      pat_id,
      treat_week,
      up_date,
      elemkey,
      value_4,
      priority
  FROM (
      SELECT
          w.pat_id,
          w.treat_week,
          w.max_ind_treat_start_date AS up_date,
          ''dev-'' || base.ab || ''-'' || lpad(v.key, 4, ''0'') AS elemkey,
          v.value AS value_4,
          1 AS priority
      FROM ntss_db5_ptp_week w
      CROSS JOIN LATERAL jsonb_each(w.ind_device_set_info::jsonb) kv
      CROSS JOIN LATERAL (VALUES (''A''), (''B'')) AS base(ab)
      CROSS JOIN LATERAL jsonb_each_text(
          kv.value::jsonb -> ''dev'' -> base.ab
      ) v
      WHERE
          w.facility_cd = @facilityCd
          AND w.priority = 1
          AND w.ind_device_set_info IS NOT NULL
          AND w.ind_device_set_info <> ''[]''

      UNION ALL

-- ind_ord_main側
      SELECT
          o.pat_id,
          o.treat_week,
          o.up_date::text,
          ''dev-'' || base.ab || ''-'' || lpad(v.key, 4, ''0'') AS elemkey,
          v.value AS value_4,
          2 AS priority
      FROM ind_ord_main o
      CROSS JOIN LATERAL jsonb_each(o.ind_device_set_info::jsonb) kv
      CROSS JOIN LATERAL (VALUES (''A''), (''B'')) AS base(ab)
      CROSS JOIN LATERAL jsonb_each_text(
          kv.value::jsonb -> ''dev'' -> base.ab
      ) v
      WHERE
          o.ind_device_set_info IS NOT NULL
          AND o.ind_device_set_info <> ''[]''

  ) src

-- priorityの小さいものを優先
  ORDER BY pat_id, treat_week, elemkey, priority

),


  
  elements3 AS (
  SELECT elemkey, ctlno
  FROM elements
  WHERE datapattern = ''3''
    AND ctlno IN (''81'',''150'',''151'',''189'',''231'',''232'',''233'',''239'')
),
  
  ntss_db5_pu_physical AS (
  SELECT
    pu.pat_id,
    j.physical_info_json ->> ''dw'' AS dw,
    RANK() OVER (
      PARTITION BY pu.pat_id
      ORDER BY
        j.physical_info_json ->> ''inspect_date'' DESC,
        j.physical_info_json ->> ''exam_date'' DESC
    ) AS priority,
    ROW_NUMBER() OVER (
      PARTITION BY pu.pat_id
      ORDER BY
        j.physical_info_json ->> ''inspect_date'' DESC,
        j.physical_info_json ->> ''exam_date'' DESC
    ) AS sortkey
  FROM pat_unique pu
  JOIN ntss_db5_pm pm
    ON pu.pat_id = pm.pat_id
   AND pu.facility_cd = pm.facility_cd
  CROSS JOIN LATERAL jsonb_array_elements(pu.physical_info::jsonb) j(physical_info_json)
  WHERE pu.is_del = ''0''
),

ind_cond_info AS (
  SELECT
    w.pat_id::integer,
    w.treat_week::integer,
    w.max_ind_treat_start_date::text AS up_date,
    e.elemkey,
    CASE e.ctlno
      WHEN ''81''  THEN w.ind_cond_info #>> ''{33,value}''
      WHEN ''150'' THEN w.ind_cond_info #>> ''{3,value}''
      WHEN ''151'' THEN w.ind_cond_info #>> ''{14,value}''
      WHEN ''189'' THEN w.ind_cond_info #>> ''{14,value}''
      WHEN ''231'' THEN w.ind_cond_info #>> ''{24,value}''
      WHEN ''232'' THEN w.ind_cond_info #>> ''{23,value}''
      WHEN ''233'' THEN w.ind_cond_info #>> ''{20,value}''
      WHEN ''239'' THEN w.ind_cond_info #>> ''{21,value}''
    END AS value_4,
    1 AS priority
  FROM ntss_db5_ptp_week w
  JOIN elements3 e
    ON TRUE
  WHERE w.ind_cond_info IS NOT NULL
    AND w.ind_cond_info <> ''[]''

  UNION ALL
  SELECT
    o.pat_id::integer,
    o.treat_week::integer,
    o.up_date::text,
    e.elemkey,
    CASE e.ctlno
      WHEN ''81''  THEN o.ind_cond_info #>> ''{33,value}''
      WHEN ''150'' THEN o.ind_cond_info #>> ''{3,value}''
      WHEN ''151'' THEN o.ind_cond_info #>> ''{14,value}''
      WHEN ''189'' THEN o.ind_cond_info #>> ''{14,value}''
      WHEN ''231'' THEN o.ind_cond_info #>> ''{24,value}''
      WHEN ''232'' THEN o.ind_cond_info #>> ''{23,value}''
      WHEN ''233'' THEN o.ind_cond_info #>> ''{20,value}''
      WHEN ''239'' THEN o.ind_cond_info #>> ''{21,value}''
          END AS value_4,
    2 AS priority
  FROM ind_ord_main o
  JOIN elements3 e
    ON TRUE
  WHERE o.ind_cond_info IS NOT NULL
    AND o.ind_cond_info <> ''[]''
),-- ord_main,pat_treatment_patternのind_cond_infoデータ取得END
  -- ベッド情報取得START
  ptp_machine AS (
    SELECT
        w.pat_id,
        w.treat_week,
        m.up_date,
        m.tmp_center_hd,
        m.tmp_center_ecum,
        m.tmp_center_hdf,
        m.tmp_center_hf,
        m.tmp_center_ohdf,
        m.tmp_center_ohf,
        1 AS priority
    FROM ntss_db5_ptp_week w
    JOIN ntss.mst_bed b
        ON w.ind_sch_info ->> ''ind_bed_cd'' = b.bed_cd::TEXT
        AND w.facility_cd = b.facility_cd
        AND b.is_del = ''0'' AND b.is_disp = ''1''
    JOIN ntss.mst_machine m
        ON b.machine_no = m.machine_no
        AND w.facility_cd = m.facility_cd
        AND m.is_del = ''0'' AND m.is_disp = ''1''
    WHERE w.ind_sch_info IS NOT NULL AND w.ind_sch_info <> ''[]''
),
om_machine AS (
    SELECT
        o.pat_id,
        o.treat_week,
        m.up_date,
        m.tmp_center_hd,
        m.tmp_center_ecum,
        m.tmp_center_hdf,
        m.tmp_center_hf,
        m.tmp_center_ohdf,
        m.tmp_center_ohf,
        2 AS priority
    FROM ind_ord_main o
    JOIN ntss.mst_bed b
        ON o.ind_bed_cd = b.bed_cd
        AND o.facility_cd = b.facility_cd
        AND b.is_del = ''0'' AND b.is_disp = ''1''
    JOIN ntss.mst_machine m
        ON b.machine_no = m.machine_no
        AND o.facility_cd = m.facility_cd
        AND m.is_del = ''0'' AND m.is_disp = ''1''
    WHERE o.ind_bed_cd IS NOT NULL
),
ranked_machine_info AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY pat_id, treat_week ORDER BY priority) AS rn
        FROM (
            SELECT * FROM ptp_machine
            UNION ALL
            SELECT * FROM om_machine
        ) AS combined
    ) AS ranked
    WHERE rn = 1
),
ptp_om_machine_info AS (
    SELECT
        r.pat_id,
        r.treat_week,
        r.up_date,
        e.elemkey,
        CASE e.elemkey
            WHEN ''tmp_center_hd'' THEN r.tmp_center_hd
            WHEN ''tmp_center_ecum'' THEN r.tmp_center_ecum
            WHEN ''tmp_center_hdf'' THEN r.tmp_center_hdf
            WHEN ''tmp_center_hf'' THEN r.tmp_center_hf
            WHEN ''tmp_center_ohdf'' THEN r.tmp_center_ohdf
            WHEN ''tmp_center_ohf'' THEN r.tmp_center_ohf
        END AS value_4
    FROM ranked_machine_info r
    JOIN elements e
        ON e.datapattern = ''5''
), -- ベッド情報取得END
  -- ダイアライザ情報取得START 

ptp_dialyzer_info AS (
    SELECT
        w.pat_id,
        w.treat_week,
        COALESCE(d.up_date, w.up_date) AS up_date,
        d.ufr_warning_max,
        d.ufr_warning_min,
        d.ufr_warning_reduction,
        d.koa,
        COALESCE(d.dialyzer_type, ''0'') AS dialyzer_type,
        1 AS priority
    FROM ntss_db5_ptp_week w
    LEFT JOIN ntss.mst_dialyzer d
        ON d.facility_cd = w.facility_cd
        AND d.dialyzer_cd::text = w.ind_cond_info #>> ''{5,value}''
        AND d.is_del = ''0''
        AND d.is_disp = ''1''
    WHERE w.ind_cond_info IS NOT NULL AND w.ind_cond_info <> ''[]''
),
  om_dialyzer_info AS (
    SELECT
        o.pat_id,
        o.treat_week,
        COALESCE(d.up_date, o.up_date) AS up_date,
        d.ufr_warning_max,
        d.ufr_warning_min,
        d.ufr_warning_reduction,
        d.koa,
        COALESCE(d.dialyzer_type, ''0'') AS dialyzer_type,
        2 AS priority
    FROM ind_ord_main o
    LEFT JOIN ntss.mst_dialyzer d
        ON d.facility_cd = o.facility_cd
        AND d.dialyzer_cd::text = o.ind_cond_info #>> ''{5,value}''
        AND d.is_del = ''0''
        AND d.is_disp = ''1''
    WHERE o.ind_cond_info IS NOT NULL AND o.ind_cond_info <> ''[]''
    ),
ranked_dialyzer AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(
                PARTITION BY pat_id, treat_week
                ORDER BY priority, up_date DESC
            ) AS rn
        FROM (
            SELECT pat_id, treat_week, up_date, ufr_warning_max, ufr_warning_min, ufr_warning_reduction, koa, dialyzer_type, priority
            FROM ptp_dialyzer_info
            UNION ALL
            SELECT pat_id, treat_week, up_date, ufr_warning_max, ufr_warning_min, ufr_warning_reduction, koa, dialyzer_type, priority
            FROM om_dialyzer_info
        ) AS combined
    ) AS numbered
    WHERE rn = 1
),
ind_ord_main_ptp_dialyzer AS (
    SELECT
        r.pat_id,
        r.treat_week,
        r.up_date,
        e.elemkey,
        CASE e.elemkey
            WHEN ''ufr_warning_max'' THEN r.ufr_warning_max::text
            WHEN ''ufr_warning_min'' THEN r.ufr_warning_min::text
            WHEN ''ufr_warning_reduction'' THEN r.ufr_warning_reduction::text
            WHEN ''koa'' THEN r.koa::text
            WHEN ''dialyzer_type'' THEN r.dialyzer_type::text
        END AS value_4
    FROM ranked_dialyzer r
    JOIN elements e
        ON e.datapattern = ''4''
), -- ダイアライザ情報取得END
  -- 各曜日のデータ集計
  ind_ord_main_ptp_dsi AS (
  SELECT
    pat_id::integer,
    treat_week::integer,
    up_date::text,
    elemkey::text,
    value_4::text
  FROM (
    SELECT *,
           ROW_NUMBER() OVER (
             PARTITION BY pat_id, treat_week, elemkey
             ORDER BY priority
           ) AS rn
    FROM yellow_idsi
  ) y
  WHERE rn = 1

  UNION ALL
  SELECT
    pat_id::integer,
    treat_week::integer,
    up_date::text,
    elemkey::text,
    value_4::text
  FROM ptp_om_machine_info
  UNION ALL
  SELECT
    pat_id::integer,
    treat_week::integer,
    up_date::text,
    elemkey::text,
    value_4::text
  FROM ind_ord_main_ptp_dialyzer

  UNION ALL
  SELECT
    pat_id::integer,
    treat_week::integer,
    up_date::text,
    elemkey::text,
    value_4
  FROM (
    SELECT
      i.pat_id,
      i.treat_week,
      i.up_date,
      i.elemkey,
      CASE
        WHEN i.elemkey = ''ind_cond_info-3-value''
         AND i.value_4 = ''-1''
        THEN p.dw
        ELSE i.value_4::text
      END AS value_4,
      ROW_NUMBER() OVER (
        PARTITION BY i.pat_id, i.treat_week, i.elemkey
        ORDER BY i.priority
      ) AS rn
    FROM ind_cond_info i
    LEFT JOIN ntss_db5_pu_physical p
      ON i.pat_id = p.pat_id
     AND p.priority = ''1''
     AND p.sortkey = ''1''
  ) c
  WHERE rn = 1
  UNION ALL
  SELECT
    w.pat_id::integer,
    w.treat_week::integer,
    w.max_ind_treat_start_date::text AS up_date,
    e.elemkey::text,
    e.defaultvalue::text AS value_4
  FROM ntss_db5_ptp_week w
  JOIN elements e
    ON e.datapattern = ''7''
  WHERE w.priority = ''1''
),
ind_ord_main_ptp_dsi_days AS (
SELECT 
      ind_ord_main_ptp_dsi.pat_id,
      ind_ord_main_ptp_dsi.elemkey,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = EXTRACT(ISODOW FROM CURRENT_DATE)) AS up_date_0,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = EXTRACT(ISODOW FROM CURRENT_DATE)) AS value_4_0,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''1'') AS up_date_1,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''1'') AS value_4_1,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''2'') AS up_date_2,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''2'') AS value_4_2,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''3'') AS up_date_3,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''3'') AS value_4_3,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''4'') AS up_date_4,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''4'') AS value_4_4,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''5'') AS up_date_5,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''5'') AS value_4_5,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''6'') AS up_date_6,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''6'') AS value_4_6,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''7'') AS up_date_7,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''7'') AS value_4_7
 FROM 
      ind_ord_main_ptp_dsi
    GROUP BY 
      ind_ord_main_ptp_dsi.pat_id, ind_ord_main_ptp_dsi.elemkey
  ),
  --select5
  elements_extended AS (
    SELECT
      *,
      CASE
        WHEN elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'') THEN ''0''
        ELSE NULL
      END AS fixed_value,
      CASE
        WHEN elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'') THEN NULL
        ELSE NULL
      END AS fixed_update
    FROM
      elements
  )
SELECT
  ntss_db5_pm.pat_id AS patid,
  '''' AS hosppatid,
  '''' AS name,
  elements_extended.ctlno AS ctlno,
  elements_extended.setname AS setname,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_0
    END
  ) AS value,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_0 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS
update
,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_1
    END
  ) AS monvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_1 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS monupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_2
    END
  ) AS tuevalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_2 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS tueupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_3
    END
  ) AS wedvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_3 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS wedupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_4
    END
  ) AS thuvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_4 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS thuupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_5
    END
  ) AS frivalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_5 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS friupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_6
    END
  ) AS satvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_6 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS satupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_7
    END
  ) AS sunvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_7 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS sunupdate
FROM
  ntss_db5_pm
  JOIN elements_extended ON TRUE
  LEFT JOIN ntss_db5_pm_dsi ON ntss_db5_pm.pat_id = ntss_db5_pm_dsi.pat_id
  AND elements_extended.elemkey = ntss_db5_pm_dsi.elemkey
  LEFT JOIN ind_ord_main_ptp_dsi_days ON ntss_db5_pm.pat_id = ind_ord_main_ptp_dsi_days.pat_id
  AND elements_extended.elemkey = ind_ord_main_ptp_dsi_days.elemkey;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);