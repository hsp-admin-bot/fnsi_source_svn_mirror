DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2080,-2071)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2080, '-- 【SQL_CD=-2080】
WITH ntss_db5_pm as (
    SELECT
        ntss_db5_pm.pat_id
        ,ntss_db5_pm.up_date
        ,ntss_db5_pm.tare_info
        ,ntss_db5_pm.is_wheel_chair
    FROM
        pat_main ntss_db5_pm
    WHERE
        ntss_db5_pm.facility_cd = @facilityCd
        AND ntss_db5_pm.is_del != ''1''
)
,ntss_db5_pm_mst_wc as(
    SELECT
        ntss_db5_pm_mst_wc.pat_id
        ,ntss_db5_pm_mst_wc.in_hospital_cd_1
        ,ntss_db5_pm_mst_wc.wheel_chair_name
        ,ntss_db5_pm_mst_wc.wheel_chair_weight 
    FROM
        mst_wheel_chair as ntss_db5_pm_mst_wc
    WHERE
        ntss_db5_pm_mst_wc.facility_cd = @facilityCd
    )
,tabletmp as(
    select 
        ntss_db5_pm.pat_id
        ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS up_date
        ,ntss_db5_pm.tare_info
        ,ntss_db5_pm.is_wheel_chair
        ,ntss_db5_pm_mst_wc.in_hospital_cd_1
        ,ntss_db5_pm_mst_wc.wheel_chair_name
        ,ntss_db5_pm_mst_wc.wheel_chair_weight 
       FROM
           ntss_db5_pm
           LEFT JOIN ntss_db5_pm_mst_wc
           ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           AND ntss_db5_pm.is_wheel_chair = ''1''
)
SELECT
    *
    FROM
        (
        SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 1 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_1}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_1}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_1}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_1}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_1}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_1}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_1}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_1}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_1}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_1}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_1}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_1}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_1}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_1}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_1}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_1}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_1}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_1}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_1}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_1}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_1}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_1}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
            SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 2 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_2}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_2}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_2}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_2}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_2}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_2}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_2}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_2}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_2}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_2}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_2}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_2}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_2}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_2}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_2}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_2}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_2}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_2}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_2}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_2}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_2}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_2}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
        SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 3 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_3}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_3}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_3}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_3}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_3}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_3}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_3}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_3}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_3}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_3}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_3}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_3}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_3}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_3}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_3}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_3}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_3}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_3}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_3}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_3}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_3}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_3}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
        SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 4 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_4}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_4}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_4}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_4}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_4}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_4}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_4}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_4}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_4}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_4}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_4}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_4}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_4}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_4}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_4}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_4}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_4}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_4}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_4}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_4}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_4}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_4}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
        SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 5 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_5}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_5}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_5}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_5}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_5}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_5}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_5}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_5}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_5}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_5}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_5}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_5}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_5}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_5}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_5}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_5}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_5}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_5}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_5}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_5}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_5}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_5}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
    SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 6 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , wheel_chair_name AS revisename                       --風袋補正名(当日)
               , coalesce(wheel_chair_weight,0) AS reviseweight --重量(当日) 
               , in_hospital_cd_1 AS hospwheelchaircd --車椅子コード(当日)
               , wheel_chair_name AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , wheel_chair_name AS monrevisename --風袋補正名(月曜日)
               , coalesce(wheel_chair_weight,0) AS monreviseweight --重量(月曜日)
               , in_hospital_cd_1 AS monhospwheelchaircd --車椅子コード(月曜日)
               , wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , wheel_chair_name AS tuerevisename --風袋補正名(火曜日)
               , coalesce(wheel_chair_weight,0) AS tuereviseweight --重量(火曜日)
               , in_hospital_cd_1 AS tuehospwheelchaircd --車椅子コード(火曜日)
               , wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , wheel_chair_name AS wedrevisename --風袋補正名(水曜日)
               , coalesce(wheel_chair_weight,0) AS wedreviseweight --重量(水曜日)
               , in_hospital_cd_1 AS wedhospwheelchaircd --車椅子コード(水曜日)
               , wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , wheel_chair_name AS thurevisename --風袋補正名(木曜日)
               , coalesce(wheel_chair_weight,0) AS thureviseweight --重量(木曜日)
               , in_hospital_cd_1 AS thuhospwheelchaircd --車椅子コード(木曜日)
               , wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , wheel_chair_name AS frirevisename --風袋補正名(金曜日)
               , coalesce(wheel_chair_weight,0) AS frireviseweight --重量(金曜日)
               , in_hospital_cd_1 AS frihospwheelchaircd --車椅子コード(金曜日)
               , wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , wheel_chair_name AS satrevisename --風袋補正名(土曜日)
               , coalesce(wheel_chair_weight,0) AS satreviseweight --重量(土曜日)
               , in_hospital_cd_1 AS sathospwheelchaircd --車椅子コード(土曜日)
               , wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , wheel_chair_name AS sunrevisename --風袋補正名(日曜日)
               , coalesce(wheel_chair_weight,0) AS sunreviseweight --重量(日曜日)
               , in_hospital_cd_1 AS sunhospwheelchaircd --車椅子コード(日曜日)
               , wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    )as uniontable;
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
