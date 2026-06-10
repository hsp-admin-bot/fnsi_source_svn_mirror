DELETE FROM sys_data_set WHERE sql_cd in(-2310,-2120);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2310,'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_pe.pat_id AS patid
    , to_char(ntss_db5_pe.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , '''' AS names                               --氏名
    , '''' AS namekana                            --患者名(かな）
    , to_char(ntss_db5_pe.reg_date, ''YYYYMMDD'') AS regdate --起票日
    , to_char(ntss_db5_pe.reg_date, ''hh24mi'') AS regtime --起票時刻
    , CASE
        WHEN poc.kind_info ::json ->> ''kind_no'' is not null
            THEN poc.kind_info ::json ->> ''kind_no''
        ELSE ''0''
        END AS kindid                           --種別ID
    , CASE
        WHEN poc.kind_info ::json ->> ''kind_no'' is not null
            THEN poc.kind_info ::json ->> ''kind_name''
        ELSE ''SOAP''
        END AS kindname                         --種別名
    , '''' AS staffcd                             --起票者ID
    , ntss_db5_pe.reg_staff_info #>> ''{reg_staff_cd}'' AS userid
    , ntss_db5_pe.reg_staff_info #>> ''{reg_staff_name}'' AS staffname --起票者名
    , '''' AS staffcd                             --編集者id
    , ntss_db5_pe.reg_staff_info #>> ''{reg_staff_name}'' AS editname --編集者名
    , poc.obs_rec_info ::json ->> ''detail1'' AS detail1 --内容1
    , poc.obs_rec_info ::json ->> ''detail2'' AS detail2 --内容2
    , poc.obs_rec_info ::json ->> ''detail3'' AS detail3 --内容3
    , poc.obs_rec_info ::json ->> ''detail4'' AS detail4 --内容4
FROM
    pat_event ntss_db5_pe
    LEFT JOIN (
        SELECT
            tb1.kind_info
            ,tb1.obs_rec_info
            , tb1.pat_id
        FROM
            (
                select
                    tb2.*
                    , ROW_NUMBER() OVER (PARTITION BY pat_id ORDER BY rec_date DESC) AS num
                FROM
                    pat_obs_rec tb2
            ) tb1
        WHERE
            tb1.num = 1
    ) poc
        ON poc.pat_id = ntss_db5_pe.pat_id
WHERE
    ntss_db5_pe.is_del = ''0''
    AND ntss_db5_pe.facility_cd = @facilityCd
    AND ntss_db5_pe.use_type = ''2''
    AND ntss_db5_pe.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'');',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2120,'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd1 --医療材料コード(院内コード1)
    , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
    , ntss_db5_mst_e.equipment_name AS equipname --医療材料名
    , ntss_db5_mst_c.class_name AS equipclassname --医療材料分類名
    , ntss_db5_om_rqi_json ->> ''needle_type'' AS punctureclass --穿刺針区分
    , ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
    , ntss_db5_mst_e.unit AS unit               --単位
    , ntss_db5_om_rqi_json ->> ''comment'' AS comments --コメント
FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info ::json) ntss_db5_om_rqi_json
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
    LEFT JOIN mst_equipment ntss_db5_mst_e
        ON cast(ntss_db5_mst_e.equipment_cd as char (10)) = cast(ntss_db5_om_rqi_json ->> ''cd'' as char (10))
    LEFT JOIN mst_equipment_class ntss_db5_mst_c
        ON ntss_db5_mst_c.class_cd = ntss_db5_mst_e.class_cd
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                (
                    ntss_db5_om.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_os.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
                )
            )
            ELSE ntss_db5_om.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
            END
    )
    AND ntss_db5_om.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
    AND ntss_db5_om.pat_id IS NOT NULL
    AND ntss_db5_os.treat_date IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

