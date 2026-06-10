-- V_PAT_REVISE_TARE
UPDATE sys_data_set
SET "sql" =
        'SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 1 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_1}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_1}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_1}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_1}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_1}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_1}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_1}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_1}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_1}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_1}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_1}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_1}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_1}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_1}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_1}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_1}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_1}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_1}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_1}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_1}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_1}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_1}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_1}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_1}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_1}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_1}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_1}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_1}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.tare_info IS NOT NULL
           AND ntss_db5_pm.tare_info <> ''[]''
       UNION ALL
       SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 2 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_2}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_2}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_2}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_2}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_2}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_2}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_2}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_2}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_2}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_2}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_2}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_2}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_2}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_2}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_2}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_2}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_2}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_2}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_2}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_2}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_2}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_2}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_2}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_2}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_2}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_2}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_2}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_2}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.tare_info IS NOT NULL
           AND ntss_db5_pm.tare_info <> ''[]''
       UNION ALL
       SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 3 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_3}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_3}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_3}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_3}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_3}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_3}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_3}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_3}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_3}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_3}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_3}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_3}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_3}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_3}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_3}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_3}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_3}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_3}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_3}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_3}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_3}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_3}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_3}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_3}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_3}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_3}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_3}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_3}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.tare_info IS NOT NULL
           AND ntss_db5_pm.tare_info <> ''[]''
       UNION ALL
       SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 4 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_4}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_4}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_4}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_4}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_4}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_4}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_4}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_4}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_4}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_4}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_4}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_4}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_4}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_4}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_4}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_4}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_4}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_4}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_4}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_4}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_4}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_4}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_4}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_4}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_4}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_4}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_4}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_4}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.tare_info IS NOT NULL
           AND ntss_db5_pm.tare_info <> ''[]''
       UNION ALL
       SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 5 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_5}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_5}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_5}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_5}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_5}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_5}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_5}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_5}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_5}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_5}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_5}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_5}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_5}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_5}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_5}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_5}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_5}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_5}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_5}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_5}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_5}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_5}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_5}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_5}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_5}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_5}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_5}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_5}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.tare_info IS NOT NULL
           AND ntss_db5_pm.tare_info <> ''[]'''
WHERE sql_cd = '-2080';


-- V_ONL_RST_DIALYSIS
UPDATE sys_data_set
SET "sql"=
        'WITH ntss_db5_mst_b AS (
           SELECT
            om.ord_no AS ord_no
            ,ntss_db5_mst_b.in_hospital_cd_1 AS in_hospital_cd_1
            ,ntss_db5_mst_b.bed_name AS bed_name
           FROM ord_main om
           LEFT JOIN mst_bed ntss_db5_mst_b
           ON om.rst_bed_cd = ntss_db5_mst_b.bed_cd
           WHERE ntss_db5_mst_b.facility_cd = @facilityCd
          ),
          ntss_db5_mst_k AS (
           SELECT
            om.ord_no AS ord_no
            ,ntss_db5_mst_k.in_hospital_cd_1 AS in_hospital_cd_1
           FROM ord_main om
           LEFT JOIN mst_kur ntss_db5_mst_k
           ON om.rst_kur_cd = ntss_db5_mst_k.kur_cd
           WHERE ntss_db5_mst_k.facility_cd = @facilityCd
          ),
          rst_vital_info_1 AS (
           SELECT
            om.ord_no AS ord_no
            ,om_rvi_json ->> ''bp_max'' AS bp_max
            ,om_rvi_json ->> ''bp_min'' AS bp_min
            ,om_rvi_json ->> ''bp_ave'' AS bp_ave
            ,om_rvi_json ->> ''pulse'' AS pulse
           FROM ord_main om
           CROSS JOIN LATERAL json_array_elements(om.rst_vital_info ::json) om_rvi_json
           WHERE cast(om_rvi_json ->> ''bp_class'' AS char(20)) = ''1''
            AND om.rst_vital_info IS NOT NULL
            AND om.facility_cd = @facilityCd
          ),
          rst_vital_info_2 AS (
           SELECT
            om.ord_no AS ord_no
            ,om_rvi_json ->> ''bp_max'' AS bp_max
            ,om_rvi_json ->> ''bp_min'' AS bp_min
            ,om_rvi_json ->> ''bp_ave'' AS bp_ave
            ,om_rvi_json ->> ''pulse'' AS pulse
           FROM ord_main om
           CROSS JOIN LATERAL json_array_elements(om.rst_vital_info ::json) om_rvi_json
           WHERE cast(om_rvi_json ->> ''bp_class'' AS char(20)) = ''2''
            AND om.rst_vital_info IS NOT NULL
            AND om.facility_cd = @facilityCd
          )
          SELECT
           '''' AS hosppatid --患者ID
           ,ntss_db5_om.pat_id AS patid
           ,'''' AS names --氏名
           ,ntss_db5_os.treat_date AS dialysisdate --透析日
           ,ntss_db5_om.ord_no AS dialysisno --透析番号
           ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
           ,ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
           ,ntss_db5_mst_b.bed_name AS bedname --ベッド名
           ,ntss_db5_om.rst_machine_no AS deviceno --装置番号
           ,ntss_db5_om.rst_machine_name AS devicename --装置名
           ,ntss_db5_mst_k.in_hospital_cd_1 AS kurcd --クール
           ,ntss_db5_om.rst_kur_name AS kurname --クール名
           ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
           ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
           ,round(date_part(''epoch'',ntss_db5_om.rst_end_date - ntss_db5_om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
           ,ntss_db5_om.rst_cond_info ::json #>> ''{1,value}'' AS plandialysistime --予定透析時間
           ,ntss_db5_om.rst_dialysis_cnt AS dialysisnum --透析回数
           ,'''' AS lastweight --前回体重
           ,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
           ,ntss_db5_om.rst_weight_info #>> ''{weight_after}'' AS weightafter --後体重
           ,rst_vital_info_1.bp_max AS bpbeforemax --透析前最高血圧
           ,rst_vital_info_1.bp_min AS bpbeforemin --透析前最低血圧
           ,rst_vital_info_1.bp_ave AS bpbeforeave --透析前平均血圧
           ,rst_vital_info_2.bp_max AS bpaftermax --透析後最高血圧
           ,rst_vital_info_2.bp_min AS bpaftermin --透析後最低血圧
           ,rst_vital_info_2.bp_ave AS bpafterave --透析後平均血圧
           ,ntss_db5_om.rst_weight_info #>> ''{water_removal_target}'' AS waterremovaltarget --目標除水量
           ,ntss_db5_om.rst_off_water_info #>> ''{name_1}'' AS revisename1 --除水補正項目１
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_1}'' AS reviseweight1 --除水補正値１
           ,ntss_db5_om.rst_off_water_info #>> ''{name_2}'' AS revisename2 --除水補正項目２
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_2}'' AS reviseweight2 --除水補正値２
           ,ntss_db5_om.rst_off_water_info #>> ''{name_3}'' AS revisename3 --除水補正項目３
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_3}'' AS reviseweight3 --除水補正値３
           ,ntss_db5_om.rst_off_water_info #>> ''{name_4}'' AS revisename4 --除水補正項目４
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_4}'' AS reviseweight4 --除水補正値４
           ,ntss_db5_om.rst_off_water_info #>> ''{name_5}'' AS revisename5 --除水補正項目５
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_5}'' AS reviseweight5 --除水補正値５
           ,rst_vital_info_1.pulse AS pulsebefore --透析前脈拍
           ,rst_vital_info_2.pulse AS pulseafter --透析後脈拍
           ,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_1}'' AS char(20))
             || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_1}'' AS char(20)) AS charge1name --担当者１
           ,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_2}'' AS char(20))
             || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_2}'' AS char(20)) AS charge2name --担当者２
           ,to_char((ntss_db5_om.rst_charge_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate1 --担当日時１
           ,to_char((ntss_db5_om.rst_charge_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate2 --担当日時２
           ,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_1}'' AS char(20))
             || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_1}'' AS char(20)) AS puncture1name --穿刺者１
           ,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_2}'' AS char(20))
             || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_2}'' AS char(20)) AS puncture2name --穿刺者２
           ,to_char((ntss_db5_om.rst_puncture_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate1 --穿刺日時１
           ,to_char((ntss_db5_om.rst_puncture_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate2 --穿刺日時２
           ,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_1}'' AS char(20))
             || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_1}'' AS char(20)) AS collect1name --回収者１
           ,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_2}'' AS char(20))
             || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_2}'' AS char(20)) AS collect2name --回収者２
           ,to_char((ntss_db5_om.rst_return_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate1 --回収日時１
           ,to_char((ntss_db5_om.rst_return_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate2 --回収日時２
           ,ntss_db5_om.rst_in_out_class AS inoutflg --入外
           ,ntss_db5_om.rst_kt_v AS ktvmeasure --Kt/v測定値
           ,ntss_db5_om.rst_weight_info #>> ''{urr}'' AS urr --URR
           ,((((ntss_db5_om.rst_weight_info #>> ''{recrcl_rt}'')::json #>> ''{1}'')::json)::json) #>> ''{rate}'' AS relooprate --再循環率
           ,ntss_db5_om.rst_weight_info #>> ''{ihdf_pll}'' AS pullleaveamount --I-HDF引き残し量
           ,ntss_db5_om.rst_weight_info #>> ''{add_total}'' AS addtotl --除水積算値
           ,ntss_db5_om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
           ,ntss_db5_om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
          FROM
           ord_main ntss_db5_om
           LEFT JOIN ord_schedule ntss_db5_os
           ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
           AND ntss_db5_os.facility_cd = @facilityCd
           LEFT JOIN ntss_db5_mst_b
           ON ntss_db5_mst_b.ord_no = ntss_db5_om.ord_no
           LEFT JOIN ntss_db5_mst_k
           ON ntss_db5_mst_k.ord_no = ntss_db5_om.ord_no
           INNER JOIN rst_vital_info_1
           ON rst_vital_info_1.ord_no = ntss_db5_om.ord_no
           INNER JOIN rst_vital_info_2
           ON rst_vital_info_2.ord_no = ntss_db5_om.ord_no
          WHERE
           ntss_db5_om.is_del = ''0''
           AND ntss_db5_om.facility_cd = @facilityCd
           AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
           AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
           AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2090';


-- V_RST_DIALYSIS_ADD
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid --患者ID
            ,ntss_db5_om.pat_id AS patid
            ,ntss_db5_os.treat_date AS dialysisdate --透析日
            ,ntss_db5_om.ord_no AS dialysisno --透析番号
            ,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
            ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            ,''0'' AS effectflg --実施フラグ
            ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS effectdate --実施日時
            ,ntss_db5_om_iic_json ->> ''content'' AS addition --補足指示内容
            ,'''' AS hosppatid --実施者コード
            ,cast(ntss_db5_om_iic_json ->> ''upd_user_last_name'' AS char(20))
             || cast(ntss_db5_om_iic_json ->> ''upd_user_first_name'' AS char(20)) AS staffname --実施者名
        FROM
            ord_main ntss_db5_om
            LEFT JOIN ord_schedule ntss_db5_os
            ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
            AND ntss_db5_os.facility_cd = @facilityCd
            CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_ind_comment_info ::json) ntss_db5_om_iic_json
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
             AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
            AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2150';


-- V_SCH_DIALYSIS_PLAN
UPDATE sys_data_set
SET "sql"=
        'with ntss_db5_om_1 as (
            SELECT
                array_agg(ntss_db5_om_1.ord_no) AS arr_ord_no
                , ntss_db5_om_1.pat_id
                , ntss_db5_om_1.treat_date AS treat_date
                , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
            FROM
                ord_main ntss_db5_om_1
            WHERE
                ntss_db5_om_1.is_del = ''0''
                AND ntss_db5_om_1.facility_cd = @facilityCd
                AND ntss_db5_om_1.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            GROUP BY
                ntss_db5_om_1.pat_id
                , ntss_db5_om_1.treat_date
        )
        SELECT
            '' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_om.ord_no AS bedno               --ベッド番号
            , ntss_db5_om_mst_b.bed_name AS bedname     --ベッド名
            , ntss_db5_om_mst_k.in_hospital_cd_1 AS kurcd --クールコード
            , ntss_db5_om.rst_kur_name AS kurname       --クール名
            , CASE
                WHEN ntss_db5_om_1.treat_date_count > 1
                    THEN 1
                ELSE 0
                END AS plural                           --同日複数回
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_om.ord_no AS resultdialysisno    --実績透析番号
            , CASE
                WHEN ntss_db5_om.treat_type = 0
                    THEN 1
                ELSE 0
                END AS opeindplan                       --予定作成区分
            , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
            , to_char(ntss_db5_om.rst_start_date, ''hh24:mi'') AS starttime --透析開始時刻
        FROM
            ord_main ntss_db5_om
            INNER JOIN ntss_db5_om_1
                ON ntss_db5_om.ord_no = ANY (ntss_db5_om_1.arr_ord_no)
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_os.pat_id = ntss_db5_om.pat_id
                AND ntss_db5_os.ord_no = ntss_db5_om.ord_no
            LEFT JOIN mst_bed ntss_db5_om_mst_b
                ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
            LEFT JOIN mst_kur ntss_db5_om_mst_k
                ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om.rst_kur_cd
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'');'
WHERE sql_cd = '-2170';


-- V_PAT_RECIPE
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '' AS hosppatid                             --患者ID
            , ntss_db5_op.pat_id AS patid
            , ntss_db5_op.ord_prescription_no AS prescriptno --処方番号
            , to_char(ntss_db5_op.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_op.issue_date AS executedate     --交付日
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''Rp''
                END AS ctlno                            --項目番号
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''F1''
                END AS medicinename                     --薬剤名
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                AND ntss_db5_op_pd_json ->> ''medicine_type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''medicine_cd1''
                END AS medicinecd                       --薬剤コード(院内コード1)
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                AND ntss_db5_op_pd_json ->> ''medicine_type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''medicine_cd2''
                END AS medicinecd2                      --薬剤コード(院内コード2)
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''F5''
                END AS quantity                         --分量
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''F6''
                END AS unit                             --単位
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' IN (''2'', ''3'', ''4'', ''5'')
                    THEN ntss_db5_op_pd_json ->> ''F5''
                END AS dosage                           --用量
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' IN (''2'', ''3'', ''4'', ''5'')
                 THEN ntss_db5_op_mst_tm.take_medicine_cd
                END AS takemedicinecd                   --用法コード
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' IN (''2'', ''3'', ''4'', ''5'')
                    THEN ntss_db5_op_pd_json ->> ''F2''
                END AS takemedicinename                 --用法名
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''2''
                    THEN ntss_db5_op_pd_json ->> ''F5''
                END AS daycount                         --調剤日数
            , '' AS prescriptercd                       --処方者コード
            , '' AS prescriptername                     --処方者名
            , '' AS note                                --備考
            , '' AS userid
        FROM
            ord_prescription ntss_db5_op
            CROSS JOIN LATERAL json_array_elements(ntss_db5_op.prescription_detail ::json) ntss_db5_op_pd_json
            LEFT JOIN mst_take_medicine ntss_db5_op_mst_tm
                ON cast(
                    ntss_db5_op_mst_tm.take_medicine_cd AS varchar (10)
                ) = cast(ntss_db5_op_pd_json ->> ''F2'' AS varchar (10)) -- mst_take_medicineのLEFT JOINの結合条件が間違い
            LEFT JOIN mst_medicine ntss_db5_op_mst_m
                ON cast(ntss_db5_op_mst_m.medicine_cd AS varchar (10)) = ntss_db5_op_pd_json ->> ''medicine_cd''
        WHERE
            ntss_db5_op.is_del = ''0''
            AND ntss_db5_op.facility_cd = @facilityCd
            AND ntss_db5_op_pd_json ->> ''type'' IN (''1'', ''2'', ''3'', ''4'', ''5'')
            AND ntss_db5_op.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')'
WHERE sql_cd = '-2230';


-- V_ONL_DIALYSIS_VITAL
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid --患者ID
            ,
            ntss_db5_om.pat_id AS patid,
            to_char( ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS startdate --開始日時
            ,
            to_char( ntss_db5_mm_1.occur_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS occurdate --発生日時
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''90''
            END AS bpmax --最高血圧
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''91''
            END AS bpmin --最低血圧
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''92''
            END AS bpave --平均血圧
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''93''
            END AS pulse --脈拍
            ,
        CASE
                WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN
                ntss_db5_mm_1.monitor_data ->> ''94''
            END AS temperature --体温
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''-1''
            END AS bloodsugarlevel --血糖値
            ,
            to_char( ntss_db5_mm_1.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS UPDATE --更新日時
            ,
            ntss_db5_mm_1.ord_no AS diadysisno --透析番号
            ,
            ntss_db5_mm_1.data_type AS bpclass --血圧区分

        FROM
            (
            SELECT
                ntss_db5_mm_1.facility_cd,
                ntss_db5_mm_1.ord_no AS ord_no,
                ntss_db5_mm_1.data_type AS data_type,
                ntss_db5_mm_1.monitor_data AS monitor_data,
                MIN ( ntss_db5_mm_1.occur_date ) AS occur_date,
                MIN ( ntss_db5_mm_1.up_date ) AS up_date
            FROM
                mni_monitor ntss_db5_mm_1
            WHERE
                ntss_db5_mm_1.ord_no IS NOT NULL
                AND ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'', ''-1'' )
                AND ntss_db5_mm_1.facility_cd = @facilityCd
                AND ntss_db5_mm_1.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'' )
                AND to_date(@toDate, ''YYYYMMDDHH24MISS'' )
            GROUP BY
                ntss_db5_mm_1.facility_cd,
                ntss_db5_mm_1.ord_no,
                ntss_db5_mm_1.data_type,
                ntss_db5_mm_1.monitor_data
            ) AS ntss_db5_mm_1
            LEFT JOIN ord_main ntss_db5_om ON ntss_db5_mm_1.ord_no = ntss_db5_om.ord_no
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2240';


-- V_DIALYSIS_COMP
UPDATE sys_data_set
SET "sql"=
        'SELECT
           '' AS hosppatid --患者ID
           ,ntss_db5_om.pat_id AS patid
           ,COALESCE(to_char(to_timestamp(ntss_db5_om_rci_json ->> ''occur_date'', ''YYYY-MM-DD hh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss''),
                   to_char(to_timestamp(ntss_db5_om_rti_json ->> ''occur_date'', ''YYYY-MM-DD hh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss'')) AS occurdate --発生日時
           ,CASE
               WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''2'' THEN ''0''
               WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ''1''
               WHEN ntss_db5_om_rti_json ->> ''medicine_type'' IS NULL THEN ''2''
               WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''3'' THEN ''3''
            END AS measureclass --区分
           ,ntss_db5_om_rci_json ->> ''comp_cd'' AS reqcode --愁訴コード
           ,ntss_db5_om_rci_json ->> ''complaint'' AS complaint --愁訴内容
           ,ntss_db5_om_rti_json ->> ''treat_name'' AS treatname --処置名
           ,CASE
               WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.in_hospital_cd_1
               WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_1
            END AS medicinecd1 --薬剤コード1
            ,CASE
               WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.in_hospital_cd_2
               WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_2
            END AS medicinecd2 --薬剤コード2
            ,ntss_db5_om_rti_json ->> ''medicine_name'' AS medicinename --薬剤名称
            ,ntss_db5_om_rti_json ->> ''amount'' AS amount --数量
            ,ntss_db5_om_rti_json ->> ''unit'' AS unit --単位
            ,ntss_db5_om_rti_json ->> ''procedure_name'' AS procedurename --手技名
            ,ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd1 --手技コード1
            ,ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード2
            ,SUBSTR(ntss_db5_om_tsi_json ->> ''treat_staff_name'', 0, 10) treatpersonname --処置者名
            ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
       FROM
           ord_main ntss_db5_om
           cross join lateral json_array_elements(ntss_db5_om.rst_complaint_info ::json) ntss_db5_om_rci_json
           cross join lateral json_array_elements(ntss_db5_om.rst_treatment_info ::json) ntss_db5_om_rti_json
           LEFT JOIN mst_medicine_mix ntss_db5_mst_mm
           ON cast(ntss_db5_mst_mm.medicine_mix_cd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
           AND ntss_db5_mst_mm.facility_cd = @facilityCd
           AND ntss_db5_mst_mm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
           AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
           LEFT JOIN mst_medicine ntss_db5_mst_m
           ON cast(ntss_db5_mst_m.medicine_cd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
           AND ntss_db5_mst_m.facility_cd = @facilityCd
           AND ntss_db5_mst_m.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
           AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
           LEFT JOIN  mst_procedure ntss_db5_mst_p
           ON cast(ntss_db5_mst_p.procedure_cd AS char(4)) = ntss_db5_om_rti_json ->> ''procedure_cd''
           AND ntss_db5_mst_p.facility_cd = @facilityCd
           AND ntss_db5_mst_p.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
           AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
           cross join lateral json_array_elements(ntss_db5_om.rst_treat_staff_info ::json) ntss_db5_om_tsi_json
       WHERE ntss_db5_om.is_del = ''0''
           AND ntss_db5_om.facility_cd = @facilityCd
           AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
           AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2250';

