DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2070,-2071)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2070, '-- 【SQL_CD=-2070】
WITH ntss_db5_pm as (
    SELECT
        ntss_db5_pm.pat_id
        , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update
        , ntss_db5_pm.off_water_info
        , ntss_db5_pm.off_water_info #>> ''{1,name_1}'' as name11
        , ntss_db5_pm.off_water_info #>> ''{1,name_2}'' as name12
        , ntss_db5_pm.off_water_info #>> ''{1,name_3}'' as name13
        , ntss_db5_pm.off_water_info #>> ''{1,name_4}'' as name14
        , ntss_db5_pm.off_water_info #>> ''{1,name_5}'' as name15
        , ntss_db5_pm.off_water_info #>> ''{2,name_1}'' as name21
        , ntss_db5_pm.off_water_info #>> ''{2,name_2}'' as name22
        , ntss_db5_pm.off_water_info #>> ''{2,name_3}'' as name23
        , ntss_db5_pm.off_water_info #>> ''{2,name_4}'' as name24
        , ntss_db5_pm.off_water_info #>> ''{2,name_5}'' as name25
        , ntss_db5_pm.off_water_info #>> ''{3,name_1}'' as name31
        , ntss_db5_pm.off_water_info #>> ''{3,name_2}'' as name32
        , ntss_db5_pm.off_water_info #>> ''{3,name_3}'' as name33
        , ntss_db5_pm.off_water_info #>> ''{3,name_4}'' as name34
        , ntss_db5_pm.off_water_info #>> ''{3,name_5}'' as name35
        , ntss_db5_pm.off_water_info #>> ''{4,name_1}'' as name41
        , ntss_db5_pm.off_water_info #>> ''{4,name_2}'' as name42
        , ntss_db5_pm.off_water_info #>> ''{4,name_3}'' as name43
        , ntss_db5_pm.off_water_info #>> ''{4,name_4}'' as name44
        , ntss_db5_pm.off_water_info #>> ''{4,name_5}'' as name45
        , ntss_db5_pm.off_water_info #>> ''{5,name_1}'' as name51
        , ntss_db5_pm.off_water_info #>> ''{5,name_2}'' as name52
        , ntss_db5_pm.off_water_info #>> ''{5,name_3}'' as name53
        , ntss_db5_pm.off_water_info #>> ''{5,name_4}'' as name54
        , ntss_db5_pm.off_water_info #>> ''{5,name_5}'' as name55
        , ntss_db5_pm.off_water_info #>> ''{6,name_1}'' as name61
        , ntss_db5_pm.off_water_info #>> ''{6,name_2}'' as name62
        , ntss_db5_pm.off_water_info #>> ''{6,name_3}'' as name63
        , ntss_db5_pm.off_water_info #>> ''{6,name_4}'' as name64
        , ntss_db5_pm.off_water_info #>> ''{6,name_5}'' as name65
        , ntss_db5_pm.off_water_info #>> ''{7,name_1}'' as name71
        , ntss_db5_pm.off_water_info #>> ''{7,name_2}'' as name72
        , ntss_db5_pm.off_water_info #>> ''{7,name_3}'' as name73
        , ntss_db5_pm.off_water_info #>> ''{7,name_4}'' as name74
        , ntss_db5_pm.off_water_info #>> ''{7,name_5}'' as name75
        , coalesce(ntss_db5_pm.off_water_info #>> ''{1,weight_1}'', ''0'') as weight11
        , coalesce(ntss_db5_pm.off_water_info #>> ''{1,weight_2}'', ''0'') as weight12
        , coalesce(ntss_db5_pm.off_water_info #>> ''{1,weight_3}'', ''0'') as weight13
        , coalesce(ntss_db5_pm.off_water_info #>> ''{1,weight_4}'', ''0'') as weight14
        , coalesce(ntss_db5_pm.off_water_info #>> ''{1,weight_5}'', ''0'') as weight15
        , coalesce(ntss_db5_pm.off_water_info #>> ''{2,weight_1}'', ''0'') as weight21
        , coalesce(ntss_db5_pm.off_water_info #>> ''{2,weight_2}'', ''0'') as weight22
        , coalesce(ntss_db5_pm.off_water_info #>> ''{2,weight_3}'', ''0'') as weight23
        , coalesce(ntss_db5_pm.off_water_info #>> ''{2,weight_4}'', ''0'') as weight24
        , coalesce(ntss_db5_pm.off_water_info #>> ''{2,weight_5}'', ''0'') as weight25
        , coalesce(ntss_db5_pm.off_water_info #>> ''{3,weight_1}'', ''0'') as weight31
        , coalesce(ntss_db5_pm.off_water_info #>> ''{3,weight_2}'', ''0'') as weight32
        , coalesce(ntss_db5_pm.off_water_info #>> ''{3,weight_3}'', ''0'') as weight33
        , coalesce(ntss_db5_pm.off_water_info #>> ''{3,weight_4}'', ''0'') as weight34
        , coalesce(ntss_db5_pm.off_water_info #>> ''{3,weight_5}'', ''0'') as weight35
        , coalesce(ntss_db5_pm.off_water_info #>> ''{4,weight_1}'', ''0'') as weight41
        , coalesce(ntss_db5_pm.off_water_info #>> ''{4,weight_2}'', ''0'') as weight42
        , coalesce(ntss_db5_pm.off_water_info #>> ''{4,weight_3}'', ''0'') as weight43
        , coalesce(ntss_db5_pm.off_water_info #>> ''{4,weight_4}'', ''0'') as weight44
        , coalesce(ntss_db5_pm.off_water_info #>> ''{4,weight_5}'', ''0'') as weight45
        , coalesce(ntss_db5_pm.off_water_info #>> ''{5,weight_1}'', ''0'') as weight51
        , coalesce(ntss_db5_pm.off_water_info #>> ''{5,weight_2}'', ''0'') as weight52
        , coalesce(ntss_db5_pm.off_water_info #>> ''{5,weight_3}'', ''0'') as weight53
        , coalesce(ntss_db5_pm.off_water_info #>> ''{5,weight_4}'', ''0'') as weight54
        , coalesce(ntss_db5_pm.off_water_info #>> ''{5,weight_5}'', ''0'') as weight55
        , coalesce(ntss_db5_pm.off_water_info #>> ''{6,weight_1}'', ''0'') as weight61
        , coalesce(ntss_db5_pm.off_water_info #>> ''{6,weight_2}'', ''0'') as weight62
        , coalesce(ntss_db5_pm.off_water_info #>> ''{6,weight_3}'', ''0'') as weight63
        , coalesce(ntss_db5_pm.off_water_info #>> ''{6,weight_4}'', ''0'') as weight64
        , coalesce(ntss_db5_pm.off_water_info #>> ''{6,weight_5}'', ''0'') as weight65
        , coalesce(ntss_db5_pm.off_water_info #>> ''{7,weight_1}'', ''0'') as weight71
        , coalesce(ntss_db5_pm.off_water_info #>> ''{7,weight_2}'', ''0'') as weight72
        , coalesce(ntss_db5_pm.off_water_info #>> ''{7,weight_3}'', ''0'') as weight73
        , coalesce(ntss_db5_pm.off_water_info #>> ''{7,weight_4}'', ''0'') as weight74
        , coalesce(ntss_db5_pm.off_water_info #>> ''{7,weight_5}'', ''0'') as weight75
    FROM
        pat_main ntss_db5_pm
    WHERE
        ntss_db5_pm.facility_cd = @facilityCd
        AND ntss_db5_pm.is_del = ''0''
)
SELECT --ctlno = 1
    '''' AS hosppatid --患者ID
    , ntss_db5_pm.pat_id AS patid
    , '''' AS name --氏名
    , 1 as ctlno --管理番号
    , ntss_db5_pm.update AS update --更新日時(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.name11
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.name21
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.name31
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.name41
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.name51
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.name61
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.name71
        END AS revisename --除水補正名(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.weight11
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.weight21
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.weight31
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.weight41
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.weight51
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.weight61
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.weight71
        END AS reviseweight --除水補正名(当日)
    , ntss_db5_pm.update AS monupdate --更新日時(月曜日)
    , ntss_db5_pm.name11 AS monrevisename --除水補正名(月曜日)
    , ntss_db5_pm.weight11 AS monreviseweight --重量(月曜日)
    , ntss_db5_pm.update AS tueupdate --更新日時(火曜日)
    , ntss_db5_pm.name21 AS tuerevisename --除水補正名(火曜日)
    , ntss_db5_pm.weight21 AS tuereviseweight --重量(火曜日)
    , ntss_db5_pm.update AS wedupdate --更新日時(水曜日)
    , ntss_db5_pm.name31 AS wedrevisename --除水補正名(水曜日)
    , ntss_db5_pm.weight31 AS wedreviseweight --重量(水曜日)
    , ntss_db5_pm.update AS thuupdate --更新日時(木曜日)
    , ntss_db5_pm.name41 AS thurevisename --除水補正名(木曜日)
    , ntss_db5_pm.weight41 AS thureviseweight --重量(木曜日)
    , ntss_db5_pm.update AS friupdate --更新日時(金曜日)
    , ntss_db5_pm.name51 AS frirevisename --除水補正名(金曜日)
    , ntss_db5_pm.weight51 AS frireviseweight --重量(金曜日)
    , ntss_db5_pm.update AS satupdate --更新日時(土曜日)
    , ntss_db5_pm.name61 AS satrevisename --除水補正名(土曜日)
    , ntss_db5_pm.weight61 AS satreviseweight --重量(土曜日)
    , ntss_db5_pm.update AS sunupdate --更新日時(日曜日)
    , ntss_db5_pm.name71 AS sunrevisename --除水補正名(日曜日)
    , ntss_db5_pm.weight71 AS sunreviseweight --重量(日曜日)
FROM
    ntss_db5_pm
UNION ALL
SELECT --ctlno = 2
    '''' AS hosppatid --患者ID
    , ntss_db5_pm.pat_id AS patid
    , '''' AS name --氏名
    , 2 as ctlno --管理番号
    , ntss_db5_pm.update AS update --更新日時(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.name12
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.name22
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.name32
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.name42
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.name52
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.name62
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.name72
        END AS revisename --除水補正名(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.weight12
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.weight22
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.weight32
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.weight42
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.weight52
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.weight62
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.weight72
        END AS reviseweight --除水補正名(当日)
    , ntss_db5_pm.update AS monupdate --更新日時(月曜日)
    , ntss_db5_pm.name12 AS monrevisename --除水補正名(月曜日)
    , ntss_db5_pm.weight12 AS monreviseweight --重量(月曜日)
    , ntss_db5_pm.update AS tueupdate --更新日時(火曜日)
    , ntss_db5_pm.name22 AS tuerevisename --除水補正名(火曜日)
    , ntss_db5_pm.weight22 AS tuereviseweight --重量(火曜日)
    , ntss_db5_pm.update AS wedupdate --更新日時(水曜日)
    , ntss_db5_pm.name32 AS wedrevisename --除水補正名(水曜日)
    , ntss_db5_pm.weight32 AS wedreviseweight --重量(水曜日)
    , ntss_db5_pm.update AS thuupdate --更新日時(木曜日)
    , ntss_db5_pm.name42 AS thurevisename --除水補正名(木曜日)
    , ntss_db5_pm.weight42 AS thureviseweight --重量(木曜日)
    , ntss_db5_pm.update AS friupdate --更新日時(金曜日)
    , ntss_db5_pm.name52 AS frirevisename --除水補正名(金曜日)
    , ntss_db5_pm.weight52 AS frireviseweight --重量(金曜日)
    , ntss_db5_pm.update AS satupdate --更新日時(土曜日)
    , ntss_db5_pm.name62 AS satrevisename --除水補正名(土曜日)
    , ntss_db5_pm.weight62 AS satreviseweight --重量(土曜日)
    , ntss_db5_pm.update AS sunupdate --更新日時(日曜日)
    , ntss_db5_pm.name72 AS sunrevisename --除水補正名(日曜日)
    , ntss_db5_pm.weight72 AS sunreviseweight --重量(日曜日)
FROM
    ntss_db5_pm
UNION ALL
SELECT --ctlno = 3
    '''' AS hosppatid --患者ID
    , ntss_db5_pm.pat_id AS patid
    , '''' AS name --氏名
    , 3 as ctlno --管理番号
    , ntss_db5_pm.update AS update --更新日時(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.name13
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.name23
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.name33
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.name43
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.name53
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.name63
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.name73
        END AS revisename --除水補正名(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.weight13
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.weight23
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.weight33
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.weight43
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.weight53
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.weight63
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.weight73
        END AS reviseweight --除水補正名(当日)
    , ntss_db5_pm.update AS monupdate --更新日時(月曜日)
    , ntss_db5_pm.name13 AS monrevisename --除水補正名(月曜日)
    , ntss_db5_pm.weight13 AS monreviseweight --重量(月曜日)
    , ntss_db5_pm.update AS tueupdate --更新日時(火曜日)
    , ntss_db5_pm.name23 AS tuerevisename --除水補正名(火曜日)
    , ntss_db5_pm.weight23 AS tuereviseweight --重量(火曜日)
    , ntss_db5_pm.update AS wedupdate --更新日時(水曜日)
    , ntss_db5_pm.name33 AS wedrevisename --除水補正名(水曜日)
    , ntss_db5_pm.weight33 AS wedreviseweight --重量(水曜日)
    , ntss_db5_pm.update AS thuupdate --更新日時(木曜日)
    , ntss_db5_pm.name43 AS thurevisename --除水補正名(木曜日)
    , ntss_db5_pm.weight43 AS thureviseweight --重量(木曜日)
    , ntss_db5_pm.update AS friupdate --更新日時(金曜日)
    , ntss_db5_pm.name53 AS frirevisename --除水補正名(金曜日)
    , ntss_db5_pm.weight53 AS frireviseweight --重量(金曜日)
    , ntss_db5_pm.update AS satupdate --更新日時(土曜日)
    , ntss_db5_pm.name63 AS satrevisename --除水補正名(土曜日)
    , ntss_db5_pm.weight63 AS satreviseweight --重量(土曜日)
    , ntss_db5_pm.update AS sunupdate --更新日時(日曜日)
    , ntss_db5_pm.name73 AS sunrevisename --除水補正名(日曜日)
    , ntss_db5_pm.weight73 AS sunreviseweight --重量(日曜日)
FROM
    ntss_db5_pm
UNION ALL
SELECT --ctlno = 4
    '''' AS hosppatid --患者ID
    , ntss_db5_pm.pat_id AS patid
    , '''' AS name --氏名
    , 4 as ctlno --管理番号
    , ntss_db5_pm.update AS update --更新日時(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.name14
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.name24
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.name34
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.name44
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.name54
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.name64
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.name74
        END AS revisename --除水補正名(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.weight14
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.weight24
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.weight34
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.weight44
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.weight54
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.weight64
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.weight74
        END AS reviseweight --除水補正名(当日)
    , ntss_db5_pm.update AS monupdate --更新日時(月曜日)
    , ntss_db5_pm.name14 AS monrevisename --除水補正名(月曜日)
    , ntss_db5_pm.weight14 AS monreviseweight --重量(月曜日)
    , ntss_db5_pm.update AS tueupdate --更新日時(火曜日)
    , ntss_db5_pm.name24 AS tuerevisename --除水補正名(火曜日)
    , ntss_db5_pm.weight24 AS tuereviseweight --重量(火曜日)
    , ntss_db5_pm.update AS wedupdate --更新日時(水曜日)
    , ntss_db5_pm.name34 AS wedrevisename --除水補正名(水曜日)
    , ntss_db5_pm.weight34 AS wedreviseweight --重量(水曜日)
    , ntss_db5_pm.update AS thuupdate --更新日時(木曜日)
    , ntss_db5_pm.name44 AS thurevisename --除水補正名(木曜日)
    , ntss_db5_pm.weight44 AS thureviseweight --重量(木曜日)
    , ntss_db5_pm.update AS friupdate --更新日時(金曜日)
    , ntss_db5_pm.name54 AS frirevisename --除水補正名(金曜日)
    , ntss_db5_pm.weight54 AS frireviseweight --重量(金曜日)
    , ntss_db5_pm.update AS satupdate --更新日時(土曜日)
    , ntss_db5_pm.name64 AS satrevisename --除水補正名(土曜日)
    , ntss_db5_pm.weight64 AS satreviseweight --重量(土曜日)
    , ntss_db5_pm.update AS sunupdate --更新日時(日曜日)
    , ntss_db5_pm.name74 AS sunrevisename --除水補正名(日曜日)
    , ntss_db5_pm.weight74 AS sunreviseweight --重量(日曜日)
FROM
    ntss_db5_pm
UNION ALL
SELECT --ctlno = 5
    '''' AS hosppatid --患者ID
    , ntss_db5_pm.pat_id AS patid
    , '''' AS name --氏名
    , 5 as ctlno --管理番号
    , ntss_db5_pm.update AS update --更新日時(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.name15
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.name25
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.name35
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.name45
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.name55
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.name65
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.name75
        END AS revisename --除水補正名(当日)
    , CASE
        WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.weight15
        WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.weight25
        WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.weight35
        WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.weight45
        WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.weight55
        WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.weight65
        WHEN extract(DOW FROM now()) = 0 THEN ntss_db5_pm.weight75
        END AS reviseweight --除水補正名(当日)
    , ntss_db5_pm.update AS monupdate --更新日時(月曜日)
    , ntss_db5_pm.name15 AS monrevisename --除水補正名(月曜日)
    , ntss_db5_pm.weight15 AS monreviseweight --重量(月曜日)
    , ntss_db5_pm.update AS tueupdate --更新日時(火曜日)
    , ntss_db5_pm.name25 AS tuerevisename --除水補正名(火曜日)
    , ntss_db5_pm.weight25 AS tuereviseweight --重量(火曜日)
    , ntss_db5_pm.update AS wedupdate --更新日時(水曜日)
    , ntss_db5_pm.name35 AS wedrevisename --除水補正名(水曜日)
    , ntss_db5_pm.weight35 AS wedreviseweight --重量(水曜日)
    , ntss_db5_pm.update AS thuupdate --更新日時(木曜日)
    , ntss_db5_pm.name45 AS thurevisename --除水補正名(木曜日)
    , ntss_db5_pm.weight45 AS thureviseweight --重量(木曜日)
    , ntss_db5_pm.update AS friupdate --更新日時(金曜日)
    , ntss_db5_pm.name55 AS frirevisename --除水補正名(金曜日)
    , ntss_db5_pm.weight55 AS frireviseweight --重量(金曜日)
    , ntss_db5_pm.update AS satupdate --更新日時(土曜日)
    , ntss_db5_pm.name65 AS satrevisename --除水補正名(土曜日)
    , ntss_db5_pm.weight65 AS satreviseweight --重量(土曜日)
    , ntss_db5_pm.update AS sunupdate --更新日時(日曜日)
    , ntss_db5_pm.name75 AS sunrevisename --除水補正名(日曜日)
    , ntss_db5_pm.weight75 AS sunreviseweight --重量(日曜日)
FROM
    ntss_db5_pm;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2071, '-- 【SQL_CD=-2071】
SELECT
	hosp_pat_id AS hosppatid
	,pat_id AS patid
	,CONCAT(personal_info_decrypt(pat_last_name), ''　'', personal_info_decrypt(pat_first_name)) AS name
FROM
	pat_personal_main
WHERE is_del != ''1''
	AND facility_cd = @facilityCd;
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
