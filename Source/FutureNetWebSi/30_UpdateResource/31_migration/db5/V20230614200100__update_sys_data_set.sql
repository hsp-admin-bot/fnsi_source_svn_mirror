DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2200);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2200,'WITH ntss_db5_om_1 AS (
    SELECT
        ntss_db5_om_1.ord_no AS ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date AS treat_date
        , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
    FROM
        ord_main ntss_db5_om_1
    WHERE
        1 = 1
        AND ntss_db5_om_1.facility_cd = @facilityCd
        AND ntss_db5_om_1.treat_date IS NOT NULL
        AND (
            CASE
                WHEN @syncMode = ''update''
                    THEN ntss_db5_om_1.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                ELSE ntss_db5_om_1.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
                END
        )
    GROUP BY
        ntss_db5_om_1.ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date
)
, ntss_db5_mst_e AS (
    SELECT
        ntss_db5_mst_e.*
    FROM
        mst_equipment ntss_db5_mst_e
    WHERE
        ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
        AND ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
)
, ntss_db5_om_rei_json AS (
    SELECT
       om.ind_cond_info ::json -> ''6'' ->> ''value''  AS value_6
        , om.ind_cond_info ::json -> ''7'' ->> ''value'' AS value_7
        , om.ind_cond_info ::json -> ''8'' ->> ''value'' AS value_8
        , om.ind_cond_info ::json -> ''9'' ->> ''value'' AS value_9
        , om.ind_cond_info ::json -> ''10'' ->> ''value'' AS value_10
        , om.ind_cond_info ::json -> ''11'' ->> ''value'' AS value_11
        , om.ind_cond_info ::json -> ''12'' ->> ''value'' AS value_12
        , om.ind_cond_info ::json -> ''13'' ->> ''value'' AS value_13
        , ntss_db5_om_rei_json ->> ''amount'' AS amount
        , ntss_db5_om_rei_json ->> ''class_name'' AS class_name
        , ntss_db5_om_rei_json ->> ''name'' AS name
        , ntss_db5_om_rei_json ->> ''cd'' AS cd
        , om.ord_no AS ord_no
    FROM
        ord_main om
        CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND (
            CASE
                WHEN @syncMode = ''update''
                    THEN om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                ELSE om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
                END
        )
)
, ntss_db5_om_iei_json AS (
    SELECT
        ntss_db5_om_iei_json ->> ''unit'' AS unit
        , ntss_db5_om_iei_json ->> ''comment'' AS COMMENT
        , ntss_db5_om_iei_json ->> ''cd'' AS cd
        , om.ord_no AS ord_no
    FROM
        ord_main om
        CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND (
            CASE
                WHEN @syncMode = ''update''
                    THEN om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                ELSE om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
                END
        )
)
, ind_cond_info_table AS (
    SELECT
        value_6
        , value_7
        , value_8
        , value_9
        , value_10
        , value_11
        , value_12
        , value_13
        , amount
        , unit
        , comment
        , class_name
        , name
        , oij.ord_no
    FROM
        ntss_db5_om_rei_json orj
        INNER JOIN ntss_db5_om_iei_json oij
            ON orj.ord_no = oij.ord_no
            AND orj.cd = oij.cd
)
, ntss_db5_mst_list AS (
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_6, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_6 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_7, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_7 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_8, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_8 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''1'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_9, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_9 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''2'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_10, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_10 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''3'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_11, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_11 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_12, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_12 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_13, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_13 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , '''' AS puncture_class
        , '''' AS class_name
        , '''' AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , '''' AS amount
        , '''' AS unit
        , '''' AS comments
    FROM
        ntss_db5_om_rei_json om
        LEFT JOIN ntss_db5_mst_e
            ON om.cd = cast(ntss_db5_mst_e.equipment_cd as char (4))
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , CASE
        WHEN ntss_db5_om_1.treat_date_count > 1
            THEN 1
        ELSE 0
        END AS plural                           --同日複数回
    , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_mst_list.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
    , ntss_db5_mst_list.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
    , ntss_db5_mst_list.class_name AS equipclassname --医療材料分類名
    , SUBSTR(ntss_db5_mst_list.names, 0, 14) AS equipname --医療材料名
    , ntss_db5_mst_list.puncture_class AS punctureclass --医療材料名
    , ntss_db5_mst_list.amount AS amount        --数量
    , ntss_db5_mst_list.unit AS unit            --数量
    , ntss_db5_mst_list.comments AS comments    --コメント
    , '''' AS indicatorcd                         --指示者
    , ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
    , CASE
        WHEN ntss_db5_om.treat_type = 0
            THEN ''1''
        ELSE ''0''
        END AS opeindplan                       --予定作成区分
FROM
    ord_main ntss_db5_om
    INNER JOIN ntss_db5_om_1
        ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
    INNER JOIN ntss_db5_mst_list
        ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            ELSE ntss_db5_om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
            END
    )
    AND ntss_db5_om.pat_id IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);
